class_name LifeVignette
extends Control
## H6 of the SWORN reference (2026-11-21): the low-life vignette. When the paladin is hurt badly the edges of the screen
## darken in a dark blood ink, with a few ink drops creeping in from the border and a slow pulse (the heartbeat, never a
## flash). Nothing in the middle, nothing over the fight: the centre stays clear and the strongest part is the corners.
## danger 0..1 (Hud: how far the life is under DANGER_FROM of its maximum). Costs nothing when it is 0.
##   var v := LifeVignette.new()
##   v.danger = 0.6

const COLOR := Color(0.3, 0.03, 0.04)
## The strongest the border gets (opacity) at danger 1, how deep it reaches (share of the smaller side) and the pulse.
const MAX_ALPHA := 0.6
const DEPTH := 0.16
const PULSE_HZ := 0.9
const PULSE_SWING := 0.22
## Ink drops: how many per side, how far in they reach (share of the smaller side) and how wide they are.
const DROPS := 9
const DROP_DEPTH := Vector2(0.03, 0.095)
const DROP_WIDTH := Vector2(0.012, 0.035)

var danger := 0.0:
	set(v):
		v = snappedf(clampf(v, 0.0, 1.0), 0.01)
		if v != danger:
			danger = v
			set_process(danger > 0.0)
			queue_redraw()
var _t := 0.0
## [side, along 0..1, depth 0..1, width 0..1] of each drop, fixed so the vignette never shimmers.
var _drops: Array[Vector4] = []


func _init() -> void:
	name = "LifeVignette"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var rng := RandomNumberGenerator.new()
	rng.seed = 29
	for side in 4:
		for i in DROPS:
			_drops.append(Vector4(side, (i + rng.randf_range(0.1, 0.9)) / DROPS, rng.randf(), rng.randf()))
	set_process(false)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


## How strong the border is now (opacity of its darkest edge), with the pulse.
func strength() -> float:
	return MAX_ALPHA * danger * (1.0 - PULSE_SWING * (0.5 + 0.5 * sin(TAU * PULSE_HZ * _t)))


func _draw() -> void:
	if danger <= 0.0:
		return
	var a := strength()
	var s := minf(size.x, size.y)
	var d := s * DEPTH
	var dark := Color(COLOR, a)
	var clear := Color(COLOR, 0.0)
	# four bands from the edge in, mitred at the corners (each band's ends go the whole way: the corners overlap and
	# darken, as a lens would)
	_band(Vector2.ZERO, Vector2(size.x, 0.0), Vector2(0.0, d), dark, clear)
	_band(Vector2(0.0, size.y), Vector2(size.x, size.y), Vector2(0.0, -d), dark, clear)
	_band(Vector2.ZERO, Vector2(0.0, size.y), Vector2(d, 0.0), dark, clear)
	_band(Vector2(size.x, 0.0), Vector2(size.x, size.y), Vector2(-d, 0.0), dark, clear)
	for v in _drops:
		_drop(int(v.x), v.y, lerpf(DROP_DEPTH.x, DROP_DEPTH.y, v.z) * s, lerpf(DROP_WIDTH.x, DROP_WIDTH.y, v.w) * s, Color(COLOR, a * 1.1))


func _band(from: Vector2, to: Vector2, inward: Vector2, dark: Color, clear: Color) -> void:
	draw_polygon(PackedVector2Array([from, to, to + inward, from + inward]), PackedColorArray([dark, dark, clear, clear]))


## A drop of ink creeping in from a side: a base on the border and a rounded tip inward.
func _drop(side: int, along: float, depth: float, width: float, col: Color) -> void:
	var base := Vector2.ZERO
	var inward := Vector2.ZERO
	var tangent := Vector2.ZERO
	match side:
		0:
			base = Vector2(along * size.x, 0.0)
			inward = Vector2(0.0, 1.0)
			tangent = Vector2(1.0, 0.0)
		1:
			base = Vector2(along * size.x, size.y)
			inward = Vector2(0.0, -1.0)
			tangent = Vector2(1.0, 0.0)
		2:
			base = Vector2(0.0, along * size.y)
			inward = Vector2(1.0, 0.0)
			tangent = Vector2(0.0, 1.0)
		_:
			base = Vector2(size.x, along * size.y)
			inward = Vector2(-1.0, 0.0)
			tangent = Vector2(0.0, 1.0)
	var tip := base + inward * depth
	var pts := PackedVector2Array([base - tangent * width, base + tangent * width, tip + tangent * width * 0.35, tip + inward * width * 0.5, tip - tangent * width * 0.35])
	draw_colored_polygon(pts, col)
