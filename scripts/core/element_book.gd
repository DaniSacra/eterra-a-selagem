class_name ElementBook
extends RefCounted
## Native elemental states of the Maga (fire = Queimadura, ice = Frio, volt = Eletrizado), pure (04_PLANO C.2).
## Keys are any objects (the game's enemies). Separate from the Bênção states (`burn_t`, `frozen_t`) and from the Marca.
## Applying a held element renews it (no stacking, no duplicate reaction); two states together make one reaction,
## chosen Térmico > Sobrecarga > Cristalização, consuming only that pair. Reactions apply no states.

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
var thermal := 20.0
var overload := 15.0
var overload_radius := 1.8
var crystal_freeze := 0.8
var crystal_boss_poise := 25.0
## Multiplier on Térmico and Sobrecarga damage (Reação Amplificada).
var react_pct := 0.0

var now := 0.0
## key -> {burn: s, cold: s, hits: int, volt: s, last: float}
var _s: Dictionary = {}


func _row(key: Object) -> Dictionary:
	if not _s.has(key):
		_s[key] = {"burn": 0.0, "cold": 0.0, "hits": 0, "volt": 0.0, "last": -1000.0}
	return _s[key]


func has_fire(key: Object) -> bool:
	return _s.has(key) and float(_s[key]["burn"]) > 0.0


func has_ice(key: Object) -> bool:
	return _s.has(key) and float(_s[key]["cold"]) > 0.0


func has_volt(key: Object) -> bool:
	return _s.has(key) and float(_s[key]["volt"]) > 0.0


## Frio hits held (0 when expired); at `cold_freeze_at` the caller freezes the target through its own `frozen_t`.
func cold_hits(key: Object) -> int:
	return int(_s[key]["hits"]) if has_ice(key) else 0


func cold_full(key: Object) -> bool:
	return cold_hits(key) >= cold_freeze_at


func tracked() -> int:
	return _s.size()


## Applies `element` to `key`. `resists` is a boss or armoured target (Quebra instead of a freeze).
## Returns the reactions it caused (zero or one).
func apply(key: Object, element: StringName, resists: bool = false) -> Array[Reaction]:
	var out: Array[Reaction] = []
	var r := _row(key)
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
	return out


func _react(key: Object, r: Dictionary, resists: bool) -> Reaction:
	if now - float(r["last"]) < react_gap - 0.0001:
		return null
	var fire := float(r["burn"]) > 0.0
	var ice := float(r["cold"]) > 0.0
	var volt := float(r["volt"]) > 0.0
	var re: Reaction = null
	if fire and ice:
		re = Reaction.make(Reaction.Kind.THERMAL, key)
		re.damage = thermal * (1.0 + react_pct)
		r["burn"] = 0.0
		_drop_cold(r)
	elif fire and volt:
		re = Reaction.make(Reaction.Kind.OVERLOAD, key)
		re.damage = overload * (1.0 + react_pct)
		re.radius = overload_radius
		r["burn"] = 0.0
		r["volt"] = 0.0
	elif ice and volt:
		re = Reaction.make(Reaction.Kind.CRYSTAL, key)
		if resists:
			re.poise = crystal_boss_poise
		else:
			re.freeze = crystal_freeze
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
		if float(r["burn"]) <= 0.0 and float(r["cold"]) <= 0.0 and float(r["volt"]) <= 0.0 \
				and now - float(r["last"]) >= react_gap:
			gone.append(key)
	for key in gone:
		_s.erase(key)
	return dmg


## Death of one enemy.
func clear(key: Object) -> void:
	_s.erase(key)


## Room change.
func clear_all() -> void:
	_s.clear()
