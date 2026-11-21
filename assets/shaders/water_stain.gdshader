shader_type spatial;
// Spilled water (BreakableKit, at_q0_breakables.md 2.2): a dark stain with a ragged edge opening to `open` (share of
// the quad's half), a thin pale rim (rim_m share, rim_value) that goes first as it dries (`dry` 0 to 1, from the edge
// in). Never green, never glowing, never a ring of light.
render_mode blend_mix, depth_draw_never, cull_back, unshaded, shadows_disabled;

uniform vec3 color : source_color = vec3(0.12, 0.13, 0.14);
uniform float alpha = 0.55;
uniform float open = 1.0;
uniform float dry = 0.0;
uniform float seed = 0.0;
uniform float rim = 0.03;
uniform float rim_value = 0.6;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

void fragment() {
	vec2 q = (UV - vec2(0.5)) * 2.0;
	float a = atan(q.y, q.x);
	float ragged = 0.75 + 0.25 * noise(vec2(a * 3.0 + seed, seed * 1.7));
	float reach = open * ragged * (1.0 - 0.85 * dry);
	float d = length(q);
	float inside = 1.0 - smoothstep(reach - 0.04, reach, d);
	float edge = smoothstep(reach - rim - 0.02, reach - rim, d) * inside * (1.0 - smoothstep(0.0, 0.3, dry));
	ALBEDO = mix(color, vec3(rim_value), edge);
	ALPHA = inside * mix(alpha, alpha * 0.8, edge) * (1.0 - dry * 0.6);
}
