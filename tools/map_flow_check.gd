extends SceneTree
## Drives the descent's map (DV-1, MAP-03) in a real run like a player, with real events: the keyboard (M opens, the
## arrows walk the rooms, M closes; Esc closes too and never opens the pause), the gamepad (Back opens, the d-pad walks,
## Start or Back close) and the mouse (the HUD's "Mapa [M]" button opens, the pointer focuses a room, Voltar closes), then the
## pause's Mapa (opens over the pause, Esc comes back to it, Esc leaves the pause). While the map is open the run's
## clock stands still; no press that opened or closed it swings or dodges. Prints MAP_FLOW ok or MAP_FLOW FAIL.
## ~/tools/godot/godot --headless --path . -s tools/map_flow_check.gd

const PLAY := 0
const CHOICE := 1
const PAUSE := 2

var _fail := 0
var _moves := 0
var _game: Node


func _initialize() -> void:
	(func() -> void: root.get_node("Save").set("enabled", false)).call_deferred()
	create_timer(60.0).timeout.connect(func() -> void:
		print("MAP_FLOW FAIL (timeout)")
		quit(1))
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok   " if ok else "FAIL ") + what)
	if not ok:
		_fail += 1


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _send(e: InputEvent) -> void:
	Input.parse_input_event(e)
	Input.flush_buffered_events()
	await _frames(2)


func _tap(e: InputEvent) -> void:
	e.set(&"pressed", true)
	await _send(e)
	var up := e.duplicate() as InputEvent
	up.set(&"pressed", false)
	await _send(up)
	await _frames(2)


func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.keycode = code
	return e


func _pad(button: JoyButton) -> InputEventJoypadButton:
	var e := InputEventJoypadButton.new()
	e.button_index = button
	return e


## A mouse event at the centre of a control (or a point in it), in the window's own pixels.
func _mouse(c: Control, at: Variant = null, motion := false) -> InputEventMouse:
	var e: InputEventMouse = InputEventMouseMotion.new() if motion else InputEventMouseButton.new()
	if not motion:
		(e as InputEventMouseButton).button_index = MOUSE_BUTTON_LEFT
	var local: Vector2 = at if at != null else c.size * 0.5
	e.position = root.get_final_transform() * (c.get_global_transform_with_canvas() * local)
	return e


func _mode() -> int:
	return int(_game.get(&"mode"))


func _map() -> Node:
	var s: Variant = _game.get(&"_screen")
	return s if s != null and String((s as Node).get_script().resource_path).ends_with("map_screen.gd") else null


func _run() -> void:
	_game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	root.add_child(_game)
	await create_timer(1.0).timeout
	var player: Node = _game.get(&"player")
	player.get(&"runner").connect(&"move_started", func(_n: Variant) -> void: _moves += 1)
	player.connect(&"dodged", func(_d: Variant) -> void: _moves += 1)
	var hud: Node = _game.get(&"hud")
	var button := hud.get(&"map_button") as Button
	_check(button.visible and button.text.contains("M"), "the HUD shows Mapa [M]: " + button.text)

	# keyboard
	await _tap(_key(KEY_M))
	_check(_mode() == CHOICE and _map() != null, "M opens the map")
	var t: float = _game.get(&"time")
	await _frames(10)
	_check(float(_game.get(&"time")) == t, "the run's clock stands still under the map")
	var graph: Node = _map().get(&"graph")
	var first: int = graph.get(&"focus_id")
	await _tap(_key(KEY_DOWN))
	_check(int(graph.get(&"focus_id")) != first, "down walks to the next depth")
	var text: String = _map().call(&"focus_text")
	var depth: int = graph.get(&"map").call(&"room", graph.get(&"focus_id")).get(&"depth")
	_check(text.contains("Sala %d de" % depth), "the page tells the room in focus: " + text.replace("\n", " / "))
	await _tap(_key(KEY_UP))
	_check(int(graph.get(&"focus_id")) == first, "up comes back")
	await _tap(_key(KEY_M))
	_check(_mode() == PLAY and _map() == null, "M closes it")
	await _tap(_key(KEY_M))
	await _tap(_key(KEY_ESCAPE))
	_check(_mode() == PLAY, "Esc closes it and the pause stays shut")

	# gamepad
	await _tap(_pad(JOY_BUTTON_BACK))
	_check(_mode() == CHOICE and _map() != null, "Back opens the map")
	graph = _map().get(&"graph")
	first = graph.get(&"focus_id")
	await _tap(_pad(JOY_BUTTON_DPAD_DOWN))
	_check(int(graph.get(&"focus_id")) != first, "the d-pad walks the rooms")
	await _tap(_pad(JOY_BUTTON_START))
	_check(_mode() == PLAY and _map() == null, "Start closes it and the pause stays shut")
	await _tap(_pad(JOY_BUTTON_BACK))
	await _tap(_pad(JOY_BUTTON_BACK))
	_check(_mode() == PLAY, "Back closes it")

	# mouse
	await _tap(_mouse(button))
	_check(_mode() == CHOICE and _map() != null, "a click on Mapa opens the map")
	graph = _map().get(&"graph")
	var last: int = (graph.get(&"map").get(&"layers") as Array)[-1][0].get(&"id")
	await _send(_mouse(graph as Control, graph.call(&"centre", last), true))
	_check(int(graph.get(&"focus_id")) == last, "the pointer focuses the room under it (Morvath)")
	await _tap(_mouse(_map().find_child("back", true, false) as Control))
	_check(_mode() == PLAY and _map() == null, "Voltar closes it")

	# the pause's Mapa
	await _tap(_key(KEY_ESCAPE))
	_check(_mode() == PAUSE, "Esc opens the pause")
	var pause: Node = _game.get(&"_screen")
	var entry := pause.get(&"map_button") as Button
	_check(entry != null, "the pause has Mapa")
	await _tap(_key(KEY_M))
	_check(pause.find_child("map_screen", false, false) != null, "M opens the map over the pause")
	await _tap(_key(KEY_ESCAPE))
	_check(pause.find_child("map_screen", false, false) == null and _mode() == PAUSE, "Esc comes back to the pause")
	_check(entry.has_focus(), "the focus is back on Mapa")
	await _tap(_key(KEY_ESCAPE))
	_check(_mode() == PLAY, "Esc leaves the pause")
	await _frames(10)
	_check(_moves == 0, "no swing nor dodge from any of it (%d)" % _moves)
	print("MAP_FLOW " + ("ok" if _fail == 0 else "FAIL (%d)" % _fail))
	quit(0 if _fail == 0 else 1)
