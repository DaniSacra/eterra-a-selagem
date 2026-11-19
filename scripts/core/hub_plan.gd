class_name HubPlan
extends RefCounted
## The hub's plan (HUB-01, HUB-B1; docs/design/hub_spec_art.md sections 2.1 to 2.4): its floor, what blocks on it,
## where the hero arrives, the camera's fixed point and the five stations' use points and sign anchors. The plan is
## drawn in the hub's own frame (u to the right of the screen, v up the screen, away from the camera, the fountain's
## middle at the origin) and turned into the world by the camera's yaw (to_world), so the axis portal, fountain and
## arrival is the screen's vertical. The hub's RoomLayout is made here, never in the descent's StageDef (it never
## enters the draw of arenas nor the Compêndio). Provisional pieces until HUB-B2 (environment-artist) dresses it.
##   var layout := HubPlan.layout()          # Arena.build(layout)
##   HubPlan.STATIONS                        # ids, in the order of the spec's table 2.4

## The stations, in the spec's order.
const PORTAL := &"portal"
const VENDOR := &"vendor"
const TREE := &"tree"
const SMITH := &"smith"
const BOOK := &"book"
const STATIONS: Array[StringName] = [PORTAL, VENDOR, TREE, SMITH, BOOK]
## The walkable floor (local u, v; flat, y 0): 25 m wide and 16.5 m deep.
const FLOOR: Array[Vector2] = [Vector2(-8.5, -10.5), Vector2(-12.5, -7.5), Vector2(-12.5, 6.0), Vector2(12.5, 6.0),
	Vector2(12.5, -7.5), Vector2(8.5, -10.5)]
## Where the hero appears (local) and the camera's fixed point (local) with how far it may move for his safe frame.
const ARRIVAL := Vector2(-2.4, -8.8)
const CAM_TARGET := Vector2(0.0, 1.0)
const CAM_REACH := 3.0
## Each station's use point on the floor (local) and the anchor its sign stands on (local u, v and height y).
const USE := {
	PORTAL: Vector2(0.0, 4.6), VENDOR: Vector2(-9.2, 3.0), TREE: Vector2(9.4, 3.0), SMITH: Vector2(-8.4, -3.8),
	BOOK: Vector2(8.6, -3.8),
}
const ANCHOR := {
	PORTAL: Vector3(0.0, 7.0, 2.8), VENDOR: Vector3(-11.4, 4.2, 2.6), TREE: Vector3(11.0, 4.4, 3.2),
	SMITH: Vector3(-10.6, -5.0, 2.2), BOOK: Vector3(11.0, -5.0, 2.2),
}
## Focus (spec 2.4): a station comes into focus 2.2 m from its use point and leaves it at 2.8; the one in focus only
## gives way to another this much nearer.
const FOCUS_IN := 2.2
const FOCUS_OUT := 2.8
const FOCUS_SWITCH := 0.4


## A point of the hub's frame (u, v) on the world's floor (x, z), for the camera's yaw (degrees).
static func to_world(local: Vector2, yaw_deg: float = Feel.live().cam_yaw) -> Vector2:
	var a := deg_to_rad(yaw_deg)
	return Vector2(cos(a) * local.x - sin(a) * local.y, -sin(a) * local.x - cos(a) * local.y)


## A floor point of the world (x, z) in the hub's frame (u, v).
static func to_local(world: Vector2, yaw_deg: float = Feel.live().cam_yaw) -> Vector2:
	var a := deg_to_rad(yaw_deg)
	return Vector2(cos(a) * world.x - sin(a) * world.y, -sin(a) * world.x - cos(a) * world.y)


## A station's use point in the world.
static func use_point(id: StringName, yaw_deg: float = Feel.live().cam_yaw) -> Vector2:
	return to_world(USE[id], yaw_deg)


## A station's sign anchor in the world (x, height, z).
static func anchor(id: StringName, yaw_deg: float = Feel.live().cam_yaw) -> Vector3:
	var a: Vector3 = ANCHOR[id]
	var p := to_world(Vector2(a.x, a.y), yaw_deg)
	return Vector3(p.x, a.z, p.y)


## The hub's room: its floor, what stands on it (provisional pieces with the plan's footprints; every one is drawn,
## nothing invisible), the arrival, the camera's point. look &"hub" (HubLook).
static func layout(yaw_deg: float = Feel.live().cam_yaw) -> RoomLayout:
	var l := RoomLayout.new()
	l.id = &"hub"
	l.look = &"hub"
	l.name_key = &"hub_name"
	l.guardian = false
	var walk := PackedVector2Array()
	for p in FLOOR:
		walk.append(to_world(p, yaw_deg))
	var polys: Array[PackedVector2Array] = [walk]
	l.floor = FloorShape.poly(polys)
	l.half = l.floor.extent()
	l.hero_spawn = to_world(ARRIVAL, yaw_deg)
	l.hero_facing = to_world(Vector2(0.0, 1.0), yaw_deg)  # up the screen, to the portal
	l.cam_target = to_world(CAM_TARGET, yaw_deg)
	l.cam_reach = CAM_REACH
	var turn := -deg_to_rad(yaw_deg)
	var w := func(u: float, v: float) -> Vector2: return to_world(Vector2(u, v), yaw_deg)
	l.obstacles.assign([
		ArenaObstacle.circle(w.call(0.0, 0.0), 1.6, &"hub_fountain", 0.8),
		ArenaObstacle.box(w.call(-11.4, 4.2), Vector2(0.5, 1.6), turn, &"hub_counter", 1.0),
		ArenaObstacle.circle(w.call(-10.6, -5.0), 0.6, &"hub_anvil", 0.9),
		ArenaObstacle.circle(w.call(-12.0, -5.8), 0.45, &"hub_smith", 1.9),
		ArenaObstacle.circle(w.call(12.2, 5.4), 2.6, &"hub_dais", 0.5),
		ArenaObstacle.box(w.call(11.0, -5.0), Vector2(0.4, 0.5), turn, &"hub_lectern", 1.1),
		ArenaObstacle.circle(w.call(-5.0, -10.2), 0.3, &"hub_lamp", 3.0),
		ArenaObstacle.circle(w.call(5.0, -10.2), 0.3, &"hub_lamp", 3.0),
	])
	return l
