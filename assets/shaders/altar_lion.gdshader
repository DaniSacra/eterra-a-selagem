shader_type spatial;
// The lion carved on the front of the Altar Esquecido (E5 spec 6.2): the seal's own drawing (assets/textures/seal/
// lion_sdf.res, red = signed distance to its outline, green = to its inner cuts, 0.5 on each edge) raised in the
// altar's stone, no gold, no light of its own: a little lighter where it stands out, its edge and cuts shaded by the
// slope of the field (a normal map from the field's gradient), worn by a noise. Outside the lion nothing is drawn
// (a discard: works in Compatibility).

uniform sampler2D lion : filter_linear_mipmap, repeat_disable;
// Pixels of the field from the edge to the full swing, and the texture's size (tools/make_seal_lion.gd).
uniform float spread = 24.0;
uniform float px = 512.0;
// The stone, how much lighter the raised lion is, the dark of the cuts, how steep the relief's edge reads, the wear.
uniform vec3 stone : source_color = vec3(0.36, 0.34, 0.33);
uniform float raised = 1.18;
uniform float cut_dark = 0.55;
uniform float relief = 2.2;
uniform float wear = 0.25;
uniform float edge_px = 3.0;

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
	vec2 f = texture(lion, UV).rg;
	float body = (f.r - 0.5) * spread * 2.0;
	float cut = (f.g - 0.5) * spread * 2.0;
	if (body < -edge_px) {
		discard;
	}
	float e = 2.0 / px;
	float gx = texture(lion, UV + vec2(e, 0.0)).r - texture(lion, UV - vec2(e, 0.0)).r;
	float gy = texture(lion, UV + vec2(0.0, e)).r - texture(lion, UV - vec2(0.0, e)).r;
	float slope = 1.0 - smoothstep(0.0, 6.0, abs(body));
	vec3 n = normalize(vec3(-gx * relief * slope * 20.0, gy * relief * slope * 20.0, 1.0));
	NORMAL_MAP = n * 0.5 + 0.5;
	float in_body = smoothstep(-edge_px, 0.5, body);
	float in_cut = smoothstep(-1.2, 0.3, cut);
	float worn = 1.0 - wear * vnoise(UV * 40.0);
	vec3 c = stone * mix(1.0, raised * worn, in_body);
	c *= mix(1.0, cut_dark, in_cut * in_body);
	ALBEDO = c;
	ALPHA = in_body;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ROUGHNESS = 0.85;
}
