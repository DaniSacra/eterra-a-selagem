class_name ArenaVariant
extends Resource
## Another way of dressing the same arena (cycle C12, RoomLayout.variants): mirrored across x = 0, another set of
## obstacles, other doors. RoomLayout.variant(n) gives the layout as it stands in variant n (0: the arena itself).

## Everything seen in a mirror across x = 0 (floor, holes, obstacles, spawns, doors, camera bounds, way in).
@export var mirror := false
## Stands in for the arena's obstacles when not empty.
@export var obstacles: Array[ArenaObstacle] = []
## Stand in for the arena's doors and spawn zones when not empty.
@export var exits: Array[ArenaExit] = []
@export var spawns: Array[Rect2] = []
@export var late_spawns: Array[Rect2] = []
## Stands in for the arena's floor when set (another hole, a fallen bridge).
@export var floor: FloorShape
