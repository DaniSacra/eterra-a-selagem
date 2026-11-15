shader_type spatial;
// Violet light rising from far below at the sides of the abyss: an upright card, bright only at its foot and fading
// fast up and to the sides, broken into drifting tatters by noise (more of them higher up), slowly breathing. It
// always turns round Y to face the camera (so seen from the fight's camera it is never a flat lit panel) and has a
// ragged edge of noise. Added on top and kept out of the fog (it is the light the mist glows with), so it reads the
// same on desktop and in the browser.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(0.4, 0.3, 0.75);
uniform float energy = 1.6;
// How far up the card the glow reaches (0 to 1 of its height), how soft its sides are, how ragged its edge (share).
uniform float reach = 0.7;
// How fast it fades up from its foot (higher: only the foot is bright).
uniform float falloff = 2.2;
uniform float side = 0.45;
uniform float ragged = 0.6;
// How much of the card the tatters cut away (0 none, 1 all), and how fast they drift up.
uniform float breakup = 0.25;
uniform float rise = 0.12;
// The share of the card at its foot that fades in (so its bottom edge never shows).
uniform float foot_fade = 0.3;
// The outer share of each side where the glow always dies out, whatever the ragged noise does (so the card's upright
// edges never show), and how soft the cut of the tatters is.
uniform float edge_fade = 0.12;
uniform float tatter_soft = 0.3;
// How far the slow noise bends the card's coordinates (share of the card).
uniform float warp = 0.3;
// Cycle 7 (the glow seen through an arch was a smooth panel, like glass): upright wisps drawn through it (how much
// they darken it, how many across the card, how fast they rise) and how much darker its top is than its fall-off
// alone would leave it (a plain gradient from the bright foot up).
uniform float wisps = 0.5;
uniform float wisp_count = 9.0;
uniform float wisp_rise = 0.05;
uniform float top_dark = 0.25;
// The wisps part the light, they do not dim it: the glow between them is this much brighter.
uniform float wisp_gain = 1.95;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	float s = 0.0;
	float a = 0.5;
	for (int i = 0; i < 3; i++) {
		s += noise(p) * a;
		// each octave turned, so the lattice of the noise never shows as squares on a card seen from near
		p = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * p * 2.03 + 1.7;
		a *= 0.5;
	}
	return s;
}

void vertex() {
	// turn round Y to the camera
	vec3 to_cam = INV_VIEW_MATRIX[3].xyz - MODEL_MATRIX[3].xyz;
	vec3 fwd = normalize(vec3(to_cam.x, 0.0, to_cam.z));
	vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), fwd));
	vec3 w = MODEL_MATRIX[3].xyz + right * VERTEX.x + vec3(0.0, 1.0, 0.0) * VERTEX.y;
	VERTEX = (inverse(MODEL_MATRIX) * vec4(w, 1.0)).xyz;
}

void fragment() {
	float up = 1.0 - UV.y;
	// the card's own coordinates bent by a slow noise (cycle 6): no straight edge, no square of the noise's lattice
	vec2 uv = UV + (vec2(fbm(UV * 3.0 + 7.0), fbm(UV * 3.0 + 13.0 + TIME * 0.02)) - 0.5) * warp;
	float n = fbm(vec2(uv.x * 6.0 + uv.y * 2.0, uv.y * 3.0 - TIME * 0.15));
	float rag = (fbm(vec2(uv.x * 7.0 - uv.y * 3.0, uv.y * 5.0 + 3.0)) - 0.5) * ragged * 1.6;
	float v = pow(1.0 - smoothstep(0.0, reach, up + rag), falloff);
	// the foot fades in on a squared curve: a bright card would clip at once and show its bottom edge
	float foot = smoothstep(0.0, foot_fade, up);
	v *= foot * foot;
	float h = 1.0 - smoothstep(0.5 - side, 0.5, abs(UV.x - 0.5) + rag * 0.5);
	h *= 1.0 - smoothstep(0.5 - edge_fade, 0.5, abs(UV.x - 0.5));
	// tatters: the higher, the more of the card is cut away
	float t = fbm(vec2(uv.x * 5.0 + uv.y * 1.5, uv.y * 2.5 + TIME * rise));
	float keep = smoothstep(breakup * (0.5 + up * 0.7) - tatter_soft, breakup * (0.5 + up * 0.7) + tatter_soft, t);
	// wisps: long upright streaks, more of the card cut by them the higher up; and the gradient up the card
	float w = fbm(vec2(uv.x * wisp_count, uv.y * 1.1 + TIME * wisp_rise));
	float w2 = fbm(vec2(uv.x * wisp_count * 2.6 + 5.0, uv.y * 1.9 + TIME * wisp_rise * 1.8));
	float streak = smoothstep(0.32, 0.68, w * 0.65 + w2 * 0.35);
	v *= wisp_gain * (1.0 - wisps * (1.0 - streak) * (0.4 + 0.6 * smoothstep(0.0, 0.5, up)));
	v *= 1.0 - top_dark * smoothstep(0.1, 0.8, up);
	ALBEDO = color * energy * v * h * keep * (0.6 + 0.6 * n) * (0.9 + 0.1 * sin(TIME * 0.7));
}
