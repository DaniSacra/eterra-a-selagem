shader_type spatial;
// A puff of bone dust (effects pass 2026-11-25, Fx.puff): a flipbook of 8 painted frames (assets/textures/fx/puff_sheet.png,
// 4 x 2) facing the camera, opening, curling and coming apart over its life. Laid over what is behind it (premultiplied).
// `lit` makes its first frames glow warm (a death's burst of light), then it settles to the dust's own colour.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled, fog_disabled;

uniform sampler2D sheet : filter_linear;
uniform vec4 color : source_color = vec4(0.5, 0.46, 0.4, 1.0);
uniform float life = 0.0;
uniform float cover = 0.55;
uniform float lit = 0.0;
uniform float rot = 0.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

float frame_at(float f, vec2 uv) {
	float i = clamp(floor(f), 0.0, 7.0);
	vec2 cell = vec2(mod(i, 4.0), floor(i / 4.0));
	return texture(sheet, (cell + clamp(uv, vec2(0.01), vec2(0.99))) / vec2(4.0, 2.0)).r;
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float a = rot;
	vec2 q = vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a)) * 0.5 + 0.5;
	float f = clamp(life, 0.0, 0.999) * 8.0 - 0.5;
	float d = mix(frame_at(f, q), frame_at(f + 1.0, q), fract(max(f, 0.0)));
	float fade = 1.0 - smoothstep(0.65, 1.0, life);
	float hot = lit * (1.0 - smoothstep(0.0, 0.35, life));
	vec3 base = color.rgb * (0.6 + 0.4 * d);
	vec3 glow = vec3(1.0, 0.86, 0.6) * hot * d * 1.6;
	float alpha = clamp(d * cover * fade, 0.0, 1.0);
	if (alpha < 0.01 && hot < 0.01) discard;
	ALBEDO = base * alpha + glow;
	ALPHA = alpha;
}
