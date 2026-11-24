extends GutTest
## Lote 2 of the SWORN reference (2026-11-21): the HUD's new layout (the bars beside the medallion, the row centred, the
## build column on the right edge, the coins' corner, the Brado's buff, the low-life vignette, the keyword colours) and
## the two bugs of the gameplay-engineer's list (B1 the Forjador's sign, B2 the glyph 105 twice).

var game: Game


func _run(with_boons := 0) -> Hud:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_process_frames(2)
	return game.hud


# ---------- B2: no glyph id twice ----------

func test_no_glyph_id_is_used_twice() -> void:
	var ids := {}
	var consts: Dictionary = (BoonIcon as GDScript).get_script_constant_map()
	for k: String in consts:
		if k.ends_with("_GLYPH") and k not in ["ACTION_GLYPH", "ULT_GLYPH"]:
			assert_false(ids.has(consts[k]), "%s repeats the id of %s" % [k, ids.get(consts[k], "")])
			ids[consts[k]] = k
	# the bare actions (ACTION_GLYPH + Boon.Slot) and the ultimates (ULT_GLYPH + UltDef.Kind) take their own ranges
	for slot in Boon.Slot.values():
		var id: int = BoonIcon.ACTION_GLYPH + slot
		assert_false(ids.has(id), "action glyph %d is %s's too" % [id, ids.get(id, "")])
		ids[id] = "action %d" % slot
	for kind in UltDef.Kind.values():
		var id: int = BoonIcon.ULT_GLYPH + kind
		assert_false(ids.has(id), "ultimate glyph %d is %s's too" % [id, ids.get(id, "")])
		ids[id] = "ultimate %d" % kind
	assert_ne(BoonIcon.MAGICK_GLYPH, BoonIcon.SHOUT_GLYPH, "the gem is not the Brado")


# ---------- B1: the Forjador's sign ----------

func test_the_forja_is_closed_on_a_new_save_and_opens_with_the_first_guardian() -> void:
	# tools/title_flow_check.gd read the Forjador's sign on a new save, where the Forja stands closed with no sign (the
	# stations open one at a time, 2026-11-21): it now opens the Forja first (SCRIPT ERROR key_text on Nil)
	var data := SaveData.defaults()
	assert_false(HubGate.is_open(data, HubPlan.SMITH), "closed on a new save: no focus, no sign")
	SaveData.hero(data, SaveData.FIRST_HERO).firsts["guardian"] = 1
	assert_true(HubGate.is_open(data, HubPlan.SMITH), "open with the first guardian")


# ---------- the bars and the row ----------

func test_the_bars_the_row_and_the_column_do_not_overlap_or_leave_the_screen() -> void:
	var hud := await _run()
	for size in [Vector2i(1280, 720), Vector2i(1600, 720), Vector2i(1280, 800), Vector2i(1920, 1080)]:
		get_window().size = size
		await wait_process_frames(3)
		var view := hud.get_viewport_rect()
		var blocks := {
			"crest": hud._crest, "magick": hud._magick, "life": hud._life, "charge": hud._charge,
			"row": hud._action_row, "column": hud._column, "coins": hud._coins}
		for k: String in blocks:
			var r: Rect2 = (blocks[k] as Control).get_global_rect()
			assert_true(view.grow(0.5).encloses(r), "%s inside the screen at %s (%s in %s)" % [k, size, r, view])
		var names := blocks.keys()
		for i in names.size():
			for j in range(i + 1, names.size()):
				var a: Rect2 = (blocks[names[i]] as Control).get_global_rect()
				var b: Rect2 = (blocks[names[j]] as Control).get_global_rect()
				if names[i] in ["magick", "life", "charge"] and names[j] in ["magick", "life", "charge"]:
					continue
				assert_false(a.intersects(b), "%s and %s apart at %s" % [names[i], names[j], size])
		# the column leaves the middle three quarters of the width to the fight and stands on the right edge
		var col: Rect2 = hud._column.get_global_rect()
		assert_almost_eq(col.end.x, view.end.x, 1.0, "on the right edge")
		assert_lte(col.size.x, view.size.x * 0.06, "no wider than 6%% of the width at %s" % size)
	get_window().size = Vector2i(1280, 720)


# ---------- H1: the build column ----------

func test_the_column_shows_the_blessing_of_each_button_and_greys_the_empty_ones() -> void:
	var hud := await _run()
	var col: BuildColumn = hud._column
	assert_eq(col.entries.size(), 6, "left, right, Q, E, Shift, Space")
	game.boons.take(game.boons.find(&"golpe_brasa"))
	await wait_process_frames(2)
	assert_not_null(col.entries[0].icon.boon, "the left button holds its Blessing")
	assert_eq(col.entries[0].icon.level, 1)
	assert_eq(col.entries[0].level_label.text, T.t(&"hud_build_level", {"n": 1}))
	assert_null(col.entries[1].icon.boon, "the right button is empty")
	assert_eq(col.entries[1].icon.icon, BoonIcon.ACTION_GLYPH + Boon.Slot.SPECIAL)
	assert_eq(col.entries[2].icon.icon, BoonIcon.SHOUT_GLYPH, "Q shows the Brado's mark")
	assert_eq(col.entries[3].icon.icon, BoonIcon.RUSH_GLYPH, "E shows the Investida's")
	assert_eq(col.entries[5].icon.icon, BoonIcon.ACTION_GLYPH + Boon.Slot.DASH, "Space the dodge's")
	assert_lt(col.entries[1].icon.modulate.a, 1.0, "grey and quiet")
	assert_eq(col.entries[1].level_label.text, "")


func test_the_column_grows_a_row_for_an_elo_and_a_psalm_and_stays_inside_the_screen() -> void:
	var hud := await _run()
	var col: BuildColumn = hud._column
	var plain := col.size.y
	var psalms := Psalms.load_catalog()
	col.show_build(game.boons, -1, psalms[0])
	assert_gt(col.size.y, plain, "a row for the Psalm")
	assert_not_null(col.find_child("psalm", true, false))
	assert_lte(col.get_global_rect().end.y, hud.get_viewport_rect().end.y)
	col.veil(1.0)
	assert_lt(col.modulate.a, 1.0, "translucent with someone behind")


# ---------- H3: the coins ----------

func test_the_pickup_greets_and_adds_up_then_fades() -> void:
	var corner := CoinCorner.new().setup()
	add_child_autofree(corner)
	corner.pickup(MaterialPurse.SILVER, 10)
	assert_eq(corner.note_text(), "+10 %s" % T.t(&"material_silver_short"))
	corner.pickup(MaterialPurse.SILVER, 2)
	assert_eq(corner.note.amount, 12, "the same material adds up while it shows")
	corner.pickup(MaterialPurse.MEMORY, 1)
	assert_eq(corner.note.amount, 1, "another material starts again")
	corner.tick(CoinCorner.NOTE_TIME * 0.5)
	assert_gt(corner.note.modulate.a, 0.0)
	corner.tick(CoinCorner.NOTE_TIME)
	assert_eq(corner.note_text(), "")
	assert_eq(corner.note.modulate.a, 0.0, "gone")


func test_materials_show_only_once_carried() -> void:
	var corner := CoinCorner.new().setup()
	add_child_autofree(corner)
	corner.show_counts("Ouro: 5", 0, 0)
	assert_false(corner.find_child(String(MaterialPurse.SILVER), true, false).visible)
	corner.show_counts("Ouro: 5", 7, 0)
	assert_true(corner.find_child(String(MaterialPurse.SILVER), true, false).visible)
	assert_false(corner.find_child(String(MaterialPurse.MEMORY), true, false).visible)


func test_the_hud_greets_a_material_found_in_the_corner() -> void:
	var hud := await _run()
	game.materials.add(MaterialPurse.SILVER, &"door", 10)
	await wait_process_frames(2)
	assert_eq(hud._coins.note_text(), "+10 %s" % T.t(&"material_silver_short"))
	assert_true(hud._coins.get_global_rect().position.x > hud.get_viewport_rect().size.x * 0.6, "bottom right")


# ---------- H2: the rajada's price and the Brado's buff ----------

func test_the_rajada_shows_its_cost_and_says_without_magia() -> void:
	var hud := await _run()
	var special: ActionSlot = hud._slots[1]
	assert_eq(special.cost, 12, "the rajada's 12 Magia (weak start)")
	assert_eq(special.caption, "", "paid: no words")
	game.player.magick.value = 0.0
	await wait_process_frames(2)
	assert_eq(special.caption, T.t(&"hud_no_magick"))
	game.player.magick.value = game.player.magick.max_value
	await wait_process_frames(2)
	assert_eq(special.caption, "")


func test_the_buff_shows_while_the_brado_runs_beside_the_bars() -> void:
	var hud := await _run()
	assert_false(hud._buff.visible)
	game.player.gifts.rally(5.0, 0.2, 0.15, 0)
	await wait_process_frames(2)
	assert_true(hud._buff.visible)
	var bars: Rect2 = hud._life.get_global_rect()
	var b := hud._buff.get_global_rect()
	assert_gt(b.position.x, bars.end.x, "beside the bars")
	assert_almost_eq(b.get_center().y, bars.get_center().y, 2.0)
	assert_false(b.intersects(hud._ult_slot.get_global_rect()))


func test_the_buff_mark_has_an_emerald_dot_only_while_the_brado_absorbs() -> void:
	var hud := await _run()
	game.player.gifts.rally(5.0, 0.2, 0.15, 0)
	game.player.gifts.ward = 0
	await wait_process_frames(2)
	assert_false(hud._buff.absorbing, "no absorption left: no dot")
	game.player.gifts.ward = 2
	await wait_process_frames(2)
	assert_true(hud._buff.absorbing, "still absorbing: the emerald dot")


# ---------- H6: the vignette ----------

func test_the_vignette_stays_off_until_life_is_low() -> void:
	var hud := await _run()
	assert_eq(hud._vignette.danger, 0.0)
	game.player.hp = game.player.max_hp * 0.1
	await wait_process_frames(2)
	assert_gt(hud._vignette.danger, 0.5)
	assert_gt(hud._vignette.strength(), 0.0)
	assert_lte(hud._vignette.strength(), LifeVignette.MAX_ALPHA)
	assert_eq(hud._vignette.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	game.player.hp = game.player.max_hp
	await wait_process_frames(2)
	assert_eq(hud._vignette.danger, 0.0)


# ---------- H4: the keywords ----------

func test_every_term_has_a_colour_that_is_not_a_rarity() -> void:
	for id in Glossary.TERMS:
		assert_true(Glossary.COLORS.has(id), "%s has its colour" % id)
		for r: Color in Boon.RARITY_COLOR:
			assert_false((Glossary.COLORS[id] as Color).is_equal_approx(r), "%s is not a rarity's colour" % id)
		assert_ne(T.t("gloss_%s_text" % id), "gloss_%s_text" % id, "%s says what it does" % id)
	var text := Glossary.emphasize("O golpe congela e incendeia.")
	assert_true(text.contains((Glossary.COLORS[&"freeze"] as Color).to_html(false)))
	assert_true(text.contains((Glossary.COLORS[&"burn"] as Color).to_html(false)))


# ---------- AN-1: the angels' portraits ----------

func test_every_angel_with_a_picture_has_it_small_in_the_package() -> void:
	var angels := Encounter.load_catalog()
	assert_eq(angels.size(), 7)
	for a in angels:
		var tex := AngelArt.texture(a.id)
		assert_not_null(tex, "%s has its portrait" % a.id)
		assert_eq(tex.get_size(), Vector2(512, 768), "scaled down from the 1024 x 1536 source")
		var path := "%sangel_%d.jpg" % [AngelArt.DIR, AngelArt.NUMBER[a.id]]
		assert_lt(FileAccess.get_file_as_bytes(path).size(), 200 * 1024, "%s under 200 KB" % path)
		assert_true(Rect2(Vector2.ZERO, tex.get_size()).encloses(AngelArt.CROP), "the crop is inside the picture")
	var cfg := FileAccess.get_file_as_string("res://export_presets.cfg")
	assert_true(cfg.contains("docs/*"), "the 1024 x 1536 sources stay out of the package")


func test_the_choice_screen_shows_the_portrait_left_of_the_cards_inside_the_screen() -> void:
	var st := BoonState.new(BoonState.load_catalog())
	for a in Encounter.load_catalog():
		var choice := BoonChoice.new()
		add_child_autofree(choice)
		choice.open([st.find(&"toque_geada"), st.find(&"golpe_brasa"), st.find(&"onda_maior")] as Array[Boon], st)
		choice.by_angel(a, func() -> void: pass)
		await wait_process_frames(4)
		var art := choice.find_child("angel_art", true, false) as Control
		assert_not_null(art, "%s: the painting, not the seal" % a.id)
		assert_null(choice.find_child("angel_seal", true, false))
		var view := choice.get_viewport_rect()
		var col := choice.find_child("angel_column", true, false) as Control
		assert_true(view.encloses(col.get_global_rect()), "%s: the column inside the screen at 1280 x 720" % a.id)
		for c in choice.cards():
			assert_false(col.get_global_rect().intersects(c.get_global_rect()), "never over a card")
			assert_gte(c.get_global_rect().position.x, art.get_global_rect().end.x, "the cards right of the portrait")
