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
## V2 (A Videira, the account's roots) and PT-9 (the hero's pick): two stations of their own, after the original five.
const VINE := &"vine"
const HEROES := &"heroes"
const STATIONS: Array[StringName] = [PORTAL, VENDOR, TREE, SMITH, BOOK, VINE, HEROES]
## The first five: no two of them more than 4 s of walking apart (LR-07). The two of V2 and PT-9 stand out in the lobes
## (beside the Vendedor, east of the Árvore) and keep within EXTRA_WALK of the rest.
const CORE: Array[StringName] = [PORTAL, VENDOR, TREE, SMITH, BOOK]
const EXTRA_WALK := 6.5
## The walkable floor (local u, v; flat, y 0): 50 m wide and 32.5 m deep (HUB-B2, the PO: the first plan, 25 x 16.5 m,
## was a fifth of Hades II's hub), its south corners cut. HUB-D (art review H-P0-1 to H-P0-3, docs/gallery/hub/
## ART_REVIEW.md, and the room-designer's LR-07): the far camera (54 m, 30 degrees, 24 of view) sees about 25 m of
## floor between the hero's safe frame at the bottom and the portal's sill at a fifth of the screen, so the portal came
## 4.5 m in: its stairs rise from NORTH in the middle, and beside its terrace two lobes of floor run up to LOBE.y (from
## |u| LOBE.x), where the Vendedor and the Árvore stand; and the hero arrives up a stair well cut into the south edge
## to the medallion, not at the floor's foot (HUB-D; gone with HV-A, below). The square keeps its size.
## HV-A (Santuário da Vigília Rev. 02, docs/backlog.md P.5, Q-HV2 a): the well is gone; every arrival comes up the
## Retorno's stairs at the south-east (ARRIVAL_STAIRS: from u, to u, on the south edge) onto its seal; the south-east
## corner is no longer cut (the stairs need it), the south-west one is. (25; SOUTH + CUT.y) stays a corner of the
## outline, in line, so the east side's low balustrade runs only along the south part as before.
const HALF_U := 25.0
const NORTH := 12.0
const SOUTH := -16.5
const CUT := Vector2(8.0, 6.0)
const LOBE := Vector2(9.0, 16.0)
const ARRIVAL_STAIRS := Vector2(14.5, 21.5)
const FLOOR: Array[Vector2] = [Vector2(-HALF_U + CUT.x, SOUTH), Vector2(-HALF_U, SOUTH + CUT.y), Vector2(-HALF_U, LOBE.y),
	Vector2(-LOBE.x, LOBE.y), Vector2(-LOBE.x, NORTH), Vector2(LOBE.x, NORTH), Vector2(LOBE.x, LOBE.y), Vector2(HALF_U, LOBE.y),
	Vector2(HALF_U, SOUTH + CUT.y), Vector2(HALF_U, SOUTH), Vector2(ARRIVAL_STAIRS.y, SOUTH), Vector2(ARRIVAL_STAIRS.x, SOUTH)]
## Where the hero appears (local) and the camera's point (local) with how far it may move off it. The camera keeps
## to its point and moves only as much as his safe frame needs (CamFrame.hold: never nearer than 18% to an edge), up
## to CAM_REACH from it: across 50 m it goes wherever he walks, and at the edges it shows the hub, not the cliff under
## it (a world box, cam_bounds, cannot: the hub is turned 35 degrees to the world's axes, so any box that lets it reach
## the side stations lets it look 5 m past the south edge too). 16 m lets the near camera (CamRig.near, plus its
## CamFrame.slack) keep him in the safe frame in the far corners (test_camera_near). HUB-D: the point puts the portal's
## sill at about a quarter of the screen with the far camera and holds there from the arrival and every station (art
## review H-P0-1: 0.15 to 0.30); the near camera follows him but never looks south of NEAR_SOUTH (H-P0-2: the south
## edge of the floor stays under 0.85 of the screen, the tower's wall under it out of the frame; Hub.lean).
## HV-A: the arrival is the Retorno's seal at the south-east (the plan's (18; -11.4)), 28.5 m from the portal.
const ARRIVAL := Vector2(18.0, -11.4)
const CAM_TARGET := Vector2(0.0, 5.6)
const CAM_REACH := 16.0
const NEAR_SOUTH := -6.0
## On arriving the near camera first looks where the far one does (CAM_TARGET: the portal in the frame, art review
## ciclo_visual_1120 P1-A2) for ARRIVAL_LOOK seconds, his safe frame first, then follows him (Hub.lean).
## HV-B: from the south-east seal no camera shows the portal's whole arch with him 18% inside the screen (far, 54 m:
## the arch's top 4% over the screen, and still over it with him 8% from the edge; near: the sill at the top edge).
## For ARRIVAL_LOOK both cameras look from ARRIVAL_DISTANCE (the showcase's 60 m; CamRig.wide 1) and keep him
## ARRIVAL_SAFE of the screen inside its edges (the arch's top 4% under the screen's top, its sill at 0.23), then ease
## back in ARRIVAL_EASE seconds to their own distance and the 18%.
const ARRIVAL_LOOK := 1.5
const ARRIVAL_DISTANCE := 60.0
const ARRIVAL_SAFE := 0.14
const ARRIVAL_EASE := 1.0
## Each station's use point on the floor (local) and the anchor its sign stands on (local u, v and height y).
## HUB-D (LR-07): 11.5 m off the axis arrival to portal, so no two are more than 4 s apart walking (the portal's at
## the foot of its stairs, its sign over them). HV-A (Q-HV1 a): the quarters of today with the plan's distances, about
## 10 m off the axis and 5 m off the fountain's line; the portal's stays (the far camera was measured on it).
const USE := {
	PORTAL: Vector2(0.0, 11.0), VENDOR: Vector2(-10.3, 5.2), TREE: Vector2(10.1, 5.0), SMITH: Vector2(-10.3, -5.2),
	BOOK: Vector2(10.1, -5.1), VINE: Vector2(19.0, 8.2), HEROES: Vector2(-17.5, 7.4),
}
const ANCHOR := {
	PORTAL: Vector3(4.2, 12.9, 1.7), VENDOR: Vector3(-10.6, 7.6, 3.1), TREE: Vector3(11.9, 8.9, 4.4),
	SMITH: Vector3(-12.2, -6.0, 2.4), BOOK: Vector3(12.0, -5.9, 2.6), VINE: Vector3(19.0, 9.9, 2.6),
	HEROES: Vector3(-17.5, 9.5, 2.6),
}
## What the camera shows of each station while it is in focus (HUB-D; local u, v and height over the floor): the
## portal's head over its stairs, the awning, the tree's crown, the forge's mouth under its chimney, the shelf of
## scrolls. Standing at a station the camera leans (CamRig.lean, frame_for) only as far as it takes to bring that point
## SHOW_MARGIN inside the screen; the hero's safe frame still wins (CamFrame.hold). Daniel's test: at the Portal he
## stood glued to the top of the screen with the portal cut off.
const SHOW := {
	PORTAL: Vector3(0.0, 17.6, 6.0), VENDOR: Vector3(-13.4, 10.2, 5.0), TREE: Vector3(11.9, 8.9, 8.0),
	SMITH: Vector3(-15.8, -3.8, 7.6), BOOK: Vector3(15.1, -3.1, 4.8), VINE: Vector3(19.0, 10.0, 3.4),
	HEROES: Vector3(-17.5, 9.6, 3.2),
}
const SHOW_MARGIN := 0.06
## The apex of the portal's outer order (u, v, height): the far camera keeps it in the screen from everywhere (its SHOW
## point lies lower, so standing at the portal the camera does not lean and the portal does not jump).
const PORTAL_TOP := Vector3(0.0, 17.6, 7.8)
## Where the stations' pieces stand (local; the layout's footprints and HubLook's drawing read these). HUB-D (H-P0-4):
## each station a place of its own, its main piece 1.5 to 2 times the hero and something 4 to 6 m tall behind it, all
## facing the camera: the Vendedor's stall (counter along u under a great awning, racks behind) in the west lobe, the
## Árvore on its dais in the east one, the Forjador's forge (its mouth to the south, over the anvil) and yard, the Livro's
## lectern before a tall case of books and scrolls; the yards of the two below closed to the south by low walls.
## HV-A: each station's pieces sit where they sat round its use point before (the stall 2.4 m behind it, the anvil
## 1.9 m west of it, the lectern 1.9 m east), the forge south of the Alquimista's space; the fountain blocks 3.1 m.
const FOUNTAIN := Vector3(0.0, 2.6, 3.1)
const COUNTER := Vector2(-10.6, 7.6)
const COUNTER_HALF := Vector2(2.0, 0.5)
const ANVIL := Vector2(-12.2, -6.0)
## Where the two NPCs stand (HubLook._people draws them there; each blocks as a body): the Forjador where his hammer
## lands on the anvil (HubNpc.strike_point), the Vendedor behind his counter.
const SMITH_SPOT := Vector2(ANVIL.x - 0.66, ANVIL.y + 0.49)
const VENDOR_SPOT := Vector2(COUNTER.x, COUNTER.y + 1.05)
const FORGE := Vector2(-15.8, -4.0)
const FORGE_HALF := Vector2(1.9, 1.5)
const DAIS := Vector3(11.9, 8.9, 3.2)
const LECTERN := Vector2(12.0, -5.9)
const SHELF := Vector2(15.1, -3.1)
const SHELF_HALF := Vector2(2.0, 0.5)
## V2: the Videira's arch in the east lobe, off the Árvore's dais, the cypress, the urn and the arbour (centre u, v and
## half sizes; the planting grows in front of it, VineStation). PT-9: the hero's station west of the Vendedor's stall, off
## his goods, the lamp and the cypress: a stand of two banners on a low plinth (HeroStation).
const VINE_ARCH := Vector2(19.0, 10.0)
const VINE_ARCH_HALF := Vector2(1.5, 0.5)
const HERO_STAND := Vector2(-17.5, 9.5)
const HERO_STAND_HALF := Vector2(1.5, 0.55)
## The forge's yard's low wall (from u, to u, v; height YARD_WALL_HEIGHT). HV-A: only the west one (the east one stood
## across the Retorno's way in).
const YARD_WALL := Vector3(-22.5, -14.0, -11.2)
const YARD_WALL_HEIGHT := 0.65
## HV-A (Q-OF7): the Alquimista's space (centre u, v and half sizes), reserved, out of STATIONS: no focus, sign, use
## nor focus light. Its bench and the shelf behind it block (ALCHEMIST_BENCH: centre u, v, half sizes); its lean-to
## does not.
const ALCHEMIST := Vector4(-18.4, 0.0, 2.15, 2.5)
const ALCHEMIST_BENCH := Vector4(-20.0, 0.0, 0.55, 1.1)
## The Vendedor's goods along the west lobe and the garden bed in the east one, against the side walls (u, v, half
## sizes), out of the stall's and the tree's ways.
const GOODS: Array[Vector4] = [Vector4(-19.0, 13.6, 1.2, 0.9), Vector4(-22.6, 12.4, 1.0, 1.4)]
const ARBOUR: Array[Vector4] = [Vector4(21.6, 12.6, 1.6, 1.0)]
## The Forjador's yard west of the forge and the Livro's writing desk east of his case (u, v, half sizes).
const YARD := Vector4(-21.0, -7.6, 2.6, 2.4)
const DESK := Vector4(20.6, -4.7, 1.1, 0.55)
## Lamp posts along the south and on the cut corners, benches round the fountain (local u, v), flower beds by the
## arrival and along the side walls before their statues (u, v, half sizes); all off the straight ways from the arrival to the stations.
const LAMPS: Array[Vector2] = [Vector2(-7.5, -15.9), Vector2(7.5, -15.9), Vector2(-20.6, -13.0), Vector2(24.0, -13.0),
	Vector2(-19.5, 5.0), Vector2(19.5, 5.0)]
## HV-A: in the north lobes (the one by the portal's axis stood on the Retorno's way to it).
const BENCHES: Array[Vector2] = [Vector2(-15.5, 14.0), Vector2(15.5, 14.0)]
const BENCH := Vector2(0.35, 1.3)
## Raised beds of copper shrubs (u, v, half sizes; HUB-D: they read as coffins as flower beds): the south wings and
## the square's sides between the stations.
## HV-A: the east wing's bed off the Retorno's way, the west side's out of the Alquimista's space.
const BEDS: Array[Vector4] = [Vector4(-10.0, -12.6, 2.2, 0.8), Vector4(8.4, -13.6, 2.2, 0.8),
	Vector4(22.4, 1.6, 0.8, 2.0),
	# the two lower quarters of the square, between the medallion's way and the fountain (art re-review E-1: 9.75 m free;
	# HV-A: 0.8 m in, off the Retorno's way to the portal)
	Vector4(-6.6, -1.8, 1.2, 0.5), Vector4(6.6, -1.8, 1.2, 0.5)]
const BED_HEIGHT := 0.55
## The braziers on stands flanking the top of the arrival's stairs (warm light in the square, H-P1-7; HV-A: the
## Retorno's two smaller braziers).
const ARRIVAL_FIRES: Array[Vector2] = [Vector2(13.8, -15.4), Vector2(22.2, -15.4)]
## Great urns on plinths in the square, off the ways (local u, v; radius). HUB-D: all four moved off the straight
## ways from the arrival and the paved ones from the fountain (HubLook), and the urns grown (radius, height).
## HV-A: the east one off the Retorno's way, the two by the stalls at the foot of the side walls.
const URNS: Array[Vector2] = [Vector2(-7.0, -8.8), Vector2(6.0, -12.4), Vector2(-23.6, 9.0), Vector2(23.6, 9.0)]
const URN_R := 0.75
const URN_HEIGHT := 1.5
## Cypresses in stone planters (HUB-D: the square was a vast empty slab with nothing standing on it; they give it height
## and quarters), off every straight way from the arrival and the fountain to the stations (local u, v; the planter's
## half side, the tree's height).
## HV-A: the two of the square's sides out to the side walls, behind the stations (they stood on the ring's way).
const CYPRESSES: Array[Vector2] = [Vector2(-9.6, 10.4), Vector2(9.6, 10.4), Vector2(-21.5, 6.5), Vector2(21.5, 6.5)]
const CYPRESS := Vector2(0.8, 4.2)
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


## The floor point (world) a camera looking at `from` moves to so the station's SHOW point lies SHOW_MARGIN inside the
## screen: up or down it first (only how far ahead the camera looks moves a point up the screen), then across. `from`
## when it already shows (or the station has no SHOW). The camera's numbers as in CamFrame.screen_of.
static func frame_for(id: StringName, from: Vector2, distance: float, pitch_deg: float, yaw_deg: float, fov_deg: float, aspect: float) -> Vector2:
	if not SHOW.has(id):
		return from
	var s: Vector3 = SHOW[id]
	var at := to_world(Vector2(s.x, s.y), yaw_deg)
	var up := to_world(Vector2(0.0, 1.0), yaw_deg)
	var right := to_world(Vector2(1.0, 0.0), yaw_deg)
	var screen := func(p: Vector2) -> Vector2:
		return CamFrame.screen_of(at, s.z, p, distance, pitch_deg, yaw_deg, fov_deg, aspect)
	var p := from
	var y: float = screen.call(p).y
	if y < SHOW_MARGIN or y > 1.0 - SHOW_MARGIN:
		var goal := SHOW_MARGIN if y < SHOW_MARGIN else 1.0 - SHOW_MARGIN
		# the point goes down the screen as the camera looks farther ahead
		var lo := -30.0
		var hi := 30.0
		for i in 32:
			var mid := (lo + hi) * 0.5
			if screen.call(from + up * mid).y < goal:
				lo = mid
			else:
				hi = mid
		p = from + up * ((lo + hi) * 0.5)
	var x: float = screen.call(p).x
	if x < SHOW_MARGIN or x > 1.0 - SHOW_MARGIN:
		# across, the point's place is linear in how far right the camera looks
		var k: float = screen.call(p + right).x - x
		if absf(k) > 0.0001:
			p += right * (((SHOW_MARGIN if x < SHOW_MARGIN else 1.0 - SHOW_MARGIN) - x) / k)
	return p


## What the near camera wants to look at with the hero at `hero` (world): him, but never south of NEAR_SOUTH.
static func near_want(hero: Vector2, yaw_deg: float = Feel.live().cam_yaw) -> Vector2:
	var l := to_local(hero, yaw_deg)
	return to_world(Vector2(l.x, maxf(l.y, NEAR_SOUTH)), yaw_deg)


## What the near camera wants with the hero at `hero` (world), `since` seconds after arriving (-1: he did not arrive
## by the stairs, a capture's --hero-at): the far camera's point for ARRIVAL_LOOK, then near_want.
static func near_want_at(hero: Vector2, since: float, yaw_deg: float = Feel.live().cam_yaw) -> Vector2:
	if since >= 0.0 and since < ARRIVAL_LOOK:
		return to_world(CAM_TARGET, yaw_deg)
	return near_want(hero, yaw_deg)


## How much of the arrival look is on `since` seconds after he came up (-1: placed, none): 1 for ARRIVAL_LOOK, then
## easing to 0 in ARRIVAL_EASE.
static func arrival_share(since: float) -> float:
	if since < 0.0:
		return 0.0
	return 1.0 - smoothstep(ARRIVAL_LOOK, ARRIVAL_LOOK + ARRIVAL_EASE, since)


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
		ArenaObstacle.box(w.call(COUNTER), COUNTER_HALF, turn, &"hub_counter", 1.1),
		ArenaObstacle.circle(w.call(ANVIL), 0.75, &"hub_anvil", 1.15),
		ArenaObstacle.circle(w.call(SMITH_SPOT), 0.45, &"hub_smith", 1.9),
		ArenaObstacle.circle(w.call(VENDOR_SPOT), 0.4, &"hub_vendor", 1.9),
		ArenaObstacle.box(w.call(FORGE), FORGE_HALF, turn, &"hub_forge", 3.4),
		ArenaObstacle.circle(w.call(Vector2(DAIS.x, DAIS.y)), DAIS.z, &"hub_dais", 0.5),
		ArenaObstacle.box(w.call(LECTERN), Vector2(0.55, 0.6), turn, &"hub_lectern", 1.5),
		ArenaObstacle.box(w.call(SHELF), SHELF_HALF, turn, &"hub_shelf", 4.6),
		ArenaObstacle.box(w.call(VINE_ARCH), VINE_ARCH_HALF, turn, &"hub_vine", 3.2),
		ArenaObstacle.box(w.call(HERO_STAND), HERO_STAND_HALF, turn, &"hub_heroes", 2.6),
	]
	var ya := Vector2(YARD_WALL.x, YARD_WALL.z)
	var yb := Vector2(YARD_WALL.y, YARD_WALL.z)
	obstacles.append(ArenaObstacle.box(w.call((ya + yb) * 0.5), Vector2(absf(yb.x - ya.x) * 0.5, 0.25), turn, &"hub_yard_wall", YARD_WALL_HEIGHT))
	obstacles.append(ArenaObstacle.box(w.call(Vector2(ALCHEMIST_BENCH.x, ALCHEMIST_BENCH.y)), Vector2(ALCHEMIST_BENCH.z, ALCHEMIST_BENCH.w), turn, &"hub_alchemist", 2.2))
	# the yard's pieces (HubLook draws them all at the rack): the rack along its back, the trough and the grindstone at
	# its front, the coal by the forge
	var yc := Vector2(YARD.x, YARD.y)
	var r0 := yc.x - YARD.z + 0.3
	var r1 := yc.x + YARD.z * 0.2
	obstacles.append(ArenaObstacle.box(w.call(Vector2((r0 + r1) * 0.5, yc.y + YARD.w - 0.3)), Vector2((r1 - r0) * 0.5 + 0.1, 0.35), turn, &"hub_yard", 1.9))
	obstacles.append(ArenaObstacle.box(w.call(Vector2(yc.x - YARD.z * 0.35, yc.y - YARD.w + 0.55)), Vector2(0.95, 0.4), turn, &"hub_yard_part", 0.6))
	obstacles.append(ArenaObstacle.circle(w.call(Vector2(yc.x + YARD.z * 0.2, yc.y - YARD.w + 0.55)), 0.5, &"hub_yard_part", 1.05))
	obstacles.append(ArenaObstacle.circle(w.call(Vector2(yc.x + YARD.z - 0.7, yc.y)), 0.9, &"hub_yard_part", 0.45))
	obstacles.append(ArenaObstacle.box(w.call(Vector2(DESK.x, DESK.y)), Vector2(DESK.z, DESK.w), turn, &"hub_desk", 0.95))
	for g in GOODS:
		obstacles.append(ArenaObstacle.box(w.call(Vector2(g.x, g.y)), Vector2(g.z, g.w), turn, &"hub_goods", 1.6))
	for g in ARBOUR:
		obstacles.append(ArenaObstacle.box(w.call(Vector2(g.x, g.y)), Vector2(g.z, g.w), turn, &"hub_bed", BED_HEIGHT))
	for p in ARRIVAL_FIRES:
		obstacles.append(ArenaObstacle.circle(w.call(p), 0.6, &"hub_fire", 1.4))
	for p in LAMPS:
		obstacles.append(ArenaObstacle.circle(w.call(p), 0.3, &"hub_lamp", 3.0))
	for p in BENCHES:
		obstacles.append(ArenaObstacle.box(w.call(p), BENCH, turn, &"hub_bench", 0.5))
	for p in URNS:
		obstacles.append(ArenaObstacle.circle(w.call(p), URN_R, &"hub_urn", URN_HEIGHT))
	for p in CYPRESSES:
		obstacles.append(ArenaObstacle.box(w.call(p), Vector2(CYPRESS.x, CYPRESS.x), turn, &"hub_cypress", CYPRESS.y))
	for b in BEDS:
		obstacles.append(ArenaObstacle.box(w.call(Vector2(b.x, b.y)), Vector2(b.z, b.w), turn, &"hub_bed", BED_HEIGHT))
	l.obstacles.assign(obstacles)
	return l
