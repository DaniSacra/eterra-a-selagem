shader_type spatial;
// The hub's flower clumps and hanging wisteria (refine round 2, 2026-11-26): one card is one whole clump or tassel, drawn
// as clean shapes (no noise cut-out, no dither: the old canopy cards were speckled leaves). A clump is a tuft of green
// blades under a handful of round blossoms, each a flat disc with a lighter heart and a darker rim; a tassel (hang 1)
// is a column of blossoms that narrow and sway toward the tip. Edges are cut crisply (discard on the shape), colours
// are flat with a light gradient and a little emission so the petals read at dusk. cull_disabled: seen from both sides.
render_mode diffuse_burley, specular_disabled, cull_disabled, depth_prepass_alpha;

uniform vec3 petal_a : source_color = vec3(0.34, 0.26, 0.46);
uniform vec3 petal_b : source_color = vec3(0.6, 0.52, 0.72);
uniform vec3 leaf_a : source_color = vec3(0.14, 0.2, 0.1);
uniform vec3 leaf_b : source_color = vec3(0.3, 0.4, 0.2);
// 0 a clump, 1 a hanging tassel.
uniform float hang = 0.0;
// How many blossoms of a clump (up to 9); the tassel's count along its length (up to 12).
uniform float blossoms = 7.0;
// The share of a clump's height the blades take.
uniform float blade_share = 0.42;
uniform float backlight = 0.3;
uniform float glow = 0.1;

varying float seed;
// How much taller than wide the card is drawn (twice its height over its width): the discs are made round by it.
varying float squash;

void vertex() {
	seed = INSTANCE_CUSTOM.x;
	squash = 2.0 * length(MODEL_MATRIX[1].xyz) / max(length(MODEL_MATRIX[0].xyz), 0.001);
}

float hash1(float n) {
	return fract(sin(n * 127.1 + seed * 311.7) * 43758.5453);
}

void fragment() {
	// x -1..1 across, h 0 at the foot (or the tip of a tassel) to 1 at the top
	float x = (UV.x - 0.5) * 2.0;
	float h = 1.0 - UV.y;
	vec3 col = vec3(0.0);
	bool hit = false;
	if (hang < 0.5) {
		// blades: pointed, leaning, from the foot
		for (int i = 0; i < 6; i++) {
			float fi = float(i);
			float bx = (hash1(fi + 1.0) - 0.5) * 1.5;
			float lean = (hash1(fi + 9.0) - 0.5) * 0.7;
			float len = blade_share * (0.7 + hash1(fi + 17.0) * 0.5);
			float w = 0.17 * (1.0 - h / len);
			if (h < len && abs(x - bx - lean * h) < w) {
				hit = true;
				col = mix(leaf_a, leaf_b, h / len * 0.7 + hash1(fi + 25.0) * 0.3);
			}
		}
		// blossoms: discs in the upper part, the nearer (later) ones over the others
		for (int i = 0; i < 9; i++) {
			if (float(i) >= blossoms) {
				break;
			}
			float fi = float(i);
			vec2 c = vec2((hash1(fi + 40.0) - 0.5) * 1.35, mix(blade_share * 0.8, 0.88, hash1(fi + 50.0)));
			float r = 0.32 + hash1(fi + 60.0) * 0.14;
			vec2 d = vec2(x - c.x, (h - c.y) * squash);
			float dist = length(d) / r;
			if (dist < 1.0) {
				hit = true;
				float tone = hash1(fi + 70.0);
				vec3 base = mix(petal_a, petal_b, tone * 0.7 + 0.3 * smoothstep(0.0, 1.0, c.y));
				// darker rim, lighter heart
				col = mix(base * 0.7, base * 1.15, smoothstep(1.0, 0.45, dist));
				col = mix(col, base * 1.4 + 0.05, smoothstep(0.32, 0.0, dist) * 0.7);
			}
		}
	} else {
		// a tassel: blossoms down a swaying axis, wide at the top, to a point; h is 1 at the top
		float count = min(blossoms, 12.0);
		for (int i = 0; i < 12; i++) {
			if (float(i) >= count) {
				break;
			}
			float u = (float(i) + 0.5) / count;
			float widthK = mix(1.0, 0.18, u);
			vec2 c = vec2(sin(u * 3.2 + seed * 6.28) * 0.12 * u + (hash1(float(i) + 3.0) - 0.5) * 0.28 * widthK, 1.0 - u * 0.96);
			float r = mix(0.5, 0.16, u) * (0.85 + hash1(float(i) + 11.0) * 0.3);
			float dist = length(vec2(x - c.x, (h - c.y) * squash)) / r;
			if (dist < 1.0) {
				hit = true;
				vec3 base = mix(petal_a, petal_b, 0.25 + u * 0.7 + (hash1(float(i) + 21.0) - 0.5) * 0.25);
				col = mix(base * 0.72, base * 1.15, smoothstep(1.0, 0.4, dist));
				col = mix(col, base * 1.35 + 0.04, smoothstep(0.3, 0.0, dist) * 0.6);
			}
		}
		// a green stalk at the top
		if (h > 0.93 && abs(x) < 0.06) {
			hit = true;
			col = leaf_b;
		}
	}
	if (!hit) {
		discard;
	}
	ALBEDO = col;
	ROUGHNESS = 0.9;
	BACKLIGHT = col * backlight;
	EMISSION = col * glow;
}
