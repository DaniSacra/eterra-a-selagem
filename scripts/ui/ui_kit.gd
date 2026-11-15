class_name UiKit
extends RefCounted
## One look for every screen: Cinzel for titles, Alegreya Sans for text, dark panels with a thin gold edge.

const TITLE_FONT: Font = preload("res://assets/fonts/Cinzel.ttf")
const TEXT_FONT: Font = preload("res://assets/fonts/AlegreyaSans-Regular.ttf")
const BOLD_FONT: Font = preload("res://assets/fonts/AlegreyaSans-Bold.ttf")
const GOLD := Color(0.96, 0.8, 0.45)
const PALE := Color(0.94, 0.9, 0.82)
const DIM := Color(0.66, 0.62, 0.7)
const RED := Color(0.86, 0.2, 0.18)
const PANEL := Color(0.055, 0.04, 0.075, 0.94)
const EDGE := Color(0.72, 0.56, 0.3)
## The HUD's palette (cycle 5): frames in ink with a line of old gold, empty glyphs in parchment.
const INK := Color("0c0a0e")
const OLD_GOLD := Color("8e7444")
const PARCHMENT := Color("d8c8a8")

static var _theme: Theme


static func theme() -> Theme:
	if _theme != null:
		return _theme
	var t := Theme.new()
	t.default_font = TEXT_FONT
	t.default_font_size = 22
	t.set_stylebox(&"normal", &"Button", box(Color(0.08, 0.06, 0.1, 0.9), Color(0.4, 0.32, 0.22), 1, 10))
	t.set_stylebox(&"hover", &"Button", box(Color(0.16, 0.11, 0.08, 0.95), GOLD, 2, 10))
	t.set_stylebox(&"pressed", &"Button", box(Color(0.22, 0.15, 0.08, 0.95), GOLD, 2, 10))
	t.set_stylebox(&"disabled", &"Button", box(Color(0.06, 0.05, 0.07, 0.8), Color(0.25, 0.22, 0.25), 1, 10))
	t.set_stylebox(&"focus", &"Button", box(Color(0.16, 0.11, 0.08, 0.95), GOLD, 2, 10))
	t.set_font(&"font", &"Button", BOLD_FONT)
	t.set_color(&"font_color", &"Button", PALE)
	t.set_color(&"font_hover_color", &"Button", GOLD)
	t.set_color(&"font_focus_color", &"Button", GOLD)
	t.set_color(&"font_pressed_color", &"Button", GOLD)
	t.set_color(&"font_disabled_color", &"Button", DIM)
	t.set_stylebox(&"panel", &"PanelContainer", box(PANEL, EDGE, 1, 18))
	t.set_color(&"font_color", &"Label", PALE)
	t.set_color(&"font_outline_color", &"Label", Color(0.02, 0.01, 0.03))
	t.set_constant(&"outline_size", &"Label", 4)
	t.set_constant(&"separation", &"VBoxContainer", 8)
	t.set_constant(&"separation", &"HBoxContainer", 10)
	_theme = t
	return t


static func box(bg: Color, border: Color, width: int = 1, margin: int = 8, radius: int = 4) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(width)
	s.set_content_margin_all(margin)
	s.set_corner_radius_all(radius)
	return s


static func label(text: String, color: Color = PALE, size: int = 22, font: Font = null) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override(&"font_color", color)
	l.add_theme_font_size_override(&"font_size", size)
	if font:
		l.add_theme_font_override(&"font", font)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func title(text: String, size: int = 44, color: Color = GOLD) -> Label:
	var l := label(text, color, size, TITLE_FONT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_constant_override(&"outline_size", 8)
	return l


## A button that takes focus when the mouse touches it, so mouse, keys and gamepad always agree.
static func button(text: String, on_press: Callable = Callable(), width: float = 320.0) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(width, 48)
	b.add_theme_font_size_override(&"font_size", 22)
	b.mouse_entered.connect(func() -> void:
		if not b.has_focus():
			b.grab_focus())
	b.focus_entered.connect(func() -> void: Audio.play(&"ui_move"))
	if on_press.is_valid():
		b.pressed.connect(func() -> void:
			Audio.play(&"ui_ok")
			on_press.call())
	return b


## A centred column on a dimmed full screen.
static func column(parent: Control, width: float, dim: float = 0.6) -> VBoxContainer:
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.0, 0.02, dim)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)
	var box_ := VBoxContainer.new()
	box_.custom_minimum_size.x = width
	box_.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(box_)
	return box_


static func format_number(v: float) -> String:
	if is_equal_approx(v, roundf(v)):
		return str(roundi(v))
	return ("%.1f" % v).replace(".", ",")


## Label of the key or button of an action, with every gamepad button named (Controls.label names only A, B, X, Y).
static func action_label(action: StringName) -> String:
	var label := Controls.label(action)
	# key names come from the system in English ("Space"); the common ones have a Portuguese name
	return T.t("key_" + label) if T.table.entries.has("key_" + label) else label


## The mouse button bound to an action (0 when it is a key, or the gamepad is in use): the HUD draws a mouse for it.
static func action_mouse_button(action: StringName) -> int:
	if Controls.using_pad:
		return 0
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return 0
		if ev is InputEventMouseButton:
			return (ev as InputEventMouseButton).button_index
	return 0
