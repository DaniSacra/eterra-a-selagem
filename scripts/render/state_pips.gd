class_name StatePips
extends Node3D
## TA-10: up to three small icons above each enemy that carries an element state (fire diamond, cold flake, volt
## spark), one MultiMesh for the whole horde. Colors from ElementLook, never red.
## Integration (the game owns the instance, once, as a child of the world node):
##   var pips := StatePips.new(); add_child(pips)
##   pips.update(horde.enemies, element_book)    # each frame after the horde moved, `enemies: Array[Enemy]`

const MAX_PIPS := 900
const SHADER := preload("res://shaders/state_pip.gdshader")
const PIP_SIZE := 0.22
const GAP := 0.26
const LIFT := 0.35

var _multi: MultiMesh
var _view: MultiMeshInstance3D


func _init() -> void:
	_multi = MultiMesh.new()
	_multi.transform_format = MultiMesh.TRANSFORM_3D
	_multi.use_colors = true
	_multi.use_custom_data = true
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	quad.material = mat
	_multi.mesh = quad
	_multi.instance_count = MAX_PIPS
	_multi.visible_instance_count = 0
	_view = MultiMeshInstance3D.new()
	_view.multimesh = _multi
	_view.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_view.extra_cull_margin = 200.0
	add_child(_view)


## Draws the pips of `enemies` (Array of Enemy) from `book` (ElementBook). Returns how many pips were drawn.
func update(enemies: Array, book: ElementBook) -> int:
	var n := 0
	for e in enemies:
		if n + 3 > MAX_PIPS:
			break
		if e == null or not e.alive or e.state == Enemy.State.DEAD:
			continue
		var kinds: Array[int] = []
		if book.has_fire(e):
			kinds.append(0)
		if book.has_ice(e):
			kinds.append(1)
		if book.has_volt(e):
			kinds.append(2)
		if kinds.is_empty():
			continue
		var top: float = e.y + e.height() + LIFT
		var x0 := -GAP * 0.5 * float(kinds.size() - 1)
		for i in kinds.size():
			var k: int = kinds[i]
			var basis := Basis.from_scale(Vector3.ONE * PIP_SIZE)
			_multi.set_instance_transform(n, Transform3D(basis, Vector3(e.pos.x, top, e.pos.y) + Vector3(x0 + GAP * i, 0.0, 0.0)))
			_multi.set_instance_color(n, _color(k))
			_multi.set_instance_custom_data(n, Color(float(k), 0.0, 0.0, 0.0))
			n += 1
	_multi.visible_instance_count = n
	return n


static func _color(kind: int) -> Color:
	match kind:
		0: return ElementLook.FIRE
		1: return ElementLook.COLD
	return ElementLook.VOLT
