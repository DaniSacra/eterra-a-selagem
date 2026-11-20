class_name DealtBy
extends RefCounted
## The damage the hero dealt, by where it came from (DT-016, E3-05): each action (attack, special, cast, dash, the
## Omegas), every Blessing that acts on its own (by its id), the ultimate, burns, shatters and the rest. Read in the
## RESULT and the run log (dealt_by) to balance Gifts and Blessings. Pure.

var by: Dictionary = {}


## Where a hit with these tags came from. A Blessing's own hits carry &"skill", its family tag and its id (Skills).
static func source(tags: Array[StringName]) -> StringName:
	if tags.has(&"echo"):
		return &"echo"  # Eco da Verdade's echo of a blow (Fatia 2)
	if tags.has(&"psalm"):
		return &"psalm"  # what a Psalm adds (E4): the Pastor's waves, the Rocha's stone, the Sentinela's blows
	if tags.has(&"ultimate"):
		return &"ultimate"
	if tags.has(&"skill"):
		return tags[2] if tags.size() > 2 else &"skill"
	if tags.has(&"omega"):
		return &"omega_special" if tags.has(&"heavy") else &"omega_attack"
	if tags.has(&"dash"):
		return &"dash"
	if tags.has(&"heavy"):
		return &"special"
	if tags.has(&"light"):
		return &"attack"
	if tags.has(&"cast"):
		return &"cast"
	if tags.has(&"ember"):
		return &"embers"
	if tags.has(&"mark"):
		return &"mark"
	return &"other"


func add(from: StringName, amount: float) -> void:
	if amount <= 0.0:
		return
	var key := String(from) if from != &"" else "other"
	by[key] = by.get(key, 0.0) + amount


## A copy with whole numbers, the largest first (for the RESULT).
func report() -> Dictionary:
	var keys := by.keys()
	keys.sort_custom(func(a: String, b: String) -> bool: return by[a] > by[b])
	var out := {}
	for k: String in keys:
		out[k] = roundi(by[k])
	return out


func total() -> float:
	var t := 0.0
	for k: String in by:
		t += by[k]
	return t
