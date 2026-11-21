shader_type spatial;
// A soft round mark on the floor (BreakableKit: the contact shadow round a breakable's foot, a water jar's wet ring):
// `color` at `alpha` in the middle, fading to nothing at the quad's rim. No light of its own.
render_mode blend_mix, depth_draw_never, cull_back, unshaded, shadows_disabled;

uniform vec3 color : source_color = vec3(0.0);
uniform float alpha = 0.32;

void fragment() {
	float d = length(UV - vec2(0.5)) * 2.0;
	ALBEDO = color;
	ALPHA = alpha * (1.0 - smoothstep(0.35, 1.0, d));
}
