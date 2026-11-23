class_name BoonIcon
extends Control
## A gift's medallion, drawn in code: a round gem in the family's colour and a simple glyph for the gift.
## An Elo (a gift forged from two others) has a rim of chain links.
## cooldown (0..1) darkens the part of the medallion that is still recharging.

## Glyph ids of the bare actions: ACTION_GLYPH + Boon.Slot (attack, special, circle of light, dodge, Investida, ultimate: 100 to 106).
const ACTION_GLYPH := 100
## Glyph ids of the ultimates: ULT_GLYPH + UltDef.Kind (the cleave, the Voragem).
const ULT_GLYPH := 110
## The glyph of the Brado de Guerra (E): a mouth with the cry rippling out in arcs.
const SHOUT_GLYPH := 120
## The Investida (E): a thrust with its speed lines.
const RUSH_GLYPH := 121
## The Maga's marks (M1b): the shot, the Explosão Rúnica, the Suspensão Arcana, the Tempestade dos Selos (ULT_GLYPH + Kind.STORM).
const BOLT_GLYPH := 130
const BLAST_GLYPH := 131
const DOME_GLYPH := 132
## Glyph of the most Magia (T5, the Provação's Reserva): a cut crystal with a light down its middle.
const MAGICK_GLYPH := 107

var boon: Boon
var cooldown := 0.0
var level := 0
var max_level := 0
## Without a Boon (T5, the Provação's blessing, setup_glyph): the glyph and the gem's colour to draw.
var icon := -1
var tint := Color.WHITE


func setup(b: Boon, size_px: float) -> BoonIcon:
	boon = b
	custom_minimum_size = Vector2(size_px, size_px)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


## The same medallion for something that is not a Boon (a glyph and a colour): no levels, no Elo rim.
func setup_glyph(glyph_id: int, color: Color, size_px: float) -> BoonIcon:
	icon = glyph_id
	tint = color
	return setup(null, size_px)


## The rim of a drawn medallion, the one the painted PNGs wear (assets/ui/boons/vapor.png, measured on its radius, AP-4
## 2.3): from the outside in, a dark edge, bronze, a groove, a lit bead, bronze, a groove, a dull band and the shadow it
## throws inside. RING_BANDS: (from, to) as shares of the width from the outer edge, and the colour (sRGB, luma about
## 55 on average, as the PNG's).
const RING_BANDS := [
	[0.0, 0.08, Color8(40, 27, 14)], [0.08, 0.26, Color8(85, 59, 32)], [0.26, 0.33, Color8(58, 38, 19)],
	[0.33, 0.43, Color8(102, 77, 48)], [0.43, 0.55, Color8(82, 55, 29)], [0.55, 0.68, Color8(49, 33, 21)],
	[0.68, 0.95, Color8(73, 51, 37)], [0.95, 1.0, Color8(52, 33, 22)]]
## The painted rim is this wide at the card's size (PAINTED 128 px at 720: 0.19 of its 64 px radius); smaller icons
## (HUD, Elo sources) take RING_SHARE of their size.
const RING_PX := 12.2
const RING_SHARE := 0.12
## The shadow the rim throws inside: this wide (share of the rim) and this dark.
const RING_SHADOW := 0.35
const RING_SHADOW_ALPHA := 0.45


static func ring_width(s: float) -> float:
	return minf(RING_PX, s * RING_SHARE)


## Draws the rim with its outer edge at radius outer, w wide.
static func ring(ci: CanvasItem, c: Vector2, outer: float, w: float) -> void:
	var inner := outer - w
	ci.draw_arc(c, inner - w * RING_SHADOW * 0.5, 0.0, TAU, 64, Color(0, 0, 0, RING_SHADOW_ALPHA), w * RING_SHADOW, true)
	for band: Array in RING_BANDS:
		var a: float = band[0]
		var b: float = band[1]
		ci.draw_arc(c, outer - w * (a + b) * 0.5, 0.0, TAU, 64, band[2], maxf(1.0, w * (b - a)) + 0.5, true)


func _draw() -> void:
	if boon == null and icon < 0:
		return
	var s := minf(size.x, size.y)
	var c := Vector2(size.x * 0.5, s * 0.5)
	var r := s * 0.46
	var col := boon.color() if boon != null else tint
	var w := ring_width(s)
	draw_circle(c, r, col.darkened(0.72))
	draw_circle(c + Vector2(-r * 0.15, -r * 0.18), r * 0.8, col.darkened(0.45))
	draw_circle(c + Vector2(-r * 0.25, -r * 0.3), r * 0.45, col.darkened(0.15))
	glyph(self, boon.icon if boon != null else icon, c, r * 0.62, Color(1.0, 0.98, 0.9), col.darkened(0.5))
	if cooldown > 0.0:
		var pts := PackedVector2Array([c])
		var steps := 24
		for i in steps + 1:
			var a := -PI * 0.5 + TAU * cooldown * float(i) / steps
			pts.append(c + Vector2(cos(a), sin(a)) * (r + 1.0))
		if pts.size() >= 3:
			draw_colored_polygon(pts, Color(0, 0, 0, 0.6))
	ring(self, c, r + s * 0.035, w)
	if boon == null:
		return
	if boon.is_duo():
		# an Elo wears a rim of chain links (see EloLink)
		EloLink.ring(self, c, r + s * 0.02, maxf(6.0, s * 0.15))
	for i in max_level:
		var x := c.x + (i - (max_level - 1) * 0.5) * s * 0.16
		var y := s * (1.06 if boon.is_duo() else 0.98)  # under the chain rim of an Elo
		draw_circle(Vector2(x, y), s * 0.05, Color(0.1, 0.08, 0.1))
		draw_circle(Vector2(x, y), s * 0.035, col.lightened(0.3) if i < level else Color(0.25, 0.22, 0.25))


## A simple shape per gift (index from Boon.icon), drawn on any control during its _draw (the HUD's action slots too).
## The ids from ACTION_GLYPH up are the bare actions, without a gift (in Boon.Slot order).
static func glyph(ci: CanvasItem, i: int, c: Vector2, r: float, w: Color, accent: Color) -> void:
	var th := maxf(2.0, r * 0.14)
	match i:
		0:  # Brasas: three embers falling, small to large, each a bead of fire with its tail (the painted medallion's)
			var fall := Vector2(0.45, 0.89)
			for e: Vector3 in [Vector3(-0.5, -0.6, 0.13), Vector3(-0.45, 0.02, 0.17), Vector3(0.22, 0.3, 0.27)]:
				var p := c + Vector2(e.x, e.y) * r
				var side := fall.orthogonal() * e.z * r
				ci.draw_colored_polygon(PackedVector2Array([p + side, p - fall * e.z * r * 3.2, p - side]), w)
				ci.draw_circle(p, e.z * r, w)
		14:  # flame
			flame(ci, c, r, w)
		1:  # whirl of fire: three arcs
			for k in 3:
				ci.draw_arc(c, r * (0.35 + k * 0.25), k * 2.1, k * 2.1 + 3.6, 20, w, th, true)
		2:  # burning blade
			sword(ci, c, r, w, th)
			flame(ci, c + Vector2(r * 0.45, r * 0.25), r * 0.45, Color(1.0, 0.75, 0.4))
		3:  # snowflake
			for k in 6:
				var a := TAU * k / 6.0
				var d := Vector2(cos(a), sin(a))
				ci.draw_line(c, c + d * r, w, th, true)
				ci.draw_line(c + d * r * 0.55, c + d * r * 0.55 + d.rotated(0.8) * r * 0.3, w, th * 0.7, true)
				ci.draw_line(c + d * r * 0.55, c + d * r * 0.55 + d.rotated(-0.8) * r * 0.3, w, th * 0.7, true)
		4:  # shards bursting out
			for k in 7:
				var a := TAU * k / 7.0
				var d := Vector2(cos(a), sin(a))
				ci.draw_colored_polygon(PackedVector2Array([c + d * r * 0.25 + d.orthogonal() * r * 0.12, c + d * r, c + d * r * 0.25 - d.orthogonal() * r * 0.12]), w)
		5:  # great falling shard of ice: a faceted icicle with two chips beside it, no bar across (QW-117: it read "†")
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.36, -r), c + Vector2(r * 0.12, -r * 0.92),
				c + Vector2(r * 0.34, -r * 0.55), c + Vector2(0, r)]), w)
			ci.draw_line(c + Vector2(-r * 0.05, -r * 0.92), c + Vector2(0, r * 0.7), accent, th * 0.6, true)
			for chip: Vector3 in [Vector3(-0.62, 0.35, 0.16), Vector3(0.58, 0.55, 0.13)]:
				var p := c + Vector2(chip.x, chip.y) * r
				var k := chip.z * r
				ci.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -k * 1.6), p + Vector2(k, 0), p + Vector2(0, k * 1.2), p + Vector2(-k, 0)]), w)
		6:  # heart
			ci.draw_circle(c + Vector2(-r * 0.32, -r * 0.2), r * 0.38, w)
			ci.draw_circle(c + Vector2(r * 0.32, -r * 0.2), r * 0.38, w)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.68, -r * 0.05), c + Vector2(r * 0.68, -r * 0.05), c + Vector2(0, r * 0.8)]), w)
		7, 13:  # tide of light: crescents
			for k in 3:
				ci.draw_arc(c + Vector2(-r * 0.5 + k * r * 0.45, 0), r * 0.6, -1.1, 1.1, 16, w, th, true)
		8:  # pillar of light with rays
			ci.draw_rect(Rect2(c + Vector2(-r * 0.18, -r), Vector2(r * 0.36, r * 2.0)), w)
			for k in 4:
				var a := -PI * 0.5 + (k - 1.5) * 0.5
				ci.draw_line(c + Vector2(0, r * 0.6), c + Vector2(0, r * 0.6) + Vector2(cos(a), sin(a)) * r * 0.9, w, th * 0.6, true)
		9, 15:  # the watch's shield: a chevron rising over a small diamond of light (QW-117: the four-pointed star on it
			# read as a cross at 16 px; never a cross)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.75, -r * 0.8), c + Vector2(r * 0.75, -r * 0.8), c + Vector2(r * 0.7, 0.1 * r), c + Vector2(0, r), c + Vector2(-r * 0.7, 0.1 * r)]), w)
			ci.draw_polyline(PackedVector2Array([c + Vector2(-r * 0.46, -r * 0.05), c + Vector2(0, -r * 0.5), c + Vector2(r * 0.46, -r * 0.05)]),
				accent, th * 1.3, true)
			var g := c + Vector2(0, r * 0.3)
			var d := r * 0.2
			ci.draw_colored_polygon(PackedVector2Array([g + Vector2(0, -d), g + Vector2(d * 0.8, 0), g + Vector2(0, d), g + Vector2(-d * 0.8, 0)]), accent)
		10, 16, 17:  # wing (light steps)
			for k in 4:
				var y := -r * 0.6 + k * r * 0.38
				ci.draw_line(c + Vector2(-r * 0.6, y + r * 0.2), c + Vector2(r * (0.7 - k * 0.15), y), w, th * 1.2, true)
		11:  # tower of the vow
			ci.draw_rect(Rect2(c + Vector2(-r * 0.45, -r * 0.5), Vector2(r * 0.9, r * 1.4)), w)
			for k in 3:
				ci.draw_rect(Rect2(c + Vector2(-r * 0.45 + k * r * 0.33, -r * 0.85), Vector2(r * 0.22, r * 0.35)), w)
		12:  # steam: clouds
			for k in 3:
				ci.draw_circle(c + Vector2(-r * 0.4 + k * r * 0.4, -r * 0.05 * k), r * 0.36, w)
		20:  # Veu (AN-2): a veil folded into a drop, a fold down its middle
			var top := c + Vector2(0, -r * 0.8)
			var drop := PackedVector2Array([top])
			for k in 13:
				var a := lerpf(-0.75, PI + 0.75, float(k) / 12.0)
				drop.append(c + Vector2(0, r * 0.2) + Vector2(cos(a), sin(a)) * r * 0.55)
			ci.draw_colored_polygon(drop, w)
			ci.draw_line(c + Vector2(0, -r * 0.4), c + Vector2(0, r * 0.62), accent, th * 0.9, true)
		21:  # Mare (AN-2): two stacked waves
			for k in 2:
				var line := PackedVector2Array()
				for j in 11:
					var t := float(j) / 10.0
					line.append(c + Vector2(-r * 0.75 + t * r * 1.5, (k - 0.5) * r * 0.7 - sin(t * TAU) * r * 0.2))
				ci.draw_polyline(line, w, th * 1.3, true)
		22:  # Marca (AN-2): an arrowhead inside a ring
			ci.draw_arc(c, r * 0.72, 0.0, TAU, 28, w, th * 0.8, true)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r * 0.5), c + Vector2(r * 0.24, r * 0.18), c + Vector2(0, 0.0), c + Vector2(-r * 0.24, r * 0.18)]), w)
			ci.draw_line(c, c + Vector2(0, r * 0.5), w, th, true)
		101:  # the sword
			sword(ci, c, r * 1.1, w, th)
		102:  # the arrow of light
			var tip := c + Vector2(r * 0.8, -r * 0.8)
			ci.draw_line(c + Vector2(-r * 0.75, r * 0.75), tip, w, th, true)
			ci.draw_colored_polygon(PackedVector2Array([tip + Vector2(r * 0.15, -r * 0.15), tip + Vector2(-r * 0.55, 0.0), tip + Vector2(0.0, r * 0.55)]), w)
			ci.draw_line(c + Vector2(-r * 0.75, r * 0.75), c + Vector2(-r * 0.75, r * 0.3), w, th * 0.8, true)
			ci.draw_line(c + Vector2(-r * 0.75, r * 0.75), c + Vector2(-r * 0.3, r * 0.75), w, th * 0.8, true)
		103:  # the circle of light around a point
			ci.draw_arc(c, r * 0.8, 0.0, TAU, 32, w, th, true)
			ci.draw_circle(c, r * 0.22, w)
			for k in 4:
				var d := Vector2.from_angle(TAU * k / 4.0 + PI * 0.25)
				ci.draw_line(c + d * r * 0.38, c + d * r * 0.62, w, th * 0.8, true)
		104:  # the dash: two chevrons forward with speed lines behind
			for k in 2:
				var x := -r * 0.1 + k * r * 0.45
				ci.draw_polyline(PackedVector2Array([c + Vector2(x - r * 0.3, -r * 0.55), c + Vector2(x + r * 0.15, 0.0), c + Vector2(x - r * 0.3, r * 0.55)]), w, th, true)
			for k in 3:
				var y := (k - 1) * r * 0.4
				ci.draw_line(c + Vector2(-r * (0.95 - absf(k - 1) * 0.2), y), c + Vector2(-r * 0.45, y), w, th * 0.8, true)
		120:  # the Brado: the cry as three arcs spreading out of a point, to both sides
			ci.draw_circle(c, r * 0.2, w)
			for k in 3:
				var rad := r * (0.45 + k * 0.28)
				ci.draw_arc(c, rad, -0.75, 0.75, 14, w, th, true)
				ci.draw_arc(c, rad, PI - 0.75, PI + 0.75, 14, w, th, true)
		121:  # the Investida: a pointed blade driving right, three speed lines behind it
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(r * 0.95, 0), c + Vector2(r * 0.1, -r * 0.34), c + Vector2(-r * 0.1, 0), c + Vector2(r * 0.1, r * 0.34)]), w)
			for k in 3:
				var y := (k - 1) * r * 0.5
				ci.draw_line(c + Vector2(-r * 0.95, y), c + Vector2(-r * (0.3 - absf(k - 1) * 0.1), y), w, th * 0.8, true)
		MAGICK_GLYPH:  # the most Magia: a cut gem (table, girdle, a point below), its facets in a V; never a cross
			var gem := PackedVector2Array([c + Vector2(-r * 0.42, -r * 0.6), c + Vector2(r * 0.42, -r * 0.6), c + Vector2(r * 0.85, -r * 0.15),
				c + Vector2(0, r * 0.9), c + Vector2(-r * 0.85, -r * 0.15)])
			ci.draw_colored_polygon(gem, w)
			for x in [-0.42, 0.42]:
				ci.draw_line(c + Vector2(r * x, -r * 0.6), c + Vector2(0, r * 0.9), accent, th * 0.7, true)
				ci.draw_line(c + Vector2(r * x, -r * 0.6), c + Vector2(r * x * 2.0, -r * 0.15), accent, th * 0.6, true)
		110:  # the cleave: a blade without its guard driving down aslant into a split in the floor, two chips flying
			# (QW-117: blade and guard upright read as a cross)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.62, -r * 0.95), c + Vector2(-r * 0.34, -r * 0.98),
				c + Vector2(r * 0.12, r * 0.45), c + Vector2(-r * 0.04, r * 0.5)]), w)
			for chip: Vector3 in [Vector3(-0.55, 0.3, 0.12), Vector3(0.5, 0.2, 0.1)]:
				var p := c + Vector2(chip.x, chip.y) * r
				var k := chip.z * r
				ci.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -k), p + Vector2(k, 0), p + Vector2(0, k), p + Vector2(-k, 0)]), w)
			ci.draw_polyline(PackedVector2Array([c + Vector2(-r * 0.9, r * 0.75), c + Vector2(-r * 0.4, r * 0.6), c + Vector2(-r * 0.1, r * 0.85),
				c + Vector2(r * 0.3, r * 0.6), c + Vector2(r * 0.9, r * 0.75)]), w, th, true)
		111:  # the Voragem: three arms turning into the middle
			for k in 3:
				var pts := PackedVector2Array()
				for j in 9:
					var t := float(j) / 8.0
					pts.append(c + Vector2.from_angle(TAU * k / 3.0 + t * 2.4) * r * (0.95 - 0.8 * t))
				ci.draw_polyline(pts, w, th, true)
			ci.draw_circle(c, r * 0.14, w)
		130:  # the Maga's shot: a bolt flying right with a bright head and two trailing sparks
			ci.draw_circle(c + Vector2(r * 0.45, 0), r * 0.32, w)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(r * 0.45, -r * 0.28), c + Vector2(-r * 0.9, 0), c + Vector2(r * 0.45, r * 0.28)]), w)
			for y in [-0.5, 0.5]:
				ci.draw_line(c + Vector2(-r * 0.2, r * y), c + Vector2(-r * 0.85, r * y), w, th * 0.8, true)
		131:  # the Explosão Rúnica: a hexagon of the seal with a burst of rays out of its middle
			var hex := PackedVector2Array()
			for k in 7:
				hex.append(c + Vector2.from_angle(TAU * k / 6.0 + PI / 6.0) * r * 0.9)
			ci.draw_polyline(hex, w, th, true)
			for k in 6:
				var d := Vector2.from_angle(TAU * k / 6.0)
				ci.draw_line(c + d * r * 0.2, c + d * r * 0.65, w, th * 0.9, true)
		132:  # the Suspensão Arcana: a dome over a line of ground, a small seal under it
			ci.draw_arc(c + Vector2(0, r * 0.45), r * 0.9, PI, TAU, 24, w, th, true)
			ci.draw_line(c + Vector2(-r * 0.95, r * 0.45), c + Vector2(r * 0.95, r * 0.45), w, th, true)
			ci.draw_circle(c + Vector2(0, r * 0.05), r * 0.2, w)
		112:  # the Tempestade dos Selos: three seals (rings) falling in a staggered column
			for k in 3:
				var p := c + Vector2((k - 1) * r * 0.55, (1 - k % 2) * r * 0.1 + (k - 1) * r * 0.1)
				ci.draw_arc(p, r * 0.34, 0.0, TAU, 16, w, th, true)
				ci.draw_circle(p, r * 0.08, w)
		_:
			ci.draw_circle(c, r * 0.5, w)


static func flame(ci: CanvasItem, c: Vector2, r: float, w: Color) -> void:
	var pts := PackedVector2Array()
	for k in 20:
		var t := float(k) / 19.0
		var a := t * TAU
		var rr := r * (0.55 + 0.1 * sin(a * 3.0))
		var p := Vector2(sin(a) * rr * 0.75, -cos(a) * rr)
		if p.y < 0.0:
			p.x *= 1.0 + p.y / r * 0.8
			p.y *= 1.5
		pts.append(c + p + Vector2(0, r * 0.25))
	ci.draw_colored_polygon(pts, w)


static func sword(ci: CanvasItem, c: Vector2, r: float, w: Color, th: float) -> void:
	ci.draw_line(c + Vector2(-r * 0.7, r * 0.7), c + Vector2(r * 0.6, -r * 0.6), w, th * 1.4, true)
	ci.draw_line(c + Vector2(-r * 0.75, r * 0.25), c + Vector2(-r * 0.25, r * 0.75), w, th, true)
