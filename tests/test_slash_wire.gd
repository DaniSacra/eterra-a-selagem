extends GutTest
## C12d (VX-01, VX-10): the light of a cut is drawn at the Emeth's tip and already sweeping on the frame of the blow;
## a blow's chips are grey slivers along their flight, gone well before 8 frames of the movie.

var fx: Fx


func before_each() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0, 30, 30)
	add_child_autofree(camera)
	camera.look_at(Vector3.ZERO)
	var overlay := Control.new()
	add_child_autofree(overlay)
	fx = Fx.new()
	add_child_autofree(fx)
	fx.setup(camera, overlay)


func _live(list_name: StringName) -> ShaderMaterial:
	for e: Dictionary in fx.get(list_name):
		if (e.node as Node3D).visible:
			return e.mat
	return null


func test_a_cut_is_drawn_at_the_blade_tip() -> void:
	fx.slash(Vector2.ZERO, Vector2.RIGHT, 5.4, 150.0, Combat.EMETH, Combat.SLASH_TIME)
	for list: StringName in [&"_slashes", &"_inks"]:
		var mat := _live(list)
		assert_not_null(mat, "%s shown" % list)
		assert_almost_eq(float(mat.get_shader_parameter(&"reach_m")), 5.4, 0.001)
		assert_almost_eq(float(mat.get_shader_parameter(&"blade_m")), Fx.BLADE_REACH, 0.001)
	assert_almost_eq(float(_live(&"_slashes").get_shader_parameter(&"band_from")), Fx.SLASH_INNER, 0.001)
	assert_almost_eq(float(_live(&"_inks").get_shader_parameter(&"band_from")), Fx.INK_INNER, 0.001)
	# the mesh starts inside the tip, so the edge is never pushed to the outer side
	assert_lt(Fx.SLASH_INNER * 5.4, Fx.BLADE_REACH)


func test_a_cut_not_of_the_paladin_keeps_its_outer_edge() -> void:
	fx.slash(Vector2.ZERO, Vector2.RIGHT, 4.0, 60.0, Color.VIOLET, 0.2, false, 0.9, false, 0.0)
	assert_eq(float(_live(&"_slashes").get_shader_parameter(&"blade_m")), 0.0)


func test_a_cut_sweeps_with_the_blade_in_three_frames() -> void:
	fx.slash(Vector2.ZERO, Vector2.RIGHT, 5.4, 150.0, Combat.EMETH, Combat.SLASH_TIME)
	var mat := _live(&"_slashes")
	var sweep: float = mat.get_shader_parameter(&"sweep")
	var head := func() -> float: return clampf(float(mat.get_shader_parameter(&"t")) / sweep, 0.0, 1.0)
	assert_gt(head.call(), 0.2, "already on its way on the frame of the blow")
	fx.animate(1.0 / 60.0)
	assert_lt(head.call(), 1.0, "still sweeping on the next frame")
	fx.animate(1.0 / 60.0)
	assert_almost_eq(head.call(), 1.0, 0.02, "through by the third frame")


func test_a_chip_is_a_sliver_along_its_flight() -> void:
	var w := 0.04
	var fast := Fx.streak(Vector3(0, 0, 9.0), w)
	assert_almost_eq(fast.normalized().z, 1.0, 0.001, "along the flight")
	assert_almost_eq(fast.length(), w * Fx.MOTE_LONG.y, 0.0001, "never longer than 4 widths")
	assert_almost_eq(Fx.streak(Vector3(0.1, 0, 0), w).length(), w * Fx.MOTE_LONG.x, 0.0001, "never shorter than 2")
	assert_almost_eq(Fx.streak(Vector3.ZERO, w).length(), w * Fx.MOTE_LONG.x, 0.0001, "still: lies along x")


func test_chips_are_gone_before_eight_movie_frames() -> void:
	fx.chips(Vector3.ZERO, Vector3.RIGHT, Combat.CHIP_COLOR, 6, Combat.CHIP_SPEED, Combat.CHIP_SIZE, Combat.CHIP_LIFE)
	assert_eq(fx.showing(&"motes"), 6)
	for i in 16:  # 8 frames at 30 fps
		fx.animate(1.0 / 60.0)
	assert_eq(fx.showing(&"motes"), 0)
	var lit: Color = Combat.CHIP_COLOR * Fx.MOTE_GLOW
	assert_lt(lit.s, 0.2, "grey, not the blow's colour")
