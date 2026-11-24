extends GutTest
## The UI layout review of d2ff05d (docs/gallery/ui_review_d2ff05d/REVIEW.md): the HUD's numbers never in Cinzel
## (P0-1), the clock and the hit count on a veil and the clock out of a boss's way (P1-2), gold summing like damage
## (P1-3), the book's own buttons, bookmarks and scroll bars (P1-4, P1-5, P1-6, P1-12), signs that keep out of a
## greeting (P1-1), the stations' verbs (P1-9), both endings alike (P1-10) and one control for every setting (P1-11).

var game: Game


func after_each() -> void:
	Dev.put("seed", "1")  # back to the seed of every test, never none (tests/hooks/pre_run.gd, BUG-109)
	Dev._args.erase("boons")
	DoorSign.keep_out = Rect2()


func _run() -> void:
	Dev._args["seed"] = "5"
	Dev._args["boons"] = "0"
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.horde.clear_crowd()
	await wait_process_frames(4)


func _data(xp: int) -> Dictionary:
	var d := SaveData.defaults()
	SaveData.hero(d, "warrior").mastery_xp = xp
	return d


# ---------- P0-1, P1-2, P1-3: the HUD ----------

## Every label of the HUD showing a digit is in lining figures, never in Cinzel (whose 1 reads as a Roman I).
func test_no_hud_number_is_in_cinzel() -> void:
	await _run()
	var hud := game.hud
	hud.on_combo(11)
	hud.show_notice(T.t(&"hud_ult_locked_tip", {"n": 2}))
	await wait_process_frames(2)
	var cinzel: Array[String] = []
	var seen := 0
	for n in hud.find_children("*", "Label", true, false):
		var l := n as Label
		if not UiKit.has_digit(l.text):
			continue
		seen += 1
		if l.get_theme_font(&"font") == UiKit.TITLE_FONT:
			cinzel.append(l.text)
	assert_gte(seen, 4, "room, clock, gold and the hit count have digits")
	assert_eq(cinzel, [] as Array[String], "numbers set in Cinzel")


func test_the_clock_and_the_hit_count_stand_on_a_veil() -> void:
	await _run()
	var hud := game.hud
	hud.on_combo(5)
	await wait_process_frames(2)
	var clock := HudVeil.text_rect(hud._clock)
	assert_true(hud._clock_veil.visible)
	assert_true(hud._clock_veil.get_global_rect().encloses(clock), "the clock's veil holds its text")
	# the hit count left the field for the bars (UI-HB5, no background): it reads by its dark outline
	assert_gte(hud._combo.get_theme_constant(&"outline_size"), 4, "the count's own outline")
	assert_true(hud._combo_row.visible)
	hud.on_combo(0)
	hud._move_t = 0.0
	await wait_process_frames(2)
	assert_false(hud._combo.visible, "no count, nothing shown")


func test_with_a_boss_bar_the_clock_goes_to_the_corner() -> void:
	await _run()
	var hud := game.hud
	var top_middle := hud._clock.get_global_rect().get_center()
	hud._boss_box.visible = true
	hud._place_clock(true)
	var view := hud.get_viewport_rect().size
	var clock := hud._clock.get_global_rect()
	assert_gt(clock.get_center().x, view.x * 0.8, "the clock on the right")
	assert_lt(clock.position.y, 20.0, "in the top corner (the gold lives at the bottom right now)")
	assert_lt(hud._boss_box.get_global_rect().position.y, top_middle.y, "the boss's name alone at the top")
	assert_false(hud._boss_box.get_global_rect().intersects(clock), "nothing stacked")
	hud._place_clock(false)
	assert_almost_eq(hud._clock.get_global_rect().get_center().x, view.x * 0.5, 1.0)


func test_gold_sums_like_the_damage() -> void:
	await _run()
	var at := Vector3(game.player.pos.x, 2.4, game.player.pos.y)
	for i in 3:
		game.fx.gold(at + Vector3(i * 0.5, 0, 0), 1)
	assert_eq(game.fx.gold_shown(), 3, "three drops, one \"+3 ouro\"")
	var shown := 0
	for l in game.fx._labels:
		if l.visible and l.text.ends_with(T.t(&"hud_gold_short")):
			shown += 1
			assert_eq(l.text, "+3 %s" % T.t(&"hud_gold_short"))
			assert_lt(l.get_theme_font_size(&"font_size"), Fx.NUMBER_SIZE, "smaller than a damage number")
	assert_eq(shown, 1, "one word")


# ---------- P1-1: greetings and signs ----------

func test_a_sign_steps_under_a_greeting() -> void:
	var cam := Camera3D.new()
	add_child_autofree(cam)
	cam.position = Vector3(0, 10, 10)
	cam.look_at(Vector3.ZERO)
	cam.make_current()
	var sign := DoorSign.make(T.t(&"reward_boon"), T.t(&"door_hard"))
	add_child_autofree(sign)
	await wait_process_frames(2)
	var plate := sign._box
	var r := Rect2(plate.position, plate.size)
	DoorSign.keep_out = r.grow(4.0)
	sign._process(0.0)
	assert_gte(plate.position.y, DoorSign.keep_out.end.y, "under the greeting's band")


func test_the_greeting_marks_its_band_while_it_shows() -> void:
	var banner := EloBanner.new()
	add_child_autofree(banner)
	banner.size = Vector2(420, 100)
	banner.show_boon(BoonState.load_catalog()[0])
	banner._process(0.5)
	assert_true(DoorSign.keep_out.has_area(), "the band is kept")
	banner._process(EloBanner.TIME)
	assert_false(DoorSign.keep_out.has_area(), "and let go when it ends")


# ---------- P1-4, P1-5, P1-6, P1-12: the book ----------

func test_paper_buttons_are_ink_on_paper() -> void:
	var b := Book.button("Voltar")
	autofree(b)
	var normal := b.get_theme_stylebox(&"normal") as StyleBoxFlat
	assert_lt(normal.bg_color.a, 0.5, "the paper shows through, never a dark block")
	assert_eq(normal.border_color, Book.GILT)
	assert_eq(b.get_theme_color(&"font_color"), Book.INK)
	var main := Book.primary(Book.button("Descer"))
	autofree(main)
	assert_eq(main.get_theme_color(&"font_color"), Book.RUBRIC)


func test_the_portal_leaf_has_paper_buttons() -> void:
	var p := HubPanel.new()
	add_child_autofree(p)
	p.open("T", "L", [[&"go", "Descer"], [&"stay", "Ficar"]])
	for b in p.buttons:
		assert_eq((b.get_theme_stylebox(&"normal") as StyleBoxFlat).border_color, Book.GILT, b.name)


func test_the_book_in_the_hub_has_no_way_down() -> void:
	var title := HeroScreen.new()
	add_child_autofree(title)
	title.open(_data(500), HeroScreen.Chapter.OPENING)
	assert_not_null(title.find_child("descend", true, false), "the title's book goes down")
	var hub := HeroScreen.new()
	add_child_autofree(hub)
	hub.open(_data(500), HeroScreen.Chapter.OPENING, true)
	await wait_process_frames(2)
	assert_null(hub.find_child("descend", true, false), "only the Portal goes down")
	assert_null(hub.find_child("descend_hero", true, false))
	assert_not_null(get_viewport().gui_get_focus_owner(), "something holds the focus")
	hub._show(HeroScreen.Chapter.HERO)
	var foot := hub.find_child("foot", true, false) as HBoxContainer
	for id in ["to_gifts", "codex"]:
		assert_eq((foot.find_child(id, false, false) as Button).get_parent(), foot, "%s in the one row" % id)


func test_the_chapters_are_ribbons_of_the_book() -> void:
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(_data(500))
	await wait_process_frames(2)
	for c in s.chapters:
		assert_not_null(c.get_node_or_null("ribbon"), "%s is a ribbon out of the cover" % c.name)
	var open := s.chapters[HeroScreen.Chapter.HERO]
	var shut := s.chapters[HeroScreen.Chapter.OPENING]
	assert_gte(open.size.y - shut.size.y, Book.MARK_RISE - 0.1, "the open one stands longer")
	assert_gte(open.get_global_rect().position.y, 12.0 - 0.5, "12 px from the top at least")


func test_the_scroll_bars_have_a_look_and_lists_fade_out() -> void:
	for t: Theme in [UiKit.theme(), Book.theme()]:
		assert_true(t.get_stylebox(&"grabber", &"VScrollBar") is StyleBoxTexture, "a long diamond")
		assert_true(t.get_stylebox(&"scroll", &"VScrollBar") is StyleBoxLine, "a thin line")
	var codex := CodexScreen.new()
	add_child_autofree(codex)
	codex.open(CodexScreen.Tab.GIFTS, _data(99999))
	var fades := codex._scroll.get_children(true).filter(func(n: Node) -> bool: return n is UiKit.ScrollFade)
	assert_eq(fades.size(), 1, "the list fades at its foot")
	assert_eq(codex._scroll.get_child(0), codex._list, "the list is still the scroll's one child")


# ---------- P1-7, P1-9: the hub's words ----------

func test_every_station_has_its_verb_and_no_prototype_words() -> void:
	for id: StringName in HubPlan.STATIONS:
		assert_true(T.table.entries.has("hub_use_%s" % id), "%s has a verb" % id)
		assert_ne(StationSign.verb(id), T.t(&"hub_use"))
	for key: String in ["hub_soon", "hub_vendor_soon", "hub_portal_desc"]:
		var text := T.t(key).to_lower()
		assert_false(text.contains("definir"), key)
		assert_false(text.contains("nesta versão"), key)


# ---------- P1-10: the endings ----------

func _end(victory: bool) -> EndScreen:
	var end := EndScreen.new()
	add_child_autofree(end)
	end.open(victory, {"time": 200.0, "level": 0, "kills": 30, "best_combo": 9, "boons": 4}, false)
	if victory:
		end.finish_sealing()
	return end


func test_both_endings_have_the_ways_in_the_same_places() -> void:
	for victory in [true, false]:
		var end := _end(victory)
		var ways := end.find_child("ways", true, false) as HBoxContainer
		assert_eq((ways.get_child(0) as Button).text, T.t(&"end_menu"), "back to the hub on the left")
		assert_eq((ways.get_child(1) as Button).text, T.t(&"end_again"), "down again on the right")


func test_the_numbers_stand_in_one_row_with_no_empty_cell() -> void:
	for victory in [true, false]:
		var end := _end(victory)
		var row := end.find_child("stats", true, false)
		assert_true(row is HBoxContainer, "one row")
		for cell in row.get_children():
			var labels := cell.find_children("*", "Label", true, false)
			assert_eq(labels.size(), 2, "a name and a number")
			assert_ne((labels[1] as Label).text, "")


func test_the_defeat_hides_the_hud() -> void:
	await _run()
	var end := EndScreen.new()
	game.add_child(end)
	end.open(false, {"time": 20.0, "level": 0, "kills": 3, "best_combo": 2, "boons": 0}, false)
	assert_false(game.hud.visible)


# ---------- P1-11: Configurações ----------

func test_every_setting_is_one_kind_of_row_with_its_tip() -> void:
	var o := OptionsScreen.new()
	add_child_autofree(o)
	o.open()
	await wait_process_frames(2)
	var rows := 0
	for n in o.find_children("opt_*", "Button", true, false):
		var b := n as Button
		rows += 1
		assert_ne(b.text, "<")
		assert_ne(b.text, ">")
		assert_not_null(b.find_child(b.name + "_1", true, false), "%s has its chevrons" % b.name)
		assert_ne(OptionsScreen.tip_text(b.name), "", "%s says what it does" % b.name)
	# Vídeo: window, full screen, quality, camera and the visual style (DT-RS2)
	assert_eq(rows, OptionsScreen.VOLUMES.size() + 5 + OptionsScreen.COMFORT.size())


func test_the_window_is_greyed_with_the_full_screen() -> void:
	var was: bool = Save.option("fullscreen")
	Save.data.options["fullscreen"] = true
	var o := OptionsScreen.new()
	add_child_autofree(o)
	o.open()
	var win := o.find_child("opt_scale", true, false) as Button
	assert_true(win.disabled)
	assert_eq(win.focus_mode, Control.FOCUS_NONE, "the focus skips it")
	Save.data.options["fullscreen"] = was


func test_left_and_right_step_a_setting_and_the_tip_follows() -> void:
	var was: String = String(Save.option("camera"))
	var o := OptionsScreen.new()
	add_child_autofree(o)
	o.open()
	await wait_process_frames(2)
	var cam := o.find_child("opt_camera", true, false) as Button
	cam.grab_focus()
	await wait_process_frames(1)
	assert_eq(o.tip.text, T.t(&"opt_camera_tip"))
	var ev := InputEventAction.new()
	ev.action = &"ui_right"
	ev.pressed = true
	cam.gui_input.emit(ev)
	await wait_process_frames(2)
	assert_ne(String(Save.option("camera")), was, "right stepped it")
	var again := o.find_child("opt_camera", true, false) as Button
	assert_true(again.has_focus(), "the focus stays on the row")
	Save.data.options["camera"] = was


# ---------- P1-8: the hub's names ----------

func test_the_hub_names_its_place_and_its_stations() -> void:
	# the far camera: with the near one (the default since LR-01) no station shows from the arrival yet; the hub's
	# layout for it is LR-11 (room-designer, environment-artist)
	var cam_was: Variant = Save.option("camera")
	Save.data.options["camera"] = "far"
	var hub: Hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	for i in 4:
		await get_tree().process_frame
	var labels := hub.find_child("HubLabels", false, false) as HubLabels
	assert_not_null(labels)
	assert_gt(labels.place.modulate.a, 0.5, "the place's name on arriving")
	assert_eq(labels.place.text, T.t(&"hub_name"))
	assert_gt(labels.shown().size(), 0, "some station named from the arrival")
	hub.player.pos = HubPlan.use_point(HubPlan.BOOK)
	hub.cam.snap()
	for i in 3:
		await get_tree().process_frame
	assert_false(labels.shown().has(HubPlan.BOOK), "the one in focus has its sign instead")
	Save.data.options["camera"] = cam_was


# ---------- P2-2, P2-5, P2-8, the Mastery's line (after Fatia 1) ----------

func test_the_mastery_reveals_and_the_memory_opens() -> void:
	assert_true(T.t(&"end_unlocked_many", {"name": "x"}).begins_with("Dons revelados"))
	assert_true(T.t(&"end_unlocked", {"name": "x"}).begins_with("Dom revelado"))
	assert_true(T.t(&"hero_next", {"n": 3, "what": "x"}).contains("você ganha"))


func test_the_codex_enemies_have_a_mark_and_a_tall_row() -> void:
	var d := _data(0)
	d.codex.enemies = {"skeleton": {"defeated": 64, "elite": 5}}
	var c := CodexScreen.new()
	add_child_autofree(c)
	c.open(CodexScreen.Tab.ENEMIES, d)
	var row := c.find_child("skeleton", true, false) as HBoxContainer
	assert_not_null(row.find_child("Mark", false, false) as RoleMark)
	assert_gte(row.custom_minimum_size.y, CodexScreen.LIST_ROW)
	var times := row.find_child("Times", false, false) as Label
	assert_true(times.text.contains(" · "), times.text)
	assert_eq(times.get_theme_font(&"font"), UiKit.number_font())


func test_a_juramento_off_says_nothing_on_the_right() -> void:
	var saved := Save.data
	Save.data = SaveData.defaults()
	Save.data.wins = 1
	var j := JuramentoScreen.new()
	add_child_autofree(j)
	j.open()
	for id: StringName in j._rows:
		assert_eq((j._rows[id].cost as Label).text, "")
	Save.data = saved


func test_the_hubs_menu_is_a_leaf_of_the_livro() -> void:
	var p := PauseMenu.new()
	p.hub = true
	add_child_autofree(p)
	p.open()
	assert_true(p.find_child("panel", true, false) is BookSpread)
	var plain := PauseMenu.new()
	add_child_autofree(plain)
	plain.open()
	assert_true(plain.find_child("panel", true, false) is PanelContainer)


func test_the_music_lists_one_lit_listen() -> void:
	var m := MusicRoomScreen.new()
	add_child_autofree(m)
	m.open()
	await wait_process_frames(2)
	var lit := 0
	for id: StringName in m._listen:
		if (m._listen[id] as Button).modulate.a > 0.5:
			lit += 1
	assert_lte(lit, 1, "only the one in focus, hovered or playing")
