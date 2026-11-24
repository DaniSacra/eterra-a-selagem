class_name Ichthys
extends RefCounted
## PT-10: the ichthys, the fish of two curves lying down, the sign of the Encanto (the Emeth's blow enchanted). It is
## drawn, never an image: two arcs from the crossing at the tail to the nose, the tail's ends going past the crossing.
##   Ichthys.draw(canvas_item, centre, length, color, line_width)

const STEPS := 16


## The two arcs as polylines (upper, lower), the nose to the right, in the item's own space.
static func arcs(c: Vector2, length: float) -> Array[PackedVector2Array]:
	var half := length * 0.5
	var bulge := length * 0.3
	var tail := length * 0.2
	var nose := c + Vector2(half, 0.0)
	var out: Array[PackedVector2Array] = []
	for sgn in [-1.0, 1.0]:
		# starts below the crossing for the upper arc (and above it for the lower), so the two cross at the tail
		var a := c + Vector2(-half - tail * 0.2, -sgn * tail * 0.9)
		var ctrl := c + Vector2(-length * 0.02, sgn * bulge * 2.0)
		var pts := PackedVector2Array()
		for i in STEPS + 1:
			var t := float(i) / STEPS
			pts.append(a.lerp(ctrl, t).lerp(ctrl.lerp(nose, t), t))
		out.append(pts)
	return out


static func draw(ci: CanvasItem, c: Vector2, length: float, color: Color, width: float) -> void:
	for pts in arcs(c, length):
		ci.draw_polyline(pts, color, width, true)
