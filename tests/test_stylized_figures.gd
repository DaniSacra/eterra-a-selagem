extends GutTest
## Eterra Stylized, the figures (STY-06; docs/art/stylized_spec.md 2.3 and 3.3, T18 to T25): the classic look keeps
## every parameter of the crowd, the hero, Emeth and their passes exactly as before (and the switch, F7, gives them
## back exactly); the stylized look puts the spec's numbers; the shaders branch on the global art_style only.

const SHADERS: Array[String] = [
	"res://assets/shaders/crowd.gdshader", "res://assets/shaders/crowd_outline.gdshader",
	"res://assets/shaders/emeth.gdshader", "res://assets/shaders/slash.gdshader", "res://assets/shaders/slash_ink.gdshader",
	"res://assets/shaders/chip.gdshader", "res://assets/shaders/ground.gdshader", "res://assets/shaders/ground_fill.gdshader",
]


func before_each() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func after_all() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func _def(id: StringName) -> EnemyDef:
	return load("res://data/enemies/%s.tres" % id) as EnemyDef


## Every parameter a material has (and its next passes'), by name: what the classic look must give back.
static func _params(m: Material) -> Dictionary:
	var out := {}
	var depth := 0
	while m != null and depth < 6:
		if m is ShaderMaterial:
			for u: Dictionary in (m as ShaderMaterial).shader.get_shader_uniform_list(true):
				out["%d/%s" % [depth, u.name]] = (m as ShaderMaterial).get_shader_parameter(u.name)
		elif m is BaseMaterial3D:
			for p: Dictionary in m.get_property_list():
				if p.usage & PROPERTY_USAGE_STORAGE:
					out["%d/%s" % [depth, p.name]] = m.get(p.name)
		out["%d/next" % depth] = m.next_pass != null
		m = m.next_pass
		depth += 1
	return out


func test_the_shaders_branch_on_the_global_art_style() -> void:
	for path in SHADERS:
		var code := (load(path) as Shader).code
		if path.ends_with("ground.gdshader") or path.ends_with("ground_fill.gdshader"):
			code = (load("res://assets/shaders/ground.gdshaderinc") as ShaderInclude).code
		assert_true(code.contains("global uniform float art_style"), path)
		assert_true(code.contains("art_style > 0.5"), path + " branches on it")
	var hero := (HeroBody.PAINT as Shader).code
	assert_false(hero.contains("art_style"), "the hero's shader is only put on him in the stylized look")


func test_the_classic_crowd_is_as_before_and_comes_back_after_the_switch() -> void:
	var renderer := CrowdRenderer.new()
	add_child_autofree(renderer)
	var common := _def(&"skeleton")
	var elite := _def(&"skeleton_elite")
	renderer.register(common)
	renderer.register(elite)
	var plain: ShaderMaterial = renderer._materials[common.id]
	var gilded: ShaderMaterial = renderer._materials[elite.id]
	assert_null(plain.next_pass, "classic: no shell on the common crowd (no pass and no cost added)")
	var edge := gilded.next_pass as ShaderMaterial
	assert_not_null(edge, "elites keep their thin outline")
	assert_eq(float(edge.get_shader_parameter(&"width")), CrowdRenderer.OUTLINE_WIDTH)
	assert_eq(edge.get_shader_parameter(&"color"), CrowdRenderer.OUTLINE_COLOR)
	var before_plain := _params(plain)
	var before_gilded := _params(gilded)
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var shell := plain.next_pass as ShaderMaterial
	assert_not_null(shell, "stylized: every figure has the shell (T20)")
	assert_almost_eq(float(shell.get_shader_parameter(&"style_width")), 0.04, 0.0001)
	assert_eq(shell.get_shader_parameter(&"style_color"), Color(0.07, 0.06, 0.06))
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	assert_eq(_params(plain), before_plain, "the classic crowd is given back exactly")
	assert_eq(_params(gilded), before_gilded)


func test_the_stylized_numbers_of_the_crowd_are_the_specs() -> void:
	# (the headless renderer has no shader defaults to ask: the declarations are read)
	var crowd := (load("res://assets/shaders/crowd.gdshader") as Shader).code
	assert_true(crowd.contains("uniform vec3 style_rim_color : source_color = vec3(1.0, 0.82, 0.62);"), "warm rim (T19)")
	assert_true(crowd.contains("uniform float style_flat = 0.35;"), "paint_flat (T21)")
	assert_true(crowd.contains("uniform float style_rim_power = 3.5;"), "fresnel 3 to 4")
	var hero := (HeroBody.PAINT as Shader).code
	assert_true(hero.contains("uniform vec3 rim_color : source_color = vec3(1.0, 0.82, 0.62);"), "the same warm rim on him")
	assert_true(hero.contains("uniform float flatten = 0.35;"))
	var bands := (load("res://assets/shaders/figure_paint.gdshaderinc") as ShaderInclude).code
	assert_true(bands.contains("0.42 + 0.30 * smoothstep(0.3 - w, 0.3 + w, ndl) + 0.28 * smoothstep(0.65 - w, 0.65 + w, ndl)"),
		"three bands: 0.42, 0.72, 1.0 at N.L 0.3 and 0.65 (T18)")


func test_the_classic_hero_and_emeth_are_as_before_and_come_back_after_the_switch() -> void:
	var body: Array = HeroBody.make()
	var model: Node3D = body[0]
	add_child_autofree(model)
	var mi: MeshInstance3D = null
	for n in model.find_children("*", "MeshInstance3D", true, false):
		if (n as MeshInstance3D).material_override is StandardMaterial3D and HeroBody.fills((n as MeshInstance3D).material_override):
			mi = n
			break
	assert_not_null(mi)
	var own := mi.material_override as StandardMaterial3D
	assert_almost_eq(own.emission_energy_multiplier, HeroBody.FILL, 0.0001, "classic: his StandardMaterial3D with the fill")
	var before := _params(own)
	var sword: MeshInstance3D = body[2]
	var core := sword.get_node(^"Blade/Core") as MeshInstance3D
	var core_mat := core.material_override as StandardMaterial3D
	assert_eq(core_mat.albedo_color, EmethSword.CORE * EmethSword.CORE_GLOW, "classic: the edge that blooms")
	var blade := (sword.get_node(^"Blade") as MeshInstance3D).material_override as ShaderMaterial
	var before_blade := _params(blade)
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var painted := mi.material_override as ShaderMaterial
	assert_not_null(painted, "stylized: his own shader")
	assert_eq(painted.shader, HeroBody.PAINT)
	assert_eq(painted.get_shader_parameter(&"albedo"), own.albedo_texture, "the same painting (the x-ray reads it)")
	var outline := painted.next_pass as ShaderMaterial
	assert_almost_eq(float(outline.get_shader_parameter(&"width")), 0.045, 0.0001, "T20: 0.045 m")
	var c := EmethSword.STYLE_CORE
	assert_lt(maxf(c.r, maxf(c.g, c.b)), 1.0, "the stylized edge never blooms")
	assert_eq(core_mat.albedo_color, c)
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	assert_eq(mi.material_override, own, "classic again: his own material back")
	assert_eq(_params(own), before)
	assert_eq(core_mat.albedo_color, EmethSword.CORE * EmethSword.CORE_GLOW)
	assert_eq(_params(blade), before_blade, "Emeth's numbers do not change: the shader reads the look")


func test_the_blink_after_a_hit_lightens_him_in_both_looks() -> void:
	var body: Array = HeroBody.make()
	var model: Node3D = body[0]
	add_child_autofree(model)
	var mi: MeshInstance3D = null
	for n in model.find_children("*", "MeshInstance3D", true, false):
		if HeroBody.fills((n as MeshInstance3D).material_override):
			mi = n
			break
	var both := HeroBody.materials(mi)
	assert_eq(both.size(), 2, "the classic and the stylized material")
	for m in both:
		assert_true(HeroBody.fills(m))
		HeroBody.set_fill(m, 0.5)
	assert_almost_eq((both[0] as StandardMaterial3D).emission_energy_multiplier, 0.5, 0.0001)
	assert_almost_eq(float((both[1] as ShaderMaterial).get_shader_parameter(&"fill")), 0.5, 0.0001)


func test_the_painting_filter_is_optional_and_off_by_default() -> void:
	assert_false(PaintPass.DEFAULT_ON, "STY-07 discarded by the spec's 5.2 (see the plan): off unless --paint-pass=1")
	assert_false(PaintPass.wanted(GraphicsQuality.LOW), "never at the Baixa")
	assert_false(PaintPass.wanted(GraphicsQuality.HIGH), "headless or off by default")


## LC-4 and LC-5 (the Compatibility renderer's stylized look): the compensations are uniforms that only that renderer
## sets; their defaults are neutral, so Forward+ (and the classic look everywhere) draw exactly as before, and the
## shaders only use them in their stylized branch.
func test_the_compatibility_compensation_is_neutral_off_that_renderer() -> void:
	var compat := RenderingServer.get_current_rendering_method() == "gl_compatibility"
	var renderer := CrowdRenderer.new()
	add_child_autofree(renderer)
	renderer.register(_def(&"guard_elite"))
	var mat := renderer._materials[&"guard_elite"] as ShaderMaterial
	var hero := HeroBody.painted(StandardMaterial3D.new())
	var ground := GroundLook.new_node()
	var floor_mat := ground.material_override as ShaderMaterial
	if compat:
		assert_almost_eq(float(mat.get_shader_parameter(&"style_gamma")), CrowdRenderer.COMPAT_GAMMA, 0.0001)
		assert_almost_eq(float(hero.get_shader_parameter(&"gamma")), HeroBody.COMPAT_GAMMA, 0.0001)
		assert_almost_eq(float(floor_mat.get_shader_parameter(&"style_compat_under")), GroundLook.COMPAT_UNDER, 0.0001)
	else:
		for m: ShaderMaterial in [mat, mat.next_pass as ShaderMaterial]:
			var g: Variant = m.get_shader_parameter(&"style_gamma")
			assert_true(g == null or is_equal_approx(float(g), 1.0), "the crowd's light is not raised off Compatibility")
		var hg: Variant = hero.get_shader_parameter(&"gamma")
		assert_true(hg == null or is_equal_approx(float(hg), 1.0), "nor the hero's")
		for m: ShaderMaterial in [floor_mat, floor_mat.next_pass as ShaderMaterial]:
			var gain: Variant = m.get_shader_parameter(&"style_compat_gain")
			var under: Variant = m.get_shader_parameter(&"style_compat_under")
			assert_true(gain == null or is_equal_approx(float(gain), 1.0), "the warnings' light is as before")
			assert_true(under == null or is_zero_approx(float(under)), "and nothing darkens the floor under Morvath's")
	ground.free()
	# the defaults in the shaders are the neutral ones, and the uniforms are read only where the look is stylized
	var crowd := (load("res://assets/shaders/crowd.gdshader") as Shader).code
	assert_true(crowd.contains("uniform float style_gamma = 1.0;"))
	assert_true(crowd.contains("if (styled && style_gamma != 1.0)"))
	var paint := (HeroBody.PAINT as Shader).code
	assert_true(paint.contains("uniform float gamma = 1.0;"))
	var inc := (load("res://assets/shaders/ground.gdshaderinc") as ShaderInclude).code
	assert_true(inc.contains("uniform float style_compat_gain = 1.0;"))
	assert_true(inc.contains("uniform float style_compat_under = 0.0;"))
	assert_true(inc.contains("art_style > 0.5 && style == 0 ? style_compat_gain : 1.0"))
	# the figure's light is raised by its luminance (hue and saturation kept), between the identity and 1/2.2
	assert_true(CrowdRenderer.COMPAT_GAMMA > 1.0 / 2.2 and CrowdRenderer.COMPAT_GAMMA < 1.0)
	assert_eq(HeroBody.COMPAT_GAMMA, CrowdRenderer.COMPAT_GAMMA)
