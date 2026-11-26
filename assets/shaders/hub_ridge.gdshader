shader_type spatial;
// SV-R (Santuario da Vigilia): one layer of far mountains, a card standing north of the hub: a ridge line from layered
// noise, the colour going from `low_color` at the foot of the ridge to `top_color` at its crest, nothing above the line.
// Unlit (it is the distance: the nearer the layer the darker and greener) and never fogged twice.
render_mode unshaded, cull_disabled, depth_draw_never, fog_disabled, shadows_disabled;

uniform vec3 low_color : source_color = vec3(0.5, 0.6, 0.6);
uniform vec3 top_color : source_color = vec3(0.7, 0.78, 0.82);
// The ridge's base share of the card's height and how much it rises and falls.
uniform vec2 ridge = vec2(0.4, 0.3);
uniform float scale = 5.0;
uniform float seed = 0.0;
// The crest's softness (a share of the card's height).
uniform float soft = 0.004;

float hash(float n) {
	return fract(sin(n * 127.1 + seed * 31.7) * 43758.5453);
}

float noise(float x) {
	float i = floor(x);
	float f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(hash(i), hash(i + 1.0), f);
}

void fragment() {
	float x = UV.x * scale + seed;
	float line = ridge.x + ridge.y * (noise(x) * 0.6 + noise(x * 2.7) * 0.28 + noise(x * 7.3) * 0.12);
	float y = 1.0 - UV.y;
	float inside = 1.0 - smoothstep(line - soft, line + soft, y);
	ALBEDO = mix(low_color, top_color, clamp(y / max(line, 0.01), 0.0, 1.0));
	ALPHA = inside;
}
