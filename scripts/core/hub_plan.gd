class_name HubPlan
extends RefCounted
## The hub's plan (HUB-01, HUB-B1; docs/design/hub_spec_art.md sections 2.1 to 2.4): its floor, what blocks on it,
## where the hero arrives, the camera's fixed point and the five stations' use points and sign anchors. The plan is
## drawn in the hub's own frame (u to the right of the screen, v up the screen, away from the camera, the fountain's
## middle at the origin) and turned into the world by the camera's yaw (to_world), so the axis portal, fountain and
## arrival is the screen's vertical. The hub's RoomLayout is made here, never in the descent's StageDef (it never
## enters the draw of arenas nor the Compêndio). HubLook (HUB-B2) draws every piece on these footprints.
##   var layout := HubPlan.layout()          # Arena.build(layout)
##   HubPlan.STATIONS                        # ids, in the order of the spec's table 2.4

## The stations, in the spec's order.
const PORTAL := &"portal"
const VENDOR := &"vendor"
const TREE := &"tree"
const SMITH := &"smith"
const BOOK := &"book"
const STATIONS: Array[StringName] = [PORTAL, VENDOR, TREE, SMITH, BOOK]
## The walkable floor (local u, v; flat, y 0): 50 m wide and 33 m deep (HUB-B2, the PO: the first plan, 25 x 16.5 m,
## was a fifth of Hades II's hub; the composition kept, every distance about doubled), centred on the fountain (the
## camera's margins are measured from the middle); its south corners cut, the arrival stairs in the south edge.
const HALF_U := 25.0
const NORTH := 16.5
const SOUTH := -16.5
const CUT := Vector2(8.0, 6.0)
const FLOOR: Array[Vector2] = [Vector2(-HALF_U + CUT.x, SOUTH), Vector2(-HALF_U, SOUTH + CUT.y), Vector2(-HALF_U, NORTH),
	Vector2(HALF_U, NORTH), Vector2(HALF_U, SOUTH + CUT.y), Vector2(HALF_U - CUT.x, SOUTH)]
## Where the hero appears (local) and the camera's point (local) with how far it may move off it. The camera keeps
## to its point and moves only as much as his safe frame needs (CamFrame.hold: never nearer than 18% to an edge), up
## to CAM_REACH from it: across 50 m it goes wherever he walks, and at the edges it shows the hub, not the cliff under
## it (a world box, cam_bounds, cannot: the hub is turned 35 degrees to the world's axes, so any box that lets it reach
## the side stations lets it look 5 m past the south edge too). 16 m lets the near camera (CamRig.near, plus its
## CamFrame.slack) keep him in the safe frame in the far corners (test_camera_near).
const ARRIVAL := Vector2(-3.0, -14.6)
const CAM_TARGET := Vector2(0.0, 1.0)
const CAM_REACH := 16.0
## Each station's use point on the floor (local) and the anchor its sign stands on (local u, v and height y).
const USE := {
	PORTAL: Vector2(0.0, 15.0), VENDOR: Vector2(-20.4, 9.0), TREE: Vector2(18.6, 8.6), SMITH: Vector2(-19.8, -6.0),
	BOOK: Vector2(19.8, -6.0),
}
const ANCHOR := {
	PORTAL: Vector3(0.0, 18.0, 2.8), VENDOR: Vector3(-22.8, 10.4, 2.6), TREE: Vector3(21.6, 11.6, 3.6),
	SMITH: Vector3(-22.0, -7.6, 2.2), BOOK: Vector3(22.2, -7.6, 2.2),
}
## Where the stations' pieces stand (local; the layout's footprints and HubLook's drawing read these).
const FOUNTAIN := Vector3(0.0, 0.0, 2.3)
const COUNTER := Vector2(-22.8, 10.4)
const ANVIL := Vector2(-22.0, -7.6)
const SMITH_SPOT := Vector2(-23.4, -8.6)
const DAIS := Vector3(21.6, 11.6, 3.2)
const LECTERN := Vector2(22.2, -7.6)
## Lamp posts along the south and on the cut corners, benches round the fountain (local u, v), flower beds by the
## arrival and along the side walls before their statues (u, v, half sizes); all off the straight ways from the arrival to the stations.
const LAMPS: Array[Vector2] = [Vector2(-7.5, -15.9), Vector2(7.5, -15.9), Vector2(-20.6, -13.0), Vector2(20.6, -13.0)]
const BENCHES: Array[Vector2] = [Vector2(-7.5, 0.0), Vector2(7.5, 0.0)]
const BENCH := Vector2(0.35, 1.3)
const BEDS: Array[Vector4] = [Vector4(-10.5, -13.2, 1.2, 0.5), Vector4(10.5, -13.2, 1.2, 0.5),
	Vector4(-24.3, 1.0, 0.6, 2.6), Vector4(24.3, 1.0, 0.6, 2.6)]
## Great urns on plinths in the square, off the ways (local u, v; radius).
const URNS: Array[Vector2] = [Vector2(-16.0, 1.0), Vector2(16.0, 1.0), Vector2(-13.0, -4.5), Vector2(13.0, -4.5)]
const URN_R := 0.6
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


## The hub's room: its floor, what stands on it (HubLook draws each piece on its footprint; every one is drawn,
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
	var w := func(p: Vector2) -> Vector2: return to_world(p, yaw_deg)
	var obstacles: Array[ArenaObstacle] = [
		ArenaObstacle.circle(w.call(Vector2(FOUNTAIN.x, FOUNTAIN.y)), FOUNTAIN.z, &"hub_fountain", 0.8),
		ArenaObstacle.box(w.call(COUNTER), Vector2(0.5, 1.6), turn, &"hub_counter", 1.0),
		ArenaObstacle.circle(w.call(ANVIL), 0.6, &"hub_anvil", 0.9),
		ArenaObstacle.circle(w.call(SMITH_SPOT), 0.45, &"hub_smith", 1.9),
		ArenaObstacle.circle(w.call(Vector2(DAIS.x, DAIS.y)), DAIS.z, &"hub_dais", 0.5),
		ArenaObstacle.box(w.call(LECTERN), Vector2(0.4, 0.5), turn, &"hub_lectern", 1.1),
	]
	for p in LAMPS:
		obstacles.append(ArenaObstacle.circle(w.call(p), 0.3, &"hub_lamp", 3.0))
	for p in BENCHES:
		obstacles.append(ArenaObstacle.box(w.call(p), BENCH, turn, &"hub_bench", 0.5))
	for p in URNS:
		obstacles.append(ArenaObstacle.circle(w.call(p), URN_R, &"hub_urn", 1.6))
	for b in BEDS:
		obstacles.append(ArenaObstacle.box(w.call(Vector2(b.x, b.y)), Vector2(b.z, b.w), turn, &"hub_bed", 0.5))
	l.obstacles.assign(obstacles)
	return l
