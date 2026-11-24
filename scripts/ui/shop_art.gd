class_name ShopArt
extends RefCounted
## The merchant family's drawn pieces (docs/art/shop_spec.md C and D): the colours of the leather tag, the stripes and the
## brass, and the final art by its planned path under assets/ui/shop/ (null while the file is not there yet, so a screen
## draws its provisional piece instead). The same for the Vendedor's screen and the descent's shop signs.

const DIR := "res://assets/ui/shop/"

const LEATHER := Color("5a3424")
const LEATHER_EDGE := Color("2e1a12")
const STITCH := Color("e9dcc0")
const BRASS := Color("a08050")
const WINE := Color("6e2a2a")
const EARTH := Color("8a6a48")
const WOOD := Color("2a1c12")
const WOOD_TOP := Color("5a3c24")
const PLATE_LEATHER := Color("2e1e16")
## The red of a price that cannot be paid (the spec's c05040 lightened to read on dark leather).
const SHORT := Color("e8806c")
const STRIPE := 64.0


## The final art by name ("counter_bg"), or null while it has not arrived.
static func texture(art_name: String) -> Texture2D:
	var path := "%s%s.png" % [DIR, art_name]
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


## A dashed stitch along the closed outline of a polygon, `inset` px inside it (the spec's: 4 px stroke, 3 px gap).
static func stitch(ci: CanvasItem, rect: Rect2, inset: float, cut: float = 0.0, color: Color = STITCH) -> void:
	var r := rect.grow(-inset)
	var pts := PackedVector2Array([Vector2(r.position.x + cut, r.position.y), Vector2(r.end.x, r.position.y), r.end,
		Vector2(r.position.x + cut, r.end.y)])
	if cut > 0.0:
		pts.append(Vector2(r.position.x, r.end.y - cut))
		pts.append(Vector2(r.position.x, r.position.y + cut))
	pts.append(pts[0])
	for i in pts.size() - 1:
		var a := pts[i]
		var b := pts[i + 1]
		var len_ := a.distance_to(b)
		var dir := (b - a) / maxf(len_, 0.001)
		var t := 0.0
		while t < len_:
			ci.draw_line(a + dir * t, a + dir * minf(t + 4.0, len_), color, 1.5)
			t += 7.0


## The striped cloth (wine and earth, 64 px stripes) over a rect, its lower edge cut into scallops of `fringe` px.
static func awning(ci: CanvasItem, rect: Rect2, fringe: float) -> void:
	var tex := texture("awning")
	if tex != null:
		ci.draw_texture_rect(tex, rect.grow_individual(0, 0, 0, fringe), false)
		return
	var n := int(ceil(rect.size.x / STRIPE))
	for i in n:
		var x := rect.position.x + i * STRIPE
		var w := minf(STRIPE, rect.end.x - x)
		var col := WINE if i % 2 == 0 else EARTH
		ci.draw_rect(Rect2(x, rect.position.y, w, rect.size.y), col)
		var pts := PackedVector2Array([Vector2(x, rect.end.y), Vector2(x + w, rect.end.y), Vector2(x + w * 0.5, rect.end.y + fringe)])
		ci.draw_colored_polygon(pts, col)
		# art review 2026-11-23 (11): cloth, not a flat print: a fold in each stripe (shade to one side, light to the other)
		ci.draw_rect(Rect2(x, rect.position.y, w * 0.18, rect.size.y), Color(0, 0, 0, 0.14))
		ci.draw_rect(Rect2(x + w * 0.62, rect.position.y, w * 0.1, rect.size.y), Color(1, 1, 1, 0.06))
		ci.draw_polyline(PackedVector2Array([Vector2(x, rect.end.y), Vector2(x + w * 0.5, rect.end.y + fringe), Vector2(x + w, rect.end.y)]), Color(0, 0, 0, 0.3), 1.5)
	ci.draw_rect(Rect2(rect.position.x, rect.end.y - 3.0, rect.size.x, 3.0), Color(0, 0, 0, 0.25))
	ci.draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 5.0), Color(0, 0, 0, 0.22))


## The back wall and the counter top (a lighter board with grain) under y_top..y_top+height.
static func counter(ci: CanvasItem, wall: Rect2, top_y: float, top_h: float) -> void:
	var tex := texture("counter_bg")
	if tex != null:
		ci.draw_texture_rect(tex, wall, false)
		return
	ci.draw_rect(wall, WOOD)
	for i in 9:
		var x := wall.position.x + (i + 0.5) * wall.size.x / 9.0
		ci.draw_line(Vector2(x, wall.position.y), Vector2(x, top_y), Color(0, 0, 0, 0.22), 2.0)
	ci.draw_rect(Rect2(wall.position.x, top_y, wall.size.x, top_h), WOOD_TOP)
	ci.draw_rect(Rect2(wall.position.x, top_y, wall.size.x, 3.0), WOOD_TOP.lightened(0.18))
	for i in 5:
		var y := top_y + 8.0 + i * (top_h - 14.0) / 4.0
		ci.draw_line(Vector2(wall.position.x, y), Vector2(wall.end.x, y + (i % 2) * 2.0), WOOD_TOP.darkened(0.2), 1.0)
	var front := Rect2(wall.position.x, top_y + top_h, wall.size.x, wall.end.y - top_y - top_h)
	ci.draw_rect(front, WOOD.darkened(0.35))
	# the counter's front (the strip under the top): planks, a bronze rail and studs, so it is a piece of furniture, not a void
	for i in 7:
		var px := front.position.x + i * front.size.x / 7.0
		ci.draw_rect(Rect2(px, front.position.y, front.size.x / 7.0 - 3.0, front.size.y), WOOD.darkened(0.28 + 0.04 * (i % 2)))
		ci.draw_rect(Rect2(px + front.size.x / 7.0 - 3.0, front.position.y, 3.0, front.size.y), Color(0, 0, 0, 0.35))
	ci.draw_rect(Rect2(front.position.x, front.position.y + 6.0, front.size.x, 4.0), Color(0.55, 0.42, 0.22, 0.8))
	for i in 15:
		ci.draw_circle(Vector2(front.position.x + (i + 0.5) * front.size.x / 15.0, front.position.y + 8.0), 2.2, Color(0.8, 0.65, 0.35))
