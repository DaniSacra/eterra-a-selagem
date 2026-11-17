shader_type spatial;
// Ímpeto's charges (Player.show_fury; warrior_spec.md 4, "três brasas esmeralda pequenas na lâmina, abaixo do glow"):
// a small ember on the Emeth's blade per charge. The blade is emerald and lit itself, so an emerald dot alone vanished
// on it (E2 capture): each ember is a pale emerald heart in an emerald body ringed by a thin dark ink, flickering a
// little as an ember does, drawn over the blade and the body (no depth test: the hero's own x-ray passes write the
// depth over him, and the Emeth reads over him there too). Its brightest channel is `peak`
// (under the glow threshold 1.3 and kept by ScreenTone, set by Player), laid over what is behind (premultiplied:
// mixed, never added). A billboard on a quad (QuadMesh 1 x 1, its size given by the mesh).
render_mode unshaded, blend_premul_alpha, depth_test_disabled, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(0.3, 1.0, 0.45, 1.0);
uniform float peak = 1.0;
// How far the heart goes toward white, its size and the body's (shares of the quad's half width), the ink ring.
uniform float heart_pale = 0.5;
uniform float heart = 0.32;
uniform float body = 0.62;
uniform float ink = 0.55;
// The flicker: how much its light breathes and how fast (cycles a second); each ember its own phase.
uniform float flicker = 0.18;
uniform float flicker_rate = 3.1;
instance uniform float phase = 0.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0), vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
}

void fragment() {
	float r = length(UV - 0.5) * 2.0;
	if (r >= 1.0) discard;
	float t = TIME * flicker_rate * 6.2832 + phase * 6.2832;
	float breath = 1.0 - flicker * (0.5 + 0.5 * sin(t) * sin(t * 1.7 + 1.3));
	vec3 hue = color.rgb / max(max(color.r, color.g), max(color.b, 0.001));
	float in_body = 1.0 - smoothstep(body * 0.8, body, r);
	float in_heart = 1.0 - smoothstep(heart * 0.5, heart, r);
	vec3 light = hue * peak * 0.8 * in_body;
	light = mix(light, mix(hue, vec3(1.0), heart_pale) * peak, in_heart);
	light *= breath;
	float ring = smoothstep(body * 0.8, body, r) * (1.0 - smoothstep(0.75, 1.0, r));
	float a = max(in_body, ring * ink);
	ALBEDO = light;
	ALPHA = a;
}
