class_name DoorArrow
extends Control
## Daniel 2026-11-25: while the open doors are off the screen, their medallions do not crowd its edge; a small golden
## arrow at the edge points the way instead, and the medallions show once the doors come into view
## (Rooms._pull_doors sets `target` and `shown`). Display only.

## Px of the arrow (at 720 lines) and how far it keeps from the screen's sides.
const SIZE := 34.0
const EDGE := 48.0
const GOLD := Color(0.95, 0.78, 0.42)
const DARK := Color(0.05, 0.035, 0.03, 0.85)
## Seconds of one slow beat of its glow.
const BEAT := 1.2

## Where the doors are on the screen (canvas px; may be outside it) and whether the arrow shows.
var target := Vector2.ZERO
var shown := false
var _t := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _process(delta: float) -> void:
	_t += delta
	visible = shown
	if shown:
		queue_redraw()


## The point on the screen's edge (EDGE inside) on the way from its centre to `to`, and the direction.
static func edge_spot(screen: Vector2, to: Vector2, edge: float) -> Array:
	var c := screen * 0.5
	var d := to - c
	if d.length() < 0.001:
		return [c, Vector2.RIGHT]
	var half := c - Vector2(edge, edge)
	var k := minf(half.x / maxf(absf(d.x), 0.001), half.y / maxf(absf(d.y), 0.001))
	return [c + d * minf(k, 1.0), d.normalized()]


func _draw() -> void:
	var s := size.y / 720.0
	var spot := edge_spot(size, target, EDGE * s)
	var at: Vector2 = spot[0]
	var dir: Vector2 = spot[1]
	var side := dir.orthogonal()
	var r := SIZE * s
	var glow := 0.75 + 0.25 * sin(_t * TAU / BEAT)
	var tip := at + dir * r * 0.6
	var pts := PackedVector2Array([tip, at - dir * r * 0.5 + side * r * 0.55, at - dir * r * 0.2, at - dir * r * 0.5 - side * r * 0.55])
	draw_circle(at, r * 0.95, DARK)
	draw_colored_polygon(pts, Color(GOLD, glow))
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color(1, 0.93, 0.75, glow), 1.5 * s, true)
