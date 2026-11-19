// The body of the garden's floor moss (root_moss.gdshader and its painted twin root_moss_paint.gdshader).
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
#ifdef PAINT
// The painted moss (room redesign lot C, docs/art/room_redesign_lotC_spec.md 1): one grey green (hue about 95,
// saturation under 0.3) in three steps of value, the highest under the garden's slabs.
uniform vec3 paint_moss : source_color = vec3(0.20, 0.24, 0.17);
uniform vec3 paint_moss_steps = vec3(0.78, 0.95, 1.1);
#endif

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
#ifdef PAINT
	// three steps of value of one grey green (room redesign lot C: never a lawn, under the slabs' value)
	float t = fbm(w * 3.0 + 4.0) * 0.8 + grain * 0.3;
	float steps = mix(paint_moss_steps.x, paint_moss_steps.y, smoothstep(0.42, 0.46, t));
	steps = mix(steps, paint_moss_steps.z, smoothstep(0.62, 0.66, t));
	ALBEDO = paint_moss * steps;
#else
	ALBEDO = mix(moss_dark, moss_light, clamp(fbm(w * 3.0 + 4.0) * 0.8 + grain * 0.3, 0.0, 1.0));
#endif
	ROUGHNESS = 1.0;
	SPECULAR = 0.1;
	ALPHA = clamp(a * cover, 0.0, 1.0);
}
