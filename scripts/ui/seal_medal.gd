class_name SealMedal
extends Control
## A drawn medallion in the house's seal (the PsalmIcon's: a round seal of ink inside a ring of old gold and a thin
## ivory ring) with an ivory glyph lit in its colour. T5 (A-T5-6), the altar's trades: a pomegranate (what the life
## buys; never a heart, which reads as gaining life on a trade that takes it), a candle's flame (the candles lit for
## Magia) and an open arch (walking on, taking nothing). Never a sun (no rays) nor a cross.
##   var m := SealMedal.new().setup(SealMedal.Glyph.CANDLE, Color(0.98, 0.78, 0.45), 80.0)

enum Glyph { POMEGRANATE, CANDLE, OPEN_ARCH }

const IVORY := Color(0.96, 0.92, 0.82)
const INK := Color(0.07, 0.055, 0.075)
const INK_EDGE := Color(0.03, 0.025, 0.04)

## The glyph's reach against the seal's radius.
const GLYPH := 0.74

var glyph := Glyph.OPEN_ARCH
var tint := UiKit.OLD_GOLD


func setup(g: Glyph, color: Color, size_px: float) -> SealMedal:
	glyph = g
	tint = color
	custom_minimum_size = Vector2(size_px, size_px)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.46
	var w := draw_seal(self, c, r)
	draw_glyph(self, glyph, c, r * GLYPH, maxf(1.2, w * 0.9), tint)


## The seal under any glyph: the ink disc, its dark edge, the ring of old gold and the thin ivory ring inside it (lit:
## full; not: the dim closed seal). Returns the ring's width (the glyph's lines follow it).
static func draw_seal(ci: CanvasItem, c: Vector2, r: float, lit: bool = true, under: Callable = Callable()) -> float:
	var w := maxf(1.0, r * 0.06)
	ci.draw_circle(c, r + w, INK_EDGE)
	ci.draw_circle(c, r, INK)
	if under.is_valid():
		under.call()
	ci.draw_arc(c, r, 0.0, TAU, 48, UiKit.OLD_GOLD if lit else Color(UiKit.OLD_GOLD, 0.55), w * 1.6, true)
	ci.draw_arc(c, r - w * 2.2, 0.0, TAU, 48, Color(IVORY, 0.55 if lit else 0.18), maxf(1.0, w * 0.6), true)
	return w


## A glyph about 2 r across at c: ivory lines, col for the lit part.
static func draw_glyph(ci: CanvasItem, g: Glyph, c: Vector2, r: float, w: float, col: Color) -> void:
	match g:
		Glyph.POMEGRANATE:
			# the fruit: a round body a little wider than tall, its crown of sepals on top, a seed-lit cut on its face
			var body := c + Vector2(0, r * 0.18)
			var br := r * 0.68
			var pts := PackedVector2Array()
			for k in 33:
				var a := TAU * k / 32.0
				pts.append(body + Vector2(cos(a) * br * 1.04, sin(a) * br * 0.96))
			ci.draw_colored_polygon(pts, col)
			ci.draw_circle(body + Vector2(-br * 0.3, -br * 0.28), br * 0.34, Color(col.lightened(0.3), 0.6))
			ci.draw_polyline(pts, IVORY, w, true)
			var top := body + Vector2(0, -br * 0.94)
			var crown := PackedVector2Array([top + Vector2(-r * 0.26, 0), top + Vector2(-r * 0.3, -r * 0.3),
				top + Vector2(-r * 0.12, -r * 0.14), top + Vector2(0, -r * 0.36), top + Vector2(r * 0.12, -r * 0.14),
				top + Vector2(r * 0.3, -r * 0.3), top + Vector2(r * 0.26, 0)])
			ci.draw_colored_polygon(crown, col.darkened(0.2))
			ci.draw_polyline(crown, IVORY, w * 0.85, true)
			for k in 3:
				ci.draw_circle(body + Vector2((k - 1) * br * 0.32, br * 0.2 + absf(k - 1) * br * 0.1), w * 0.9, IVORY)
		Glyph.CANDLE:
			# a short candle of ivory wax, its wick, and the flame: a fine point, an ivory core, an old gold edge
			var wax := Rect2(c + Vector2(-r * 0.22, r * 0.12), Vector2(r * 0.44, r * 0.86))
			ci.draw_rect(wax, Color(IVORY, 0.9))
			ci.draw_line(wax.position + Vector2(0, r * 0.12), wax.position + Vector2(wax.size.x, r * 0.06), Color(INK, 0.5), w * 0.6, true)
			ci.draw_line(c + Vector2(0, r * 0.12), c + Vector2(0, -r * 0.02), INK_EDGE, w * 0.8, true)
			var base := c + Vector2(0, -r * 0.02)
			var flame := _flame(base, r * 0.36, r * 0.98)
			ci.draw_colored_polygon(flame, col)
			ci.draw_polyline(flame, UiKit.OLD_GOLD.lightened(0.15), w * 0.7, true)
			ci.draw_colored_polygon(_flame(base + Vector2(0, -r * 0.06), r * 0.16, r * 0.5), IVORY)
		Glyph.OPEN_ARCH:
			# a pointed doorway left open (no leaf, the dark beyond it), a sill, and the way through it as a chevron
			var a := PsalmIcon.arch(c + Vector2(0, r * 0.02), r * 0.62, r * 1.7)
			ci.draw_colored_polygon(a, Color(col.darkened(0.6), 0.7))
			ci.draw_polyline(a, IVORY, w, true)
			ci.draw_line(c + Vector2(-r * 0.9, r * 0.87), c + Vector2(r * 0.9, r * 0.87), IVORY, w, true)
			ci.draw_polyline(PackedVector2Array([c + Vector2(-r * 0.24, r * 0.5), c + Vector2(0, r * 0.2), c + Vector2(r * 0.24, r * 0.5)]),
				col.lightened(0.3), w, true)


## A flame standing on base: width at its belly, height to its fine point (closed polygon).
static func _flame(base: Vector2, width: float, height: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var steps := 12
	for i in steps + 1:
		var t := float(i) / steps
		var y := -height * t
		var half := width * 0.5 * sin(PI * pow(1.0 - t, 0.75)) * (1.0 - t * 0.35)
		pts.append(base + Vector2(half, y))
	for i in range(steps - 1, -1, -1):
		var t := float(i) / steps
		var half := width * 0.5 * sin(PI * pow(1.0 - t, 0.75)) * (1.0 - t * 0.35)
		pts.append(base + Vector2(-half, -height * t))
	return pts
