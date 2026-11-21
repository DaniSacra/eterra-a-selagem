extends GutTest
## Cadence review 7 (P1, docs/design/combat_cadence.md 7): in the Compatibility renderer's stylized look an armed rune
## tile read only by its frame. RunesLook sets paint_compat_* on the rune floor there only; their defaults are neutral,
## the classic rune floor has none of them, so Forward+ and the classic look draw exactly as before.

const STAGE := "res://data/stages/catacombs.tres"
const NAMES: Array[StringName] = [&"paint_compat_gain", &"paint_compat_fill", &"paint_compat_glow", &"paint_compat_strike"]


func before_each() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func after_all() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func _runes() -> RunesLook:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	we.environment = env
	add_child_autofree(we)
	var moon := DirectionalLight3D.new()
	add_child_autofree(moon)
	RoomMood.own(we, moon)
	var stage: StageDef = load(STAGE)
	var layout: RoomLayout = null
	for l in stage.layouts:
		if l.id == &"runes":
			layout = l
	var a := Arena.new()
	add_child_autofree(a)
	a.build(layout, 3, 1406)
	return a.look as RunesLook


func test_the_compat_uniforms_are_neutral_by_default_and_only_painted() -> void:
	var neutral := {&"paint_compat_gain": 1.0, &"paint_compat_fill": 0.0, &"paint_compat_glow": 0.0,
		&"paint_compat_strike": 0.0}
	var painted := {}
	for u: Dictionary in ArenaKit.RUNE_FLOOR_PAINT.get_shader_uniform_list():
		painted[u.name] = true
	for k: StringName in NAMES:
		assert_true(painted.has(String(k)), "the painted rune floor reads %s" % k)
	for u: Dictionary in ArenaKit.RUNE_FLOOR.get_shader_uniform_list():
		assert_false(String(u.name).begins_with("paint_compat"), "the classic rune floor has no %s" % u.name)
	var inc := (load("res://assets/shaders/rune_tiles.gdshaderinc") as ShaderInclude).code
	for k: StringName in neutral:
		var v: float = neutral[k]
		assert_true(inc.contains("uniform float %s = %s;" % [k, "1.0" if v == 1.0 else "0.0"]), "%s defaults to %s" % [k, v])


func test_only_the_compatibility_renderer_sets_them() -> void:
	var compat := RenderingServer.get_current_rendering_method() == "gl_compatibility"
	var look := _runes()
	var mat := look.floor_mat
	var want := {&"paint_compat_gain": RunesLook.COMPAT_GAIN, &"paint_compat_fill": RunesLook.COMPAT_FILL,
		&"paint_compat_glow": RunesLook.COMPAT_GLOW, &"paint_compat_strike": RunesLook.COMPAT_STRIKE}
	for k: StringName in NAMES:
		var v: Variant = mat.get_shader_parameter(k)
		if compat:
			assert_almost_eq(float(v), float(want[k]), 0.0001, "%s set in Compatibility" % k)
		else:
			assert_null(v, "%s untouched off Compatibility" % k)
	# switching to the stylized look and back keeps them as they were (nothing set off that renderer)
	VisualProfile.toggle()
	look.get_parent().restyle()
	assert_eq(mat.shader, ArenaKit.RUNE_FLOOR_PAINT)
	if not compat:
		for k: StringName in NAMES:
			assert_null(mat.get_shader_parameter(k), "%s still untouched stylized" % k)
	# the armed tile reads stronger there, never weaker: gain and glow up, the stone laid toward the amber
	assert_true(RunesLook.COMPAT_GAIN >= 1.0 and RunesLook.COMPAT_GLOW > 0.0 and RunesLook.COMPAT_FILL > 0.0)
	assert_true(RunesLook.COMPAT_FILL < 1.0, "the frame and the marks still show through")
