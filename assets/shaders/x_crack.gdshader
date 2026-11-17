shader_type spatial;
// The cross crack of the Provação (E5 spec 5.1 and 5.2): on the entry slab in the room before it (TrialLook.entry_slab)
// and on the block in its middle, a jagged X of lilac light from corner to corner, laid on the stone (a quad 1 cm over
// it, added light). Its brightest channel up to `glow` (0.8), pulsing +-15% at 0.3 Hz; level: 1 before the choice,
// TrialLook.SETTLED after it. Straight strokes, nothing round.
render_mode unshaded, blend_add, depth_draw_never, cull_back, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(0.52, 0.36, 0.78);
uniform float glow = 0.8;
uniform float level = 1.0;
uniform float pulse = 0.15;
uniform float pulse_hz = 0.3;
// The crack: its width (share of the quad), how much it wanders, its burnt halo (width, light).
uniform float width = 0.018;
uniform float wander = 0.035;
uniform float halo = 0.07;
uniform float halo_light = 0.25;
// How far short of the corners it stops (share of the half diagonal).
uniform float short_of = 0.08;

float h11(float x) {
	return fract(sin(x * 127.1) * 43758.5453);
}

float jag(float t, float seed) {
	float i = floor(t);
	return mix(h11(i + seed), h11(i + 1.0 + seed), fract(t)) - 0.5;
}

float stroke(vec2 p, vec2 dir, float seed) {
	float along = dot(p, dir);
	float across = dot(p, vec2(-dir.y, dir.x)) - (jag(along * 14.0, seed) * 0.7 + jag(along * 37.0, seed + 9.0) * 0.3) * wander;
	float reach = 0.707 * (1.0 - short_of);
	float end = 1.0 - smoothstep(reach - 0.06, reach, abs(along));
	return abs(across) / max(end, 0.001);
}

void fragment() {
	vec2 p = UV - 0.5;
	float d = min(stroke(p, normalize(vec2(1.0, 1.0)), 1.0), stroke(p, normalize(vec2(1.0, -1.0)), 5.0));
	float core = 1.0 - smoothstep(width * 0.5, width, d);
	float burn = (1.0 - smoothstep(width, halo, d)) * halo_light;
	float beat = 1.0 + pulse * sin(TIME * TAU * pulse_hz);
	ALBEDO = color / max(color.r, max(color.g, color.b)) * glow * max(core, burn) * level * beat;
}
