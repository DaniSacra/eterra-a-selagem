class_name BoonMod
extends Resource
## One number a gift changes. stat is a word the game knows (damage_pct, freeze_time...),
## tag limits it to moves carrying that tag ("" = always), values has one entry per level.

@export var stat: StringName
@export var tag: StringName
@export var values: PackedFloat32Array = PackedFloat32Array()


func value(level: int) -> float:
	if level <= 0 or values.is_empty():
		return 0.0
	return values[mini(level, values.size()) - 1]
