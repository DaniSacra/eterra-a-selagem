shader_type spatial;
// The paladin seen through whatever stands in front of him: his own colours (the petrol scarf and mantle, the copper
// hair), flat and a little lifted, only where something else covers him. Three passes on his meshes, drawn after
// everything else (Player.XRAY_PRIORITY): xray_depth lays his own depth in a layer right in front of the camera, this
// one paints the frontmost of his surfaces there, xray_edge draws the thin rim around them.
render_mode unshaded, blend_mix, cull_back, shadows_disabled, depth_draw_always;

// His painted texture (white where a piece has none) times its colour.
uniform sampler2D albedo : source_color, hint_default_white, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(1.0);
// The colours as painted times `gain`, capped under the glow threshold (read, never bloom). His dark leathers would
// be lost among the enemies: what is painted darker than `dark_to` (its brightest channel) turns to `dark`, a deep
// petrol under the lighter one of his scarf (docs/art/cycle5_spec.md A2), fully so under `dark_from`.
uniform float gain = 1.3;
uniform vec4 dark : source_color = vec4(0.15, 0.4, 0.43, 1.0);
uniform float dark_from = 0.2;
uniform float dark_to = 0.4;
uniform float opacity = 0.92;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
// Meters something must stand in front of his frontmost surface to count as hiding him (his own body does not:
// xray_depth keeps only that surface).
uniform float hidden_by = 0.25;
// His vertices are drawn this many times closer to the camera: the same place on the screen, in front of the room.
const float LAYER = 0.05;

void vertex() {
	POSITION = PROJECTION_MATRIX * vec4((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz * LAYER, 1.0);
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
	vec3 paint = texture(albedo, UV).rgb * tint.rgb;
	float bright = max(paint.r, max(paint.g, paint.b));
	ALBEDO = min(mix(dark.rgb, paint * gain, smoothstep(dark_from, dark_to, bright)), vec3(0.95));
	ALPHA = opacity;
}
