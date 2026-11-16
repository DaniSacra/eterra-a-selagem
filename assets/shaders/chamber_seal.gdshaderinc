// The Chamber of the Seal's own floor (included by catacomb_floor.gdshaderinc when CHAMBER is defined; uniforms set by
// BossChamber, values over time by SealLook; docs/art/boss_chamber_spec.md 2.2, 2.3 and 6):
// - the seal in the middle, in the stone (fixed): a double ring of inlaid old gold, a band of lozenges and leaves, eight
//   long points of lighter stone outlined in gold with a darker half, leaves between them, and in its heart the standing
//   lion in raised stone (assets/textures/seal/lion_sdf.res, drawn by hand in lion.svg), with a gold edge and dark cuts;
// - the crack of violet light across the lion, growing with Morvath's phases, its burnt edge and the stain round it;
// - a light layer over the rings that may turn (the stone never does): lit points, rings and runes of the ritual, the
//   wave of the ritual, the flash of its breaking, the flicker and tremor of the last phase, the traces of the victory;
// - the veins of the last phase along the floor's joints, and the gold they eat;
// - the edge of the walkable circle (a band of kerb stones a step darker and a thread of old gold) and worn inscriptions.
// Every emission here stays at or under 1.0 in its greatest channel (under the glow's threshold, 1.3).

#include "res://assets/shaders/rune_glyph.gdshaderinc"

// The seal's turn on the floor (the camera's yaw: its x runs right on the screen, its y down) and its outer radius.
uniform float seal_turn = 0.6108652;
uniform float seal_radius = 5.3;
// Rings (outer filets, inner filets; m), filet width, the band's lozenges and leaves, the points (base, tip, half the
// base), the leaves between them (radius, length), the heart (lion) radius.
uniform vec2 seal_outer = vec2(3.5, 3.66);
uniform vec2 seal_inner = vec2(2.82, 2.96);
uniform float seal_filet = 0.06;
uniform vec2 seal_lozenge = vec2(0.22, 0.12);
uniform float seal_band_contrast = 0.5;
uniform vec3 seal_point = vec3(3.66, 5.0, 0.5);
uniform float seal_point_edge = 0.05;
uniform float seal_point_stone = 1.12;
uniform float seal_point_dark = 0.85;
uniform vec2 seal_leaf = vec2(4.0, 0.4);
// The lion: its distance field (red: body, green: cuts; 0.5 on the edge, `seal_lion_spread` pixels to the full swing
// on a `seal_lion_px` texture covering `seal_lion_span` m), the field's point laid on the seal's middle (m, in the
// texture's frame), its body's value, gold edge (m), the shadow it casts down the screen (m) and its darkness.
uniform sampler2D seal_lion : filter_linear_mipmap, repeat_disable;
uniform float seal_lion_span = 4.8;
uniform float seal_lion_px = 512.0;
uniform float seal_lion_spread = 24.0;
uniform vec2 seal_lion_shift = vec2(-0.21, -0.06);
uniform float seal_lion_value = 1.1;
uniform float seal_lion_edge = 0.05;
uniform float seal_lion_shadow = 0.04;
uniform float seal_lion_shade = 0.6;
// The stone of the heart (inside the inner ring): a step lighter, all one stone.
uniform float seal_heart_value = 1.04;
// The crack: segments (a.xy, b.xy, in the seal's frame), per segment when it grows (grow from, to) and its width at
// each end (m); its colour at full light (greatest channel 1.0), the burnt edge (m) and the stain round it (m, how much
// darker the stone, its tint), the heart it closes toward in the victory and the farthest it reaches from it.
uniform vec4 seal_crack[24];
uniform vec4 seal_crack_t[24];
uniform int seal_crack_count = 0;
uniform vec3 seal_crack_color : source_color = vec3(0.52, 0.18, 1.0);
uniform float seal_crack_burn = 0.12;
uniform vec3 seal_stain = vec3(0.6, 0.3, 0.0);
uniform vec3 seal_stain_tint : source_color = vec3(0.85, 0.7, 1.0);
uniform vec2 seal_heart = vec2(-0.1, -0.2);
uniform float seal_heal_reach = 5.2;
// Colours of the light layer (greatest channel 1.0): violet (outer ring), spectral blue (inner ring, runes), old gold
// (the victory), the corrupted emerald of the veins.
uniform vec3 seal_violet : source_color = vec3(0.52, 0.18, 1.0);
uniform vec3 seal_spirit : source_color = vec3(0.32, 0.6, 1.0);
uniform vec3 seal_gold : source_color = vec3(1.0, 0.8, 0.44);
uniform vec3 seal_emerald : source_color = vec3(0.32, 0.7, 0.6);
// The state, as SealLook.values() gives it.
uniform float seal_gold_glow = 0.0;
uniform vec2 seal_ring_light = vec2(0.0);
uniform vec2 seal_ring_mix = vec2(0.0, 1.0);
uniform float seal_runes = 0.0;
uniform float seal_points = 0.0;
uniform float seal_first_point = 0.0;
uniform float seal_point_light = 0.0;
uniform float seal_wave = 0.0;
uniform float seal_inside_dark = 0.0;
uniform float seal_crack_core = 0.75;
uniform float seal_crack_grow = 1.0;
uniform float seal_crack_heal = 0.0;
uniform float seal_scar = 0.0;
uniform float seal_spot = 1.0;
uniform float seal_veins = 0.0;
uniform float seal_vein_light = 0.0;
uniform float seal_tremor = 0.0;
uniform float seal_converge = -1.0;
uniform float seal_lion_glow = 0.0;
uniform float seal_flash = 0.0;
uniform float seal_violet_left = 1.0;
uniform vec2 seal_turns = vec2(0.0);
uniform float seal_clock = 0.0;
uniform float seal_gold_eaten = 0.0;
// The edge of the walkable circle: the floor's radius, the kerb band's inner radius and value, the gold thread's
// radius and width; the mouths of the stairs where the kerb is a sill (x from, x to, z from: rects of floor).
uniform float edge_radius = 12.5;
uniform float edge_band = 12.05;
uniform float edge_value = 0.8;
uniform vec2 edge_thread = vec2(12.45, 0.04);
// Worn inscriptions: share of the slabs (and that share in the ring between the two radii), how dark (share of the
// slab's value), no inscription within this radius.
uniform float glyph_share = 0.08;
uniform vec3 glyph_ring = vec3(7.0, 9.0, 0.3);
uniform float glyph_dark = 0.15;
uniform float glyph_clear = 5.3;

// The point in the seal's frame (x right, y down on the screen).
vec2 seal_frame(vec2 wp) {
	float c = cos(seal_turn);
	float s = sin(seal_turn);
	return vec2(c * wp.x - s * wp.y, s * wp.x + c * wp.y);
}

// How much of the floor's slab joints stay at wp: none in the seal's heart nor under its points (one carved stone).
float chamber_joints(vec2 wp) {
	vec2 q = seal_frame(wp);
	float d = length(q);
	if (d > seal_point.y + 0.1) {
		return 1.0;
	}
	float heart = 1.0 - smoothstep(seal_inner.y - 0.05, seal_inner.y + 0.05, d);
	float k = floor(atan(q.y, q.x) / 0.7853982 + 0.5);
	vec2 ax = vec2(cos(k * 0.7853982), sin(k * 0.7853982));
	float u = dot(q, ax);
	float v = abs(dot(q, vec2(-ax.y, ax.x)));
	float in_point = step(seal_outer.x, u) * step(v, seal_point.z * (seal_point.y - u) / (seal_point.y - seal_point.x));
	float band = step(seal_inner.x, d) * step(d, seal_outer.y);
	return 1.0 - max(max(heart, in_point), band * 0.6);
}

// A filet (a thin inlaid line) at distance x from its middle: 1 on it.
float filet(float x, float w) {
	return 1.0 - smoothstep(w * 0.35, w * 0.5, abs(x));
}

// The lion's field at q (seal's frame): x = signed distance to its outline (m, + inside), y = to its cuts.
vec2 lion_at(vec2 q) {
	vec2 uv = (q - seal_lion_shift) / seal_lion_span + 0.5;
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
		return vec2(-1.0);
	}
	vec2 f = texture(seal_lion, uv).rg;
	float to_m = seal_lion_spread * 2.0 * seal_lion_span / seal_lion_px;
	return (f - 0.5) * to_m;
}

// The crack at q: x = its core (1 in the middle of the drawn line), y = the burnt edge, z = the stain round it,
// w = 1 where it is drawn at all (the scar).
vec4 crack_at(vec2 q) {
	float core = 0.0;
	float burn = 0.0;
	float near_d = 99.0;
	float heal_r = (1.0 - seal_crack_heal) * seal_heal_reach;
	for (int i = 0; i < 24; i++) {
		if (i >= seal_crack_count) {
			break;
		}
		vec4 s = seal_crack[i];
		vec4 g = seal_crack_t[i];
		float shown = clamp((seal_crack_grow - g.x) / max(g.y - g.x, 0.001), 0.0, 1.0);
		if (shown <= 0.0) {
			continue;
		}
		vec2 a = s.xy;
		vec2 b = mix(s.xy, s.zw, shown);
		vec2 ab = b - a;
		float h = clamp(dot(q - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0);
		vec2 p = a + ab * h;
		// it closes from its tips toward the lion's heart
		if (length(p - seal_heart) > heal_r) {
			continue;
		}
		float dist = length(q - p);
		float w = mix(g.z, g.w, h * shown) * 0.5;
		core = max(core, 1.0 - smoothstep(w * 0.4, w, dist));
		burn = max(burn, 1.0 - smoothstep(w, w + seal_crack_burn, dist));
		near_d = min(near_d, dist);
	}
	float stain = 1.0 - smoothstep(0.0, seal_stain.x, near_d + (noise(q * 5.0) - 0.5) * 0.3);
	return vec4(core, burn, stain, step(near_d, 0.06));
}

// The seal at wp, laid on the floor's colour c: its stone and gold (albedo), its light (emit), its relief (lean, the
// floor-space tilt of the normal) and its gold's sheen (rough).
void seal_draw(vec2 wp, inout vec3 c, inout vec3 emit, inout vec2 lean, inout float rough) {
	vec2 q = seal_frame(wp);
	float d = length(q);
	float ang = atan(q.y, q.x);
	vec3 gold = mix(gold_dark, gold_light, 0.55 + 0.45 * noise(wp * 6.0));
	float gold_k = 0.0;
	float glow = 0.0;
	vec3 light = vec3(0.0);
	// the light layer turns (the stone does not) and trembles in the last phase
	float ang_out = ang - seal_turns.x - seal_tremor;
	float ang_in = ang - seal_turns.y - seal_tremor;
	// ---- the heart: one stone, a step lighter, darker under the ritual's shield; the lion raised in it
	float heart = 1.0 - smoothstep(seal_inner.x - 0.03, seal_inner.x, d);
	c *= mix(1.0, seal_heart_value, heart);
	c *= 1.0 - seal_inside_dark * (1.0 - smoothstep(2.85, 2.95, d));
	vec2 lion = lion_at(q);
	if (lion.x > -0.3) {
		float body = smoothstep(-0.01, 0.01, lion.x);
		vec2 up = lion_at(q - vec2(0.0, seal_lion_shadow));
		float shade = smoothstep(-0.01, 0.01, up.x) * (1.0 - body);
		c *= mix(1.0, seal_lion_value, body);
		c *= mix(1.0, seal_lion_shade, shade);
		// the relief's bevel: the outline leans out (normal from the field), lit on one side
		vec2 e = vec2(0.02, 0.0);
		vec2 grad = vec2(lion_at(q + e.xy).x - lion_at(q - e.xy).x, lion_at(q + e.yx).x - lion_at(q - e.yx).x);
		float rim = body * (1.0 - smoothstep(0.0, 0.06, lion.x));
		if (length(grad) > 1e-5) {
			vec2 g = -normalize(grad) * rim * 0.5;
			float cs = cos(seal_turn);
			float sn = sin(seal_turn);
			lean += vec2(cs * g.x + sn * g.y, -sn * g.x + cs * g.y);
		}
		// the gold edge and the dark cuts
		float edge = filet(lion.x, seal_lion_edge);
		gold_k = max(gold_k, edge);
		float cut = smoothstep(-0.008, 0.008, lion.y) * body;
		c *= 1.0 - cut * 0.55;
		light += seal_gold * edge * seal_lion_glow;
	}
	// ---- the rings: two double filets of gold with a dark groove between
	float outer = max(filet(d - seal_outer.x, seal_filet), filet(d - seal_outer.y, seal_filet));
	float inner = max(filet(d - seal_inner.x, seal_filet), filet(d - seal_inner.y, seal_filet));
	float groove = step(seal_outer.x + seal_filet * 0.5, d) * step(d, seal_outer.y - seal_filet * 0.5)
		+ step(seal_inner.x + seal_filet * 0.5, d) * step(d, seal_inner.y - seal_filet * 0.5);
	c *= 1.0 - groove * 0.45;
	gold_k = max(gold_k, max(outer, inner));
	// the band: lozenges and leaves turn and turn about, half the gold's contrast
	float band_mid = (seal_inner.y + seal_outer.x) * 0.5;
	float n32 = 6.2831853 / 32.0;
	float k32 = floor(ang / n32 + 0.5);
	vec2 ax32 = vec2(cos(k32 * n32), sin(k32 * n32));
	vec2 l32 = vec2(dot(q, ax32) - band_mid, dot(q, vec2(-ax32.y, ax32.x)));
	float orn = 0.0;
	if (mod(k32, 2.0) < 0.5) {
		orn = 1.0 - smoothstep(0.9, 1.0, abs(l32.y) / (seal_lozenge.x * 0.5) + abs(l32.x) / (seal_lozenge.y * 0.5));
	} else {
		// a leaf: two arcs meeting in points along the band
		float lw = seal_lozenge.x * 0.45;
		orn = 1.0 - smoothstep(0.9, 1.05, length(vec2(l32.y / lw, l32.x / (seal_lozenge.y * 0.5))) + abs(l32.y / lw) * 0.4);
	}
	gold_k = max(gold_k, orn * seal_band_contrast);
	// ---- the eight points: lighter stone, a darker half, a gold edge
	float k8 = floor(ang / 0.7853982 + 0.5);
	vec2 ax = vec2(cos(k8 * 0.7853982), sin(k8 * 0.7853982));
	float u = dot(q, ax);
	float v = dot(q, vec2(-ax.y, ax.x));
	float slope = seal_point.z / (seal_point.y - seal_point.x);
	float pedge = (seal_point.z * (seal_point.y - u) / (seal_point.y - seal_point.x) - abs(v)) / sqrt(1.0 + slope * slope);
	float past = step(seal_outer.y, u);
	float in_point = step(0.0, pedge) * past;
	c *= mix(1.0, seal_point_stone * (v < 0.0 ? seal_point_dark : 1.0), in_point);
	float p_edge = filet(pedge - seal_point_edge * 0.5, seal_point_edge) * past * step(u, seal_point.y);
	gold_k = max(gold_k, p_edge);
	// which points are lit (from the one pointing at Morvath, clockwise on the screen)
	float idx = mod(k8 + 2.0, 8.0);
	float rel = mod(idx - seal_first_point + 8.0, 8.0);
	float lit = clamp(seal_points - rel, 0.0, 1.0);
	// the ritual's wave from the heart to the tips
	float wave = 1.0 + seal_wave * sin(6.2831853 * (0.7 * seal_clock) - d * 1.4);
	// ---- the leaves between the points
	float a_gap = (floor(ang / 0.7853982) + 0.5) * 0.7853982;
	vec2 gax = vec2(cos(a_gap), sin(a_gap));
	vec2 gl = vec2(dot(q, gax) - seal_leaf.x, dot(q, vec2(-gax.y, gax.x)));
	float leaf = 1.0 - smoothstep(0.9, 1.05, length(vec2(gl.x / (seal_leaf.y * 0.5), gl.y / (seal_leaf.y * 0.2))));
	gold_k = max(gold_k, leaf);
	// ---- the crack, its burn and stain, or its scar once healed
	vec4 cr = crack_at(q);
	float violet = seal_violet_left;
	c *= 1.0 - cr.z * seal_stain.y * seal_spot * violet;
	c = mix(c, c * seal_stain_tint, cr.z * seal_spot * violet);
	c *= 1.0 - cr.y * 0.75 * violet;
	c = mix(c, c * 0.7, max(cr.w, cr.x) * seal_scar);
	light += seal_crack_color * cr.x * seal_crack_core * violet;
	c = mix(c, c * 0.4, cr.x * violet);
	// ---- runes of the ritual in the band, turning with the outer ring
	if (seal_runes > 0.0 && d > seal_inner.y && d < seal_outer.x) {
		float cells = 16.0;
		float a01 = fract(ang_out / 6.2831853) * cells;
		vec2 cell = vec2(fract(a01) * (band_mid * 6.2831853 / cells), d - seal_inner.y);
		float g = rune_glyph(cell, vec2(band_mid * 6.2831853 / cells, seal_outer.x - seal_inner.y), floor(a01));
		light += seal_spirit * (1.0 - smoothstep(0.015, 0.03, g)) * seal_runes * wave;
	}
	// ---- the lit rings: a light traced over the gold filets, broken into dashes that turn
	float dash_out = 0.6 + 0.4 * smoothstep(-0.2, 0.6, sin(ang_out * 24.0));
	float dash_in = 0.6 + 0.4 * smoothstep(-0.2, 0.6, sin(ang_in * 16.0));
	vec3 col_out = seal_ring_mix.x < 0.0 ? seal_gold : mix(seal_violet, seal_spirit, seal_ring_mix.x);
	vec3 col_in = seal_ring_mix.y < 0.0 ? seal_gold : mix(seal_violet, seal_spirit, seal_ring_mix.y);
	light += col_out * outer * dash_out * seal_ring_light.x * wave;
	light += col_in * inner * dash_in * seal_ring_light.y * wave;
	light += mix(seal_violet, seal_spirit, 0.5) * p_edge * lit * seal_point_light * wave;
	// the breaking of the ritual: violet and gold, never white
	light += mix(seal_violet, seal_gold, 0.4) * (gold_k * 0.8) * seal_flash;
	// ---- the victory: eight traces of old gold run down the points to the heart
	if (seal_converge >= 0.0) {
		float head = seal_point.y * (1.0 - seal_converge);
		float on_axis = 1.0 - smoothstep(0.03, 0.07, abs(v));
		float trail = smoothstep(head - 0.05, head + 0.02, u) * (1.0 - smoothstep(head + 0.6, head + 1.6, u)) * step(u, seal_point.y);
		light += seal_gold * on_axis * trail * step(0.0, u);
		light += seal_gold * (1.0 - smoothstep(0.0, 0.5, d)) * smoothstep(0.85, 1.0, seal_converge);
	}
	// the gold: inlaid metal (its own sheen), eaten where the veins of the last phase pass, a faint light of its own
	// at rest after the victory
	vec3 metal = gold * (1.0 - 0.4 * seal_gold_eaten * step(0.001, seal_veins) * (1.0 - smoothstep(0.0, 1.5, d - seal_veins * 0.5)));
	c = mix(c, metal, gold_k);
	rough = mix(rough, 0.45, gold_k);
	light += seal_gold * gold_k * seal_gold_glow;
	// keep every channel at or under 1.0
	float top = max(light.r, max(light.g, light.b));
	emit += light / max(top, 1.0);
}

// The veins of the last phase: the floor's joints near the crack light up out to seal_veins meters.
void veins_draw(vec2 wp, float joint, inout vec3 c, inout vec3 emit) {
	if (seal_veins <= 0.0) {
		return;
	}
	float d = length(wp);
	float net = smoothstep(0.48, 0.62, fbm(wp * 0.6 + 7.0));
	float reach = 1.0 - smoothstep(seal_veins - 0.6, seal_veins + 0.2, d + (noise(wp * 1.3) - 0.5) * 1.2);
	float vein = joint * net * reach;
	if (vein <= 0.0) {
		return;
	}
	// a corrupted emerald core with a violet edge (the edge where the joint is thin)
	vec3 col = mix(seal_violet, seal_emerald, smoothstep(0.75, 1.0, joint));
	c = mix(c, c * 0.5, vein);
	vec3 l = col * vein * seal_vein_light;
	float top = max(l.r, max(l.g, l.b));
	emit += l / max(top, 1.0);
}

// The edge of the walkable circle and the worn inscriptions on the slabs.
void edge_draw(vec2 wp, vec2 id, vec4 rect, inout vec3 c, inout vec3 emit, inout float rough) {
	float d = length(wp);
	float band = step(edge_band, d) * step(d, edge_radius);
	c *= mix(1.0, edge_value, band);
	float thread = filet(d - edge_thread.x, edge_thread.y);
	c = mix(c, mix(gold_dark, gold_light, noise(wp * 5.0)), thread * 0.85);
	rough = mix(rough, 0.5, thread);
	// a few slabs carry a line of worn glyphs, cut dark (no glow, no colour)
	float share = glyph_share + (step(glyph_ring.x, d) * step(d, glyph_ring.y)) * glyph_ring.z;
	if (d > glyph_clear && d < edge_band && hash1(id + 61.0) < share) {
		vec2 lo = rect.xy * unit;
		vec2 size = rect.zw * unit;
		vec2 lp = wp - lo - size * vec2(0.15, 0.4);
		float h = size.y * 0.2;
		vec2 cs = vec2(h * 0.7, h);
		float cell_i = floor(lp.x / cs.x);
		if (lp.y > 0.0 && lp.y < cs.y && lp.x > 0.0 && lp.x < size.x * 0.7) {
			float g = rune_glyph(vec2(mod(lp.x, cs.x), lp.y), cs, cell_i + hash1(id) * 40.0);
			float worn = smoothstep(0.3, 0.55, noise(wp * 4.0 + id));
			c *= 1.0 - glyph_dark * (1.0 - smoothstep(0.012, 0.024, g)) * worn;
		}
	}
}

// Everything the Chamber adds to the floor at wp (the floor's slab id and rect in units, its joint).
void chamber_floor(vec2 wp, vec2 id, vec4 rect, float joint, inout vec3 c, inout vec3 emit, inout vec2 lean, inout float rough) {
	edge_draw(wp, id, rect, c, emit, rough);
	veins_draw(wp, joint, c, emit);
	if (length(wp) < seal_radius) {
		seal_draw(wp, c, emit, lean, rough);
	}
}
