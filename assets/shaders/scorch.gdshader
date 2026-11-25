shader_type spatial;
// A darkening on the floor under a strong effect (effects pass 2026-11-25, Fx.scorch): an irregular dark blotch (the first
// frame of assets/textures/fx/puff_sheet.png) laid flat, so the lit rings and cuts above it read against the green floor.
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

uniform sampler2D sheet : filter_linear;
uniform float life = 0.0;
uniform float opacity = 0.5;
uniform float rot = 0.0;
uniform vec4 color : source_color = vec4(0.02, 0.02, 0.025, 1.0);

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	vec2 q = vec2(p.x * cos(rot) - p.y * sin(rot), p.x * sin(rot) + p.y * cos(rot)) * 0.5 + 0.5;
	float d = texture(sheet, clamp(q, vec2(0.01), vec2(0.99)) * vec2(0.25, 0.5)).r;
	float in_ = smoothstep(0.0, 0.08, life);
	float out_ = 1.0 - smoothstep(0.45, 1.0, life);
	float a = d * opacity * in_ * out_;
	if (a < 0.01) discard;
	ALBEDO = color.rgb;
	ALPHA = a;
}
