extends GutTest
## "Como Jogar" (HowToScreen): every action the player has is listed, with the bindings that are live right now.


func after_each() -> void:
	Controls.using_pad = false
	Controls.apply_bindings()


func _screen() -> HowToScreen:
	var s := HowToScreen.new()
	add_child_autofree(s)
	s.open()
	return s


func _text(s: HowToScreen, node_name: String) -> String:
	var l := s.find_child(node_name, true, false)
	assert_not_null(l, node_name)
	return String(l.get(&"text")) if l else ""


func test_builds_with_rows_and_buttons() -> void:
	var s := _screen()
	assert_not_null(s.find_child("back", true, false))
	assert_not_null(s.find_child("moves", true, false))
	for row in HowToScreen.ROWS:
		assert_ne(_text(s, "keys_" + row.id), "")
		assert_ne(_text(s, "pad_" + row.id), "?", "every row has a gamepad binding: " + row.id)


func test_lists_every_gameplay_action() -> void:
	var listed: Array = []
	for row in HowToScreen.ROWS:
		listed.append_array(row.actions)
	for action in Controls.ACTIONS:
		if not HowToScreen.HIDDEN.has(action):
			assert_true(listed.has(action), "missing from Como Jogar: " + action)
	for row in HowToScreen.ROWS:
		assert_true(T.table.entries.has("howto_" + row.id), "name text " + row.id)
		assert_true(T.table.entries.has("howto_%s_desc" % row.id), "description text " + row.id)


func test_labels_come_from_controls_and_follow_remaps() -> void:
	InputMap.action_erase_events(&"light_attack")
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_K
	InputMap.action_add_event(&"light_attack", ev)
	var pad := InputEventJoypadButton.new()
	pad.button_index = JOY_BUTTON_X
	InputMap.action_add_event(&"light_attack", pad)
	var s := _screen()
	assert_eq(_text(s, "keys_light_attack"), "K")
	assert_eq(_text(s, "pad_light_attack"), T.t("pad_%d" % JOY_BUTTON_X))
	assert_eq(_text(s, "keys_dodge"), UiKit.action_label(&"dodge"))
	assert_eq(_text(s, "pad_move"), T.t(&"pad_stick_left"))


func test_keyboard_column_ignores_the_device_in_use() -> void:
	Controls.using_pad = true
	assert_eq(HowToScreen.keys_label([&"dodge"]), T.t(&"key_Space"))
	assert_true(Controls.using_pad, "the device in use is restored")
	Controls.using_pad = false
	assert_eq(HowToScreen.pad_label([&"dodge"]), T.t("pad_%d" % JOY_BUTTON_B))
	assert_false(Controls.using_pad)


func test_compendio_opens_the_codex_and_comes_back() -> void:
	var s := _screen()
	(s.find_child("moves", true, false) as Button).pressed.emit()
	var codex := s.find_children("*", "CodexScreen", true, false)
	assert_eq(codex.size(), 1)
	(codex[0] as CodexScreen).closed.emit()
	await wait_process_frames(1)
	assert_eq(s.find_children("*", "CodexScreen", true, false).size(), 0)


## F6: the Maga's controls page uses her own lines where they exist and the common one elsewhere.
func test_the_maga_page_reads_her_lines_and_falls_back_to_the_common_ones() -> void:
	assert_eq(HowToScreen.desc_key("light_attack", true), &"howto_light_attack_desc_maga")
	assert_eq(HowToScreen.desc_key("ultimate", true), &"howto_ultimate_desc_maga")
	assert_eq(HowToScreen.desc_key("interact", true), &"howto_interact_desc", "no line of hers: the common one")
	assert_eq(HowToScreen.desc_key("light_attack", false), &"howto_light_attack_desc", "the Warrior keeps his own")
	assert_false(T.t(&"howto_ultimate_desc_maga").contains("—"))
