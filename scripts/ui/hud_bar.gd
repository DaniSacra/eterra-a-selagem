class_name HudBar
extends Control
## A framed bar with a pointed end (life, Magia, the boss): the HUD's line of old gold over ink, an empty part in dark
## translucent slate (the floor shows through, it is never a black hole), the fill in a gradient (light at the top,
## dark at the bottom) with a sheen on top, a pale trail that shows for a moment what a hit took, a short glint at the
## fill's end whenever the value changes, an optional thin second bar on top (the boss's armour), the numbers in
## the middle, and for a boss the marks where his phases begin and a veil of his shield while it stands.

const BACK := Color(0.1, 0.12, 0.16, 0.72)
const TRAIL := Color(1.0, 0.9, 0.78, 0.8)
## The trail stands still for TRAIL_HOLD of its TRAIL_TIME seconds, then drains to the fill.
const TRAIL_TIME := 0.4
const TRAIL_HOLD := 0.4
## The glint at the end of the fill: seconds, width in pixels, and the smallest change of ratio that lights it (a
## slow refill does not keep it on).
const TIP_TIME := 0.25
const TIP_WIDTH := 5.0
const TIP_MIN := 0.004
const TIP := Color(1.0, 0.98, 0.92, 0.9)
## Ink outside the frame's line.
const INK_WIDTH := 1.0
const SHEEN := Color(1.0, 0.96, 0.9, 0.16)

var fill_top := Color.WHITE
var fill_bottom := Color.WHITE
var over_color := Color.WHITE
## Pointed at both ends (the boss), or only at the right.
var both_ends := false
var font_size := 12
## Shares of the bar where a boss's next phases begin (thin notches across it).
var marks := PackedFloat32Array()
## The boss's shield stands (0..1): the bar is veiled in its colour and framed in it.
var shield := 0.0
var shield_color := Color(0.4, 1.0, 0.75)
const MARK := Color(0.05, 0.04, 0.06, 0.9)
const MARK_WIDTH := 2.0
const SHIELD_VEIL := 0.45
var _ratio := 1.0
## Where the trail started (the value before the hit) and how long it still shows.
var _trail_from := 1.0
var _trail_t := 0.0
var _tip := 0.0
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
	if ratio < _ratio:
		# a second hit while the trail still shows keeps the older, longer trail
		_trail_from = maxf(trail(), _ratio)
		_trail_t = TRAIL_TIME
	if absf(ratio - _ratio) >= TIP_MIN:
		_tip = 1.0
	_ratio = ratio
	_text = text
	_over = over
	queue_redraw()


## A boss's phase marks and how much his shield stands (redraws only on a change).
func show_boss(phase_marks: PackedFloat32Array, shielded: float) -> void:
	if phase_marks == marks and is_equal_approx(shielded, shield):
		return
	marks = phase_marks
	shield = shielded
	queue_redraw()


## Where the trail ends now (0..1): the value before the hit, draining to the fill at the end of its time.
func trail() -> float:
	if _trail_t <= 0.0:
		return _ratio
	var left := clampf(_trail_t / (TRAIL_TIME * (1.0 - TRAIL_HOLD)), 0.0, 1.0)
	return maxf(_ratio, lerpf(_ratio, _trail_from, left))


func _process(delta: float) -> void:
	if _trail_t > 0.0 or _tip > 0.0:
		_trail_t = maxf(0.0, _trail_t - delta)
		_tip = maxf(0.0, _tip - delta / TIP_TIME)
		queue_redraw()


func _draw() -> void:
	var inner := Rect2(Vector2.ZERO, size)
	_ring(inner.grow(UiKit.FRAME), inner.grow(UiKit.FRAME + INK_WIDTH), UiKit.INK)
	_ring(inner, inner.grow(UiKit.FRAME), UiKit.OLD_GOLD)
	var body := shape(inner)
	draw_colored_polygon(body, BACK)
	_band(body, _ratio, trail(), TRAIL, TRAIL, 0.0, size.y)
	_band(body, 0.0, _ratio, fill_top, fill_bottom, 0.0, size.y)
	# the sheen: a soft band on the upper third and a brighter hairline at the very top
	_band(body, 0.0, _ratio, SHEEN, Color(SHEEN, 0.0), 0.0, size.y * 0.45)
	_band(body, 0.0, _ratio, Color(SHEEN, 0.3), Color(SHEEN, 0.3), 0.0, 1.0)
	if _tip > 0.0:
		var glint := Color(TIP, TIP.a * _tip)
		_band(body, _ratio - TIP_WIDTH / size.x, _ratio, glint, glint, 0.0, size.y)
	if _over > 0.0:
		_band(body, 0.0, _over, over_color, over_color.darkened(0.25), 0.0, size.y * 0.4)
	for m in marks:
		_band(body, m - MARK_WIDTH * 0.5 / size.x, m + MARK_WIDTH * 0.5 / size.x, MARK, MARK, 0.0, size.y)
	if shield > 0.0:
		var veil := Color(shield_color, SHIELD_VEIL * shield)
		_band(body, 0.0, 1.0, veil, Color(shield_color.darkened(0.4), SHIELD_VEIL * shield), 0.0, size.y)
		_ring(inner, inner.grow(UiKit.FRAME), Color(shield_color, shield))
	if _text != "":
		var font := UiKit.number_font()
		var w := font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var at := Vector2((size.x - w) * 0.5, (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5).round()
		UiKit.draw_shadow(self, font, at, _text, font_size)
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


## The band between two outlines of the bar (a frame line that leaves the inside open, so the empty part can be
## translucent).
func _ring(from: Rect2, to: Rect2, color: Color) -> void:
	var a := shape(from)
	var b := shape(to)
	for i in a.size():
		var j := (i + 1) % a.size()
		draw_colored_polygon(PackedVector2Array([a[i], a[j], b[j], b[i]]), color)


## Fills the part of the body between the ratios x0 and x1 and the heights y0 and y1, from top (at y0) to bottom (at y1).
func _band(body: PackedVector2Array, x0: float, x1: float, top: Color, bottom: Color, y0: float, y1: float) -> void:
	if x1 <= maxf(x0, 0.0):
		return
	var left := -1.0 if x0 <= 0.0 else size.x * x0
	var clip := PackedVector2Array([Vector2(left, y0), Vector2(size.x * x1, y0), Vector2(size.x * x1, y1), Vector2(left, y1)])
	for part in Geometry2D.intersect_polygons(body, clip):
		if _area(part) < 0.5:
			continue  # a sliver at the pointed end: nothing to see, and it cannot be triangulated
		var colors := PackedColorArray()
		for p in part:
			colors.append(top.lerp(bottom, clampf((p.y - y0) / maxf(y1 - y0, 0.001), 0.0, 1.0)))
		draw_polygon(part, colors)


static func _area(poly: PackedVector2Array) -> float:
	var twice := 0.0
	for i in poly.size():
		twice += poly[i].cross(poly[(i + 1) % poly.size()])
	return absf(twice) * 0.5
