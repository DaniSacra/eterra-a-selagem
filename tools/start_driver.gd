extends SceneTree
## QA tool (E1c, bug 1 "sempre que começa a partida o herói solta um golpe sem eu apertar nada"): opens the title,
## clicks Iniciar with the left mouse button (a real click through Input, as a player's) once the menu is ready, or
## confirms it with --start-key=enter|space or --start-pad (the A button), and touches nothing after: a video
## (tools/movie.sh with PRE="-s res://tools/start_driver.gd") shows whether the run opens on a swing or a dodge.

var _t := 0.0
var _sent := false
## The release of the press, sent a few frames later (a person's click lasts about 0.1 s).
var _release: Array[InputEvent] = []
var _release_at := 0.0


func _initialize() -> void:
	change_scene_to_file("res://scenes/boot.tscn")


func _process(dt: float) -> bool:
	_t += dt
	if not _release.is_empty() and _t >= _release_at:
		for e in _release:
			Input.parse_input_event(e)
		_release.clear()
	if _sent or _t < 1.5:
		return false
	var menu: Node = null
	for n in root.find_children("*", "Control", true, false):
		if n.has_signal(&"start_pressed"):
			menu = n
	if menu == null:
		return false
	_sent = true
	var how := "mouse"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--start-key="):
			how = a.trim_prefix("--start-key=")
		elif a == "--start-pad":
			how = "pad"
	print("START by ", how)
	match how:
		"enter", "space":
			var code := KEY_ENTER if how == "enter" else KEY_SPACE
			for down in [true, false]:
				var k := InputEventKey.new()
				k.physical_keycode = code
				k.keycode = code
				k.pressed = down
				_send(k)
		"pad":
			for down in [true, false]:
				var j := InputEventJoypadButton.new()
				j.button_index = JOY_BUTTON_A
				j.pressed = down
				_send(j)
		_:
			var button: Control = menu.call(&"button", 0)
			var at := button.get_global_rect().get_center()
			var m := InputEventMouseMotion.new()
			m.position = at
			m.global_position = at
			Input.parse_input_event(m)
			for down in [true, false]:
				var b := InputEventMouseButton.new()
				b.button_index = MOUSE_BUTTON_LEFT
				b.position = at
				b.global_position = at
				b.pressed = down
				_send(b)
	return false


func _send(e: InputEvent) -> void:
	if e.is_pressed():
		Input.parse_input_event(e)
	else:
		_release.append(e)
		_release_at = _t + 0.1
