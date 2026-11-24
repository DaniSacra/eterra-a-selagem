class_name Courage
extends RefCounted
## Coragem (BL-02): help with no menu for whoever falls early again and again. Each death in room LAST_ROOM or earlier
## gives the next descent LIFE_PER_STACK more life and one pomegranate, up to MAX_STACKS; it resets when a descent gets
## past LAST_ROOM, is won, or when a Juramento is sworn. Saved per hero (heroes.<id>.courage, a count); pure rules here.

const MAX_STACKS := 3
const LIFE_PER_STACK := 3.0
const POMS_PER_STACK := 1
## The last room whose death still counts as "early".
const LAST_ROOM := 5
const KEY := "courage"


## The stacks after a descent ended: outcome "death", "victory" or "quit"; room the one reached (1 based).
static func after(stacks: int, outcome: String, room: int) -> int:
	if outcome == "victory" or room > LAST_ROOM:
		return 0
	if outcome == "death":
		return mini(stacks + 1, MAX_STACKS)
	return stacks


static func life(stacks: int) -> float:
	return LIFE_PER_STACK * clampi(stacks, 0, MAX_STACKS)


static func pomegranates(stacks: int) -> int:
	return POMS_PER_STACK * clampi(stacks, 0, MAX_STACKS)


## What the descent starts with: the saved stacks, none under a Juramento.
static func active(stacks: int, vowed: bool) -> int:
	return 0 if vowed else clampi(stacks, 0, MAX_STACKS)


static func stacks_of(data: Dictionary, hero_id: String) -> int:
	return clampi(int(SaveData.hero(data, hero_id).get(KEY, 0)), 0, MAX_STACKS)


static func set_stacks(data: Dictionary, hero_id: String, stacks: int) -> void:
	SaveData.hero(data, hero_id)[KEY] = clampi(stacks, 0, MAX_STACKS)
