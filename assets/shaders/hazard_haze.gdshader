shader_type spatial;
// The rift's breath (docs/art/sw_g7_hazard_grammar.md 3.7; HazardPiece breath): a sheet of grey-indigo haze standing
// along the brink, rising with `rise` (0 under the floor's edge, 1 its full height) and torn at its top with `tear`
// (the gust); never violet (the stylized rift's haze grey). Blended over what is behind, no light of its own.
render_mode blend_mix, depth_draw_never, cull_disabled, unshaded, shadows_disabled;

uniform vec3 color : source_color = vec3(0.34, 0.34, 0.42);
uniform float alpha = 0.45;
uniform float rise = 0.0;
uniform float tear = 0.0;
uniform float seed = 0.0;

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
	float up = 1.0 - UV.y;
	float n = noise(vec2(UV.x * 6.0 + seed, up * 3.0 - TIME * 0.6));
	float top = rise * (0.6 + 0.4 * n);
	float body = 1.0 - smoothstep(top - 0.25, top, up);
	float torn = mix(1.0, smoothstep(0.35, 0.65, noise(vec2(UV.x * 14.0 + seed, up * 8.0 - TIME * 3.0))), tear);
	float sides = smoothstep(0.0, 0.15, UV.x) * smoothstep(1.0, 0.85, UV.x);
	ALBEDO = color;
	ALPHA = alpha * body * torn * sides * (0.55 + 0.45 * n);
}
