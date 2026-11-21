class_name Book
extends RefCounted
## The page language of the Livro de Ahk (art pack stage 2, boards 04, 05 and 09): dark ink on warm parchment, headings
## in Cinzel in a manuscript's red, numbers and ornaments in an old gold dark enough to read on paper, the tree on a
## slate inset. BookSpread draws the open book; HeroScreen (the Warrior's chapters and his Gift tree) and CodexScreen
## (the Compendium) write on its pages. Buttons on the paper are the page's own (button: ink on a deeper paper under a
## gilt line, the focus a rubric line with a diamond; UI review d2ff05d, P1-6), never the menus' dark blocks.

const INK := Color(0.16, 0.11, 0.07)
const FADED := Color(0.38, 0.31, 0.23)
const RUBRIC := Color(0.47, 0.13, 0.09)
const GILT := Color(0.5, 0.36, 0.15)
const LEATHER := Color(0.14, 0.1, 0.08)
const LEATHER_EDGE := Color(0.27, 0.17, 0.09)
const RIBBON := Color(0.06, 0.27, 0.27)
## On the page: a Gift worn, and a rule that refuses.
const OK := Color(0.1, 0.4, 0.25)
const WARN := Color(0.56, 0.17, 0.09)
## A button on the paper (button): a deeper paper under a line of gilt; the main action on a toasted paper; the
## focus and the hover a line of rubric and a diamond on the left.
const BUTTON_PAPER := Color(0.55, 0.43, 0.27, 0.22)
const BUTTON_LIT := Color(0.55, 0.43, 0.27, 0.36)
const BUTTON_TOAST := Color(0.5, 0.27, 0.12, 0.3)
const BUTTON_TOAST_LIT := Color(0.5, 0.27, 0.12, 0.44)
const BUTTON_SIZE := 20
## The rubric band down the left of the selected entry of an index (4 px at 1080).
const ENTRY_BAND := 3
const ENTRY_DROP := 3.0
const BUTTON_DIAMOND := 4.5
## A chapter's bookmark (mark), px at 720 lines: the part under the cover, the height (a shut one stands 20 above
## the cover, 30 less the hidden part), how much longer the open one stands, its letters, padding, least width and tail.
const MARK_HIDDEN := 10.0
const MARK_HEIGHT := 32.0
const MARK_RISE := 8.0
const MARK_FONT := 19
const MARK_PAD := 16.0
const MARK_MIN := 80.0
const MARK_TAIL := 5.3
const MARK_SHADOW := 1.3
const MARK_IVORY := Color(0.97, 0.94, 0.85)
## The paper's tone where a list fades out at its foot (UiKit.scroll_fade).
const PAPER := Color(0.83, 0.75, 0.6)
## The value a bright colour of the menus (a family's, a branch's) takes to be read on the paper.
const INK_VALUE := 0.4

static var _theme: Theme


## The menus' theme with labels in ink and no outline (an outline round dark letters on paper reads as a smudge).
static func theme() -> Theme:
	if _theme != null:
		return _theme
	var t := UiKit.theme().duplicate() as Theme
	t.set_color(&"font_color", &"Label", INK)
	t.set_constant(&"outline_size", &"Label", 0)
	UiKit.scroll_bar(t, GILT, RUBRIC)
	_theme = t
	return t


## A bright colour of the menus (a family's, a branch's) dark enough for the paper, its hue kept.
static func ink(c: Color) -> Color:
	return Color.from_hsv(c.h, clampf(c.s * 1.1 + 0.1, 0.0, 1.0), INK_VALUE)


static func label(text: String, color: Color = INK, size: int = 18, font: Font = null) -> Label:
	return UiKit.label(text, color, size, font)


## A heading of the page: Cinzel in the rubric's red over a rule of old gold.
static func heading(text: String, size: int = 30, width: float = 300.0) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.name = "heading"
	v.add_theme_constant_override(&"separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := label(text, RUBRIC, size, UiKit.TITLE_FONT)
	l.name = "text"
	v.add_child(l)
	var r := GoldRule.new()
	r.tint = GILT
	r.custom_minimum_size = Vector2(width, 12)
	r.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	v.add_child(r)
	return v


## A small diamond of gilt and a name in small Cinzel ("◆ EFEITO"), the head of a part of the page.
static func section(text: String, size: int = 15) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override(&"separation", 8)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var d := Control.new()
	d.custom_minimum_size = Vector2(9, 9)
	d.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	d.mouse_filter = Control.MOUSE_FILTER_IGNORE
	d.draw.connect(func() -> void:
		var c := d.size * 0.5
		d.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -4.5), c + Vector2(4.5, 0), c + Vector2(0, 4.5), c + Vector2(-4.5, 0)]), GILT))
	h.add_child(d)
	h.add_child(label(text.to_upper(), RUBRIC, size, UiKit.TITLE_FONT))
	return h


## A line of text that wraps inside the page.
static func text(s: String, color: Color = INK, size: int = 18) -> Label:
	var l := label(s, color, size)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 60.0
	return l


## An entry of an index on the page (the Compendium's chapters): a toggle with a mark on its left and a count on its
## right; ink when it waits, a wash of paper with a band of rubric on its left when it is the one on show, only a
## diamond of rubric with the focus (never a solid dark box on the paper, AP-4 1.3).
## height, font_size, pad (where the name starts) and count_w make the compact entries of the Forja's grid.
static func index_entry(text_: String, mark: Control, count: String, width: float, height := 40.0, font_size := 18,
		pad := 48, count_w := 60.0) -> Button:
	var b := UiKit.button(text_, Callable(), width)
	b.toggle_mode = true
	b.custom_minimum_size.y = height
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_override(&"font", UiKit.TITLE_FONT)
	b.add_theme_font_size_override(&"font_size", font_size)
	var none := Color(0, 0, 0, 0)
	b.add_theme_stylebox_override(&"normal", _entry_box(none, none, 0, pad))
	b.add_theme_stylebox_override(&"hover", _entry_box(Color(INK, 0.07), none, 0, pad))
	b.add_theme_stylebox_override(&"pressed", _entry_box(BUTTON_LIT, none, 0, pad))
	b.add_theme_stylebox_override(&"hover_pressed", _entry_box(BUTTON_LIT, none, 0, pad))
	b.add_theme_stylebox_override(&"focus", _entry_box(none, none, 0, pad))
	b.add_theme_color_override(&"font_color", INK)
	b.add_theme_color_override(&"font_hover_color", RUBRIC)
	b.add_theme_color_override(&"font_focus_color", RUBRIC)
	b.add_theme_color_override(&"font_pressed_color", RUBRIC)
	b.add_theme_color_override(&"font_hover_pressed_color", RUBRIC)
	# the selected entry: a band of rubric down its left edge reaching ENTRY_DROP below it, as a marker; the focus
	# without the selection is only the diamond of the rubric on the left
	b.draw.connect(func() -> void:
		if b.button_pressed:
			b.draw_rect(Rect2(0, 0, ENTRY_BAND, b.size.y + ENTRY_DROP), RUBRIC)
		if b.has_focus() and not b.button_pressed:
			var d := Vector2(5.0, b.size.y * 0.5)
			var k := BUTTON_DIAMOND - 0.5
			b.draw_colored_polygon(PackedVector2Array([d + Vector2(0, -k), d + Vector2(k, 0), d + Vector2(0, k), d + Vector2(-k, 0)]), RUBRIC))
	b.toggled.connect(func(_on: bool) -> void: b.queue_redraw())
	b.focus_entered.connect(b.queue_redraw)
	b.focus_exited.connect(b.queue_redraw)
	mark.position = Vector2(10, (b.custom_minimum_size.y - mark.custom_minimum_size.y) * 0.5)
	b.add_child(mark)
	var n := label(count, GILT, 15, UiKit.number_font())
	n.name = "count"
	n.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	n.offset_left = -10 - count_w
	n.offset_right = -10
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	n.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	b.add_child(n)
	return b


static func _entry_box(bg: Color, border: Color, width: int, pad: int, band: int = 0) -> StyleBoxFlat:
	var s := UiKit.box(bg, border, width, 8, 3)
	s.content_margin_left = pad
	if band > 0:
		# the selected entry: the rubric band down its left edge, as a marker
		s.border_width_left = band
		s.corner_radius_top_left = 0
		s.corner_radius_bottom_left = 0
	return s


## A button on the parchment (UI review d2ff05d, P1-6): the menus' button (UiKit.button: the mouse takes the focus,
## the same height and sounds) in the page's language: ink on a deeper paper under one line of gilt; the focus and the
## hover a line of rubric, rubric letters and a small diamond on the left.
static func button(text_: String, on_press: Callable = Callable(), width: float = 200.0) -> Button:
	var b := UiKit.button(text_, on_press, width)
	b.add_theme_font_size_override(&"font_size", BUTTON_SIZE)
	_paper(b, BUTTON_PAPER, BUTTON_LIT, INK)
	b.draw.connect(func() -> void:
		if b.has_focus() or b.is_hovered():
			var c := Vector2(13.0, b.size.y * 0.5)
			var k := BUTTON_DIAMOND
			b.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -k), c + Vector2(k, 0), c + Vector2(0, k), c + Vector2(-k, 0)]), RUBRIC))
	b.focus_entered.connect(b.queue_redraw)
	b.focus_exited.connect(b.queue_redraw)
	b.mouse_exited.connect(b.queue_redraw)
	return b


## Makes a paper button the page's main action: a toasted paper and rubric letters even without the focus.
static func primary(b: Button) -> Button:
	_paper(b, BUTTON_TOAST, BUTTON_TOAST_LIT, RUBRIC)
	return b


static func _paper(b: Button, fill: Color, lit: Color, letters: Color) -> void:
	b.add_theme_stylebox_override(&"normal", _button_box(fill, GILT, 1))
	b.add_theme_stylebox_override(&"hover", _button_box(lit, RUBRIC, 1))
	b.add_theme_stylebox_override(&"pressed", _button_box(lit, RUBRIC, 2))
	b.add_theme_stylebox_override(&"hover_pressed", _button_box(lit, RUBRIC, 2))
	b.add_theme_stylebox_override(&"focus", _button_box(Color(0, 0, 0, 0), RUBRIC, 2))
	b.add_theme_stylebox_override(&"disabled", _button_box(Color(fill, fill.a * 0.4), Color(GILT, 0.4), 1))
	b.add_theme_color_override(&"font_color", letters)
	b.add_theme_color_override(&"font_hover_color", RUBRIC)
	b.add_theme_color_override(&"font_focus_color", RUBRIC)
	b.add_theme_color_override(&"font_pressed_color", RUBRIC)
	b.add_theme_color_override(&"font_hover_pressed_color", RUBRIC)
	b.add_theme_color_override(&"font_disabled_color", Color(FADED, 0.6))
	b.add_theme_constant_override(&"outline_size", 0)


static func _button_box(bg: Color, border: Color, width: int) -> StyleBoxFlat:
	var s := UiKit.box(bg, border, width, 10, 2)
	s.content_margin_left = 26
	s.content_margin_right = 26
	return s


## A chapter's bookmark (AP-4 1.2): a narrow ribbon that comes out from under the cover's top edge (its foot hidden
## behind the book, MARK_HIDDEN px of it; the callers' column overlaps the book by that much) and rises above it, its
## top cut in a swallow's tail. Shut: toasted leather, rising MARK_SHUT; open: the petrol ribbon with a pale line on
## its left and a dark one on its right, longer by MARK_RISE, its letters in full ivory; the focus a gilt line round it;
## a shadow of 2 px on the table. Its width is its name and MARK_PAD (never under MARK_MIN). A toggle: pressed is the
## chapter on show (mark_open sets it and lengthens it).
static func mark(text_: String, min_width: float = 0.0) -> Button:
	var b := UiKit.button(text_, Callable(), 0.0)
	b.toggle_mode = true
	var w := UiKit.TITLE_FONT.get_string_size(text_, HORIZONTAL_ALIGNMENT_LEFT, -1, MARK_FONT).x + MARK_PAD
	b.custom_minimum_size = Vector2(maxf(maxf(w, MARK_MIN), min_width), MARK_HEIGHT)
	b.size_flags_vertical = Control.SIZE_SHRINK_END
	b.add_theme_font_override(&"font", UiKit.TITLE_FONT)
	b.add_theme_font_size_override(&"font_size", MARK_FONT)
	var empty := StyleBoxEmpty.new()
	empty.content_margin_bottom = MARK_HIDDEN - 5.0
	empty.content_margin_top = 0
	for st: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"focus"]:
		b.add_theme_stylebox_override(st, empty)
	var shut_ink := Color(PAPER.r * 0.75, PAPER.g * 0.75, PAPER.b * 0.75)
	b.add_theme_color_override(&"font_color", shut_ink)
	b.add_theme_color_override(&"font_hover_color", PAPER)
	b.add_theme_color_override(&"font_focus_color", PAPER)
	b.add_theme_color_override(&"font_pressed_color", MARK_IVORY)
	b.add_theme_color_override(&"font_hover_pressed_color", MARK_IVORY)
	var tongue := Control.new()
	tongue.name = "ribbon"
	tongue.show_behind_parent = true
	tongue.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tongue.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tongue.draw.connect(_draw_tongue.bind(tongue, b))
	b.add_child(tongue)
	for sig: Signal in [b.toggled, b.focus_entered, b.focus_exited, b.mouse_entered, b.mouse_exited]:
		sig.connect(func(_a: Variant = null) -> void: tongue.queue_redraw())
	return b


## A bookmark longer while its chapter is open.
static func mark_open(b: Button, open: bool) -> void:
	b.set_pressed_no_signal(open)
	b.custom_minimum_size.y = MARK_HEIGHT + (MARK_RISE if open else 0.0)
	(b.get_node("ribbon") as Control).queue_redraw()


static func _draw_tongue(t: Control, b: Button) -> void:
	var w := t.size.x
	var h := t.size.y
	var open := b.button_pressed
	var notch := MARK_TAIL * (1.25 if open else 1.0)
	var body := RIBBON if open else LEATHER_EDGE
	if b.is_hovered() and not open:
		body = body.lightened(0.12)
	var shadow := Color(INK, 0.35)
	var at := Vector2(MARK_SHADOW, MARK_SHADOW)
	t.draw_colored_polygon(_tail(w, h, notch, at), shadow)
	t.draw_colored_polygon(_tail(w, h, notch, Vector2.ZERO), body)
	# the pale line on its left and the dark one on its right (open); the shut one a faint edge
	t.draw_line(Vector2(0.7, notch * 0.2), Vector2(0.7, h), body.lightened(0.3 if open else 0.15), 1.0)
	t.draw_line(Vector2(w - 0.7, notch * 0.2), Vector2(w - 0.7, h), body.darkened(0.45), 1.0)
	if b.has_focus():
		t.draw_polyline(PackedVector2Array([Vector2(0, h), Vector2(0, 0), Vector2(w * 0.5, notch), Vector2(w, 0), Vector2(w, h)]), UiKit.GOLD, 1.5)


## The ribbon's outline: a swallow's tail cut into its top, the foot square.
static func _tail(w: float, h: float, notch: float, at: Vector2) -> PackedVector2Array:
	return PackedVector2Array([at, at + Vector2(w * 0.5, notch), at + Vector2(w, 0), at + Vector2(w, h), at + Vector2(0, h)])
