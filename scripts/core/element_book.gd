class_name ElementBook
extends RefCounted
## Native elemental states of the Maga (fire = Queimadura, ice = Frio, volt = Eletrizado), pure (04_PLANO C.2).
## Keys are any objects (the game's enemies). Separate from the Bênção states (`burn_t`, `frozen_t`) and from the Marca.
## Applying a held element renews it (no stacking, no duplicate reaction); two states together make one reaction,
## chosen Térmico > Sobrecarga > Cristalização, consuming only that pair. Reactions apply no states.
## GP-5: the Trindade's residue (a reaction a direct blow made leaves it; the third element makes the other two reactions at once).

const FIRE := &"fire"
const ICE := &"ice"
const VOLT := &"volt"

# Tunables (ElementKit in the data feeds these).
var burn_time := 3.0
var burn_dps := 4.0
var volt_time := 3.0
var cold_time := 3.0
var cold_freeze_at := 3
var react_gap := 0.5
var thermal := 35.0
var overload := 25.0
var overload_radius := 1.8
var crystal_freeze := 0.8
var crystal_boss_poise := 25.0
## Multiplier on Térmico and Sobrecarga damage and on the Cristalização's Quebra (Catalisador).
var react_pct := 0.0
## Trindade: with it on, a reaction struck by a direct blow leaves a residue of `residue_time` seconds; the third element (the one
## that was not in the reaction) landing in it makes the other two reactions at once and the residue goes.
var trinity := false
var residue_time := 3.0

var now := 0.0
## key -> {burn: s, cold: s, hits: int, volt: s, last: float, res: residue seconds left, pair: the residue's reaction kind}
var _s: Dictionary = {}
## key -> {n: hits, t: when the window opened} (count_hit)
var _h: Dictionary = {}


func _row(key: Object) -> Dictionary:
	if not _s.has(key):
		_s[key] = {"burn": 0.0, "cold": 0.0, "hits": 0, "volt": 0.0, "last": -1000.0, "res": 0.0, "pair": -1}
	return _s[key]


func has_fire(key: Object) -> bool:
	return _s.has(key) and float(_s[key]["burn"]) > 0.0


func has_ice(key: Object) -> bool:
	return _s.has(key) and float(_s[key]["cold"]) > 0.0


func has_volt(key: Object) -> bool:
	return _s.has(key) and float(_s[key]["volt"]) > 0.0


## Whether `key` holds the state of this element now.
func has_element(key: Object, element: StringName) -> bool:
	return has_fire(key) if element == FIRE else has_ice(key) if element == ICE else has_volt(key)


## Seconds of Trindade residue left on `key` (0: none).
func residue(key: Object) -> float:
	return float(_s[key]["res"]) if _s.has(key) else 0.0


## Frio hits held (0 when expired); at `cold_freeze_at` the caller freezes the target through its own `frozen_t`.
func cold_hits(key: Object) -> int:
	return int(_s[key]["hits"]) if has_ice(key) else 0


func cold_full(key: Object) -> bool:
	return cold_hits(key) >= cold_freeze_at


func tracked() -> int:
	return _s.size()


## The two elements a reaction is made of.
static func pair_of(kind: int) -> Array[StringName]:
	match kind:
		Reaction.Kind.THERMAL:
			return [FIRE, ICE]
		Reaction.Kind.OVERLOAD:
			return [FIRE, VOLT]
	return [ICE, VOLT]


## The reaction two elements make.
static func kind_of(a: StringName, b: StringName) -> int:
	if a == FIRE and b == ICE or a == ICE and b == FIRE:
		return Reaction.Kind.THERMAL
	if a == FIRE or b == FIRE:
		return Reaction.Kind.OVERLOAD
	return Reaction.Kind.CRYSTAL


## Applies `element` to `key`. `resists` is a boss or armoured target (Quebra instead of a freeze). `source` is where it came from
## (&"direct": a blow of hers; &"area", &"spread", &"ult"): only a direct blow's reaction leaves a residue (GP-5 4.1).
## Returns the reactions it caused: none, one, or (Trindade) the two a residue's third element makes.
func apply(key: Object, element: StringName, resists: bool = false, source: StringName = &"direct") -> Array[Reaction]:
	var out: Array[Reaction] = []
	var r := _row(key)
	var triple := _triple(key, r, element, resists)
	if not triple.is_empty():
		return triple
	match element:
		FIRE:
			r["burn"] = burn_time
		ICE:
			r["cold"] = cold_time
			r["hits"] = mini(int(r["hits"]) + 1, cold_freeze_at) if float(r["cold"]) > 0.0 else 1
		VOLT:
			r["volt"] = volt_time
	var re := _react(key, r, resists)
	if re != null:
		out.append(re)
		if trinity and source == &"direct":
			r["res"] = residue_time
			r["pair"] = re.kind
	return out


## The residue's third element lands: the other two reactions together, states and residue cleared. The triple opens no residue and
## respects react_gap (it is one shot).
func _triple(key: Object, r: Dictionary, element: StringName, resists: bool) -> Array[Reaction]:
	var out: Array[Reaction] = []
	if not trinity or float(r["res"]) <= 0.0 or now - float(r["last"]) < react_gap - 0.0001:
		return out
	var pair := pair_of(int(r["pair"]))
	if pair.has(element):
		return out
	for other in pair:
		out.append(_make(kind_of(other, element), key, resists))
	r["burn"] = 0.0
	_drop_cold(r)
	r["volt"] = 0.0
	r["res"] = 0.0
	r["last"] = now
	return out


func _make(kind: int, key: Object, resists: bool) -> Reaction:
	var re := Reaction.make(kind, key)
	match kind:
		Reaction.Kind.THERMAL:
			re.damage = thermal * (1.0 + react_pct)
		Reaction.Kind.OVERLOAD:
			re.damage = overload * (1.0 + react_pct)
			re.radius = overload_radius
		_:
			if resists:
				re.poise = crystal_boss_poise * (1.0 + react_pct)
			else:
				re.freeze = crystal_freeze
	return re


func _react(key: Object, r: Dictionary, resists: bool) -> Reaction:
	if now - float(r["last"]) < react_gap - 0.0001:
		return null
	var fire := float(r["burn"]) > 0.0
	var ice := float(r["cold"]) > 0.0
	var volt := float(r["volt"]) > 0.0
	var re: Reaction = null
	if fire and ice:
		re = _make(Reaction.Kind.THERMAL, key, resists)
		r["burn"] = 0.0
		_drop_cold(r)
	elif fire and volt:
		re = _make(Reaction.Kind.OVERLOAD, key, resists)
		r["burn"] = 0.0
		r["volt"] = 0.0
	elif ice and volt:
		re = _make(Reaction.Kind.CRYSTAL, key, resists)
		_drop_cold(r)
		r["volt"] = 0.0
	if re != null:
		r["last"] = now
	return re


func _drop_cold(r: Dictionary) -> void:
	r["cold"] = 0.0
	r["hits"] = 0


## Advances the clock; returns key -> Queimadura damage this step. Expired rows are forgotten.
func tick(dt: float) -> Dictionary:
	now += dt
	var dmg: Dictionary = {}
	var gone: Array = []
	for key in _s:
		var r: Dictionary = _s[key]
		if float(r["burn"]) > 0.0:
			dmg[key] = burn_dps * minf(dt, float(r["burn"]))
			r["burn"] = maxf(0.0, float(r["burn"]) - dt)
		r["cold"] = maxf(0.0, float(r["cold"]) - dt)
		if float(r["cold"]) <= 0.0:
			r["hits"] = 0
		r["volt"] = maxf(0.0, float(r["volt"]) - dt)
		r["res"] = maxf(0.0, float(r["res"]) - dt)
		if float(r["burn"]) <= 0.0 and float(r["cold"]) <= 0.0 and float(r["volt"]) <= 0.0 and float(r["res"]) <= 0.0 \
				and now - float(r["last"]) >= react_gap:
			gone.append(key)
	for key in gone:
		_s.erase(key)
	return dmg


## Death of one enemy.
func clear(key: Object) -> void:
	_s.erase(key)
	_h.erase(key)


## Room change.
func clear_all() -> void:
	_s.clear()
	_h.clear()


## Every key holding a state (the caller forgets the dead ones).
func keys() -> Array:
	return _s.keys()


## Counts one hit on `key` inside a window of `window` seconds (it restarts when the window ran out). True on the `need`-th
## hit, and the count starts over (Centelha: three hits put Queimadura on the target).
func count_hit(key: Object, need: int, window: float) -> bool:
	var h: Dictionary = _h.get(key, {"n": 0, "t": -1000.0})
	if now - float(h["t"]) > window:
		h["n"] = 0
	if int(h["n"]) == 0:
		h["t"] = now
	h["n"] = int(h["n"]) + 1
	if int(h["n"]) >= need:
		_h.erase(key)
		return true
	_h[key] = h
	return false
