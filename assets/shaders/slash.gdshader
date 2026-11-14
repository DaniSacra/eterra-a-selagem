shader_type spatial;
// The bright part of a sword arc, drawn over the dark ink layer (slash_ink.gdshader).
// UV.x runs along the swing (0 start, 1 end), UV.y across it (0 inner, 1 outer edge).
// t goes 0 -> 1 over the life of the slash: the head sweeps through during the first `sweep` of it,
// then a few thin brush streaks trail behind it, break up and fade.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(0.85, 0.82, 1.0, 1.0);
uniform float t = 0.0;
uniform float sweep = 0.4;
uniform float intensity = 2.2;
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

	// ragged outer edge
	if (y > 0.985 - noise(vec2(along * 40.0, 3.0)) * 0.06) discard;

	float value = 0.0;
	// the blade itself: a thick bright band right at the head
	value += smoothstep(0.1, 0.9, y) * (1.0 - smoothstep(0.0, 0.12, behind)) * 1.5;
	// four brush streaks, each with its own tail length, broken up along the swing
	for (int k = 0; k < 4; k++) {
		float fk = float(k);
		float center = 0.3 + fk * 0.19;
		float width = (0.03 + fk * 0.012) * (0.5 + 1.1 * noise(vec2(along * 9.0, fk * 3.1)));
		float tail = 0.7 + 0.35 * hash(vec2(fk, 9.0));
		float line = 1.0 - smoothstep(0.0, width, abs(y - center));
		float gaps = smoothstep(0.25, 0.55, noise(vec2(along * 26.0, fk * 5.3)));
		line *= mix(1.0, gaps, smoothstep(0.0, 0.25, behind));
		line *= 1.0 - smoothstep(tail * 0.55, tail, behind);
		line *= mix(1.0, 0.45, smoothstep(0.0, 0.8, behind));
		value += line;
	}
	float life = 1.0 - smoothstep(0.55, 1.0, t);
	vec3 c = mix(color.rgb, vec3(1.0), smoothstep(0.8, 1.6, value));
	ALBEDO = c * value * life * intensity;
}
