extends GutTest
## Combate C1 (docs/art/combate_c1_leitura.md 6): a line that still follows the paladin is a thread, and as it locks it
## pulses once. Only drawn: the zone's life, place and damage are the same.

var ground: Ground


func before_each() -> void:
	ground = Ground.new()
	add_child_autofree(ground)


func _strength(z: Ground.Zone) -> float:
	return z.mat.get_shader_parameter(&"strength")


func test_a_tracking_line_is_a_thin_thread() -> void:
	var z := ground.add_line_warning(Vector2.ZERO, Vector2.RIGHT, 6.0, 2.4, 1.0, 0.0)
	var settled := _strength(z)
	ground.track_line(z)
	assert_almost_eq(_strength(z), GroundLook.TRACK_STRENGTH, 0.001)
	assert_lt(_strength(z), settled)
	var a := ground.add_aim_warning(Vector2.ZERO, Vector2.RIGHT, 8.0, 0.5, 1.0, 0.0)
	ground.track_line(a)
	assert_almost_eq(a.mat.get_shader_parameter(&"aim_light"), GroundLook.TRACK_AIM_LIGHT, 0.001)
	assert_almost_eq(a.mat.get_shader_parameter(&"aim_px"), GroundLook.TRACK_AIM_PX, 0.001)
	assert_eq(a.mat.get_shader_parameter(&"fill_max"), 0.0, "no fill while it follows")


func test_the_lock_pulses_once_then_settles() -> void:
	var z := ground.add_line_warning(Vector2.ZERO, Vector2.RIGHT, 6.0, 2.4, 1.0, 0.0)
	ground.track_line(z)
	ground.lock_line(z)
	assert_almost_eq(z.lock_t, 0.0, 0.0001, "starts at the lock")
	var peak := 0.0
	for i in 40:
		ground.step(1.0 / 60.0)
		peak = maxf(peak, _strength(z))
	assert_almost_eq(peak, GroundLook.LOCK_STRENGTH_PEAK, 0.4, "up to the peak in LOCK_RISE")
	assert_almost_eq(_strength(z), GroundLook.WARNING_STRENGTH, 0.001, "and back to a piece")
	var t := z.lock_t
	ground.lock_line(z)
	assert_eq(z.lock_t, t, "once a blow: a second call changes nothing")


func test_an_aim_fills_from_the_lock_on() -> void:
	var z := ground.add_aim_warning(Vector2.ZERO, Vector2.RIGHT, 8.0, 0.5, 0.8, 0.0)
	ground.track_line(z)
	ground.step(0.4)
	ground.lock_line(z)
	assert_almost_eq(z.mat.get_shader_parameter(&"fill_max"), GroundLook.AIM_FILL, 0.0001)
	assert_almost_eq(z.mat.get_shader_parameter(&"fill_late"), z.life / z.total, 0.01, "the fill starts at the lock")
	for i in 30:
		ground.step(1.0 / 60.0)
	assert_almost_eq(z.mat.get_shader_parameter(&"aim_px"), GroundLook.LOCK_AIM_PX_SETTLED, 0.01)


func test_a_line_that_never_tracked_does_not_pulse() -> void:
	var z := ground.add_line_warning(Vector2.ZERO, Vector2.RIGHT, 6.0, 2.4, 1.0, 0.0)
	ground.lock_line(z)
	assert_eq(z.lock_t, -1.0)
	ground.lock_line(null)


func test_a_pooled_quad_comes_back_plain() -> void:
	var z := ground.add_aim_warning(Vector2.ZERO, Vector2.RIGHT, 8.0, 0.5, 0.5, 0.0)
	ground.track_line(z)
	ground.step(0.2)
	ground.lock_line(z)
	ground.step(1.0)
	var plain := ground.add_warning(Vector2.ZERO, 2.0, 1.0, 0.0)
	assert_eq(plain.mat.get_shader_parameter(&"fill_late"), GroundLook.AIM_FILL_LATE)
	assert_eq(plain.mat.get_shader_parameter(&"aim_px"), 0.0)
