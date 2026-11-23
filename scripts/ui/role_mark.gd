class_name RoleMark
extends Control
## An enemy's part in a fight as a small mark in ink (the Compêndio's Inimigos, UI review d2ff05d P2-5), drawn in lines
## like the book's other marks (CodexMark): pressure a blade pointing in, react three chevrons, control an orb with a
## ring, flank an arrow off to the side, block a round shield, swarm three dots, sweep a bar turning on its root, rally a horn, leap four corners in L, throw a line with a head at each end, grave a mound with a shovel, area a diamond with a ring on the floor, a guardian the
## two chevrons of the doors (DoorGlyph). Faded, the "???" of one never defeated.
##   RoleMark.new().setup(&"flank", 22.0)

var role: StringName
var faded := false


func setup(p_role: StringName, px: float, p_faded := false) -> RoleMark:
	role = p_role
	faded = p_faded
	custom_minimum_size = Vector2(px, px)
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.44
	var ink := Book.FADED if faded else Book.INK
	var w := maxf(1.5, r * 0.16)
	if faded:
		draw_arc(c, r * 0.6, 0.0, TAU, 20, Color(ink, 0.6), w * 0.7, true)
		return
	match role:
		&"pressure":
			# a blade pointing in from the upper right
			var tip := c + Vector2(-r * 0.8, r * 0.8)
			var base := c + Vector2(r * 0.55, -r * 0.55)
			draw_line(base, tip, ink, w * 1.4, true)
			draw_line(base + Vector2(-r * 0.35, -r * 0.35), base + Vector2(r * 0.35, r * 0.35), ink, w, true)
			draw_line(base, base + Vector2(r * 0.35, -r * 0.35), ink, w, true)
		&"react":
			for k in 3:
				var x := c.x - r * 0.7 + k * r * 0.55
				draw_polyline(PackedVector2Array([Vector2(x, c.y - r * 0.6), Vector2(x + r * 0.45, c.y), Vector2(x, c.y + r * 0.6)]), ink, w, true)
		&"control":
			draw_circle(c, r * 0.32, ink)
			draw_arc(c, r * 0.78, 0.0, TAU, 24, ink, w, true)
		&"flank":
			var a := c + Vector2(-r * 0.85, r * 0.45)
			var b := c + Vector2(r * 0.85, -r * 0.45)
			draw_line(a, b, ink, w, true)
			var d := (b - a).normalized()
			var n := Vector2(-d.y, d.x)
			draw_colored_polygon(PackedVector2Array([b + d * r * 0.1, b - d * r * 0.45 + n * r * 0.28, b - d * r * 0.45 - n * r * 0.28]), ink)
			draw_line(a, a + d * r * 0.3 + n * r * 0.3, ink, w * 0.8, true)
			draw_line(a, a + d * r * 0.3 - n * r * 0.3, ink, w * 0.8, true)
		&"block":
			draw_arc(c, r * 0.82, 0.0, TAU, 24, ink, w * 1.2, true)
			draw_arc(c, r * 0.4, 0.0, TAU, 16, ink, w * 0.8, true)
			draw_circle(c, r * 0.12, ink)
		&"swarm":
			# three small bodies at the corners of a triangle
			for k in 3:
				draw_circle(c + Vector2.from_angle(-PI * 0.5 + TAU * k / 3.0) * r * 0.52, r * 0.24, ink)
		&"sweep":
			# a bar turning round its root: a quarter of a ring and a line out of the middle
			draw_arc(c, r * 0.8, -PI * 0.1, PI * 0.6, 14, ink, w, true)
			draw_line(c, c + Vector2(r * 0.8, -r * 0.1), ink, w * 1.3, true)
			draw_circle(c, r * 0.16, ink)
		&"rally":
			# a horn: a flared cone with two short lines of sound
			draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.7, -r * 0.12), c + Vector2(-r * 0.7, r * 0.12), c + Vector2(r * 0.15, r * 0.5),
				c + Vector2(r * 0.15, -r * 0.5)]), ink)
			draw_line(c + Vector2(r * 0.4, -r * 0.3), c + Vector2(r * 0.8, -r * 0.5), ink, w * 0.8, true)
			draw_line(c + Vector2(r * 0.4, r * 0.3), c + Vector2(r * 0.8, r * 0.5), ink, w * 0.8, true)
		&"leap":
			# the four corners of a square, each an L
			for sx in [-1.0, 1.0]:
				for sy in [-1.0, 1.0]:
					var corner := c + Vector2(sx, sy) * r * 0.7
					draw_polyline(PackedVector2Array([corner + Vector2(-sx * r * 0.5, 0), corner, corner + Vector2(0, -sy * r * 0.5)]), ink, w, true)
		&"throw":
			# one line out and back: a head at each end
			draw_line(c + Vector2(-r * 0.8, 0), c + Vector2(r * 0.8, 0), ink, w, true)
			draw_polyline(PackedVector2Array([c + Vector2(r * 0.4, -r * 0.4), c + Vector2(r * 0.8, 0), c + Vector2(r * 0.4, r * 0.4)]), ink, w, true)
			draw_polyline(PackedVector2Array([c + Vector2(-r * 0.4, -r * 0.4), c + Vector2(-r * 0.8, 0), c + Vector2(-r * 0.4, r * 0.4)]), ink, w, true)
		&"beam":
			# a long thin beam out of a small ring at its root
			draw_arc(c + Vector2(-r * 0.6, 0), r * 0.26, 0.0, TAU, 12, ink, w, true)
			draw_line(c + Vector2(-r * 0.34, 0), c + Vector2(r * 0.9, 0), ink, w * 1.2, true)
			draw_line(c + Vector2(-r * 0.2, r * 0.22), c + Vector2(r * 0.9, r * 0.22), ink, w * 0.6, true)
		&"trap":
			# an X inside a square: the plate
			draw_rect(Rect2(c - Vector2(r * 0.7, r * 0.7), Vector2(r * 1.4, r * 1.4)), ink, false, w)
			draw_line(c + Vector2(-r * 0.45, -r * 0.45), c + Vector2(r * 0.45, r * 0.45), ink, w, true)
			draw_line(c + Vector2(-r * 0.45, r * 0.45), c + Vector2(r * 0.45, -r * 0.45), ink, w, true)
		&"grave":
			# a mound of earth with a shovel standing in it
			draw_arc(c + Vector2(0, r * 0.5), r * 0.75, PI, TAU, 14, ink, w, true)
			draw_line(c + Vector2(r * 0.3, r * 0.5), c + Vector2(r * 0.3, -r * 0.8), ink, w, true)
			draw_line(c + Vector2(r * 0.12, -r * 0.8), c + Vector2(r * 0.48, -r * 0.8), ink, w, true)
		&"area":
			var gem := PackedVector2Array([c + Vector2(0, -r * 0.55), c + Vector2(r * 0.4, 0), c + Vector2(0, r * 0.55), c + Vector2(-r * 0.4, 0)])
			draw_colored_polygon(gem, ink)
			draw_arc(c + Vector2(0, r * 0.5), r * 0.85, PI * 0.15, PI * 0.85, 12, ink, w, true)
		_:
			# a guardian: the doors' two chevrons
			for k in 2:
				var y := c.y - r * 0.15 + k * r * 0.55
				draw_polyline(PackedVector2Array([Vector2(c.x - r * 0.75, y), Vector2(c.x, y - r * 0.5), Vector2(c.x + r * 0.75, y)]), ink, w * 1.2, true)
