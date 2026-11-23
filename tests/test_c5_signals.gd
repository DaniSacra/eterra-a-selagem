extends GutTest
## Lote C5 signals (drawing only): the ring closing round a Trinca's mound and the chevrons of the Varredor's bar.

func test_ring_closes_over_the_rise_time() -> void:
	assert_almost_eq(C5Marks.ring_radius(0.0, 3.5), C5Marks.RING_R0, 0.001)
	assert_almost_eq(C5Marks.ring_radius(3.5, 3.5), C5Marks.RING_R1, 0.001)
	assert_lt(C5Marks.ring_radius(1.75, 3.5), C5Marks.ring_radius(0.5, 3.5))
	assert_almost_eq(C5Marks.ring_radius(9.0, 3.5), C5Marks.RING_R1, 0.001)


func test_ring_shows_only_for_a_mound_that_will_rise() -> void:
	assert_true(C5Marks.ring_shown(true, 3.5, 1))
	assert_false(C5Marks.ring_shown(true, 3.5, 0), "the group is over")
	assert_false(C5Marks.ring_shown(false, 3.5, 2))
	assert_false(C5Marks.ring_shown(true, 0.0, 2))


func test_ring_is_ivory_never_red_or_gold() -> void:
	var c := C5Marks.RING_COLOR
	assert_gt(c.r, 0.8)
	assert_gt(c.g, 0.8)
	assert_gt(c.b, 0.6)
	assert_lt(C5Marks.ring_alpha(0.0, 3.5), 0.01)
	assert_lte(C5Marks.ring_alpha(3.5, 3.5), 1.0)


func test_chevrons_point_the_way_the_bar_turns() -> void:
	for way in [1.0, -1.0]:
		var aim := Vector2(0.6, 0.8)
		var turn := C5Marks.turn_dir(aim, way)
		var later := SweepRules.dir_at(aim, way, 200.0, 1.6, 0.05)
		assert_gt(turn.dot(later - aim), 0.0, "same side as the sweep (way %s)" % way)
		assert_almost_eq(turn.dot(aim), 0.0, 0.001)


func test_chevrons_lie_inside_the_bar() -> void:
	var from := Vector2(2, 3)
	var aim := Vector2.RIGHT
	var last := -1.0
	for k in C5Marks.CHEVRON_COUNT:
		var p := C5Marks.chevron_at(from, aim, 5.5, k, C5Marks.CHEVRON_COUNT)
		assert_gt((p - from).dot(aim), last)
		last = (p - from).dot(aim)
		assert_lt(last, 5.5)
		assert_almost_eq(p.y, 3.0, 0.001)
