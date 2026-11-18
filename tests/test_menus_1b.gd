extends GutTest
## Stage 1B of the art pack (boards 06 and 10): the pause (compact panel, Continuar first, ways out at the foot, focus
## order and its return from a page), Suas Bênçãos grouped (actions, automatic, Elos) for a full hand, the credits in
## blocks with every attribution, the victory's sealing before its summary, the defeat's main action, Configurações in
## tabs and Como Jogar in tabs, all within 1280 x 720.

const MANY: Array[StringName] = [&"golpe_brasa", &"toque_geada", &"circulo_radiante", &"passos", &"brasas", &"redemoinho",
	&"lamina_ardente", &"estilhaco", &"peso_inverno", &"consolo", &"onda_maior", &"flagelo", &"escudo", &"firmeza",
	&"vapor", &"aurora", &"chama_viva", &"bastiao", &"rastro", &"passo_frio"]

var _saving := true
var _options := {}


func before_each() -> void:
	_saving = Save.enabled
	Save.enabled = false
	_options = Save.data.options.duplicate(true)


func after_each() -> void:
	Save.data.options = _options
	Save.enabled = _saving


func _press(action: StringName) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	Input.parse_input_event(e)
	await get_tree().process_frame
	var r := InputEventAction.new()
	r.action = action
	r.pressed = false
	Input.parse_input_event(r)
	await get_tree().process_frame
	await get_tree().process_frame


func _focus() -> Control:
	return get_viewport().gui_get_focus_owner()


func _full_hand() -> BoonState:
	var state := BoonState.new(BoonState.load_catalog())
	for id in MANY:
		state.take(state.find(id))
	return state


func _holder() -> Control:
	var holder := Control.new()
	holder.size = Vector2(1280, 720)
	add_child_autofree(holder)
	return holder


func _on_screen(root: Node) -> void:
	for c: Control in root.find_children("*", "Button", true, false):
		if not c.is_visible_in_tree():
			continue
		var r := c.get_global_rect()
		assert_true(r.position.y >= 0.0 and r.end.y <= 720.0 and r.position.x >= 0.0 and r.end.x <= 1280.0,
				"%s on a 1280 x 720 screen (%s)" % [c.name, r])


func _texts(n: Node) -> Array[String]:
	var out: Array[String] = []
	if n is Label:
		out.append((n as Label).text)
	if n is Button:
		out.append((n as Button).text)
	for c in n.get_children():
		out.append_array(_texts(c))
	return out


# ---------- the pause ----------

func test_pause_walks_its_buttons_in_order_and_wraps() -> void:
	var pause := PauseMenu.new()
	_holder().add_child(pause)
	pause.open()
	await wait_process_frames(2)
	var names: Array[String] = []
	for b in pause.buttons:
		names.append(String(b.name))
	var expected: Array[String] = ["continue", "boons", "codex", "options", "quit"]
	if not OS.has_feature("mobile") and not OS.has_feature("web"):
		expected.append("exit_game")
	assert_eq(names, expected, "Continuar first, the ways out last")
	assert_true(pause.buttons[0].has_focus(), "Continuar has the focus")
	assert_eq(pause.buttons[0].get_theme_stylebox(&"normal").bg_color, UiKit.PRIMARY_FILL, "Continuar stands out")
	assert_eq(pause.buttons[-1].get_parent().name, &"foot", "the ways out at the foot")
	for i in pause.buttons.size():
		await _press(&"ui_down")
		assert_eq(_focus(), pause.buttons[(i + 1) % pause.buttons.size()], "down to the next (%d)" % i)
	await _press(&"ui_up")
	assert_eq(_focus(), pause.buttons[-1], "up from Continuar wraps to the last")
	_on_screen(pause)


func test_pause_gives_the_focus_back_to_the_page_s_button() -> void:
	var pause := PauseMenu.new()
	_holder().add_child(pause)
	pause.open()
	await wait_process_frames(2)
	var options: Button = pause.buttons[3]
	options.grab_focus()
	options.pressed.emit()
	await wait_process_frames(2)
	assert_eq(pause.find_children("*", "OptionsScreen", true, false).size(), 1, "Configurações opens over the pause")
	await _press(&"ui_cancel")
	await wait_process_frames(2)
	assert_eq(pause.find_children("*", "OptionsScreen", true, false).size(), 0)
	assert_true(options.has_focus(), "the focus back on Configurações")


# ---------- Suas Bênçãos ----------

func test_blessings_are_grouped_and_a_full_hand_scrolls() -> void:
	var state := _full_hand()
	var panel := BoonsScreen.new()
	panel.state = state
	_holder().add_child(panel)
	panel.open()
	await wait_process_frames(3)
	assert_eq((panel.rows[BoonsScreen.Group.ACTIONS] as Array).size(), 4, "one on each action")
	assert_eq((panel.rows[BoonsScreen.Group.ELOS] as Array).size(), 6)
	assert_eq((panel.rows[BoonsScreen.Group.AUTO] as Array).size(), state.owned().size() - 10)
	for b in state.owned():
		var g := BoonsScreen.group_of(b)
		assert_true((panel.rows[g] as Array).any(func(r: Control) -> bool: return r.name == b.id), "%s in its group" % b.id)
		assert_eq(g == BoonsScreen.Group.ELOS, b.is_duo())
	var first: Control = (panel.rows[BoonsScreen.Group.ACTIONS] as Array)[0]
	assert_true(first.has_focus(), "the focus starts on the first row")
	assert_true(panel.nav[0].button_pressed, "its group is lit")
	# the Elos' entry takes the focus to the first Elo, and the list scrolls to it
	panel.nav[2].pressed.emit()
	await wait_process_frames(3)
	var elo: Control = (panel.rows[BoonsScreen.Group.ELOS] as Array)[0]
	assert_true(elo.has_focus())
	assert_true(panel.nav[2].button_pressed)
	var scroll := panel.find_child("list", true, false) as ScrollContainer
	assert_gt(scroll.scroll_vertical, 0, "scrolled down to the Elos")
	await _press(&"ui_left")
	assert_eq(_focus(), panel.nav[2], "left goes back to the group")
	_on_screen(panel)


# ---------- the end screen ----------

func test_victory_shows_the_sealing_first_and_a_press_ends_it() -> void:
	var end := EndScreen.new()
	_holder().add_child(end)
	end.open(true, {"time": 300.0, "level": 0, "kills": 120, "best_combo": 14, "boons": 5}, false)
	await wait_process_frames(2)
	assert_true(end.intro, "the sealing plays")
	var sealing := end.find_child("sealing", true, false) as Control
	assert_not_null(sealing)
	assert_not_null(sealing.find_child("seal", true, false), "the seal alone first")
	var summary := end.find_child("summary", true, false) as Control
	assert_not_null(summary)
	await _press(&"ui_accept")
	assert_false(end.intro, "a press ends it")
	assert_false(sealing.visible)
	var seal := sealing.find_child("seal", true, false) as SealEmblem
	assert_eq(seal.closed, 1.0)
	var go_on := end.find_child("continue", true, false) as Button
	assert_true(go_on.has_focus(), "Continuar has the focus")
	_on_screen(end)


func test_victory_sealing_ends_by_itself() -> void:
	var end := EndScreen.new()
	_holder().add_child(end)
	end.open(true, {"time": 300.0, "level": 0, "kills": 120, "best_combo": 14, "boons": 5}, false)
	await wait_seconds(EndScreen.SUMMARY_AT + EndScreen.SUMMARY_RISE + 0.2)
	assert_false(end.intro)
	assert_almost_eq(end.modulate.a, 1.0, 0.01)


func test_defeat_has_its_main_action_and_the_real_labels() -> void:
	var end := EndScreen.new()
	_holder().add_child(end)
	var gain := HeroDef.warrior().mastery.run_xp({"rooms": 5})
	end.open(false, {"time": 200.0, "level": 0, "kills": 30, "best_combo": 9, "boons": 4, "defeated_by": &"killer_storm",
		"mastery": {"gain": gain, "xp_before": 0}}, false)
	await wait_process_frames(2)
	var retry := end.find_child("retry", true, false) as Button
	assert_eq(retry.text, T.t(&"end_again"))
	assert_true(retry.has_focus())
	assert_eq(retry.get_theme_stylebox(&"normal").bg_color, UiKit.PRIMARY_FILL, "the main action stands out")
	assert_eq((end.find_child("menu", true, false) as Button).text, T.t(&"end_menu"))
	assert_not_null(end.find_child("mastery", true, false), "the progress kept")
	_on_screen(end)


# ---------- Configurações and Como Jogar ----------

func test_options_in_tabs_show_the_page_of_the_focus() -> void:
	var o := OptionsScreen.new()
	_holder().add_child(o)
	o.open()
	await wait_process_frames(2)
	assert_eq(o.tabs.size(), 4)
	assert_true(o.tabs[OptionsScreen.Tab.AUDIO].has_focus(), "the focus starts on Áudio")
	assert_true(o.pages[OptionsScreen.Tab.AUDIO].is_ancestor_of(o.find_child("music_room", true, false)), "Músicas under Áudio")
	await _press(&"ui_right")
	assert_eq(o.tab, OptionsScreen.Tab.VIDEO, "right on the tabs shows the next page")
	assert_true(o.pages[OptionsScreen.Tab.VIDEO].visible)
	assert_false(o.pages[OptionsScreen.Tab.AUDIO].visible)
	await _press(&"ui_down")
	assert_true(o.pages[OptionsScreen.Tab.VIDEO].is_ancestor_of(_focus()), "down goes into the page")
	(o.find_child("opt_rumble", true, false) as Control).grab_focus()
	await wait_process_frames(1)
	assert_eq(o.tab, OptionsScreen.Tab.COMFORT, "a row of another page brings its page")
	for t in o.tabs.size():
		o.tabs[t].grab_focus()
		await wait_process_frames(2)
		_on_screen(o)


func test_how_to_has_the_descent_and_the_controls() -> void:
	var h := HowToScreen.new()
	_holder().add_child(h)
	h.open()
	await wait_process_frames(2)
	assert_eq(h.tabs.size(), 2)
	assert_true(h.pages[HowToScreen.Tab.DESCENT].visible, "the descent first")
	for id in HowToScreen.STEPS:
		assert_not_null(h.find_child("step_" + id, true, false))
		for key: String in ["howto_step_" + id, "howto_step_%s_desc" % id]:
			assert_ne(T.t(key), key)
	h.tabs[HowToScreen.Tab.CONTROLS].grab_focus()
	await wait_process_frames(2)
	assert_true(h.pages[HowToScreen.Tab.CONTROLS].visible)
	assert_true((h.find_child("keys_dodge", true, false) as Control).is_visible_in_tree())
	_on_screen(h)


func test_new_texts_have_no_dash() -> void:
	for key: String in ["pause_carried", "boons_group_actions", "boons_group_auto", "boons_group_elos", "options_tab_audio",
			"options_tab_video", "options_tab_controls", "howto_tab_descent", "options_title", "pause_options"]:
		var t := T.t(key)
		assert_ne(t, key, "%s is in text_pt.tres" % key)
		assert_false(t.contains("—") or t.contains("–"), key)
	assert_eq(T.t(&"options_title"), T.t(&"title_settings"), "one name for the settings everywhere")
	assert_eq(T.t(&"pause_options"), T.t(&"title_settings"))
