class_name Leveling
extends RefCounted
## Experience from the orbs of light the enemies leave behind.

const BASE := 5
const STEP := 3
const CURVE := 0.12


## Orbs needed to go from this level to the next.
static func needed(level: int) -> int:
	return BASE + STEP * (level - 1) + int(CURVE * (level - 1) * (level - 1))


## Adds experience. Returns { level, xp, gained } where gained is how many levels went up.
static func add(level: int, xp: int, amount: int) -> Dictionary:
	xp += amount
	var gained := 0
	while xp >= needed(level):
		xp -= needed(level)
		level += 1
		gained += 1
	return {"level": level, "xp": xp, "gained": gained}
