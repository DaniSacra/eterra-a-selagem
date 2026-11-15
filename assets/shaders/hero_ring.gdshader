shader_type spatial;
// A thin ring on the floor around the paladin's feet, in the petrol of his scarf: faint on the open floor, clearer
// through whoever stands over it, so the eye finds him in a crowd. Never red (warnings) nor filled (areas).
render_mode unshaded, blend_mix, cull_disabled, shadows_disabled, depth_draw_never, depth_test_disabled;

uniform vec4 color : source_color = vec4(0.24, 0.56, 0.58, 1.0);
// Opacity on the open floor and through what covers it.
uniform float open = 0.35;
uniform float through = 0.75;
// The band, as a share of the quad's half side.
uniform float band = 0.09;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
// Meters in front of the ring: less than `near` is the floor itself, more than `hidden_by` covers it (in between,
// feet standing on it hide it as they would).
uniform float near = 0.08;
uniform float hidden_by = 0.6;

void fragment() {
	float d = length(UV * 2.0 - 1.0);
	float ring = smoothstep(1.0 - band, 1.0 - band * 0.6, d) * (1.0 - smoothstep(1.0 - band * 0.4, 1.0, d));
	if (ring < 0.01) {
		discard;
	}
	float depth = texture(depth_tex, SCREEN_UV).r;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
#else
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
#endif
	vec4 scene = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float ahead = -VERTEX.z + scene.z / scene.w;
	if (ahead > near && ahead < hidden_by) {
		discard;
	}
	ALBEDO = color.rgb;
	ALPHA = ring * (ahead >= hidden_by ? through : open);
}
