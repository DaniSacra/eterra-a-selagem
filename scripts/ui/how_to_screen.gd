class_name HowToScreen
extends Control
## "Como Jogar" (art pack board 10), one framed page with two tabs: "A descida" (a descent in three steps: the rooms and
## their doors, the Blessings they give, Morvath sealed at the end) and "Controles" (every action of the game with what
## is bound to it right now on the keyboard and mouse, remapped keys shown as remapped, and on the gamepad, read from
## the InputMap, and what it does). The game has one region, so there is no chapter to choose here. "Compêndio" opens the Codex
## (CodexScreen: Dons and Golpes). The credits are a text file next to the game (CREDITOS.txt), not a screen.
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
	{"id": "ultimate", "actions": [&"ultimate"]},
	{"id": "map", "actions": [&"map"]},
	{"id": "interact", "actions": [&"interact"]},
	{"id": "pause", "actions": [&"pause"]},
]
## Controls actions that are not for the player (the live tuning panel of debug builds).
const HIDDEN: Array[StringName] = [&"feel_panel"]

## The tabs: what a descent is (three steps) and the controls.
enum Tab { DESCENT, CONTROLS }

const TAB_KEY: Array[StringName] = [&"howto_tab_descent", &"options_tab_controls"]
const TAB_NAME: Array[String] = ["tab_descent", "tab_controls"]
## The steps of a descent (howto_step_<id>, howto_step_<id>_desc): the rooms, the Blessings, the Provação and the
## Altar (BUG-106: the events the PO did not understand in T5), Morvath.
const STEPS: Array[String] = ["rooms", "boons", "events", "seal"]
const WIDTH := 1100.0
const TAB_WIDTH := 200.0
const STEP_WIDTH := 236.0
const GLYPH := 76.0
## The page under the tabs is this tall (the controls fit it), so the tabs and the foot never move.
const PAGE_HEIGHT := 420.0

var tab := Tab.DESCENT
var tabs: Array[Button] = []
var pages: Array[Control] = []
var _page: Control
## The page open over this one (the Codex) and the button that opened it.
var _moves: Control
var _moves_button: Button
var _from: Button


func open() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_page = Control.new()
	_page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_page)
	var v := UiKit.page(_page, T.t(&"howto_title"), WIDTH, 0.8, 36)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 6)
	v.add_child(row)
	var holder := Control.new()
	holder.custom_minimum_size.y = PAGE_HEIGHT
	v.add_child(holder)
	for t: int in Tab.values():
		var b := UiKit.tab(T.t(TAB_KEY[t]), TAB_WIDTH)
		b.name = TAB_NAME[t]
		b.focus_entered.connect(_show_tab.bind(t))
		b.pressed.connect(_show_tab.bind(t))
		row.add_child(b)
		tabs.append(b)
	var descent := _descent()
	holder.add_child(descent)
	pages.append(descent)
	var controls := _controls()
	holder.add_child(controls)
	pages.append(controls)
	var bottom := UiKit.foot()
	v.add_child(bottom)
	_moves_button = UiKit.button(T.t(&"howto_moves"), _open_moves, 220)
	_moves_button.name = "moves"
	bottom.add_child(_moves_button)
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 220)
	back.name = "back"
	bottom.add_child(back)
	for b in tabs:
		b.focus_neighbor_bottom = b.get_path_to(back)
	for b: Button in [_moves_button, back]:
		b.focus_neighbor_top = b.get_path_to(tabs[0])
	_show_tab(Tab.DESCENT)
	tabs[0].grab_focus.call_deferred()


func _show_tab(t: int) -> void:
	tab = t as Tab
	for i in tabs.size():
		tabs[i].set_pressed_no_signal(i == t)
		pages[i].visible = i == t
	for b: Button in [_moves_button, find_child("back", true, false)]:
		if b:
			b.focus_neighbor_top = b.get_path_to(tabs[t])


## A descent in four steps, each with its sign: an open door (the rooms), a Blessing's medallion (what the rooms
## give), the Provação's cracked seal (the events on the way), the seal (Morvath at the end).
func _descent() -> Control:
	var page := CenterContainer.new()
	page.name = "page_descent"
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var steps := HBoxContainer.new()
	steps.add_theme_constant_override(&"separation", 20)
	page.add_child(steps)
	for i in STEPS.size():
		var id := STEPS[i]
		var col := VBoxContainer.new()
		col.name = "step_" + id
		col.custom_minimum_size.x = STEP_WIDTH
		col.add_theme_constant_override(&"separation", 10)
		steps.add_child(col)
		col.add_child(step_glyph(i))
		var head := UiKit.shadow(UiKit.label(T.t("howto_step_" + id), UiKit.GOLD, 22, UiKit.TITLE_FONT))
		head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		head.add_theme_constant_override(&"outline_size", 6)
		col.add_child(head)
		var rule := GoldRule.new()
		rule.custom_minimum_size = Vector2(STEP_WIDTH * 0.6, 12)
		rule.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		col.add_child(rule)
		var desc := UiKit.label(T.t("howto_step_%s_desc" % id), UiKit.PALE, 18)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.custom_minimum_size.x = STEP_WIDTH
		col.add_child(desc)
	return page


## The sign of a step of a descent (a door, a Blessing's medallion, the Provação's painted seal, the seal), side px
## across: here and on the opening page of the Livro de Ahk (HeroScreen).
static func step_glyph(step: int, side: float = GLYPH) -> Control:
	match step:
		0:
			var door := DoorMark.new()
			door.custom_minimum_size = Vector2(side, side)
			door.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			return door
		1:
			for b in BoonState.load_catalog():
				if not b.is_duo():
					var icon := BoonIcon.new().setup(b, side)
					icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
					return icon
		2:
			var tex := BoonArt.event(&"trial_seal")
			if tex != null:
				var art := BoonArt.rect(tex, side)
				art.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				return art
	return SealEmblem.new().setup(side)


## Every action with its keys, its gamepad button and what it does, and the tip under them.
func _controls() -> Control:
	var page := VBoxContainer.new()
	page.name = "page_controls"
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override(&"separation", 8)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override(&"h_separation", 18)
	grid.add_theme_constant_override(&"v_separation", 5)
	page.add_child(grid)
	for head: StringName in [&"howto_col_action", &"howto_col_keys", &"howto_col_pad", &""]:
		grid.add_child(UiKit.label(T.t(head) if head != &"" else "", UiKit.OLD_GOLD.lightened(0.35), 17, UiKit.BOLD_FONT))
	for row in ROWS:
		var id: String = row.id
		var actions: Array = row.actions
		grid.add_child(_cell(T.t("howto_" + id), UiKit.PALE, 19, UiKit.BOLD_FONT, 150.0))
		var keys := _cell(keys_label(actions) if not actions.is_empty() else T.t(&"mouse_aim"), UiKit.GOLD, 19, UiKit.BOLD_FONT, 150.0)
		keys.name = "keys_" + id
		grid.add_child(keys)
		var pad := _cell(pad_label(actions) if not actions.is_empty() else T.t(&"pad_stick_right"), UiKit.GOLD, 19, UiKit.BOLD_FONT, 160.0)
		pad.name = "pad_" + id
		grid.add_child(pad)
		var desc := _cell(T.t("howto_%s_desc" % id), UiKit.PALE, 17, null, 540.0)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(desc)
	var tip := UiKit.label(T.t(&"howto_tip"), UiKit.DIM.lightened(0.1), 17)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(tip)
	return page


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
	_open_sub(CodexScreen.new(), _moves_button)


func _open_sub(screen: Control, from: Button) -> void:
	_page.visible = false
	_moves = screen
	_from = from
	add_child(screen)
	screen.call(&"open")
	screen.connect(&"closed", _close_moves)


func _close_moves() -> void:
	if _moves == null:
		return
	_moves.queue_free()
	_moves = null
	_page.visible = true
	_from.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _moves != null and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_moves()
	elif _moves == null and UiKit.step_tabs(event, tabs, tab):
		get_viewport().set_input_as_handled()


## An open door under a pointed arch, in old gold over ink: the rooms of a descent (Como Jogar).
class DoorMark:
	extends Control

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _arch(c: Vector2, w: float, h: float, spring: float) -> PackedVector2Array:
		# a pointed arch: two straight jambs up to the spring, two arcs meeting at the top
		var pts := PackedVector2Array()
		pts.append(c + Vector2(-w, h))
		pts.append(c + Vector2(-w, spring))
		for i in 9:
			var a := float(i) / 8.0
			pts.append(c + Vector2(-w + w * a, spring - (h * 0.95 + spring) * sin(a * PI * 0.5)))
		for i in range(1, 9):
			var a := 1.0 - float(i) / 8.0
			pts.append(c + Vector2(w - w * a, spring - (h * 0.95 + spring) * sin(a * PI * 0.5)))
		pts.append(c + Vector2(w, spring))
		pts.append(c + Vector2(w, h))
		return pts

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.5
		draw_circle(c, r - 1.0, SealEmblem.INK)
		draw_arc(c, r - 3.0, 0.0, TAU, 96, UiKit.OLD_GOLD, maxf(2.0, r * 0.07), true)
		var outer := _arch(c + Vector2(0, r * 0.08), r * 0.42, r * 0.5, -r * 0.05)
		draw_colored_polygon(outer, UiKit.OLD_GOLD.lerp(UiKit.GOLD, 0.3))
		# the doorway open on a warm light
		var inner := _arch(c + Vector2(0, r * 0.14), r * 0.3, r * 0.44, 0.0)
		draw_colored_polygon(inner, Color(0.98, 0.8, 0.5))
		var deep := _arch(c + Vector2(0, r * 0.3), r * 0.18, r * 0.28, 0.0)
		draw_colored_polygon(deep, Color(1.0, 0.93, 0.78))
		# the step under the door
		draw_rect(Rect2(c + Vector2(-r * 0.55, r * 0.56), Vector2(r * 1.1, r * 0.08)), UiKit.OLD_GOLD)
