extends GutTest
## E6 (DT-003): "Qualidade gráfica" Alta, Média, Baixa (GraphicsQuality): each level costs no more than the one above,
## the option is in the save and on the options screen, and the levels land on the viewport and the environment.


func test_three_levels_each_no_dearer_than_the_one_above() -> void:
	assert_eq(GraphicsQuality.LEVELS.size(), 3)
	assert_eq(GraphicsQuality.TEXT.size(), 3)
	for i in range(1, 3):
		var up: Dictionary = GraphicsQuality.settings(i - 1)
		var s: Dictionary = GraphicsQuality.settings(i)
		assert_lte(s.scale, up.scale, "scale")
		assert_lte(s.msaa, up.msaa, "MSAA")
		assert_lte(s.shadow_atlas, up.shadow_atlas, "shadows")
		assert_lte(s.sun_shadow, up.sun_shadow, "sun shadows")
		assert_lte(s.soft_shadows, up.soft_shadows, "soft shadows")
		for k in ["volumetric_fog", "ssao", "ssr"]:
			assert_true(up[k] or not s[k], "%s never comes back at a lower level" % k)
	var high := GraphicsQuality.settings(GraphicsQuality.HIGH)
	assert_eq(high.scale, 1.0, "Alta is the look the art was made for")
	assert_true(high.volumetric_fog and high.ssao and high.ssr)
	assert_eq(GraphicsQuality.settings(-3), GraphicsQuality.settings(GraphicsQuality.HIGH), "clamped")
	assert_eq(GraphicsQuality.settings(9), GraphicsQuality.settings(GraphicsQuality.LOW), "clamped")


func test_the_option_is_saved_and_has_its_words() -> void:
	assert_eq(SaveData.defaults().options.quality, GraphicsQuality.HIGH, "Alta by default")
	assert_eq(SaveData.merged({"options": {"quality": 2}}).options.quality, 2, "kept from the file")
	assert_eq(SaveData.merged({"options": {}}).options.quality, GraphicsQuality.HIGH, "old saves get Alta")
	for key in GraphicsQuality.TEXT:
		assert_ne(T.t(key), String(key), "%s has its text" % key)
	assert_ne(T.t(&"opt_quality"), "opt_quality")


func test_the_levels_land_on_the_environment() -> void:
	var e := Environment.new()
	var forward := RenderingServer.get_current_rendering_method() != "gl_compatibility"
	GraphicsQuality.apply_environment(e, GraphicsQuality.LOW)
	assert_false(e.volumetric_fog_enabled or e.ssao_enabled or e.ssr_enabled, "Baixa: no screen effects")
	GraphicsQuality.apply_environment(e, GraphicsQuality.MEDIUM)
	assert_true(e.ssao_enabled, "Média keeps the contact shadows")
	assert_false(e.volumetric_fog_enabled or e.ssr_enabled)
	GraphicsQuality.apply_environment(e, GraphicsQuality.HIGH)
	assert_eq(e.volumetric_fog_enabled, forward, "Alta: fog in the air where the renderer has it")
	assert_eq(e.ssr_enabled, forward)
	assert_true(e.ssao_enabled)
	GraphicsQuality.apply_environment(null, GraphicsQuality.LOW)  # no world yet: nothing happens


func test_the_levels_land_on_a_viewport() -> void:
	var vp := SubViewport.new()
	add_child_autofree(vp)
	GraphicsQuality.apply_viewport(vp, GraphicsQuality.LOW)
	assert_almost_eq(vp.scaling_3d_scale, GraphicsQuality.settings(GraphicsQuality.LOW).scale, 0.001)
	assert_eq(vp.msaa_3d, Viewport.MSAA_DISABLED)
	assert_eq(vp.positional_shadow_atlas_size, 1024)
	GraphicsQuality.apply_viewport(vp, GraphicsQuality.HIGH)
	assert_almost_eq(vp.scaling_3d_scale, 1.0, 0.001)
	assert_eq(vp.scaling_3d_mode, Viewport.SCALING_3D_MODE_BILINEAR, "full size: no upscaler")
	assert_eq(vp.msaa_3d, Viewport.MSAA_2X)
	assert_eq(vp.positional_shadow_atlas_size, 4096)
	# the window back to the game's level (Alta when no save says otherwise)
	GraphicsQuality.apply_viewport(get_tree().root, GraphicsQuality.current(int(Save.option("quality"))))


func test_the_options_screen_shows_the_row() -> void:
	var o := OptionsScreen.new()
	add_child_autofree(o)
	o.open()
	assert_not_null(o.find_child("opt_quality_1", true, false), "the row's arrows")
	assert_not_null(o.find_child("opt_quality_-1", true, false))
