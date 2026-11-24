shader_type spatial;
// The clock on the rim of the Suspensao Absoluta: an amber ring on the floor that empties clockwise as the seconds run out.
render_mode unshaded, blend_mix, cull_disabled, shadows_disabled, depth_draw_never;

uniform vec4 color : source_color = vec4(1.0, 0.62, 0.18, 0.9);
uniform float left : hint_range(0.0, 1.0) = 1.0;
uniform float band = 0.05;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float ring = smoothstep(1.0 - band * 2.0, 1.0 - band * 1.8, r) * (1.0 - smoothstep(0.99, 1.0, r));
	float a = atan(p.x, -p.y) / 6.2831853 + 0.5;  // 0 at the top, clockwise
	float on = step(a, left);
	// the faint track where it already ran out
	float alpha = ring * mix(0.18, color.a, on);
	ALBEDO = color.rgb;
	ALPHA = alpha;
}
