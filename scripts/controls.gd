extends Node
## Autoload "Controls": the game never reads a key directly, only these actions.
## Keyboard and mouse, gamepad and (later, on phones) on-screen buttons all feed the same actions.

## The player went from keys and mouse to a gamepad (pad true) or back.
signal device_changed(pad: bool)

const ACTIONS: Array[StringName] = [&"move_left", &"move_right", &"move_up", &"move_down", &"light_attack", &"heavy_attack", &"dodge", &"cast", &"shout", &"rush", &"ultimate", &"interact", &"pause", &"feel_panel"]
## Actions the player may rebind in Options.
## interact (HUB-B1): use the station in focus in the hub (F since 2026-11-21, A on the gamepad); in a descent (C19, Q-13)
## take the reward, buy a shop's item, walk through a door. shout (2026-11-21): the Warrior's Brado de Guerra on Q (RB on
## the gamepad); rush: his Investida on E (R3); the ultimate on Shift. The circle (cast) has no key now: it left the
## Warrior's kit (the Paladin's later), so it is not remappable.
const REMAPPABLE: Array[StringName] = [&"move_up", &"move_down", &"move_left", &"move_right", &"light_attack", &"heavy_attack", &"dodge", &"shout", &"rush", &"ultimate", &"interact"]
const DEFAULT_KEYS := {
	&"move_left": [KEY_A, KEY_LEFT], &"move_right": [KEY_D, KEY_RIGHT], &"move_up": [KEY_W, KEY_UP], &"move_down": [KEY_S, KEY_DOWN],
	&"dodge": [KEY_SPACE], &"shout": [KEY_Q], &"rush": [KEY_E], &"ultimate": [KEY_SHIFT], &"interact": [KEY_F], &"pause": [KEY_ESCAPE, KEY_P],
	# debug builds only: the live tuning panel (scripts/ui/feel_panel.gd)
	&"feel_panel": [KEY_F1],
}
const DEFAULT_MOUSE := {&"light_attack": MOUSE_BUTTON_LEFT, &"heavy_attack": MOUSE_BUTTON_RIGHT}
## A save from before an action may have given its default key to another one (HUB-B1: E was free before interact and
## could be a blow's; 2026-11-21: E, F and Shift changed hands): an action listed here then takes the first of these no
## saved binding holds (keys_for). A saved binding is only the keys the player changed, so an old save with nothing
## remapped simply reads the new defaults, and one that remapped something keeps it (a key two actions would share goes
## to the spare, never to both).
const SPARE_KEYS := {&"interact": [KEY_G, KEY_T, KEY_B, KEY_N], &"shout": [KEY_Z, KEY_C, KEY_V, KEY_B], &"rush": [KEY_Z, KEY_C, KEY_V, KEY_B], &"ultimate": [KEY_X, KEY_C, KEY_V, KEY_B]}
const DEFAULT_PAD := {&"interact": JOY_BUTTON_A, &"light_attack": JOY_BUTTON_X, &"heavy_attack": JOY_BUTTON_Y, &"dodge": JOY_BUTTON_B, &"shout": JOY_BUTTON_RIGHT_SHOULDER, &"rush": JOY_BUTTON_RIGHT_STICK, &"ultimate": JOY_BUTTON_LEFT_SHOULDER, &"pause": JOY_BUTTON_START}
const PAD_AXES := {&"move_left": [JOY_AXIS_LEFT_X, -1.0], &"move_right": [JOY_AXIS_LEFT_X, 1.0], &"move_up": [JOY_AXIS_LEFT_Y, -1.0], &"move_down": [JOY_AXIS_LEFT_Y, 1.0]}
const STICK_DEADZONE := 0.3
## Menu actions, never rebound: LB and RB (PageUp and PageDown on the keyboard) step through a screen's tabs
## (Configurações, Como Jogar, the Livro's chapters, the Compendium's index; DT-103, UiKit.step_tabs).
## The actions whose gamepad button the player may change (DT-103): those with a button, not the stick's walking.
const PAD_REMAPPABLE: Array[StringName] = [&"light_attack", &"heavy_attack", &"dodge", &"shout", &"rush", &"ultimate", &"interact"]
## The gamepad's buttons of Godot's menu actions (confirm, back).
const MENU_BUTTONS := {&"ui_accept": JOY_BUTTON_A, &"ui_cancel": JOY_BUTTON_B}
## Where a gamepad binding is kept in the saved bindings (beside the key bindings, which use the action's own name).
const PAD_PREFIX := "pad:"
## menu_reroll: Y (R on the keyboard) draws the Blessings' cards again (Discernimento I, BoonChoice), only on a menu
## (R is only this now: the ultimate is on Shift).
const MENU_KEYS := {&"tab_prev": [JOY_BUTTON_LEFT_SHOULDER, KEY_PAGEUP], &"tab_next": [JOY_BUTTON_RIGHT_SHOULDER, KEY_PAGEDOWN],
	&"menu_reroll": [JOY_BUTTON_Y, KEY_R]}

## The last device touched was a gamepad (device_changed when it flips, for hints that name the keys live).
var using_pad := false:
	set(v):
		if v != using_pad:
			using_pad = v
			device_changed.emit(v)
## Which devices were touched since forget_devices() (the run's log: RunLog.device).
var seen_keys := false
var seen_pad := false
## Set by the test bot (or, later, touch buttons): overrides the devices while not null.
var virtual: VirtualPad = null
var _last_aim := Vector2.RIGHT
## Presses seen since the game last stepped (kept through hit stop frames, cleared by flush()).
var _latched: Dictionary = {}
## The same for the virtual pad (the bot, touch): its taps last one frame, so a frame the game did not step keeps
## them here until it does (GF-06; Game calls latch_virtual).
var _pad_latched: Dictionary = {}
## Actions whose button was down when the presses were last cleared (clear_presses): they count again only once that
## button has been let go, so a click or a key that closed a screen (the title's Iniciar, a gift card, the pause)
## never reaches the run as a swing or a dodge (E1c, bug 1).
var _swallowed: Dictionary = {}


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
			for key: Key in keys_for(action, saved):
				var ev := InputEventKey.new()
				ev.physical_keycode = key
				InputMap.action_add_event(action, ev)
			if DEFAULT_MOUSE.has(action):
				var mb := InputEventMouseButton.new()
				mb.button_index = DEFAULT_MOUSE[action]
				InputMap.action_add_event(action, mb)
		var button := pad_button_for(action, saved)
		if button >= 0:
			var jb := InputEventJoypadButton.new()
			jb.button_index = button as JoyButton
			InputMap.action_add_event(action, jb)
		if PAD_AXES.has(action):
			var jm := InputEventJoypadMotion.new()
			jm.axis = PAD_AXES[action][0]
			jm.axis_value = PAD_AXES[action][1]
			InputMap.action_add_event(action, jm)
	# Godot's own menu actions have no gamepad button in this project's map: A confirms and B goes back (DT-103), as
	# UiKit.MENU_PAD and the action bar say
	for action: StringName in MENU_BUTTONS:
		if not InputMap.has_action(action):
			continue
		var has := InputMap.action_get_events(action).any(func(ev: InputEvent) -> bool:
			return ev is InputEventJoypadButton and (ev as InputEventJoypadButton).button_index == MENU_BUTTONS[action])
		if not has:
			var jb := InputEventJoypadButton.new()
			jb.button_index = MENU_BUTTONS[action]
			InputMap.action_add_event(action, jb)
	for action: StringName in MENU_KEYS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		InputMap.add_action(action)
		var jb := InputEventJoypadButton.new()
		jb.button_index = MENU_KEYS[action][0]
		InputMap.action_add_event(action, jb)
		var key := InputEventKey.new()
		key.physical_keycode = MENU_KEYS[action][1]
		InputMap.action_add_event(action, key)


## The default keys of an action not rebound, given the saved bindings: its own (DEFAULT_KEYS), or, when a saved
## binding of another action holds all of them and it has spares (SPARE_KEYS), the first spare no saved binding holds.
static func keys_for(action: StringName, saved: Dictionary) -> Array:
	var own: Array = DEFAULT_KEYS.get(action, [])
	if not SPARE_KEYS.has(action):
		return own
	var taken := {}
	for other: String in saved:
		# (an action the game no longer has, as the map's of an old save, holds no key)
		if not saved[other] is Dictionary or not ACTIONS.has(StringName(other)):
			continue
		var entry: Dictionary = saved[other]
		if other != String(action) and entry.get("type", "key") == "key":
			taken[int(entry.get("code", 0))] = true
	# (BH-7) the actions listed before it that fall back on a spare hold theirs
	for before: StringName in SPARE_KEYS:
		if before == action:
			break
		if not saved.has(String(before)):
			for k in keys_for(before, saved):
				taken[int(k)] = true
	var free := own.filter(func(k: Key) -> bool: return not taken.has(int(k)))
	if not free.is_empty():
		return free
	for k: Key in SPARE_KEYS[action]:
		if not taken.has(int(k)):
			return [k]
	return own


## The gamepad button of an action given the saved bindings: the player's own ("pad:<action>", DT-103), else its
## default (DEFAULT_PAD), -1 for none.
static func pad_button_for(action: StringName, saved: Dictionary) -> int:
	var own: Variant = saved.get(PAD_PREFIX + String(action))
	if own is Dictionary and (own as Dictionary).get("type") == "pad":
		return int((own as Dictionary).get("code", -1))
	return int(DEFAULT_PAD.get(action, -1))


## Stores a gamepad button as an action's button (DT-103: remapping on the gamepad, from the Configurações). Only the
## actions with a button (PAD_REMAPPABLE; walking stays on the stick). A button another of them has is swapped: that
## action takes this one's old button. Returns false for anything else.
func rebind_pad(action: StringName, event: InputEvent) -> bool:
	var jb := event as InputEventJoypadButton
	if jb == null or not PAD_REMAPPABLE.has(action):
		return false
	var saved: Dictionary = Save.option("bindings")
	var was := pad_button_for(action, saved)
	var button := int(jb.button_index)
	for other in PAD_REMAPPABLE:
		if other != action and pad_button_for(other, saved) == button:
			saved[PAD_PREFIX + String(other)] = {"type": "pad", "code": was}
	saved[PAD_PREFIX + String(action)] = {"type": "pad", "code": button}
	Save.set_option("bindings", saved)
	apply_bindings()
	return true


## A binding as the save keeps it ({type: key or mouse, code}), or empty for an event that cannot be bound.
static func entry_of(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		return {"type": "key", "code": int((event as InputEventKey).physical_keycode)}
	if event is InputEventMouseButton:
		return {"type": "mouse", "code": int((event as InputEventMouseButton).button_index)}
	return {}


## Stores a key or mouse button as the binding of an action. Returns false for events that cannot be bound.
## A key (or button) another rebindable action already uses is swapped: that action takes this one's old key, so no
## two actions share one (HUB-B1: interact and the blows or the dodge never fight over E or Space).
func rebind(action: StringName, event: InputEvent) -> bool:
	var entry := entry_of(event)
	if entry.is_empty():
		return false
	var saved: Dictionary = Save.option("bindings")
	var was := _first_bound(action)
	for other in REMAPPABLE:
		if other != action and _bound_to(other).has(entry):
			if was.is_empty():
				saved.erase(String(other))
			else:
				saved[String(other)] = was
	saved[String(action)] = entry
	Save.set_option("bindings", saved)
	apply_bindings()
	return true


## Every key and mouse button an action has now (as save entries).
func _bound_to(action: StringName) -> Array:
	var out: Array = []
	for ev in InputMap.action_get_events(action):
		var entry := entry_of(ev)
		if not entry.is_empty():
			out.append(entry)
	return out


## The first key or mouse button an action has now (empty: none).
func _first_bound(action: StringName) -> Dictionary:
	var all := _bound_to(action)
	return all[0] if not all.is_empty() else {}


func reset_bindings() -> void:
	Save.set_option("bindings", {})
	apply_bindings()


## Label of what is bound to an action on the device in use ("Espaço", "Mouse esq.", "B").
func label(action: StringName) -> String:
	for ev in InputMap.action_get_events(action):
		if using_pad and ev is InputEventJoypadButton:
			return T.t("pad_%d" % (ev as InputEventJoypadButton).button_index)
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
	for action: StringName in _swallowed.keys():
		if not Input.is_action_pressed(action):
			_swallowed.erase(action)
	for action in ACTIONS:
		if Input.is_action_just_pressed(action) and not _swallowed.has(action):
			_latched[action] = true


## Forgets every press so far and swallows the buttons still down until they are let go: called when the run begins
## and when a screen over it closes (the gift, the pause), so the press that got there plays nothing (E1c, bug 1:
## the click on Iniciar was latched on the title, where nothing flushes, and the run opened on a swing). The virtual
## pad (the bot, touch) only loses its kept taps: its held buttons are its own.
func clear_presses() -> void:
	_latched.clear()
	_pad_latched.clear()
	_swallowed.clear()
	for action in ACTIONS:
		if Input.is_action_pressed(action):
			_swallowed[action] = true


## The game stepped: presses so far have been seen.
func flush() -> void:
	_latched.clear()
	_pad_latched.clear()


## The game did not step this frame: the virtual pad's taps are kept for the next step (as the keyboard's are).
func latch_virtual() -> void:
	if virtual:
		for action: StringName in virtual.tapped:
			_pad_latched[action] = true


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > STICK_DEADZONE):
		using_pad = true
		seen_pad = true
	elif event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		using_pad = false
		seen_keys = seen_keys or not event is InputEventMouseMotion


## Starts counting the devices anew (a run begins).
func forget_devices() -> void:
	seen_keys = false
	seen_pad = false


func move() -> Vector2:
	if virtual:
		return virtual.move.limit_length(1.0)
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


func pressed(action: StringName) -> bool:
	if virtual:
		return virtual.tapped.has(action) or _pad_latched.has(action)
	if _swallowed.has(action):
		return false
	return _latched.has(action) or Input.is_action_just_pressed(action)


func released(action: StringName) -> bool:
	if virtual:
		return virtual.released.has(action)
	return Input.is_action_just_released(action)


func held(action: StringName) -> bool:
	if virtual:
		return virtual.held.has(action)
	return Input.is_action_pressed(action) and not _swallowed.has(action)


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
