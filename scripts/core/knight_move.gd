class_name KnightMove
extends Resource
## One entry of a guardian's priority list (data/enemies/knight.tres, EnemyDef.moves; docs/design/sworn_gawain.md, principle 2):
## the list runs top to bottom, the first entry whose conditions hold is the one it does, one at a time, none cut by the next.

## What it does: &"throw" (the shield), &"charge" (a run along a line; `count` of them in a row).
@export var id: StringName
## Charges in a row (only for &"charge").
@export var count := 1
## Open while its life is at or under this share of the full bar (1: from the start; 0.5: from half its life).
@export_range(0.0, 1.0, 0.01) var from_life := 1.0
## Seconds before it may do this again (counted from when it starts), and before it may do it the first time in a fight.
@export var cooldown := 0.0
@export var first := 0.0
## The paladin's distance it needs (meters; max 0: no limit).
@export var min_dist := 0.0
@export var max_dist := 0.0
