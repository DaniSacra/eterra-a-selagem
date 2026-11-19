shader_type spatial;
// The distant vortex of the Salão das Fendas B in the stylized look (room redesign lot B, F5): an accent far behind
// the rift's north mouth, never a light. A card with a slow spiral of desaturated violet, its arms fading out to the
// rim and in toward a dark eye; its brightest channel at `peak` (the art's 0.45); it turns `turn` turns a second.
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;

uniform vec3 color : source_color = vec3(0.28, 0.2, 0.42);
uniform float peak = 0.45;
uniform float turn = 0.02;
uniform float arms = 3.0;
uniform float twist = 5.5;
uniform float alpha = 0.7;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

void fragment() {
	vec2 m = (UV - 0.5) * 2.0;
	float r = length(m);
	float a = atan(m.y, m.x) + TIME * turn * 6.2831853;
	// the spiral: arms wound by the radius, broken by a little noise
	float s = sin(a * arms + log(max(r, 0.02)) * twist);
	float arm = smoothstep(0.1, 0.95, s * 0.5 + 0.5) * mix(0.6, 1.0, noise(m * 5.0 + vec2(a, 0.0)));
	float rim = 1.0 - smoothstep(0.55, 1.0, r);
	float eye = smoothstep(0.06, 0.3, r);
	float k = arm * rim * eye;
	vec3 c = color * mix(0.55, 1.0, arm);
	// the brightest channel never over peak
	c *= peak / max(max(color.r, color.g), color.b);
	ALBEDO = c;
	ALPHA = alpha * k * (0.35 + 0.65 * rim);
}
