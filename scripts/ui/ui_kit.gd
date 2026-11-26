class_name UiKit
extends RefCounted
## One look for every screen: Cinzel for titles, Alegreya Sans for text, dark panels with a thin gold edge.

const TITLE_FONT: Font = preload("res://assets/fonts/Cinzel.ttf")
const TEXT_FONT: Font = preload("res://assets/fonts/AlegreyaSans-Regular.ttf")
const BOLD_FONT: Font = preload("res://assets/fonts/AlegreyaSans-Bold.ttf")
const GOLD := Color(0.96, 0.8, 0.45)
const PALE := Color(0.94, 0.9, 0.82)
const DIM := Color(0.66, 0.62, 0.7)
## The words and numbers that matter inside a text (UI-HB2): full ivory and bold, never a reserved colour.
const STRONG := Color(0.98, 0.95, 0.87)
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
## The scroll bar (scroll_bar): its width, the length of the grabber's points; the fade at a list's foot (scroll_fade).
const SCROLL_WIDTH := 10.0
const LOZENGE_TIP := 7
const FADE_HEIGHT := 24.0

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
	scroll_bar(t, OLD_GOLD, GOLD)
	_theme = t
	return t


## The scroll bar of a theme (UI review d2ff05d, P1-12; the Godot grey one was the only piece of the game without a
## look): a track of a 2 px line at 0.3 of `line`, and a grabber in a long diamond (pointed at both ends) of `line`,
## `lit` while hovered or dragged.
static func scroll_bar(t: Theme, line: Color, lit: Color) -> void:
	var track := StyleBoxLine.new()
	track.vertical = true
	track.thickness = 2
	track.color = Color(line, 0.3)
	track.content_margin_left = SCROLL_WIDTH * 0.5
	track.content_margin_right = SCROLL_WIDTH * 0.5
	t.set_stylebox(&"scroll", &"VScrollBar", track)
	t.set_stylebox(&"scroll_focus", &"VScrollBar", track)
	t.set_stylebox(&"grabber", &"VScrollBar", _lozenge(line))
	t.set_stylebox(&"grabber_highlight", &"VScrollBar", _lozenge(lit))
	t.set_stylebox(&"grabber_pressed", &"VScrollBar", _lozenge(lit))


## A long diamond that stretches in its middle: pointed ends LOZENGE_TIP px long, SCROLL_WIDTH wide.
static func _lozenge(c: Color) -> StyleBoxTexture:
	var w := int(SCROLL_WIDTH)
	var tip := LOZENGE_TIP
	var h := tip * 2 + 2
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		# half width at this row: grows over the tip, straight between
		var half := minf(float(mini(y, h - 1 - y)) + 0.5, float(tip)) / float(tip) * float(w) * 0.5
		for x in w:
			var d := absf(float(x) + 0.5 - float(w) * 0.5)
			img.set_pixel(x, y, Color(c, c.a * clampf(half - d + 0.5, 0.0, 1.0)))
	var sb := StyleBoxTexture.new()
	sb.texture = ImageTexture.create_from_image(img)
	sb.texture_margin_top = tip
	sb.texture_margin_bottom = tip
	sb.content_margin_top = tip
	sb.content_margin_bottom = tip
	return sb


## A scroll's foot fades into the page while more of the list lies below (P1-12: the last line was cut in the middle,
## with nothing to say there was more): FADE_HEIGHT px from clear to `paper`, over the list, hidden at the end.
static func scroll_fade(scroll: ScrollContainer, paper: Color) -> Control:
	var fade := ScrollFade.new()
	fade.paper = paper
	scroll.add_child(fade, false, Node.INTERNAL_MODE_FRONT)
	return fade


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
## A number or a word of rule marked inside a text for a RichTextLabel (rich): full ivory, bold (UI-HB2).
static func strong(text: String) -> String:
	return "[color=#%s][b]%s[/b][/color]" % [STRONG.to_html(false), text]


## A wrapping text with marks (strong) in Alegreya Sans, as tall as its lines, left aligned; body: its plain colour.
static func rich(bbcode: String, body: Color = PALE, size: int = 18) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.add_theme_font_override(&"normal_font", TEXT_FONT)
	r.add_theme_font_override(&"bold_font", BOLD_FONT)
	r.add_theme_font_size_override(&"normal_font_size", size)
	r.add_theme_font_size_override(&"bold_font_size", size)
	r.add_theme_color_override(&"default_color", body)
	r.add_theme_constant_override(&"line_separation", 1)
	r.text = bbcode
	return r


## A line of words that may name a mouse button (PT-26-1: it shows the mouse icon, MouseGlyph.keyed): one RichTextLabel,
## the text font, the HUD's shadow, no wrapping unless wrap. Set its words with `r.text = MouseGlyph.keyed(words)`.
static func keyed_line(color: Color, size: int, wrap: bool = false) -> RichTextLabel:
	var r := rich("", color, size)
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	r.add_theme_color_override(&"font_shadow_color", SHADOW)
	r.add_theme_constant_override(&"shadow_offset_x", 0)
	r.add_theme_constant_override(&"shadow_offset_y", SHADOW_DROP)
	r.add_theme_constant_override(&"shadow_outline_size", SHADOW_SPREAD)
	return r


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
	# centred over the action bar's row, never under it (every such screen has the bar)
	center.offset_bottom = -ActionBar.RESERVE
	parent.add_child(center)
	var box_ := VBoxContainer.new()
	box_.custom_minimum_size.x = width
	box_.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(box_)
	return box_


## Whether a text has a digit: such a text is never set in Cinzel, whose 1 is a bare stroke and reads as a Roman I
## (UI review d2ff05d, P0-1); use number_font for it.
static func has_digit(text: String) -> bool:
	for c in text:
		if c >= "0" and c <= "9":
			return true
	return false


## A number as the player reads it: a whole one plain, else one decimal with a comma (seconds, metres: "1,5 s").
static func format_number(v: float) -> String:
	if is_equal_approx(v, roundf(v)):
		return str(roundi(v))
	return ("%.1f" % v).replace(".", ",")


## A count the HUD shows whole (life, Magia, gold, damage; BUG-113): rounded, and never 0 for something above 0.
static func whole(v: float) -> String:
	return str(maxi(roundi(v), 1) if v > 0.0 else roundi(v))


## LB and RB (PageUp and PageDown; Controls.MENU_KEYS) step through a screen's tabs (DT-103): the next or the previous
## tab takes the focus, which shows its page, wrapping round. True when the event was one of them (the caller marks it
## handled).
static func step_tabs(event: InputEvent, buttons: Array, current: int) -> bool:
	if buttons.is_empty() or event.is_echo():
		return false
	var step := 1 if event.is_action_pressed(&"tab_next") else (-1 if event.is_action_pressed(&"tab_prev") else 0)
	if step == 0:
		return false
	var to := buttons[posmod(current + step, buttons.size())] as BaseButton
	to.grab_focus()
	return true


## Label of the key or button of an action, with every gamepad button named (Controls.label names only A, B, X, Y).
## The gamepad's buttons of Godot's menu actions.
const MENU_PAD := {&"ui_accept": JOY_BUTTON_A, &"ui_cancel": JOY_BUTTON_B}


static func action_label(action: StringName) -> String:
	var label := Controls.label(action)
	if label == "" and not Controls.using_pad:
		# Godot's own menu actions (ui_accept, ui_cancel) bind by key code, not by place on the keyboard
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey and (ev as InputEventKey).keycode != KEY_NONE:
				label = OS.get_keycode_string((ev as InputEventKey).keycode)
				break
	if Controls.using_pad and (label == "" or label == "?") and MENU_PAD.has(action):
		# the menus' A and B: Godot's own, not always listed in the map (the ScreenHost and the screens read them)
		label = T.t("pad_%d" % MENU_PAD[action])
	# key names come from the system in English ("Space"); the common ones have a Portuguese name
	return T.t("key_" + label) if T.table.entries.has("key_" + label) else label


## The name of an action's key or button for the keyboard (pad false) or the gamepad (true), read from the bindings,
## never fixed text. Used by the controls lines (title_controls, title_pad).
static func bound_name(action: StringName, pad: bool) -> String:
	var label := Controls.label_for(action, pad)
	return T.t("key_" + label) if T.table.entries.has("key_" + label) else label


## The controls line (`title_controls` keyboard and mouse, `title_pad` gamepad) with the real bindings.
static func controls_line(pad: bool) -> String:
	var p := {}
	for a: StringName in [&"light_attack", &"heavy_attack", &"dodge", &"shout", &"rush", &"ultimate", &"interact", &"pause"]:
		p[String(a)] = bound_name(a, pad)
	p["supremo"] = p["ultimate"]
	var move := ""
	for a: StringName in [&"move_up", &"move_left", &"move_down", &"move_right"]:
		move += bound_name(a, false)
	p["move"] = move
	return T.t(&"title_pad" if pad else &"title_controls", p)


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
	crown(panel)
	outer.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override(&"separation", 10)
	panel.add_child(v)
	v.add_child(header(text, title_size, width * 0.55))
	return v


## UI-HB3 (benchmark_hades2_style.md): a menu panel is not a bare rectangle. Over its frame: a crest on the top edge
## (a diamond of old gold in a small arch of two lines, the cards' diamond) and a bracket of old gold at each corner with
## a small diamond on it. Drawn on the panel itself, under its children; nothing of the layout changes.
const CROWN_ARCH := 46.0
const CROWN_DIAMOND := 7.0
const CROWN_CORNER := 22.0


static func crown(panel: Control) -> void:
	panel.draw.connect(func() -> void:
		var s := panel.size
		var gold := OLD_GOLD.lightened(0.15)
		var top := Vector2(s.x * 0.5, 0.0)
		# the arch over the top edge, a diamond in it, the edge cut under it
		var arch := PackedVector2Array()
		for i in 13:
			var a := PI + PI * i / 12.0
			arch.append(top + Vector2(cos(a) * CROWN_ARCH * 0.5, sin(a) * CROWN_ARCH * 0.32))
		var fill := arch.duplicate()
		panel.draw_colored_polygon(fill, INK)
		panel.draw_polyline(arch, gold, 1.6, true)
		panel.draw_line(top + Vector2(-CROWN_ARCH * 0.5 - 30.0, 0), top + Vector2(-CROWN_ARCH * 0.5, 0), gold, 1.6, true)
		panel.draw_line(top + Vector2(CROWN_ARCH * 0.5, 0), top + Vector2(CROWN_ARCH * 0.5 + 30.0, 0), gold, 1.6, true)
		var d := top + Vector2(0, -CROWN_ARCH * 0.14)
		var h := CROWN_DIAMOND
		panel.draw_colored_polygon(PackedVector2Array([d + Vector2(0, -h), d + Vector2(h * 0.75, 0), d + Vector2(0, h), d + Vector2(-h * 0.75, 0)]), GOLD)
		# the corners' brackets, each with a small diamond at its bend
		for c: Vector2 in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]:
			var at := Vector2(c.x * s.x, c.y * s.y) + Vector2(6.0 if c.x == 0 else -6.0, 6.0 if c.y == 0 else -6.0)
			var dx := CROWN_CORNER * (1.0 if c.x == 0 else -1.0)
			var dy := CROWN_CORNER * (1.0 if c.y == 0 else -1.0)
			panel.draw_polyline(PackedVector2Array([at + Vector2(dx, 0), at, at + Vector2(0, dy)]), gold, 2.0, true)
			var k := 3.5
			panel.draw_colored_polygon(PackedVector2Array([at + Vector2(0, -k), at + Vector2(k, 0), at + Vector2(0, k), at + Vector2(-k, 0)]), GOLD))


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
## follows the focus (Suas Bênçãos).
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
## levels: the level's dots under each medallion (the endings leave them out: too small to read, and Suas Bênçãos tells
## them; UI review d2ff05d, P2-12).
static func gift_icons(parent: Container, carried: Array, icon_px: float, max_shown: int, levels: bool = true) -> void:
	for i in mini(carried.size(), max_shown):
		var b: Boon = carried[i].boon
		var icon := BoonIcon.new().setup(b, icon_px)
		if levels:
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


## The fade at a list's foot (scroll_fade): follows its ScrollContainer each frame.
class ScrollFade:
	extends Control

	var paper := Color.BLACK

	func _init() -> void:
		name = "fade"
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(_delta: float) -> void:
		var scroll := get_parent() as ScrollContainer
		if scroll == null:
			return
		var bar := scroll.get_v_scroll_bar()
		var more := bar.visible and bar.value + bar.page < bar.max_value - 1.0
		visible = more
		if more:
			position = Vector2(0, scroll.size.y - FADE_HEIGHT)
			size = Vector2(scroll.size.x - bar.size.x, FADE_HEIGHT)

	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)]),
			PackedColorArray([Color(paper, 0.0), Color(paper, 0.0), paper, paper]))


## A find's name (oficio_<id>: "Cabeça da Picareta").
static func find_name(id: StringName) -> String:
	var key := "oficio_" + String(id)
	return T.t(key) if T.table.entries.has(key) else String(id)
