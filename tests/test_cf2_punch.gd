extends GutTest
## CF2-03 (camera zoom punch) and CF2-06 (the music dip under the Apogeu and the Brado).


func test_punch_curve_rises_and_returns_within_120ms() -> void:
	assert_eq(Fx.punch_amount(0.0, 0.03), 0.0)
	assert_almost_eq(Fx.punch_amount(Fx.PUNCH_IN, 0.03), 0.03, 0.0001)
	assert_eq(Fx.punch_amount(Fx.PUNCH_IN + Fx.PUNCH_OUT, 0.03), 0.0)
	assert_true(Fx.PUNCH_IN + Fx.PUNCH_OUT < 0.12)
	assert_true(Fx.PUNCH_ZOOM * 1.5 <= 0.04 and Fx.PUNCH_ZOOM >= 0.02)


func test_punch_off_with_shake_option_and_largest_zoom_wins() -> void:
	var fx := Fx.new()
	fx.shake_scale = 0.0
	fx.punch(1.0)
	assert_eq(fx.cam_zoom(), 1.0)
	fx.shake_scale = 1.0
	fx.punch(1.0)
	fx.tick(Fx.PUNCH_IN)
	assert_almost_eq(fx.cam_zoom(), 1.0 + Fx.PUNCH_ZOOM, 0.001)
	fx.zoom = 1.05
	assert_eq(fx.cam_zoom(), 1.05)
	fx.free()


func test_music_blow_dips_about_3db_then_returns() -> void:
	var mix := MusicMix.new()
	mix.blow()
	mix.step(0.1)
	assert_almost_eq(mix.blow_duck, MusicMix.BLOW_DUCK, 0.001)
	assert_almost_eq(linear_to_db(mix.blow_duck), -3.0, 0.3)
	mix.step(0.2)
	mix.step(0.3)
	assert_eq(mix.blow_duck, 1.0)
