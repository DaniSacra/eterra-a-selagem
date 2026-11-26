shader_type spatial;
// The snap where a blow of the paladin lands (vfx_pass_spec.md V-05, Fx.contact): a star of 5 to 7 uneven spikes
// (spike_min_m to spike_max_m), half of them in a fan of `fan` radians toward `aim` (the way the blade went, on the
// screen), a small ivory heart (heart_m), the tips in the blow's colour; 3 frames, growing 1.0 to 1.25 (Fx). Faces the
// camera; laid over what is behind (premultiplied) under `peak` (226 on the screen). Never a 4-point star.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled, fog_disabled;

uniform vec4 color : source_color = vec4(0.3, 1.0, 0.45, 1.0);
uniform float life = 0.0;
uniform float seed = 0.0;
uniform float count = 6.0;
// half of the quad, metres (the quad is 2 x 2 scaled to it by Fx)
uniform float half_m = 1.0;
uniform float spike_min_m = 0.25;
uniform float spike_max_m = 0.6;
uniform float heart_m = 0.12;
// P1-1: the heart is a hard five-point star (heart_m out to its points), no soft disc; as it fades every spike shrinks
// toward the shortest (spike_min_m), so the last frame never keeps a lone pair of long points (it read as a cross)
// the screen-space direction the blade went (normalised), and the fan half of the spikes go into
uniform vec2 aim = vec2(1.0, 0.0);
uniform float fan = 1.22;
uniform float peak = 1.0;
// PM-1 (stylized only, `ink` 1 from Fx.contact; 0 is the look as it was): the snap is brush ink, not a star. 3 to 5
// fragments, every one in a fan toward `aim` (none the other way, so never a cross nor an even ring), each bent a
// little like a stroke and thinning to its tip; a dark core (the ink) with a thin ivory-mint rim, off the centre
// toward the blade; no white heart.
uniform float ink = 0.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	vec2 m = (UV * 2.0 - 1.0) * vec2(1.0, -1.0) * half_m;
	float star = 0.0;
	float tip = 0.0;
	float n = count;
	float base = atan(aim.y, aim.x);
	for (int i = 0; i < 7; i++) {
		float fi = float(i);
		if (fi >= n) break;
		float h1 = fract(sin(fi * 12.9898 + seed * 78.233) * 43758.5453);
		float h2 = fract(sin(fi * 39.3468 + seed * 11.135) * 24634.6345);
		// the first half in the fan toward aim, the rest round the other way, all turned off the regular
		float ang = fi < n * 0.5
			? base + ((fi + 0.5) / max(floor(n * 0.5), 1.0) - 0.5) * fan + (h1 - 0.5) * 0.3
			: base + PI + (fi - n * 0.5) / max(n * 0.5, 1.0) * TAU * 0.6 - TAU * 0.3 + (h1 - 0.5) * 0.5;
		if (ink > 0.5) {
			ang = base + ((fi + 0.5) / max(n, 1.0) - 0.5) * fan * 1.15 + (h1 - 0.5) * 0.4;
		}
		vec2 axis = vec2(cos(ang), sin(ang));
		float len = mix(spike_min_m, mix(spike_min_m, spike_max_m, h2), 1.0 - smoothstep(0.2, 0.8, life));
		float along = dot(m, axis);
		float across = abs(m.x * axis.y - m.y * axis.x);
		if (ink > 0.5) {
			// a stroke bends: slide across by the square of the way along, to one side or the other
			across = abs(m.x * axis.y - m.y * axis.x - (h2 - 0.5) * 0.9 * along * along / max(len, 0.01));
		}
		if (along > 0.0 && along < len) {
			float k = along / len;
			// ART_REVIEW_2026-11-26c: the ink strokes are fatter at the root (0.075 m) so the fan, not the core, is the snap
			float w = (ink > 0.5 ? 0.075 : 0.05) * (1.0 - k) + 0.004;
			float on = 1.0 - smoothstep(w * 0.6, w, across);
			star = max(star, on);
			tip = max(tip, on * k);
		}
	}
	// a five-point star: its radius swings between heart_m (the points) and 0.42 of it (the notches), hard edged
	float ha = atan(m.y, m.x) + seed * TAU;
	float notch = abs(fract(ha / TAU * 5.0) * 2.0 - 1.0);
	float heart_r = mix(heart_m * 0.42, heart_m, pow(notch, 1.6));
	float hpx = max(fwidth(m.x), 0.0005);
	float heart = 1.0 - smoothstep(heart_r - hpx, heart_r, length(m));
	float fadeout = 1.0 - smoothstep(0.5, 1.0, life);
	if (ink > 0.5) {
		// the dark core and its rim, shifted toward where the blade went; it shrinks as it fades
		vec2 c = m - vec2(cos(base), sin(base)) * heart_m * 0.35;
		float rr = length(c) / (heart_m * mix(1.0, 0.7, life));
		float core = 1.0 - smoothstep(0.78, 0.92, rr);
		// ART_REVIEW_2026-11-26c: a hairline rim (out to 1.12, was 1.25): the round ring read as a reticle or an eye
		float rim = (1.0 - smoothstep(1.0, 1.12, rr)) * smoothstep(0.78, 0.92, rr);
		float va = max(star, max(core, rim)) * fadeout;
		if (va <= 0.01) discard;
		vec3 tipc = color.rgb / max(max(color.r, max(color.g, color.b)), 0.0001);
		vec3 mint = vec3(0.84, 1.0, 0.9);
		vec3 stroke = mix(mint, tipc, clamp(tip * 1.3, 0.0, 1.0));
		vec3 dark = tipc * 0.08;
		vec3 rgb = mix(stroke, dark, core * (1.0 - rim));
		ALBEDO = rgb * va * peak;
		ALPHA = clamp(va, 0.0, 1.0);
	} else {
	float v = max(star, heart) * fadeout;
	if (v <= 0.01) discard;
	vec3 hue = color.rgb / max(max(color.r, max(color.g, color.b)), 0.0001);
	vec3 light = mix(vec3(1.0, 0.95, 0.86), hue, clamp(tip * 1.5, 0.0, 1.0) * (1.0 - heart)) * v;
	light *= peak;
	ALBEDO = light;
	ALPHA = clamp(v, 0.0, 1.0);
	}
}
