shader_type spatial;
// Last pass of the paladin's x-ray (xray.gdshader): a hair of warm light around his silhouette where something
// covers him, his body grown along the normals and seen from inside (the body itself, already in the depth, cuts
// the middle out). Its width is set on the screen, so it stays a hair at any camera distance
// (docs/art/cycle7_spec.md 3.2: at most 1.5 px on a 941 line screen, never a thick white outline).
render_mode unshaded, blend_mix, cull_front, shadows_disabled, depth_draw_never;

uniform vec4 color : source_color = vec4(0.96, 0.9, 0.78, 0.5);
// Pixels the rim stands out of his body on a screen `lines` tall (it scales with the screen).
uniform float width = 1.5;
uniform float lines = 941.0;
// Meters the rim is drawn behind his surface: more than his body is deep, so one limb in front of another draws
// no line inside him (only the outer silhouette is left).
uniform float behind = 1.6;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform float hidden_by = 0.25;
const float LAYER = 0.05;

void vertex() {
	vec3 seen = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	// pushed away along the line of sight: the same place on the screen
	vec4 at = PROJECTION_MATRIX * vec4(seen * (1.0 + behind / length(seen)) * LAYER, 1.0);
	vec3 n = normalize(MODELVIEW_NORMAL_MATRIX * NORMAL);
	// the normal on the screen, in pixels; clip space is 2 across the screen whatever its size
	vec2 dir = (PROJECTION_MATRIX * vec4(n, 0.0)).xy * VIEWPORT_SIZE;
	float len = length(dir);
	if (len > 0.0001) {
		at.xy += dir / len * (2.0 * width / lines) * vec2(VIEWPORT_SIZE.y / VIEWPORT_SIZE.x, 1.0) * at.w;
	}
	POSITION = at;
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
