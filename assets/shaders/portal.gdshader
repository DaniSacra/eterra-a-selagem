shader_type spatial;
// The way on to the next room: a sheet of green otherworldly light deep in a doorway. Brightest at its foot (the
// mouth where the light pours out, two lighter patches on the ground), fading toward the top, darker along its sides,
// with wisps rising slowly through it. Unlit and added on top (above 1 the glow of the WorldEnvironment picks it up a
// little). power dims it while the room is not cleared. The teeth hanging from the lintel are stone, not painted.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec3 color : source_color = vec3(0.25, 1.0, 0.45);
uniform float power = 1.0;
// The sheet's size in meters (for the dark sides), its value at the top (1 at the foot), how far the sides darken.
uniform vec2 size = vec2(3.8, 4.6);
uniform float top_value = 0.65;
uniform float side_dark = 0.3;
// The wisps: how much they change the light, how fast they rise (m/s).
uniform float wisp = 0.15;
uniform float rise = 0.08;
// The two lighter patches at the foot: how much lighter.
uniform float mouth = 0.45;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	float s = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		s += noise(p) * a;
		p = p * 2.03 + 1.3;
		a *= 0.5;
	}
	return s;
}

void fragment() {
	vec2 m = vec2(UV.x, 1.0 - UV.y) * size;
	float v = mix(top_value, 1.0, UV.y);
	float sides = smoothstep(0.0, side_dark, min(m.x, size.x - m.x));
	v *= mix(0.35, 1.0, sides);
	// wisps: long upright streaks rising
	float w = fbm(vec2(m.x * 2.2, m.y * 0.9 - TIME * rise * 0.9));
	float streak = fbm(vec2(m.x * 4.5 + 3.0, m.y * 0.5 - TIME * rise * 0.5));
	v *= 1.0 + wisp * (w * 2.0 - 1.0) * 2.0 + wisp * (streak - 0.5) * 2.0;
	// the mouth: two lighter patches low down
	vec2 a = (m - vec2(size.x * 0.33, 0.35)) / vec2(0.7, 0.45);
	vec2 b = (m - vec2(size.x * 0.68, 0.3)) / vec2(0.6, 0.4);
	v += mouth * (exp(-dot(a, a)) + exp(-dot(b, b)));
	ALBEDO = color * max(v, 0.0) * power * (0.96 + 0.04 * sin(TIME * 1.3));
}
