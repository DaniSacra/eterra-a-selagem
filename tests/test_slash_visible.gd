extends GutTest
## BUG (cycle r9 sequence): the sword's arc never showed in 8 frames 0.1 s apart. The arc must exist, be visible, hold
## light and stay alive long enough (SLASH_MIN_LIFE) to be seen by a frame sampled up to 0.1 s after the blow.


func _slash(time: float) -> Fx:
	var fx := Fx.new()
	add_child_autofree(fx)
	fx.setup(Camera3D.new(), Control.new())
	fx.slash(Vector2.ZERO, Vector2(0, 1), 2.4, 150.0, Combat.EMETH, time)
	return fx


func _lit(fx: Fx) -> bool:
	var s: Dictionary = fx._slashes[0]
	for e: Dictionary in fx._slashes:
		if (e.node as Node3D).visible:
			s = e
	return (s.node as Node3D).visible and float((s.mat as ShaderMaterial).get_shader_parameter(&"intensity")) > 0.0


func test_the_arc_is_alive_after_the_blow() -> void:
	for time in [Combat.SLASH_TIME, Combat.HEAVY_SLASH_TIME, Combat.FINISHER_SLASH_TIME]:
		var fx := _slash(time)
		assert_true(_lit(fx), "visible at once")
		for i in 9:  # 0.15 s at 60 fps
			fx.animate(1.0 / 60.0)
		assert_true(_lit(fx), "still alive 0.15 s after a %s s cut" % time)
		var s: Dictionary = fx._slashes[0]
		var t: float = (s.mat as ShaderMaterial).get_shader_parameter(&"t")
		assert_lt(t, 0.95, "its light has not run out at 0.15 s")


func test_the_wave_leaves_its_path_lit() -> void:
	var fx := Fx.new()
	add_child_autofree(fx)
	fx.setup(Camera3D.new(), Control.new())
	var pr := Projectiles.new()
	add_child_autofree(pr)
	pr.fx = fx
	pr.fire_wave(Projectiles.Kind.SPARK, Vector2.ZERO, Vector2(0, 1), 10.0, 8.0, 1.0, Combat.EMETH, [] as Array[StringName])
	var lit := 0
	for e: Dictionary in fx._thrusts:
		if (e.node as Node3D).visible:
			lit += 1
	assert_eq(lit, 1, "a beam along the flight")
	for i in 12:  # 0.2 s
		fx.animate(1.0 / 60.0)
	var alive := false
	for e: Dictionary in fx._thrusts:
		alive = alive or (e.node as Node3D).visible
	assert_true(alive, "still lit 0.2 s after the throw")
