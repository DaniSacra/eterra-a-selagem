shader_type spatial;
// Overlay on the paladin: white flash when hit, a colour glow while charging or shielded, a thin warm edge.
// Everything but the hit flash stays on the edge of the body: at the game's camera the hero is about 90 px tall,
// and a glow over the whole body painted him gold (Daniel's capture, 2026-11-14).
render_mode unshaded, blend_add, cull_back, shadows_disabled, depth_draw_never;

uniform float flash = 0.0;
uniform vec4 glow : source_color = vec4(0.0);
// A steady coloured edge so the paladin reads in a crowd (alpha is strength).
uniform vec4 outline : source_color = vec4(1.0, 0.78, 0.35, 0.0);
// How much of the glow covers the body (the rest is on the edge), where the edge starts (0..1 of the grazing
// angle) and how bright it gets (below the glow threshold of the WorldEnvironment, so it does not bloom).
uniform float glow_body = 0.06;
uniform float edge_from = 0.9;
uniform float edge_gain = 0.18;

void fragment() {
	float grazing = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float rim = grazing * grazing * grazing;
	float edge = smoothstep(edge_from, 1.0, grazing);
	ALBEDO = vec3(1.0) * flash * 1.6 + glow.rgb * glow.a * (glow_body + rim * 1.2) + outline.rgb * outline.a * edge * edge_gain;
}
