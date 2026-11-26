shader_type spatial;
// The flash where a blow lands (effects pass 2026-11-25, Fx.hit_star): a painted star (assets/textures/fx/star4.png or
// star6.png, torn rays, hot core) facing the camera, white-hot for its first frames and then the colour of the blow, spun
// a little as it dies. Added over what is behind it and HDR on purpose (intensity past 1: the WorldEnvironment glow
// picks it up on Forward+, over its threshold; Fx lowers it on Compatibility). Short: 3 to 6 frames.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled, fog_disabled;

uniform sampler2D star : source_color, filter_linear_mipmap;
uniform vec4 color : source_color = vec4(0.3, 1.0, 0.5, 1.0);
uniform float life = 0.0;
uniform float intensity = 3.0;
uniform float rot = 0.0;
// 0..1: how long the white-hot part lasts (a share of life)
uniform float hot = 0.3;
// PM-1: in the stylized look (art_style 1) the round white clap under the star is nearly gone (it read as a white disc over the target).
global uniform float art_style;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float a = rot + life * 0.35;
	vec2 q = vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
	// the star shrinks its rays as it fades but keeps its core
	float grow = mix(0.8, 1.0, smoothstep(0.0, 0.2, life));
	float s = texture(star, q / grow * 0.5 + 0.5).r;
	float fade = 1.0 - smoothstep(0.25, 1.0, life);
	float heat = 1.0 - smoothstep(0.0, hot, life);
	vec3 tint = mix(color.rgb / max(max(color.r, max(color.g, color.b)), 0.001), vec3(1.0, 0.97, 0.9), heat);
	// a round clap of white light under the star while hot
	float clap = exp(-dot(p, p) * 14.0) * heat * mix(1.0, 0.12, art_style);
	vec3 light = (tint * s * fade + vec3(1.0, 0.95, 0.85) * clap * 0.9) * intensity;
	if (max(light.r, max(light.g, light.b)) < 0.01) discard;
	ALBEDO = light;
}
