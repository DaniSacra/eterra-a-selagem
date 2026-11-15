shader_type spatial;
// The wave of a finisher: a thin crescent that flies out past the blow (Fx.crescent scales it up), a blade of dark
// ink with a fine line of the blow's colour along it. The light goes first, the ink lingers and breaks into specks.
// UV.x runs along the swing, UV.y from the inner (0) to the outer edge (1). t goes 0 -> 1 over its life.
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled, fog_disabled;

uniform vec4 color : source_color = vec4(0.85, 0.82, 1.0, 1.0);
uniform vec4 ink : source_color = vec4(0.02, 0.02, 0.035, 1.0);
uniform float t = 0.0;
uniform float ink_opacity = 0.6;
uniform float edge_intensity = 1.5;
// Share of the life the light edge lasts.
uniform float edge_life = 0.85;
// How far the edge goes from the blow's colour toward white.
uniform float edge_pale = 0.3;

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
	float x = UV.x;
	float y = UV.y;
	// the ends of the crescent taper to points
	float ends = smoothstep(0.0, 0.22, x) * smoothstep(1.0, 0.78, x);
	float thick = ends * (0.8 + 0.2 * noise(vec2(x * 12.0, 2.0)));
	float body = smoothstep(1.0 - thick, 1.0 - thick + 0.3, y) * (1.0 - smoothstep(0.9, 1.0, y));
	body *= 0.7 + 0.3 * noise(vec2(x * 8.0, y * 6.0));
	float cut = smoothstep(0.3, 1.0, t) * 1.1;
	body *= smoothstep(cut, cut + 0.2, noise(vec2(x * 30.0, y * 2.0) + 7.0));
	// the light: a line a third of the band across, near its outer edge
	float edge = (1.0 - smoothstep(0.04, 0.16, abs(y - 0.78))) * ends;
	edge *= 0.7 + 0.3 * noise(vec2(x * 40.0, 5.0));
	edge *= 1.0 - smoothstep(edge_life * 0.4, edge_life, t);
	float a = max(body * ink_opacity, edge);
	if (a <= 0.01) discard;
	vec3 light = mix(color.rgb, vec3(1.0), edge_pale) * edge_intensity;
	ALBEDO = mix(ink.rgb, light, clamp(edge / max(a, 0.001), 0.0, 1.0));
	ALPHA = clamp(a, 0.0, 1.0);
}
