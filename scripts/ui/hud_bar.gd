class_name HudBar
extends Control
## A framed bar with a pointed end (life, Magia, the boss): the fill, a pale trail that drains behind it after a hit,
## an optional thin second bar on top (the boss's armour) and the numbers in the middle.

const FRAME := Color(0.03, 0.02, 0.035, 0.92)
const BACK := Color(0.09, 0.06, 0.08, 0.92)
const TRAIL := Color(1.0, 0.86, 0.7, 0.55)
const TRAIL_SPEED := 0.5

var fill_color := Color.WHITE
var over_color := Color.WHITE
## Pointed at both ends (the boss), or only at the right.
var both_ends := false
var font_size := 12
var _ratio := 1.0
var _trail := 1.0
var _over := 0.0
var _text := ""


func setup(color: Color, size_px: Vector2, font_px: int = 12, both: bool = false) -> HudBar:
	fill_color = color
	custom_minimum_size = size_px
	size = size_px
	font_size = font_px
	both_ends = both
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


## ratio 0..1; text in the middle ("" for none); over 0..1 is the thin bar on top.
func show_value(ratio: float, text: String = "", over: float = 0.0) -> void:
	ratio = clampf(ratio, 0.0, 1.0)
	if ratio == _ratio and text == _text and over == _over:
		return
	if ratio > _trail:
		_trail = ratio
	_ratio = ratio
	_text = text
	_over = over
	queue_redraw()


func _process(delta: float) -> void:
	if _trail > _ratio:
		_trail = move_toward(_trail, _ratio, delta * TRAIL_SPEED)
		queue_redraw()


func _draw() -> void:
	var inner := Rect2(Vector2.ZERO, size)
	draw_colored_polygon(shape(inner.grow(2.0)), FRAME)
	var edge := shape(inner.grow(1.0))
	edge.append(edge[0])
	draw_polyline(edge, Color(UiKit.EDGE, 0.75), 1.0, true)
	var body := shape(inner)
	draw_colored_polygon(body, BACK)
	_fill(body, _trail, TRAIL, 0.0, size.y)
	_fill(body, _ratio, fill_color, 0.0, size.y)
	_fill(body, _ratio, Color(1, 1, 1, 0.14), 0.0, size.y * 0.32)
	_fill(body, _ratio, fill_color.darkened(0.35), size.y * 0.75, size.y)
	if _over > 0.0:
		_fill(body, _over, over_color, 0.0, size.y * 0.4)
	if _text != "":
		var font := UiKit.BOLD_FONT
		var w := font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var at := Vector2((size.x - w) * 0.5, (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5)
		draw_string_outline(font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, Color(0.02, 0.01, 0.03))
		draw_string(font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, UiKit.PALE)


## The bar's outline in a rectangle: square left end (or pointed) and a pointed right end.
func shape(r: Rect2) -> PackedVector2Array:
	var t := r.size.y * 0.6
	var mid := r.position.y + r.size.y * 0.5
	var pts := PackedVector2Array([Vector2(r.end.x - t, r.position.y), Vector2(r.end.x, mid), Vector2(r.end.x - t, r.end.y)])
	if both_ends:
		pts.append_array([Vector2(r.position.x + t, r.end.y), Vector2(r.position.x, mid), Vector2(r.position.x + t, r.position.y)])
	else:
		pts.append_array([r.position + Vector2(0.0, r.size.y), r.position])
	return pts


## Fills the part of the body left of ratio, between the heights y0 and y1.
func _fill(body: PackedVector2Array, ratio: float, color: Color, y0: float, y1: float) -> void:
	if ratio <= 0.0:
		return
	var clip := PackedVector2Array([Vector2(-1.0, y0), Vector2(size.x * ratio, y0), Vector2(size.x * ratio, y1), Vector2(-1.0, y1)])
	for part in Geometry2D.intersect_polygons(body, clip):
		draw_colored_polygon(part, color)
