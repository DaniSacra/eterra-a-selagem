extends GutTest
## SW-O1 (docs/design/onboarding_sw_o.md): the arrival scene's clock, its skip and its colours.

const T := preload("res://scripts/core/arrival_timeline.gd")


func test_black_at_the_start_then_a_star() -> void:
	var s := T.state_at(0.0)
	assert_eq(s[&"black"], 1.0)
	assert_eq(s[&"star"], 0.0)
	assert_false(s[&"beam_on"])
	assert_gt(T.state_at(1.0)[&"star"], 0.9, "the star at its second 0.6 to 1.6")
	assert_eq(T.state_at(1.0)[&"black"], 1.0)


func test_the_black_opens_after_the_star_and_the_comet_falls_and_lands() -> void:
	assert_lt(T.state_at(2.0)[&"black"], 1.0)
	assert_eq(T.state_at(T.T_OPEN + T.OPEN_TIME)[&"black"], 0.0)
	assert_eq(T.state_at(T.T_OPEN - 0.01)[&"comet"], 0.0)
	assert_between(T.state_at(2.0)[&"comet"], 0.1, 0.9)
	assert_false(T.state_at(2.0)[&"impact"])
	assert_false(T.state_at(2.0)[&"beam_on"], "no light stays before it lands")
	assert_true(T.state_at(T.T_IMPACT)[&"impact"])
	assert_eq(T.state_at(T.T_IMPACT)[&"flash"], 1.0)
	assert_almost_eq(float(T.state_at(T.T_IMPACT + T.FLASH_TIME)[&"flash"]), 0.0, 0.001)
	assert_almost_eq(float(T.state_at(T.T_IMPACT + T.SHOCK_TIME)[&"shock"]), 1.0, 0.001)
	assert_eq(T.state_at(3.0)[&"beam"], 1.0)
	assert_eq(T.state_at(2.5)[&"star"], 0.0, "the star became the comet")
	assert_almost_eq(T.state_at(0.0)[&"dim"], T.DIM, 0.001)
	assert_lte(T.T_IMPACT, T.T_RING, "the seal opens on the landing")
	assert_lt(T.T_IMPACT, T.T_HERO)


func test_the_hero_is_unseen_before_3_6_and_seen_after() -> void:
	assert_false(T.state_at(3.59)[&"hero_visible"])
	assert_true(T.state_at(3.61)[&"hero_visible"])
	assert_eq(T.state_at(3.59)[&"hero_form"], 0.0)
	assert_almost_eq(T.state_at(4.0)[&"hero_form"], 1.0, 0.001)
	assert_gt(T.state_at(3.8)[&"hero_flash"], 0.9)
	assert_almost_eq(T.state_at(4.0)[&"hero_flash"], 0.0, 0.001)


func test_the_sparks_are_over_before_he_appears() -> void:
	assert_false(T.state_at(2.9)[&"motes_on"])
	assert_true(T.state_at(3.2)[&"motes_on"])
	for t in [3.55, 3.6, 3.8, 4.5]:
		assert_false(T.state_at(t)[&"motes_on"], "no sparks at %s" % t)
	assert_lt(T.T_MOTES + T.MOTES_TIME, T.T_HERO)


func test_control_from_4_0_and_the_caption_after() -> void:
	assert_false(T.state_at(3.99)[&"control"])
	assert_true(T.state_at(4.0)[&"control"])
	assert_false(T.state_at(4.1)[&"caption"])
	assert_true(T.state_at(4.2)[&"caption"])
	assert_true(T.T_CONTROL <= 4.0)


func test_everything_is_put_away_by_5_0() -> void:
	var s := T.state_at(5.0)
	assert_true(s[&"done"])
	assert_eq(s[&"beam"], 0.0)
	assert_eq(s[&"ring"], 0.0)
	assert_eq(s[&"black"], 0.0)
	assert_eq(s[&"dim"], 1.0)
	assert_almost_eq(s[&"crystal_glow"], T.CRYSTAL_LOW, 0.001, "the crystals stay lit low")
	assert_eq(s[&"crystals"], 1.0)


func test_the_crystals_and_the_ring_come_up_with_the_seal() -> void:
	assert_eq(T.state_at(2.3)[&"crystals"], 0.0)
	assert_gt(T.state_at(2.7)[&"crystals"], 0.0)
	assert_gt(T.state_at(2.7)[&"ring"], 0.0)
	assert_eq(T.state_at(3.0)[&"ring"], 1.0)


func test_skip_only_after_one_second() -> void:
	assert_eq(T.skip_to(0.5), 0.5)
	assert_eq(T.skip_to(0.99), 0.99)
	assert_eq(T.skip_to(1.0), T.T_CONTROL)
	assert_eq(T.skip_to(3.0), T.T_CONTROL)
	assert_eq(T.skip_to(4.5), 4.5, "once he can walk, nothing to skip")


func test_the_scene_skip_moves_its_clock() -> void:
	var s := ArrivalScene.new()
	add_child_autofree(s)
	s.skip()
	assert_eq(s.clock, 0.0, "not playing: nothing")
	s._playing = true
	s.clock = 0.5
	s.skip()
	assert_eq(s.clock, 0.5)
	assert_false(s.skipped)
	s.clock = 2.0
	s.skip()
	assert_eq(s.clock, T.T_CONTROL)
	assert_true(s.skipped)
	s._playing = false


func test_no_colour_of_the_scene_passes_the_screens_ceiling() -> void:
	for c: Color in [ArrivalScene.STAR_IVORY, ArrivalScene.STAR_EMERALD, ArrivalScene.RING_COLOR,
			ArrivalScene.RING_GLOW, ArrivalScene.MOTES_COLOR, Combat.EMETH]:
		assert_lte(ScreenTone.peak8(ScreenTone.fit(c)), ScreenTone.SCREEN_MAX, str(c))
	# the forming silhouette and the crystals are held under the ceiling by their peak
	var cap := ScreenTone.linear_peak(Color(1, 0.94, 0.82)) * ArrivalScene.FORM_CAP_SHARE
	assert_lte(cap, ScreenTone.linear_peak(Color(1, 0.94, 0.82)))
	assert_gt(ScreenTone.linear_peak(Combat.EMETH.lerp(Color.WHITE, 0.25), ArrivalScene.CRYSTAL_SCREEN), 0.0)


func test_the_hero_form_shader_loads_with_its_uniforms() -> void:
	var m := ShaderMaterial.new()
	m.shader = ArrivalScene.FORM_SHADER
	var names := PackedStringArray()
	for u in m.shader.get_shader_uniform_list():
		names.append(u.name)
	for want in ["albedo", "cut", "flash", "cap"]:
		assert_true(names.has(want), want)
