class_name AngelStage
extends Control
## BC-3: an angel standing at a side of the screen, the whole height: its painting (AngelArt.figure, fading into the
## dark, the mirrored one on the right looking in) and its family's effect (AngelFx) over it. `lit` (0..1) is how much
## it is in focus: light, effect and a slight approach (the owner moves it over ~0.2 s with `follow`). Shared by the
## Encontro (two stages, one in focus) and the Bênção's screen (one, always lit).
##   var s := AngelStage.new().setup(angel, flip)   # a child filling the side it should occupy

const ASPECT := 512.0 / 768.0
const DIM := 0.36
const RATE := 5.0  # lit units a second: the 0.2 s turn

var angel: AngelDef
var flip := false
var lit := 0.0:
	set(v):
		lit = clampf(v, 0.0, 1.0)
		_apply()
var figure: Control
var fx: AngelFx
var _fallback: AngelSeal


func setup(a: AngelDef, p_flip := false) -> AngelStage:
	angel = a
	flip = p_flip
	name = "stage_" + String(a.id)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	figure = AngelArt.figure(a, Vector2.ZERO, flip)
	if figure != null:
		add_child(figure)
	else:
		_fallback = AngelSeal.new().setup(a.family, 220.0)
		add_child(_fallback)
	fx = AngelFx.new().setup(a.family, flip)
	fx.name = "fx"
	add_child(fx)
	resized.connect(_layout)
	_layout.call_deferred()
	return self


## Moves `lit` toward the target at the turn's pace.
func follow(target: float, delta: float) -> void:
	if not is_equal_approx(lit, target):
		lit = move_toward(lit, target, delta * RATE)


func figure_rect() -> Rect2:
	var w := minf(size.y * ASPECT, size.x)
	return Rect2((size.x - w) if flip else 0.0, 0.0, w, size.y)


func _layout() -> void:
	var r := figure_rect()
	if figure != null:
		figure.position = r.position
		figure.size = r.size
		figure.pivot_offset = Vector2(r.size.x if flip else 0.0, r.size.y)
	elif _fallback != null:
		_fallback.position = r.get_center() - _fallback.size * 0.5
	fx.position = Vector2.ZERO
	fx.size = size
	# the body stands in the outer 60% of the painting
	fx.center = Vector2(r.position.x + r.size.x * (0.62 if flip else 0.38), size.y * 0.5)
	fx.reach = size.y * 0.36
	_apply()


func _apply() -> void:
	if fx == null:
		return
	fx.strength = lerpf(0.3, 1.0, lit)
	if figure != null:
		var v := lerpf(DIM, 1.0, lit)
		figure.modulate = Color(v, v, v, lerpf(0.85, 1.0, lit))
		figure.scale = Vector2.ONE * lerpf(0.96, 1.04, lit)
