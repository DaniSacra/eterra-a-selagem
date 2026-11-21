class_name Psalms
extends RefCounted
## The Psalms of a run (E4, docs/design/e4_psalms.md), pure: no nodes, no clock of its own. Which can be offered, the
## draw of a Psalm card over a Blessings draw, which are taken, and the small state their effects keep (the shelters
## of the dodge, the lights of the flock, the stone's wait). PsalmPlay (scripts/game/psalm_play.gd) feeds it the fight
## and does what it answers.
##
## - A Psalm can be offered when one held thing of each of its three groups is found, never the same thing for two
##   groups (met): a Blessing or an Elo owned (BoonState), or a Gift equipped (PsalmDef.GIFT before its id).
## - Each card of a draw becomes a Psalm with the stage's chance (StageDef.psalm_chance 10%, 5% at the guardian),
##   drawn among the ones that can be offered (fill); the rng is only read when one can.
## - Never one already taken, never another of a theme taken, never more than MAX_PER_RUN in a run. No level.

const DIR := "res://data/psalms/"
## Psalms a run can take (D-59: rare; Hades II limits a legendary per god, ours is a run's two).
const MAX_PER_RUN := 2
## Chance a card is a Psalm when one can be offered (Hades II's legendary): a room's and the guardian's. These are the
## defaults; a stage carries its own (StageDef.psalm_chance, guardian_psalm_chance).
const CHANCE := 0.1
const CHANCE_GUARDIAN := 0.05

var catalog: Array[PsalmDef] = []
## The hero has the circle of light (HeroDef.circle): the Sentinela, which walks with it, is never offered without it.
var circle := true
## Taken in this run, in order.
var taken: Array[PsalmDef] = []
## Offered on a card in this run (ids), for the Codex and the "Salmo descoberto" greeting.
var seen := {}

## SHELTER: the shelters standing (x, z, seconds left), the oldest first, and their radius.
var shelters: Array[Vector3] = []
var shelter_radius := 0.0
## FLOCK: the lights gathered.
var lights := 0
## STONE: seconds before another stone may be planted.
var stone_left := 0.0


func _init(defs: Array[PsalmDef] = []) -> void:
	catalog = defs


static func load_catalog(dir: String = DIR) -> Array[PsalmDef]:
	var out: Array[PsalmDef] = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir + path))
	return out


func find(id: StringName) -> PsalmDef:
	for p in catalog:
		if p.id == id:
			return p
	return null


func has(id: StringName) -> bool:
	return taken.any(func(p: PsalmDef) -> bool: return p.id == id)


## The Psalm taken with this effect (null: none).
func holding(effect: PsalmDef.Effect) -> PsalmDef:
	for p in taken:
		if p.effect == effect:
			return p
	return null


## What the hero holds, as the entries of a group read it: Blessing and Elo ids, and Gift ids after PsalmDef.GIFT.
static func held_of(boons: BoonState, gifts: Array[StringName]) -> Dictionary:
	var out := {}
	if boons != null:
		for b in boons.owned():
			out[String(b.id)] = true
	for g in gifts:
		out[PsalmDef.GIFT + String(g)] = true
	return out


## True when one held thing of each group is found, a different one for each group.
static func met(p: PsalmDef, held: Dictionary) -> bool:
	return _match(p.requires, 0, held, {})


## The held things that open a Psalm, one per group in the groups' order (what its card shows, E4-03); empty when
## it is not met.
static func matching(p: PsalmDef, held: Dictionary) -> PackedStringArray:
	var used := {}
	if not _match(p.requires, 0, held, used):
		return PackedStringArray()
	# used keeps its insertion order: the entry chosen for group 0, then group 1...
	return PackedStringArray(used.keys())


static func _match(groups: Array[PackedStringArray], i: int, held: Dictionary, used: Dictionary) -> bool:
	if i >= groups.size():
		return true
	for entry in groups[i]:
		if held.has(entry) and not used.has(entry):
			used[entry] = true
			if _match(groups, i + 1, held, used):
				return true
			used.erase(entry)
	return false


## The Psalms that may come on a card now (see the class's comment).
func eligible(boons: BoonState, gifts: Array[StringName]) -> Array[PsalmDef]:
	var out: Array[PsalmDef] = []
	if taken.size() >= MAX_PER_RUN:
		return out
	var held := held_of(boons, gifts)
	for p in catalog:
		if p.effect == PsalmDef.Effect.SENTINEL and not circle:
			continue
		if taken.has(p) or taken.any(func(t: PsalmDef) -> bool: return t.theme == p.theme):
			continue
		if met(p, held):
			out.append(p)
	return out


## Turns cards of a draw into Psalm cards (BoonState.Card.psalm), each with the chance, among the eligible ones (each
## at most once); a draw short of n cards may get one more. Returns the cards.
func fill(cards: Array[BoonState.Card], rng: RandomNumberGenerator, chance: float, boons: BoonState,
		gifts: Array[StringName], n: int = 3) -> Array[BoonState.Card]:
	if chance <= 0.0:
		return cards
	var pool := eligible(boons, gifts)
	for i in n:
		if pool.is_empty():
			break
		if rng.randf() >= chance:
			continue
		var c := BoonState.Card.new()
		c.psalm = pool.pop_at(rng.randi() % pool.size())
		if i < cards.size():
			cards[i] = c
		else:
			cards.append(c)
	return cards


## Takes a Psalm (false when it may not be taken: already, its theme, or two already).
func take(p: PsalmDef) -> bool:
	if p == null or taken.size() >= MAX_PER_RUN or taken.has(p) or taken.any(func(t: PsalmDef) -> bool: return t.theme == p.theme):
		return false
	taken.append(p)
	return true


func ids() -> Array[String]:
	var out: Array[String] = []
	for p in taken:
		out.append(String(p.id))
	return out


func step(dt: float) -> void:
	stone_left = maxf(0.0, stone_left - dt)
	var i := shelters.size() - 1
	while i >= 0:
		shelters[i].z -= dt
		if shelters[i].z <= 0.0:
			shelters.remove_at(i)
		i -= 1


## A room ends: what stood on its floor goes with it (the lights gathered stay).
func clear() -> void:
	shelters.clear()
	stone_left = 0.0


# ---------- SHELTER ----------

## A shelter where the dodge ended; past p.count the oldest goes. Returns how many went (to end their drawing).
func shelter(at: Vector2, p: PsalmDef) -> int:
	shelter_radius = p.radius
	shelters.append(Vector3(at.x, at.y, p.duration))
	var gone := 0
	while shelters.size() > maxi(p.count, 1):
		shelters.pop_front()
		gone += 1
	return gone


## True when a shot of this radius at p touches a shelter (it is undone there).
func bars(p: Vector2, r: float) -> bool:
	for s in shelters:
		if p.distance_to(Vector2(s.x, s.y)) < shelter_radius + r:
			return true
	return false


# ---------- FLOCK ----------

## A kill gathers a light, up to p.count.
func gather(p: PsalmDef) -> void:
	lights = mini(lights + 1, p.count)


## The lights the special lets go (all of them; none left after).
func release() -> int:
	var n := lights
	lights = 0
	return n


## The ways the n waves more fly, around dir: one each side in turn, spread degrees apart (n 1: spread to one side).
static func fan(dir: Vector2, n: int, spread: float) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for k in n:
		var turn := ((k >> 1) + 1) * spread * (1.0 if k % 2 == 0 else -1.0)
		out.append(dir.rotated(deg_to_rad(turn)))
	return out


# ---------- STONE ----------

## A spin may plant a stone: true (and the wait starts) when none stands.
func plant(p: PsalmDef) -> bool:
	if stone_left > 0.0:
		return false
	stone_left = p.duration
	return true
