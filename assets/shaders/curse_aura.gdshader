shader_type spatial;
// A boss's curse on the paladin (CurseAura): a few small violet runes that turn around him (rune) and a faint violet
// haze on the floor under his feet (not rune). Both stay under the glow threshold: they say "cursed" without lighting
// the room, and the haze is thin enough that a warning on the floor reads through it.
render_mode unshaded, blend_mix, cull_disabled, shadows_disabled, depth_draw_never;

uniform bool rune = true;
uniform vec3 color : source_color = vec3(0.62, 0.32, 0.95);
uniform float brightness = 0.9;
// 0..1: the curse rises and goes (CurseAura.power).
uniform float power = 0.0;
// The floor haze's most opacity.
uniform float haze = 0.34;
// Which of the four runes a quad shows (CurseAura sets one per quad).
instance uniform float variant = 0.0;

float seg(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a, ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return length(pa - ba * h);
}

// Three strokes of a rune, in a unit square (y down).
float glyph(vec2 p, int v) {
	if (v == 0) {
		return min(seg(p, vec2(0.42, 0.12), vec2(0.42, 0.88)), min(seg(p, vec2(0.42, 0.3), vec2(0.72, 0.14)), seg(p, vec2(0.42, 0.52), vec2(0.72, 0.36))));
	} else if (v == 1) {
		return min(seg(p, vec2(0.32, 0.12), vec2(0.32, 0.88)), min(seg(p, vec2(0.32, 0.26), vec2(0.7, 0.5)), seg(p, vec2(0.7, 0.5), vec2(0.32, 0.74))));
	} else if (v == 2) {
		return min(seg(p, vec2(0.5, 0.12), vec2(0.5, 0.88)), min(seg(p, vec2(0.26, 0.32), vec2(0.74, 0.68)), seg(p, vec2(0.74, 0.32), vec2(0.26, 0.68))));
	}
	return min(seg(p, vec2(0.3, 0.88), vec2(0.5, 0.12)), min(seg(p, vec2(0.5, 0.12), vec2(0.7, 0.88)), seg(p, vec2(0.38, 0.58), vec2(0.62, 0.58))));
}

void vertex() {
	if (rune) {
		// always faces the camera, keeping its own size
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	}
}

void fragment() {
	if (rune) {
		float d = glyph(UV, int(variant + 0.5));
		float aa = fwidth(d) * 1.2;
		float stroke = 1.0 - smoothstep(0.055, 0.055 + aa, d);
		float halo = exp(-d * 9.0) * 0.35;
		float flicker = 0.85 + 0.15 * sin(TIME * 7.0 + variant * 2.1);
		ALBEDO = color * brightness * flicker;
		ALPHA = clamp(stroke + halo, 0.0, 1.0) * power;
	} else {
		float r = length(UV - 0.5) * 2.0;
		float a = atan(UV.y - 0.5, UV.x - 0.5);
		// a soft disc, a little denser towards its rim, that breathes and turns
		float body = smoothstep(1.0, 0.55, r) * (0.55 + 0.45 * smoothstep(0.2, 0.8, r));
		float swirl = 0.75 + 0.25 * sin(a * 3.0 - TIME * 1.4 + r * 6.0);
		ALBEDO = color * brightness * 0.6;
		ALPHA = body * swirl * haze * power * (0.85 + 0.15 * sin(TIME * 2.3));
	}
}
