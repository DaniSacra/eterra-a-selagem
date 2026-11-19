class_name HubLook
extends ArenaRoom
## The hub's look (HUB-01; plan in HubPlan and docs/design/hub_spec_art.md). HUB-B1 only: a provisional build on the
## plan so the hub can be walked and tested; the scenery, light and palette of the spec (portal in the stairs, lions,
## stations, fountain) are HUB-B2's (environment-artist). Every blocking piece of the layout is drawn on its own
## footprint by ArenaRoom.piece (plain stone shafts and blocks); the edges are walls (closed_edge, low toward the
## camera); a flight of stairs, a landing and a pointed arch with the portal's sheet stand past the north edge.

## The walls round the floor (m; closed_edge lowers the ones toward the camera).
const WALL_HEIGHT := 5.0
## The portal past the north edge (HubPlan's frame, u and v in m; spec 3.1): stairs from v 6 to 9, 8 m wide, six steps;
## the landing at 1.2 m; the arch's opening 3.6 x 5.0 m at v 11.
const STAIRS_FROM := 6.0
const STAIRS_WIDTH := 8.0
const STAIRS_STEPS := 6
const STAIRS_RISE := 0.2
const STAIRS_RUN := 0.5
const LANDING := Vector3(11.0, 1.2, 2.5)
const ARCH_AT := 11.0
const ARCH := Vector2(3.6, 5.0)
## Provisional air and light (the spec's 4.1 numbers, to be tuned by HUB-B2): warmer and lighter than any room.
const AIR := {
	&"sky": Color(0.06, 0.08, 0.13), &"fog": Color(0.14, 0.13, 0.13), &"fog_depth": Vector2(60.0, 140.0),
	&"ambient": Color(0.78, 0.76, 0.72), &"ambient_gain": 1.9, &"moon": Color(1.0, 0.92, 0.8), &"moon_energy": 1.0,
	&"moon_shadow": true,
}
const KEY := Color(1.0, 0.85, 0.65)
const KEY_ENERGY := 1.2


func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		super.edge(a, b, out, kind, faces)
		return
	var la := HubPlan.to_local(a)
	var lb := HubPlan.to_local(b)
	var half := STAIRS_WIDTH * 0.5
	if absf(la.y - STAIRS_FROM) < 0.01 and absf(lb.y - STAIRS_FROM) < 0.01:
		# the north wall opens on the stairs to the portal
		var lo := minf(la.x, lb.x)
		var hi := maxf(la.x, lb.x)
		if lo < -half:
			closed_edge(HubPlan.to_world(Vector2(lo, STAIRS_FROM)), HubPlan.to_world(Vector2(-half, STAIRS_FROM)), out, WALL_HEIGHT, ashlar())
		if hi > half:
			closed_edge(HubPlan.to_world(Vector2(half, STAIRS_FROM)), HubPlan.to_world(Vector2(hi, STAIRS_FROM)), out, WALL_HEIGHT, ashlar())
		return
	closed_edge(a, b, out, WALL_HEIGHT, ashlar())


func air() -> Dictionary:
	return AIR


func _light() -> void:
	key_light(KEY, KEY_ENERGY)


func dress() -> void:
	var up := HubPlan.to_world(Vector2(0.0, 1.0))
	var foot := HubPlan.to_world(Vector2(0.0, STAIRS_FROM))
	m.stairs(Vector3(foot.x, 0.0, foot.y), up, STAIRS_WIDTH, STAIRS_STEPS, STAIRS_RISE, STAIRS_RUN, stone())
	var landing := HubPlan.to_world(Vector2(0.0, STAIRS_FROM + STAIRS_STEPS * STAIRS_RUN + LANDING.z * 0.5))
	var yaw := deg_to_rad(Feel.live().cam_yaw)  # Masonry turns +x to the hub's u by +yaw
	m.block(Vector3(landing.x, -0.6, landing.y), Vector3(LANDING.x, LANDING.y + 0.6, LANDING.z), yaw, stone())
	var arch := HubPlan.to_world(Vector2(0.0, ARCH_AT))
	m.pointed_arch(Vector3(arch.x, LANDING.y, arch.y), -up, ARCH.x, ARCH.y, 0.5, 0.6, ashlar())
	kit.portal_glow(Vector3(arch.x, LANDING.y + ARCH.y * 0.45, arch.y) - Vector3(up.x, 0.0, up.y) * 0.1,
		atan2(-up.x, -up.y), Vector2(ARCH.x - 0.2, ARCH.y * 0.9))
