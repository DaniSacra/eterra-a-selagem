class_name PsalmIcon
extends Control
## A Psalm's medallion (E4-03): a round seal of ink inside a ring of old gold and a thin ivory ring, with a pointed
## arch (the catacombs' window, the Psalms' own mark) in the Psalm's colour behind an ivory glyph of what it does to
## its action. Never a sun (no rays) nor a cross, never a number. Used by the card, the "Salmo descoberto" greeting
## and the Compendium; psalm null draws the closed seal of a Psalm not found yet (a dim arch, no glyph).

const IVORY := Color(0.96, 0.92, 0.82)
## The arch behind the glyph: its share of the radius (half width, height) and how dark the Psalm's colour is there.
const ARCH_W := 0.56
const ARCH_H := 0.94
const ARCH_DARK := 0.55

var psalm: PsalmDef


func setup(p: PsalmDef, size_px: float) -> PsalmIcon:
	psalm = p
	custom_minimum_size = Vector2(size_px, size_px)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


## The Psalm's colour as the interface shows it: its light, a little paler (old gold and emerald stay, never bright).
static func tint(p: PsalmDef) -> Color:
	return p.color.lightened(0.18) if p != null else UiKit.DIM


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.46
	var col := tint(psalm)
	SealMedal.draw_seal(self, c, r, psalm != null, func() -> void:
		draw_colored_polygon(arch(c + Vector2(0, r * 0.08), r * ARCH_W, r * ARCH_H), Color(col.darkened(ARCH_DARK), 0.75) if psalm else Color(UiKit.DIM, 0.25)))
	if psalm != null:
		glyph(self, psalm.effect, c + Vector2(0, r * 0.08), r * 0.5, IVORY, col)
	# the rim of the painted medallions (AP-4 2.3), over the seal's own
	var s := minf(size.x, size.y)
	BoonIcon.ring(self, c, s * 0.495, BoonIcon.ring_width(s))


## A pointed arch of this half width and height centred on centre: straight sides, then two arcs meeting in a point
## (an equilateral arch, each side centred on the opposite springing, squeezed to the height asked).
static func arch(centre: Vector2, half_w: float, height: float) -> PackedVector2Array:
	var foot := centre.y + height * 0.5
	var top := height * 0.55
	var spring := foot - (height - top)
	var squeeze := top / (2.0 * half_w * sin(TAU / 3.0))
	var steps := 10
	var pts := PackedVector2Array([Vector2(centre.x - half_w, foot)])
	for i in steps + 1:
		var a := lerpf(PI, TAU / 3.0, float(i) / steps)
		pts.append(Vector2(centre.x + half_w + 2.0 * half_w * cos(a), spring - 2.0 * half_w * sin(a) * squeeze))
	for i in range(steps - 1, -1, -1):
		var a := lerpf(PI, TAU / 3.0, float(i) / steps)
		pts.append(Vector2(centre.x - half_w - 2.0 * half_w * cos(a), spring - 2.0 * half_w * sin(a) * squeeze))
	pts.append(Vector2(centre.x + half_w, foot))
	return pts


## The glyph of an effect at c, about 2 r across: ivory lines with the Psalm's colour as the lit part.
static func glyph(ci: CanvasItem, effect: PsalmDef.Effect, c: Vector2, r: float, ink: Color, col: Color) -> void:
	var w := maxf(1.2, r * 0.14)
	match effect:
		PsalmDef.Effect.SENTINEL:
			# the circle of light that walks with him: a ring with three marks on it and his place in the middle
			ci.draw_arc(c, r * 0.82, 0.0, TAU, 32, ink, w, true)
			for k in 3:
				var p := c + Vector2.from_angle(-PI * 0.5 + TAU * k / 3.0) * r * 0.82
				_diamond(ci, p, w * 1.6, col.lightened(0.3))
			_diamond(ci, c, w * 1.3, ink)
		PsalmDef.Effect.SHELTER:
			# a dome of light on the ground with a shot breaking on it
			ci.draw_arc(c + Vector2(0, r * 0.45), r * 0.9, PI, TAU, 24, ink, w, true)
			ci.draw_line(c + Vector2(-r, r * 0.45), c + Vector2(r, r * 0.45), ink, w * 0.8, true)
			var hit := c + Vector2(r * 0.5, -r * 0.3)
			for k in 3:
				ci.draw_line(hit, hit + Vector2.from_angle(-PI * 0.15 + k * 0.55) * r * 0.32, col.lightened(0.3), w * 0.7, true)
		PsalmDef.Effect.FLOCK:
			# three lights gathering to one
			var to := c + Vector2(0, r * 0.45)
			for k in 3:
				var from := c + Vector2((k - 1) * r * 0.75, -r * 0.55 + absf(k - 1) * r * 0.25)
				ci.draw_line(from, from.lerp(to, 0.62), Color(ink, 0.6), w * 0.6, true)
				_diamond(ci, from, w * 1.5, col.lightened(0.3))
			_diamond(ci, to, w * 2.2, ink)
		PsalmDef.Effect.STONE:
			# a standing stone on the ground, a crack of light down its face
			var stone := PackedVector2Array([c + Vector2(-r * 0.5, r * 0.6), c + Vector2(-r * 0.55, -r * 0.35),
				c + Vector2(-r * 0.15, -r * 0.8), c + Vector2(r * 0.45, -r * 0.55), c + Vector2(r * 0.5, r * 0.6)])
			ci.draw_colored_polygon(stone, Color(ink, 0.22))
			stone.append(stone[0])
			ci.draw_polyline(stone, ink, w * 0.8, true)
			ci.draw_polyline(PackedVector2Array([c + Vector2(-r * 0.05, -r * 0.55), c + Vector2(r * 0.1, -r * 0.1),
				c + Vector2(-r * 0.05, r * 0.2), c + Vector2(r * 0.08, r * 0.55)]), col.lightened(0.35), w * 0.7, true)
			ci.draw_line(c + Vector2(-r, r * 0.6), c + Vector2(r, r * 0.6), ink, w * 0.8, true)


static func _diamond(ci: CanvasItem, c: Vector2, d: float, col: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]), col)
