class_name RoomLayout
extends Resource
## The shape of one room: its size and what stands in it. Positions (x, z) in meters from the room's center.
## Cycle C12 (arenas): the same Resource describes every arena (the catacomb hall, the crypt, the rift hall, the
## garden; the boss chamber): what it is (id, size, difficulty, where in the descent, how many fight in it), its floor
## (FloorShape, with holes), what stands on it (ArenaObstacle: the collision and the look come from the same data),
## where enemies rise, its doors (ArenaExit), the box the camera looks inside and its variants (ArenaVariant).
## Written by _stage in tools/make_data.gd.

enum Size { SMALL, MEDIUM, LARGE, LONG }

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

@export_group("Arena")
## Its name in code and in the run's log (&"hall", &"crypt", &"rift", &"garden").
@export var id: StringName = &""
## Text shown for 2 s on walking in (data/text_pt.tres; &"": none).
@export var name_key: StringName = &""
## Who draws it (Arena: &"hall" the catacomb hall, &"crypt", &"rift", &"garden": an ArenaRoom look).
@export var look: StringName = &""
@export var size_class := Size.MEDIUM
## 0 low, 1 middle, 2 high: a high one is never drawn before 40% of the descent (RunMap.HARD_FROM).
@export_range(0, 2) var difficulty := 0
## Where in the descent it may be drawn for a fight: from and to, as EncounterGen.progress (0 the first room, 1 the last
## fight before the shop).
@export var depth := Vector2(0.0, 1.0)
## The fewest and the most enemies standing at once in it (0: the tier's own); never past the tier's most.
@export var max_alive := Vector2i.ZERO
## At most this many shooters (EnemyDef.Behavior.ARCHER) at once (0: no limit); roles never drawn here.
@export var max_ranged := 0
@export var banned_roles: Array[StringName] = []
## Which rooms may be held in it besides fights: the guardian's, the fountain's.
@export var guardian := true
@export var fountain := false
## What stands on the floor (columns, sarcophagi, the trunk, roots).
@export var obstacles: Array[ArenaObstacle] = []
## Where enemies may rise (rectangles of floor; empty: anywhere on it). Every one is reached from the way in.
@export var spawns: Array[Rect2] = []
## Zones used only from the second wave on (near the way in: the first wave never rises beside the paladin).
@export var late_spawns: Array[Rect2] = []
## Its doors, in order (empty: the look places them, as the catacomb hall does).
@export var exits: Array[ArenaExit] = []
## The box the point the camera looks at stays inside (zero size: the room's rectangle less Game.CAM_MARGIN).
@export var cam_bounds := Rect2()
## Other ways of dressing it (variant 1 is variants[0]).
@export var variants: Array[ArenaVariant] = []


## The layout as it stands in variant n (0 or out of range: itself). A new Resource; the floor is mirrored too.
func variant(n: int) -> RoomLayout:
	if n <= 0 or n > variants.size():
		return self
	var v := variants[n - 1]
	var out := duplicate() as RoomLayout
	out.variants = []
	if not v.obstacles.is_empty():
		out.obstacles = v.obstacles.duplicate()
	if not v.exits.is_empty():
		out.exits = v.exits.duplicate()
	if not v.spawns.is_empty():
		out.spawns = v.spawns.duplicate()
	if not v.late_spawns.is_empty():
		out.late_spawns = v.late_spawns.duplicate()
	if v.floor != null:
		out.floor = v.floor
	if v.mirror:
		out._mirror()
	return out


## How many ways it can be dressed (itself and its variants).
func variant_count() -> int:
	return 1 + variants.size()


func _mirror() -> void:
	var obs: Array[ArenaObstacle] = []
	for o in obstacles:
		obs.append(o.mirrored())
	obstacles = obs
	var ex: Array[ArenaExit] = []
	for e in exits:
		ex.append(e.mirrored())
	exits = ex
	var sp: Array[Rect2] = []
	for r in spawns:
		sp.append(mirror_rect(r))
	spawns = sp
	var late: Array[Rect2] = []
	for r in late_spawns:
		late.append(mirror_rect(r))
	late_spawns = late
	if cam_bounds.has_area():
		cam_bounds = mirror_rect(cam_bounds)
	hero_spawn.x = -hero_spawn.x
	hero_facing.x = -hero_facing.x
	boss_spawn.x = -boss_spawn.x
	cam_target.x = -cam_target.x
	var cols: Array[Vector3] = []
	for p in pillars:
		cols.append(Vector3(-p.x, p.y, p.z))
	pillars = cols
	if floor != null:
		var f := floor.duplicate() as FloorShape
		f.center.x = -f.center.x
		f.polys = _mirror_polys(f.polys)
		f.holes = _mirror_polys(f.holes)
		f.changed()
		floor = f


static func mirror_rect(r: Rect2) -> Rect2:
	return Rect2(-r.end.x, r.position.y, r.size.x, r.size.y)


static func _mirror_polys(list: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	for q in list:
		var m := PackedVector2Array()
		for i in range(q.size() - 1, -1, -1):
			m.append(Vector2(-q[i].x, q[i].y))
		out.append(m)
	return out
