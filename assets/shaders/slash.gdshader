shader_type spatial;
// The bright part of a sword arc, drawn over the dark ink layer (slash_ink.gdshader): one ribbon of light, not
// streaks. It is widest right behind the head of the swing and thins to nothing along its tail, which covers at
// most `tail` of the arc; the head is the brightest, so a still frame tells which way the blade went.
// UV.x runs along the swing (0 start, 1 end), UV.y across it (0 inner, 1 outer edge: the reach of the blow).
// t goes 0 -> 1 over the life of the slash: the head sweeps through during the first `sweep` of it, then the tail
// catches up with it while everything fades.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(0.85, 0.82, 1.0, 1.0);
uniform float t = 0.0;
uniform float sweep = 0.4;
uniform float intensity = 2.2;
uniform bool flip = false;
// Share of the arc the tail covers behind the head.
uniform float tail = 0.6;
// How far the front of the ribbon goes from the blow's colour toward white (never all the way).
uniform float core = 0.42;
// The ribbon at its widest, as a share of the band (cycle 8: a blade of light, not a sheet), and how much light its
// inner, soft side keeps (the edge of the blade carries the cut).
uniform float widest = 0.72;
uniform float inner_light = 0.25;

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
	float behind = head - along;
	if (behind < 0.0) discard;
	float rest = clamp((t - sweep) / max(1.0 - sweep, 0.001), 0.0, 1.0);
	float k = behind / (tail * (1.0 - 0.5 * rest));
	if (k >= 1.0) discard;
	float y = UV.y;

	// the ribbon: a pointed nose at the head, full width right behind it, a point again at the end of the tail;
	// its outer edge is always the reach of the blow
	// (and at the very end of the arc, where the swing stops: never a straight cut across the ribbon)
	float nose = pow(clamp(behind / 0.11, 0.0, 1.0), 0.8) * sqrt(smoothstep(0.0, 0.07, 1.0 - along));
	float width = nose * pow(1.0 - k, 1.3) * widest;
	float outer = 0.975 - noise(vec2(along * 40.0, 3.0)) * 0.025;
	float inner = outer - width;
	float across = (y - inner) / max(width, 0.001);
	if (across <= 0.0 || y >= outer) discard;
	// soft on the inside, sharp on the edge of the blade
	float body = smoothstep(0.0, 0.7, across) * (1.0 - smoothstep(outer - 0.02, outer, y));
	body *= mix(inner_light, 1.0, across * across * across);
	// the edge of the blade: a fine line along the outside that lasts to the end of the tail
	float wire = (1.0 - smoothstep(0.0, 0.022, abs(y - (outer - 0.035)))) * nose;
	// the head is the brightest: the light falls along the ribbon
	float glow = pow(1.0 - k, 2.0);
	float front = (1.0 - smoothstep(0.05, 0.34, k)) * smoothstep(0.3, 0.85, across);
	float value = body * (0.1 + 1.0 * glow) + wire * (0.25 + 0.5 * glow);
	float life = pow(1.0 - rest, 1.5);
	vec3 c = mix(color.rgb, vec3(1.0), core * max(front, wire * glow));
	ALBEDO = c * value * life * intensity;
}
