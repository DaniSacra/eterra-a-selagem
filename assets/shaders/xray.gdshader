shader_type spatial;
// Second pass on the paladin: a faint coloured silhouette drawn through whatever stands in front of him.
render_mode unshaded, blend_add, cull_back, shadows_disabled, depth_draw_never, depth_test_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.78, 0.35, 0.0);

void fragment() {
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 1.5);
	ALBEDO = color.rgb * color.a * (0.15 + rim * 0.9);
}
