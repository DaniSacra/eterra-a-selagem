class_name PickMark
extends Control
## The Picareta of the Ofícios (Roteiro A) drawn in code, never a cross: a curved iron head of two arms (one a point,
## one a flat blade) on a wooden haft set at a slant. Three looks: LOST (only the outline, in faded ink), HEAD (the
## head alone, the haft broken off short: the find) and WHOLE (restored). On paper (Book) by default; over the run
## (paper = false) the iron is pale and the outline dark.
##   PickMark.new().setup(PickMark.Look.HEAD, 48.0)

enum Look { LOST, HEAD, WHOLE }

const IRON := Color(0.36, 0.37, 0.4)
const IRON_PALE := Color(0.72, 0.73, 0.76)
const WOOD := Color(0.42, 0.28, 0.16)
const EDGE_DARK := Color(0.06, 0.05, 0.05)

var look := Look.WHOLE:
	set(v):
		look = v
		queue_redraw()
var paper := true


func setup(p_look: Look, px: float, on_paper: bool = true) -> PickMark:
	look = p_look
	paper = on_paper
	custom_minimum_size = Vector2(px, px)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


func _draw() -> void:
	paint(self, look, size * 0.5, minf(size.x, size.y), paper)


## Draws the pick on any canvas item, centred at c, h px tall.
static func paint(ci: CanvasItem, p_look: Look, c: Vector2, h: float, on_paper: bool = true) -> void:
	var u := h / 2.0
	var line := maxf(1.2, h * 0.045)
	var ink := Book.INK if on_paper else EDGE_DARK
	var faded := Color(Book.FADED, 0.7) if on_paper else Color(UiKit.DIM, 0.8)
	# the haft: from the low left to the head at the top right
	var top := c + Vector2(0.28, -0.42) * u
	var foot := c + Vector2(-0.55, 0.78) * u
	if p_look == Look.HEAD:
		foot = top.lerp(foot, 0.3)
	var head := _head(top, u)
	if p_look == Look.LOST:
		ci.draw_line(top, foot, faded, line, true)
		var o := head.duplicate()
		o.append(o[0])
		ci.draw_polyline(o, faded, line, true)
		return
	var haft_w := maxf(2.0, u * 0.16)
	ci.draw_line(top, foot, ink, haft_w + line * 1.6, true)
	ci.draw_line(top, foot, WOOD.lightened(0.15) if not on_paper else WOOD, haft_w, true)
	if p_look == Look.HEAD:
		# the broken end of the haft: a short jagged cut
		var d := (foot - top).normalized()
		var n := Vector2(-d.y, d.x) * haft_w * 0.6
		ci.draw_polyline(PackedVector2Array([foot + n, foot + d * haft_w * 0.5, foot - n * 0.2, foot + d * haft_w * 0.3 - n]),
			ink, line, true)
	ci.draw_colored_polygon(head, IRON if on_paper else IRON_PALE)
	var o2 := head.duplicate()
	o2.append(o2[0])
	ci.draw_polyline(o2, ink, line, true)
	# the eye where the haft goes through
	ci.draw_circle(top, haft_w * 0.45, ink)


## The head: a crescent across the haft's top, sharp at the left point, a flat blade on the right.
static func _head(at: Vector2, u: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var steps := 10
	for i in steps + 1:
		var t := i / float(steps)
		pts.append(at + Vector2(lerpf(-0.95, 0.85, t), _arch(t)) * u)
	for i in steps + 1:
		var t := 1.0 - i / float(steps)
		pts.append(at + Vector2(lerpf(-0.95, 0.85, t), _arch(t) + lerpf(0.03, 0.3, t)) * u)
	return pts


static func _arch(t: float) -> float:
	return -0.1 - 0.24 * (1.0 - pow(2.0 * t - 1.0, 2.0))
