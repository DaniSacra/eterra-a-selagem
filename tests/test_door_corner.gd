extends GutTest
## PT-6b (Daniel, 2026-11-25): the doors in use stand together in the north-east corner, 3 to 4.5 m apart, so the choice
## needs no walking from door to door; the third (when there is one) is to their left.

const STAGE := "res://data/stages/catacombs.tres"


func _layouts() -> Array[RoomLayout]:
	var stage: StageDef = load(STAGE)
	var out: Array[RoomLayout] = []
	for l in stage.layouts:
		if l.platform:
			continue
		for v in l.variant_count():
			out.append(l.variant(v))
	out.append(stage.trial_layout)
	out.append(stage.altar_layout)
	return out


func test_first_two_doors_are_in_the_north_east() -> void:
	for l in _layouts():
		if l.id == &"hall":
			continue
		var box := l.floor.bounds()
		assert_gte(l.exits.size(), 2, l.id)
		for i in 2:
			var e := l.exits[i]
			assert_gt(e.edge().x, 0.0, "%s: door %d east of the middle" % [l.id, i])
			assert_lt(e.edge().y, box.get_center().y, "%s: door %d in the north half" % [l.id, i])
			if l.id != &"altar":  # the chapel has its doors in the east wall itself
				assert_lt(e.edge().x, box.end.x - 1.0, "%s: door %d not glued to the east wall" % [l.id, i])
		var d := l.exits[0].at.distance_to(l.exits[1].at)
		assert_between(d, 3.0, 4.5, "%s: the two doors 3 to 4.5 m apart" % l.id)
		if l.exits.size() > 2 and l.id != &"bridge" and l.id != &"trial":
			assert_lt(l.exits[2].at.x, minf(l.exits[0].at.x, l.exits[1].at.x), "%s: the third to their left" % l.id)


## The hall of room 1 (built in code, layout "platform"): its portal and its east stairs are the first two doors and stand
## together in the north-east corner, with nothing of the room's collision on either spot.
func test_hall_first_two_doors_together_in_the_north_east() -> void:
	var stage: StageDef = load(STAGE)
	for n in [2, 3]:
		var a := Arena.new()
		add_child_autofree(a)
		a.build(stage.layouts[0], n, 1406)
		assert_eq(a.exits.size(), n)
		assert_eq(a.exit_zones.size(), n)
		assert_eq(a.exit_inward.size(), n)
		for i in 2:
			assert_gt(a.exits[i].x, 0.0, "hall door %d east of the middle" % i)
			assert_lt(a.exits[i].y, 0.0, "hall door %d in the north half" % i)
			assert_true(a.exit_zones[i].has_point(a.exits[i]), "hall door %d: its spot is in its zone" % i)
			assert_eq(a.resolve(a.exits[i], 0.4), a.exits[i], "hall door %d: nothing in front of it" % i)
		assert_between(a.exits[0].distance_to(a.exits[1]), 3.0, 4.5, "hall: the two doors 3 to 4.5 m apart")
		assert_lt(absf(a.door_pos.x - a.exits[0].x), 2.5, "the portal's light stands over door 0")
