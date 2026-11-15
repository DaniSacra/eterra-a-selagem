shader_type spatial;
// The cut of a blow landing (Fx.gash): a short streak along `axis` (the way the blade was moving there, in the
// world), pointed at both ends, a pale core inside the blow's colour, opening fast and closing as it fades. A heavy
// blow adds a thinner streak across it. Drawn on a quad that turns around the axis to face the camera.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled, skip_vertex_transform;

uniform vec4 color : source_color = vec4(1.0, 0.8, 0.4, 1.0);
uniform float life = 0.0;
uniform float intensity = 2.0;
// Meters from end to end.
uniform float size = 1.0;
uniform vec3 axis = vec3(1.0, 0.0, 0.0);
// Thickness of the streak at its middle, as a share of its length.
uniform float thick = 0.16;
// 1: the second streak of a heavy blow.
uniform float cross_cut = 0.0;
// How far the core goes from the blow's colour toward white.
uniform float pale = 0.6;

void vertex() {
	vec3 center = MODEL_MATRIX[3].xyz;
	vec3 along = normalize(axis);
	vec3 side = normalize(cross(along, normalize(CAMERA_POSITION_WORLD - center)));
	vec3 world = center + (along * VERTEX.x + side * VERTEX.y) * size;
	VERTEX = (VIEW_MATRIX * vec4(world, 1.0)).xyz;
}

// A streak along x: pointed at both ends, x and y in -1..1 of its length and of its thickness.
float streak(vec2 p, float len, float wide, out float heart) {
	float k = clamp(abs(p.x) / max(len, 0.001), 0.0, 1.0);
	float w = wide * (1.0 - k * k);
	float d = abs(p.y) / max(w, 0.0005);
	heart = (1.0 - smoothstep(0.0, 0.4, d)) * step(k, 0.999);
	return (1.0 - smoothstep(0.25, 1.0, d)) * step(k, 0.999);
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float open = mix(0.5, 1.0, smoothstep(0.0, 0.3, life));
	float close = 1.0 - 0.6 * smoothstep(0.4, 1.0, life);
	float heart = 0.0;
	float edge = streak(p, open, thick * close, heart);
	if (cross_cut > 0.0) {
		// 70 degrees across the first, shorter and thinner
		vec2 q = vec2(0.342 * p.x + 0.94 * p.y, -0.94 * p.x + 0.342 * p.y);
		float heart2 = 0.0;
		float edge2 = streak(q, open * 0.6, thick * 0.55 * close, heart2);
		edge = max(edge, edge2 * 0.8);
		heart = max(heart, heart2 * 0.8);
	}
	float fade = 1.0 - smoothstep(0.6, 1.0, life);
	vec3 c = color.rgb * edge + mix(color.rgb, vec3(1.0), pale) * heart * 0.8;
	ALBEDO = c * fade * intensity;
}
