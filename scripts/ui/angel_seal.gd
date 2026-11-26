class_name AngelSeal
extends Control
## The seal of an angel of a family of Bênçãos (Fatia 1, the Encounter: docs/design/rejogabilidade/sistemas.md 3.4 and
## the proposal in section 4; nothing canonical, the names wait for Daniel). Drawn in code, no picture and no AI: the
## house's seal (SealMedal.draw_seal: ink, a ring of old gold, a thin ivory ring) with the family's mark in ivory lines,
## lit in the family's colour. Never a sun (no rays round anything), never a cross (the frost has six arms, never four),
## never the lion (the hero's), never a shield nor an eye.
##   Chama   an ember in a diamond with three tongues of flame on top
##   Geada   a flake of six short arms, each with a pair of twigs
##   Luz     a narrow beam coming down onto a diamond (no rays round it)
##   Vigília the watchman's horn, its bell to the right, a sling hanging from its bands
##   Véu     a veil folded into a drop (Velael)
##   Maré    three stacked waves (Galael)
##   Marca   an arrowhead inside a ring (Qeshael)
## Elo (DUO) has no angel of its own: the two seals side by side (the encounter's pair), so it draws nothing here.
##   var s := AngelSeal.new().setup(Boon.Family.GEADA, 96.0)
##   AngelSeal.mark(canvas_item, Boon.Family.LUZ, centre, radius, width)   # the mark alone, on any canvas

const IVORY := SealMedal.IVORY
## Each family's colour on its seal (the spec's section 4, muted: red earth and old gold, pale ice blue, ivory and old
## gold, petrol): calmer than Boon.FAMILY_COLOR, which is the cards' glow. Indexed by Boon.Family.
## Kept off the colours the fight reserves (ui-ux-designer, the Encontro screen): the Chama an amber earth (hue 24,
## not the danger's red near 350 nor the life's), the Vigília a sage (hue 88: its family's green, but far from the
## Emeth's emerald near 150 and the hero's petrol near 180; it was petrol, hue 177).
const TINT: Array[Color] = [Color(0.82, 0.5, 0.27), Color(0.58, 0.76, 0.88), Color(0.92, 0.82, 0.56), Color(0.58, 0.68, 0.43), UiKit.OLD_GOLD,
	Color(0.7, 0.66, 0.6), Color(0.3, 0.48, 0.78), Color(0.66, 0.58, 0.3), Color("9fae7a"), Color("7d8590")]
## The mark's reach against the seal's radius (SealMedal.GLYPH).
const MARK := 0.74

var family := Boon.Family.LUZ
## Unlit: the closed seal of an angel not met yet (dim ring, the mark at a fifth).
var lit := true


func setup(f: Boon.Family, size_px: float, lit_ := true) -> AngelSeal:
	family = f
	lit = lit_
	custom_minimum_size = Vector2(size_px, size_px)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


## The family's colour on the seal (Elo: old gold).
static func tint(f: Boon.Family) -> Color:
	return TINT[f] if f < TINT.size() else UiKit.OLD_GOLD


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.46
	var w := SealMedal.draw_seal(self, c, r, lit)
	if family == Boon.Family.DUO:
		return
	var col := tint(family)
	if not lit:
		col = Color(col, 0.2)
	mark(self, family, c, r * MARK, maxf(1.2, w * 0.9), col, IVORY if lit else Color(IVORY, 0.2))


## The family's mark about 2 r across at c: ivory lines w wide, col for the lit part.
static func mark(ci: CanvasItem, f: Boon.Family, c: Vector2, r: float, w: float, col: Color, ink: Color = IVORY) -> void:
	match f:
		Boon.Family.CHAMA:
			# the ember: a diamond a little taller than wide, lit inside, three tongues of flame rising from its top
			var d := c + Vector2(0, r * 0.32)
			var gem := _diamond(d, r * 0.46, r * 0.56)
			ci.draw_colored_polygon(gem, col)
			ci.draw_colored_polygon(_diamond(d + Vector2(0, r * 0.08), r * 0.2, r * 0.26), Color(col.lightened(0.45), 0.85))
			ci.draw_polyline(_closed(gem), ink, w, true)
			var top := d + Vector2(0, -r * 0.56)
			for k in 3:
				var x := (k - 1) * r * 0.27
				var tall := r * (0.7 if k == 1 else 0.46)
				var lean := (k - 1) * r * 0.1
				var tongue := _tongue(top + Vector2(x * 0.55, r * 0.06 + absf(k - 1) * r * 0.1), r * 0.2, tall, lean)
				ci.draw_colored_polygon(tongue, col.lightened(0.15))
				ci.draw_polyline(_closed(tongue), ink, w * 0.8, true)
		Boon.Family.GEADA:
			# six short arms (never four: it would read as a cross), each with a pair of twigs, a small hexagon inside
			for k in 6:
				var dir := Vector2.from_angle(-PI * 0.5 + TAU * k / 6.0)
				var tip := c + dir * r * 0.86
				ci.draw_line(c + dir * r * 0.2, tip, ink, w, true)
				var fork := c + dir * r * 0.55
				for side: float in [-1.0, 1.0]:
					ci.draw_line(fork, fork + dir.rotated(side * 0.75) * r * 0.24, ink, w * 0.8, true)
				ci.draw_circle(tip, w * 0.75, col.lightened(0.3))
			var hexagon := PackedVector2Array()
			for k in 7:
				hexagon.append(c + Vector2.from_angle(-PI * 0.5 + TAU * k / 6.0) * r * 0.2)
			ci.draw_colored_polygon(hexagon, col)
			ci.draw_polyline(hexagon, ink, w * 0.8, true)
		Boon.Family.LUZ:
			# a beam coming down onto a diamond (T-2, art re-review: no apex, never a standing stone): a flat top that
			# fades in (alpha 0.2 up there to 0.9 below), widening as it falls to the diamond's width, two thin lines on
			# its edges fading the same way; nothing round it (no rays, no sun, no cross)
			var d := c + Vector2(0, r * 0.5)
			var top_y := -r * 0.9
			var foot_y := r * 0.42
			var top_w := r * 0.14
			var foot_w := r * 0.4
			var faint := Color(col, 0.2 * col.a)
			var full := Color(col, 0.9 * col.a)
			var beam := PackedVector2Array([c + Vector2(-top_w, top_y), c + Vector2(top_w, top_y),
				c + Vector2(foot_w, foot_y), c + Vector2(-foot_w, foot_y)])
			ci.draw_polygon(beam, PackedColorArray([faint, faint, full, full]))
			var ink_faint := Color(ink, 0.15 * ink.a)
			var ink_full := Color(ink, 0.85 * ink.a)
			for side: float in [-1.0, 1.0]:
				var edge := PackedVector2Array([c + Vector2(side * top_w, top_y), c + Vector2(side * foot_w, foot_y)])
				ci.draw_polyline_colors(edge, PackedColorArray([ink_faint, ink_full]), w * 0.6, true)
			var gem := _diamond(d, r * 0.42, r * 0.32)
			ci.draw_colored_polygon(gem, col.lightened(0.2))
			ci.draw_polyline(_closed(gem), ink, w, true)
			# where the beam lands: its light on the diamond's top facets, no rays
			ci.draw_line(d + Vector2(-r * 0.22, -r * 0.15), d + Vector2(0, -r * 0.3), Color(ink, 0.8 * ink.a), w * 0.7, true)
			ci.draw_line(d + Vector2(0, -r * 0.3), d + Vector2(r * 0.22, -r * 0.15), Color(ink, 0.8 * ink.a), w * 0.7, true)
		Boon.Family.VIGILIA:
			# the watchman's horn: a narrow mouthpiece at the left, the tube curving down and up to a flared bell
			# at the right, a sling hanging from its bands
			var tube := PackedVector2Array()
			var lower := PackedVector2Array()
			var steps := 14
			for i in steps + 1:
				var t := float(i) / steps
				var x := lerpf(-0.82, 0.5, t) * r
				var y := (0.18 * sin(t * PI) - 0.08) * r
				var half := r * (0.05 + 0.14 * t * t)
				tube.append(c + Vector2(x, y - half))
				lower.append(c + Vector2(x, y + half))
			var bell_top := tube[tube.size() - 1]
			var bell_bottom := lower[lower.size() - 1]
			var body := PackedVector2Array(tube)
			body.append(bell_top + Vector2(r * 0.3, -r * 0.24))
			body.append(bell_bottom + Vector2(r * 0.3, r * 0.24))
			lower.reverse()
			body.append_array(lower)
			ci.draw_colored_polygon(body, col)
			ci.draw_polyline(_closed(body), ink, w, true)
			# the bell's rim and the bands round the tube, in ivory
			ci.draw_line(bell_top + Vector2(r * 0.3, -r * 0.24), bell_bottom + Vector2(r * 0.3, r * 0.24), ink, w * 1.2, true)
			for t: float in [0.3, 0.62]:
				var i := int(t * steps)
				ci.draw_line(tube[i], body[body.size() - 1 - i], ink, w * 0.8, true)
			# the sling hangs from the two bands (tied to the tube, so it reads as a strap, not a mark of its own)
			var from := body[body.size() - 1 - int(0.3 * steps)]
			var to := body[body.size() - 1 - int(0.62 * steps)]
			var sling := PackedVector2Array()
			for i in 9:
				var t := float(i) / 8.0
				sling.append(from.lerp(to, t) + Vector2(0, 0.2 * r * sin(t * PI)))
			ci.draw_polyline(sling, Color(ink, 0.6 * ink.a), w * 0.6, true)
		Boon.Family.VEU:
			# a veil folded into a drop: the drop's outline, a fold line down its middle and a second, shorter one beside it
			var top := c + Vector2(0, -r * 0.88)
			var drop := PackedVector2Array([top])
			for i in 15:
				var a := lerpf(-0.75, PI + 0.75, float(i) / 14.0)
				drop.append(c + Vector2(0, r * 0.2) + Vector2(cos(a), sin(a)) * r * 0.52)
			ci.draw_colored_polygon(drop, Color(col, col.a * 0.85))
			ci.draw_polyline(_closed(drop), ink, w, true)
			ci.draw_line(c + Vector2(0, -r * 0.5), c + Vector2(0, r * 0.62), ink, w * 0.8, true)
			ci.draw_line(c + Vector2(-r * 0.2, -r * 0.1), c + Vector2(-r * 0.2, r * 0.5), Color(ink, 0.6 * ink.a), w * 0.6, true)
		Boon.Family.MARE:
			# three waves stacked, each a ridge of one swell, the lower ones wider
			for k in 3:
				var y := c.y + (k - 1) * r * 0.42
				var half := r * (0.5 + 0.12 * k)
				var line := PackedVector2Array()
				for i in 13:
					var t := float(i) / 12.0
					line.append(Vector2(c.x - half + t * half * 2.0, y - sin(t * TAU) * r * 0.13))
				ci.draw_polyline(line, ink if k != 1 else col.lightened(0.25), w * (1.0 if k != 1 else 1.3), true)
		Boon.Family.MARCA:
			# an arrowhead pointing up inside a ring
			ci.draw_arc(c, r * 0.8, 0.0, TAU, 40, ink, w * 0.9, true)
			var head := PackedVector2Array([c + Vector2(0, -r * 0.55), c + Vector2(r * 0.26, r * 0.08), c + Vector2(0, -r * 0.04), c + Vector2(-r * 0.26, r * 0.08)])
			ci.draw_colored_polygon(head, col)
			ci.draw_polyline(_closed(head), ink, w, true)
			ci.draw_line(c + Vector2(0, -r * 0.04), c + Vector2(0, r * 0.55), ink, w, true)
			ci.draw_line(c + Vector2(0, r * 0.55), c + Vector2(-r * 0.12, r * 0.42), ink, w * 0.8, true)
			ci.draw_line(c + Vector2(0, r * 0.55), c + Vector2(r * 0.12, r * 0.42), ink, w * 0.8, true)
		Boon.Family.PESTE:
			# a drop with two bubbles rising from it
			var drop := PackedVector2Array([c + Vector2(0, -r * 0.7)])
			for i in 15:
				var a := lerpf(-0.75, PI + 0.75, float(i) / 14.0)
				drop.append(c + Vector2(0, r * 0.28) + Vector2(cos(a), sin(a)) * r * 0.46)
			ci.draw_colored_polygon(drop, Color(col, col.a * 0.85))
			ci.draw_polyline(_closed(drop), ink, w, true)
			ci.draw_arc(c + Vector2(r * 0.42, -r * 0.3), r * 0.1, 0.0, TAU, 12, ink, w * 0.8, true)
			ci.draw_arc(c + Vector2(r * 0.55, -r * 0.62), r * 0.07, 0.0, TAU, 12, ink, w * 0.8, true)
		Boon.Family.TROVAO:
			# a bolt: a zigzag in three strokes with a pointed tip
			var bolt := PackedVector2Array([c + Vector2(r * 0.18, -r * 0.82), c + Vector2(-r * 0.3, r * 0.06), c + Vector2(0, r * 0.06), c + Vector2(-r * 0.18, r * 0.82),
				c + Vector2(r * 0.34, -r * 0.1), c + Vector2(r * 0.04, -r * 0.1)])
			ci.draw_colored_polygon(bolt, col)
			ci.draw_polyline(_closed(bolt), ink, w, true)
		_:
			pass


static func _diamond(c: Vector2, half_w: float, half_h: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(0, -half_h), c + Vector2(half_w, 0), c + Vector2(0, half_h), c + Vector2(-half_w, 0)])


static func _closed(pts: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array(pts)
	out.append(pts[0])
	return out


## A tongue of flame standing on base: its width at the belly, its height to the point, the point leaning sideways.
static func _tongue(base: Vector2, width: float, height: float, lean: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var steps := 8
	for i in steps + 1:
		var t := float(i) / steps
		var half := width * 0.5 * sin(PI * pow(1.0 - t, 0.7)) * (1.0 - t * 0.3)
		pts.append(base + Vector2(half + lean * t * t, -height * t))
	for i in range(steps - 1, 0, -1):
		var t := float(i) / steps
		var half := width * 0.5 * sin(PI * pow(1.0 - t, 0.7)) * (1.0 - t * 0.3)
		pts.append(base + Vector2(-half + lean * t * t, -height * t))
	return pts
