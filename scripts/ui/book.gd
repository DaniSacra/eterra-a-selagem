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
const LEATHER := Color(0.12, 0.07, 0.05)
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
const BUTTON_DIAMOND := 4.5
## A chapter's bookmark (mark): its height, how much longer the open one stands, its letters.
const MARK_HEIGHT := 30.0
const MARK_RISE := 6.0
const MARK_FONT := 15
const MARK_OPEN := Color(0.22, 0.13, 0.08)
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
## right; ink when it waits, the petrol of the menus' tabs when it is the one on show, a gilt line with the focus.
static func index_entry(text_: String, mark: Control, count: String, width: float) -> Button:
	var b := UiKit.button(text_, Callable(), width)
	b.toggle_mode = true
	b.custom_minimum_size.y = 40
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_override(&"font", UiKit.TITLE_FONT)
	b.add_theme_font_size_override(&"font_size", 18)
	var pad := 48
	b.add_theme_stylebox_override(&"normal", _entry_box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 1, pad))
	b.add_theme_stylebox_override(&"hover", _entry_box(Color(INK, 0.07), GILT, 1, pad))
	b.add_theme_stylebox_override(&"pressed", _entry_box(UiKit.TAB_ON, UiKit.OLD_GOLD, 1, pad))
	b.add_theme_stylebox_override(&"hover_pressed", _entry_box(UiKit.TAB_ON.lightened(0.05), UiKit.GOLD, 2, pad))
	b.add_theme_stylebox_override(&"focus", _entry_box(Color(0, 0, 0, 0), RUBRIC, 2, pad))
	b.add_theme_color_override(&"font_color", INK)
	b.add_theme_color_override(&"font_hover_color", RUBRIC)
	b.add_theme_color_override(&"font_focus_color", RUBRIC)
	b.add_theme_color_override(&"font_pressed_color", UiKit.PALE)
	b.add_theme_color_override(&"font_hover_pressed_color", UiKit.GOLD)
	mark.position = Vector2(10, (b.custom_minimum_size.y - mark.custom_minimum_size.y) * 0.5)
	b.add_child(mark)
	var n := label(count, GILT, 15, UiKit.number_font())
	n.name = "count"
	n.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	n.offset_left = -70
	n.offset_right = -10
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	n.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	b.add_child(n)
	return b


static func _entry_box(bg: Color, border: Color, width: int, pad: int) -> StyleBoxFlat:
	var s := UiKit.box(bg, border, width, 8, 3)
	s.content_margin_left = pad
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


## A chapter's bookmark (UI review d2ff05d, P1-5): a leather tongue standing out of the top of the cover, its name in
## small Cinzel in old gold; the one open is longer, lighter and has the petrol ribbon on its top; the focus a gilt
## line round it. A toggle: pressed is the chapter on show (the caller sets it, and lengthens it by mark_open).
static func mark(text_: String, width: float) -> Button:
	var b := UiKit.button(text_, Callable(), width)
	b.toggle_mode = true
	b.custom_minimum_size.y = MARK_HEIGHT
	b.size_flags_vertical = Control.SIZE_SHRINK_END
	b.add_theme_font_override(&"font", UiKit.TITLE_FONT)
	b.add_theme_font_size_override(&"font_size", MARK_FONT)
	b.add_theme_stylebox_override(&"normal", _tongue(LEATHER, LEATHER_EDGE, 0))
	b.add_theme_stylebox_override(&"hover", _tongue(LEATHER.lightened(0.08), UiKit.OLD_GOLD, 0))
	b.add_theme_stylebox_override(&"pressed", _tongue(MARK_OPEN, LEATHER_EDGE.lightened(0.2), 4))
	b.add_theme_stylebox_override(&"hover_pressed", _tongue(MARK_OPEN.lightened(0.06), UiKit.OLD_GOLD, 4))
	b.add_theme_stylebox_override(&"focus", _tongue(Color(0, 0, 0, 0), UiKit.GOLD, 0, 2))
	b.add_theme_color_override(&"font_color", UiKit.OLD_GOLD.lightened(0.15))
	b.add_theme_color_override(&"font_hover_color", UiKit.GOLD)
	b.add_theme_color_override(&"font_focus_color", UiKit.GOLD)
	b.add_theme_color_override(&"font_pressed_color", UiKit.GOLD.lightened(0.2))
	b.add_theme_color_override(&"font_hover_pressed_color", UiKit.GOLD.lightened(0.2))
	return b


## A bookmark longer while its chapter is open.
static func mark_open(b: Button, open: bool) -> void:
	b.set_pressed_no_signal(open)
	b.custom_minimum_size.y = MARK_HEIGHT + (MARK_RISE if open else 0.0)


static func _tongue(bg: Color, border: Color, ribbon: int, width: int = 1) -> StyleBoxFlat:
	var s := UiKit.box(bg, border, width, 6, 0)
	s.border_width_bottom = 0
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.content_margin_top = 6 + ribbon
	s.content_margin_bottom = 2
	if ribbon > 0:
		# the open one: the petrol ribbon on its top, its sides in the same line
		s.border_width_top = ribbon
		s.border_color = RIBBON.lightened(0.15)
	return s
