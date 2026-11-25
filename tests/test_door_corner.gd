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
