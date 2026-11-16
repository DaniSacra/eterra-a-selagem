extends SceneTree
## Drives the title like a player (keyboard): Iniciar starts the run, the pause's way back reaches the title again,
## Como Jogar and Configurações open and close with Esc, focus moves with the arrows. Prints FLOW ok or FLOW FAIL.
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


func _run() -> void:
	change_scene_to_file("res://scenes/boot.tscn")
	await _wait(1.5)
	var boot := current_scene
	_check(boot != null and boot.name == "Boot", "title opens")
	var menu = boot.get(&"_menu")  # untyped: a -s script compiles before the autoloads exist
	_check(menu.button(0).has_focus(), "focus starts on Iniciar")
	await _key(&"ui_down")
	_check(menu.button(1).has_focus(), "down moves to Como Jogar")
	await _key(&"ui_accept")
	await _wait(0.3)
	_check(_sub_is(boot, "how_to_screen.gd"), "Como Jogar opens its screen")
	await _key(&"ui_cancel")
	await _wait(0.3)
	_check(boot.get(&"_sub") == null and menu.visible, "Esc closes it")
	_check(menu.button(1).has_focus(), "focus back on Como Jogar")
	await _key(&"ui_down")
	await _key(&"ui_accept")
	await _wait(0.3)
	_check(_sub_is(boot, "options_screen.gd"), "Configurações opens the options")
	await _key(&"ui_cancel")
	await _wait(0.3)
	_check(boot.get(&"_sub") == null, "Esc closes the options")
	await _key(&"ui_down")
	_check(menu.button(3).has_focus(), "down reaches Sair")
	await _key(&"ui_up")
	await _key(&"ui_up")
	await _key(&"ui_up")
	_check(menu.button(0).has_focus(), "up returns to Iniciar")
	await _key(&"ui_accept")
	await _wait(2.0)
	_check(current_scene != null and current_scene.scene_file_path == "res://scenes/game.tscn", "Iniciar starts the run")
	change_scene_to_file("res://scenes/boot.tscn")
	await _wait(1.5)
	_check(current_scene != null and current_scene.name == "Boot" and current_scene.get(&"_menu") != null, "back to the title from the run")
	print("FLOW ok" if _fail == 0 else "FLOW FAIL %d" % _fail)
	quit(_fail)
