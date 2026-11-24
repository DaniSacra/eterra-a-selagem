class_name Candles
extends Control
## The Devotion of the Livro de Ahk as a row of candles (meta_screens_identity.md 1.1): one candle per point, lit when
## it is free, put out with a thread of smoke when it is spent (a Gift worn). `preview` candles flicker harder: the ones
## the focused entry would cost (or holds). The number is written beside it by the page ("7 de 12"), never left to the
## drawing. The same painter draws the small candles of an entry's cost (`paint`).
##   var row := Candles.new().setup(16.0)

const FLAME := Color("e8a43a")
const FLAME_CORE := Color("fff0b8")
const WAX := Color("e3d6b4")
const WAX_SHADE := Color("b9a67a")
const SMOKE := Color(0.3, 0.26, 0.22, 0.55)

var used := 0
var total := 0
var preview := 0
var preview_held := false
var step := 16.0
var _time := 0.0


func setup(p_step: float = 16.0) -> Candles:
	step = p_step
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(60.0, p_step * 1.75)
	return self


func set_counts(p_used: int, p_total: int) -> void:
	used = p_used
	total = p_total
	queue_redraw()


## The candles the focused entry costs flicker (0: none).
func set_preview(n: int, held: bool = false) -> void:
	preview_held = held
	preview = n
	set_process(n > 0)
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


## The step that fits `total` candles in `width` (at most `step`, at least a third of it).
func step_for(width: float) -> float:
	return clampf(width / maxf(total, 1), step / 3.0, step)


func _draw() -> void:
	var st := step_for(size.x)
	for i in total:
		var spent := i < used
		var flick := 0
		if preview > 0:
			# a preview: the first free ones (or, when it is worn, the last spent ones) tremble
			var lo := maxi(used - preview, 0) if preview_held else mini(used, maxi(total - preview, 0))
			flick = 1 if i >= lo and i < lo + preview else 0
		paint(self, Vector2(st * 0.5 + i * st, size.y - 1.0), st * 0.62, not spent, _time + i * 0.7, flick)


## One candle standing on `foot` (bottom centre), `w` wide and 2.2 w tall; lit with a flame, or put out with smoke.
static func paint(ci: CanvasItem, foot: Vector2, w: float, lit: bool, time: float = 0.0, flicker: int = 0) -> void:
	var h := w * 1.7
	var body := Rect2(foot + Vector2(-w * 0.5, -h), Vector2(w, h))
	ci.draw_rect(body, WAX if lit else WAX_SHADE.darkened(0.15))
	ci.draw_rect(Rect2(body.position, Vector2(w * 0.3, h)), Color(1, 1, 1, 0.18 if lit else 0.06))
	ci.draw_rect(body, Color(Book.INK, 0.55), false, 1.0)
	var top := body.position + Vector2(w * 0.5, 0.0)
	if lit:
		var sway := sin(time * (13.0 if flicker > 0 else 5.0)) * w * (0.28 if flicker > 0 else 0.1)
		var fh := w * (1.25 if flicker > 0 else 1.0)
		var tip := top + Vector2(sway, -fh)
		var side := Vector2(w * 0.32, 0.0)
		ci.draw_colored_polygon(PackedVector2Array([top - side, top + Vector2(0, -fh * 0.35) - side * 1.1, tip, top + Vector2(0, -fh * 0.35) + side * 1.1, top + side]), FLAME)
		ci.draw_colored_polygon(PackedVector2Array([top - side * 0.4, tip.lerp(top, 0.35), top + side * 0.4]), FLAME_CORE)
	else:
		var pts := PackedVector2Array()
		for k in 6:
			var t := float(k) / 5.0
			pts.append(top + Vector2(sin(t * 5.0) * w * 0.35, -t * w * 1.4))
		ci.draw_polyline(pts, SMOKE, 1.2, true)
