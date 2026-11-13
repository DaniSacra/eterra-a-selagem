class_name BoonState
extends RefCounted
## The gifts the paladin holds in this run, the numbers they add up to, and the draw of the next three cards.

const DUO_WEIGHT := 3.0

var catalog: Array[Boon] = []
var levels: Dictionary = {}
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


## Raises a gift by one level. Returns the new level (0 when it could not be taken).
func take(b: Boon) -> int:
	if not can_offer(b):
		return 0
	levels[b.id] = level(b.id) + 1
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
				total += m.value(lv)
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
