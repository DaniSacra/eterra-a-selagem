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


func test_the_warrior_has_four_blows_the_dodge_and_the_supremo_and_no_q_nor_e() -> void:
	var hud := await _run()
	var seen: Array[String] = []
	for s: ActionSlot in hud._slots:
		seen.append("%s:%s" % [s.action, s.hold])
	assert_eq(seen, ["light_attack:false", "light_attack:true", "heavy_attack:false", "heavy_attack:true", "dodge:false"],
			"touch and hold of each button, then Space (Shift is the Supremo's round slot)")
	assert_not_null(hud._ult_slot)
	assert_eq(hud._ult_slot.shape, ActionSlot.Shape.ROUND)


func test_each_blow_shows_its_own_magia() -> void:
	var hud := await _run()
	var costs: Array[int] = []
	for i in 4:
		costs.append((hud._slots[i] as ActionSlot).cost)
	assert_eq(costs, [0, 12, 8, 20] as Array[int], "the combo is free, the Esmagador, the Corte Circular, the Lança")


func test_a_slot_dims_alone_when_its_magia_lacks() -> void:
	var hud := await _run()
	var power: ActionSlot = hud._slots[2]
	var lance: ActionSlot = hud._slots[3]
	game.player.magick.value = 10.0
	await wait_process_frames(2)
	assert_false(power.starved, "8 is there")
	assert_true(lance.starved, "20 is not")
	game.player.magick.value = 0.0
	await wait_process_frames(2)
	assert_true(power.starved)
	game.player.magick.value = game.player.magick.max_value
	await wait_process_frames(2)
	assert_false(lance.starved)


func test_the_magia_bar_marks_the_costs() -> void:
	var hud := await _run()
	await wait_process_frames(2)
	var max_v := game.player.magick.max_value
	assert_eq(hud._magick.bar.ticks.size(), 3, "the Corte Circular, the Esmagador, the Lança")
	assert_almost_eq(hud._magick.bar.ticks[0], 8.0 / max_v, 0.001)
	assert_almost_eq(hud._magick.bar.ticks[2], 20.0 / max_v, 0.001)


func test_a_refusal_flashes_the_pressed_frame_and_says_it() -> void:
	var hud := await _run()
	var right: ActionSlot = hud._slots[2]
	game.player.magick.value = 0.0
	await wait_process_frames(2)
	Input.action_press(&"heavy_attack")
	hud._on_magick_refused()
	Input.action_release(&"heavy_attack")
	assert_gt(right._refused, 0.0)
	assert_eq(hud._notice.text, T.t(&"hud_no_magick"))


func test_the_rhythm_arc_follows_the_armed_rhythm() -> void:
	var hud := await _run()
	var right: ActionSlot = hud._slots[3]
	await wait_process_frames(2)
	assert_eq(right.rhythm, 0.0, "not armed")
	assert_eq(hud._rhythm.share, 0.0)
	game.hero_gifts.rhythm.arm()
	await wait_process_frames(2)
	assert_gt(right.rhythm, 0.0)
	assert_gt(hud._rhythm.share, 0.0, "the Ritmo's gold line fills while it is armed")
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
