class_name HudMark
extends Control
## Small ornaments of the HUD drawn in code: the gold coin beside the gold, and the brush stroke under the hit count.

enum Kind { COIN, STROKE }

var kind := Kind.COIN
var color := UiKit.GOLD


func setup(k: Kind, size_px: Vector2, c: Color = UiKit.GOLD) -> HudMark:
	kind = k
	color = c
	custom_minimum_size = size_px
	size = size_px
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
