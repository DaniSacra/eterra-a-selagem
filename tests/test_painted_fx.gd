extends GutTest
## The hand-painted sword effects (docs/art/vfx_painted_style.md, Fx.painted_*): the blow picks its sheet, a card steps its
## frames without blending, the stylized look draws them and the classic look (or --painted-fx=off) keeps the old effects.


func after_each() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	Dev.drop("painted-fx")


func _fx() -> Fx:
	var fx := Fx.new()
	add_child_autofree(fx)
	fx.setup(Camera3D.new(), Control.new())
	return fx


func _lit(list: Array[Dictionary]) -> int:
	var n := 0
	for e in list:
		if (e.node as Node3D).visible:
			n += 1
	return n


func test_a_blow_picks_its_sheet() -> void:
	assert_eq(Fx.painted_sheet(true, false, true, 0), &"spin", "a turn is the spin, finisher or not")
	assert_eq(Fx.painted_sheet(true, true, false, 0), &"spin")
	assert_eq(Fx.painted_sheet(false, true, false, 0), &"smash", "a heavy blow is the smash")
	assert_eq(Fx.painted_sheet(false, false, true, 0), &"cut2", "the finisher's arc is the wider cut")
	assert_eq(Fx.painted_sheet(false, false, false, 0), &"cut1")
	assert_eq(Fx.painted_sheet(false, false, false, 1), &"cut2", "the light blows take turns")
	assert_eq(Fx.painted_sheet(false, false, false, 2), &"cut1")


func test_every_sheet_is_there_with_its_frames() -> void:
	for id: StringName in Fx.PAINTED_SHEETS:
		var def: Dictionary = Fx.PAINTED_SHEETS[id]
		var tex := def.tex as Texture2D
		var grid: Vector2 = def.grid
		assert_not_null(tex, str(id))
		assert_eq(tex.get_width() % int(grid.x), 0, "%s: whole cells" % id)
		assert_lte(int(def.frames), int(grid.x * grid.y), "%s: frames fit the grid" % id)


func test_the_frame_is_stepped_from_the_life() -> void:
	assert_eq(Fx.painted_frame(0.0, 6), 0)
	assert_eq(Fx.painted_frame(0.16, 6), 0)
	assert_eq(Fx.painted_frame(0.17, 6), 1)
	assert_eq(Fx.painted_frame(0.5, 6), 3)
	assert_eq(Fx.painted_frame(0.999, 6), 5)
	assert_eq(Fx.painted_frame(1.0, 6), 5, "never past the last frame")
	assert_eq(Fx.painted_frame(-1.0, 4), 0)
	var seen := {}
	for i in 100:
		seen[Fx.painted_frame(i / 99.0, 8)] = true
	assert_eq(seen.size(), 8, "all the frames of the spin, each whole")


func test_a_card_lives_its_time_then_goes() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var fx := _fx()
	fx.painted_swing(false, false, false, Vector2.ZERO, Vector2(0, 1), 2.6, 150.0, Combat.EMETH, false)
	assert_eq(_lit(fx._painted_cards), 1)
	var card: Dictionary = fx._painted_cards[0]
	var mat := card.mat as ShaderMaterial
	assert_eq(float(mat.get_shader_parameter(&"life")), 0.0)
	assert_almost_eq(float(mat.get_shader_parameter(&"keep_deg")), 150.0, 0.01, "trimmed to the blow's angle")
	for i in 4:
		fx.animate(1.0 / 60.0)
	var mid := float(mat.get_shader_parameter(&"life"))
	assert_between(mid, 0.3, 0.7)
	for i in 10:
		fx.animate(1.0 / 60.0)
	assert_eq(_lit(fx._painted_cards), 0, "gone after 0.13 s and a few frames")


func test_a_wide_blow_keeps_the_whole_sheet_arc() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var fx := _fx()
	fx.painted_swing(false, false, true, Vector2.ZERO, Vector2(0, 1), 2.6, 330.0, Combat.EMETH, true)
	var card: Dictionary = fx._painted_cards[0]
	assert_eq(float((card.mat as ShaderMaterial).get_shader_parameter(&"keep_deg")), float(Fx.PAINTED_SHEETS[&"cut2"].span))
	assert_eq(float((card.mat as ShaderMaterial).get_shader_parameter(&"flip")), 1.0)
	assert_eq(_lit(fx._painted_cards), 2, "the finisher flies a second, paler card past the blow")


func test_a_spin_is_whole_and_a_smash_is_a_fan() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var fx := _fx()
	fx.painted_swing(true, false, false, Vector2.ZERO, Vector2(0, 1), 3.0, 360.0, Combat.EMETH, false)
	assert_eq(float((fx._painted_cards[0].mat as ShaderMaterial).get_shader_parameter(&"mode")), 0.0)
	fx.painted_swing(false, true, false, Vector2.ZERO, Vector2(0, 1), 2.6, 120.0, Combat.EMETH, false)
	var smash: Dictionary = fx._painted_cards[1]
	assert_eq(float((smash.mat as ShaderMaterial).get_shader_parameter(&"mode")), 2.0)
	assert_almost_eq(float((smash.mat as ShaderMaterial).get_shader_parameter(&"keep_deg")), 110.0, 0.01, "no wider than the paint")


func test_the_contact_is_a_spark_and_a_ring() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var fx := _fx()
	fx.contact(Vector3(1, 1, 1), Vector3(1, 0, 0), Combat.EMETH, false, 0)
	assert_eq(_lit(fx._painted_sparks), 1)
	assert_eq(_lit(fx._painted_cards), 1, "the broken ring under the one struck")
	assert_eq(_lit(fx._contacts), 0, "the procedural star is not drawn")
	assert_eq(fx.showing(&"contacts"), 1, "the painted spark counts against the contact budget")


func test_the_switch() -> void:
	assert_false(Fx.painted_on(), "the classic look keeps the old effects")
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	assert_true(Fx.painted_on(), "on by default in the stylized look")
	Dev.put("painted-fx", "off")
	assert_false(Fx.painted_on(), "--painted-fx=off")
	var fx := _fx()
	fx.contact(Vector3.ONE, Vector3.RIGHT, Combat.EMETH)
	assert_eq(_lit(fx._painted_sparks), 0)
	assert_eq(_lit(fx._contacts), 1, "off: the old contact star")
	Dev.drop("painted-fx")
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	fx.contact(Vector3.ONE, Vector3.RIGHT, Combat.EMETH)
	assert_eq(_lit(fx._painted_sparks), 0, "classic: the old one too")


func test_without_the_ribbon_the_ink_stays() -> void:
	var fx := _fx()
	fx.slash(Vector2.ZERO, Vector2(0, 1), 2.4, 150.0, Combat.EMETH, 0.12, false, 0.9, true, Fx.BLADE_REACH, false)
	assert_eq(_lit(fx._slashes), 0, "no ribbon")
	assert_eq(_lit(fx._inks), 1, "the ink under the cut stays")
