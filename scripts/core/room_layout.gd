class_name RoomLayout
extends Resource
## The shape of one room: its size and what stands in it. Positions (x, z) in meters from the room's center.

## Half the room's width (x) and depth (z).
@export var half := Vector2(15, 12)
## Pillars: (x, z, radius that blocks the way).
@export var pillars: Array[Vector3] = []
## Cold light falling from cracks in the ceiling.
@export var shafts: Array[Vector2] = []
## A platform over the abyss (balustrades on the sides, a raised dais with the portals to the north, stairs down to
## the south) instead of a hall closed by walls. Built by Arena from ArenaKit.
@export var platform := false
## Stone fire bowls on the platform (x, z): its warm light; they block like a small pillar.
@export var braziers: Array[Vector2] = []
