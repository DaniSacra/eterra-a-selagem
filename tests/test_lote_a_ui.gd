extends GutTest
## Lote A, front A5 (the interface still open): the visual style as a setting (DT-RS2), the door the map looks at lit in
## the room and the map's page turning in and drawing its way (MAP-07, MAP-08), Morvath's entrance under his bar (AP-2,
## ART-05.5), the gamepad's buttons for the menus and their remapping (DT-103), the sealing's veil and halo and the gold
## beside the number (QW-115), the quieter common bars (ART-02.6) and the key plates of Como Jogar (P2-3).

var game: Game
var _look: VisualProfile.Look


func before_each() -> void:
	_look = VisualProfile.current()


func after_each() -> void:
	Dev.put("seed", "1")  # back to the seed of every test, never none (tests/hooks/pre_run.gd, BUG-109)
	Dev._args.erase("boons")
	VisualProfile.set_look(_look)
	Controls.reset_bindings()


func _run() -> void:
	Dev._args["seed"] = "5"
	Dev._args["boons"] = "0"
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.horde.clear_crowd()
	await wait_process_frames(4)


# ---------- DT-RS2 ----------

func test_the_video_page_has_the_visual_style_and_it_flips_as_f7() -> void:
	var o := OptionsScreen.new()
	add_child_autofree(o)
	o.open()
	await wait_process_frames(2)
	var row := o.find_child("opt_look", true, false) as Button
	assert_not_null(row, "Vídeo has Estilo visual")
	assert_true(o.pages[OptionsScreen.Tab.VIDEO].is_ancestor_of(row), "on the Vídeo page")
	var was := VisualProfile.current()
	row.pressed.emit()
	await wait_process_frames(2)
	assert_ne(VisualProfile.current(), was, "a step flips the style")
	var state := o.find_child("opt_look", true, false).find_child("state", true, false) as Label
	assert_eq(state.text, T.t("opt_look_stylized" if VisualProfile.stylized() else "opt_look_classic"), "the row says the style in use")
	(o.find_child("opt_look", true, false) as Button).pressed.emit()
	await wait_process_frames(2)
	assert_eq(VisualProfile.current(), was, "and back")
	assert_ne(OptionsScreen.tip_text("opt_look"), "", "it says what it does")


# ---------- DT-103 ----------

func test_the_menus_take_a_and_b() -> void:
	var a := InputEventJoypadButton.new()
	a.button_index = JOY_BUTTON_A
	a.pressed = true
	var b := InputEventJoypadButton.new()
	b.button_index = JOY_BUTTON_B
	b.pressed = true
	assert_true(a.is_action_pressed(&"ui_accept"), "A confirms in the menus")
	assert_true(b.is_action_pressed(&"ui_cancel"), "B goes back")


func test_a_gamepad_button_rebinds_and_swaps() -> void:
	Controls.reset_bindings()
	var y := InputEventJoypadButton.new()
	y.button_index = JOY_BUTTON_Y
	assert_true(Controls.rebind_pad(&"light_attack", y))
	var saved: Dictionary = Save.option("bindings")
	assert_eq(Controls.pad_button_for(&"light_attack", saved), JOY_BUTTON_Y)
	assert_eq(Controls.pad_button_for(&"heavy_attack", saved), JOY_BUTTON_X, "the Especial takes the X the Ataque had")
	var press := InputEventJoypadButton.new()
	press.button_index = JOY_BUTTON_Y
	press.pressed = true
	assert_true(press.is_action_pressed(&"light_attack"), "the InputMap follows")
	assert_false(press.is_action_pressed(&"heavy_attack"))
	assert_false(Controls.rebind_pad(&"move_up", y), "the walking stays on the stick")
	Controls.reset_bindings()
	assert_eq(Controls.pad_button_for(&"light_attack", Save.option("bindings")), JOY_BUTTON_X, "Teclas padrão gives it back")


func test_the_controls_page_shows_the_buttons_on_plates() -> void:
	var o := OptionsScreen.new()
	add_child_autofree(o)
	o.open()
	await wait_process_frames(2)
	for action in Controls.PAD_REMAPPABLE:
		var row := o.find_child("key_" + action, true, false)
		assert_not_null(row)
		var cap := row.find_child("pad", true, false) as StationSign.KeyCap
		assert_not_null(cap, "%s shows its button" % action)
		if cap:
			assert_eq(cap.text, HowToScreen.pad_label([action]))
	assert_not_null(o.find_child("pad_note", true, false), "a line says a button binds too")


# ---------- P2-3 ----------

func test_how_to_plays_puts_keys_and_buttons_on_plates() -> void:
	var s := HowToScreen.new()
	add_child_autofree(s)
	s.open()
	await wait_process_frames(2)
	var keys := s.find_child("keys_move", true, false)
	assert_eq(keys.find_children("*", "Control", false, false).size(), 4, "W A S D: four plates")
	var pad := s.find_child("pad_dodge", true, false)
	var cap := pad.get_child(0) as StationSign.KeyCap
	assert_true(cap.rounded, "a face button of the gamepad is round")


# ---------- MAP-08 ----------

func test_the_newest_stretch_draws_in() -> void:
	var m := DescentMap.from_dict(MapSample.at("middle"))
	var g := MapGraph.new().setup(m)
	g.size = Vector2(400, 500)
	add_child_autofree(g)
	assert_eq(g.ink, 1.0)
	g.draw_in(0.2)
	assert_eq(g.ink, 0.0, "the stretch into the room starts undrawn")
	await wait_seconds(0.35)
	assert_eq(g.ink, 1.0, "and is drawn after")


# ---------- AP-2 ----------

func test_morvaths_entrance_takes_the_chambers_notice() -> void:
	await _run()
	game.start_boss(game.rooms.stage.boss)
	await wait_process_frames(2)
	var hud := game.hud
	assert_true(hud.entrance_shown(), "he rises with his entrance")
	hud.show_notice(T.t(&"room_boss"), 2.0)
	assert_ne(hud._notice.text, T.t(&"room_boss"), "the chamber's name goes into his entrance, no separate notice")
	assert_eq((hud._entrance.get_node(^"place") as Label).text, T.t(&"room_boss"))
	assert_eq((hud._entrance.get_node(^"name") as Label).text, "Morvath")
	assert_eq((hud._entrance.get_node(^"epithet") as Label).text, "O rei que traiu a luz")
	await wait_seconds(Hud.ENTRANCE_TIME + 0.2)
	assert_false(hud.entrance_shown(), "gone before his first blow")


# ---------- QW-115 ----------

func test_the_gold_rises_beside_where_it_fell() -> void:
	await _run()
	var at := Vector3(game.player.pos.x, 2.4, game.player.pos.y)
	game.fx.gold(at, 1)
	var e = game.fx._tally.entries[game.fx._gold_at]
	assert_gt(Vector2(e.pos.x - at.x, e.pos.z - at.z).length(), Fx.GOLD_SIDE * 0.6, "beside the number, not over it")
	assert_lt(Fx.GOLD_SIZE, Fx.NUMBER_SIZE, "and smaller")


func test_the_seals_halo_is_a_gradient() -> void:
	var tex := SealEmblem.halo_texture()
	assert_eq(tex.fill, GradientTexture2D.FILL_RADIAL)
	assert_eq(tex.gradient.colors[-1].a, 0.0, "nothing at its edge")


# ---------- ART-02.6 ----------

func test_common_bars_are_quieter() -> void:
	var code := (load("res://assets/shaders/life_bar.gdshader") as Shader).code
	assert_true(code.contains("common_dim = 0.85"), "15% darker")
	assert_true(code.contains("common_cut"), "and thinner")
