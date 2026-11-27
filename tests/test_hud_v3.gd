extends GutTest
## HUD v3 (2026-11-27, Daniel's new reference): the layout of the run's HUD stays inside the safe area at three window sizes, the
## values bind to the game, the names of the Blessing column show when gained, hovered or in the pause, and every piece of the painted
## kit has a drawn stand-in.

var game: Game


func _run() -> Hud:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_process_frames(2)
	return game.hud


func test_every_block_stands_inside_the_safe_area_at_three_sizes() -> void:
	var hud := await _run()
	for size in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)]:
		get_window().size = size
		await wait_process_frames(3)
		var safe := hud.get_viewport_rect().grow(-6.0)
		var blocks := {"head": hud._head, "cartouche": hud._cartouche, "crest": hud._crest, "life": hud._life, "magick": hud._magick,
			"charge": hud._charge, "rhythm": hud._rhythm, "row": hud._action_row, "column": hud._column, "coins": hud._coins}
		for k: String in blocks:
			var r: Rect2 = (blocks[k] as Control).get_global_rect()
			assert_true(safe.encloses(r), "%s inside the safe area at %s (%s in %s)" % [k, size, r, safe])
		assert_almost_eq(hud._action_row.get_global_rect().get_center().x, hud.get_viewport_rect().size.x * 0.5, 2.0, "the row centred at %s" % size)
		assert_lt(hud._head.get_global_rect().end.x, hud._cartouche.get_global_rect().position.x, "the room's header clear of the clock at %s" % size)
		assert_lt(hud._crest.get_global_rect().end.x, hud._action_row.get_global_rect().position.x, "the portrait clear of the row at %s" % size)
		assert_lt(hud._action_row.get_global_rect().end.x, hud._column.get_global_rect().position.x, "the row clear of the column at %s" % size)
	get_window().size = Vector2i(1280, 720)


func test_the_values_bind_to_the_game() -> void:
	var hud := await _run()
	var p := game.player
	p.hp = 32.0
	p.max_hp = 40.0
	p.magick.value = 22.0
	await wait_process_frames(2)
	assert_eq(hud._life.bar._text, "32/40")
	assert_almost_eq(hud._life.bar._ratio, 0.8, 0.001)
	assert_eq(hud._magick.bar._text, "%d/%d" % [22, roundi(p.magick.max_value)])
	assert_eq(hud._clock.text, SaveData.format_time(game.time))
	assert_eq(hud._rhythm._text, T.t(&"hud_rhythm"))
	assert_ne(hud._room.text, "", "the room's count")


func test_the_supremo_bar_says_its_charge_in_percent() -> void:
	var hud := await _run()
	hud._charge.show_value(0.65, "65%")
	assert_eq(hud._charge.bar._text, "65%")
	assert_almost_eq(hud._charge.bar._ratio, 0.65, 0.001)


func test_the_row_is_four_blows_the_supremo_a_divider_and_the_dodge_all_squares_of_one_size() -> void:
	var hud := await _run()
	var kinds: Array[String] = []
	var sides := {}
	for c in hud._action_row.get_children():
		kinds.append("divider" if c is HudDivider else "square" if (c as ActionSlot).shape == ActionSlot.Shape.SQUARE else "other")
		if c is ActionSlot:
			sides[(c as ActionSlot).side] = true
	assert_eq(kinds, ["square", "square", "square", "square", "square", "divider", "square"] as Array[String])
	assert_eq(sides.size(), 1, "the six slots are one size")
	assert_eq(hud._action_row.get_child(4), hud._ult_slot, "the Supremo is the fifth slot, before the divider")
	assert_eq(hud._action_row.get_child(6), hud._slots.back(), "the dodge is last")
	var pieces: Array[StringName] = []
	var holds: Array[bool] = []
	for s: ActionSlot in hud._slots:
		pieces.append(s.piece)
		holds.append(s.hold)
	assert_eq(pieces, [&"icon_attack", &"icon_power", &"icon_smash", &"icon_lance", &"icon_dodge"] as Array[StringName])
	assert_eq(holds, [false, false, true, true, false] as Array[bool], "tap, tap, hold, hold")
	assert_eq([hud._slots[0].action, hud._slots[1].action, hud._slots[2].action, hud._slots[3].action],
		[&"light_attack", &"heavy_attack", &"light_attack", &"heavy_attack"], "left, right, left, right")


func test_the_mouse_is_white_for_a_click_and_gold_for_a_hold() -> void:
	var tap := MouseGlyphArt.rasterize(MOUSE_BUTTON_LEFT, MouseGlyphArt.Style.TAP)
	var hold := MouseGlyphArt.rasterize(MOUSE_BUTTON_LEFT, MouseGlyphArt.Style.HOLD)
	var plain := MouseGlyphArt.rasterize(MOUSE_BUTTON_LEFT)
	var lit := Vector2i(int(MouseGlyphArt.W * 0.3 * MouseGlyphArt.SCALE), int(MouseGlyphArt.H * 0.2 * MouseGlyphArt.SCALE))
	assert_gt(tap.get_pixelv(lit).b, 0.85, "tap: the button is white")
	assert_lt(hold.get_pixelv(lit).b, 0.4, "hold: the button is gold")
	assert_lt(plain.get_pixelv(lit).b, 0.4, "the cards' mouse keeps the gold")
	var right := MouseGlyphArt.rasterize(MOUSE_BUTTON_RIGHT, MouseGlyphArt.Style.TAP)
	assert_lt(right.get_pixelv(lit).b, 0.2, "the right button is dark when the left is lit")


func test_a_gained_blessing_shows_its_name_for_a_while_then_hides_it() -> void:
	var hud := await _run()
	var col: BuildColumn = hud._column
	col.show_build(game.boons)  # the build the run began with is not "gained"
	var st := game.boons
	st.take(st.find(&"passo_radiante"), Boon.Rarity.COMMON)
	col.show_build(st)
	col.visible = true
	col.tick(game.skills)
	assert_eq(col.names_shown().size(), 1, "just gained: its name beside the medallion")
	col._name_t[&"passo_radiante"] = 0.0
	col.tick(game.skills)
	assert_eq(col.names_shown().size(), 0, "icons only afterwards")
	col.names_all = true
	col.tick(game.skills)
	assert_eq(col.names_shown().size(), 1, "the pause lists the names")


func test_the_name_shows_only_while_the_mouse_is_over_a_medallion() -> void:
	var hud := await _run()
	var col: BuildColumn = hud._column
	col.show_build(game.boons)
	game.boons.take(game.boons.find(&"passo_radiante"), Boon.Rarity.COMMON)
	col.show_build(game.boons)
	col._name_t.clear()
	col.visible = true
	var e: BuildColumn.Entry = col._all_entries()[0]
	assert_gt(e.hit_rect().get_area(), 0.0)
	col.tick(game.skills)
	assert_eq(e.name_box.visible, e.hit_rect().has_point(col.get_global_mouse_position()))


func test_the_kit_is_complete_and_the_hud_builds_without_any_of_it() -> void:
	for piece in HudArt.NAMES:
		assert_true(ResourceLoader.exists(HudArt.DIR + String(piece) + ".png"), "the kit has %s" % piece)
	for piece in HudArt.NAMES:
		HudArt._cache[piece] = null  # as if no file were there: the drawn stand-ins
	var hud := await _run()
	await wait_process_frames(2)
	assert_not_null(hud._life)
	HudArt.reload()


func test_the_costs_come_from_the_player() -> void:
	var hud := await _run()
	await wait_process_frames(2)
	var p := game.player
	var l: Array = Player.INTENT_MOVES[&"light_attack"]
	var h: Array = Player.INTENT_MOVES[&"heavy_attack"]
	var moves: Array = [l[0], h[0], l[1], h[1]]  # left tap, right tap, left hold, right hold
	for i in 4:
		assert_eq((hud._slots[i] as ActionSlot).cost, hud._cost_of(p, moves[i]), "slot %d" % i)
