class_name BoonIcon
extends Control
## A gift's medallion, drawn in code: a round gem in the family's colour and a simple glyph for the gift.
## cooldown (0..1) darkens the part of the medallion that is still recharging.

## Glyph ids of the bare actions: ACTION_GLYPH + Boon.Slot (attack, special, circle of light, dodge).
const ACTION_GLYPH := 100

var boon: Boon
var cooldown := 0.0
var level := 0
var max_level := 0


func setup(b: Boon, size_px: float) -> BoonIcon:
	boon = b
	custom_minimum_size = Vector2(size_px, size_px)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


func _draw() -> void:
	if boon == null:
		return
	var s := minf(size.x, size.y)
	var c := Vector2(size.x * 0.5, s * 0.5)
	var r := s * 0.46
	var col := boon.color()
	draw_circle(c, r + s * 0.035, Color(0.85, 0.68, 0.36))
	draw_circle(c, r, col.darkened(0.72))
	draw_circle(c + Vector2(-r * 0.15, -r * 0.18), r * 0.8, col.darkened(0.45))
	draw_circle(c + Vector2(-r * 0.25, -r * 0.3), r * 0.45, col.darkened(0.15))
	glyph(self, boon.icon, c, r * 0.62, Color(1.0, 0.98, 0.9), col.darkened(0.5))
	if cooldown > 0.0:
		var pts := PackedVector2Array([c])
		var steps := 24
		for i in steps + 1:
			var a := -PI * 0.5 + TAU * cooldown * float(i) / steps
			pts.append(c + Vector2(cos(a), sin(a)) * (r + 1.0))
		if pts.size() >= 3:
			draw_colored_polygon(pts, Color(0, 0, 0, 0.6))
	draw_arc(c, r, 0.0, TAU, 48, Color(1.0, 0.9, 0.6, 0.8), maxf(1.5, s * 0.02), true)
	for i in max_level:
		var x := c.x + (i - (max_level - 1) * 0.5) * s * 0.16
		var y := s * 0.98
		draw_circle(Vector2(x, y), s * 0.05, Color(0.1, 0.08, 0.1))
		draw_circle(Vector2(x, y), s * 0.035, col.lightened(0.3) if i < level else Color(0.25, 0.22, 0.25))


## A simple shape per gift (index from Boon.icon), drawn on any control during its _draw (the HUD's action slots too).
## The ids from ACTION_GLYPH up are the bare actions, without a gift (in Boon.Slot order).
static func glyph(ci: CanvasItem, i: int, c: Vector2, r: float, w: Color, accent: Color) -> void:
	var th := maxf(2.0, r * 0.14)
	match i:
		0, 14:  # flame
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
		5:  # great falling blade of ice
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.3, -r), c + Vector2(r * 0.3, -r), c + Vector2(0, r)]), w)
			ci.draw_line(c + Vector2(-r * 0.6, -r * 0.55), c + Vector2(r * 0.6, -r * 0.55), w, th, true)
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
		9, 15:  # shield
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.75, -r * 0.8), c + Vector2(r * 0.75, -r * 0.8), c + Vector2(r * 0.7, 0.1 * r), c + Vector2(0, r), c + Vector2(-r * 0.7, 0.1 * r)]), w)
			ci.draw_line(c + Vector2(0, -r * 0.6), c + Vector2(0, r * 0.6), accent, th, true)
			ci.draw_line(c + Vector2(-r * 0.45, -r * 0.2), c + Vector2(r * 0.45, -r * 0.2), accent, th, true)
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
