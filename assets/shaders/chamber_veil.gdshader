shader_type spatial;
// The veil across the mouth of the Chamber's stairs while Morvath fights (docs/art/boss_chamber_spec.md 2.6): a low
// curtain of violet runes (Morvath's glyphs, rune_glyph.gdshaderinc) standing on the sill, faint, the glyphs rising
// slowly and fading toward the top. Only a sign that the fight closes the way out; it blocks nothing.
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

#include "res://assets/shaders/rune_glyph.gdshaderinc"

// Its size (m), colour (greatest channel at most 0.8), how opaque, a glyph cell's size (m), how fast they rise (m/s),
// and how much of it shows (0 gone, 1 whole: it fades when Morvath is sealed).
uniform vec2 size = vec2(4.6, 1.2);
uniform vec3 color : source_color = vec3(0.5, 0.2, 0.8);
uniform float alpha = 0.35;
uniform vec2 cell = vec2(0.32, 0.4);
uniform float rise = 0.3;
uniform float power = 1.0;

void fragment() {
	vec2 p = vec2(UV.x * size.x, (1.0 - UV.y) * size.y);
	vec2 q = p - vec2(0.0, TIME * rise);
	vec2 id = floor(q / cell);
	vec2 local = q - id * cell;
	float d = rune_glyph(local, cell, id.x * 17.0 + id.y * 3.0);
	float glyph = 1.0 - smoothstep(0.012, 0.03, d);
	// a faint sheet, the glyphs over it; thinning toward the top and at both ends
	float fade = (1.0 - smoothstep(0.3, 1.0, p.y / size.y)) * smoothstep(0.0, 0.25, p.x) * smoothstep(0.0, 0.25, size.x - p.x);
	float a = (0.25 + 0.75 * glyph) * alpha * fade * power;
	ALBEDO = color * (0.6 + 0.4 * glyph);
	ALPHA = a;
}
