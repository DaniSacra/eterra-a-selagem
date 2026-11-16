shader_type spatial;
// A pillar of light (or of shadow): brightest at the base, fading upwards and with life.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.9, 0.5, 1.0);
uniform float life = 0.0;
uniform float intensity = 2.5;
// No channel past this (Fx.beam: 1.0 where the column stands over the boss, so its core never goes white on him).
uniform float cap = 1000.0;

void fragment() {
	float up = 1.0 - UV.y;
	float side = pow(abs(dot(NORMAL, VIEW)), 1.5);
	float fade = 1.0 - smoothstep(0.3, 1.0, life);
	vec3 c = mix(color.rgb, vec3(1.0), side * 0.6);
	ALBEDO = min(c * side * (1.0 - up * 0.85) * fade * intensity, vec3(cap));
}
