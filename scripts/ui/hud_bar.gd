class_name HudBar
extends Control
## A framed bar with a pointed end (life, Magia, the boss): the HUD's line of old gold over ink, an empty part in dark
## translucent slate (the floor shows through, it is never a black hole), the fill in a gradient (light at the top,
## dark at the bottom) with a sheen on top, a pale trail that shows for a moment what a hit took, a short glint at the
## fill's end whenever the value changes, an optional thin second bar on top (the boss's armour), the numbers in
## the middle, and for a boss the marks where his phases begin and a veil of his shield while it stands.
## Boss marks: dark notches ahead of his life; the ones his life has passed turn to old gold with a small diamond,
## and the one just reached flashes (MARK_FLASH seconds). The shield: the frame in its colour and slanted bands that
## drift along a thin veil, so the bar reads as warded while his life stays readable under it.
## The ritual's count (QW-005): a row of diamonds set in the middle of the bar, one for each dead that breaks the
## shield; the ones still standing glow in the shield's colour inside old gold, the fallen go dark and hollow, and the
## one that just fell flashes (SEAL_FLASH seconds).

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
## GP-1: quiet ticks at these shares of the bar (the Magia's: where the Esmagador, the Corte Circular and the Lança cost).
var ticks := PackedFloat32Array():
	set(v):
		if v != ticks:
			ticks = v
			queue_redraw()
## HUD v3: the number stands at the right end (inside the point) instead of the middle, and the frame is drawn by someone else
## (StatBar puts the painted bar_frame over it) when framed is false.
var text_right := false
var framed := true
## The boss's shield stands (0..1): the bar is veiled in its colour and framed in it.
var shield := 0.0
var shield_color := Color(0.4, 1.0, 0.75)
const MARK := Color(0.05, 0.04, 0.06, 0.9)
const MARK_WIDTH := 2.0
const MARK_FLASH := 0.9
## The shield: veil opacity, the bands' opacity, width, spacing and drift (pixels a second).
const SHIELD_VEIL := 0.22
const SHIELD_BAND := 0.5
const SHIELD_BAND_WIDTH := 4.0
const SHIELD_BAND_GAP := 12.0
const SHIELD_DRIFT := 22.0
## The ritual's seals: half the diagonal of a diamond and the gap between their middles, in pixels.
const SEAL := 6.0
const SEAL_GAP := 19.0
const SEAL_FLASH := 0.6
const SEAL_FALLEN := Color(0.07, 0.06, 0.09, 0.95)
## The ritual's dead still standing and how many it began with (0: no ritual, nothing drawn).
var ritual_left := 0
var ritual_total := 0
var _seal_flash := 0.0
var _seal_flash_at := -1
## Marks passed when last looked (-1: not looked yet, so a fight joined late does not flash).
var _reached := -1
var _mark_flash := 0.0
var _flash_at := -1.0
var _drift := 0.0
var _ratio := 1.0
## Where the trail started (the value before the hit) and how long it still shows.
var _trail_from := 1.0
var _trail_t := 0.0
var _tip := 0.0
var _over := 0.0
var _text := ""
## A small mark at the bar's left end (UI 16): none, a heart (life) or a drop (Magia).
enum Mark { NONE, HEART, DROP }
const CAPTION_PX := 12
const MARK_SIZE := 5.0
const MARK_PAD := 11.0
## PT-26: a word at the bar's right end, outside it, so the thin bars say what they are ("Magia", "Supremo").
var caption := "":
	set(v):
		caption = v
		queue_redraw()
var icon := Mark.NONE:
	set(v):
		icon = v
		queue_redraw()


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


## The ritual's count: left of total dead still standing (total 0 hides it). A dead that falls flashes its seal.
func show_ritual(left: int, total: int) -> void:
	left = clampi(left, 0, total)
	if left == ritual_left and total == ritual_total:
		return
	if total == ritual_total and left < ritual_left:
		_seal_flash = 1.0
		_seal_flash_at = left
	ritual_left = left
	ritual_total = total
	queue_redraw()


## Where the middle of the ritual's seal i stands on the bar (pixels).
func seal_at(i: int) -> Vector2:
	return Vector2(size.x * 0.5 + (i - (ritual_total - 1) * 0.5) * SEAL_GAP, size.y * 0.5)


## How many of the boss's marks his life has passed (the phases begun after the first).
func reached() -> int:
	var n := 0
	for m in marks:
		if _ratio <= m:
			n += 1
	return n


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
	if not marks.is_empty():
		var n := reached()
		if _reached >= 0 and n > _reached:
			_mark_flash = 1.0
			_flash_at = marks[n - 1] if n - 1 < marks.size() else -1.0
		_reached = n
	if _mark_flash > 0.0:
		_mark_flash = maxf(0.0, _mark_flash - delta / MARK_FLASH)
		queue_redraw()
	if _seal_flash > 0.0:
		_seal_flash = maxf(0.0, _seal_flash - delta / SEAL_FLASH)
		queue_redraw()
	if shield > 0.0:
		_drift = fposmod(_drift + delta * SHIELD_DRIFT, SHIELD_BAND_GAP)
		queue_redraw()


func _draw() -> void:
	var inner := Rect2(Vector2.ZERO, size)
	if framed:
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
	if shield > 0.0:
		var veil := Color(shield_color, SHIELD_VEIL * shield)
		_band(body, 0.0, 1.0, veil, Color(shield_color.darkened(0.4), SHIELD_VEIL * shield), 0.0, size.y)
		_shield_bands(body, Color(shield_color.lightened(0.3), SHIELD_BAND * shield))
		_ring(inner, inner.grow(UiKit.FRAME), Color(shield_color, shield))
	for m in marks:
		_draw_mark(body, m)
	for t in ticks:
		_band(body, t - 0.5 / size.x, t + 0.5 / size.x, Color(UiKit.PALE, 0.55), Color(UiKit.PALE, 0.55), 0.0, size.y)
	for i in ritual_total:
		_draw_seal(i)
	if icon != Mark.NONE:
		_draw_icon(Vector2(MARK_PAD, size.y * 0.5))
	if caption != "":
		var cf := UiKit.BOLD_FONT
		var at := Vector2(size.x + 6.0, (size.y + cf.get_ascent(CAPTION_PX) - cf.get_descent(CAPTION_PX)) * 0.5).round()
		UiKit.draw_shadow(self, cf, at, caption, CAPTION_PX)
		draw_string(cf, at, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_PX, Color(fill_top.lightened(0.35), 0.9))
	if _text != "":
		var font := UiKit.number_font()
		var w := font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var x := size.x - w - size.y * 0.6 - 6.0 if text_right else (size.x - w) * 0.5
		var at := Vector2(x, (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5).round()
		UiKit.draw_shadow(self, font, at, _text, font_size)
		draw_string_outline(font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, UiKit.INK)
		draw_string(font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, UiKit.PALE)


## The heart or the drop, a pale shape over an ink one.
func _draw_icon(c: Vector2) -> void:
	for pass_i in 2:
		var k := MARK_SIZE + (1.2 if pass_i == 0 else 0.0)
		var col := Color(UiKit.INK, 0.9) if pass_i == 0 else UiKit.PALE
		if icon == Mark.HEART:
			HudArt.heart(self, c, k, col)
		else:
			HudArt.drop(self, c, k, col)


## A boss's phase mark: a dark notch ahead of his life; once passed, old gold with a small diamond over the frame,
## and a flash of light on the one just reached.
func _draw_mark(body: PackedVector2Array, m: float) -> void:
	var half := MARK_WIDTH * 0.5 / size.x
	var x := size.x * m
	if _ratio > m:
		_band(body, m - half, m + half, MARK, MARK, 0.0, size.y)
		return
	var flash := _mark_flash if is_equal_approx(m, _flash_at) else 0.0
	var gold := UiKit.OLD_GOLD.lerp(UiKit.GOLD, 0.5).lerp(UiKit.PALE, flash)
	_band(body, m - half, m + half, gold, gold, 0.0, size.y)
	var d := 3.5 + 3.0 * flash
	for y: float in [-UiKit.FRAME - 1.0, size.y + UiKit.FRAME + 1.0]:
		var c := Vector2(x, y)
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d - 1.5), c + Vector2(d + 1.5, 0), c + Vector2(0, d + 1.5), c + Vector2(-d - 1.5, 0)]), UiKit.INK)
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]), gold)
	if flash > 0.0:
		var glow := Color(UiKit.PALE, 0.5 * flash)
		var w := (6.0 + 22.0 * (1.0 - flash)) / size.x
		_band(body, m - w, m + w, glow, Color(glow, 0.0), 0.0, size.y)


## One of the ritual's seals: ink, an old gold diamond and inside it the shield's glow while its dead stands, a dark
## hollow once it fell (with a short flash of light the moment it falls).
func _draw_seal(i: int) -> void:
	var c := seal_at(i)
	var standing := i < ritual_left
	var flash := _seal_flash if i == _seal_flash_at else 0.0
	if flash > 0.0:
		_diamond(c, SEAL + 2.5 + 8.0 * (1.0 - flash), Color(UiKit.PALE, 0.4 * flash))
	_diamond(c, SEAL + 2.5, UiKit.INK)
	_diamond(c, SEAL + 1.0, UiKit.OLD_GOLD.lerp(UiKit.GOLD, 0.4) if standing else UiKit.OLD_GOLD.darkened(0.35))
	_diamond(c, SEAL - 0.5, shield_color.lightened(0.15) if standing else SEAL_FALLEN.lerp(UiKit.PALE, flash))
	if standing:
		_diamond(c + Vector2(0, -1.5), SEAL * 0.35, Color(UiKit.PALE, 0.55))


func _diamond(c: Vector2, d: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]), color)


## Slanted bands drifting along the bar while the shield stands.
func _shield_bands(body: PackedVector2Array, color: Color) -> void:
	var slant := size.y
	var x := -slant - SHIELD_BAND_GAP + _drift
	while x < size.x:
		var band := PackedVector2Array([Vector2(x + slant, 0), Vector2(x + slant + SHIELD_BAND_WIDTH, 0), Vector2(x + SHIELD_BAND_WIDTH, size.y), Vector2(x, size.y)])
		for part in Geometry2D.intersect_polygons(body, band):
			if _area(part) >= 0.5:
				draw_colored_polygon(part, color)
		x += SHIELD_BAND_GAP


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
