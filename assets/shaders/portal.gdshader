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
	vec2 uv = UV - vec2(0.5, 0.55);
	float r = length(uv * vec2(1.4, 1.0));
	float a = atan(uv.y, uv.x);
	float swirl = noise(vec2(a * 2.0 + TIME * 0.6 - r * 6.0, r * 5.0 - TIME * 0.8));
	float heart = 1.0 - smoothstep(0.0, 0.55, r);
	float edge = smoothstep(0.5, 0.0, abs(UV.x - 0.5)) * smoothstep(1.0, 0.75, UV.y) * smoothstep(0.0, 0.1, UV.y);
	float glow = (heart * 1.6 + swirl * 0.7) * edge;
	ALBEDO = color * glow * 2.2 * power;
}
