class_name DoorSign
extends Node3D
## The sign over a door, a reward or a shop item: what it gives in warm gold (Alegreya Sans Bold, a dark outline and
## the HUD's shadow) and, under it, a detail in pale (the price). Drawn as interface text over the point it marks (a
## CanvasLayer above the world, like the damage numbers), so fog, glow, tonemap and the vignette never wash it: the
## capitals stand CAP_PX tall at 1080 lines (in proportion on any other screen, through the canvas stretch) and both
## colours keep at least MIN_CONTRAST against the outline (UI-01).
##   var sign := DoorSign.make(T.t(&"reward_gold"), "120 ouro")
##   sign.position.y = 2.7   # the point the sign stands on (its text grows upwards from there)
## The shop (C13-04, three groups and the healing): DoorSign.shop(name, price, group) adds the group's word over the
## name in a cool grey and the price in ivory under it; set_gold(gold) keeps the price ivory while there is gold for it
## and, when not, turns it a muted rose with what is missing ("150 ouro, faltam 40"): the word, not only the colour.
##   var sign := DoorSign.shop(T.t(&"reward_heal"), 50, T.t(&"shop_group_care"))
##   sign.set_gold(rooms.gold)
## E5 (docs/art/e5_spec.md 7.1): a door's sign may carry a pictogram left of its name (DoorGlyph: chevrons for a hard
## fight, the guardian and Morvath, a drop, a coin, a flame, the cracked diamond) and, for a room that is not a common
## fight, the kind in pale under it ("Difícil", "Guardião"). The Provação's slab says its price in life, or "Vida
## insuficiente" in SHORT_COLOR when he has not enough (set_short).
##   var sign := DoorSign.make(T.t(&"reward_boon"), T.t(&"door_hard"), DoorGlyph.Kind.HARD)

## Height of the capitals at a screen 1080 lines tall (the backlog asks for 16 at least).
const CAP_PX := 19.0
## Lines of the project's base canvas (window/size/viewport_height; canvas_items stretch scales from it).
const BASE_LINES := 720.0
## Cap height of Alegreya Sans Bold over its em (OS/2 sCapHeight 644 of 1000).
const CAP_RATIO := 0.644
## The name's font size on the base canvas (capitals CAP_PX at 1080).
const FONT_SIZE := 20
## The detail line against the name.
const DETAIL_SIZE := 16
## Outline in canvas pixels (about 6 screen pixels at 1080).
const OUTLINE := 4
const TITLE_COLOR := Color(0.98, 0.84, 0.5)
const DETAIL_COLOR := UiKit.PALE
## The shop group's word over the name, smaller, and the price without gold enough for it.
const GROUP_SIZE := 16
const GROUP_COLOR := Color(0.74, 0.72, 0.8)
## The note's size (add_note), under the detail.
const NOTE_SIZE := 15
const SHORT_COLOR := Color(0.92, 0.62, 0.58)
const OUTLINE_COLOR := Color(0.035, 0.027, 0.04)
## WCAG contrast ratio each colour keeps against the outline.
const MIN_CONTRAST := 4.5
## Above the world, with the damage numbers, under the HUD and the menus (Game: numbers 2, HUD 5).
const LAYER := 2

var title: Label
var detail: Label
## The pictogram left of the name (null: none).
var mark: DoorGlyph
## The shop group's word (null: not a shop sign).
var group: Label
## The explanation under the detail (null: none; add_note).
var note: Label
## The shop price (-1: not a shop sign) and the gold still missing for it (0: enough).
var price := -1
var missing := 0
var _layer: CanvasLayer
var _box: VBoxContainer


## A sign with a name and, optionally, a detail line under it (empty: none) and a pictogram left of the name.
static func make(name_text: String, detail_text: String = "", glyph: DoorGlyph.Kind = DoorGlyph.Kind.NONE) -> DoorSign:
	var s := DoorSign.new()
	s.name = "DoorSign"
	s._layer = CanvasLayer.new()
	s._layer.layer = LAYER
	s.add_child(s._layer)
	s._box = VBoxContainer.new()
	s._box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s._box.add_theme_constant_override(&"separation", -4)
	s._box.visible = false
	s._layer.add_child(s._box)
	s.title = _label(name_text, TITLE_COLOR, FONT_SIZE)
	s.title.name = "title"
	if glyph == DoorGlyph.Kind.NONE:
		s._box.add_child(s.title)
	else:
		var row := HBoxContainer.new()
		row.name = "row"
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		row.add_theme_constant_override(&"separation", 5)
		s.mark = DoorGlyph.new().setup(glyph)
		s.mark.name = "mark"
		row.add_child(s.mark)
		row.add_child(s.title)
		s._box.add_child(row)
	if detail_text != "":
		s.detail = _label(detail_text, DETAIL_COLOR, DETAIL_SIZE)
		s.detail.name = "detail"
		s._box.add_child(s.detail)
	return s


## A shop item's sign: the group's word over the name (empty: none), the name and its price in ivory.
static func shop(name_text: String, price_: int, group_text: String = "") -> DoorSign:
	var s := make(name_text, price_text(price_))
	s.price = price_
	if group_text != "":
		s.group = _label(group_text, GROUP_COLOR, GROUP_SIZE)
		s.group.name = "group"
		s._box.add_child(s.group)
		s._box.move_child(s.group, 0)
	return s


## "150 ouro".
static func price_text(n: int) -> String:
	return T.t(&"shop_price", {"n": n})


## The price in ivory while gold is enough; without, muted rose and what is missing.
func set_gold(gold: int) -> void:
	if detail == null or price < 0:
		return
	missing = maxi(price - gold, 0)
	if missing > 0:
		detail.text = T.t(&"shop_price_short", {"n": price, "missing": missing})
		detail.add_theme_color_override(&"font_color", SHORT_COLOR)
	else:
		detail.text = price_text(price)
		detail.add_theme_color_override(&"font_color", DETAIL_COLOR)


## A short explanation under everything (T5, the Provação's slab: what it is and how to refuse it), smaller and in the
## shop group's cool grey so the name and the price stay first. Lines split by "\n".
func add_note(text: String) -> Label:
	if note == null:
		note = _label(text, GROUP_COLOR, NOTE_SIZE)
		note.name = "note"
		_box.add_child(note)
	note.text = text
	return note


## The detail line as a warning (the slab without life enough: "Vida insuficiente" in SHORT_COLOR) or back to its own
## text in the detail colour.
func set_short(short: bool, short_text: String, normal_text: String) -> void:
	if detail == null:
		return
	detail.text = short_text if short else normal_text
	detail.add_theme_color_override(&"font_color", SHORT_COLOR if short else DETAIL_COLOR)


## Whether the gold given last (set_gold) is enough for this sign's price (true for a sign without price).
func affordable() -> bool:
	return missing == 0


## Follows the point it marks: the text's bottom centre on it; hidden behind the camera or with the sign hidden.
func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	var at := global_position
	if cam == null or cam.is_position_behind(at) or not is_visible_in_tree():
		_box.visible = false
		return
	var s := _box.get_combined_minimum_size()
	_box.size = s
	_box.position = (cam.unproject_position(at) - Vector2(s.x * 0.5, s.y)).round()
	_box.visible = true


## Height of the capitals in screen pixels for this canvas font size on a screen this many lines tall.
static func cap_px(font_size: int, lines: float) -> float:
	return font_size * CAP_RATIO * lines / BASE_LINES


## WCAG 2 contrast ratio between two colours (1 to 21).
static func contrast(a: Color, b: Color) -> float:
	var la := _luminance(a)
	var lb := _luminance(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


static func _luminance(c: Color) -> float:
	return 0.2126 * _linear(c.r) + 0.7152 * _linear(c.g) + 0.0722 * _linear(c.b)


static func _linear(v: float) -> float:
	return v / 12.92 if v <= 0.04045 else pow((v + 0.055) / 1.055, 2.4)


static func _label(text: String, color: Color, size: int) -> Label:
	var l := UiKit.shadow(UiKit.label(text, color, size, UiKit.BOLD_FONT))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	l.add_theme_constant_override(&"outline_size", OUTLINE)
	l.add_theme_color_override(&"font_outline_color", OUTLINE_COLOR)
	return l
