shader_type spatial;
render_mode blend_add, unshaded, cull_back, depth_draw_never, fog_disabled;
// The glow of the Maga's staff heads (MagaStaff): a thin amber haze over each orb, soft at the edge, with a slow breath.
// `cast` (0 to 1) lifts it for the cast. Kept under the glow threshold (1.3) and never white: amber to ivory at the core.

uniform vec3 amber : source_color = vec3(1.0, 0.55, 0.12);
uniform vec3 ivory : source_color = vec3(1.0, 0.92, 0.72);
uniform float strength = 0.55;
uniform float cast : hint_range(0.0, 1.0) = 0.0;
uniform float phase = 0.0;

void fragment() {
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float breath = 0.85 + 0.15 * sin(TIME * 2.1 + phase);
	float core = pow(facing, 1.6);
	vec3 col = mix(amber, ivory, core * (0.25 + 0.35 * cast));
	ALBEDO = col * (strength + 0.4 * cast) * breath * (0.35 + 0.65 * core);
}
