extends SceneTree
## QA (A8): the title by gamepad only (real InputEventJoypadButton): A on Iniciar (in focus) reaches the hub. Exits
## with the number of failures.
## ~/tools/godot/godot --headless --path . -s tools/title_pad_check.gd -- --title --nosave

var _fail := 0


func _initialize() -> void:
	(func() -> void: root.get_node("Save").set("enabled", false)).call_deferred()
	change_scene_to_file.call_deferred("res://scenes/boot.tscn")
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok   " if ok else "FAIL ") + what)
	if not ok:
		_fail += 1


func _pad(button: JoyButton) -> void:
	for down: bool in [true, false]:
		var e := InputEventJoypadButton.new()
		e.button_index = button
		e.pressed = down
		Input.parse_input_event(e)
		await process_frame
		await process_frame


func _run() -> void:
	await create_timer(2.0).timeout
	var f := root.gui_get_focus_owner()
	_check(f != null, "the title has a button in focus (%s)" % (f.name if f else "none"))
	await _pad(JOY_BUTTON_A)
	await create_timer(2.0).timeout
	var path := current_scene.scene_file_path if current_scene else ""
	_check(path == "res://scenes/hub.tscn", "A on Iniciar reaches the hub (%s)" % path)
	quit(_fail)
