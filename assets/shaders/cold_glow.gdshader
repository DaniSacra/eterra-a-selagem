shader_type spatial;
// The cold light far behind a door (room redesign, lot A 2.3: the crypt's north door): a card inside the arch that
// adds a cool glow, brightest at its foot and gone at its top, its sides soft. Unshaded, added, no light of its own.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 bottom : source_color = vec3(0.1, 0.17, 0.21);
uniform vec3 top : source_color = vec3(0.02, 0.03, 0.04);
uniform float side_soft = 0.18;

void fragment() {
	float sides = smoothstep(0.0, side_soft, UV.x) * smoothstep(0.0, side_soft, 1.0 - UV.x);
	// a QuadMesh's UV.y is 0 at its top
	ALBEDO = mix(top, bottom, smoothstep(0.0, 1.0, UV.y)) * sides;
}
