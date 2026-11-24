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


# ---- the lacre of a sealed Gift (Livro de Ahk): a disc of wax on a cord, the Memória's price pressed in it ----

const WAX := Color("7a3a34")
const CORD := Color("5a4630")


## The cord across an entry's paragraph, from `a` to `b` (it sags a little), and the lacre at `at` of radius `r` with
## `number` pressed in it. `crack` 0..1 is the break: the two halves part and fall, the cord lets go (0: whole).
static func lacre(ci: CanvasItem, a: Vector2, b: Vector2, at: Vector2, r: float, number: String, crack: float = 0.0) -> void:
	var cord_alpha := 1.0 - crack
	if cord_alpha > 0.0:
		var pts := PackedVector2Array()
		for i in 13:
			var t := float(i) / 12.0
			pts.append(a.lerp(b, t) + Vector2(0.0, sin(t * PI) * 2.5))
		ci.draw_polyline(pts, Color(CORD, cord_alpha), 2.2, true)
	var fall := crack * crack * r * 1.4
	var apart := crack * r * 0.7
	for side: float in [-1.0, 1.0]:
		var half := PackedVector2Array()
		for i in 13:
			var ang := (PI * 0.5 if side < 0.0 else -PI * 0.5) + PI * float(i) / 12.0
			var k := r if i % 2 == 0 else r * 0.86
			half.append(Vector2(cos(ang), sin(ang)) * k)
		for i in half.size():
			half[i] += at + Vector2(side * apart, fall)
		var col := Color(WAX, 1.0 - crack * 0.8)
		ci.draw_colored_polygon(half, col)
	if crack <= 0.0:
		ci.draw_arc(at, r * 0.62, 0.0, TAU, 20, WAX.lightened(0.3), 1.2, true)
		ci.draw_line(at + Vector2(0.0, -r * 0.95), at + Vector2(0.0, r * 0.95), WAX.darkened(0.45), 1.0)
		var font := UiKit.number_font()
		var fs := int(r * 1.05)
		var w := font.get_string_size(number, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var pos := at + Vector2(-w * 0.5, (font.get_ascent(fs) - font.get_descent(fs)) * 0.5)
		ci.draw_string(font, pos + Vector2(0.8, 0.8), number, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.1, 0.03, 0.03, 0.8))
		ci.draw_string(font, pos, number, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.95, 0.8, 0.72))
