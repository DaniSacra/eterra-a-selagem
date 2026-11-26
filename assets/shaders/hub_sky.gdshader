shader_type spatial;
// SV-R (Santuario da Vigilia): the sky and the sea of cloud under the hub, one unlit gradient. `vertical` = 1 on the
// standing card (UV.y 0 at its top: top_color there, bottom_color at its foot), 0 on the flat plane under the floor (UV.y 0
// at its north end: top_color far away to the north, bottom_color toward the camera). `cloud` mottles it with soft noise
// in world space so the sea is not a flat sheet.
render_mode unshaded, cull_disabled, depth_draw_always, fog_disabled, shadows_disabled;

uniform vec3 top_color : source_color = vec3(0.45, 0.65, 0.85);
uniform vec3 bottom_color : source_color = vec3(0.98, 0.88, 0.72);
uniform float vertical = 1.0;
uniform float cloud = 0.0;
uniform float cloud_scale = 0.02;

varying vec3 world;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float t = clamp(UV.y, 0.0, 1.0);
	vec3 c = mix(top_color, bottom_color, vertical > 0.5 ? t : 1.0 - t);
	float n = noise(world.xz * cloud_scale) * 0.65 + noise(world.xz * cloud_scale * 3.1) * 0.35;
	ALBEDO = c * (1.0 + cloud * (n - 0.5));
}
