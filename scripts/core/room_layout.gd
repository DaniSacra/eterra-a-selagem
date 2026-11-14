class_name RoomLayout
extends Resource
## The shape of one room: its size and what stands in it. Positions (x, z) in meters from the room's center.

## Half the room's width (x) and depth (z).
@export var half := Vector2(15, 12)
## Pillars: (x, z, radius that blocks the way).
@export var pillars: Array[Vector3] = []
## Cold light falling from cracks in the ceiling.
@export var shafts: Array[Vector2] = []
