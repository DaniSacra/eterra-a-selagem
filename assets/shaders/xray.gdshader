shader_type spatial;
// Second pass on the paladin: a faint coloured silhouette drawn through whatever stands in front of him, and only
// there (where he is in plain sight it would add its gold over his own body).
render_mode unshaded, blend_add, cull_back, shadows_disabled, depth_draw_never, depth_test_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.78, 0.35, 0.0);
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
// Meters something must stand in front of him to count as hiding him: more than his own depth, or his mantle,
// scarf and arms hide the rest of him and the silhouette paints over his own body.
uniform float hidden_by = 1.0;

void fragment() {
	float depth = texture(depth_tex, SCREEN_UV).r;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
#else
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
#endif
	vec4 scene = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	if (-scene.z / scene.w > -VERTEX.z - hidden_by) {
		discard;
	}
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 1.5);
	ALBEDO = color.rgb * color.a * (0.04 + rim * 0.6);
}
