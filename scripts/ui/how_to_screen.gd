class_name HowToScreen
extends Control
## "Como Jogar": every action of the game with what is bound to it right now on the keyboard and mouse (remapped keys
## show as remapped) and on the gamepad (read from the InputMap), and what it does. "Compêndio" opens the Codex
## (CodexScreen: Dons and Golpes).
## The caller closes this screen on ui_cancel, like the others; while the combo list is open this screen takes
## ui_cancel itself and goes back to its own page.

signal closed

## One row per thing the player does: the text id (howto_<id>, howto_<id>_desc) and the Controls actions behind it.
## "aim" has no action: the mouse pointer or the right stick (Controls.aim).
const ROWS: Array[Dictionary] = [
	{"id": "move", "actions": [&"move_up", &"move_left", &"move_down", &"move_right"]},
	{"id": "aim", "actions": []},
	{"id": "light_attack", "actions": [&"light_attack"]},
	{"id": "heavy_attack", "actions": [&"heavy_attack"]},
	{"id": "cast", "actions": [&"cast"]},
	{"id": "dodge", "actions": [&"dodge"]},
	{"id": "pause", "actions": [&"pause"]},
]
## Controls actions that are not for the player (the live tuning panel of debug builds).
const HIDDEN: Array[StringName] = [&"feel_panel"]

var _page: Control
var _moves: CodexScreen
var _moves_button: Button


func open() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_page = Control.new()
	_page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_page)
	var v := UiKit.column(_page, 1100.0, 0.8)
	v.add_child(UiKit.title(T.t(&"howto_title"), 40))
	var panel := PanelContainer.new()
	v.add_child(panel)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override(&"h_separation", 22)
	grid.add_theme_constant_override(&"v_separation", 10)
	panel.add_child(grid)
	for head: StringName in [&"howto_col_action", &"howto_col_keys", &"howto_col_pad", &""]:
		grid.add_child(UiKit.label(T.t(head) if head != &"" else "", UiKit.DIM, 18, UiKit.BOLD_FONT))
	for row in ROWS:
		var id: String = row.id
		var actions: Array = row.actions
		grid.add_child(_cell(T.t("howto_" + id), UiKit.PALE, 21, UiKit.BOLD_FONT, 170.0))
		var keys := _cell(keys_label(actions) if not actions.is_empty() else T.t(&"mouse_aim"), UiKit.GOLD, 21, UiKit.BOLD_FONT, 170.0)
		keys.name = "keys_" + id
		grid.add_child(keys)
		var pad := _cell(pad_label(actions) if not actions.is_empty() else T.t(&"pad_stick_right"), UiKit.GOLD, 21, UiKit.BOLD_FONT, 170.0)
		pad.name = "pad_" + id
		grid.add_child(pad)
		var desc := _cell(T.t("howto_%s_desc" % id), UiKit.PALE, 19, null, 520.0)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(desc)
	var tip := UiKit.label(T.t(&"howto_tip"), UiKit.DIM, 19)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(tip)
	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(bottom)
	_moves_button = UiKit.button(T.t(&"howto_moves"), _open_moves, 220)
	_moves_button.name = "moves"
	bottom.add_child(_moves_button)
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 220)
	back.name = "back"
	bottom.add_child(back)
	back.grab_focus.call_deferred()


func _cell(text: String, color: Color, size: int, font: Font, width: float) -> Label:
	var l := UiKit.label(text, color, size, font)
	l.custom_minimum_size.x = width
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l


## What the keyboard and mouse have on these actions now ("W A S D", "Mouse esq."), whatever device is in use.
static func keys_label(actions: Array) -> String:
	var was := Controls.using_pad
	Controls.using_pad = false
	var parts: PackedStringArray = []
	for action: StringName in actions:
		parts.append(UiKit.action_label(action))
	Controls.using_pad = was
	return " ".join(parts)


## What the gamepad has on these actions: its button (Controls.label) or, for movement, the stick of its axis events.
static func pad_label(actions: Array) -> String:
	var was := Controls.using_pad
	Controls.using_pad = true
	var parts: PackedStringArray = []
	for action: StringName in actions:
		var text := Controls.label(action)
		if text == "?":
			text = _stick_label(action)
		if text != "" and not parts.has(text):
			parts.append(text)
	Controls.using_pad = was
	return " ".join(parts) if not parts.is_empty() else "?"


static func _stick_label(action: StringName) -> String:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadMotion:
			var axis := (ev as InputEventJoypadMotion).axis
			if axis == JOY_AXIS_LEFT_X or axis == JOY_AXIS_LEFT_Y:
				return T.t(&"pad_stick_left")
			if axis == JOY_AXIS_RIGHT_X or axis == JOY_AXIS_RIGHT_Y:
				return T.t(&"pad_stick_right")
	return ""


func _open_moves() -> void:
	_page.visible = false
	_moves = CodexScreen.new()
	add_child(_moves)
	_moves.open()
	_moves.closed.connect(_close_moves)


func _close_moves() -> void:
	if _moves == null:
		return
	_moves.queue_free()
	_moves = null
	_page.visible = true
	_moves_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _moves != null and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_moves()
