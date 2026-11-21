// A piece the paladin (or Morvath) can walk behind opens round him: where it stands between the eye and him, a round
// hole is stippled out of it (radius m at his distance, round his middle `height` m over his feet), keeping `keep` of
// it in the middle, so he reads behind it and never on top of it. Shared by masonry.gdshader (obelisks, the chamber's
// front balustrade) and the chamber's front candles (candle_see.gdshader, C12a BOSS-002).

global uniform vec3 hero_pos;
// The Chamber of the Seal (C11): the same hole opens round Morvath too (BossChamber.BOSS_FAR when there is none).
global uniform vec3 boss_pos;

// A 4 x 4 ordered dither: the threshold of this pixel (0..1).
float bayer4(vec2 frag) {
	ivec2 p = ivec2(mod(frag, 4.0));
	int i = p.x + p.y * 4;
	int m[16] = int[](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return (float(m[i]) + 0.5) / 16.0;
}

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
			open = max(open, (1.0 - smoothstep(0.15, 1.0, d)) * (1.0 - max(keep, SEE_GHOST)) * amount);
		}
	}
	return ign(frag) < open;
}
