shader_type spatial;
// Overlay on the paladin and the big enemies: white flash when hit, a colour glow while charging or shielded.
render_mode unshaded, blend_add, cull_back, shadows_disabled, depth_draw_never;

uniform float flash = 0.0;
uniform vec4 glow : source_color = vec4(0.0);

void fragment() {
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);
	ALBEDO = vec3(1.0) * flash * 1.6 + glow.rgb * glow.a * (0.25 + rim * 1.2);
}
