class_name BoonMod
extends Resource
## One number a gift changes. stat is a word the game knows (damage_pct, freeze_time...), tag limits it to moves
## carrying that tag ("" = always). The number grows as in Hades II (C13-05, GetProcessedValue): level 1 is base
## (times the rarity, when by_rarity), and every level after it adds a fixed gain, per_level[0] for level 2,
## per_level[1] for level 3 and so on, the last one again for every level after; the rarity never scales the gains.

@export var stat: StringName
@export var tag: StringName
@export var base := 0.0
@export var per_level: PackedFloat32Array = PackedFloat32Array()
## Rarer cards multiply the base (damage, burn...). Off for counts, cooldowns and other numbers that must not scale.
@export var by_rarity := true


## The number at a level, with a rarity's multiplier (applied only when by_rarity).
func at(level: int, mult: float = 1.0) -> float:
	if level <= 0:
		return 0.0
	return base * (mult if by_rarity else 1.0) + gains(level)


## The number at a level of a common card.
func value(level: int) -> float:
	return at(level, 1.0)


## What the levels after the first add up to at this level.
func gains(level: int) -> float:
	var total := 0.0
	for lv in range(2, level + 1):
		if per_level.is_empty():
			break
		total += per_level[mini(lv - 2, per_level.size() - 1)]
	return total


## A value as the player reads it: percentages for *_pct and for the undead multiplier, decimal comma otherwise.
static func format(stat_name: StringName, v: float) -> String:
	if String(stat_name).ends_with("_pct"):
		return "%d%%" % roundi(v * 100.0)
	if stat_name == &"undead_mult":
		return "%d%%" % roundi((v - 1.0) * 100.0)
	if is_equal_approx(v, roundf(v)):
		return str(roundi(v))
	return ("%.1f" % v).replace(".", ",")
