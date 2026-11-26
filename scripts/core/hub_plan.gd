class_name HubPlan
extends RefCounted
## The hub's plan (SV-R, 2026-11-25: the Santuário da Vigília redone from the PO's package docs/art/ref/hub01_2026-11-25/,
## 02-planta-dados.json): a monastery-garden of terraces, not a square. Its floor, what blocks on it, where the hero
## arrives, the camera's point, each station's use point and sign anchor, the buildings, the doors. The plan is drawn in
## the hub's own frame (u to the right of the screen, v up the screen) and turned into the world by the camera's yaw
## (to_world). The hub's RoomLayout is made here, never in the descent's StageDef. HubLook (HubBlockout for the masses
## and doors) draws every piece on these footprints.
##   var layout := HubPlan.layout()          # Arena.build(layout); the doors of the closed stations: layout(yaw, closed)
##   HubPlan.STATIONS                        # ids
##
## Levels (refine round 2, 2026-11-26): the simulation stays on the plane (FloorShape, colliders), but the hub has a height
## field over it: the upper terrace (the galleries, the Forja, the Aposento and the Biblioteca, every floor point north of
## TIER_V) stands TIER_H over the lower one, joined by two flights of stairs (STAIR_A on the Forja's way, STAIR_B on the
## main axis) that rise toward +v. `ramp_at` is the smooth field (what HubLevels lifts the drawn meshes by),
## `height_at` the stepped one (the hero's feet: the treads). TIER_H 0 makes the hub flat again (everything off).
## The two future rooms at -1.2 m stay visual (their sunken yards).
## Round 3: the chasm between their corridors is a lower plaza at -PLAZA_DROP (PLAZA, PLAZA_FLIGHTS: the flights go down from the
## Videira's side), in the same field (ramp_at, height_at).

## The stations.
const PORTAL := &"portal"
const VENDOR := &"vendor"
const TREE := &"tree"
const SMITH := &"smith"
const BOOK := &"book"
const VINE := &"vine"
const HEROES := &"heroes"
const STATIONS: Array[StringName] = [PORTAL, VENDOR, TREE, SMITH, BOOK, VINE, HEROES]
## Doors that have no station in STATIONS: the Alquimista's (closed by HubGate.FLAGS) and the two future rooms (always).
const ALCHEMIST_ID := &"alchemist"
const FUTURE_A := &"future_a"
const FUTURE_B := &"future_b"
const ALWAYS_CLOSED: Array[StringName] = [ALCHEMIST_ID, FUTURE_A, FUTURE_B]

## The walkable floor (local u, v; flat): the package's outline (the paths, the courtyards and the galleries as one
## polygon, 71 x 54 m) less its three basins (WATER_*, no one walks there). The two future rooms are cut off it at their
## doors (floor_polys).
const OUTLINE: Array[Vector2] = [
	Vector2(-20.0, -17.0), Vector2(-15.75, -17.0), Vector2(-15.75, -13.14), Vector2(-16.44, -9.0),
	Vector2(-19.0, -9.0), Vector2(-19.0, -13.0), Vector2(-29.0, -13.0), Vector2(-29.0, -3.0),
	Vector2(-19.0, -3.0), Vector2(-19.0, -5.0), Vector2(-17.0, -5.0), Vector2(-17.0, -1.0),
	Vector2(-18.0, -1.0), Vector2(-18.0, 0.0), Vector2(-29.0, 0.0), Vector2(-29.0, 10.0),
	Vector2(-17.0, 10.0), Vector2(-17.0, 14.0), Vector2(-17.0, 15.0), Vector2(-29.0, 15.0),
	Vector2(-29.0, 25.0), Vector2(-16.0, 25.0), Vector2(-16.0, 18.0), Vector2(-13.0, 18.0),
	Vector2(-12.27, 18.0), Vector2(-9.0, 18.89), Vector2(-9.0, 30.0), Vector2(7.0, 30.0),
	Vector2(7.0, 21.0), Vector2(12.0, 21.0), Vector2(12.0, 29.0), Vector2(26.0, 29.0),
	Vector2(26.0, 18.0), Vector2(19.44, 18.0), Vector2(19.81, 17.17), Vector2(12.67, 14.0),
	Vector2(22.0, 14.0), Vector2(22.0, 5.0), Vector2(12.0, 5.0), Vector2(12.0, 4.0),
	Vector2(7.53, 4.0), Vector2(6.5, 4.51), Vector2(6.5, 0.33), Vector2(7.83, -1.0),
	Vector2(9.0, -1.0), Vector2(9.0, 1.0), Vector2(21.0, 1.0), Vector2(21.0, -9.0),
	Vector2(9.0, -9.0), Vector2(9.0, -5.0), Vector2(6.17, -5.0), Vector2(5.27, -4.1),
	Vector2(4.67, -5.89), Vector2(6.65, -10.5), Vector2(23.96, -10.5), Vector2(30.0, -4.46),
	Vector2(30.0, 1.0), Vector2(42.0, 1.0), Vector2(42.0, -12.0), Vector2(30.0, -12.0),
	Vector2(30.0, -11.54), Vector2(26.04, -15.5), Vector2(6.75, -15.5), Vector2(6.75, -17.0),
	Vector2(11.0, -17.0), Vector2(11.0, -24.0), Vector2(0.0, -24.0), Vector2(0.0, -17.0),
	Vector2(3.25, -17.0), Vector2(3.25, -15.26), Vector2(0.35, -8.5), Vector2(-7.0, -8.5),
	Vector2(-7.0, -8.02), Vector2(-12.93, -8.76), Vector2(-12.25, -12.86), Vector2(-12.25, -17.0),
	Vector2(-9.0, -17.0), Vector2(-9.0, -24.0), Vector2(-20.0, -24.0),
]
const WATER_1: Array[Vector2] = [Vector2(4.7, 17.0), Vector2(6.0, 15.96), Vector2(6.0, 15.24), Vector2(9.15, 16.81), Vector2(9.58, 17.0)]
const WATER_2: Array[Vector2] = [Vector2(-11.73, 14.0), Vector2(-13.0, 14.0), Vector2(-13.0, 6.53), Vector2(-14.76, 3.0), Vector2(-13.0, 3.0), Vector2(-13.0, 5.0), Vector2(0.0, 5.0), Vector2(0.0, -3.5), Vector2(0.2, -3.5), Vector2(1.5, 0.41), Vector2(1.5, 12.0), Vector2(2.0, 12.0), Vector2(2.0, 14.04), Vector2(-1.46, 16.8)]
## (round 2: the Mercador's pool ends at v 10, short of the main axis' stairs that start at STAIR_B's v 10.4)
const WATER_3: Array[Vector2] = [Vector2(6.5, 8.99), Vector2(8.47, 8.0), Vector2(9.0, 8.0), Vector2(9.0, 10.0), Vector2(6.5, 10.0)]
## The cut of the future rooms: the floor south of v -17 (their doors stand at the corridors' mouths, DOORS).
const FUTURE_CUT: Array[Vector4] = [Vector4(-21.0, -26.0, -8.0, -17.0), Vector4(-1.0, -26.0, 12.0, -17.0)]

## The levels. TIER_H: how much the upper terrace stands over the lower; TIER_V: the line (v) from which every floor point
## is on it, except the garden's own basin (GARDEN_SHRINK in from its edge: the soil stays low, the gallery's edge
## over it is the retaining wall). The flights: rects (u0, v0, u1, v1) that rise from 0 at v0 to TIER_H at v1 in
## STAIR_STEPS treads; their sides are floor edges (the outline, the basins) except STAIR_B's east one, where STAIR_CUT
## is a slit hole (the Mercador's plaza stands beside it at the lower level; HubLevels draws a parapet over the slit).
const TIER_H := 1.2
const TIER_V := 14.06
const STAIR_A := Vector4(-17.0, 10.0, -13.0, 14.06)
const STAIR_B := Vector4(1.5, 10.4, 12.4, 14.06)
const STAIRS: Array[Vector4] = [STAIR_A, STAIR_B]
const STAIR_STEPS := 6
const STAIR_CUT: Array[Vector2] = [Vector2(12.4, 10.4), Vector2(13.0, 10.4), Vector2(13.0, 14.06), Vector2(12.4, 14.06)]
const GARDEN_SHRINK := 0.15
const STAIR_EPS := 0.01
## Round 3 (2026-11-26): the chasm south of the Videira (the notch of OUTLINE between the two future rooms' corridors) is a
## lower plaza, PLAZA_DROP under the lower terrace: PLAZA is its floor (a polygon PLAZA_GAP in from the notch's walls, so a
## slit of void keeps the corridors and the Mercador's way apart from it) and PLAZA_FLIGHTS the two wide flights that
## go down into it from the Videira's side (rects u0, v0 (foot), u1, v1 (head); they descend toward -v). The tab joins the
## floor between them (no enclosed hole); a planter (PLANTER_BOX) fills the space between the flights and a flower bed
## (PLAZA_BED) stands in the middle of the plaza. PLAZA_DROP 0 turns it into plain floor again (the field).
const PLAZA_DROP := 1.2
const PLAZA_GAP := 0.4
const PLAZA: Array[Vector2] = [
	Vector2(-11.8, -17.0), Vector2(2.8, -17.0), Vector2(2.8, -15.3), Vector2(1.25, -11.6), Vector2(0.0, -11.6),
	Vector2(0.0, -9.0), Vector2(-3.8, -9.0), Vector2(-3.8, -8.3), Vector2(-7.8, -8.3), Vector2(-7.8, -9.0), Vector2(-11.8, -9.0),
]
## The part of the plaza the field lowers (what the tab's top, over the planter, leaves out).
const PLAZA_LOW: Array[Vector2] = [
	Vector2(-11.8, -17.0), Vector2(2.8, -17.0), Vector2(2.8, -15.3), Vector2(1.25, -11.6), Vector2(0.0, -11.6),
	Vector2(0.0, -8.95), Vector2(-11.8, -8.95),
]
const PLAZA_FLIGHTS: Array[Vector4] = [Vector4(-11.8, -11.6, -7.8, -8.2), Vector4(-3.8, -11.6, 0.0, -8.2)]
const PLANTER_BOX := Vector4(-5.8, -10.1, 2.0, 1.5)  # centre u, v, half u, v (between the flights)
const PLANTER_HEIGHT := 1.7  # over the plaza's floor (0.5 over the terrace)
const PLAZA_BED := Vector4(-4.5, -13.9, 2.6, 0.6)
const PLAZA_BED_HEIGHT := 0.45
## How far from the plaza's walls the scenery keeps off (no rock, ivy or rail of the old cliff in it).
const PLAZA_ZONE := 1.3
## The box the plaza's field lives in (u0, u1; the v of its foot and of the top of its flights): a quick reject.
const PLAZA_U := Vector2(-12.4, 3.6)
const PLAZA_ZONE_BOX := Rect2(-13.5, -18.5, 18.0, 11.3)
const PLAZA_FOOT := -17.6
const PLAZA_TOP := -8.0
## The basin that keeps the lower level (WATER_2, the Videira's garden) is index 1 of water().

## Where the hero appears (the Ponto de Vigília, a corner of the west) and the camera's point: the far camera looks
## at CAM_TARGET and goes as far as CAM_REACH from it (71 m of floor: wherever he walks); the near camera follows him
## (NEAR_SOUTH: it may look this far south of the hero's line: the whole plan, so none).
const ARRIVAL := Vector2(-24.0, -7.0)
const CAM_TARGET := Vector2(-6.0, -3.0)
const CAM_REACH := 48.0
const NEAR_SOUTH := -40.0
## On arriving the near camera first looks where the far one does (CAM_TARGET) for ARRIVAL_LOOK seconds, from
## ARRIVAL_DISTANCE and with the hero ARRIVAL_SAFE of the screen inside its edges, then eases back in ARRIVAL_EASE.
const ARRIVAL_LOOK := 1.5
const ARRIVAL_DISTANCE := 60.0
const ARRIVAL_SAFE := 0.14
const ARRIVAL_EASE := 1.0
## Each station's use point on the floor (local), the anchor its sign stands on (u, v, height) and what the camera
## shows of it while it is in focus (u, v, height; frame_for).
const USE := {
	PORTAL: Vector2(32.0, -6.0), VENDOR: Vector2(12.0, 6.0), TREE: Vector2(10.0, -3.0), SMITH: Vector2(-17.6, 16.2),
	BOOK: Vector2(19.0, 19.0), VINE: Vector2(-7.0, -5.0), HEROES: Vector2(-1.0, 19.0),
}
const ANCHOR := {
	PORTAL: Vector3(35.0, -6.0, 2.2), VENDOR: Vector3(11.5, 8.6, 3.1), TREE: Vector3(14.6, -4.2, 4.4),
	SMITH: Vector3(-19.8, 17.3, 2.4), BOOK: Vector3(21.1, 19.4, 2.6), VINE: Vector3(-7.0, -2.6, 2.6),
	HEROES: Vector3(-1.0, 21.1, 2.6),
}
const SHOW := {
	PORTAL: Vector3(37.0, -6.0, 5.5), VENDOR: Vector3(11.5, 10.2, 5.0), TREE: Vector3(14.6, -4.2, 8.0),
	SMITH: Vector3(-23.4, 17.7, 7.6), BOOK: Vector3(19.0, 21.7, 4.8), VINE: Vector3(-7.0, -2.5, 3.4),
	HEROES: Vector3(-1.0, 21.2, 3.2),
}
const SHOW_MARGIN := 0.06
## The apex of the gate (u, v, height): the far camera keeps it in the screen from everywhere.
const PORTAL_TOP := Vector3(37.0, -6.0, 7.8)
## The Portão's mass (u0, v0, u1, v1; it runs to the floor's edge so no one slips behind it), its height, and the
## middle of its opening on its west face (u 37).
const GATE := Vector4(37.0, -12.6, 42.0, 1.6)
const GATE_HEIGHT := 6.0
const GATE_FACE_U := 37.0
const GATE_MID_V := -6.0
## The buildings (id, rect u0, v0, u1, v1, height): the package's footprints, trimmed where a piece needs room (the
## Vigília's by the arrival, the Alquimista's and the Dons' for their bench and dais, the Biblioteca's for its case, the
## Mercador's for the awning), each a solid mass; the stations' pieces stand in front of them.
const BUILDINGS: Array[Dictionary] = [
	{&"id": &"vigil", &"rect": Vector4(-28.0, -12.0, -25.2, -5.0), &"h": 2.4},
	{&"id": &"smith", &"rect": Vector4(-28.0, 19.0, -18.0, 24.0), &"h": 4.5},
	{&"id": &"alchemist", &"rect": Vector4(-28.0, 3.0, -21.4, 9.0), &"h": 3.4},
	{&"id": &"heroes", &"rect": Vector4(-8.0, 22.0, 6.0, 29.0), &"h": 5.2},
	{&"id": &"book", &"rect": Vector4(13.0, 22.2, 25.0, 28.0), &"h": 4.6},
	{&"id": &"vendor", &"rect": Vector4(14.6, 9.6, 21.0, 13.0), &"h": 3.2},
	{&"id": &"tree", &"rect": Vector4(18.4, -8.0, 21.0, -1.0), &"h": 4.5},
]
## The doors (centre u, v, half u, v): on a building's face, outside it, never across a route (test_hub_sv). Closed
## they block (the layout's obstacles, from `closed`); open they are a doorway (HubBlockout). The future rooms' stand
## across their corridors' mouths.
const DOORS := {
	SMITH: Vector4(-19.6, 18.85, 0.9, 0.15), ALCHEMIST_ID: Vector4(-21.25, 7.0, 0.15, 0.9),
	HEROES: Vector4(2.5, 21.85, 0.9, 0.15), BOOK: Vector4(15.0, 22.05, 0.9, 0.15),
	VENDOR: Vector4(14.45, 11.4, 0.15, 0.9), TREE: Vector4(18.25, -6.0, 0.15, 0.9),
	VINE: Vector4(-7.0, -3.3, 1.4, 0.12),
	FUTURE_A: Vector4(-14.0, -16.6, 1.75, 0.15), FUTURE_B: Vector4(5.0, -16.6, 1.75, 0.15),
}
const DOOR_HEIGHT := 2.6
## Where the stations' pieces stand (local; the layout's footprints and HubLook's drawing read these), each in front of
## its building and facing the camera: the Mercador's counter under its awning, the Dons' dais, the Forjador's forge
## and anvil, the Livro's lectern and case, the Videira's arch and bed, the heroes' stand, the Alquimista's bench.
const COUNTER := Vector2(11.5, 8.6)
const COUNTER_HALF := Vector2(2.0, 0.5)
const ANVIL := Vector2(-19.8, 17.3)
const SMITH_SPOT := Vector2(ANVIL.x - 0.66, ANVIL.y + 0.49)
const VENDOR_SPOT := Vector2(COUNTER.x, COUNTER.y + 1.05)
const FORGE := Vector2(-23.4, 17.5)
const FORGE_HALF := Vector2(1.9, 1.4)
const DAIS := Vector3(14.6, -4.2, 3.2)
const LECTERN := Vector2(21.1, 19.4)
const SHELF := Vector2(19.0, 21.65)
const SHELF_HALF := Vector2(2.0, 0.45)
const VINE_ARCH := Vector2(-7.0, -2.6)
const VINE_ARCH_HALF := Vector2(1.5, 0.5)
const VINE_BED := Vector4(-6.5, 1.5, 4.5, 2.0)
## Round 2: the stand stands on a plinth (HERO_PLINTH high) against the Aposento's face, and the flight of steps with the
## red carpet (HERO_STEPS, solid: a monument's stair, the way into the chapel is its door) climbs to it from the gallery.
const HERO_STAND := Vector2(-1.0, 21.6)
const HERO_STAND_HALF := Vector2(1.5, 0.4)
const HERO_STEPS := Vector2(-1.0, 20.6)
const HERO_STEPS_HALF := Vector2(1.5, 0.6)
const HERO_PLINTH := 0.8
const HERO_STEP_COUNT := 5
## Round 3: the stone screen of the Ponto de Vigília's arch, just west of its brazier (centre u, v, half u, half v): it blocks.
const VIGIL_ARCH := Vector4(-24.95, -10.2, 0.25, 2.2)
const ALCHEMIST_BENCH := Vector4(-19.4, 4.2, 0.55, 1.1)
const BED_HEIGHT := 0.55
## Focus: a station comes into focus 2.2 m from its use point and leaves it at 2.8; the one in focus only gives way to
## another this much nearer.
const FOCUS_IN := 2.2
const FOCUS_OUT := 2.8
const FOCUS_SWITCH := 0.4

static var _polys: Array[PackedVector2Array] = []


## The walkable polygons (local u, v): the outline less the future rooms (made once).
static func floor_polys() -> Array[PackedVector2Array]:
	if _polys.is_empty():
		var cut: Array[PackedVector2Array] = [PackedVector2Array(OUTLINE)]
		for r in FUTURE_CUT:
			var box := PackedVector2Array([Vector2(r.x, r.y), Vector2(r.z, r.y), Vector2(r.z, r.w), Vector2(r.x, r.w)])
			var next: Array[PackedVector2Array] = []
			for p in cut:
				next.append_array(Geometry2D.clip_polygons(p, box))
			cut = next
		if PLAZA_DROP > 0.0:
			var add: Array[PackedVector2Array] = [PackedVector2Array(PLAZA)]
			for f in PLAZA_FLIGHTS:
				add.append(PackedVector2Array([Vector2(f.x, f.y), Vector2(f.z, f.y), Vector2(f.z, f.w + 0.3), Vector2(f.x, f.w + 0.3)]))
			for q in add:
				var merged: Array[PackedVector2Array] = []
				var cur := q
				for p in cut:
					var m := Geometry2D.merge_polygons(p, cur)
					if m.size() == 1:
						cur = m[0]
					else:
						merged.append(p)
				merged.append(cur)
				cut = merged
		_polys = cut
	return _polys


## The basins (local): the holes of the floor.
static func water() -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = [PackedVector2Array(WATER_1), PackedVector2Array(WATER_2), PackedVector2Array(WATER_3)]
	return out


static var _garden: Array[PackedVector2Array] = []


## Whether a point (local u, v) is inside the garden's basin, in from its edge (made once).
static func _in_garden(p: Vector2) -> bool:
	if _garden.is_empty():
		_garden = Geometry2D.offset_polygon(PackedVector2Array(WATER_2), -GARDEN_SHRINK)
	for g in _garden:
		if Geometry2D.is_point_in_polygon(p, g):
			return true
	return false


## The smooth height field (local u, v): 0 on the lower terrace, TIER_H on the upper, rising linearly along v on a
## flight. What the drawn pieces are lifted by (HubLevels).
static func ramp_at(p: Vector2) -> float:
	if TIER_H <= 0.0:
		return 0.0
	for z in STAIRS:
		if p.x >= z.x - STAIR_EPS and p.x <= z.z + STAIR_EPS and p.y >= z.y and p.y <= z.w:
			return TIER_H * (p.y - z.y) / (z.w - z.y)
	if p.y >= TIER_V and not _in_garden(p):
		return TIER_H
	return _plaza_ramp(p)


## The stepped field: on a flight the tread under the point (the hero's feet), else ramp_at.
static func height_at(p: Vector2) -> float:
	if TIER_H <= 0.0:
		return 0.0
	for z in STAIRS:
		if p.x >= z.x - STAIR_EPS and p.x <= z.z + STAIR_EPS and p.y >= z.y and p.y <= z.w:
			var k := minf(floorf((p.y - z.y) / (z.w - z.y) * STAIR_STEPS) + 1.0, float(STAIR_STEPS))
			return TIER_H * k / STAIR_STEPS
	if PLAZA_DROP > 0.0 and p.y < PLAZA_TOP and p.y > PLAZA_FOOT:
		for z in PLAZA_FLIGHTS:
			if p.x >= z.x - STAIR_EPS and p.x <= z.z + STAIR_EPS and p.y >= z.y and p.y <= z.w:
				var k := minf(floorf((z.w - p.y) / (z.w - z.y) * STAIR_STEPS) + 1.0, float(STAIR_STEPS))
				return -PLAZA_DROP * k / STAIR_STEPS
	return ramp_at(p)


## The plaza's share of the field: down the flights toward -v (smooth), PLAZA_DROP under the lower terrace on its floor.
static func _plaza_ramp(p: Vector2) -> float:
	if PLAZA_DROP <= 0.0 or p.y >= PLAZA_TOP or p.y < PLAZA_FOOT:
		return 0.0
	for z in PLAZA_FLIGHTS:
		if p.x >= z.x - STAIR_EPS and p.x <= z.z + STAIR_EPS and p.y >= z.y and p.y <= z.w:
			return -PLAZA_DROP * (z.w - p.y) / (z.w - z.y)
	if p.x < PLAZA_U.x or p.x > PLAZA_U.y:
		return 0.0
	if _plaza_low.is_empty():
		_plaza_low = Geometry2D.offset_polygon(PackedVector2Array(PLAZA_LOW), PLAZA_GAP * 0.5)
	for g in _plaza_low:
		if Geometry2D.is_point_in_polygon(p, g):
			return -PLAZA_DROP
	return 0.0


static var _plaza_low: Array[PackedVector2Array] = []
static var _plaza_zone: Array[PackedVector2Array] = []
static var _plaza_tight: Array[PackedVector2Array] = []


## Whether a point (local) is within PLAZA_ZONE of the plaza (what its scenery keeps off) or, with `tight`, within a hair of
## its own edges (not the old walls of the notch, PLAZA_GAP away).
static func near_plaza(p: Vector2, tight := false) -> bool:
	if PLAZA_DROP <= 0.0 or not PLAZA_ZONE_BOX.has_point(p):
		return false
	if _plaza_zone.is_empty():
		_plaza_zone = Geometry2D.offset_polygon(PackedVector2Array(PLAZA), PLAZA_ZONE)
		_plaza_tight = Geometry2D.offset_polygon(PackedVector2Array(PLAZA), 0.15)
	for g in (_plaza_tight if tight else _plaza_zone):
		if Geometry2D.is_point_in_polygon(p, g):
			return true
	return false


## Ground height at a world point (x, z), for a camera's yaw.
static func ground(world: Vector2, yaw_deg: float = Feel.live().cam_yaw) -> float:
	return height_at(to_local(world, yaw_deg))


## A door's rectangle in the world's frame is the layout's; this is its local box.
static func door_rect(id: StringName) -> Rect2:
	var d: Vector4 = DOORS[id]
	return Rect2(d.x - d.z, d.y - d.w, d.z * 2.0, d.w * 2.0)


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
	s.z += ramp_at(Vector2(s.x, s.y))
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
	return Vector3(p.x, a.z + ramp_at(Vector2(a.x, a.y)), p.y)


## The hub's room: its floor, what stands on it (HubLook draws each piece on its footprint; every one is drawn,
## nothing invisible), the arrival, the camera's point; `closed` are the doors that stand shut (the Alquimista's, the
## future rooms' and the stations HubGate has not opened: Hub.closed_doors). look &"hub" (HubLook).
static func layout(yaw_deg: float = Feel.live().cam_yaw, closed: Array[StringName] = ALWAYS_CLOSED) -> RoomLayout:
	var l := RoomLayout.new()
	l.id = &"hub"
	l.look = &"hub"
	l.name_key = &"hub_name"
	l.guardian = false
	var w := func(p: Vector2) -> Vector2: return to_world(p, yaw_deg)
	var walk: Array[PackedVector2Array] = []
	for poly in floor_polys():
		var q := PackedVector2Array()
		for p in poly:
			q.append(w.call(p))
		walk.append(q)
	var holes: Array[PackedVector2Array] = []
	for poly in water():
		var q := PackedVector2Array()
		for p in poly:
			q.append(w.call(p))
		holes.append(q)
	if TIER_H > 0.0:
		var slit := PackedVector2Array()
		for p in STAIR_CUT:
			slit.append(w.call(p))
		holes.append(slit)
	l.floor = FloorShape.poly(walk, holes)
	l.half = l.floor.extent()
	l.hero_spawn = w.call(ARRIVAL)
	l.hero_facing = w.call(Vector2(1.0, 0.0))  # east, to the Videira and the way to the gate
	l.cam_target = w.call(CAM_TARGET)
	l.cam_reach = CAM_REACH
	var turn := -deg_to_rad(yaw_deg)
	var box := func(c: Vector2, half: Vector2, piece: StringName, h: float, see := false) -> ArenaObstacle:
		return ArenaObstacle.box(w.call(c), half, turn, piece, h, true, see)
	var obstacles: Array[ArenaObstacle] = [
		box.call(COUNTER, COUNTER_HALF, &"hub_counter", 1.1),
		ArenaObstacle.circle(w.call(ANVIL), 0.75, &"hub_anvil", 1.15),
		ArenaObstacle.circle(w.call(SMITH_SPOT), 0.45, &"hub_smith", 1.9),
		ArenaObstacle.circle(w.call(VENDOR_SPOT), 0.4, &"hub_vendor", 1.9),
		box.call(FORGE, FORGE_HALF, &"hub_forge", 3.4),
		ArenaObstacle.circle(w.call(Vector2(DAIS.x, DAIS.y)), DAIS.z, &"hub_dais", 0.5),
		box.call(LECTERN, Vector2(0.55, 0.6), &"hub_lectern", 1.5),
		box.call(SHELF, SHELF_HALF, &"hub_shelf", 4.6),
		box.call(VINE_ARCH, VINE_ARCH_HALF, &"hub_vine", 3.2),
		box.call(HERO_STAND, HERO_STAND_HALF, &"hub_heroes", 2.6),
		box.call(HERO_STEPS, HERO_STEPS_HALF, &"hub_heroes_steps", HERO_PLINTH),
		box.call(Vector2(VINE_BED.x, VINE_BED.y), Vector2(VINE_BED.z, VINE_BED.w), &"hub_bed", BED_HEIGHT),
		box.call(Vector2(VIGIL_ARCH.x, VIGIL_ARCH.y), Vector2(VIGIL_ARCH.z, VIGIL_ARCH.w), &"hub_vigil_arch", 3.5),
		box.call(Vector2(PLANTER_BOX.x, PLANTER_BOX.y), Vector2(PLANTER_BOX.z, PLANTER_BOX.w), &"hub_planter", PLANTER_HEIGHT),
		box.call(Vector2(PLAZA_BED.x, PLAZA_BED.y), Vector2(PLAZA_BED.z, PLAZA_BED.w), &"hub_plaza_bed", PLAZA_BED_HEIGHT),
		box.call(Vector2(ALCHEMIST_BENCH.x, ALCHEMIST_BENCH.y), Vector2(ALCHEMIST_BENCH.z, ALCHEMIST_BENCH.w), &"hub_alchemist", 2.2),
	]
	for b in BUILDINGS:
		var r: Vector4 = b[&"rect"]
		obstacles.append(box.call(Vector2(r.x + r.z, r.y + r.w) * 0.5, Vector2(r.z - r.x, r.w - r.y) * 0.5, &"hub_building", b[&"h"], true))
	var g := GATE
	obstacles.append(box.call(Vector2(g.x + g.z, g.y + g.w) * 0.5, Vector2(g.z - g.x, g.w - g.y) * 0.5, &"hub_gate", GATE_HEIGHT, true))
	for id in closed:
		if DOORS.has(id):
			var d: Vector4 = DOORS[id]
			obstacles.append(box.call(Vector2(d.x, d.y), Vector2(d.z, d.w), &"hub_door", DOOR_HEIGHT))
	l.obstacles.assign(obstacles)
	return l
