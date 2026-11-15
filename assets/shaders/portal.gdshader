shader_type spatial;
// The way on to the next room: a sheet of green otherworldly light filling a doorway, swirling slowly and brightest
// at its heart. Unlit and glowing (above 1 the glow of the WorldEnvironment picks it up). power dims it while the
// room is not cleared.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec3 color : source_color = vec3(0.25, 1.0, 0.45);
uniform float power = 1.0;

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
	// the opening: almost the whole card, with soft sides; three dark stones hang from its top
	float top = 0.04;
	for (int i = 0; i < 3; i++) {
		float x = 0.22 + float(i) * 0.28 + (hash1(vec2(float(i), 4.0)) - 0.5) * 0.08;
		float len = 0.06 + 0.06 * hash1(vec2(float(i), 9.0));
		top = max(top, len * (1.0 - smoothstep(0.0, 0.07, abs(UV.x - x))));
	}
	float open = smoothstep(top, top + 0.015, UV.y) * smoothstep(0.0, 0.03, UV.x) * smoothstep(1.0, 0.97, UV.x);
	float swirl = noise(vec2(UV.x * 5.0 + TIME * 0.3, UV.y * 4.0 - TIME * 0.6));
	// brightest low down, where the light pours out onto the steps, and in the middle
	float pour = 0.75 + 0.45 * UV.y - 0.35 * abs(UV.x - 0.5);
	ALBEDO = color * open * (pour + 0.35 * swirl) * 0.9 * power * (0.95 + 0.05 * sin(TIME * 1.3));
}
