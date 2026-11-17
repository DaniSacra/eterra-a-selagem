shader_type spatial;
// The lilac veins of the Provação's floor (E5 spec 5.2, TrialLook): thin cracks of light running through the slabs,
// laid over the floor (a sheet of the floor's own triangles 1 cm over it, added light, no light cast), never closer
// than `clear` m to the block's footprint. level: 1 before the choice, falling to TrialLook.SETTLED after it. Its
// brightest channel stays at `glow` (0.5, under the glow's threshold).
render_mode unshaded, blend_add, depth_draw_never, cull_back, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(0.52, 0.36, 0.78);
uniform float glow = 0.5;
uniform float level = 1.0;
// The block's footprint (middle, half size) and how far from it the veins stop.
uniform vec2 block_center = vec2(0.0);
uniform vec2 block_half = vec2(0.6);
uniform float clear = 1.5;
// How fine the veins run (per m), how thin (pixels on the screen, so they stay hairlines at any slope of the noise),
// how much of the floor has them, their slow breath.
uniform float scale = 0.55;
uniform float width_px = 1.1;
uniform float share = 0.45;
uniform float breath = 0.12;
uniform float breath_hz = 0.3;

varying vec3 wp;

void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float h21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), u.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), u.x), u.y);
}

void fragment() {
	vec2 p = wp.xz;
	vec2 q = abs(p - block_center) - block_half;
	float to_block = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
	float fade = smoothstep(clear, clear + 1.0, to_block);
	// veins: the ridges of a warped noise
	vec2 w = p * scale + vec2(vnoise(p * 0.3), vnoise(p * 0.3 + 4.0)) * 1.5;
	float n = vnoise(w) * 0.78 + vnoise(w * 2.3 + 7.1) * 0.22;
	float px = abs(n - 0.5) / max(fwidth(n), 0.00001);
	float line = 1.0 - smoothstep(width_px * 0.5, width_px, px);
	float keep = smoothstep(1.0 - share, 1.15 - share, vnoise(p * 0.18 + 2.0));
	float beat = 1.0 + breath * sin(TIME * TAU * breath_hz);
	ALBEDO = color / max(color.r, max(color.g, color.b)) * glow * line * keep * fade * level * beat;
}
