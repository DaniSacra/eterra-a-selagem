shader_type spatial;
// The violet of the Salão das Fendas (RiftLook, cycle C12; spec 3.5): flat sheets of glowing mist a few meters down
// inside the rift and the holes (the abyss's light seen from above, never a floor: patchy, drifting, its ends fading
// out), and the faint violet the abyss throws on the slabs along a lip (ramp: strongest at the drop, gone 1.5 m in).
// Unlit and see-through, under the glow's threshold.
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(0.3, 0.12, 0.6);
uniform float alpha = 0.6;
// Share of the sheet faded out at each end of UV.x, and at UV.y 0 and 1 (0: not faded).
uniform float fade_u = 0.1;
uniform vec2 fade_v = vec2(0.1, 0.1);
// 1: the alpha falls across the sheet from UV.y 0 (the drop) to 1 as the square of the distance (a lip's glow).
uniform float ramp = 0.0;
// How patchy the mist is (0: even), its swirls (per meter), its drift (m/s).
uniform float patchy = 0.5;
uniform float scale = 0.22;
uniform vec2 drift = vec2(0.12, 0.04);

varying vec3 world;

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
		p = p * 2.03 + 1.7;
		a *= 0.5;
	}
	return s;
}

// 0 at the border, 1 from w on (w 0: always 1).
float edge(float x, float w) {
	return w <= 0.0 ? 1.0 : smoothstep(0.0, w, x);
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float e = edge(UV.x, fade_u) * edge(1.0 - UV.x, fade_u) * edge(UV.y, fade_v.x) * edge(1.0 - UV.y, fade_v.y);
	float r = 1.0 - UV.y;
	e *= mix(1.0, r * r, ramp);
	float n = fbm(world.xz * scale + drift * TIME * scale);
	float m = mix(1.0, smoothstep(0.25, 0.75, n) * 1.5, patchy);
	ALBEDO = color * (0.75 + 0.5 * n);
	ALPHA = clamp(alpha * e * m, 0.0, 1.0);
}
