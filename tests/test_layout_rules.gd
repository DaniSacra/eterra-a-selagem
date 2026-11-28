extends GutTest
## QA sweep 2026-11-27 (night): the layout rules every room and variant of the stage must keep, built as the game builds
## them (Arena over RoomLayout.variant(n)): enemies rise on floor the paladin reaches and not beside the way in, no breakable,
## relic or vein stands in a hole, a wall or a gap, the way in has free floor around it, no two doors touch.

const STAGE := "res://data/stages/catacombs.tres"
## First-wave zones keep this far from the way in (the first wave never rises beside the paladin).
const SPAWN_FROM_START := 5.0
const BODY := 0.6


func _cases() -> Array[Dictionary]:
	var stage: StageDef = load(STAGE)
	var out: Array[Dictionary] = []
	for l in stage.layouts:
		if l.platform:
			continue
		for v in l.variant_count():
			out.append({"layout": l.variant(v), "name": "%s v%d" % [l.id, v], "exits": 2})
	out.append({"layout": stage.trial_layout, "name": "trial", "exits": 2})
	out.append({"layout": stage.altar_layout, "name": "altar", "exits": 2})
	return out


func _arena(c: Dictionary) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(c.layout, c.exits, 1406)
	return a


func _in_gap(a: Arena, p: Vector2) -> bool:
	for g in a.gaps:
		if g.has_point(p):
			return true
	return false


func test_the_way_in_has_free_floor_around_it() -> void:
	for c in _cases():
		var a := _arena(c)
		for d in [Vector2.ZERO, Vector2(1.5, 0), Vector2(-1.5, 0), a.start_facing * 1.5, a.start_facing * 3.0]:
			assert_true(a.free_at(a.start + d, Player.RADIUS), "%s: free at the way in %s + %s" % [c.name, a.start, d])
		assert_false(_in_gap(a, a.start), "%s: the way in is not in a gap" % c.name)


func test_spawn_zones_give_floor_the_paladin_reaches_away_from_the_way_in() -> void:
	for c in _cases():
		var a := _arena(c)
		var first: Array[Rect2] = a.spawns
		for zi in first.size():
			var z := first[zi]
			var good := 0
			var total := 0
			var near := 0
			for ix in 5:
				for iz in 5:
					var p := z.position + z.size * Vector2((ix + 0.5) / 5.0, (iz + 0.5) / 5.0)
					total += 1
					var q := a.resolve(p, BODY)
					if a.nav.walkable(q) and a.nav.reachable(q, a.start) and not _in_gap(a, q):
						good += 1
					if p.distance_to(a.start) < SPAWN_FROM_START:
						near += 1
			assert_gt(good, 0, "%s: spawn zone %d %s has no floor the paladin reaches" % [c.name, zi, z])
			assert_lt(near, total / 2 + 1, "%s: spawn zone %d %s is mostly beside the way in %s" % [c.name, zi, z, a.start])


func test_no_breakable_in_a_hole_a_wall_or_a_gap() -> void:
	for c in _cases():
		var a := _arena(c)
		for b in a.layout.breakables:
			assert_true(a.on_floor(b.at, 0.0), "%s: %s at %s is off the floor (a hole)" % [c.name, b.form, b.at])
			assert_true(a.free_at(b.at, minf(b.radius, 0.3)), "%s: %s at %s is inside a solid piece" % [c.name, b.form, b.at])
			assert_false(_in_gap(a, b.at), "%s: %s at %s is in a gap" % [c.name, b.form, b.at])


func test_relic_and_vein_spots_stand_on_free_floor() -> void:
	for c in _cases():
		var a := _arena(c)
		for p in a.layout.relic_spots:
			assert_true(a.free_at(p, 0.4), "%s: relic spot %s" % [c.name, p])
		for p in a.layout.gather_spots:
			assert_true(a.free_at(p, 0.4), "%s: vein spot %s" % [c.name, p])


func test_gaps_keep_off_the_way_in_and_the_doors() -> void:
	for c in _cases():
		var a := _arena(c)
		for g in a.gaps:
			assert_false(g.grow(1.0).has_point(a.start), "%s: gap %s on the way in" % [c.name, g])
			for i in a.exits.size():
				assert_false(g.has_point(a.door_goal(i)), "%s: gap %s on door %d" % [c.name, g, i])


func test_no_two_doors_touch() -> void:
	for c in _cases():
		var a := _arena(c)
		for i in a.exits.size():
			for j in range(i + 1, a.exits.size()):
				assert_gt(a.exits[i].distance_to(a.exits[j]), 3.0, "%s: doors %d and %d touch" % [c.name, i, j])
