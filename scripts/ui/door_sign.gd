class_name DoorSign
extends Node3D
## The sign over a door, a reward or a shop item: what it gives in warm gold (Alegreya Sans Bold, a dark outline and
## the HUD's shadow) and, under it, a detail in pale (the price). Drawn as interface text over the point it marks (a
## CanvasLayer above the world, like the damage numbers), so fog, glow, tonemap and the vignette never wash it: the
## capitals stand CAP_PX tall at 1080 lines (in proportion on any other screen, through the canvas stretch) and both
## colours keep at least MIN_CONTRAST against the outline (UI-01).
##   var sign := DoorSign.make(T.t(&"reward_gold"), "120 ouro")
##   sign.position.y = 2.7   # the point the sign stands on (its text grows upwards from there)

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
const OUTLINE_COLOR := Color(0.035, 0.027, 0.04)
## WCAG contrast ratio each colour keeps against the outline.
const MIN_CONTRAST := 4.5
## Above the world, with the damage numbers, under the HUD and the menus (Game: numbers 2, HUD 5).
const LAYER := 2

var title: Label
var detail: Label
var _layer: CanvasLayer
var _box: VBoxContainer


## A sign with a name and, optionally, a detail line under it (empty: none).
static func make(name_text: String, detail_text: String = "") -> DoorSign:
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
	s._box.add_child(s.title)
	if detail_text != "":
		s.detail = _label(detail_text, DETAIL_COLOR, DETAIL_SIZE)
		s.detail.name = "detail"
		s._box.add_child(s.detail)
	return s


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
