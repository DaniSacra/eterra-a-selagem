class_name Enchants
extends RefCounted
## The rules of the Encantos (Rejogabilidade, Fatia 2; sistemas.md 1.7), pure: which may be offered (learned at the
## Forja, not taken, not excluded by a Gift equipped or an Encanto taken), at most MAX a descent (StageDef.enchant_max)
## and three to choose. The descent's are held in BoonState.enchants (their stats count in BoonState.stat).
##
## API for the UI (the Encanto's choice; game side Game.open_enchant_choice, signal Game.enchant_offered):
##   Enchants.load_catalog() -> Array[EnchantDef]; Enchants.learned(catalog, data) -> those that may come.
##   Enchants.offers(pool, taken, gifts, rng, n) -> up to n to choose (never one taken nor excluded).
##   EnchantDef: id, name_key, desc_key, slot (Boon.Slot), mods.

const DIR := "res://data/enchants/"
## Offered at once.
const CHOICES := 3


static func load_catalog(dir: String = DIR) -> Array[EnchantDef]:
	var out: Array[EnchantDef] = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir.path_join(path)))
	return out


## Those that may come in a descent: learned from the start or inscribed at the Forja (forge.inscribed of the hero).
static func learned(catalog: Array[EnchantDef], data: Dictionary = {}, hero_id := SaveData.FIRST_HERO) -> Array[EnchantDef]:
	var inscribed: Array = []
	if not data.is_empty():
		inscribed = Forge.block(data, hero_id).get("inscribed", [])
	var out: Array[EnchantDef] = []
	for e in catalog:
		if e.learned or inscribed.has(String(e.id)):
			out.append(e)
	return out


## True when e may be offered with these taken and these Gifts equipped.
static func allowed(e: EnchantDef, taken: Array[EnchantDef], gifts: Array[StringName]) -> bool:
	if taken.has(e):
		return false
	for x in e.excludes:
		if gifts.has(x):
			return false
		for t in taken:
			if t.id == x:
				return false
	for t in taken:
		if t.excludes.has(e.id):
			return false
	return true


## Up to n Encantos to choose, in a shuffled order on rng.
static func offers(pool: Array[EnchantDef], taken: Array[EnchantDef], gifts: Array[StringName],
		rng: RandomNumberGenerator, n: int = CHOICES) -> Array[EnchantDef]:
	var can: Array[EnchantDef] = []
	for e in pool:
		if allowed(e, taken, gifts):
			can.append(e)
	for i in range(can.size() - 1, 0, -1):
		var j := rng.randi() % (i + 1)
		var t := can[i]
		can[i] = can[j]
		can[j] = t
	return can.slice(0, n)
