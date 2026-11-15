shader_type spatial;
// Overlay on the paladin: one short flash when hit, a colour glow while charging or shielded, a thin cold edge and
// the painted light on his shoulders and hair. Everything but the hit flash stays on the edge of the body: at the
// game's camera the hero is about 90 px tall, and a glow over the whole body painted him gold (Daniel's capture,
// 2026-11-14). The blink after a hit is not here: Player lightens his own colours (docs/art/cycle7_spec.md 3.2),
// since a white body is how a struck enemy looks.
render_mode unshaded, blend_add, cull_back, shadows_disabled, depth_draw_never;

uniform float flash = 0.0;
// The flash is warm and keeps the shape of the body (stronger on its edges), never a flat white.
uniform vec3 flash_color : source_color = vec3(1.0, 0.94, 0.82);
uniform float flash_gain = 0.75;
uniform vec4 glow : source_color = vec4(0.0);
// A steady coloured edge so the paladin reads in a crowd (alpha is strength).
uniform vec4 outline : source_color = vec4(1.0, 0.78, 0.35, 0.0);
// How much of the glow covers the body (the rest is on the edge), where the edge starts (0..1 of the grazing
// angle) and how bright it gets (below the glow threshold of the WorldEnvironment, so it does not bloom).
uniform float glow_body = 0.06;
uniform float edge_from = 0.9;
uniform float edge_gain = 0.18;
// The painted light that lifts his shoulders and hair off the crowd: from the top left of the screen, the crowd's
// own key (crowd.gdshader `key_dir`, view space); alpha is the gain (at most 0.35).
uniform vec3 key_dir = vec3(-0.45, 0.75, 0.5);
uniform vec4 key : source_color = vec4(1.0, 0.93, 0.8, 0.0);

void fragment() {
	float grazing = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float rim = grazing * grazing * grazing;
	float edge = smoothstep(edge_from, 1.0, grazing);
	float lobe = max(dot(NORMAL, normalize(key_dir)), 0.0);
	ALBEDO = flash_color * flash * flash_gain * (0.6 + 0.4 * grazing)
		+ glow.rgb * glow.a * (glow_body + rim * 1.2)
		+ outline.rgb * outline.a * edge * edge_gain
		+ key.rgb * key.a * lobe * lobe * lobe;
}
