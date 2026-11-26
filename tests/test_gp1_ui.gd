extends GutTest
## GP-1, the Warrior V1's interface (docs/design/heroes/warrior_v1_2026-11-26.md 10): four groups in the HUD (left, right, Space,
## Shift) with the touch and the hold of each and their Magia, the held blow's ring, the refusal, the Ritmo's arc, no Q and E,
## the tips and the Blessing card's gesture. The Maga keeps her own Q and C diamonds.

var game: Game


func _run() -> Hud:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_process_frames(2)
	return game.hud


func test_the_warrior_has_four_groups_and_no_q_nor_e() -> void:
	var hud := await _run()
	var actions: Array[StringName] = []
	for s: ActionSlot in hud._slots:
		actions.append(s.action)
	assert_eq(actions, [&"light_attack", &"heavy_attack", &"dodge"] as Array[StringName], "left, right, Space (Shift is the ultimate's)")
	assert_not_null(hud._ult_slot)


func test_each_half_shows_its_name_and_its_magia() -> void:
	var hud := await _run()
	var left: ActionSlot = hud._slots[0]
	var right: ActionSlot = hud._slots[1]
	assert_eq(left.full_name(), "%s · %s" % [T.t(&"hud_slot_light_attack"), T.t(&"hud_hold_attack")])
	assert_eq(right.full_name(), "%s · %s" % [T.t(&"hud_slot_heavy_attack"), T.t(&"hud_hold_heavy_attack")])
	assert_eq(left.tap_cost, 0, "the combo is free")
	assert_eq(left.hold_cost, 12, "the Esmagador")
	assert_eq(right.tap_cost, 8, "the Corte Circular")
	assert_eq(right.hold_cost, 20, "the Lança da Emeth")
	assert_gte(left.custom_minimum_size.x, left.side + 12.0)


func test_a_half_dims_alone_when_the_magia_lacks() -> void:
	var hud := await _run()
	var right: ActionSlot = hud._slots[1]
	game.player.magick.value = 10.0
	await wait_process_frames(2)
	assert_false(right.tap_starved, "8 is there")
	assert_true(right.hold_starved, "20 is not")
	game.player.magick.value = 0.0
	await wait_process_frames(2)
	assert_true(right.tap_starved)
	game.player.magick.value = game.player.magick.max_value
	await wait_process_frames(2)
	assert_false(right.hold_starved)


func test_the_magia_bar_marks_the_costs() -> void:
	var hud := await _run()
	await wait_process_frames(2)
	var max_v := game.player.magick.max_value
	assert_eq(hud._magick.ticks.size(), 3, "the Corte Circular, the Esmagador, the Lança")
	assert_almost_eq(hud._magick.ticks[0], 8.0 / max_v, 0.001)
	assert_almost_eq(hud._magick.ticks[2], 20.0 / max_v, 0.001)


func test_a_refusal_flashes_the_pressed_frame_and_says_it() -> void:
	var hud := await _run()
	var right: ActionSlot = hud._slots[1]
	game.player.magick.value = 0.0
	Input.action_press(&"heavy_attack")
	hud._on_magick_refused()
	Input.action_release(&"heavy_attack")
	assert_gt(right._refused, 0.0)
	assert_eq(hud._notice.text, T.t(&"hud_no_magick"))


func test_the_rhythm_arc_follows_the_armed_rhythm() -> void:
	var hud := await _run()
	var right: ActionSlot = hud._slots[1]
	await wait_process_frames(2)
	assert_eq(right.rhythm, 0.0, "not armed")
	game.hero_gifts.rhythm.arm()
	await wait_process_frames(2)
	assert_gt(right.rhythm, 0.0)
	game.hero_gifts.rhythm.clear()


func test_no_hero_builds_a_brado_nor_an_investida_diamond() -> void:
	assert_true(Hud.RETIRED.has(&"shout") and Hud.RETIRED.has(&"rush"), "GP-5: the Maga lost Q and C too")


func test_the_how_to_page_has_no_brado_nor_investida_rows() -> void:
	for row in HowToScreen.ROWS:
		assert_false(row["id"] in ["shout", "rush"], "the Warrior has no %s" % row["id"])
	for id in ["light_attack", "heavy_attack", "ultimate", "dodge", "interact"]:
		assert_ne(T.t("howto_" + id), "howto_" + id)
		assert_ne(T.t("howto_%s_desc" % id), "howto_%s_desc" % id)
	for key in [&"howto_rhythm", &"howto_rhythm_desc", &"tip_rhythm", &"tip_controls_v1", &"tip_hold"]:
		assert_ne(T.t(key), String(key))


func test_the_controls_tip_comes_once_to_a_save_that_already_descended() -> void:
	var old := {"runs": 3, "hub": {"tips": []}}
	assert_eq(FirstTips.pick(old, {"fighting": false}), &"controls_v1")
	FirstTips.mark(old, &"controls_v1")
	assert_ne(FirstTips.pick(old, {"fighting": false}), &"controls_v1", "once")
	assert_ne(FirstTips.pick({"runs": 0, "hub": {"tips": []}}, {"fighting": false}), &"controls_v1", "a new save has the Antessala")
	assert_eq(FirstTips.pick({"runs": 0, "hub": {"tips": []}}, {"fighting": true, "rhythm": true}), &"rhythm")
	for id in [&"rhythm", &"controls_v1"]:
		var s := TipToast.text_of(id)
		assert_false(s.begins_with("tip_") or s.contains("{") or s.contains("—") or s.contains("–"), String(id))


func test_the_card_says_how_the_button_is_worked() -> void:
	assert_eq(Boon.gesture_key(Boon.Slot.ATTACK), &"tap_hold_hint")
	assert_eq(Boon.gesture_key(Boon.Slot.CAST), &"tap_hint")
	assert_eq(Boon.gesture_key(Boon.Slot.SPECIAL), &"hold_hint")
	assert_eq(Boon.gesture_key(Boon.Slot.DASH), &"")
	var state := BoonState.new(BoonState.load_catalog())
	var checked := 0
	for b in state.catalog:
		if b.slot == Boon.Slot.NONE or b.is_duo():
			continue
		var card := BoonCard.new()
		var row: Control = card.call(&"_meta", b, 1)
		assert_eq(row.find_child("Gesture", true, false) != null, Boon.gesture_key(b.slot) != &"", String(b.id))
		row.free()
		card.free()
		checked += 1
		if checked >= 6:
			break
	assert_gt(checked, 0)
