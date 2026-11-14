shader_type spatial;
// The dark wake of a sword arc: wisps of smoke that trail behind the bright streaks and linger a little longer.
// Same UV layout as slash.gdshader.
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(0.03, 0.02, 0.05, 1.0);
uniform float t = 0.0;
uniform float strength = 0.7;
uniform bool flip = false;
uniform float seed = 0.0;

float hash2(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 17.0) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash2(i), hash2(i + vec2(1, 0)), f.x), mix(hash2(i + vec2(0, 1)), hash2(i + vec2(1, 1)), f.x), f.y);
}

void fragment() {
	float along = flip ? 1.0 - UV.x : UV.x;
	float head = clamp(t * 2.0, 0.0, 1.0);
	if (along > head) discard;
	float env = pow(sin(3.14159 * along), 0.8);
	float across = (UV.y - (1.0 - env)) / max(env, 0.001);
	if (across < 0.0) discard;
	// wisps stretched along the swing, drifting outwards as it ages
	float n = noise(vec2(along * 6.0 - t * 1.5, across * 5.0 + t * 2.0));
	n = n * 0.7 + noise(vec2(along * 14.0, across * 11.0 - t * 3.0)) * 0.3;
	float wisp = smoothstep(0.42 + t * 0.35, 0.9, n) * 0.85;
	float band = smoothstep(0.1, 0.5, across) * (1.0 - smoothstep(0.85, 1.0, across));
	float trail = clamp(1.0 - (head - along) * 1.1, 0.0, 1.0);
	float life = 1.0 - smoothstep(0.35, 1.0, t);
	ALBEDO = color.rgb;
	ALPHA = clamp(wisp * band * (0.4 + trail * 0.6) * life * strength, 0.0, 1.0);
}
