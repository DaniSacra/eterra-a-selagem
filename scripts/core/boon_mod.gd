class_name BoonMod
extends Resource
## One number a gift changes. stat is a word the game knows (damage_pct, freeze_time...),
## tag limits it to moves carrying that tag ("" = always), values has one entry per level.

@export var stat: StringName
@export var tag: StringName
@export var values: PackedFloat32Array = PackedFloat32Array()
## Rarer cards multiply this number (damage, burn...). Off for counts, cooldowns and other numbers that must not scale.
@export var by_rarity := true


func value(level: int) -> float:
	if level <= 0 or values.is_empty():
		return 0.0
	return values[mini(level, values.size()) - 1]


## A value as the player reads it: percentages for *_pct and for the undead multiplier, decimal comma otherwise.
static func format(stat_name: StringName, v: float) -> String:
	if String(stat_name).ends_with("_pct"):
		return "%d%%" % roundi(v * 100.0)
	if stat_name == &"undead_mult":
		return "%d%%" % roundi((v - 1.0) * 100.0)
	if is_equal_approx(v, roundf(v)):
		return str(roundi(v))
	return ("%.1f" % v).replace(".", ",")
