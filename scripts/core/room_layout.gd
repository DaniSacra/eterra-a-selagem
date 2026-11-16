class_name RoomLayout
extends Resource
## The shape of one room: its size and what stands in it. Positions (x, z) in meters from the room's center.

## Half the room's width (x) and depth (z).
@export var half := Vector2(15, 12)
## Pillars: (x, z, radius that blocks the way).
@export var pillars: Array[Vector3] = []
## Cold light falling from cracks in the ceiling.
@export var shafts: Array[Vector2] = []
## The catacomb hall of the reference image (CatacombHall: a platform over the abyss, the portal on its dais) instead
## of a hall closed by walls; its size and pieces are CatacombHall's.
@export var platform := false

@export_group("Boss chamber")
## A boss's own round chamber (the Seal Chamber of cycle C11, Arena._build_boss_room): its floor is `floor`, nothing
## else collides, the paladin and the boss rise where this layout says and the camera keeps to cam_target.
@export var chamber := false
## The floor bodies stand on (null: the room's rectangle). In the chamber: a circle of 12.5 m (the balustrade's inner
## face), so the paladin's middle walks up to 12 m from the seal.
@export var floor: FloorShape
## Where the paladin walks in and the way he faces; where the boss stands when the fight begins.
@export var hero_spawn := Vector2.ZERO
@export var hero_facing := Vector2.UP
@export var boss_spawn := Vector2.ZERO
## The camera looks at this floor point and moves off it only to keep the paladin in the safe frame (CamFrame.keep),
## never more than cam_reach meters (0: it follows the paladin as in the hall).
@export var cam_target := Vector2.ZERO
@export var cam_reach := 0.0
