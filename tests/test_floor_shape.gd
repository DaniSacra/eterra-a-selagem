extends GutTest
## The floor of a room as data (FloorShape, cycle C11): the circle of the Seal Chamber and the hall's rectangle.

const EPS := 0.0001


func test_circle_contains_clamps_and_measures_its_edge() -> void:
	var c := FloorShape.circle(12.5)
	assert_true(c.is_round())
	assert_true(c.contains(Vector2(0, 12.0), 0.5), "the paladin's middle may stand 12 m out")
	assert_false(c.contains(Vector2(0, 12.01), 0.5))
	assert_almost_eq(c.edge_distance(Vector2(3, 4)), 7.5, EPS)
	assert_almost_eq(c.edge_distance(Vector2(0, 13.5)), -1.0, EPS, "negative outside")
	assert_eq(c.clamp(Vector2(1, 1), 0.5), Vector2(1, 1), "inside: untouched")
	var q := c.clamp(Vector2(30, 0), 0.5)
	assert_almost_eq(q.x, 12.0, EPS, "pushed back along its way to the middle")
	assert_almost_eq(q.y, 0.0, EPS)
	# no corner anywhere: the same 12 m in every direction
	for k in 36:
		var far := Vector2.from_angle(TAU * k / 36.0) * 40.0
		assert_almost_eq(c.clamp(far, 0.5).length(), 12.0, EPS)


func test_a_circle_off_the_origin() -> void:
	var c := FloorShape.circle(5.0, Vector2(10, -2))
	assert_true(c.contains(Vector2(14, -2), 1.0))
	assert_false(c.contains(Vector2(0, 0)))
	assert_almost_eq(c.clamp(Vector2(30, -2), 1.0).x, 14.0, EPS)
	assert_almost_eq(c.cut(Vector2(10, -2), Vector2.RIGHT, 99.0), 5.0, EPS)


func test_circle_cuts_a_lane_at_its_edge() -> void:
	var c := FloorShape.circle(12.5)
	assert_almost_eq(c.cut(Vector2.ZERO, Vector2.RIGHT, 26.0), 12.5, EPS, "from the middle: to the edge")
	assert_almost_eq(c.cut(Vector2.ZERO, Vector2.RIGHT, 6.0), 6.0, EPS, "shorter than the floor: whole")
	assert_almost_eq(c.cut(Vector2(-10, 0), Vector2.RIGHT, 40.0), 22.5, EPS, "across the whole floor")
	assert_almost_eq(c.cut(Vector2(10, 0), Vector2.RIGHT, 40.0), 2.5, EPS, "toward the near edge")
	assert_almost_eq(c.cut(Vector2(0, -1.2), Vector2.DOWN, 16.0, 1.4), 12.3, EPS, "a body stops with its edge at the edge")
	assert_almost_eq(c.cut(Vector2.ZERO, Vector2.UP, 26.0, -0.3), 12.8, EPS, "a negative margin goes past the edge")
	assert_eq(c.cut(Vector2(20, 0), Vector2.LEFT, 10.0), 0.0, "from outside: nothing")
	assert_eq(c.cut(Vector2.ZERO, Vector2.ZERO, 10.0), 0.0, "no way: nothing")
	# a chord: the point where it leaves is on the edge
	var from := Vector2(-6, 3)
	var dir := Vector2(1, 0.4).normalized()
	var t := c.cut(from, dir, 99.0)
	assert_almost_eq((from + dir * t).length(), 12.5, 0.001)


func test_rectangle_keeps_the_hall_as_it_was() -> void:
	var r := FloorShape.rect(Vector2(14.8, 13.8))
	assert_false(r.is_round())
	assert_true(r.contains(Vector2(14.2, 0), 0.5))
	assert_false(r.contains(Vector2(14.3, 0), 0.5), "strictly inside, as Arena.inside always was")
	assert_eq(r.clamp(Vector2(30, -30), 0.5), Vector2(14.3, -13.3))
	assert_almost_eq(r.edge_distance(Vector2(10, 0)), 4.8, EPS)
	assert_almost_eq(r.edge_distance(Vector2(17.8, 17.8)), -5.0, EPS)
	assert_almost_eq(r.cut(Vector2.ZERO, Vector2.RIGHT, 99.0), 14.8, EPS)
	assert_almost_eq(r.cut(Vector2.ZERO, Vector2(1, 1).normalized(), 99.0), 13.8 * sqrt(2.0), 0.001, "by the nearer side")
	assert_almost_eq(r.cut(Vector2.ZERO, Vector2.UP, 99.0, 1.0), 12.8, EPS)
	assert_eq(r.extent(), Vector2(14.8, 13.8))
	assert_eq(FloorShape.circle(12.5).extent(), Vector2(12.5, 12.5))
