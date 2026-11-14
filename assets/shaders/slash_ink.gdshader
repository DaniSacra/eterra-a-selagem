shader_type spatial;
// The dark brush stroke behind a sword arc: it makes the bright streaks (slash.gdshader) stand out
// without blowing the screen out. Same UVs and timing; it lingers longer and dissolves into specks.
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(0.03, 0.02, 0.045, 1.0);
uniform float t = 0.0;
uniform float sweep = 0.25;
uniform float opacity = 0.85;
uniform bool flip = false;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	float head = clamp(t / sweep, 0.0, 1.0);
	float along = flip ? 1.0 - UV.x : UV.x;
	if (along > head) discard;
	float behind = head - along;
	float y = UV.y;

	float n1 = noise(vec2(along * 18.0, 1.0));
	float n2 = noise(vec2(along * 22.0, 7.0));
	// a thick stroke with brushed, uneven edges; thinner towards the tail
	float thin = smoothstep(0.0, 0.9, behind) * 0.35;
	float band = smoothstep(0.02 + n1 * 0.2 + thin, 0.3 + thin, y) * (1.0 - smoothstep(0.82 - n2 * 0.1, 1.0, y));
	// feathered wisps past the outer edge
	band += smoothstep(0.55, 0.85, noise(vec2(along * 40.0, y * 3.0))) * smoothstep(0.8, 0.95, y) * (1.0 - smoothstep(0.95, 1.0, y)) * 0.6;
	// streaky texture across the stroke, like dry bristles
	band *= 0.65 + 0.35 * noise(vec2(along * 6.0, y * 30.0));
	// the tail and, over time, the whole stroke break up into specks
	float cut = smoothstep(0.35, 1.0, t) * 1.15 + smoothstep(0.75, 1.0, behind) * 0.4;
	band *= smoothstep(cut, cut + 0.18, noise(vec2(along * 14.0, y * 4.0) + 3.0));
	band *= 1.0 - smoothstep(0.1, 1.0, behind) * 0.55;
	if (band <= 0.01) discard;
	ALBEDO = color.rgb;
	ALPHA = clamp(band, 0.0, 1.0) * opacity;
}
