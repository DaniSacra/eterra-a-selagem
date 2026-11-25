class_name StarGlyph
extends RefCounted
## The drawn star of the constellation screens (SW-M1): a soft halo and a four-pointed glint, by code (no image). Used by the
## Videira's figures and by the Dons' lit nodes.

const POINTS := 4


## A four-pointed star of radius `r` (the tips) with a waist of `r * waist`, in `col`.
static func spikes(ci: CanvasItem, c: Vector2, r: float, col: Color, waist := 0.22) -> void:
	var pts := PackedVector2Array()
	for i in POINTS * 2:
		var a := TAU * i / (POINTS * 2) - PI * 0.5
		pts.append(c + Vector2.from_angle(a) * (r if i % 2 == 0 else r * waist))
	ci.draw_colored_polygon(pts, col)


## The halo: `layers` discs growing from `r` out to `r * reach`, each a faint share of `col`.
static func halo(ci: CanvasItem, c: Vector2, r: float, col: Color, reach := 3.0, layers := 5) -> void:
	for k in layers:
		var f := 1.0 - float(k) / layers
		ci.draw_circle(c, r * (1.0 + (reach - 1.0) * f), Color(col, col.a / layers * 1.4))


## A lit star: halo, glint, white-hot core.
static func lit(ci: CanvasItem, c: Vector2, r: float, tint: Color, alpha := 1.0) -> void:
	halo(ci, c, r, Color(tint, 0.34 * alpha))
	spikes(ci, c, r * 2.2, Color(tint.lightened(0.35), 0.9 * alpha))
	ci.draw_circle(c, r, Color(tint.lightened(0.5), alpha))
	ci.draw_circle(c, r * 0.5, Color(1, 1, 1, alpha))
