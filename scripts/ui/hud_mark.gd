class_name HudMark
extends Control
## Small ornaments of the HUD drawn in code: the gold coin beside the gold, the brush stroke under the hit count and
## the chevron that points, from the edge of the screen, at something out of view (it points right; turn the control).

enum Kind { COIN, STROKE, CHEVRON }

## The chevron's outline in units of its size, pointing right.
const CHEVRON_SHAPE: Array[Vector2] = [Vector2(0.14, 0.04), Vector2(0.44, 0.04), Vector2(0.92, 0.5), Vector2(0.44, 0.96), Vector2(0.14, 0.96), Vector2(0.6, 0.5)]

var kind := Kind.COIN
var color := UiKit.GOLD


func setup(k: Kind, size_px: Vector2, c: Color = UiKit.GOLD) -> HudMark:
	kind = k
	color = c
	custom_minimum_size = size_px
	size = size_px
	pivot_offset = size_px * 0.5
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


func _draw() -> void:
	match kind:
		Kind.COIN:
			var r := minf(size.x, size.y) * 0.5
			var c := size * 0.5
			draw_circle(c, r, Color(0.02, 0.01, 0.03))
			draw_circle(c, r - 1.2, color.darkened(0.35))
			draw_circle(c + Vector2(-0.6, -0.6), r - 2.6, color)
			draw_arc(c, r * 0.45, 0.0, TAU, 20, color.darkened(0.4), 1.4, true)
			draw_arc(c, r - 2.2, -PI * 0.95, -PI * 0.45, 8, Color(1, 1, 1, 0.6), 1.0, true)
		Kind.STROKE:
			# a dry brush stroke rising a little to the right: a point on the left, full at the right, a few loose hairs
			var top := PackedVector2Array()
			var bottom := PackedVector2Array()
			var steps := 18
			for i in steps + 1:
				var t := float(i) / steps
				var mid := size.y * (0.62 - 0.2 * t)
				var half := size.y * 0.42 * sqrt(t) * (1.0 - 0.25 * t * t * t)
				top.append(Vector2(size.x * t, mid - half))
				bottom.append(Vector2(size.x * t, mid + half))
			bottom.reverse()
			var stroke := top + bottom
			var shadow := PackedVector2Array()
			for p in stroke:
				shadow.append(p + Vector2(1.5, 1.5))
			draw_colored_polygon(shadow, Color(0.02, 0.01, 0.03, 0.7))
			draw_colored_polygon(stroke, color)
			for k in 3:
				var y := size.y * (0.3 + 0.18 * k)
				draw_line(Vector2(size.x * (0.5 + 0.1 * k), y), Vector2(size.x * (0.7 + 0.08 * k), y - 0.5), Color(color.darkened(0.45), 0.8), 1.0, true)
		Kind.CHEVRON:
			var pts := PackedVector2Array()
			for p in CHEVRON_SHAPE:
				pts.append(p * size)
			var outline := pts.duplicate()
			outline.append(pts[0])
			draw_polyline(outline, UiKit.INK, 4.0, true)
			# a concave shape: two halves, so the fill never depends on the triangulation
			draw_colored_polygon(PackedVector2Array([pts[0], pts[1], pts[2], pts[5]]), color)
			draw_colored_polygon(PackedVector2Array([pts[5], pts[2], pts[3], pts[4]]), color)
