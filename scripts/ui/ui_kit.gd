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
## Every frame of the HUD (portrait ring, action diamonds, bars, key plates) is one line of OLD_GOLD this wide, in
## pixels at 720 lines, over ink.
const FRAME := 2.0
## The dark shadow under every text of the HUD, so pale letters hold over a lit floor: this far down, this soft.
const SHADOW := Color(0.047, 0.039, 0.055, 0.6)
const SHADOW_DROP := 2
const SHADOW_SPREAD := 6

static var _theme: Theme
static var _number_font: FontVariation


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


## Gives a label the HUD's text shadow (on top of the theme's thin outline).
static func shadow(l: Label) -> Label:
	l.add_theme_color_override(&"font_shadow_color", SHADOW)
	l.add_theme_constant_override(&"shadow_offset_x", 0)
	l.add_theme_constant_override(&"shadow_offset_y", SHADOW_DROP)
	l.add_theme_constant_override(&"shadow_outline_size", SHADOW_SPREAD)
	return l


## The same shadow for text drawn by hand in a _draw: call it before draw_string, with the same arguments.
static func draw_shadow(ci: CanvasItem, font: Font, at: Vector2, text: String, size: int) -> void:
	ci.draw_string_outline(font, at + Vector2(0, SHADOW_DROP), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, SHADOW_SPREAD, SHADOW)


## The bold text font with lining, fixed-width figures: Alegreya's own figures are old style (as low as the small
## letters), too small to read on the bars.
static func number_font() -> Font:
	if _number_font == null:
		var ts := TextServerManager.get_primary_interface()
		_number_font = FontVariation.new()
		_number_font.base_font = BOLD_FONT
		_number_font.opentype_features = {ts.name_to_tag("lnum"): 1, ts.name_to_tag("tnum"): 1}
	return _number_font


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


# ---- Stage 1B of the art pack (boards 06 and 10): one language for every menu page ----

## The panel of a menu page: ink under a line of old gold.
const PAGE := Color(0.035, 0.03, 0.045, 0.95)
## The action that matters on a screen (Continuar, Tentar de novo): warm bronze under a lit gold line.
const PRIMARY_FILL := Color(0.25, 0.16, 0.07, 0.97)
const PRIMARY_LIT := Color(0.37, 0.24, 0.09, 1.0)
## The tab on show: deep petrol under the gold line (the scene's teal).
const TAB_ON := Color(0.04, 0.17, 0.16, 0.97)


## A title over a gold rule (GoldRule), centred: the head of every menu page.
static func header(text: String, size: int = 38, width: float = 420.0) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.name = "header"
	v.add_theme_constant_override(&"separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(shadow(title(text, size)))
	var r := GoldRule.new()
	r.custom_minimum_size = Vector2(width, 14)
	r.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(r)
	return v


## The page's frame: ink, a line of old gold and a soft shadow round it.
static func frame_box(margin: int = 22) -> StyleBoxFlat:
	var s := box(PAGE, OLD_GOLD, 1, margin, 3)
	s.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	s.shadow_size = 14
	return s


## A menu page: the screen dimmed, a framed panel this wide in the middle with its title on top; returns the panel's
## column (the caller adds the content and the foot).
static func page(parent: Control, text: String, width: float, dim: float = 0.8, title_size: int = 36) -> VBoxContainer:
	var outer := column(parent, width, dim)
	var panel := PanelContainer.new()
	panel.name = "page"
	panel.add_theme_stylebox_override(&"panel", frame_box())
	outer.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override(&"separation", 10)
	panel.add_child(v)
	v.add_child(header(text, title_size, width * 0.55))
	return v


## Makes a button the screen's main action: bronze fill and a lit gold line even without the focus.
static func primary(b: Button) -> Button:
	b.add_theme_stylebox_override(&"normal", box(PRIMARY_FILL, EDGE.lightened(0.2), 2, 10))
	b.add_theme_stylebox_override(&"hover", box(PRIMARY_LIT, GOLD, 2, 10))
	b.add_theme_stylebox_override(&"pressed", box(PRIMARY_LIT, GOLD, 2, 10))
	b.add_theme_stylebox_override(&"focus", box(PRIMARY_LIT, GOLD, 3, 10))
	b.add_theme_color_override(&"font_color", GOLD.lightened(0.15))
	return b


## A tab (Configurações, Como Jogar): pressed is the page on show (petrol), the focus a gold line over it.
static func tab(text: String, width: float) -> Button:
	var b := button(text, Callable(), width)
	b.toggle_mode = true
	b.custom_minimum_size.y = 44
	b.add_theme_font_override(&"font", TITLE_FONT)
	b.add_theme_font_size_override(&"font_size", 19)
	b.add_theme_stylebox_override(&"pressed", box(TAB_ON, OLD_GOLD.lightened(0.2), 2, 10))
	b.add_theme_stylebox_override(&"hover_pressed", box(TAB_ON.lightened(0.05), GOLD, 2, 10))
	b.add_theme_stylebox_override(&"focus", box(Color(0, 0, 0, 0), GOLD, 2, 10))
	b.add_theme_color_override(&"font_pressed_color", PALE)
	b.add_theme_color_override(&"font_hover_pressed_color", GOLD)
	return b


## A quiet way out at the foot of a panel (Sair para o menu, Sair do jogo): small text, a box only with the focus.
static func link(text: String, on_press: Callable = Callable(), width: float = 0.0) -> Button:
	var b := button(text, on_press, width)
	b.custom_minimum_size.y = 36
	b.add_theme_font_size_override(&"font_size", 17)
	b.add_theme_stylebox_override(&"normal", box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 1, 8))
	b.add_theme_stylebox_override(&"hover", box(Color(0.12, 0.09, 0.06, 0.6), OLD_GOLD, 1, 8))
	b.add_theme_stylebox_override(&"pressed", box(Color(0.16, 0.11, 0.07, 0.8), GOLD, 1, 8))
	b.add_theme_stylebox_override(&"focus", box(Color(0.14, 0.1, 0.06, 0.75), GOLD, 1, 8))
	b.add_theme_color_override(&"font_color", DIM.lightened(0.25))
	return b


## A section's name with a rule running on after it ("Ações ————").
static func section(text: String, color: Color = OLD_GOLD.lightened(0.35), size: int = 17) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override(&"separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := shadow(label(text, color, size, TITLE_FONT))
	l.add_theme_constant_override(&"outline_size", 4)
	h.add_child(l)
	var line := ColorRect.new()
	line.color = Color(OLD_GOLD, 0.55)
	line.custom_minimum_size.y = 1
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(line)
	return h


## A centred row for the buttons at the foot of a page.
static func foot(gap: int = 14) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.name = "foot"
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_theme_constant_override(&"separation", gap)
	return h


## A row that takes the focus (mouse, keys, gamepad) and lights its frame with it, for lists inside a scroll that
## follows the focus (Suas Bênçãos, Créditos).
static func focus_row(margin: int = 10) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.focus_mode = Control.FOCUS_ALL
	var plain := box(Color(0.07, 0.05, 0.09, 0.9), EDGE.darkened(0.35), 1, margin)
	var lit := box(Color(0.12, 0.08, 0.1, 0.95), GOLD, 2, margin)
	panel.add_theme_stylebox_override(&"panel", plain)
	panel.focus_entered.connect(func() -> void:
		panel.add_theme_stylebox_override(&"panel", lit)
		Audio.play(&"ui_move"))
	panel.focus_exited.connect(func() -> void: panel.add_theme_stylebox_override(&"panel", plain))
	panel.mouse_entered.connect(func() -> void: panel.grab_focus())
	return panel


## The gifts carried, as medallions in a row or a flow (the end screen, the pause): carried is [{boon, level}], at
## most max_shown of them, the rest summed in "+N".
static func gift_icons(parent: Container, carried: Array, icon_px: float, max_shown: int) -> void:
	for i in mini(carried.size(), max_shown):
		var b: Boon = carried[i].boon
		var icon := BoonIcon.new().setup(b, icon_px)
		icon.level = int(carried[i].get("level", 1))
		icon.max_level = b.max_level
		parent.add_child(icon)
	if carried.size() > max_shown:
		var more := label("+%d" % (carried.size() - max_shown), PALE, roundi(icon_px * 0.55), BOLD_FONT)
		more.name = "more"
		more.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		parent.add_child(more)


## The gifts a BoonState holds, as gift_icons wants them.
static func carried_of(state: BoonState) -> Array:
	var out := []
	if state != null:
		for b: Boon in state.owned():
			out.append({"boon": b, "level": state.level(b.id)})
	return out
