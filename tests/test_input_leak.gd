extends GutTest
## E1c, bug 1 (Daniel's test of E1: "sempre que começa a partida o herói solta um golpe sem eu apertar nada"): the
## click or key that starts the run, picks a gift or leaves the pause must never reach the run as a swing or a dodge.
## Controls latched every press while no game stepped (the title flushes nothing), so the left click on Iniciar (also
## light_attack) waited there and the run opened on a swing; Space (ui_accept and dodge) opened it on a dodge. These
## drive the real Input with real events and the real game scene, frame by frame.

var game: Game
var started: Array[StringName] = []
var dodges := 0


func before_each() -> void:
	Controls.virtual = null
	Controls.clear_presses()
	started.clear()
	dodges = 0


func after_each() -> void:
	Input.action_release(&"light_attack")
	Input.action_release(&"dodge")
	Input.action_release(&"heavy_attack")
	Input.action_release(&"pause")
	Input.action_release(&"map")
	Controls.virtual = null
	Controls.clear_presses()
	Engine.time_scale = 1.0


func _mouse(pressed: bool) -> InputEvent:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = pressed
	e.position = Vector2(-50, -50)  # off every control: only the action matters here
	return e


func _key(code: Key, pressed: bool) -> InputEvent:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.keycode = code
	e.pressed = pressed
	return e


func _pad(button: JoyButton, pressed: bool) -> InputEvent:
	var e := InputEventJoypadButton.new()
	e.button_index = button
	e.pressed = pressed
	return e


## A real event through Input, then frames go by (Controls sees it in its _process). The event goes in at the start
## of a frame, before any _process, as the engine's own events do.
func _send(e: InputEvent, frames := 2) -> void:
	await get_tree().process_frame
	Input.parse_input_event(e)
	Input.flush_buffered_events()
	for i in frames:
		await get_tree().process_frame


## The title's confirm: pressed and let go while no run is there (the title's fade lasts 0.45 s: many frames).
func _confirm_on_title(down: InputEvent, up: InputEvent) -> void:
	await _send(down, 3)
	await _send(up, 6)


## The run starts (Game._ready) with the paladin in a quiet room; then `frames` frames with no input.
func _start_run() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	_watch()


func _watch() -> void:
	game.player.runner.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
	game.player.dodged.connect(func(_d: Vector2) -> void: dodges += 1)


func _idle(frames := 20) -> void:
	for i in frames:
		await get_tree().process_frame


func _assert_still(how: String) -> void:
	assert_eq(started, [] as Array[StringName], "no move without a new press (%s)" % how)
	assert_eq(dodges, 0, "no dodge without a new press (%s)" % how)


func test_starting_from_the_title_with_the_mouse_plays_nothing() -> void:
	await _confirm_on_title(_mouse(true), _mouse(false))
	await _start_run()
	await _idle()
	_assert_still("mouse click on Iniciar")


func test_starting_from_the_title_with_the_keyboard_plays_nothing() -> void:
	# Enter and Space both confirm on the title; Space is also the dodge
	await _confirm_on_title(_key(KEY_ENTER, true), _key(KEY_ENTER, false))
	await _confirm_on_title(_key(KEY_SPACE, true), _key(KEY_SPACE, false))
	await _start_run()
	await _idle()
	_assert_still("Enter or Space on Iniciar")


func test_starting_from_the_title_with_a_gamepad_plays_nothing() -> void:
	await _confirm_on_title(_pad(JOY_BUTTON_A, true), _pad(JOY_BUTTON_A, false))
	# a player who confirms with the attack button of the pad
	await _confirm_on_title(_pad(JOY_BUTTON_X, true), _pad(JOY_BUTTON_X, false))
	await _start_run()
	await _idle()
	_assert_still("gamepad on Iniciar")


func test_a_button_still_down_when_the_run_starts_waits_for_its_release() -> void:
	# the click is still held when the run begins: nothing until it is let go, then a new click swings
	await _send(_mouse(true), 3)
	await _start_run()
	await _idle(10)
	_assert_still("held through the start")
	assert_false(Controls.held(&"light_attack"), "a held swallowed button charges nothing either")
	await _send(_mouse(false), 3)
	await _send(_mouse(true), 3)
	await _send(_mouse(false), 3)
	assert_eq(started.size(), 1, "a new click after the release swings once")


func test_picking_a_gift_with_the_mouse_or_space_plays_nothing() -> void:
	await _start_run()
	await _idle(5)
	for down: InputEvent in [_mouse(true), _key(KEY_SPACE, true)]:
		var offers: Array[Boon] = [game.boons.catalog[0]]
		game.call(&"_open_choice", offers)
		await _idle(3)
		assert_eq(game.mode, Game.Mode.CHOICE)
		# the card answers the press (in the same frame as the press)
		await get_tree().process_frame
		Input.parse_input_event(down)
		Input.flush_buffered_events()
		game.call(&"_on_chosen", offers[0])
		await _idle(4)
		var up := down.duplicate() as InputEvent
		up.set(&"pressed", false)
		await _send(up, 6)
		assert_eq(game.mode, Game.Mode.PLAY)
	_assert_still("a gift picked")


func test_leaving_the_pause_with_its_key_or_a_click_plays_nothing() -> void:
	await _start_run()
	await _idle(5)
	# Esc opens it and Esc closes it: the second Esc must not open it again, and nothing is swung
	await _send(_key(KEY_ESCAPE, true), 2)
	await _send(_key(KEY_ESCAPE, false), 3)
	assert_eq(game.mode, Game.Mode.PAUSE, "Esc opens the pause")
	await _send(_key(KEY_ESCAPE, true), 2)
	await _send(_key(KEY_ESCAPE, false), 3)
	assert_eq(game.mode, Game.Mode.PLAY, "Esc closes it and it stays closed")
	# Continuar clicked with the mouse
	game.call(&"_open_pause")
	await _idle(3)
	await get_tree().process_frame
	Input.parse_input_event(_mouse(true))
	Input.flush_buffered_events()
	(game.get(&"_screen") as PauseMenu).resumed.emit()
	await _idle(4)
	await _send(_mouse(false), 6)
	assert_eq(game.mode, Game.Mode.PLAY)
	_assert_still("the pause left")


## DV-1, MAP-03: the map opens and closes on its key (M, Back on the gamepad), closes on Esc too, and none of those
## presses (nor the click on the HUD's button, which is also the attack) reaches the run.
func test_the_map_opens_and_closes_without_a_swing() -> void:
	await _start_run()
	await _idle(5)
	for pair: Array in [[_key(KEY_M, true), _key(KEY_M, false)], [_pad(JOY_BUTTON_BACK, true), _pad(JOY_BUTTON_BACK, false)]]:
		await _send(pair[0], 2)
		await _send(pair[1], 3)
		assert_eq(game.mode, Game.Mode.CHOICE, "the map key opens the map")
		assert_true(game.get(&"_screen") is MapScreen)
		await _send(pair[0], 2)
		await _send(pair[1], 3)
		assert_eq(game.mode, Game.Mode.PLAY, "the map key closes it and it stays closed")
	# Esc closes it and does not open the pause
	await _send(_key(KEY_M, true), 2)
	await _send(_key(KEY_M, false), 3)
	await _send(_key(KEY_ESCAPE, true), 2)
	await _send(_key(KEY_ESCAPE, false), 3)
	assert_eq(game.mode, Game.Mode.PLAY, "Esc closes the map, no pause")
	# the HUD's button clicked with the mouse (the left button is the attack): opens on the press
	await get_tree().process_frame
	var click := _mouse(true) as InputEventMouseButton
	# the window's own pixels (the canvas is stretched to the window: tests run with a tiny one)
	var b := game.hud.map_button
	click.position = get_viewport().get_final_transform() * (b.get_global_transform_with_canvas() * (b.size * 0.5))
	Input.parse_input_event(click)
	Input.flush_buffered_events()
	await _idle(3)
	assert_eq(game.mode, Game.Mode.CHOICE, "the button opens the map")
	var up := click.duplicate() as InputEventMouseButton
	up.pressed = false
	await _send(up, 3)
	(game.get(&"_screen") as MapScreen).close()
	await _idle(6)
	assert_eq(game.mode, Game.Mode.PLAY)
	_assert_still("the map opened and closed")
