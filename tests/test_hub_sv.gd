extends GutTest
## SV-R, the Santuário da Vigília redone (docs/art/ref/hub01_2026-11-25/, HubPlan, HubBlockout): the plan's floor is the
## package's outline, every station and the arrival connect on foot (with every door open and with every one shut),
## nothing stands across a route, nothing stands off the floor or in another piece, the doors of the closed stations
## block and the open ones do not, the main way is wide and short.

const YAW := 35.0
## The main way from the arrival to the gate by the Videira, as the points of the package's paths (u, v).
const MAIN: Array[Vector2] = [Vector2(-24, -7), Vector2(-15, -7), Vector2(-7, -5), Vector2(2, -6), Vector2(4, 0),
	Vector2(4, 12), Vector2(4, 17), Vector2(-1, 19.4)]
## The walk from the arrival to each station, by the package's paths (u, v), the use point last (HubPlan.USE). The
## other hub tests walk these too.
const ROUTES := {
	&"vine": [Vector2(-24, -7), Vector2(-15, -7), Vector2(-7, -5)],
	&"portal": [Vector2(-24, -7), Vector2(-15, -7), Vector2(-7, -5), Vector2(2, -6), Vector2(4, 0), Vector2(4, 12), Vector2(4, 17), Vector2(-1, 19.4)],
	&"tree": [Vector2(-24, -7), Vector2(-15, -7), Vector2(-7, -6), Vector2(2, -6), Vector2(4, 0), Vector2(7, -3), Vector2(10, -3)],
	&"vendor": [Vector2(-24, -7), Vector2(-15, -7), Vector2(-7, -6), Vector2(2, -6), Vector2(4, 0), Vector2(4, 8), Vector2(8, 6), Vector2(12, 6)],
	&"book": [Vector2(-24, -7), Vector2(-15, -7), Vector2(-7, -6), Vector2(2, -6), Vector2(4, 0), Vector2(4, 12), Vector2(10, 15), Vector2(19, 19)],
	&"smith": [Vector2(-24, -7), Vector2(-15, -7), Vector2(-15, 1), Vector2(-18, 1), Vector2(-15, 7), Vector2(-15, 16), Vector2(-17.6, 16.2)],
}
const ALL: Array[StringName] = [&"smith", &"alchemist", &"book", &"vendor", &"tree", &"vine", &"future_a", &"future_b"]


func _arena(closed: Array[StringName]) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(HubPlan.layout(YAW, closed))
	return a


func _w(p: Vector2) -> Vector2:
	return HubPlan.to_world(p, YAW)


func test_the_floor_is_the_packages_outline_less_the_basins_and_the_future_rooms() -> void:
	var l := HubPlan.layout(YAW)
	var area := 0.0
	for poly in HubPlan.floor_polys():
		for i in poly.size():
			area += poly[i].cross(poly[(i + 1) % poly.size()]) * 0.5
	for hole in HubPlan.water():
		for i in hole.size():
			area -= hole[i].cross(hole[(i + 1) % hole.size()]) * 0.5
	assert_gt(area, 1000.0, "a monastery, not a room: more than 1000 m2 of floor (%.0f)" % area)
	assert_lt(area, 2600.0)
	assert_eq(l.floor.holes.size(), 3 + (1 if HubPlan.TIER_H > 0.0 else 0), "three basins and the slit beside the main axis' stairs")
	for p: Vector2 in [Vector2(-14, -20), Vector2(5, -20), Vector2(-24, -7), Vector2(-7, 0), Vector2(30, -6)]:
		assert_eq(l.floor.covers(_w(p)), p.y > -17.0, "the floor ends at the future rooms' doors: %s" % p)
	for p: Vector2 in [Vector2(-5, 10), Vector2(0.5, 3)]:
		assert_false(l.floor.covers(_w(p)), "water, not floor: %s" % p)


func test_the_arrival_and_every_station_stand_on_the_floor() -> void:
	var l := HubPlan.layout(YAW)
	assert_true(l.floor.contains(l.hero_spawn, Player.RADIUS), "he arrives on the floor")
	assert_eq(HubPlan.ARRIVAL, Vector2(-24, -7), "the Ponto de Vigilia of the package")
	for id in HubPlan.STATIONS:
		assert_true(l.floor.contains(HubPlan.use_point(id, YAW), Player.RADIUS), "%s's use point is on the floor" % id)
		for other in HubPlan.STATIONS:
			if other != id:
				assert_gt(HubPlan.use_point(id, YAW).distance_to(HubPlan.use_point(other, YAW)), HubPlan.FOCUS_OUT * 2.0,
					"two stations never both in reach (%s, %s)" % [id, other])


func test_every_station_is_reached_on_foot_with_every_door_open_and_shut() -> void:
	for closed: Array[StringName] in [[] as Array[StringName], [&"future_a", &"future_b", &"alchemist", &"smith",
			&"book", &"vendor", &"tree", &"vine"] as Array[StringName]]:
		var a := _arena(closed)
		var start := HubPlan.to_world(HubPlan.ARRIVAL, YAW)
		assert_true(a.nav.walkable(start), "the arrival is walkable")
		for id in HubPlan.STATIONS:
			assert_true(a.nav.walkable(HubPlan.use_point(id, YAW)), "%s's use point is walkable (%d doors shut)" % [id, closed.size()])
			assert_true(a.nav.reachable(start, HubPlan.use_point(id, YAW)), "%s reached on foot (%d doors shut)" % [id, closed.size()])
		# the alchemist's yard and the way to the future rooms' doors are floor too
		assert_true(a.nav.reachable(start, _w(Vector2(-18, 1))), "the Alquimista's courtyard")
		assert_true(a.nav.reachable(start, _w(Vector2(-14, -14))), "the corridor to the first future door")
		assert_true(a.nav.reachable(start, _w(Vector2(5, -14))), "the corridor to the second future door")
		var sizes := a.nav.island_sizes()
		var total := 0
		for n in sizes:
			total += n
		assert_gt(float(sizes[a.nav.island[a.nav.nearest_free(start)]]) / float(total), 0.97, "the floor is one piece but for slivers no body fits in (%d doors shut)" % closed.size())


func test_every_route_is_a_chain_of_clear_lines_with_every_door_shut() -> void:
	var a := _arena(ALL)
	for id: StringName in ROUTES:
		var pts: Array = ROUTES[id]
		assert_eq(pts[pts.size() - 1], HubPlan.USE[id], "%s's route ends on its use point" % id)
		for i in pts.size() - 1:
			assert_true(a.nav.clear_line(_w(pts[i]), _w(pts[i + 1])), "%s's route %s to %s is a clear line" % [id, pts[i], pts[i + 1]])


func test_the_way_from_the_vigilia_to_the_videira_and_the_gate_is_short() -> void:
	var to_vine := 0.0
	var vine: Array = ROUTES[&"vine"]
	for i in vine.size() - 1:
		to_vine += vine[i].distance_to(vine[i + 1])
	var total := 0.0
	for i in MAIN.size() - 1:
		total += MAIN[i].distance_to(MAIN[i + 1])
	assert_lt(to_vine, 20.0, "the Videira is the first station, about 19 m from the Ponto de Vigilia")
	assert_lt(total, 75.0, "the Portao is about 8 s away at 6.5 m/s: the return to the adventure stays quick (%.0f m)" % total)


func test_the_main_way_is_four_to_five_meters_wide() -> void:
	var l := HubPlan.layout(YAW, ALL)
	# at the middle of each main stretch the floor reaches 2 m on both sides of the line (the nav's clearance aside)
	for i in MAIN.size() - 1:
		var mid := (MAIN[i] + MAIN[i + 1]) * 0.5
		var dir := (MAIN[i + 1] - MAIN[i]).normalized()
		var side := Vector2(-dir.y, dir.x)
		for s: float in [-1.0, 1.0]:
			assert_true(l.floor.covers(_w(mid + side * s * 2.0)), "2 m off the middle of main stretch %d, side %d, is floor" % [i, int(s)])


func test_a_closed_door_blocks_and_an_open_one_does_not() -> void:
	var shut := _arena([&"smith", &"alchemist", &"future_a"] as Array[StringName])
	var open := _arena([] as Array[StringName])
	for id: StringName in [&"smith", &"alchemist", &"future_a"]:
		var d: Vector4 = HubPlan.DOORS[id]
		assert_false(shut.free_at(_w(Vector2(d.x, d.y)), 0.1), "%s's door stands shut" % id)
		assert_true(open.free_at(_w(Vector2(d.x, d.y)), 0.1), "%s's door is a doorway" % id)
	# a door shut is a solid thing of the layout, none of its own invisible: HubBlockout draws it from the same one
	var n := 0
	for o in HubPlan.layout(YAW, [&"smith", &"vine"] as Array[StringName]).obstacles:
		if o.piece == &"hub_door":
			n += 1
	assert_eq(n, 2)
	assert_eq(HubPlan.layout(YAW).obstacles.filter(func(o: ArenaObstacle) -> bool: return o.piece == &"hub_door").size(),
		HubPlan.ALWAYS_CLOSED.size(), "by default the Alquimista and the two future rooms stand shut")


func test_no_piece_stands_off_the_floor_or_in_another() -> void:
	var l := HubPlan.layout(YAW, ALL)
	var pieces: Array[ArenaObstacle] = []
	pieces.assign(l.obstacles)
	for o in pieces:
		if o.piece == &"hub_gate" or o.piece == &"hub_door":
			continue
		for p in o.outline():
			assert_true(l.floor.covers(p), "%s at %s stands on the floor" % [o.piece, HubPlan.to_local(o.center, YAW).snappedf(0.1)])
	for i in pieces.size():
		for j in range(i + 1, pieces.size()):
			var a := pieces[i]
			var b := pieces[j]
			var hit := false
			for p in a.outline():
				if b.depth(p, 0.0) > 0.02:
					hit = true
			for p in b.outline():
				if a.depth(p, 0.0) > 0.02:
					hit = true
			# the NPCs stand at their pieces by design (the Vendedor behind his counter, the Forjador at the anvil)
			if hit and not (String(a.piece).ends_with("smith") or String(a.piece).ends_with("vendor") or String(b.piece).ends_with("smith") or String(b.piece).ends_with("vendor")):
				assert_true(false, "%s at %s overlaps %s at %s" % [a.piece, HubPlan.to_local(a.center, YAW).snappedf(0.1), b.piece, HubPlan.to_local(b.center, YAW).snappedf(0.1)])


func test_the_doors_stand_on_the_floor_and_each_has_its_building_or_mouth() -> void:
	for id: StringName in HubPlan.DOORS:
		var r := HubPlan.door_rect(id)
		assert_true(HubPlan.layout(YAW).floor.covers(_w(r.get_center())), "%s's door is on the floor" % id)
	for id in HubGate.GATED:
		assert_eq(HubPlan.DOORS.has(id), not HubPlan.DISABLED.has(id), "%s has a physical door (unless the station is off)" % id)
	assert_true(HubPlan.DOORS.has(HubPlan.ALCHEMIST_ID))
	assert_eq(HubGate.FLAGS.get(HubPlan.ALCHEMIST_ID), false, "the Alquimista's door follows the flag")


func test_the_hub_shuts_the_doors_of_what_the_save_has_not_opened() -> void:
	var hub: Hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	var shut := hub.closed_doors()
	assert_true(shut.has(HubPlan.FUTURE_A) and shut.has(HubPlan.FUTURE_B) and shut.has(HubPlan.ALCHEMIST_ID))
	for id in HubGate.GATED:
		assert_eq(shut.has(id), not hub.is_open(id) and not HubPlan.DISABLED.has(id), "%s's door shut exactly when HubGate says it is closed" % id)
	var hard := hub.arena.layout.obstacles.filter(func(o: ArenaObstacle) -> bool: return o.piece == &"hub_door")
	assert_eq(hard.size(), shut.size(), "one solid door a shut station")
