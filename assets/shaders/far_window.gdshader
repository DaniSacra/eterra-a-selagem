shader_type spatial;
// A lancet of the Câmara do Selo's far ring (BossChamber.FAR_WINDOW*, AP-1 ART-02.5): before, a flat orange rectangle,
// read as a missing texture. Now a pointed lancet in a frame of the far stone: a mullion down the middle and a
// transom, the glass lit warm from below and fading upward (a fire low in the room behind), its amber cooler and
// under the glow threshold; an unlit one (`lit` 0) is only dark glass in its frame. Unlit (the far ring is), the
// frame in the depths' dark stone colour. One material for the lit lancets, one for the dark.
render_mode unshaded, cull_back, shadows_disabled;

// The glass's warm light at the sill and at the head (under the glow threshold), and an unlit lancet's dark glass.
uniform vec3 glass_low : source_color = vec3(1.0, 0.62, 0.3);
uniform vec3 glass_high : source_color = vec3(0.32, 0.17, 0.1);
uniform vec3 glass_dark : source_color = vec3(0.04, 0.035, 0.05);
uniform float lit = 1.0;
// The frame: its colour, its width round the opening, the mullion's and the transom's (shares of the width), where the
// transom crosses (share of the height) and where the pointed head springs.
uniform vec3 frame_color : source_color = vec3(0.07, 0.065, 0.09);
uniform float frame_w = 0.14;
uniform float mullion_w = 0.08;
uniform float transom_at = 0.58;
uniform float spring = 0.66;
// A faint flicker of the fire behind (share, Hz).
uniform float flicker = 0.08;
uniform float flicker_rate = 1.7;

void fragment() {
	// x across (-1..1), y up (0..1)
	vec2 p = vec2(UV.x * 2.0 - 1.0, 1.0 - UV.y);
	// the pointed head: two arcs from the springing line meeting at the top
	float half_w = 1.0;
	float r = 1.6;
	float inside_head = 1.0;
	if (p.y > spring) {
		float yy = (p.y - spring) / (1.0 - spring);
		// arc centre on the springing line at the far side, radius so the arcs meet at the top
		vec2 c = vec2(-(r - half_w), 0.0);
		vec2 q = vec2(abs(p.x), yy * sqrt(r * r - (r - half_w) * (r - half_w)));
		inside_head = step(length(q - vec2(c.x, 0.0)), r);
	}
	if (inside_head < 0.5) {
		discard;
	}
	// the opening: inside the frame
	float ax = abs(p.x);
	float open = step(ax, 1.0 - frame_w) * step(frame_w * 0.5, p.y);
	if (p.y > spring) {
		float yy = (p.y - spring) / (1.0 - spring);
		vec2 q = vec2(ax, yy * sqrt(r * r - (r - half_w) * (r - half_w)));
		open *= step(length(q - vec2(-(r - half_w), 0.0)), r - frame_w * 1.4);
	}
	// mullion and transom
	open *= step(mullion_w * 0.5, ax);
	open *= 1.0 - step(abs(p.y - transom_at), mullion_w * 0.4) * step(p.y, spring);
	float rise = smoothstep(0.0, 1.0, p.y);
	vec3 glass = mix(glass_low, glass_high, rise);
	glass *= 1.0 - flicker + flicker * sin(TIME * flicker_rate * 6.2831853 + UV.x * 2.0);
	glass = mix(glass_dark, glass, lit);
	ALBEDO = mix(frame_color, glass, open);
}
