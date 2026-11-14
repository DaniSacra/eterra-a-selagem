class_name BoonState
extends RefCounted
## The gifts the paladin holds in this run, the numbers they add up to, and the draw of the next three cards.

const DUO_WEIGHT := 3.0

var catalog: Array[Boon] = []
var levels: Dictionary = {}
## Rarity of each owned gift (Boon.Rarity); a gift keeps the best rarity it was taken at.
var rarities: Dictionary = {}
var _cache: Dictionary = {}


func _init(boons: Array[Boon] = []) -> void:
	catalog = boons


static func load_catalog(dir: String = "res://data/boons/") -> Array[Boon]:
	var out: Array[Boon] = []
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir + path))
	return out


func level(id: StringName) -> int:
	return levels.get(id, 0)


func rarity(id: StringName) -> Boon.Rarity:
	return rarities.get(id, Boon.Rarity.COMMON)


func rarity_mult(id: StringName) -> float:
	return Boon.RARITY_MULT[rarity(id)]


## The owned gift riding on an action (null when the action is free or for Slot.NONE).
func in_slot(slot: Boon.Slot) -> Boon:
	if slot == Boon.Slot.NONE:
		return null
	for b in owned():
		if b.slot == slot:
			return b
	return null


## The owned gift that taking b would throw away (another gift on the same action), or null.
func replaced_by(b: Boon) -> Boon:
	var current := in_slot(b.slot)
	return current if current != null and current != b else null


## Draws the rarity of a card.
static func roll_rarity(rng: RandomNumberGenerator, weights: Array[float] = Boon.RARITY_WEIGHT) -> Boon.Rarity:
	return rng.rand_weighted(PackedFloat32Array(weights)) as Boon.Rarity


func find(id: StringName) -> Boon:
	for b in catalog:
		if b.id == id:
			return b
	return null


func owned() -> Array[Boon]:
	var out: Array[Boon] = []
	for b in catalog:
		if level(b.id) > 0:
			out.append(b)
	return out


func can_offer(b: Boon) -> bool:
	if level(b.id) >= b.max_level:
		return false
	for need in b.requires:
		if level(need) <= 0:
			return false
	return true


## Raises a gift by one level, at least at the rarity given; a gift on an action replaces the one there.
## Returns the new level (0 when it could not be taken).
func take(b: Boon, at: Boon.Rarity = Boon.Rarity.COMMON) -> int:
	if not can_offer(b):
		return 0
	var old := replaced_by(b)
	if old != null:
		levels.erase(old.id)
		rarities.erase(old.id)
	levels[b.id] = level(b.id) + 1
	rarities[b.id] = maxi(rarity(b.id), at)
	_cache.clear()
	return levels[b.id]


## Sum of a stat over every owned gift. With tags, only modifiers that are untagged or match one of them count.
func stat(stat_name: StringName, tags: Array[StringName] = []) -> float:
	var use_cache := tags.is_empty()
	if use_cache and _cache.has(stat_name):
		return _cache[stat_name]
	var total := 0.0
	for b in catalog:
		var lv := level(b.id)
		if lv <= 0:
			continue
		for m in b.mods:
			if m.stat == stat_name and (m.tag == &"" or tags.has(m.tag)):
				total += m.value(lv) * (rarity_mult(b.id) if m.by_rarity else 1.0)
	if use_cache:
		_cache[stat_name] = total
	return total


## Up to n different gifts to choose from. Combinations that just became possible come up more often.
func offers(rng: RandomNumberGenerator, n: int = 3) -> Array[Boon]:
	var pool: Array[Boon] = []
	var weights := PackedFloat32Array()
	for b in catalog:
		if can_offer(b):
			pool.append(b)
			weights.append(DUO_WEIGHT if b.is_duo() else 1.0)
	var out: Array[Boon] = []
	while out.size() < n and not pool.is_empty():
		var i := rng.rand_weighted(weights)
		out.append(pool[i])
		pool.remove_at(i)
		weights.remove_at(i)
	return out


## True when some owned gift can still grow (a door may then promise one more level).
func can_grow() -> bool:
	for b in owned():
		if can_offer(b):
			return true
	return false


## Up to n owned gifts that can still grow, to choose which one gets the extra level.
func grow_offers(rng: RandomNumberGenerator, n: int = 3) -> Array[Boon]:
	var pool: Array[Boon] = []
	for b in owned():
		if can_offer(b):
			pool.append(b)
	var out: Array[Boon] = []
	while out.size() < n and not pool.is_empty():
		out.append(pool.pop_at(rng.randi() % pool.size()))
	return out
