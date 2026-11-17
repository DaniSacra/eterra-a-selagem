shader_type spatial;
// E5 spec 7.2: the breath of the next room in the mouth of a door used (ArenaRoom.breath): an upright card of the
// next arena's air rising out of the stairs like a breath, strongest low and gone before its top, soft at its sides,
// drifting up slowly. Unlit, no light cast, never past the colour given (its brightest channel at most 0.6) and the
// alpha given (0.35): it tells the colour of the room beyond, it never outshines the door's gem above it. thread: a
// thin wavering line of another colour through it (the runes' amber; alpha 0: none).
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(0.16, 0.5, 0.5);
uniform float alpha = 0.35;
uniform vec4 thread : source_color = vec4(0.0);
// How high the breath reaches (share of the card), the share faded at each side, how fast it rises (UV per second).
uniform float reach = 0.85;
uniform float side = 0.3;
uniform float rise = 0.06;
// The thread: its height on the card, its width (share of the card) and its strength.
uniform float thread_at = 0.62;
uniform float thread_width = 0.012;
uniform float thread_strength = 0.8;

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
	// v: 0 at the foot, 1 at the top
	float v = 1.0 - UV.y;
	float x = UV.x;
	float sides = smoothstep(0.0, side, x) * smoothstep(0.0, side, 1.0 - x);
	float up = 1.0 - smoothstep(0.15, reach, v);
	float foot = smoothstep(0.0, 0.08, v);
	float n = noise(vec2(x * 5.0, v * 3.0 - TIME * rise * 3.0)) * 0.6 + noise(vec2(x * 11.0 + 3.0, v * 6.0 - TIME * rise * 5.0)) * 0.4;
	float a = alpha * sides * up * foot * (0.55 + 0.45 * n);
	vec3 c = color;
	if (thread.a > 0.0) {
		float wave = thread_at + (noise(vec2(x * 4.0 + TIME * 0.2, 1.0)) - 0.5) * 0.12;
		float line = 1.0 - smoothstep(thread_width * 0.4, thread_width, abs(1.0 - UV.y - wave));
		float t = line * sides * thread.a * thread_strength;
		c = mix(c, thread.rgb * 0.6, t);
		a = max(a, alpha * t);
	}
	ALBEDO = c;
	ALPHA = clamp(a, 0.0, 1.0);
}
