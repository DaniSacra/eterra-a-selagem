shader_type spatial;
// Soft patches on the floor (FloorScatter, SR-G1 and SR-G3): moss, damp and the dark frame at the room's edge. A flat quad
// a hair over the slabs, lit like the floor, alpha from noise so the border breaks up. Two modes:
//   patch (radial 1): a blob from a PlaneMesh (UV 0..1), tint and strength from the instance colour (rgb, a);
//   band (radial 0): a strip along an edge, the vertex colour's alpha 1 at the edge falling to 0 (the dark frame).
// Never glows, never casts a shadow; drawn under the floor's warnings (render priority is set by the material).
render_mode blend_mix, depth_draw_never, cull_disabled, shadows_disabled, specular_disabled;

uniform float radial = 1.0;
uniform float breakup = 0.55;
uniform float rough_wet = 0.5;
uniform float grain = 6.0;

varying float seed;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

void vertex() {
	seed = hash(MODEL_MATRIX[3].xz) * 40.0;
	NORMAL = (inverse(MODEL_MATRIX) * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
}

void fragment() {
	vec2 q = UV * 2.0 - 1.0;
	vec2 at = radial > 0.5 ? q * 2.5 + seed : vec2(UV.x * 18.0, UV.y * 3.0) + seed;
	float n = noise(at) * 0.6 + noise(at * 2.7 + 5.0) * 0.4;
	float a;
	if (radial > 0.5) {
		float edge = length(q) + (n - 0.5) * breakup * 1.6;
		a = 1.0 - smoothstep(0.55, 0.8, edge);
	} else {
		a = COLOR.a * mix(1.0, 0.55 + 0.9 * n, breakup);
	}
	float lit = 0.8 + 0.4 * noise(at * grain * 0.25);
	ALBEDO = COLOR.rgb * lit;
	ALPHA = clamp(a * (radial > 0.5 ? COLOR.a : 1.0), 0.0, 1.0);
	ROUGHNESS = mix(1.0, rough_wet, step(COLOR.r * 1.5, COLOR.b));
}
