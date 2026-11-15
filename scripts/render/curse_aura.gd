class_name CurseAura
extends Node3D
## What a boss's curse looks like on the paladin (the rules are CurseState's): RUNES small violet runes turning slowly
## around his waist and a faint violet haze on the floor under him (curse_aura.gdshader), both under the glow
## threshold; Player adds a violet edge on his body and corrupts Emeth's crystal (EmethSword.set_corrupt). No
## cloud of particles: the runes are few and small, they never pass in front of his face, the haze never hides a
## warning on the floor.

const SHADER := preload("res://assets/shaders/curse_aura.gdshader")
const COLOR := Color(0.62, 0.32, 0.95)
const RUNES := 4
## Rune quad size, orbit radius and height band in metres (the hero is drawn 2.75 m tall: waist to chest, below
## the face), and how fast they turn (radians a second).
const RUNE_SIZE := 0.32
const ORBIT := 0.95
const HEIGHT := Vector2(0.85, 1.45)
const SPIN := 1.1
## The floor haze's diameter in metres.
const HAZE_SIZE := 2.6
## Seconds the curse takes to rise and to go.
const RISE := 0.18
const FADE := 0.35

## 0..1: how much shows (Player sets `on`; it eases by itself).
var power := 0.0
var on := false
var _t := 0.0
var _runes: Array[MeshInstance3D] = []
var _rune_mat: ShaderMaterial
var _haze_mat: ShaderMaterial


func _ready() -> void:
	_rune_mat = _material(true)
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * RUNE_SIZE
	for i in RUNES:
		var mi := _mesh(quad, _rune_mat)
		mi.set_instance_shader_parameter(&"variant", float(i % 4))
		_runes.append(mi)
	_haze_mat = _material(false)
	var plane := PlaneMesh.new()
	plane.size = Vector2.ONE * HAZE_SIZE
	var haze := _mesh(plane, _haze_mat)
	haze.position.y = 0.04
	visible = false


func _process(delta: float) -> void:
	power = move_toward(power, 1.0 if on else 0.0, delta / (RISE if on else FADE))
	visible = power > 0.0
	if not visible:
		return
	_t += delta
	_rune_mat.set_shader_parameter(&"power", power)
	_haze_mat.set_shader_parameter(&"power", power)
	for i in _runes.size():
		_runes[i].position = rune_at(i, _runes.size(), _t)


## Where rune i of n stands at time t, around the paladin's feet (his node's origin): evenly spaced on a slow
## circle, each bobbing in the height band at its own pace.
static func rune_at(i: int, n: int, t: float) -> Vector3:
	var a := TAU * float(i) / float(n) + t * SPIN
	var bob := 0.5 + 0.5 * sin(t * 1.7 + float(i) * 2.3)
	return Vector3(cos(a) * ORBIT, lerpf(HEIGHT.x, HEIGHT.y, bob), sin(a) * ORBIT)


func _material(rune: bool) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = SHADER
	m.set_shader_parameter(&"rune", rune)
	m.set_shader_parameter(&"color", COLOR)
	return m


func _mesh(mesh: Mesh, mat: ShaderMaterial) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.layers = 1
	add_child(mi)
	return mi
