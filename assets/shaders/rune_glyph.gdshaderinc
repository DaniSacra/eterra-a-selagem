// Morvath's runes (cycle 9), shared by his circles on the floor (ritual_rune.gdshader) and his shield
// (boss_shield.gdshader): a stem and a few strokes picked by a cell's id, drawn in a cell of size `s` (any unit).

float rune_hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

float rune_seg(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a;
	vec2 ba = b - a;
	return length(pa - ba * clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0));
}

// Distance from p (0..s) to the glyph of cell `id`; some cells are left blank (a big distance).
float rune_glyph(vec2 p, vec2 s, float id) {
	if (rune_hash(vec2(id, 3.1)) < 0.12) {
		return 99.0;
	}
	float d = rune_seg(p, vec2(0.5, 0.15) * s, vec2(0.5, 0.85) * s);
	if (rune_hash(vec2(id, 1.0)) < 0.5) d = min(d, rune_seg(p, vec2(0.22, 0.85) * s, vec2(0.78, 0.85) * s));
	if (rune_hash(vec2(id, 2.0)) < 0.35) d = min(d, rune_seg(p, vec2(0.25, 0.15) * s, vec2(0.75, 0.15) * s));
	if (rune_hash(vec2(id, 4.0)) < 0.4) d = min(d, rune_seg(p, vec2(0.22, 0.25) * s, vec2(0.5, 0.6) * s));
	if (rune_hash(vec2(id, 5.0)) < 0.4) d = min(d, rune_seg(p, vec2(0.78, 0.25) * s, vec2(0.5, 0.6) * s));
	if (rune_hash(vec2(id, 6.0)) < 0.35) d = min(d, rune_seg(p, vec2(0.5, 0.45) * s, vec2(0.8, 0.62) * s));
	if (rune_hash(vec2(id, 7.0)) < 0.3) d = min(d, abs(length(p - vec2(0.5, 0.62) * s) - 0.11 * s.y));
	return d;
}
