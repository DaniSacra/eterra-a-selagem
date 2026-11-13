extends Node
## Autoload "Controls": the game never reads a key directly, only these actions.
## Keyboard and mouse, gamepad and (later, on phones) on-screen buttons all feed the same actions.

const ACTIONS: Array[StringName] = [&"move_left", &"move_right", &"move_up", &"move_down", &"light_attack", &"heavy_attack", &"dodge", &"pause"]
## Actions the player may rebind in Options.
const REMAPPABLE: Array[StringName] = [&"move_up", &"move_down", &"move_left", &"move_right", &"light_attack", &"heavy_attack", &"dodge"]
const DEFAULT_KEYS := {
	&"move_left": [KEY_A, KEY_LEFT], &"move_right": [KEY_D, KEY_RIGHT], &"move_up": [KEY_W, KEY_UP], &"move_down": [KEY_S, KEY_DOWN],
	&"dodge": [KEY_SPACE], &"pause": [KEY_ESCAPE, KEY_P],
}
const DEFAULT_MOUSE := {&"light_attack": MOUSE_BUTTON_LEFT, &"heavy_attack": MOUSE_BUTTON_RIGHT}
const DEFAULT_PAD := {&"light_attack": JOY_BUTTON_X, &"heavy_attack": JOY_BUTTON_Y, &"dodge": JOY_BUTTON_B, &"pause": JOY_BUTTON_START}
const PAD_AXES := {&"move_left": [JOY_AXIS_LEFT_X, -1.0], &"move_right": [JOY_AXIS_LEFT_X, 1.0], &"move_up": [JOY_AXIS_LEFT_Y, -1.0], &"move_down": [JOY_AXIS_LEFT_Y, 1.0]}
const STICK_DEADZONE := 0.3

var using_pad := false
## Set by the test bot (or, later, touch buttons): overrides the devices while not null.
var virtual: VirtualPad = null
var _last_aim := Vector2.RIGHT
## Presses seen since the game last stepped (kept through hit stop frames, cleared by flush()).
var _latched: Dictionary = {}


class VirtualPad:
	var move := Vector2.ZERO
	var aim := Vector2.RIGHT
	var held: Dictionary = {}
	var tapped: Dictionary = {}
	var released: Dictionary = {}

	func press(action: StringName) -> void:
		if not held.has(action):
			tapped[action] = true
		held[action] = true

	func release(action: StringName) -> void:
		if held.has(action):
			released[action] = true
		held.erase(action)

	func end_frame() -> void:
		tapped.clear()
		released.clear()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	apply_bindings()


## Rebuilds the InputMap from the defaults plus the player's saved bindings.
func apply_bindings() -> void:
	var saved: Dictionary = Save.option("bindings")
	for action in ACTIONS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		InputMap.add_action(action, STICK_DEADZONE)
		if saved.has(String(action)):
			InputMap.action_add_event(action, _event_from(saved[String(action)]))
		else:
			for key: Key in DEFAULT_KEYS.get(action, []):
				var ev := InputEventKey.new()
				ev.physical_keycode = key
				InputMap.action_add_event(action, ev)
			if DEFAULT_MOUSE.has(action):
				var mb := InputEventMouseButton.new()
				mb.button_index = DEFAULT_MOUSE[action]
				InputMap.action_add_event(action, mb)
		if DEFAULT_PAD.has(action):
			var jb := InputEventJoypadButton.new()
			jb.button_index = DEFAULT_PAD[action]
			InputMap.action_add_event(action, jb)
		if PAD_AXES.has(action):
			var jm := InputEventJoypadMotion.new()
			jm.axis = PAD_AXES[action][0]
			jm.axis_value = PAD_AXES[action][1]
			InputMap.action_add_event(action, jm)


## Stores a key or mouse button as the binding of an action. Returns false for events that cannot be bound.
func rebind(action: StringName, event: InputEvent) -> bool:
	var entry := {}
	if event is InputEventKey:
		entry = {"type": "key", "code": (event as InputEventKey).physical_keycode}
	elif event is InputEventMouseButton:
		entry = {"type": "mouse", "code": (event as InputEventMouseButton).button_index}
	else:
		return false
	var saved: Dictionary = Save.option("bindings")
	saved[String(action)] = entry
	Save.set_option("bindings", saved)
	apply_bindings()
	return true


func reset_bindings() -> void:
	Save.set_option("bindings", {})
	apply_bindings()


## Label of what is bound to an action on the device in use ("Espaço", "Mouse esq.", "B").
func label(action: StringName) -> String:
	for ev in InputMap.action_get_events(action):
		if using_pad and ev is InputEventJoypadButton:
			return ["A", "B", "X", "Y"][(ev as InputEventJoypadButton).button_index] if (ev as InputEventJoypadButton).button_index < 4 else "Start"
		if not using_pad and ev is InputEventKey:
			return OS.get_keycode_string((ev as InputEventKey).physical_keycode)
		if not using_pad and ev is InputEventMouseButton:
			return T.t("mouse_%d" % (ev as InputEventMouseButton).button_index)
	return "?"


func _event_from(entry: Dictionary) -> InputEvent:
	if entry.get("type") == "mouse":
		var mb := InputEventMouseButton.new()
		mb.button_index = int(entry.code) as MouseButton
		return mb
	var ev := InputEventKey.new()
	ev.physical_keycode = int(entry.get("code", KEY_SPACE)) as Key
	return ev


func _process(_delta: float) -> void:
	for action in ACTIONS:
		if Input.is_action_just_pressed(action):
			_latched[action] = true


## The game stepped: presses so far have been seen.
func flush() -> void:
	_latched.clear()


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > STICK_DEADZONE):
		using_pad = true
	elif event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		using_pad = false


func move() -> Vector2:
	if virtual:
		return virtual.move.limit_length(1.0)
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


func pressed(action: StringName) -> bool:
	if virtual:
		return virtual.tapped.has(action)
	return _latched.has(action) or Input.is_action_just_pressed(action)


func released(action: StringName) -> bool:
	if virtual:
		return virtual.released.has(action)
	return Input.is_action_just_released(action)


func held(action: StringName) -> bool:
	if virtual:
		return virtual.held.has(action)
	return Input.is_action_pressed(action)


## True when the aim comes from the mouse pointer (no soft lock then: the player points exactly).
func aims_with_mouse() -> bool:
	return virtual == null and not using_pad


## Aim direction for someone standing at a screen position: the mouse, or the right stick.
func aim(from_screen: Vector2, mouse_screen: Vector2) -> Vector2:
	if virtual:
		_last_aim = virtual.aim.normalized() if virtual.aim.length() > 0.01 else _last_aim
	elif using_pad:
		var stick := Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		if stick.length() > STICK_DEADZONE:
			_last_aim = stick.normalized()
		elif move().length() > STICK_DEADZONE:
			_last_aim = move().normalized()
	else:
		var d := mouse_screen - from_screen
		if d.length() > 1.0:
			_last_aim = d.normalized()
	return _last_aim
