shader_type spatial;
// Santuario da Vigilia (hub refine round 1): the mountain under the platform. Warm layered rock (strata, vertical cracks),
// moss and grass in the top metres under the lip, and, going down, the rock sinks into the dusk mist the abyss planes
// make (never a flat grey wall). Lit by the moon and the ambient like the rest of the hub; no texture, all of it in
// world space along the face (the face's tangent from its normal).
render_mode specular_disabled;

uniform vec3 rock_a : source_color = vec3(0.52, 0.42, 0.34);
uniform vec3 rock_b : source_color = vec3(0.36, 0.3, 0.3);
uniform vec3 moss_color : source_color = vec3(0.3, 0.4, 0.17);
uniform vec3 mist_color : source_color = vec3(0.3, 0.22, 0.32);
// Depth (m under the floor) where the mist begins to take the rock and where it has all of it.
uniform vec2 fade = vec2(2.0, 20.0);
// How deep (m) the moss reaches, and its share.
uniform float moss_depth = 7.0;
uniform float moss_share = 0.75;
// The light of the dusk on the face: a warm wash from the top, per metre it fades.
uniform vec3 warm_color : source_color = vec3(1.0, 0.7, 0.4);
uniform float warm_depth = 5.0;
// Round 2: faceted blocks (each cell of the face its own light, a dark chink between them), the cool shadow the rock
// takes away from the light and how much darker it gets at the bottom of the fade.
uniform vec3 shade_color : source_color = vec3(0.2, 0.17, 0.36);
uniform float deep_dark = 0.65;
uniform vec2 facet_size = vec2(2.6, 1.7);

varying vec3 world;
varying vec3 wnormal;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1.0, 0.0)), f.x), mix(hash1(i + vec2(0.0, 1.0)), hash1(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
	float s = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		s += noise(p) * a;
		p = p * 2.07 + 1.3;
		a *= 0.5;
	}
	return s;
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnormal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec2 t = normalize(vec2(-wnormal.z, wnormal.x) + vec2(1e-4));
	float along = dot(world.xz, t);
	float depth = max(-world.y, 0.0);
	// strata: horizontal bands warped by noise, each band its own value
	float warp = fbm(vec2(along * 0.18, world.y * 0.22)) * 3.0;
	float band = floor((world.y + warp) * 1.7);
	float band_v = hash1(vec2(band, 3.0));
	float grain = fbm(vec2(along * 0.55, world.y * 2.6));
	vec3 c = mix(rock_a, rock_b, clamp(grain * 0.9 + band_v * 0.35 - 0.1, 0.0, 1.0));
	c *= 0.82 + 0.3 * band_v;
	// facets: irregular blocks, each a different face lit more or less, with a chink round it
	vec2 fp = vec2(along / facet_size.x + 0.5 * mod(floor(world.y / facet_size.y), 2.0), world.y / facet_size.y);
	vec2 cell = floor(fp);
	vec2 inside = fract(fp);
	float lit = hash1(cell + 7.0);
	float slope = (inside.x * 0.6 + inside.y * 0.4) * (lit - 0.5);
	c *= 0.62 + 0.7 * lit + slope * 0.5;
	c = mix(c, shade_color, (1.0 - lit) * 0.35);
	vec2 chink = min(inside, 1.0 - inside);
	c *= mix(0.45, 1.0, smoothstep(0.0, 0.07, min(chink.x * 0.6, chink.y)));
	// a dark seam at the foot of each band (a ledge's shadow) and upright cracks
	float seam = fract((world.y + warp) * 1.7);
	c *= mix(0.72, 1.0, smoothstep(0.0, 0.22, seam));
	float crack = 1.0 - smoothstep(0.0, 0.03, abs(fbm(vec2(along * 1.3, world.y * 0.11 + 5.0)) - 0.5));
	c = mix(c, c * 0.5, crack * 0.8);
	// moss and grass in the top metres, in patches, hanging lower where the noise says
	float blotch = smoothstep(0.42, 0.68, fbm(vec2(along * 0.7 + 9.0, world.y * 0.8)));
	float reach = 1.0 - smoothstep(0.0, moss_depth * (0.5 + blotch), depth);
	c = mix(c, moss_color * (0.8 + 0.5 * grain), clamp(blotch * reach * moss_share + (1.0 - smoothstep(0.0, 0.7, depth)) * 0.6, 0.0, 1.0));
	// the dusk's warm wash on the upper rock
	c = mix(c, c * warm_color * 1.6, (1.0 - smoothstep(0.0, warm_depth, depth)) * 0.45);
	// into the mist
	float f = smoothstep(fade.x, fade.y, depth);
	c *= 1.0 - deep_dark * smoothstep(fade.x, fade.y, depth);
	ALBEDO = mix(c, mist_color, f * 0.9);
	ROUGHNESS = 1.0;
	EMISSION = mist_color * f * 0.25;
}
