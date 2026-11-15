shader_type spatial;
// Last pass of the paladin's x-ray (xray.gdshader): a thin rim around his silhouette where something covers him,
// his body grown along the normals and seen from inside (the body itself, already in the depth, cuts the middle out).
render_mode unshaded, blend_mix, cull_front, shadows_disabled, depth_draw_never;

uniform vec4 color : source_color = vec4(0.72, 0.93, 0.93, 0.9);
// Meters the rim stands out of his body.
uniform float width = 0.055;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform float hidden_by = 0.25;
const float LAYER = 0.05;

void vertex() {
	vec3 at = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz + normalize(MODELVIEW_NORMAL_MATRIX * NORMAL) * width;
	POSITION = PROJECTION_MATRIX * vec4(at * LAYER, 1.0);
}

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
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
