class_name C5Marks
extends Node3D
## Lote C5 signals, drawing only (no rule, no number of play): a thin ivory ring closing round a Trinca's mound for the
## seconds it takes to rise, and chevrons along the Varredor's bar in the wind-up pointing the way it will turn.
## It reads the crowd each frame; nothing in the game reads it back.

const RING_R0 := 1.5
const RING_R1 := 0.35
const RING_WIDTH := 0.07
const RING_COLOR := Color(0.93, 0.9, 0.78)
const RING_ALPHA := 0.7
const CHEVRON_COUNT := 4
const CHEVRON_FIRST := 0.34
const CHEVRON_SIZE := 0.26

var horde: Horde
var _rings: Array[MeshInstance3D] = []
var _chevrons: Array[MeshInstance3D] = []
var _ring_mat: StandardMaterial3D
var _chevron_mat: StandardMaterial3D
var _chevron_mesh: ArrayMesh
var _ring_mesh: TorusMesh


## The ring's radius `t` seconds into a mound's `rise` seconds: closes straight from r0 to r1.
static func ring_radius(t: float, rise: float, r0 := RING_R0, r1 := RING_R1) -> float:
	return lerpf(r0, r1, clampf(t / maxf(rise, 0.001), 0.0, 1.0))


## Its opacity: fades in over the first tenth, brightens a little as it closes.
static func ring_alpha(t: float, rise: float) -> float:
	var k := clampf(t / maxf(rise, 0.001), 0.0, 1.0)
	return RING_ALPHA * minf(k * 10.0, 1.0) * lerpf(0.6, 1.0, k)


## True while a mound's ring is shown: it lies, it will rise, and another of its group still stands.
static func ring_shown(is_down: bool, rise: float, standing: int) -> bool:
	return is_down and rise > 0.0 and standing > 0


## The direction the bar turns at its start: its line turned a quarter round to `way` (1 or -1), the one SweepRules.dir_at takes.
static func turn_dir(aim: Vector2, way: float) -> Vector2:
	return aim.rotated(way * PI * 0.5)


## Where chevron `k` of `n` lies along a bar of `reach` m from `from` on `aim`: spread from the first tenth to the end.
static func chevron_at(from: Vector2, aim: Vector2, reach: float, k: int, n: int) -> Vector2:
	var f := lerpf(CHEVRON_FIRST, 0.95, float(k) / maxf(float(n - 1), 1.0))
	return from + aim * reach * f


func step() -> void:
	if horde == null:
		return
	var ring_n := 0
	var chev_n := 0
	for e in horde.list:
		if not e.alive:
			continue
		var d := e.def
		if d.rise_time > 0.0 and e.state == Enemy.State.DOWN and ring_shown(true, d.rise_time, _standing(e)):
			var m := _node(_rings, ring_n, true)
			ring_n += 1
			var r := ring_radius(e.state_t, d.rise_time)
			m.position = Vector3(e.pos.x, 0.07, e.pos.y)
			m.scale = Vector3(r, 1.0, r)
			var a := ring_alpha(e.state_t, d.rise_time)
			m.transparency = clampf(1.0 - a, 0.0, 1.0)
		elif d.behavior == EnemyDef.Behavior.SWEEP and e.state == Enemy.State.WINDUP:
			var turn := turn_dir(e.aim, e.side)
			for k in CHEVRON_COUNT:
				var m := _node(_chevrons, chev_n, false)
				chev_n += 1
				var p := chevron_at(e.pos, e.aim, d.attack_range, k, CHEVRON_COUNT)
				m.position = Vector3(p.x, 0.075, p.y)
				var x := Vector3(turn.x, 0.0, turn.y)
				m.basis = Basis(x, Vector3.UP, x.cross(Vector3.UP))
	_hide_from(_rings, ring_n)
	_hide_from(_chevrons, chev_n)


func _standing(e: Enemy) -> int:
	var n := 0
	for o in horde.list:
		if o != e and o.group_id == e.group_id and o.alive and o.state != Enemy.State.DOWN:
			n += 1
	return n


func _hide_from(pool: Array[MeshInstance3D], used: int) -> void:
	for i in range(used, pool.size()):
		pool[i].visible = false


func _node(pool: Array[MeshInstance3D], i: int, ring: bool) -> MeshInstance3D:
	if i >= pool.size():
		var m := MeshInstance3D.new()
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if ring:
			m.mesh = _ring()
			m.material_override = _ring_material()
		else:
			m.mesh = _chevron()
			m.material_override = _chevron_material()
		add_child(m)
		pool.append(m)
	pool[i].visible = true
	return pool[i]


func _ring() -> TorusMesh:
	if _ring_mesh == null:
		_ring_mesh = TorusMesh.new()
		_ring_mesh.inner_radius = 1.0 - RING_WIDTH
		_ring_mesh.outer_radius = 1.0
		_ring_mesh.rings = 48
		_ring_mesh.ring_segments = 4
	return _ring_mesh


func _ring_material() -> StandardMaterial3D:
	if _ring_mat == null:
		_ring_mat = _flat(RING_COLOR)
	return _ring_mat


func _chevron_material() -> StandardMaterial3D:
	if _chevron_mat == null:
		_chevron_mat = _flat(Color(1.0, 0.3, 0.2, 0.8))
	return _chevron_mat


func _flat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = c
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.no_depth_test = false
	return m


## A chevron lying flat, tip toward +X: two bars in a V.
func _chevron() -> ArrayMesh:
	if _chevron_mesh == null:
		var s := CHEVRON_SIZE
		var t := s * 0.35
		var v := PackedVector3Array([
			Vector3(s, 0, 0), Vector3(-s * 0.4, 0, s), Vector3(-s * 0.4 - t, 0, s),
			Vector3(s, 0, 0), Vector3(-s * 0.4 - t, 0, s), Vector3(0, 0, 0) + Vector3(s - t * 1.6, 0, 0),
			Vector3(s, 0, 0), Vector3(s - t * 1.6, 0, 0), Vector3(-s * 0.4 - t, 0, -s),
			Vector3(s, 0, 0), Vector3(-s * 0.4 - t, 0, -s), Vector3(-s * 0.4, 0, -s),
		])
		var arr := []
		arr.resize(Mesh.ARRAY_MAX)
		arr[Mesh.ARRAY_VERTEX] = v
		_chevron_mesh = ArrayMesh.new()
		_chevron_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return _chevron_mesh
