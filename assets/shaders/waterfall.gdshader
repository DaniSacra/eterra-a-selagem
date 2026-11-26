shader_type spatial;
// SL-02 (docs/art/ref/sala02_2026-11-25): the broken fountain's thin fall of water: pale streaks sliding down a quad (UV.y 0
// at the spout, 1 at the foot), thinner at the top and breaking into foam at the foot. Cosmetic: no collision, no light of
// its own (it takes a little of the cold light), never a glowing ribbon.
render_mode blend_mix, depth_draw_never, cull_disabled, unshaded;

uniform vec3 color : source_color = vec3(0.55, 0.7, 0.78);
uniform vec3 foam_color : source_color = vec3(0.82, 0.9, 0.92);
uniform float alpha = 0.55;
uniform float speed = 1.6;
uniform float streaks = 7.0;
// the share of the height at the foot where it turns to foam
uniform float foam = 0.18;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	float across = 1.0 - abs(UV.x * 2.0 - 1.0);
	// the fall narrows at the spout and spreads a little toward the foot
	float width = mix(0.45, 1.0, smoothstep(0.0, 0.7, UV.y));
	float inside = smoothstep(0.0, 0.18, across - (1.0 - width) * 0.5);
	float s = noise(vec2(UV.x * streaks, UV.y * 2.2 - TIME * speed));
	float s2 = noise(vec2(UV.x * streaks * 2.3 + 4.0, UV.y * 3.1 - TIME * speed * 1.4));
	float body = smoothstep(0.3, 0.8, s * 0.6 + s2 * 0.4);
	float at_foot = smoothstep(1.0 - foam, 1.0, UV.y);
	float froth = at_foot * smoothstep(0.35, 0.75, noise(vec2(UV.x * 9.0, TIME * 2.0 + UV.y * 5.0)));
	ALBEDO = mix(color, foam_color, clamp(froth + at_foot * 0.4, 0.0, 1.0));
	ALPHA = clamp(alpha * inside * (0.35 + 0.65 * body) + froth * 0.5 * inside, 0.0, 0.85) * smoothstep(0.0, 0.04, UV.y);
}
