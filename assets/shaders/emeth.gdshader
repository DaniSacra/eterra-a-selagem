shader_type spatial;
// Emeth, the sword of truth (EmethSword): the Meshy model's own painting, a little of it as light everywhere (the
// hero's fill: guard, grip and pommel keep their colours away from the torches) and the crystal blade lit from
// inside in emerald. The blade's light stays under the glow threshold of the WorldEnvironment, so it keeps its
// shape and its gold veins; only the pale edge down its middle (EmethSword.CORE) blooms.

uniform sampler2D albedo : source_color, filter_linear_mipmap;
// The painting as light, on the whole sword.
uniform float fill = 0.28;
// The blade: the model's height (its own space) where it starts, the emerald its painting is seen through and how
// bright that is.
uniform float blade_from = -0.1;
uniform vec3 blade_color : source_color = vec3(0.08, 0.85, 0.27);
uniform float blade_glow = 1.0;
// A swing lifts the blade's light for an instant (EmethSword.set_pulse): added to blade_glow.
uniform float pulse = 0.0;
// A boss's curse on the paladin (EmethSword.set_corrupt, 0..1): veins of dark violet creep up the crystal from the
// guard and dull the emerald where they run; the upper part of the blade and its gold veins stay Emeth's.
uniform float corrupt = 0.0;
uniform vec3 corrupt_color : source_color = vec3(0.42, 0.1, 0.62);
// How far up the blade (share of its length) the corruption reaches at its fullest.
uniform float corrupt_reach = 0.7;
// How much of the painting's own colour (the gold veins, the pale crystal) the blade's light keeps.
uniform float blade_paint = 0.35;
uniform float roughness = 0.4;
uniform float metallic = 0.3;

// Eterra Stylized (STY-06, T22; docs/art/stylized_spec.md 3.3): with the global art_style at 1 the crystal is painted in
// two bands of emerald, the deep one (hue 140, value 0.45) on the side away from the key (view space, the crowd's) and
// the face (hue 133, value 0.75) toward it, split over style_split; the gold veins keep blade_paint of the painting; no
// channel of the sword passes style_cap (no light past 1.0, the pulse of a swing included). The pale edge down the
// middle is EmethSword's (EmethSword.STYLE_CORE). art_style 0: the classic blade, unchanged.
global uniform float art_style;
uniform vec3 style_back : source_color = vec3(0.07, 0.45, 0.2);
uniform vec3 style_face : source_color = vec3(0.16, 0.75, 0.3);
uniform vec3 style_key = vec3(-0.45, 0.75, 0.5);
uniform float style_split = 0.12;
uniform float style_cap = 0.6; // STY-09: 0.98 still clipped to white on the screen (exposure 1.25)
// STY-09: under the stylized key (1.6, the classic moon is 0.35) the crystal's own lit albedo clipped to white on the
// screen: the blade takes only this share of it there (its colour is the two painted bands of the emission).
uniform float style_lit = 0.25;

// Temperar (Fatia 1, docs/design/rejogabilidade/sistemas.md 3.4; EmethSword.set_temper): the Forjador's rank of the
// blade, 0 to 2 (fractions grow the marks in). Each rank lays one vein of old gold along a flat of the crystal (rank 1
// the left of the middle, to temper_reach.x of the blade; rank 2 the right as well, to temper_reach.y) and one more
// reach of the pale thread along the cutting edges (rank 1 to temper_edge.x of the blade, rank 2 to the tip). Nothing
// passes 1.0 in a channel (under the glow); in the stylized look the gold and the thread under style_cap. 0: nothing
// drawn, the blade as before.
uniform float temper = 0.0;
uniform vec3 temper_gold : source_color = vec3(0.9, 0.66, 0.3);
uniform vec3 temper_thread : source_color = vec3(0.78, 0.95, 0.84);
uniform vec2 temper_reach = vec2(0.72, 0.86);
uniform vec2 temper_edge = vec2(0.5, 0.97);
// The blade's half width in the model's space at the guard and near the tip (emeth.glb measured), a vein's width
// (meters of the model, about 1:1 with the game's), how far off the middle a vein runs (share of the half width).
uniform vec2 temper_half = vec2(0.095, 0.06);
uniform float temper_width = 0.018;
uniform float temper_off = 0.42;
// V-08 (AP-2): the Retorno do Corte's window (EmethSword.set_return, 0 to 1 of the window left): a fine emerald
// thread runs up the middle of the blade, return_width m wide, a brighter knot travelling guard to tip return_run times
// a second; under 1.0 (no glow) and under style_cap in the stylized look. 0 draws nothing.
uniform float return_thread = 0.0;
uniform vec3 return_color : source_color = vec3(0.45, 0.95, 0.62);
uniform float return_width = 0.012;
uniform float return_run = 2.2;

varying float along;
varying vec3 local;
varying vec3 lnormal;

void vertex() {
	along = VERTEX.y;
	local = VERTEX;
	lnormal = NORMAL;
}

// The temper's marks at this point of the blade: x the gold veins, y the edge thread (0..1 each).
vec2 temper_marks(float up) {
	float half_w = mix(temper_half.x, temper_half.y, up);
	float veins = 0.0;
	for (int k = 0; k < 2; k++) {
		float grown = clamp(temper - float(k), 0.0, 1.0);
		if (grown <= 0.0) {
			break;
		}
		float side = k == 0 ? -1.0 : 1.0;
		float reach = (k == 0 ? temper_reach.x : temper_reach.y) * grown;
		float x = side * half_w * temper_off + sin(along * 17.0 + side * 1.3) * 0.01;
		float line = 1.0 - smoothstep(temper_width * 0.35, temper_width * 0.5, abs(local.x - x));
		float span = smoothstep(0.02, 0.08, up) * (1.0 - smoothstep(reach - 0.06, reach, up));
		veins = max(veins, line * span);
	}
	float edge_reach = mix(0.0, temper_edge.x, clamp(temper, 0.0, 1.0)) + (temper_edge.y - temper_edge.x) * clamp(temper - 1.0, 0.0, 1.0);
	float edge = smoothstep(0.55, 0.85, abs(normalize(lnormal).x)) * step(half_w * 0.5, abs(local.x));
	edge *= smoothstep(0.03, 0.08, up) * (1.0 - smoothstep(edge_reach - 0.05, edge_reach, up));
	return vec2(veins, edge);
}

void fragment() {
	vec3 c = texture(albedo, UV).rgb;
	float blade = smoothstep(blade_from, blade_from + 0.06, along);
	float value = max(c.r, max(c.g, c.b));
	ALBEDO = c * (1.0 - 0.5 * blade);
	ROUGHNESS = roughness;
	METALLIC = metallic * (1.0 - blade);
	vec3 lit = blade_color * value;
	bool styled = art_style > 0.5;
	if (styled) {
		float face = smoothstep(-style_split, style_split, dot(NORMAL, normalize(style_key)));
		lit = mix(style_back, style_face, face);
		ALBEDO *= 1.0 - (1.0 - style_lit) * blade;
	}
	if (corrupt > 0.0) {
		// how far up the blade this point is (0 at the guard, 1 at the tip), with a ragged front that drifts
		float up = clamp((along - blade_from) / (0.95 - blade_from), 0.0, 1.0);
		float wave = sin(local.x * 61.0 + local.z * 47.0 + TIME * 1.7) * 0.5 + sin(local.x * 23.0 - local.z * 31.0 + along * 19.0) * 0.5;
		float front = corrupt_reach * corrupt + wave * 0.08;
		float veins = 1.0 - smoothstep(front - 0.18, front, up);
		// the crystal's own darker lines turn violet first: the corruption follows the painting's veins
		float k = clamp(veins * (0.55 + 0.45 * (1.0 - value)), 0.0, 1.0) * corrupt;
		lit = mix(lit, corrupt_color * (0.35 + 0.65 * value), k);
		ALBEDO = mix(ALBEDO, corrupt_color * 0.25, k * blade);
	}
	EMISSION = c * fill + mix(lit, c, blade_paint) * (blade_glow + pulse) * blade;
	if (temper > 0.0) {
		vec2 tm = temper_marks(clamp((along - blade_from) / (0.95 - blade_from), 0.0, 1.0)) * blade;
		// under style_cap in the stylized look, keeping the gold's hue (a cap per channel would grey it)
		float k = styled ? style_cap : 1.0;
		vec3 gold = temper_gold * k;
		vec3 thread = temper_thread * k;
		EMISSION = mix(EMISSION, thread, tm.y);
		EMISSION = mix(EMISSION, gold, tm.x);
		ALBEDO = mix(ALBEDO, temper_gold * 0.5, max(tm.x, tm.y * 0.5));
	}
	if (return_thread > 0.0) {
		float up = clamp((along - blade_from) / (0.95 - blade_from), 0.0, 1.0);
		float line = 1.0 - smoothstep(return_width * 0.3, return_width * 0.5, abs(local.x));
		float knot = pow(1.0 - fract(up - TIME * return_run), 6.0);
		float k = line * blade * smoothstep(0.03, 0.1, up) * (1.0 - smoothstep(0.9, 0.97, up)) * return_thread;
		vec3 thread = return_color * (0.55 + 0.45 * knot) * (styled ? style_cap : 1.0);
		EMISSION = mix(EMISSION, thread, k);
	}
	if (styled) {
		// HB3 (2026-11-20): capped by its brightest channel, the hue kept (a cap per channel clipped only the green and
		// greyed the crystal: 0.6% of green round the paladin on the GPU, 1% asked)
		float peak = max(EMISSION.r, max(EMISSION.g, EMISSION.b));
		EMISSION *= min(1.0, style_cap / max(peak, 0.0001));
	}
}
