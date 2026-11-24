// A piece the paladin (or Morvath) can walk behind opens round him: where it stands between the eye and him, a round
// hole is stippled out of it (radius m at his distance, round his middle `height` m over his feet), keeping `keep` of
// it in the middle, so he reads behind it and never on top of it. Shared by masonry.gdshader (obelisks, the chamber's
// front balustrade) and the chamber's front candles (candle_see.gdshader, C12a BOSS-002).

global uniform vec3 hero_pos;
// The Chamber of the Seal (C11): the same hole opens round Morvath too (BossChamber.BOSS_FAR when there is none).
global uniform vec3 boss_pos;

// Interleaved gradient noise (Jimenez): a threshold with no regular grid to it (the 4 x 4 pattern read as a screen of
// dots at 1080, art review 2026-11-21 item 6).
float ign(vec2 frag) {
	return fract(52.9829189 * fract(dot(frag, vec2(0.06711056, 0.00583715))));
}

// A piece never goes fully away: it stays this much of itself in the middle, a ghost over him.
const float SEE_GHOST = 0.3;

// True when this pixel (view-space vertex) is stippled out: only for the camera's own view (a narrow perspective:
// shadow maps are orthographic or 90 degrees wide; the browser's renderer flips Y, hence abs). Stone nearer the eye
// than him by less than `gap` m is left whole (he brushes against it, he is not behind it).
bool see_through_hole(vec3 vertex, vec2 frag, mat4 view, mat4 projection, float amount, float radius, float height,
		float keep, float gap) {
	if (amount <= 0.0 || projection[3][3] >= 0.5 || abs(projection[1][1]) <= 1.5) {
		return false;
	}
	float open = 0.0;
	for (int k = 0; k < 2; k++) {
		vec3 who = k == 0 ? hero_pos : boss_pos;
		vec3 hv = (view * vec4(who + vec3(0.0, height, 0.0), 1.0)).xyz;
		if (vertex.z > hv.z + gap) {
			// this pixel's line of sight where it crosses his depth, and how far from him that is
			float d = length(vertex.xy * (hv.z / vertex.z) - hv.xy) / radius;
			open = max(open, (1.0 - smoothstep(0.0, 1.0, d)) * (1.0 - max(keep, SEE_GHOST)) * amount);
		}
	}
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	// the browser: a plain per-pixel threshold (no 4 x 4 grid), hard edge
	return ign(frag) < open;
#else
	// Forward+ (GR-8, art review 2026-11-23 item 7): the same ghost, but the threshold is two decorrelated per-pixel
	// noises averaged (triangular, no regular grid, no screen of dots) and the edge is eased over the whole 0.6 m rim,
	// so under 2x MSAA it reads as a soft fade, not stippling.
	float t = 0.5 * (ign(frag) + ign(frag.yx + vec2(17.0, 43.0)));
	return t < smoothstep(0.0, 1.0, open);
#endif
}

// Real fade (GR-8, art review 2026-11-24 N1): for the masonry twins that set SEE_FADE (masonry_fade, masonry_paint_fade:
// a transparent pipeline with an opaque depth prepass, so only the pixels that fade blend). Returns the piece's alpha
// at this pixel: 1 everywhere except where it really stands between the eye and him (his line of sight, at his depth,
// within the radius), easing to SEE_FADE_MIN in the middle over a SEE_FADE_EDGE m rim. A piece beside him stays whole.
const float SEE_FADE_MIN = 0.35;
const float SEE_FADE_EDGE = 0.6;
const float SEE_FADE_RADIUS = 1.3;

float see_through_alpha(vec3 vertex, mat4 view, mat4 projection, float amount, float radius, float height, float gap) {
	if (amount <= 0.0 || projection[3][3] >= 0.5 || abs(projection[1][1]) <= 1.5) {
		return 1.0;
	}
	radius = min(radius, SEE_FADE_RADIUS);
	float open = 0.0;
	for (int k = 0; k < 2; k++) {
		vec3 who = k == 0 ? hero_pos : boss_pos;
		vec3 hv = (view * vec4(who + vec3(0.0, height, 0.0), 1.0)).xyz;
		if (vertex.z > hv.z + gap) {
			float d = length(vertex.xy * (hv.z / vertex.z) - hv.xy);
			open = max(open, 1.0 - smoothstep(radius - SEE_FADE_EDGE, radius, d));
		}
	}
	return mix(1.0, SEE_FADE_MIN, open * amount);
}
