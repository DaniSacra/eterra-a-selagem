class_name Book
extends RefCounted
## The page language of the Livro de Ahk (art pack stage 2, boards 04, 05 and 09): dark ink on warm parchment, headings
## in Cinzel in a manuscript's red, numbers and ornaments in an old gold dark enough to read on paper, the tree on a
## slate inset. BookSpread draws the open book; HeroScreen (the Warrior's chapters and his Gift tree) and CodexScreen
## (the Compendium) write on its pages. Buttons keep the menus' dark look (UiKit), as on the boards.

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
