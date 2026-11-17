class_name Juramentos
extends RefCounted
## The Juramentos of a descent (E6, D-63; Hades II's Oath of the Unseen, rules and numbers in
## docs/design/e6_juramentos.md): optional difficulty in ranks, chosen before going down, open after the first victory.
## Each rank weighs some Peso (Hades II's Fear); the total is what a victory is worth (MasteryCurve.weight_xp) and what
## the save keeps as the best won. Pure: the run asks it for its numbers (scale, stage_for, boss_for, more_waves,
## denial) and the screen for the ranks and the Peso.

const DIR := "res://data/juramentos/"
## The words a JuramentoDef may change, and where the run reads them:
## enemy_hp_pct (Horde.vow_hp, every enemy, elites, guardians and Morvath too), enemy_damage_pct (Player.hurt_scale),
## enemy_speed_pct (Horde.speed_scale), enemy_count_pct (more_waves), elite_pct (stage_for: each pool's elite_chance),
## heal_pct (Player.heal_scale), price_pct (stage_for: the shop's prices), boon_denial (denial: Blessings not taken that
## leave the descent), boss_rival (boss_for: Morvath's rests and raised dead).
const STATS: Array[StringName] = [&"enemy_hp_pct", &"enemy_damage_pct", &"enemy_speed_pct", &"enemy_count_pct",
	&"elite_pct", &"heal_pct", &"price_pct", &"boon_denial", &"boss_rival"]
## Morvath under boss_rival: this many more raised dead standing in each phase that raises any, and in the ritual.
const RIVAL_ADDS := 2

var catalog: Array[JuramentoDef] = []
## id (StringName) to the rank chosen (only ranks above 0 are kept).
var ranks: Dictionary = {}


func _init(defs: Array[JuramentoDef] = [], chosen: Dictionary = {}) -> void:
	catalog = defs
	set_all(chosen)


static func load_catalog(dir: String = DIR) -> Array[JuramentoDef]:
	var out: Array[JuramentoDef] = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir + path))
	out.sort_custom(func(a: JuramentoDef, b: JuramentoDef) -> bool: return a.order < b.order)
	return out


## Open once Morvath was sealed once (Hades II: after the first victory over the last guardian).
static func unlocked(data: Dictionary) -> bool:
	return int(data.get("wins", 0)) > 0


## "id:rank,id:rank" (--juramentos) as a dictionary of ranks (a bare id is rank 1).
static func parse(text: String) -> Dictionary:
	var out := {}
	for part in text.split(",", false):
		var bits := part.split(":", false)
		if bits.is_empty():
			continue
		out[StringName(bits[0].strip_edges())] = int(bits[1]) if bits.size() > 1 else 1
	return out


func find(id: StringName) -> JuramentoDef:
	for d in catalog:
		if d.id == id:
			return d
	return null


func rank(id: StringName) -> int:
	return int(ranks.get(id, 0))


## Sets a rank, kept within the Juramento's own (0 takes it off); an unknown id is ignored.
func set_rank(id: StringName, r: int) -> void:
	var d := find(id)
	if d == null:
		return
	var kept := clampi(r, 0, d.max_rank())
	if kept > 0:
		ranks[id] = kept
	else:
		ranks.erase(id)


## Every rank from a dictionary (the save's, any key type, numbers as floats from JSON); what is unknown is dropped.
func set_all(chosen: Dictionary) -> void:
	ranks.clear()
	for id: Variant in chosen:
		if (id is String or id is StringName) and (chosen[id] is int or chosen[id] is float):
			set_rank(StringName(id), int(chosen[id]))


## One rank up, past the top back to 0 (the screen's Enter); returns the new rank.
func cycle(id: StringName, dir: int = 1) -> int:
	var d := find(id)
	if d == null:
		return 0
	set_rank(id, wrapi(rank(id) + dir, 0, d.max_rank() + 1))
	return rank(id)


## The total Peso.
func weight() -> int:
	var total := 0
	for d in catalog:
		total += d.weight(rank(d.id))
	return total


## The highest Peso there is (every Juramento at its top).
func max_weight() -> int:
	var total := 0
	for d in catalog:
		total += d.weight(d.max_rank())
	return total


## The sum of a word's numbers at the ranks chosen (0 with none).
func value(stat: StringName) -> float:
	var total := 0.0
	for d in catalog:
		if d.stat == stat:
			total += d.value(rank(d.id))
	return total


## 1 + value: what a number is multiplied by (never below 0).
func scale(stat: StringName) -> float:
	return maxf(0.0, 1.0 + value(stat))


## The ranks as plain values (id: rank, only the ones on) for the save, the RESULT and the run log.
func to_dict() -> Dictionary:
	var out := {}
	for d in catalog:
		if rank(d.id) > 0:
			out[String(d.id)] = rank(d.id)
	return out


## The stage of this descent: elite_pct more chance for each part of a fight to come as its elite (Hades II's Menace
## brings stronger foes) and price_pct dearer shop items (Debt). The same stage when neither is on.
func stage_for(stage: StageDef) -> StageDef:
	var elites := value(&"elite_pct")
	var prices := value(&"price_pct")
	if is_zero_approx(elites) and is_zero_approx(prices):
		return stage
	var out: StageDef = stage.duplicate()
	if not is_zero_approx(elites):
		var pools: Array[EncounterPool] = []
		for p in stage.pools:
			var copy: EncounterPool = p.duplicate()
			copy.elite_chance = clampf(p.elite_chance + elites, 0.0, 1.0)
			pools.append(copy)
		out.pools = pools
	if not is_zero_approx(prices):
		var groups: Array[ShopGroup] = []
		for g in stage.shop_groups:
			var copy: ShopGroup = g.duplicate()
			var dearer := PackedInt32Array()
			for p in g.prices:
				dearer.append(roundi(p * (1.0 + prices)))
			copy.prices = dearer
			groups.append(copy)
		out.shop_groups = groups
	return out


## Morvath under boss_rival (ours: Hades II's Rivals give the guardians new moves, which we do not have): rests
## between his attacks shorter by the value, and RIVAL_ADDS more raised dead standing. The same def when off.
func boss_for(def: BossDef) -> BossDef:
	var v := value(&"boss_rival")
	if is_zero_approx(v):
		return def
	var out: BossDef = def.duplicate()
	var rests := PackedFloat32Array()
	for r in def.rest:
		rests.append(r * maxf(0.0, 1.0 - v))
	out.rest = rests
	out.chain_rest = def.chain_rest * maxf(0.0, 1.0 - v)
	var caps := PackedInt32Array()
	for c in def.adds_cap:
		caps.append(c + RIVAL_ADDS if c > 0 else c)
	out.adds_cap = caps
	out.ritual_cap = def.ritual_cap + RIVAL_ADDS
	return out


## A fight's waves with enemy_count_pct more enemies (Hades II's Hordes): each wave grows by round(size x value),
## the kinds of the wave taken in turn from its first (the fight's highlight). Waves too big for the room wait their
## turn (EncounterGen's cap), as always.
func more_waves(waves: Array[Array]) -> Array[Array]:
	var pct := value(&"enemy_count_pct")
	if pct <= 0.0:
		return waves
	var out: Array[Array] = []
	for w in waves:
		var copy: Array = w.duplicate()
		for i in roundi(w.size() * pct):
			copy.append(w[i % w.size()])
		out.append(copy)
	return out


## The Blessings that leave the descent after one is chosen (Hades II's Denial: 2 of the ones not chosen): the first
## boon_denial of the offered ids other than the chosen one.
func denial(offered: Array[StringName], chosen: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	var n := roundi(value(&"boon_denial"))
	for id in offered:
		if out.size() >= n:
			break
		if id != chosen and not out.has(id):
			out.append(id)
	return out


## The save's block (made when missing): the ranks chosen for the next descent and the highest Peso won.
static func block(data: Dictionary) -> Dictionary:
	if not data.get("juramentos") is Dictionary:
		data["juramentos"] = SaveData.juramentos_defaults()
	return data.juramentos


## Keeps the highest Peso won (on a victory). Returns true when it is a new best.
static func record_win(data: Dictionary, weight_won: int) -> bool:
	var b := block(data)
	if weight_won <= int(b.get("best", 0)):
		return false
	b["best"] = weight_won
	return true
