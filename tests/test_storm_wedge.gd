extends GutTest
## Art review P2: the storm's lanes share the floor round Morvath (GroundLook.storm_wedges) so they never add up.


func test_the_wedges_split_every_gap_between_neighbours() -> void:
	var dirs := PackedVector2Array()
	for a: float in [0.0, 55.0, 118.0, 180.0, 236.0, 300.0]:
		dirs.append(Vector2.from_angle(deg_to_rad(a)))
	var w := GroundLook.storm_wedges(dirs)
	assert_eq(w.size(), 6)
	var total := 0.0
	for v in w:
		total += v.x + v.y
	assert_almost_eq(total, TAU, 0.001, "the wedges cover the whole turn once")
	# the lane at 0 degrees: 30 degrees to the one at 300 (smaller side), 27.5 to the one at 55
	assert_almost_eq(rad_to_deg(w[0].x), 30.0, 0.01)
	assert_almost_eq(rad_to_deg(w[0].y), 27.5, 0.01)
	# the neighbours meet on the same line
	assert_almost_eq(w[0].y, w[1].x, 0.0001)


func test_a_lane_alone_keeps_its_width() -> void:
	var w := GroundLook.storm_wedges(PackedVector2Array([Vector2.RIGHT]))
	assert_eq(w[0], Vector2.ZERO)
