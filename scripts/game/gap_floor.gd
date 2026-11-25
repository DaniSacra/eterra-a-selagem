class_name GapFloor
extends Node3D
## PT-25-9: the stream or rift that only a dash crosses, drawn on the floor (placeholder: the environment artist's piece
## replaces it): a dark water strip with a pale foam line on each bank and a slow ripple, one per rectangle of
## Arena.gaps. Display only; the rule is GapRule (Player.step keeps walkers out). It hangs from the arena and goes with it.

const Y := 0.04
const WATER := Color(0.05, 0.12, 0.2, 0.92)
const FOAM := Color(0.62, 0.76, 0.82, 0.8)
const FOAM_WIDTH := 0.18
const RIPPLE_SPEED := 0.35

var _water: Array[ShaderMaterial] = []


func _init(gaps: Array[Rect2] = []) -> void:
	name = "GapFloor"
	for r in gaps:
		_add(r)


func _add(r: Rect2) -> void:
	var water := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = r.size
	water.mesh = plane
	water.position = Vector3(r.get_center().x, Y, r.get_center().y)
	var mat := ShaderMaterial.new()
	mat.shader = _shader()
	mat.set_shader_parameter(&"water", WATER)
	mat.set_shader_parameter(&"foam", FOAM)
	mat.set_shader_parameter(&"size", r.size)
	mat.set_shader_parameter(&"foam_width", FOAM_WIDTH)
	mat.set_shader_parameter(&"speed", RIPPLE_SPEED)
	water.material_override = mat
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(water)
	_water.append(mat)


static var _cached: Shader


static func _shader() -> Shader:
	if _cached == null:
		_cached = Shader.new()
		_cached.code = """shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform vec4 water : source_color;
uniform vec4 foam : source_color;
uniform vec2 size;
uniform float foam_width;
uniform float speed;
void fragment() {
	vec2 p = (UV - 0.5) * size;
	float edge = min(size.y * 0.5 - abs(p.y), size.x * 0.5 - abs(p.x));
	float bank = 1.0 - smoothstep(0.0, foam_width, edge);
	float wave = 0.5 + 0.5 * sin((p.x * 1.3 + p.y * 2.1) - TIME * speed * 6.0);
	vec3 col = mix(water.rgb * (0.8 + 0.4 * wave), foam.rgb, bank * foam.a);
	ALBEDO = col;
	ALPHA = mix(water.a, 1.0, bank);
}
"""
	return _cached
