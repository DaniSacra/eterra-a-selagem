extends GutTest


func test_ring_hidden_until_full() -> void:
	assert_eq(Player.ult_ring_look(-1.0), Vector2.ZERO)


func test_pulse_then_light_breath() -> void:
	var start := Player.ult_ring_look(0.0)
	assert_gt(start.y, 1.2, "opens wide at the fill")
	assert_almost_eq(start.x, 1.0, 0.001)
	var rest := Player.ult_ring_look(Player.ULT_RING_PULSE + 1.0)
	assert_eq(rest.y, 1.0)
	assert_between(rest.x, 0.4, 0.7, "a breath, never a glare")
