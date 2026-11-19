class_name SealedMark
extends Control
## Something still closed, as a medallion (HUB-C): the HUD crest's ring of old gold round a dark field and a padlock of
## old gold. With a figure (the Livro de Ahk's three sealed places next to the Warrior's crest, D-H3) the field holds a
## hooded silhouette, a shade lighter than the field, with no face, no name and nothing to tell about it; the padlock
## sits at its foot. Without (the Vendedor's and the Forjador's pages, "A definir") the padlock alone, larger.
## Only a drawing: no focus, no click, no tooltip (nothing to choose).
##   row.add_child(SealedMark.new().setup(40.0, true))

const FIELD := Color(0.075, 0.058, 0.05)
const FIGURE := Color(0.33, 0.28, 0.22)
const RING_WIDTH := 2.0

var figure := false


func setup(side: float, with_figure: bool = false) -> SealedMark:
	figure = with_figure
	custom_minimum_size = Vector2(side, side)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	return self


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.5 - 1.0
	draw_circle(c, r, FIELD)
	if figure:
		var disc := _circle(c, r - RING_WIDTH)
		# shoulders: the top of a wide ellipse, cut by the medallion
		var body := PackedVector2Array()
		for i in 25:
			var a := PI + PI * float(i) / 24.0
			body.append(c + Vector2(cos(a) * r * 0.68, r * 0.62 + sin(a) * r * 0.6))
		for part in Geometry2D.intersect_polygons(body, disc):
			draw_colored_polygon(part, FIGURE)
		# the hood: pointed at the top, closed at the face
		draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.3, r * 0.1), c + Vector2(-r * 0.3, -r * 0.24),
			c + Vector2(-r * 0.12, -r * 0.52), c + Vector2(0.0, -r * 0.64), c + Vector2(r * 0.12, -r * 0.52),
			c + Vector2(r * 0.3, -r * 0.24), c + Vector2(r * 0.3, r * 0.1)]), FIGURE)
		ActionSlot.padlock(self, c + Vector2(0, r * 0.6), r * 0.2, UiKit.OLD_GOLD)
	else:
		ActionSlot.padlock(self, c + Vector2(0, r * 0.06), r * 0.42, UiKit.OLD_GOLD)
	draw_arc(c, r, 0.0, TAU, 48, UiKit.OLD_GOLD, RING_WIDTH, true)
	draw_arc(c, r - RING_WIDTH - 1.5, 0.0, TAU, 48, Color(UiKit.OLD_GOLD, 0.35), 1.0, true)


static func _circle(c: Vector2, r: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in 40:
		var a := TAU * float(i) / 40.0
		out.append(c + Vector2(cos(a), sin(a)) * r)
	return out
