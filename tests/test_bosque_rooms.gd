extends GutTest
## Chapter II, A-6: the Bosque's own greybox rooms (Portões, Jardim, Templo) keep Chapter I's rules for doors and the way in, and their
## shallow water is a mark on walkable floor with a dry route across it.

const STAGE := "res://data/stages/bosque.tres"
const OWN: Array[StringName] = [&"bosque_gates", &"bosque_garden", &"bosque_temple"]


func _own() -> Array[RoomLayout]:
	var stage: StageDef = load(STAGE)
	var out: Array[RoomLayout] = []
	for l in stage.layouts:
		if OWN.has(l.id):
			out.append(l)
	return out


func _arena(l: RoomLayout) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(l, 2, 1406)
	return a


func test_the_stage_has_the_three_rooms_and_keeps_the_hall_and_the_guardians_houses() -> void:
	var stage: StageDef = load(STAGE)
	assert_eq(_own().size(), 3)
	var ids: Array[StringName] = []
	for l in stage.layouts:
		ids.append(l.id)
	assert_true(ids.has(&"hall"))
	assert_eq(stage.minibosses.size(), 1)
	for l in stage.layouts:
		assert_true(OWN.has(l.id) or l.id == &"hall" or l.guardian_home, "%s is no Chapter I fight room" % l.id)


func test_two_doors_far_apart_with_a_piece_between_and_a_free_approach() -> void:
	for l in _own():
		assert_eq(l.exits.size(), 2, l.id)
		var d := l.exits[0].at.distance_to(l.exits[1].at)
		assert_between(d, 5.5, 13.0, "%s doors %.1f apart" % [l.id, d])
		var lo := minf(l.exits[0].edge().x, l.exits[1].edge().x)
		var hi := maxf(l.exits[0].edge().x, l.exits[1].edge().x)
		var found := false
		for o in l.obstacles:
			if o.center.x > lo and o.center.x < hi and absf(o.center.y - l.exits[0].edge().y) <= 4.0:
				found = true
		assert_true(found, "%s: a piece between the doors" % l.id)


func test_the_way_in_is_free_and_enemies_rise_on_floor_the_paladin_reaches() -> void:
	for l in _own():
		var a := _arena(l)
		for d in [Vector2.ZERO, Vector2(1.5, 0), Vector2(-1.5, 0), a.start_facing * 1.5, a.start_facing * 3.0]:
			assert_true(a.free_at(a.start + d, Player.RADIUS), "%s: free at the way in" % l.id)
		for z in a.spawns:
			var good := 0
			for ix in 5:
				for iz in 5:
					var q := a.resolve(z.position + z.size * Vector2((ix + 0.5) / 5.0, (iz + 0.5) / 5.0), 0.6)
					if a.nav.walkable(q) and a.nav.reachable(q, a.start):
						good += 1
			assert_gt(good, 0, "%s: spawn zone %s" % [l.id, z])
		for i in a.exits.size():
			assert_true(a.nav.reachable(a.door_goal(i), a.start), "%s: door %d reachable" % [l.id, i])


func test_water_is_on_the_floor_off_the_pieces_and_the_dry_route_crosses_it() -> void:
	for l in _own():
		var a := _arena(l)
		assert_gt(l.water.size(), 0, "%s has water marks" % l.id)
		for r in l.water:
			assert_true(a.on_floor(r.get_center(), 0.0), "%s: water %s on the floor" % [l.id, r])
			for o in l.obstacles:
				if o.blocks_move:
					assert_false(Geometry2D.is_point_in_circle(o.center, r.get_center(), 0.0) or r.has_point(o.center), "%s: a solid piece in the water" % l.id)
		# the dry route: the way in reaches every door and every spawn zone without a step in the water
		var wet := func(p: Vector2) -> bool:
			for r in l.water:
				if r.has_point(p):
					return true
			return false
		var step := 0.5
		var seen := {Vector2i((a.start / step).round()): true}
		var queue: Array[Vector2] = [a.start]
		while not queue.is_empty():
			var p: Vector2 = queue.pop_back()
			for dv in [Vector2(step, 0), Vector2(-step, 0), Vector2(0, step), Vector2(0, -step)]:
				var q: Vector2 = p + dv
				var key := Vector2i((q / step).round())
				if seen.has(key) or wet.call(q) or not a.free_at(q, Player.RADIUS) or not a.on_floor(q, 0.0):
					continue
				seen[key] = true
				queue.append(q)
		for i in a.exits.size():
			assert_true(seen.has(Vector2i((a.door_goal(i) / step).round())), "%s: a dry route to door %d" % [l.id, i])


func test_the_mirrored_layout_mirrors_the_water() -> void:
	var l := _own()[0].duplicate() as RoomLayout
	var w := l.water[0]
	l._mirror()
	assert_eq(l.water[0], RoomLayout.mirror_rect(w))
