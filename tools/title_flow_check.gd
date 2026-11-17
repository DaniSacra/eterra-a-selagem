extends SceneTree
## Drives the title like a player (keyboard): Iniciar starts the run, the pause's way back reaches the title again,
## O Guerreiro opens the hero screen (a Gift goes on and off with Enter, the arrows walk the tree), Como Jogar opens
## the Compêndio, Como Jogar and Configurações open and close with Esc, focus moves with the arrows, the comfort switches flip with
## Enter and keep the focus. Prints FLOW ok or FLOW FAIL.
## ~/tools/godot/godot --headless --path . -s tools/title_flow_check.gd

var _fail := 0


func _initialize() -> void:
	# a check, not a person's run: nothing written to the save or the run log (as --nosave)
	(func() -> void: root.get_node("Save").set("enabled", false)).call_deferred()
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok   " if ok else "FAIL ") + what)
	if not ok:
		_fail += 1


func _key(action: StringName) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	Input.parse_input_event(e)
	await process_frame
	var r := InputEventAction.new()
	r.action = action
	r.pressed = false
	Input.parse_input_event(r)
	await process_frame
	await process_frame


func _sub_is(boot: Node, file: String) -> bool:
	var sub = boot.get(&"_sub")
	return sub != null and String(sub.get_script().resource_path).ends_with(file)


func _wait(s: float) -> void:
	await create_timer(s).timeout


## The comfort switches by keys: Enter flips one and the focus stays on it, down reaches the next. Each is flipped
## back afterwards.
func _comfort(options: Node) -> void:
	var save := root.get_node("Save")
	var first := options.find_child("opt_impact_frames", true, false) as Control
	_check(first != null, "the options have Clarões de impacto")
	if first == null:
		return
	first.grab_focus()
	await process_frame
	for key: String in ["impact_frames", "slow_motion", "color_split", "rumble"]:
		var before: bool = save.call(&"option", key)
		await _key(&"ui_accept")
		_check(save.call(&"option", key) == not before, "Enter flips %s" % key)
		var row := options.find_child("opt_" + key, true, false) as Control
		_check(row != null and row.has_focus(), "the focus stays on %s" % key)
		await _key(&"ui_accept")
		_check(save.call(&"option", key) == before, "Enter flips %s back" % key)
		if key != "rumble":
			await _key(&"ui_down")


## The hero screen by keys: the focus starts on a Gift, Enter puts it on and takes it off, right walks to another node.
func _hero(screen: Node) -> void:
	var owner_ := root.gui_get_focus_owner()
	_check(owner_ != null and owner_.get_script() != null and String(owner_.get_script().resource_path).ends_with("talent_node.gd"),
		"the focus starts on a Gift")
	if owner_ == null:
		return
	var block: Dictionary = screen.get(&"loadout").get(&"block")
	var id := String(owner_.get(&"def").get(&"id"))
	var had: bool = (block.equipped as Array).has(id)
	await _key(&"ui_accept")
	_check((block.equipped as Array).has(id) != had, "Enter puts %s on (or off)" % id)
	await _key(&"ui_accept")
	_check((block.equipped as Array).has(id) == had, "Enter again takes it back")
	await _key(&"ui_down")
	var moved := root.gui_get_focus_owner()
	_check(moved != null and moved != owner_, "down walks the tree")


## Como Jogar's Compêndio by keys: it opens on the Gifts tab, right shows Bênçãos, Esc goes back to Como Jogar.
func _codex(howto: Node) -> void:
	var button := howto.find_child("moves", true, false) as Control
	_check(button != null, "Como Jogar has the Compêndio")
	if button == null:
		return
	button.grab_focus()
	await process_frame
	await _key(&"ui_accept")
	var codex := howto.find_children("*", "CodexScreen", true, false)
	_check(codex.size() == 1, "Compêndio opens")
	if codex.is_empty():
		return
	await _key(&"ui_right")
	_check(int(codex[0].get(&"tab")) == 1, "right shows Bênçãos")
	await _key(&"ui_cancel")
	await _wait(0.1)
	_check(howto.find_children("*", "CodexScreen", true, false).is_empty() and howto.is_inside_tree(), "Esc goes back to Como Jogar")


## The Juramentos (E6) by keys, once Morvath was sealed (wins 1, in memory only): Iniciar opens them with Descer in
## focus, up reaches a Juramento, right raises its rank and left lowers it (saved in Save.data), Esc goes back to the
## title with the focus on Iniciar; then Iniciar shows them again and Enter on Descer starts the run.
func _juramentos(boot: Node, menu: Variant) -> void:
	var save := root.get_node("Save")
	var data: Dictionary = save.get(&"data")
	data.wins = 1
	await _key(&"ui_accept")
	await _wait(0.3)
	_check(_sub_is(boot, "juramento_screen.gd"), "after a victory Iniciar opens the Juramentos")
	var owner_ := root.gui_get_focus_owner()
	_check(owner_ != null and owner_.name == "descend", "the focus starts on Descer")
	await _key(&"ui_up")
	var row := root.gui_get_focus_owner()
	var id := String(row.name) if row else ""
	_check(id == "rivals", "up reaches the last Juramento (%s)" % id)
	await _key(&"ui_right")
	_check(int((data.juramentos.ranks as Dictionary).get(id, 0)) == 1, "right raises %s to 1" % id)
	_check(root.gui_get_focus_owner() == row, "the focus stays on the row")
	await _key(&"ui_left")
	_check(int((data.juramentos.ranks as Dictionary).get(id, 0)) == 0, "left takes it off")
	await _key(&"ui_cancel")
	await _wait(0.3)
	_check(boot.get(&"_sub") == null and menu.visible, "Esc closes the Juramentos")
	_check(menu.button(0).has_focus(), "focus back on Iniciar")


func _run() -> void:
	change_scene_to_file("res://scenes/boot.tscn")
	await _wait(1.5)
	var boot := current_scene
	_check(boot != null and boot.name == "Boot", "title opens")
	var menu = boot.get(&"_menu")  # untyped: a -s script compiles before the autoloads exist
	_check(menu.button(0).has_focus(), "focus starts on Iniciar")
	await _key(&"ui_down")
	_check(menu.button(1).has_focus(), "down moves to O Guerreiro")
	await _key(&"ui_accept")
	await _wait(0.3)
	_check(_sub_is(boot, "hero_screen.gd"), "O Guerreiro opens the hero screen")
	await _hero(boot.get(&"_sub"))
	await _key(&"ui_cancel")
	await _wait(0.3)
	_check(boot.get(&"_sub") == null and menu.visible, "Esc closes the hero screen")
	_check(menu.button(1).has_focus(), "focus back on O Guerreiro")
	await _key(&"ui_down")
	_check(menu.button(2).has_focus(), "down moves to Como Jogar")
	await _key(&"ui_accept")
	await _wait(0.3)
	_check(_sub_is(boot, "how_to_screen.gd"), "Como Jogar opens its screen")
	await _codex(boot.get(&"_sub"))
	await _key(&"ui_cancel")
	await _wait(0.3)
	_check(boot.get(&"_sub") == null and menu.visible, "Esc closes it")
	_check(menu.button(2).has_focus(), "focus back on Como Jogar")
	await _key(&"ui_down")
	await _key(&"ui_accept")
	await _wait(0.3)
	_check(_sub_is(boot, "options_screen.gd"), "Configurações opens the options")
	await _comfort(boot.get(&"_sub"))
	await _key(&"ui_cancel")
	await _wait(0.3)
	_check(boot.get(&"_sub") == null, "Esc closes the options")
	await _key(&"ui_down")
	_check(menu.button(4).has_focus(), "down reaches Sair")
	await _key(&"ui_up")
	await _key(&"ui_up")
	await _key(&"ui_up")
	await _key(&"ui_up")
	_check(menu.button(0).has_focus(), "up returns to Iniciar")
	await _juramentos(boot, menu)
	await _key(&"ui_accept")
	await _wait(0.3)
	_check(_sub_is(boot, "juramento_screen.gd"), "Iniciar shows the Juramentos again")
	await _key(&"ui_accept")
	await _wait(2.0)
	_check(current_scene != null and current_scene.scene_file_path == "res://scenes/game.tscn", "Descer starts the run")
	change_scene_to_file("res://scenes/boot.tscn")
	await _wait(1.5)
	_check(current_scene != null and current_scene.name == "Boot" and current_scene.get(&"_menu") != null, "back to the title from the run")
	print("FLOW ok" if _fail == 0 else "FLOW FAIL %d" % _fail)
	quit(_fail)
