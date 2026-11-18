shader_type spatial;
// Moss on the garden's floor (GardenLook._moss; art pack 2026-11-17, section 4: the bark, the moss and the masonry
// meet): a flat band a hair over the slabs along each big root, round the trunk's foot and along the walls' feet, in
// patches thickest where the root or the wall meets the floor and thinning out into the paving. Lit like the floor
// (it lies in the same light), a dull grey green under the floor's value: old moss in the damp, never a lawn.
// The vertex colour's alpha: 1 where the band meets the root or wall, 0 at its outer border.
render_mode blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec3 moss_dark : source_color = vec3(0.13, 0.17, 0.09);
uniform vec3 moss_light : source_color = vec3(0.27, 0.33, 0.17);
// Its largest cover (alpha) and how the patches break up: their size (per meter), where the noise starts and fills.
uniform float cover = 0.92;
uniform float patches = 1.6;
uniform vec2 patch_cover = vec2(0.25, 0.45);
// How much nearness to the root raises the patches' noise.
uniform float near_lift = 0.55;
// How fast it thins away from the root (power on the vertex colour's alpha).
uniform float reach_power = 1.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	return noise(p) * 0.55 + noise(p * 2.3 + 7.1) * 0.3 + noise(p * 5.1 + 2.7) * 0.15;
}

varying vec3 world;
varying float line;

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	line = COLOR.a;
}

void fragment() {
	vec2 w = world.xz;
	float near = pow(clamp(line, 0.0, 1.0), reach_power);
	// patches: the noise raised near the root, so it is nearly whole there and breaks into islands toward the border
	float n = fbm(w * patches);
	float a = smoothstep(patch_cover.x, patch_cover.y, n + near_lift * near - 0.35) * smoothstep(0.0, 0.2, line);
	// a fine grain of tufts inside a patch
	float grain = noise(w * 14.0);
	a *= 0.75 + 0.25 * grain;
	ALBEDO = mix(moss_dark, moss_light, clamp(fbm(w * 3.0 + 4.0) * 0.8 + grain * 0.3, 0.0, 1.0));
	ROUGHNESS = 1.0;
	SPECULAR = 0.1;
	ALPHA = clamp(a * cover, 0.0, 1.0);
}
