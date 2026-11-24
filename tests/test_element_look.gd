extends GutTest

func _reserved() -> Dictionary:
	return {
		"warning_red": GroundLook.WARNING_COLOR,
		"hazard": GroundLook.HAZARD_COLOR,
		"hazard_amber_doc": Color(1.0, 0.62, 0.25),
		"hero_teal": Player.RING_COLOR,
		"supremo_ring": Player.ULT_RING_COLOR,
		"emeth": Combat.EMETH,
		"spectral": Boss.SPECTRAL,
		"boss_violet": Boss.VIOLET,
		"curse": CurseAura.COLOR,
	}


func _dist(a: Color, b: Color) -> float:
	return Vector3(a.r - b.r, a.g - b.g, a.b - b.b).length()


func test_elements_distinct_from_reserved_colors() -> void:
	for c in ElementLook.all():
		for k in _reserved():
			assert_gt(_dist(c, _reserved()[k]), ElementLook.MIN_DISTANCE, "%s vs %s" % [c, k])


func test_elements_distinct_from_each_other() -> void:
	var a := ElementLook.all()
	for i in a.size():
		for j in range(i + 1, a.size()):
			assert_gt(_dist(a[i], a[j]), ElementLook.MIN_DISTANCE)


func test_no_violet_or_emerald_hue() -> void:
	for c in ElementLook.all():
		if c.s > 0.3:
			assert_false(c.h > 0.30 and c.h < 0.48, "emerald")
			assert_false(c.h > 0.68 and c.h < 0.85, "violet")
