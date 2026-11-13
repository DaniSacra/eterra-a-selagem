class_name CrowdRenderer
extends Node3D
## Draws hundreds of characters from baked poses: one MultiMesh per (kind of enemy, animation, frame), plus one
## MultiMesh of soft round shadows. Each frame: begin(), add() once per character, commit().

const FLOATS := 16  # 12 for the transform, 4 for the custom state
const SHADER := preload("res://assets/shaders/crowd.gdshader")

class Batch:
	var mmi: MultiMeshInstance3D
	var data := PackedFloat32Array()
	var count := 0
	var capacity := 0

## Visual layers of everything drawn here (torches skip the crowd's layer).
var layers := 1
var _models: Dictionary = {}  # model id -> BakedModel
var _materials: Dictionary = {}  # enemy id -> ShaderMaterial
var _batches: Dictionary = {}  # enemy id -> anim -> Array[Batch] (one per frame)
var _used: Array[Batch] = []
var _shadow: Batch


func _ready() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(1, 1)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(0.0, 0.0, 0.02, 0.55)
	m.albedo_texture = Fx.soft_dot()
	m.disable_receive_shadows = true
	plane.material = m
	_shadow = _new_batch(plane, null, false)


func model(id: StringName) -> BakedModel:
	if not _models.has(id):
		_models[id] = load("res://assets/baked/%s.res" % id)
	return _models[id]


func model_of(d: EnemyDef) -> BakedModel:
	return model(d.model)


## Prepares the look of a kind of enemy (its model's texture, tint, glowing edge).
func register(d: EnemyDef) -> void:
	if _materials.has(d.id):
		return
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter(&"albedo", model(d.model).albedo)
	mat.set_shader_parameter(&"tint", d.tint)
	mat.set_shader_parameter(&"rim_color", d.rim_color)
	mat.set_shader_parameter(&"rim_power", d.rim)
	_materials[d.id] = mat
	_batches[d.id] = {}


func begin() -> void:
	for b in _used:
		b.count = 0
	_used.clear()
	_shadow.count = 0
	_used.append(_shadow)


## One character: kind, animation, seconds into it, where it stands, which way it faces (radians around Y),
## and its state (r flash, g frost, b burn, a dissolve).
func add(d: EnemyDef, anim: StringName, t: float, pos: Vector3, yaw: float, state: Color) -> void:
	var m := model(d.model)
	if m.frame_count(anim) == 0:
		anim = &"walk" if anim != &"idle" and m.frame_count(&"walk") > 0 else &"idle"
	var b := _batch(d, anim, m.frame_at(anim, t))
	if b.count == 0:
		_used.append(b)
	var s := d.size
	_put(b, Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3(s, s, s)), pos), state)
	if state.a < 0.5:
		var r := d.radius * 2.6 * (1.0 - state.a) / maxf(1.0 + pos.y * 0.3, 1.0)
		_put(_shadow, Transform3D(Basis().scaled(Vector3(r, 1.0, r)), Vector3(pos.x, 0.03, pos.z)), Color())


func commit() -> void:
	for b in _all_batches():
		var mm := b.mmi.multimesh
		if b.count == 0:
			b.mmi.visible = false
			continue
		b.mmi.visible = true
		mm.buffer = b.data
		mm.visible_instance_count = b.count


func _put(b: Batch, xf: Transform3D, state: Color) -> void:
	if b.count >= b.capacity:
		b.capacity = maxi(32, b.capacity * 2)
		b.data.resize(b.capacity * FLOATS if b.mmi.multimesh.use_custom_data else b.capacity * 12)
		b.mmi.multimesh.instance_count = b.capacity
	var per := FLOATS if b.mmi.multimesh.use_custom_data else 12
	var o := b.count * per
	var d := b.data
	var x := xf.basis.x
	var y := xf.basis.y
	var z := xf.basis.z
	d[o] = x.x; d[o + 1] = y.x; d[o + 2] = z.x; d[o + 3] = xf.origin.x
	d[o + 4] = x.y; d[o + 5] = y.y; d[o + 6] = z.y; d[o + 7] = xf.origin.y
	d[o + 8] = x.z; d[o + 9] = y.z; d[o + 10] = z.z; d[o + 11] = xf.origin.z
	if per == FLOATS:
		d[o + 12] = state.r; d[o + 13] = state.g; d[o + 14] = state.b; d[o + 15] = state.a
	b.count += 1


func _batch(d: EnemyDef, anim: StringName, frame: int) -> Batch:
	var by_anim: Dictionary = _batches[d.id]
	if not by_anim.has(anim):
		var frames: Array = model(d.model).anims[anim]
		var arr: Array[Batch] = []
		arr.resize(frames.size())
		by_anim[anim] = arr
	var arr: Array[Batch] = by_anim[anim]
	if arr[frame] == null:
		arr[frame] = _new_batch(model(d.model).anims[anim][frame], _materials[d.id], true)
	return arr[frame]


func _new_batch(mesh: Mesh, mat: Material, custom: bool) -> Batch:
	var b := Batch.new()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = custom
	mm.mesh = mesh
	b.mmi = MultiMeshInstance3D.new()
	b.mmi.multimesh = mm
	if mat:
		b.mmi.material_override = mat
	b.mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	b.mmi.layers = layers
	b.mmi.visible = false
	# the batches move every frame; a huge box keeps them from being culled by stale bounds
	b.mmi.custom_aabb = AABB(Vector3(-200, -10, -200), Vector3(400, 60, 400))
	add_child(b.mmi)
	return b


func _all_batches() -> Array[Batch]:
	var out: Array[Batch] = [_shadow]
	for id: StringName in _batches:
		for anim: StringName in _batches[id]:
			for b: Batch in _batches[id][anim]:
				if b != null:
					out.append(b)
	return out
