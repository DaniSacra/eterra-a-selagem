class_name SpectralMotes
extends MultiMeshInstance3D
## A handful of small spectral motes moved by their shader (spectral_motes.gdshader), one draw call: around the ritual's
## shield (ORBIT), adrift in the air of the last phase (DRIFT), gathering into the portal when Morvath is sealed
## (GATHER). Each mote's own numbers come from a fixed seed (never the run's dice).

const SHADER := preload("res://assets/shaders/spectral_motes.gdshader")
enum Mode { ORBIT, DRIFT, GATHER }
## The meters around the node the motes may be drawn in (they move in the shader, so the box is set by hand).
const REACH := 40.0

var mat: ShaderMaterial


static func make(mode: Mode, count: int, color: Color, size: float, light: float, seed_: int = 9) -> SpectralMotes:
	var m := SpectralMotes.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = quad
	mm.instance_count = count
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	for i in count:
		mm.set_instance_transform(i, Transform3D.IDENTITY)
		mm.set_instance_custom_data(i, Color(rng.randf(), rng.randf(), rng.randf(), (i + rng.randf()) / count))
	m.multimesh = mm
	m.mat = ShaderMaterial.new()
	m.mat.shader = SHADER
	m.mat.set_shader_parameter(&"mode", mode)
	m.mat.set_shader_parameter(&"color", color)
	m.mat.set_shader_parameter(&"size", size)
	m.mat.set_shader_parameter(&"light", light)
	m.material_override = m.mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	m.custom_aabb = AABB(Vector3.ONE * -REACH, Vector3.ONE * REACH * 2.0)
	return m


func set_param(name_: StringName, value: Variant) -> void:
	mat.set_shader_parameter(name_, value)
