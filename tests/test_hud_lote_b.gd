extends GutTest
## Lote B of the 2026-11-24 round: the fight HUD (one source per fact, life over Magia, the ready ultimate that stays
## lit, the Brado's word with its limits).

var game: Game


func _run() -> Hud:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_process_frames(2)
	return game.hud


func test_the_brado_word_is_told_twice_a_room_and_only_in_the_first_descents() -> void:
	var data := {"runs": 0}
	assert_true(FirstTips.shout_due(data, 0, true))
	assert_true(FirstTips.shout_due(data, FirstTips.SHOUT_PER_ROOM - 1, true))
	assert_false(FirstTips.shout_due(data, FirstTips.SHOUT_PER_ROOM, true), "the room's limit")
	assert_false(FirstTips.shout_due(data, 0, false), "only when it is worth it")
	assert_false(FirstTips.shout_due({"runs": FirstTips.SHOUT_RUNS}, 0, true), "the save's limit")
	assert_true(FirstTips.shout_due({"runs": FirstTips.SHOUT_RUNS - 1}, 0, true))


func test_the_ready_ultimate_is_urgent_only_full_and_hurt() -> void:
	assert_true(Hud.ult_urgent(true, 0.3))
	assert_false(Hud.ult_urgent(true, 0.9), "full but healthy")
	assert_false(Hud.ult_urgent(false, 0.1), "hurt but not full")
	assert_false(Hud.ult_urgent(true, Hud.ULT_HURT), "the edge is not hurt")


func test_the_column_shows_only_the_blessings_gained() -> void:
	var hud := await _run()
	hud._column.show_build(game.boons)
	assert_false(hud._column.has_content(), "nothing gained: no column")
	var st := game.boons
	st.take(st.find(&"passo_radiante"), Boon.Rarity.COMMON)
	hud._column.show_build(st)
	assert_true(hud._column.has_content())
	var shown := hud._column.entries.filter(func(e: BuildColumn.Entry) -> bool: return e.visible)
	assert_eq(shown.size(), 1, "one Blessing, one row; the actions stay in the bottom row")
	assert_lt(BuildColumn.height_for(0, 1), BuildColumn.height_for(0))


func test_life_stands_over_the_magia_and_both_have_a_mark() -> void:
	var hud := await _run()
	assert_lt(hud._life.get_global_rect().position.y, hud._magick.get_global_rect().position.y)
	assert_eq(hud._life.icon, HudBar.Mark.HEART)
	assert_eq(hud._magick.icon, HudBar.Mark.DROP)


func test_a_ready_ultimate_keeps_its_ring_and_the_robot_hears_no_brado_word() -> void:
	var hud := await _run()
	hud._ult_slot.wait = 0.0
	hud._ult_slot.pulse = true
	assert_true(hud._ult_slot.ready_ring())
	await wait_process_frames(2)
	assert_eq(hud._shout_tip_t, 0.0, "no word for the robot, a smoke run or --nosave")
