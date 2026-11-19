shader_type spatial;
// The dark body of a sword arc (C12d, VX-01): a translucent brush stroke of ink (alpha at most max_alpha) swept by
// the blade, out to its leading edge (the light of slash.gdshader sits on that edge), widest right behind the head and
// thinning along the tail. Past the edge, out to the reach of the blow, only a faint veil of the same ink (reach_veil),
// so the area the blow covers still reads. Same UVs and timing as the light; it lingers longer and breaks into specks.
// The edge: blade_m meters from the paladin when Fx gives reach_m and band_from (the mesh runs from band_from * reach_m
// to reach_m); without them, the outer edge of the mesh.
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(0.02, 0.028, 0.034, 1.0);
uniform float t = 0.0;
uniform float sweep = 0.25;
uniform float opacity = 0.85;
// Multiplies the brush stroke before the opacity: higher is a more solid body of ink.
uniform float density = 1.8;
// The most the ink ever covers (VX-01: a translucent body, the floor and the crowd read through it).
uniform float max_alpha = 0.6;
uniform bool flip = false;
uniform float band_from = 0.42;
uniform float reach_m = 0.0;
uniform float blade_m = 0.0;
// How deep the body reaches inward from the edge (a share of the band between the mesh's inner side and the edge).
uniform float body_depth = 0.75;
// The veil past the edge out to the reach: its share of the body's ink.
uniform float reach_veil = 0.2;

// Eterra Stylized (STY-06, T23): with the global art_style at 1 the ink's tail breaks into the same strokes as the
// light's (slash_strokes.gdshaderinc), and the whole ink is style_veil of its alpha (STY-10, P2-3: the stroke covered
// the struck figures more than the classic one). art_style 0: the classic ink, unchanged.
global uniform float art_style;
uniform float style_veil = 0.72;

#include "res://assets/shaders/slash_strokes.gdshaderinc"

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float edge_at() {
	if (reach_m <= 0.0 || blade_m <= 0.0) {
		return 0.97;
	}
	float inner = band_from * reach_m;
	return clamp((blade_m - inner) / max(reach_m - inner, 0.001), 0.06, 0.97);
}

void fragment() {
	float head = clamp(t / sweep, 0.0, 1.0);
	float along = flip ? 1.0 - UV.x : UV.x;
	if (along > head) discard;
	float behind = head - along;
	float y = UV.y;
	float e = edge_at();

	float n1 = noise(vec2(along * 18.0, 1.0));
	float n2 = noise(vec2(along * 22.0, 7.0));
	// the body: from the edge inward, as deep as body_depth right behind the head, thinner toward the tail, its inner
	// side brushed and uneven
	float thin = 1.0 - smoothstep(0.0, 0.9, behind) * 0.6;
	float depth = body_depth * e * thin * (0.8 + 0.2 * n1);
	float inner = e - depth;
	float band = smoothstep(inner, inner + depth * 0.45, y) * (1.0 - smoothstep(e - 0.01, e + 0.01 + n2 * 0.01, y));
	// past the edge: a faint veil out to the reach, fading toward it
	float past = y > e ? reach_veil * (1.0 - smoothstep(mix(e, 1.0, 0.4), 1.0, y)) : 0.0;
	band = max(band, past);
	// dry bristles across the stroke
	band *= 0.7 + 0.3 * noise(vec2(along * 6.0, y * 30.0));
	// the tail and, over time, the whole stroke break up into specks
	float cut = smoothstep(0.35, 1.0, t) * 1.15 + smoothstep(0.75, 1.0, behind) * 0.4;
	band *= smoothstep(cut, cut + 0.18, noise(vec2(along * 14.0, y * 4.0) + 3.0));
	band *= 1.0 - smoothstep(0.1, 1.0, behind) * 0.55;
	if (art_style > 0.5) {
		float band_m = reach_m > 0.0 ? (1.0 - band_from) * reach_m : 1.0;
		band *= slash_strokes(y * band_m, clamp(behind / max(head, 0.001), 0.0, 1.0), smoothstep(0.35, 1.0, t), fwidth(y * band_m));
	}
	if (band <= 0.01) discard;
	ALBEDO = color.rgb;
	ALPHA = min(clamp(band * density, 0.0, 1.0) * opacity, max_alpha) * (art_style > 0.5 ? style_veil : 1.0);
}
