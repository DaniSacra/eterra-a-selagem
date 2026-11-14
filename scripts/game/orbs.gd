class_name Orbs
extends Node3D
## Motes of light left by the fallen: they float, are pulled in when the paladin comes near, and give experience.
## All drawn with one MultiMesh.

const MAGNET := 3.6
const PICK := 0.7
const PULL := 30.0
const MAX := 400

class Orb:
	var pos := Vector2.ZERO
	var vel := Vector2.ZERO
	var value := 1
	var t := 0.0
	var pulled := false

var list: Array[Orb] = []
var magnet_bonus := 0.0
var _mm: MultiMesh
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	Dev.seed_rng(_rng, 2)
	var gem := SphereMesh.new()
	gem.radius = 0.16
	gem.height = 0.42
	gem.radial_segments = 4
	gem.rings = 2
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color(2.6, 2.2, 1.0)
	gem.material = m
	_mm = MultiMesh.new()
	_mm.transform_format = MultiMesh.TRANSFORM_3D
	_mm.mesh = gem
	_mm.instance_count = MAX
	_mm.visible_instance_count = 0
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = _mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.custom_aabb = AABB(Vector3(-200, -10, -200), Vector3(400, 40, 400))
	add_child(mmi)


func drop(at: Vector2, value: int) -> void:
	if list.size() >= MAX:
		# too many on the floor: merge into the oldest
		list[0].value += value
		return
	var o := Orb.new()
	o.pos = at
	o.value = value
	o.vel = Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(1.0, 3.0)
	o.t = _rng.randf() * 3.0
	list.append(o)


## Moves the motes; returns the experience gathered this step.
func step(dt: float, player_pos: Vector2) -> int:
	var got := 0
	var i := list.size() - 1
	var magnet := MAGNET + magnet_bonus
	while i >= 0:
		var o := list[i]
		o.t += dt
		var to := player_pos - o.pos
		var d := to.length()
		if not o.pulled and d < magnet:
			o.pulled = true
		if o.pulled:
			o.vel = o.vel.move_toward(to / maxf(d, 0.01) * (8.0 + o.t * 2.0 + PULL * 0.3), PULL * dt * 2.0)
		else:
			o.vel *= maxf(0.0, 1.0 - 4.0 * dt)
		o.pos += o.vel * dt
		if d < PICK:
			got += o.value
			list[i] = list[list.size() - 1]
			list.pop_back()
		i -= 1
	return got


func render() -> void:
	var n := mini(list.size(), MAX)
	for k in n:
		var o := list[k]
		var s := 1.0 + minf(o.value - 1, 6) * 0.15
		var xf := Transform3D(Basis(Vector3.UP, o.t * 2.5).scaled(Vector3.ONE * s), Vector3(o.pos.x, 0.45 + sin(o.t * 3.0) * 0.12, o.pos.y))
		_mm.set_instance_transform(k, xf)
	_mm.visible_instance_count = n
