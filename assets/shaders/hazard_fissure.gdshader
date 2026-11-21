shader_type spatial;
// The fissure of a hazard piece (docs/art/sw_g7_hazard_grammar.md 1, rules 3 and 6; HazardPiece): a jagged dark crack
// along a strip (UV.x 0..1 along it, UV.y 0..1 across) holding a low amber ember while the hazard is awake, opening and
// lighting through the windup, full of pale dust while it sleeps. Cut out (alpha scissor): opaque, no blending.
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_lambert, specular_disabled;

// the ember's light (0.08 awake at rest, up to 0.6 in the windup's last 30%), how open it is (0 at rest: rest_width of
// the strip; 1: the whole strip), the dust of a sleeping piece, the share of the strip lit from UV.x 0 (a slit's mouth
// lighting bottom up)
uniform float ember = 0.08;
uniform float open = 0.0;
uniform float dust = 0.0;
uniform float lit_to = 1.0;
uniform vec3 ember_color : source_color = vec3(1.0, 0.55, 0.2);
uniform float ember_light = 1.0;
uniform vec3 dark : source_color = vec3(0.03, 0.028, 0.03);
uniform vec3 dust_color : source_color = vec3(0.52, 0.5, 0.47);
uniform float rest_width = 0.3;
uniform float seed = 0.0;
// how far along the strip the crack runs (a column's crack climbing), how ragged it is (0: a straight slot, a slit's
// mouth)
uniform float reach = 1.0;
uniform float ragged = 1.0;

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
	float n = noise(vec2(UV.x * 9.0 + seed, seed * 3.1)) * 0.7 + noise(vec2(UV.x * 31.0 + seed, 2.0)) * 0.3;
	n = mix(1.0, n, ragged);
	// tapered at both ends (the far one where it reaches), ragged along
	float taper = mix(1.0, smoothstep(0.0, 0.1, UV.x) * smoothstep(reach, reach - 0.1, UV.x), ragged) * step(UV.x, reach);
	float w = mix(rest_width, 1.0, open) * (0.45 + 0.55 * n) * taper;
	float d = abs(UV.y - 0.5) * 2.0;
	ALPHA = 1.0 - smoothstep(w * 0.8, w, d);
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ALBEDO = mix(dark, dust_color, dust);
	ROUGHNESS = 1.0;
	// the ember glows in the crack's middle, nothing while it sleeps
	float core = 1.0 - smoothstep(0.0, max(w, 1e-3), d) * 0.6;
	EMISSION = ember_color * ember * ember_light * core * (1.0 - dust) * step(UV.x, lit_to);
}
