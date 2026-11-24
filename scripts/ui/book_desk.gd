class_name BookDesk
extends Control
## The table the Livro de Ahk lies on (docs/art/book_spec.md 1): dark wood (1a120c) with grain lines, a vignette at the
## edges and a warm light from the upper left; two ivory candles with a flickering flame on either side, only where the
## screen is wider than 16:9 leaves room (decoration, nothing to press). Placeholder until assets/ui/book/desk.png.

const WOOD := Color("1a120c")
const GRAIN := Color(0.0, 0.0, 0.0, 0.16)
const WAX := Color("e6dcc2")
const FLAME := Color(1.0, 0.72, 0.3)
## Candle size and height at 1280 x 720 (centres), scaled with the screen's height.
const CANDLE := Vector2(30, 120)
const CANDLE_Y := 560.0
## The book never grows wider than this many heights (the open book's own shape): what is left on a wider screen is
## table, and the candles stand on it.
const BOOK_ASPECT := 1.9
const VIGNETTE_STEPS := 10

var _t := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)


## The table each side of the book at this size (0 on 16:9 and narrower: the book fills the screen).
static func side_room(s: Vector2) -> float:
	return maxf(0.0, (s.x - s.y * BOOK_ASPECT) * 0.5)


## True when the table shows its candles at this size (there is table beside the book for them).
static func candles_shown(s: Vector2) -> bool:
	return side_room(s) > CANDLE.x * s.y / 720.0


func _process(delta: float) -> void:
	if candles_shown(size):
		_t += delta
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), WOOD)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var y := 0.0
	while y < size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y + rng.randf_range(-3.0, 3.0)), Color(GRAIN, rng.randf_range(0.05, 0.2)), 1.0)
		y += rng.randf_range(5.0, 14.0)
	# the lamp's light from the upper left, then the vignette: frames darker towards the edge
	draw_colored_polygon(_ellipse(size * Vector2(0.28, 0.12), size * Vector2(0.55, 0.5)), Color(1.0, 0.7, 0.35, 0.07))
	var band := minf(size.x, size.y) * 0.07 / VIGNETTE_STEPS
	for i in VIGNETTE_STEPS:
		var edge := Rect2(Vector2.ZERO, size).grow(-band * (i + 0.5))
		draw_rect(edge, Color(0, 0, 0, 0.6 * (1.0 - float(i) / VIGNETTE_STEPS)), false, band)
	if candles_shown(size):
		var k := size.y / 720.0
		var room := side_room(size)
		_candle(Vector2(room * 0.5, CANDLE_Y * k), k, 0.0)
		_candle(Vector2(size.x - room * 0.5, CANDLE_Y * k), k, 1.7)


func _candle(c: Vector2, k: float, phase: float) -> void:
	var body := Rect2(c - CANDLE * k * 0.5, CANDLE * k)
	draw_rect(body, WAX)
	draw_rect(Rect2(body.position, Vector2(body.size.x * 0.25, body.size.y)), Color(1, 1, 1, 0.12))
	draw_rect(Rect2(body.position + Vector2(body.size.x * 0.7, 0), Vector2(body.size.x * 0.3, body.size.y)), Color(0, 0, 0, 0.2))
	var flick := 1.0 + 0.12 * sin(_t * 9.0 + phase) + 0.06 * sin(_t * 23.0 + phase * 2.0)
	var top := body.position + Vector2(body.size.x * 0.5, 0)
	var h := 22.0 * k * flick
	var sway := sin(_t * 5.0 + phase) * 2.0 * k
	draw_circle(top + Vector2(0, -h * 0.5), h * 1.6, Color(FLAME, 0.08))
	draw_colored_polygon(PackedVector2Array([top, top + Vector2(-5 * k, -h * 0.4), top + Vector2(sway, -h),
		top + Vector2(5 * k, -h * 0.4)]), FLAME)
	draw_colored_polygon(PackedVector2Array([top, top + Vector2(-2.5 * k, -h * 0.3), top + Vector2(sway * 0.6, -h * 0.65),
		top + Vector2(2.5 * k, -h * 0.3)]), Color(1.0, 0.95, 0.75))


static func _ellipse(c: Vector2, r: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in 28:
		out.append(c + Vector2.from_angle(TAU * i / 28.0) * r)
	return out
