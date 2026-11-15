extends GutTest
## Cycle 9 C: the curse on the paladin (aura, Emeth, HUD), the boss's phase marks and caption, the victory screen and
## the damage numbers of a swing through a pack.

const PALE := Color(0.94, 0.9, 0.82)
const EMERALD := Color(0.08, 0.85, 0.27)


# ---------- numbers ----------

func test_past_group_from_a_frames_plain_hits_join_one_total() -> void:
	var t := NumberTally.new(40)
	var total := 0.0
	for i in NumberTally.GROUP_FROM + 5:
		t.add(i + 1, Vector3(i * 10.0, 0, 0), 10.0, PALE, false, 50)
		total += 10.0
	var groups := 0
	var shown := 0
	for e in t.entries:
		if e.shown and e.amount >= 0.0:
			shown += 1
			if e.group:
				groups += 1
				assert_eq(e.amount, total, "the total sums every plain hit of the frame")
	assert_eq(groups, 1)
	assert_eq(shown, 1, "the frame's own numbers went into the total")


func test_up_to_group_from_hits_keep_their_own_numbers() -> void:
	var t := NumberTally.new(40)
	for i in NumberTally.GROUP_FROM:
		t.add(i + 1, Vector3(i * 10.0, 0, 0), 10.0, PALE, false, 50)
	assert_eq(t.shown_count(), NumberTally.GROUP_FROM)
	for e in t.entries:
		assert_false(e.group)


func test_a_new_frame_counts_again_and_the_total_keeps_counting_briefly() -> void:
	var t := NumberTally.new(40)
	for i in NumberTally.GROUP_FROM + 1:
		t.add(i + 1, Vector3(i * 10.0, 0, 0), 10.0, PALE, false, 1)
	var g := -1
	for i in t.entries.size():
		if t.entries[i].shown and t.entries[i].group:
			g = i
	assert_gt(g, -1)
	# the next frame of the same swing: the first GROUP_FROM show alone, the overflow joins the same total
	for i in NumberTally.GROUP_FROM + 2:
		t.add(100 + i, Vector3(i * 10.0, 0, 50.0), 10.0, PALE, false, 2)
	assert_eq(t.entries[g].amount, 10.0 * (NumberTally.GROUP_FROM + 3))


func test_finishers_are_never_summed() -> void:
	var t := NumberTally.new(40)
	for i in NumberTally.GROUP_FROM + 3:
		t.add(i + 1, Vector3(i * 10.0, 0, 0), 10.0, PALE, false, 9)
	var i := t.add(500, Vector3.ZERO, 60.0, EMERALD, true, 9)
	assert_gt(i, -1)
	assert_true(t.entries[i].big)
	assert_false(t.entries[i].group)
	assert_eq(t.entries[i].amount, 60.0)


func test_without_a_frame_nothing_is_summed() -> void:
	var t := NumberTally.new(40)
	for i in NumberTally.GROUP_FROM + 3:
		t.add(i + 1, Vector3(i * 10.0, 0, 0), 10.0, PALE, false)
	for e in t.entries:
		assert_false(e.group)


func test_numbers_keep_clear_of_the_paladins_head() -> void:
	var head := Vector2(640, 300)
	var near := NumberTally.clear_of(Vector2(650, 290), head, NumberTally.HERO_CLEAR)
	assert_almost_eq(near.distance_to(head), NumberTally.HERO_CLEAR, 0.01)
	assert_gt(near.x, head.x, "pushed straight away from the head")
	var on := NumberTally.clear_of(head, head, NumberTally.HERO_CLEAR)
	assert_almost_eq(on, head + Vector2.UP * NumberTally.HERO_CLEAR, Vector2.ONE * 0.01, "right on it: straight up")
	var far := Vector2(900, 100)
	assert_eq(NumberTally.clear_of(far, head, NumberTally.HERO_CLEAR), far, "a number away from him stays")


# ---------- the curse ----------

func test_curse_runes_stay_between_waist_and_chest_around_him() -> void:
	for i in CurseAura.RUNES:
		for t: float in [0.0, 0.37, 1.9, 5.2]:
			var p := CurseAura.rune_at(i, CurseAura.RUNES, t)
			assert_almost_eq(Vector2(p.x, p.z).length(), CurseAura.ORBIT, 0.001)
			assert_between(p.y, CurseAura.HEIGHT.x, CurseAura.HEIGHT.y)
			assert_lt(p.y, HeroBody.HEIGHT * 0.6, "never in front of his face")


func test_curse_aura_eases_in_and_out() -> void:
	var a := CurseAura.new()
	add_child_autofree(a)
	a.on = true
	a._process(CurseAura.RISE * 0.5)
	assert_between(a.power, 0.4, 0.6)
	a._process(CurseAura.RISE)
	assert_eq(a.power, 1.0)
	assert_true(a.visible)
	a.on = false
	a._process(CurseAura.FADE * 2.0)
	assert_eq(a.power, 0.0)
	assert_false(a.visible)


func test_emeth_corruption_is_a_share() -> void:
	var m := ShaderMaterial.new()
	m.shader = EmethSword.SHADER
	EmethSword.set_corrupt(m, 2.0)
	assert_eq(m.get_shader_parameter(&"corrupt"), 1.0)
	EmethSword.set_corrupt(m, 0.0)
	assert_eq(m.get_shader_parameter(&"corrupt"), 0.0)


func test_badge_shows_while_cursed_and_fades_after() -> void:
	var b := ConditionBadge.new().setup(CurseAura.COLOR, "a", "b")
	add_child_autofree(b)
	assert_eq(b.shown(), 0.0)
	b.ratio = 1.0
	b._process(ConditionBadge.POP)
	assert_eq(b.shown(), 1.0)
	b.ratio = 0.0
	b._process(ConditionBadge.FADE)
	assert_eq(b.shown(), 0.0)


func test_locked_special_rings_once_when_the_lock_lifts() -> void:
	var s := ActionSlot.new().setup(&"heavy_attack", Boon.Slot.SPECIAL)
	add_child_autofree(s)
	s.locked = 0.6
	assert_eq(s._release, 0.0)
	s.locked = 0.3
	assert_eq(s._release, 0.0, "no ring while it still runs")
	s.locked = 0.0
	assert_eq(s._release, 1.0, "the ring when it lifts")
	s._process(ActionSlot.RELEASE)
	assert_eq(s._release, 0.0)


# ---------- the boss's bar ----------

func test_boss_marks_light_as_his_life_passes_them_and_flash_once() -> void:
	var b := HudBar.new().setup(Color.PURPLE, Vector2(400, 12), 11, true)
	add_child_autofree(b)
	var marks := PackedFloat32Array([0.66, 0.33, 0.15])
	b.show_value(0.9)
	b.show_boss(marks, 0.0)
	b._process(0.01)
	assert_eq(b.reached(), 0)
	b.show_value(0.6)
	b._process(0.01)
	assert_eq(b.reached(), 1)
	assert_gt(b._mark_flash, 0.9, "the mark just reached flashes")
	b._process(HudBar.MARK_FLASH)
	assert_eq(b._mark_flash, 0.0)


func test_a_fight_joined_late_does_not_flash() -> void:
	var b := HudBar.new().setup(Color.PURPLE, Vector2(400, 12), 11, true)
	add_child_autofree(b)
	b.show_value(0.3)
	b.show_boss(PackedFloat32Array([0.66, 0.33, 0.15]), 0.0)
	b._process(0.01)
	assert_eq(b.reached(), 2)
	assert_eq(b._mark_flash, 0.0)


func test_phase_text_splits_into_name_and_hint() -> void:
	assert_eq(Hud.phase_parts("O Ritual dos Mortos. Derrube os mortos!"), PackedStringArray(["O Ritual dos Mortos", "Derrube os mortos!"]))
	assert_eq(Hud.phase_parts("O Despertar"), PackedStringArray(["O Despertar", ""]))
	for n in 4:
		var parts := Hud.phase_parts(T.t("boss_phase_%d" % (n + 1)))
		assert_ne(parts[0], "")
		assert_false(parts[0].contains("."), "the name is one short line")


# ---------- the victory ----------

func test_victory_screen_focuses_continue_and_both_ways_out_work() -> void:
	var end := EndScreen.new()
	add_child_autofree(end)
	end.open(true, {"time": 300.0, "level": 1, "kills": 120, "best_combo": 14, "boons": 5}, false)
	await wait_process_frames(2)
	var buttons := end.find_children("*", "Button", true, false)
	assert_eq(buttons.size(), 2)
	var first := buttons[0] as Button
	assert_eq(first.text, T.t(&"end_continue"))
	assert_true(first.has_focus(), "keys and gamepad start on Continuar")
	watch_signals(end)
	first.pressed.emit()
	assert_signal_emitted(end, "menu")
	(buttons[1] as Button).pressed.emit()
	assert_signal_emitted(end, "retry")


func test_texts_have_no_dash() -> void:
	for key: StringName in [&"end_victory", &"end_victory_sub", &"end_spoils", &"end_continue", &"end_again", &"hud_cursed", &"hud_cursed_effects"]:
		var text := T.t(key)
		assert_ne(text, String(key), "%s is in the table" % key)
		assert_false(text.contains("—") or text.contains("–"), "%s has no dash" % key)
