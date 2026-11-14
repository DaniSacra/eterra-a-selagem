shader_type spatial;
// Laid over the tiled floor of the hall (alpha blended, lit like the stone) so the even hexagons stop reading as a
// pattern: a flat wash of dark slate over the tiles, pale painted clearings with ragged edges (where the eye rests),
// damp stains, thin cracks and a haze that darkens towards the walls. Near the torches it thins out, so their
// light pools on clean stone.
render_mode blend_mix, cull_disabled, depth_draw_never, diffuse_lambert, specular_disabled;

uniform float half_size = 36.0;
// Torch positions on the floor (x, z) and how many are set.
uniform vec2 torches[32];
uniform int torch_count = 0;
uniform vec3 wash_color : source_color = vec3(0.11, 0.13, 0.14);
uniform float wash_strength = 0.7;
uniform vec3 clearing_color : source_color = vec3(0.3, 0.32, 0.31);
uniform float clearing_strength = 0.8;
// How much of the floor the clearings cover (higher is less) and how ragged their edges are.
uniform float clearing_threshold = 0.6;
uniform float clearing_ragged = 0.08;
// Size of the clearings: higher is smaller and more of them.
uniform float clearing_scale = 0.075;
uniform vec3 stain_color : source_color = vec3(0.07, 0.1, 0.11);
uniform vec3 crack_color : source_color = vec3(0.03, 0.045, 0.05);
uniform vec3 haze_color : source_color = vec3(0.025, 0.05, 0.06);
uniform float stain_strength = 0.6;
uniform float crack_strength = 0.75;
uniform float haze_strength = 0.85;

varying vec2 world;

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
vec2 hash2(vec2 p) { return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453); }

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += noise(p) * a;
		p *= 2.03;
		a *= 0.5;
	}
	return v;
}

// Distance to the nearest edge between Voronoi cells: thin lines where it is near zero.
float cell_edge(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 o = hash2(i + g);
			float d = length(g + o - f);
			if (d < d1) { d2 = d1; d1 = d; } else if (d < d2) { d2 = d; }
		}
	}
	return d2 - d1;
}

void fragment() {
	// stains: big soft patches
	float stain = smoothstep(0.42, 0.75, fbm(world * 0.07)) * stain_strength;
	// cracks: only in some places, thin and broken
	float where = smoothstep(0.55, 0.7, fbm(world * 0.05 + 17.0));
	float crack = 1.0 - smoothstep(0.0, 0.05, cell_edge(world * 0.35 + fbm(world * 0.3) * 0.8));
	crack *= where * smoothstep(0.3, 0.6, noise(world * 1.3)) * crack_strength;
	// haze at the edges of the hall
	vec2 a = abs(world) / half_size;
	float haze = smoothstep(0.55, 1.0, max(a.x, a.y)) * (0.75 + 0.25 * noise(world * 0.2)) * haze_strength;
	// clean stone where the torches light it
	float pool = 0.0;
	for (int i = 0; i < 32; i++) {
		if (i >= torch_count) break;
		pool = max(pool, 1.0 - smoothstep(2.0, 7.0, distance(world, torches[i])));
	}
	haze *= 1.0 - pool * 0.8;
	stain *= 1.0 - pool * 0.6;
	// pale clearings: big shapes with a ragged, dry-brushed edge, mottled inside
	float shape = fbm(world * clearing_scale + 31.0) + (noise(world * 0.9) - 0.5) * clearing_ragged + (noise(world * 3.1) - 0.5) * clearing_ragged * 0.4;
	float clearing = smoothstep(clearing_threshold, clearing_threshold + 0.03, shape);
	vec3 pale = clearing_color * (0.85 + 0.25 * fbm(world * 0.6));
	// layer them: haze over cracks over stains over clearings over the wash
	vec3 c = mix(wash_color, pale, clearing);
	float alpha = mix(wash_strength, clearing_strength, clearing);
	stain *= 1.0 - clearing * 0.7;
	c = mix(c, stain_color, stain / max(alpha + stain, 0.001));
	alpha = alpha + stain * (1.0 - alpha);
	c = mix(c, crack_color, crack);
	alpha = alpha + crack * (1.0 - alpha);
	c = mix(c, haze_color, haze / max(alpha + haze, 0.001));
	alpha = alpha + haze * (1.0 - alpha);
	ALBEDO = c;
	ALPHA = clamp(alpha, 0.0, 1.0);
}
