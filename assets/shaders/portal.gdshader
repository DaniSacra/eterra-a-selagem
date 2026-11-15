shader_type spatial;
// The way on to the next room: a sheet of otherworldly light deep in a doorway (green; red for Morvath, gold for a
// reward). Cycle 7: it has structure and is not a blown-out panel: a small bright core low in the middle, a body
// that darkens and deepens in colour toward the sides and the top, slow upright veils drifting through it. Unlit
// and added on top; only the core goes over 1 (the glow of the WorldEnvironment picks that up). power dims it
// while the room is not cleared. The teeth hanging from the lintel are stone, not painted.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec3 color : source_color = vec3(0.25, 1.0, 0.45);
uniform float power = 1.0;
// The sheet's size in meters.
uniform vec2 size = vec2(3.8, 4.6);
// The body's value at its foot in the middle (power 1), the share of it left at the top and at the sides, and how
// fast it falls to the sides (higher: a wider bright middle).
uniform float body = 0.45;
uniform float top_value = 0.7;
uniform float side_value = 0.45;
uniform float side_curve = 2.0;
// The veils: how much they darken the body, upright streaks per meter, their stretch (cycles per meter of height),
// how fast they rise (m/s) and how far they sway (m).
uniform float veil = 0.42;
uniform float veil_streaks = 1.7;
uniform float veil_stretch = 0.22;
uniform float rise = 0.1;
uniform float sway = 0.1;
// The core: its middle and radii (shares of the sheet's size) and the value it adds.
uniform vec2 core_at = vec2(0.5, 0.27);
uniform vec2 core_radius = vec2(0.12, 0.1);
uniform float core_value = 0.9;
// Away from the core the colour deepens: its channels raised to this power (the weak ones fall, the strong one stays).
uniform float deep = 1.7;
// The bright core keeps this share of each channel (less blue: where the sheet goes over 1 the tonemap and the glow
// wash it toward cyan, and the picture's core is a pure green), between these two values of the light.
uniform vec3 core_tint = vec3(0.6, 1.0, 0.4);
uniform vec2 core_range = vec2(0.7, 1.4);
// The sheet cut to a pointed arch: x = the springing's height over the sheet's foot, y = the span, z = the radius of
// the two arcs (m; their centres on the springing line). Zero span: the whole rectangle glows.
uniform vec3 arch = vec3(0.0);

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
	vec2 n = m / size;
	// the body: brightest at the foot in the middle, falling to the top and to the sides
	float across = 1.0 - pow(abs(n.x * 2.0 - 1.0), side_curve);
	float v = body * mix(1.0, top_value, n.y) * mix(side_value, 1.0, across);
	// veils: long upright streaks swaying and rising slowly, two widths of them
	float x = m.x + sway * sin(m.y * 1.3 + TIME * 0.4);
	float wide = fbm(vec2(x * veil_streaks, m.y * veil_stretch - TIME * rise * veil_stretch));
	float fine = fbm(vec2(x * veil_streaks * 2.7 + 3.0, m.y * veil_stretch * 1.6 - TIME * rise * veil_stretch * 2.2));
	float fold = smoothstep(0.3, 0.62, wide) * 0.7 + smoothstep(0.35, 0.65, fine) * 0.3;
	v *= 1.0 - veil * (1.0 - fold);
	// the core: a small bright heart low in the middle, the veils thinning it a little
	vec2 c = (n - core_at) / core_radius;
	float heart = exp(-dot(c, c));
	v += core_value * heart * (0.75 + 0.25 * fold);
	if (arch.y > 0.0) {
		float off = abs(m.x - size.x * 0.5);
		float cx = arch.z - arch.y * 0.5;
		float d = m.y > arch.x ? length(vec2(off + cx, m.y - arch.x)) - arch.z : off - arch.y * 0.5;
		v *= 1.0 - smoothstep(-0.05, 0.0, d);
	}
	// deep colour in the body, the plain colour toward the core
	float near_core = smoothstep(0.0, 0.8, heart + across * 0.25);
	vec3 col = pow(color, vec3(mix(deep, 1.0, near_core)));
	col *= mix(vec3(1.0), core_tint, smoothstep(core_range.x, core_range.y, v));
	ALBEDO = col * max(v, 0.0) * power * (0.96 + 0.04 * sin(TIME * 1.3));
}
