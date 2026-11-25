class_name ArenaVariant
extends Resource
## Another way of dressing the same arena (cycle C12, RoomLayout.variants): mirrored across x = 0, another set of
## obstacles, other doors. RoomLayout.variant(n) gives the layout as it stands in variant n (0: the arena itself).

## RP-07: where in the descent this variant may be drawn (EncounterGen.progress; RoomLayout.variants_at).
@export var depth := Vector2(0.0, 1.0)
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
## Stands in for the arena's floor that strikes (E5, the runes' variant B) and its named parts, when set.
@export var hazard: HazardDef
## AT-Q1: stand in for the arena's breakables when not empty.
@export var breakables: Array[BreakablePiece] = []
## PT-25-9: stand in for the arena's streams and rifts (RoomLayout.gaps) and their fall damage, when not empty.
@export var gaps: Array[Rect2] = []
@export var gap_fall := 0.0
## OF-08: stand in for the arena's vein spots when not empty.
@export var gather_spots := PackedVector2Array()
@export var areas: Array[Rect2] = []
@export var area_names: PackedStringArray = PackedStringArray()
