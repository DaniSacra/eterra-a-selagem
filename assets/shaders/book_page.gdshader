shader_type canvas_item;
// The pages of an open book (Book, BookSpread; art pack board 04): warm parchment with fibres and soft blotches, the
// edges browned and the fold at the spine in shadow. Drawn on one rect that holds both pages; the spine sits at
// `spine` (share of the width). Sizes are in the rect's own pixels (size_px), so the grain does not stretch.

uniform vec2 size_px = vec2(1200.0, 640.0);
uniform float spine = 0.5;
uniform vec3 paper : source_color = vec3(0.86, 0.79, 0.65);
uniform vec3 aged : source_color = vec3(0.6, 0.45, 0.28);
// How far in the browned edge reaches and how deep the fold's shadow is (px).
uniform float edge_px = 46.0;
uniform float fold_px = 64.0;
uniform float fold_dark = 0.5;
uniform float seed = 3.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p *= 2.03;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 p = UV * size_px;
	float blot = fbm(p / 140.0);
	float fibre = noise(vec2(p.x / 2.5, p.y / 38.0)) * 0.5 + noise(vec2(p.x / 31.0, p.y / 3.0)) * 0.5;
	float grain = hash(floor(p));
	vec3 col = paper * (0.9 + 0.14 * blot) + (fibre - 0.5) * 0.035 + (grain - 0.5) * 0.025;
	// browned edges, ragged by the blotches; each page has its own outer edges (the spine is not an edge)
	float sx = spine * size_px.x;
	float left = UV.x < spine ? p.x : p.x - sx;
	float right = UV.x < spine ? sx - p.x : size_px.x - p.x;
	float outer = UV.x < spine ? left : right;
	float e = min(outer, min(p.y, size_px.y - p.y));
	float browned = 1.0 - smoothstep(0.0, edge_px, e + (blot - 0.5) * edge_px * 0.8);
	col = mix(col, aged * (0.85 + 0.2 * blot), browned * 0.75);
	// the fold: a soft shadow on both sides of the spine and a thin dark crease
	float g = abs(p.x - sx);
	col *= mix(fold_dark, 1.0, smoothstep(0.0, fold_px, g));
	col *= mix(0.7, 1.0, smoothstep(0.0, 2.5, g));
	COLOR = vec4(col, 1.0);
}
