shader_type spatial;
// Violet light rising from far below at the sides of the abyss: an upright card, brightest at its foot and fading
// up and to the sides, slowly breathing. Added on top and kept out of the fog (it is the light the mist glows with),
// so it reads the same on desktop and in the browser.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(0.45, 0.3, 0.95);
uniform float energy = 1.6;
// How far up the card the glow reaches (0 to 1 of its height) and how soft its sides are.
uniform float reach = 0.75;
uniform float side = 0.45;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
}

void fragment() {
	float up = 1.0 - UV.y;
	float v = pow(1.0 - smoothstep(0.0, reach, up), 1.6);
	float h = 1.0 - smoothstep(0.5 - side, 0.5, abs(UV.x - 0.5));
	float n = noise(vec2(UV.x * 6.0, UV.y * 3.0 - TIME * 0.15));
	ALBEDO = color * energy * v * h * (0.6 + 0.6 * n) * (0.9 + 0.1 * sin(TIME * 0.7));
}
