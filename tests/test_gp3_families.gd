extends GutTest
## GP-3 (VFX "tinta em movimento", signature 4): every family has a form of its own in Fx (family_mark.gdshader), found by
## the family's name so the two new ones (Peste, Trovão) work the moment their enum entries exist. Only drawn.


func _fx() -> Fx:
	var fx := Fx.new()
	add_child_autofree(fx)
	fx.setup(Camera3D.new(), Control.new())
	return fx


func test_every_family_but_the_elo_has_a_form() -> void:
	for f in Boon.Family.values():
		if f == Boon.Family.DUO:
			assert_eq(Fx.form_of(f), -1, "the Elo shows the two families' own")
		else:
			var name := str(Boon.Family.find_key(f))
			assert_eq(Fx.form_of(f), Fx.FORM_BY_NAME.get(name, -1), name)
	assert_eq(Fx.form_of(Boon.Family.MARE), 5)
	assert_eq(Fx.form_of(99), -1, "an unknown family: no form, no crash")


func test_the_times_and_peaks_cover_every_form() -> void:
	var n: int = Fx.FORM_BY_NAME.size()
	assert_eq(Fx.FORM_SCREEN.size(), n)
	assert_eq(Fx.FORM_TIME.size(), n)
	assert_eq(Fx.mark_time(Boon.Family.CHAMA), 1.5)
	assert_eq(Fx.mark_time(Boon.Family.DUO), 0.5, "no form: the plain time")


func test_a_blow_in_a_family_colour_finds_its_family() -> void:
	for f in [Boon.Family.VEU, Boon.Family.MARE, Boon.Family.MARCA]:
		assert_eq(Fx.family_of(Boon.FAMILY_COLOR[f]), f)
	assert_eq(Fx.family_of(Combat.EMETH), -1)


func test_every_form_draws_its_mark_and_its_hit() -> void:
	var fx := _fx()
	for f in Boon.Family.values():
		fx.family_mark(f, Vector2(2, 2), 2.0, Boon.FAMILY_COLOR[f], 0.5)
		fx.family_hit(f, Vector3(1, 1, 1), Vector3.RIGHT, Boon.FAMILY_COLOR[f], false)
		fx.family_hit(f, Vector3(1, 1, 1), Vector3.RIGHT, Boon.FAMILY_COLOR[f], true)
	for form in 9:
		fx.form_mark(form, Vector2.ZERO, 1.5, Color(0.5, 0.6, 0.7), 0.4, Vector2.RIGHT, 40.0)
	assert_true(true, "no error for any form")


func test_the_spec_colours_of_the_two_new_families() -> void:
	assert_eq(Fx.PESTE_SULFUR, Color("c9b458"))
	assert_eq(Fx.PESTE_LICHEN, Color("9fae7a"))
	assert_eq(Fx.TROVAO_SLATE, Color("4e5866"))
	assert_eq(Fx.TROVAO_FLASH, Color("f1e08a"))
