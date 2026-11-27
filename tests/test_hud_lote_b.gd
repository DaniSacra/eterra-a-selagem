extends GutTest
## Lote B of the 2026-11-24 round: the fight HUD (one source per fact, life over Magia, the ready ultimate that stays
## lit).

var game: Game


func _run() -> Hud:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_process_frames(2)
	return game.hud


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


func test_the_three_bars_stack_gold_blue_red_and_are_alike() -> void:
	var hud := await _run()
	# 2026-11-27 night: the held blows pay Magia again, so the Warrior's blue bar is back between the two
	assert_lt(hud._charge.get_global_rect().position.y, hud._magick.get_global_rect().position.y)
	assert_lt(hud._magick.get_global_rect().position.y, hud._life.get_global_rect().position.y)
	assert_true(hud._magick.visible, "the Magia bar for the Warrior")
	assert_eq(hud._magick.size, hud._life.size, "HUD v3: the Magia is no longer thin")


func test_a_ready_ultimate_keeps_its_ring() -> void:
	var hud := await _run()
	hud._ult_slot.wait = 0.0
	hud._ult_slot.pulse = true
	assert_true(hud._ult_slot.ready_ring())
	await wait_process_frames(2)
