class_name HudBar
extends Control
## A framed bar with a pointed end (life, Magia, the boss): a dark frame with a thin line of old gold, the fill in a
## gradient (light at the top, dark at the bottom) with a sheen on top, a pale trail that drains behind it after a
## hit, an optional thin second bar on top (the boss's armour) and the numbers in the middle.

const BACK := Color(0.07, 0.05, 0.065, 0.94)
const TRAIL := Color(1.0, 0.86, 0.7, 0.55)
const TRAIL_SPEED := 0.5
## Frame: 2 px of ink outside a 1 px line of old gold.
const FRAME_WIDTH := 2.0
const SHEEN := Color(1.0, 0.96, 0.9, 0.16)

var fill_top := Color.WHITE
var fill_bottom := Color.WHITE
var over_color := Color.WHITE
## Pointed at both ends (the boss), or only at the right.
var both_ends := false
var font_size := 12
var _ratio := 1.0
var _trail := 1.0
var _over := 0.0
var _text := ""


## color is the top of the fill; bottom the lower edge of the gradient (by default the same colour, darker).
func setup(color: Color, size_px: Vector2, font_px: int = 12, both: bool = false, bottom: Color = Color(0, 0, 0, 0)) -> HudBar:
	fill_top = color
	fill_bottom = bottom if bottom.a > 0.0 else color.darkened(0.45)
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
	draw_colored_polygon(shape(inner.grow(1.0 + FRAME_WIDTH)), UiKit.INK)
	draw_colored_polygon(shape(inner.grow(1.0)), UiKit.OLD_GOLD)
	var body := shape(inner)
	draw_colored_polygon(body, BACK)
	_fill(body, _trail, TRAIL, TRAIL, 0.0, size.y)
	_fill(body, _ratio, fill_top, fill_bottom, 0.0, size.y)
	# the sheen: a soft band on the upper third and a brighter hairline at the very top
	_fill(body, _ratio, SHEEN, Color(SHEEN, 0.0), 0.0, size.y * 0.45)
	_fill(body, _ratio, Color(SHEEN, 0.3), Color(SHEEN, 0.3), 0.0, 1.0)
	if _over > 0.0:
		_fill(body, _over, over_color, over_color.darkened(0.25), 0.0, size.y * 0.4)
	if _text != "":
		var font := UiKit.BOLD_FONT
		var w := font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var at := Vector2((size.x - w) * 0.5, (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5)
		draw_string_outline(font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, UiKit.INK)
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


## Fills the part of the body left of ratio, between the heights y0 and y1, from top (at y0) to bottom (at y1).
func _fill(body: PackedVector2Array, ratio: float, top: Color, bottom: Color, y0: float, y1: float) -> void:
	if ratio <= 0.0:
		return
	var clip := PackedVector2Array([Vector2(-1.0, y0), Vector2(size.x * ratio, y0), Vector2(size.x * ratio, y1), Vector2(-1.0, y1)])
	for part in Geometry2D.intersect_polygons(body, clip):
		var colors := PackedColorArray()
		for p in part:
			colors.append(top.lerp(bottom, clampf((p.y - y0) / maxf(y1 - y0, 0.001), 0.0, 1.0)))
		draw_polygon(part, colors)
