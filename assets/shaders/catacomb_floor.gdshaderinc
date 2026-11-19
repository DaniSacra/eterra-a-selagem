// The body of the catacomb floor (catacomb_floor.gdshader; with CHAMBER defined, the Chamber of the Seal's floor,
// chamber_floor.gdshader, which adds the seal, the edge of the walkable circle, the worn inscriptions and the veins
// of the last phase from chamber_seal.gdshaderinc).
// The floor of the catacomb platforms: big flagstones of blue-grey slate laid in a hopscotch pattern (big slabs with
// small ones at their corners, some big ones split in two or three, so no joint runs straight across the hall), each
// slab its own value, tint and slight tilt, a bevel along its edge that catches the light on one side (an analytic
// normal, no screen derivatives), rounded and nicked edges, a corner missing here and there, cracks, a few red
// petals. Wet only in front of the portal and round the fire bowls. The middle stays calm so the fighters read on it;
// the medallion is carved in the slabs (a ring of sixteen stones with worn runes, bevelled rims, a broken thread of
// dark bronze, cracks, eight points). World space, so a platform of any size takes it.

uniform vec3 stone_a : source_color = vec3(0.32, 0.25, 0.29);
uniform vec3 stone_b : source_color = vec3(0.46, 0.37, 0.41);
uniform vec3 joint_color : source_color = vec3(0.11, 0.11, 0.14);
uniform vec3 crack_color : source_color = vec3(0.05, 0.055, 0.07);
uniform vec3 moss_color : source_color = vec3(0.12, 0.2, 0.2);
uniform vec3 petal_color : source_color = vec3(0.45, 0.06, 0.06);
// The small slab's side (m; the big ones are twice that), the joint, the bevel along each edge and how much it tilts.
uniform float unit = 1.2;
uniform float joint_width = 0.045;
uniform float bevel = 0.12;
uniform float bevel_tilt = 0.8;
// Each slab tilts a little (up to this many degrees), has rounded corners (m) and an edge wobbling by this much (m).
uniform float slab_tilt = 3.0;
uniform float corner_round = 0.12;
uniform float wobble = 0.06;
// Value per slab (min, max), share of slabs tinted cold or warm, of big slabs split in two and in three, of slabs
// with a corner missing (and that corner's size range, m), of cracked slabs.
uniform vec2 slab_value = vec2(0.72, 1.25);
uniform float tinted = 0.3;
uniform float split2 = 0.3;
uniform float split3 = 0.1;
uniform float missing = 0.15;
uniform vec2 missing_size = vec2(0.2, 0.45);
uniform float cracked = 0.25;
// The calm middle: radius in meters, and how much of the stones' contrast it keeps.
uniform float calm_radius = 9.0;
uniform float calm_contrast = 0.55;
// The medallion in the middle (0 = none): its radius in meters (the long points' tips); the slab joints under its
// band and under its points (they fade there: the medallion is carved stone, not paint over the slabs).
uniform float ring_radius = 6.5;
uniform vec2 ring_center = vec2(0.0);
uniform float ring_glow = 0.0;
uniform float rose_turn = 0.0;
uniform float ring_joints = 0.05;
uniform float point_joints = 0.4;
// Its metal: a thread of dark bronze inlaid in the grooves (its width, the share of its length left, how much it
// covers the stone under it).
uniform vec3 gold_dark : source_color = vec3(0.306, 0.247, 0.149);
uniform vec3 gold_light : source_color = vec3(0.478, 0.384, 0.22);
uniform float metal_width = 0.05;
uniform float metal_left = 0.55;
uniform float metal_cover = 0.7;
// The band: curved stones (how many, their joint's width), their value and worn grain, the bevel along both rims
// (width; value on the side turned to the key light and on the side away), the groove round it (width, darkness), the
// runes cut in it (how many, stroke width, half their height as a share of the band, darkness, share worn away), and how far
// (m, min to max) its four cracks run on into the slabs.
uniform float band_stones = 16.0;
uniform float band_joint = 0.04;
uniform float band_value = 0.8;
uniform float band_grain = 0.3;
// Cycle 7 (relief by value, so the ring parts from the slabs at the game's camera): wider bevels and grooves, the
// grooves near black (groove_cover: how much of the stone they hide), runes of twice the stroke.
uniform float band_bevel = 0.2;
uniform vec2 bevel_value = vec2(1.32, 0.42);
uniform float band_groove = 0.2;
uniform float groove_dark = 0.3;
uniform float groove_cover = 0.94;
uniform float runes = 24.0;
uniform float rune_stroke = 0.24;
uniform float rune_size = 0.32;
uniform float rune_dark = 1.0;
uniform float rune_worn = 0.14;
// Cycle 6, so the runes read as cuts from the game's camera: how wide a rune is (share of its height), the lit lip on
// the far wall of each cut (width in m, how much lighter than the band), and the worn bronze thread in the bottom of
// one rune in three (share of them, how much of it is left).
uniform float rune_wide = 0.75;
uniform float rune_lip = 0.06;
uniform float rune_light = 1.28;
uniform float rune_bronze = 0.34;
uniform float rune_bronze_left = 0.4;
uniform vec2 crack_run = vec2(0.6, 1.2);
// The points: value of their light and dark halves, the groove along their edges.
uniform vec2 point_value = vec2(1.1, 0.7);
uniform float point_groove = 0.1;
// The four long points have a lit ridge down their middle (its width in m, how much lighter than the light half).
uniform vec2 point_ridge = vec2(0.07, 1.2);
// The rosette in the middle: its cut (width in m, darkness) and the lit lip on the far wall of the cut (how much
// lighter than the slabs: less than the runes', the slabs inside the ring are already the lightest of the floor).
uniform vec3 rosette_cut = vec3(0.09, 0.95, 1.1);
// Where the key light comes from, in the medallion's space (rose_turn = the camera's yaw: x is screen right, y screen
// down), for the relief painted on the bevels.
uniform vec2 relief_light = vec2(-0.7071, -0.7071);
// A rectangle of floor (x min, z min, x max, z max) that is always wet, and wet rings round the fire bowls (x, z,
// radius where it starts drying, radius where it is dry).
uniform vec4 wet_zone = vec4(0.0);
uniform vec4 wet_spots[8];
uniform int wet_spot_count = 0;
uniform float wet_roughness = 0.25;
// Relief of real stone (CC0 rock surface, assets/textures/rock_surface): its normal and height, how many times it
// repeats per meter, how much it tilts the normal, how much its hollows darken the painted colour.
uniform sampler2D rock_normal : filter_linear_mipmap, repeat_enable;
uniform sampler2D rock_height : filter_linear_mipmap, repeat_enable;
uniform float rock_scale = 0.4;
uniform float rock_relief = 0.5;
uniform float rock_value = 0.45;
uniform vec2 dry_roughness = vec2(0.75, 0.9);
// C18 (ART P1-2): pale clearings, where the stone is worn smooth and dusty, so the eye rests on a lighter floor (the
// Ember & Blade's floors): how much of their colour they take at their heart (0 none), their colour (a pale warm
// grey, never saturated), how big (noise scale, per meter: lower is bigger) and where the noise starts and is full.
uniform float clearing = 0.4;
uniform vec3 clearing_color : source_color = vec3(0.6, 0.58, 0.57);
uniform float clearing_scale = 0.11;
uniform vec2 clearing_cut = vec2(0.46, 0.7);

#ifdef PAINT
#include "res://assets/shaders/paint.gdshaderinc"
// The stylized look (stylized_spec 1.3 and 4.3): the painted stone at the classic floor's mean value (floor_ref, its
// luma), each slab's value range and hue swing (degrees), one slab in olive_share toward the olive; the rock relief
// and its value as shares of the classic ones; joints, cracks and the medallion's lines at this share of the slab's
// value, a little cold; the bevel's darkening by the joint; the floor's value toward the room's edge (from the calm
// radius times edge_from to times edge_to); the pale clearings as a share of the classic ones; how much of the big
// washes is left.
uniform vec3 floor_stone : source_color = vec3(0.325, 0.315, 0.29);
uniform float floor_ref = 0.33;
uniform vec2 slab_paint = vec2(0.85, 1.12);
uniform float slab_hue = 5.0;
uniform float olive_share = 0.125;
uniform float paint_rock = 0.3;
uniform float joint_value = 0.4;
uniform vec3 joint_cold : source_color = vec3(0.93, 0.96, 1.05);
uniform float paint_bevel = 0.75;
uniform float edge_value = 0.72;
uniform vec2 edge_span = vec2(0.9, 1.7);
uniform float paint_clearing = 0.4;
uniform float paint_washes = 0.5;
// STY-10 (art review, request 3: the runes read as smudges, the ring as a soft double edge): the medallion's band as
// one stone a little lighter than the slabs, cut by a single groove on each rim; its runes longer and thinner, cut
// crisp in the joint's value (stroke in m: 0.12 is 5.6 px at 1080 from the game's camera across the view and 3 px
// along it, where the floor is foreshortened most), with no lit lip; the
// bevels' painted relief down to a share of the classic one (their dark half beside the groove drew the second edge).
uniform float paint_band = 1.08;
uniform float paint_rune_stroke = 0.12;
uniform float paint_rune_size = 0.4;
uniform float paint_rune_edge = 0.25;
uniform float paint_band_bevel = 0.25;
uniform float paint_band_groove = 0.11;
// STY-10 (fire pools, art review criterion 3): round the fire bowls (the wet spots, within their outer radius) the
// floor keeps the middle's value, not the room edge's darker one (the east bowl's pool fell on slabs at 0.58 of the
// middle's and stayed under 100 where the others reached 110 to 150); the wet floor no darker (it reads by
// its shine; 1 keeps its value).
uniform float paint_wet_dark = 1.0;
// The quatrefoil in the middle cut as wide as the runes, crisp, with no lit lip (m).
uniform float paint_rosette = 0.12;
#define RUNE_STROKE paint_rune_stroke
#define RUNE_SIZE paint_rune_size
#define RUNE_EDGE paint_rune_edge
#define BAND_GROOVE paint_band_groove
#define ROSETTE_W paint_rosette
#else
#define RUNE_STROKE rune_stroke
#define RUNE_SIZE rune_size
#define RUNE_EDGE 0.4
#define BAND_GROOVE band_groove
#define ROSETTE_W rosette_cut.x
#endif

varying vec3 world;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	float s = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		s += noise(p) * a;
		p *= 2.03;
		a *= 0.5;
	}
	return s;
}

// The slab under p (in units): hopscotch of 2x2 and 1x1 squares (lattice (2, 1), (-1, 2)), then some big ones split.
// Returns the slab's min corner and size (units) in rect, its id.
void slab(vec2 p, out vec4 rect, out vec2 id) {
	vec2 st = vec2(2.0 * p.x + p.y, -p.x + 2.0 * p.y) / 5.0;
	vec2 base = floor(st);
	rect = vec4(0.0, 0.0, 1.0, 1.0);
	id = vec2(0.0);
	for (int dj = -1; dj <= 1; dj++) {
		for (int di = -1; di <= 1; di++) {
			vec2 ij = base + vec2(float(di), float(dj));
			vec2 o = ij.x * vec2(2.0, 1.0) + ij.y * vec2(-1.0, 2.0);
			vec2 q = p - o;
			if (q.x >= 0.0 && q.y >= 0.0 && q.x < 2.0 && q.y < 2.0) {
				rect = vec4(o, 2.0, 2.0);
				id = ij * 2.0;
			}
			vec2 r = p - o - vec2(2.0, 0.0);
			if (r.x >= 0.0 && r.y >= 0.0 && r.x < 1.0 && r.y < 1.0) {
				rect = vec4(o + vec2(2.0, 0.0), 1.0, 1.0);
				id = ij * 2.0 + vec2(1.0, 0.0);
			}
		}
	}
	if (rect.z > 1.5) {
		float h = hash1(id + 0.31);
		float pieces = h < split3 ? 3.0 : (h < split3 + split2 ? 2.0 : 1.0);
		if (pieces > 1.0) {
			bool across = hash1(id + 7.7) > 0.5;
			float along = across ? p.x - rect.x : p.y - rect.y;
			// cut points a little off the even split
			float c1 = 2.0 / pieces + (hash1(id + 3.3) - 0.5) * 0.3;
			float c2 = 4.0 / pieces + (hash1(id + 5.1) - 0.5) * 0.3;
			float lo = 0.0;
			float hi = c1;
			float k = 0.0;
			if (along >= c1) { lo = c1; hi = pieces > 2.5 ? c2 : 2.0; k = 1.0; }
			if (pieces > 2.5 && along >= c2) { lo = c2; hi = 2.0; k = 2.0; }
			if (across) { rect.x += lo; rect.z = hi - lo; } else { rect.y += lo; rect.w = hi - lo; }
			id += vec2(0.17, 0.23) * (k + 1.0);
		}
	}
}

float line_at(float d, float half_width) {
	return 1.0 - smoothstep(half_width * 0.6, half_width, abs(d));
}

// A line with a sharper edge: solid to `hard` of its half width.
float line_hard(float d, float half_width, float hard) {
	return 1.0 - smoothstep(half_width * hard, half_width, abs(d));
}

// Distance from p to the segment a-b.
float seg(vec2 p, vec2 a, vec2 b) {
	vec2 ab = b - a;
	return length(p - a - ab * clamp(dot(p - a, ab) / dot(ab, ab), 0.0, 1.0));
}

// The rune cut in the band at q (the medallion's turned space; the band runs from inner to outer): 1 in its strokes.
// A stroke along the radius and one to three of a slanted branch, a shorter one under it, a loose tick beside it:
// abstract cuts like twigs, with no crossing strokes, no right angle and no ring (so no cross, letter, number or
// sign comes out of them). Wear rubs away pieces of the strokes, not whole runes. core: the middle of the strokes;
// cell: which rune.
float rune_at(vec2 q, float inner, float outer, out float core, out float cell) {
	float turn = 6.2831853 / runes;
	float k = floor(atan(q.y, q.x) / turn);
	float a = (k + 0.5) * turn;
	vec2 ax = vec2(cos(a), sin(a));
	vec2 l = vec2(dot(q, ax) - (outer + inner) * 0.5, dot(q, vec2(-ax.y, ax.x)));
	float h = (outer - inner) * RUNE_SIZE;
	float w = h * rune_wide;
	float hs = hash1(vec2(k, 3.0));
	float pick = hash1(vec2(k, 5.0));
	float u0 = (hash1(vec2(k, 9.0)) - 0.5) * h;
	float side = hs > 0.5 ? 1.0 : -1.0;
	float dist = seg(l, vec2(-h, 0.0), vec2(h, 0.0));
	if (pick < 0.4 || hs > 0.6) {
		dist = min(dist, seg(l, vec2(u0, 0.0), vec2(u0 + h * 0.55, w * side)));
	}
	if (pick >= 0.4 || hs < 0.25) {
		dist = min(dist, seg(l, vec2(-h * 0.15, -w * side), vec2(h * 0.7, -w * side * 0.8)));
	}
	if (pick > 0.7) {
		dist = min(dist, seg(l, vec2(u0 - h * 0.5, 0.0), vec2(u0 - h * 0.15, w * side * 0.6)));
	}
	float worn = smoothstep(rune_worn - 0.08, rune_worn + 0.08, noise(q * 6.0 + k));
	core = line_at(dist, RUNE_STROKE * 0.2) * worn;
	cell = k;
	return line_hard(dist, RUNE_STROKE * 0.5, 1.0 - RUNE_EDGE) * worn;
}

// The medallion carved in the floor (a compass rose of eight points on a ring of sixteen stones). Returns x = how much
// darker or lighter the stone is painted (a multiplier), y = the bronze thread, z = how raised it is (band 1, points 2:
// the slab joints fade under it), w = the dark of its grooves, runes and cracks. Its outward normal tilt (floor space)
// through tilt.
vec4 medallion(vec2 p, float r, out vec2 tilt) {
	float c = cos(rose_turn);
	float sn = sin(rose_turn);
	vec2 q = vec2(c * p.x - sn * p.y, sn * p.x + c * p.y);
	float d = length(q);
	float ang = atan(q.y, q.x);
	float outer = r * 0.627;
	float inner = r * 0.507;
	tilt = vec2(0.0);
	vec2 radial = d > 0.001 ? q / d : vec2(0.0);
	vec2 lit = normalize(relief_light);
	float shade = 1.0;
	float groove = 0.0;
	float metal = 0.0;
	float raised = 0.0;
	// two chips knocked out of the band's outer rim
	float chip = 0.0;
	for (int i = 0; i < 2; i++) {
		float ca = 0.9 + float(i) * 3.4;
		vec2 cp = vec2(cos(ca), sin(ca)) * (outer - 0.05);
		chip = max(chip, 1.0 - smoothstep(0.16, 0.2, length(q - cp) + (noise(q * 9.0) - 0.5) * 0.1));
	}
	// the band of sixteen stones between the rings
	float band = smoothstep(inner - 0.02, inner + 0.02, d) * (1.0 - smoothstep(outer - 0.02, outer + 0.02, d));
	band *= 1.0 - chip;
	if (band > 0.0) {
		float step16 = 6.2831853 / band_stones;
		float k16 = floor(ang / step16);
		float joint = line_at((fract(ang / step16 + 0.5) - 0.5) * step16 * d, band_joint * 0.5);
		float stone_v = mix(0.9, 1.08, hash1(vec2(k16, 7.0)));
		// worn grain and small pits in the band's stone
		stone_v *= 1.0 - band_grain * 0.5 + band_grain * noise(q * 11.0 + k16 * 3.0);
		stone_v *= 1.0 - band_grain * smoothstep(0.72, 0.85, noise(q * 26.0 + k16));
		// the bevels: each rim leans out of the band, lit on the side facing the key light
		float out_b = smoothstep(outer - band_bevel - 0.01, outer - band_bevel + 0.01, d);
		float in_b = 1.0 - smoothstep(inner + band_bevel - 0.01, inner + band_bevel + 0.01, d);
		float face = out_b * dot(radial, lit) - in_b * dot(radial, lit);
		float bev = mix(bevel_value.y, bevel_value.x, smoothstep(-0.55, 0.55, face));
#ifdef PAINT
		bev = mix(1.0, bev, paint_band_bevel);
		float v = mix(band_value * paint_band, bev * paint_band, max(out_b, in_b));
#else
		float v = mix(band_value, bev, max(out_b, in_b));
#endif
		// the runes, the lit lip on the far wall of each cut (so it reads as carved) and the bronze left in some
		float rune_core;
		float rune_cell;
		float rune = rune_at(q, inner, outer, rune_core, rune_cell);
		float lip_core;
		float lip_cell;
		float lip = clamp(rune_at(q + lit * rune_lip, inner, outer, lip_core, lip_cell) - rune, 0.0, 1.0);
#ifndef PAINT
		v *= mix(1.0, rune_light, lip);
#endif
		metal = max(metal, rune_core * step(hash1(vec2(rune_cell, 17.0)), rune_bronze) * rune_bronze_left);
		groove = max(groove, max(joint, rune * rune_dark));
		shade = mix(shade, v * stone_v, band);
		raised = band;
	}
	// the groove round the band, with the bronze thread inlaid in it, worn away in places
	float g_out = step(outer, d) * step(d, outer + BAND_GROOVE);
	float g_in = step(inner - BAND_GROOVE, d) * step(d, inner);
	float in_groove = max(g_out, g_in) * (1.0 - chip);
	float wear = step(1.0 - metal_left, noise(vec2(ang * d * 1.6, d)));
	metal = max(metal, line_at(d - outer - BAND_GROOVE * 0.5, metal_width * 0.5) * wear);
	metal = max(metal, line_at(d - inner + BAND_GROOVE * 0.5, metal_width * 0.5) * wear);
	// the eight points: each a long diamond's outer half, born on the outer ring: a light half and a dark half, a
	// groove round them, some with their tip broken off
	float step8 = 0.7853982;
	float k = floor(ang / step8 + 0.5);
	float a8 = k * step8;
	vec2 axis = vec2(cos(a8), sin(a8));
	float u = dot(q, axis);
	float v = dot(q, vec2(-axis.y, axis.x));
	bool long_point = mod(k, 2.0) < 0.5;
	float tip = long_point ? r : r * 0.747;
	float half_base = long_point ? 0.7 : 0.5;
	float slope = half_base / (tip - outer);
	float edge = (half_base * (tip - u) / (tip - outer) - abs(v)) / sqrt(1.0 + slope * slope);
	float broken = hash1(vec2(k, 11.0)) < 0.5 ? tip - mix(0.2, 0.4, hash1(vec2(k, 13.0))) + (noise(q * 8.0) - 0.5) * 0.12 : tip + 1.0;
	edge = min(edge, broken - u);
	float past = step(outer + BAND_GROOVE, u);
	float inside = step(0.0, edge) * past;
	float pg = past * line_at(edge, point_groove * 0.5 + 0.02) * step(-point_groove, edge);
	groove = max(groove, pg);
	metal = max(metal, past * line_at(edge + point_groove * 0.5, metal_width * 0.4) * wear * step(u, broken - 0.05));
	float half_v = v < 0.0 ? point_value.y : point_value.x;
	if (long_point) {
		// the ridge thins out toward the tip
		half_v = mix(half_v, point_value.x * point_ridge.y, line_at(v, point_ridge.x * 0.5) * smoothstep(0.0, 0.25, edge));
	}
	shade = mix(shade, half_v, inside);
	raised = max(raised, inside * 2.0);
	vec2 perp = vec2(-axis.y, axis.x);
	tilt += inside * perp * sign(v) * 0.35 * smoothstep(0.0, 0.08, edge);
	// a shallow diamond sunk in each gap between the points, outside the ring
	float a_gap = (floor(ang / step8) + 0.5) * step8;
	vec2 g = q - vec2(cos(a_gap), sin(a_gap)) * (outer + 0.75);
	vec2 gl = vec2(dot(g, vec2(cos(a_gap), sin(a_gap))), dot(g, vec2(-sin(a_gap), cos(a_gap))));
	float dia = abs(gl.x) / 0.36 + abs(gl.y) / 0.15;
	shade *= mix(1.0, gl.y * dot(vec2(-sin(a_gap), cos(a_gap)), lit) > 0.0 ? 0.92 : 0.7, 1.0 - smoothstep(0.92, 1.0, dia));
	// four cracks across the band, running on into the slabs
	float crack = 0.0;
	for (int i = 0; i < 4; i++) {
		float fi = float(i);
		float ca = 0.5 + fi * 1.63 + hash1(vec2(fi, 17.0)) * 0.4;
		float run = mix(crack_run.x, crack_run.y, hash1(vec2(fi, 19.0)));
		float from = mod(fi, 2.0) < 0.5 ? inner - 0.05 : inner - run;
		float to = mod(fi, 2.0) < 0.5 ? outer + run : outer + 0.05;
		vec2 cd = vec2(cos(ca), sin(ca));
		float off = dot(q, vec2(-cd.y, cd.x)) + (noise(vec2(d * 3.0, fi * 7.0)) - 0.5) * 0.18;
		float along = step(from, d) * step(d, to) * step(0.0, dot(q, cd));
		crack = max(crack, (1.0 - smoothstep(0.0, mix(0.02, 0.008, smoothstep(outer, to, d)), abs(off))) * along);
	}
	groove = max(groove, in_groove);
	// the soft rosette of eight petals in the middle
	float petal = d - 1.2 * (0.55 + 0.45 * abs(cos(ang * 4.0)));
	float cut = line_hard(petal, ROSETTE_W * 0.5, 1.0 - RUNE_EDGE) * step(d, 1.3);
	vec2 ql = q + lit * rune_lip;
	float petal_l = length(ql) - 1.2 * (0.55 + 0.45 * abs(cos(atan(ql.y, ql.x) * 4.0)));
#ifndef PAINT
	shade *= mix(1.0, rosette_cut.z, clamp(line_at(petal_l, rosette_cut.x * 0.5) - cut, 0.0, 1.0) * step(d, 1.3));
#endif
	groove = max(groove, cut * rosette_cut.y);
	groove = max(groove, crack * 1.2);
	// back to floor space
	tilt = vec2(c * tilt.x + sn * tilt.y, -sn * tilt.x + c * tilt.y);
	return vec4(shade, metal * (1.0 - chip), raised, clamp(groove, 0.0, 1.2));
}

#ifdef CHAMBER
#include "res://assets/shaders/chamber_seal.gdshaderinc"
#endif
#ifdef RUNES
#include "res://assets/shaders/rune_tiles.gdshaderinc"
#endif

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 wp = world.xz;
	vec4 rect;
	vec2 id;
#ifdef RUNES
	rune_slab(wp, rect, id);
#else
	slab(wp / unit, rect, id);
#endif
	// the slab in meters: its middle, half size, where we are in it (each slab's edge wobbles its own way)
	vec2 half_size = rect.zw * unit * 0.5;
	vec2 mid = (rect.xy + rect.zw * 0.5) * unit;
	vec2 lp = wp - mid + (vec2(noise(wp * 1.7 + id * 3.1), noise(wp * 1.7 + id * 5.3 + 9.0)) - 0.5) * 2.0 * wobble;
	// rounded rectangle: distance inside from its edge, and the way out of the nearest edge
	vec2 q = abs(lp) - (half_size - corner_round);
	float outside = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - corner_round;
	float edge = -outside;
	vec2 out_dir = q.x > 0.0 && q.y > 0.0 ? normalize(q) : (q.x > q.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
	out_dir *= sign(lp + 1e-5);
	// nicks along the edges
	float nick = max(0.0, noise(wp * 7.0 + id * 2.0) - 0.62) * 0.35;
	edge -= nick;
	float rnd = hash1(id);
#ifdef PAINT
	vec3 sa = floor_stone * (paint_luma(stone_a) / floor_ref);
	vec3 sb = floor_stone * (paint_luma(stone_b) / floor_ref);
	vec3 c = mix(sa, sb, rnd);
	c *= mix(slab_paint.x, slab_paint.y, hash1(id + 9.0));
	c = paint_hue(c, (hash1(id + 13.0) - 0.5) * 2.0 * slab_hue);
	if (hash1(id + 15.0) < olive_share) {
		c = paint_olive(c);
	}
	float rock_value_ = rock_value * paint_rock;
	float rock_relief_ = rock_relief * paint_rock;
#else
	vec3 sa = stone_a;
	vec3 sb = stone_b;
	vec3 c = mix(sa, sb, rnd);
	c *= mix(slab_value.x, slab_value.y, hash1(id + 9.0));
	float tint = hash1(id + 13.0);
	if (tint < tinted * 0.5) { c *= vec3(0.92, 1.0, 1.08); } else if (tint < tinted) { c *= vec3(1.08, 1.0, 0.92); }
	float rock_value_ = rock_value;
	float rock_relief_ = rock_relief;
#endif
	// the real stone's relief, shifted on each slab so no two match
	vec2 ruv = wp * rock_scale + id * 0.37;
	float rh = texture(rock_height, ruv).r;
	// the normal is stored in two channels (BC5, compress/normal_map): its z is rebuilt
	vec2 rxy = texture(rock_normal, ruv).rg * 2.0 - 1.0;
	vec3 rn = vec3(rxy, sqrt(max(1.0 - dot(rxy, rxy), 0.0)));
	c *= mix(1.0 - rock_value_, 1.0 + rock_value_ * 0.5, smoothstep(0.2, 0.8, rh));
	// painted wash inside each slab
	float wash = fbm(wp * 0.45 + id * 3.1);
#ifdef PAINT
	// the brush along the slab's long side; dry moss in olive, not teal
	c = paint_brushed(c, wp + id * 1.3, rect.z >= rect.w ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
	c = mix(c, paint_olive(c) * 0.9, smoothstep(0.62, 0.8, fbm(wp * 0.3 + 11.0)) * 0.3);
	vec3 hollow_c = c * joint_value * joint_cold;
#else
	c *= 0.78 + 0.44 * wash;
	c = mix(c, moss_color, smoothstep(0.62, 0.8, fbm(wp * 0.3 + 11.0)) * 0.3);
#endif
	// a corner missing on some slabs: gravel in a triangle
	float gone = 0.0;
	if (hash1(id + 21.0) < missing) {
		float corner = floor(hash1(id + 25.0) * 4.0);
		vec2 cs = vec2(mod(corner, 2.0) < 0.5 ? -1.0 : 1.0, corner < 2.0 ? -1.0 : 1.0);
		vec2 to = half_size - lp * cs;
		float size = mix(missing_size.x, missing_size.y, hash1(id + 27.0));
		gone = 1.0 - smoothstep(size - 0.02, size + 0.02, to.x + to.y + (noise(wp * 9.0) - 0.5) * 0.08);
	}
	// cracks across a share of the slabs, thinner toward the slab's middle
	float cn = fbm(wp * 1.3 + id * 5.0);
	float thin = mix(0.008, 0.02, smoothstep(0.0, 0.6, min(half_size.x - abs(lp.x), half_size.y - abs(lp.y)) < 0.6 ? 0.0 : 0.6));
#ifdef PAINT
	float crack = (1.0 - smoothstep(0.0, mix(0.01, 0.004, smoothstep(0.1, 0.7, edge)), abs(cn - 0.5))) * step(hash1(id + 3.0), cracked);
	c = mix(c, hollow_c, crack * 0.85);
	// big washes, fainter (the painted value is per slab), and the floor darker toward the room's edge
	float big = fbm(wp * 0.07 + 3.0);
	c *= 1.0 - 0.3 * paint_washes + 0.6 * paint_washes * big;
	float fire_near = 0.0;
	for (int i = 0; i < 8; i++) {
		if (i >= wet_spot_count) { break; }
		fire_near = max(fire_near, 1.0 - smoothstep(wet_spots[i].z, wet_spots[i].w, length(wp - wet_spots[i].xy)));
	}
	c *= mix(mix(1.0, edge_value, smoothstep(calm_radius * edge_span.x, calm_radius * edge_span.y, length(wp))), 1.0, fire_near);
#else
	float crack = (1.0 - smoothstep(0.0, mix(0.02, 0.008, smoothstep(0.1, 0.7, edge)), abs(cn - 0.5))) * step(hash1(id + 3.0), cracked);
	c = mix(c, crack_color, crack * 0.85);
	// big painted washes across the whole floor
	float big = fbm(wp * 0.07 + 3.0);
	c *= 0.7 + 0.6 * big;
	c = mix(c, c * vec3(0.85, 1.0, 1.08), smoothstep(0.4, 0.7, fbm(wp * 0.12 + 20.0)));
#endif
	// the calm middle: less contrast where the fight is
	float calm = 1.0 - smoothstep(calm_radius * 0.6, calm_radius, length(wp));
	vec3 mean = (sa + sb) * 0.5;
	c = mix(c, mix(mean, c, calm_contrast), calm);
	// the pale clearings over the slabs (each slab keeps its wash and relief under the dust)
#ifdef PAINT
	float cleared = smoothstep(clearing_cut.x, clearing_cut.y, fbm(wp * clearing_scale + 31.0)) * clearing * paint_clearing;
	vec3 clear_c = clearing_color * vec3(1.02, 1.0, 0.92);
#else
	float cleared = smoothstep(clearing_cut.x, clearing_cut.y, fbm(wp * clearing_scale + 31.0)) * clearing;
	vec3 clear_c = clearing_color;
#endif
	c = mix(c, clear_c * (0.8 + 0.3 * wash) * mix(1.0 - rock_value_ * 0.5, 1.0, smoothstep(0.2, 0.8, rh)), cleared);
	// the medallion carved in the slabs (worked out only under it)
	vec2 tilt_m = vec2(0.0);
	vec4 rose = vec4(1.0, 0.0, 0.0, 0.0);
	float under = 0.0;
	if (ring_radius > 0.0 && length(wp - ring_center) < ring_radius * 1.05) {
		rose = medallion(wp - ring_center, ring_radius, tilt_m);
		under = 1.0 - smoothstep(ring_radius * 0.95, ring_radius * 1.05, length(wp - ring_center));
	}
	// the band is its own stone: the slabs' values do not show through it
	float on_band = step(0.5, rose.z) * step(rose.z, 1.5) * under;
	c = mix(c, mean * mix(1.0 - rock_value_, 1.0 + rock_value_ * 0.5, smoothstep(0.2, 0.8, rh)) * (0.85 + 0.3 * wash), on_band);
	c *= rose.x;
	// the bevel and the joint (faded under the medallion)
	float joint_k = mix(1.0, rose.z > 1.5 ? point_joints : ring_joints, under * min(rose.z, 1.0));
#ifdef CHAMBER
	joint_k *= chamber_joints(wp);
#endif
#ifdef PAINT
	// the joint drawn at a share of the slab's value, never black; the medallion's lines in the joint's value, no gold
	c *= mix(1.0, mix(paint_bevel, 1.0, smoothstep(joint_width, joint_width + bevel, edge)), joint_k);
	float joint = (1.0 - smoothstep(joint_width * 0.5, joint_width, edge)) * joint_k;
	vec3 gravel = hollow_c * (0.85 + 0.3 * noise(wp * 30.0));
	c = mix(c, gravel, max(joint, gone));
	vec3 cut_c = mix(hollow_c, c * joint_value * joint_cold, on_band);
	c = mix(c, cut_c, clamp(rose.w, 0.0, 1.0) * groove_cover);
	c = mix(c, cut_c, rose.y * metal_cover);
#else
	c *= mix(1.0, mix(0.6, 1.0, smoothstep(joint_width, joint_width + bevel, edge)), joint_k);
	float joint = (1.0 - smoothstep(joint_width * 0.5, joint_width, edge)) * joint_k;
	vec3 gravel = joint_color * (0.7 + 0.9 * noise(wp * 30.0));
	c = mix(c, gravel, max(joint, gone));
	// the grooves, runes and cracks, and the thread of dark bronze in them
	c = mix(c, joint_color * groove_dark, clamp(rose.w, 0.0, 1.0) * groove_cover);
	c = mix(c, mix(gold_dark, gold_light, noise(wp * 6.0)), rose.y * metal_cover);
#endif
	// red petals in rare clusters, near the slabs' edges
	vec2 pc = floor(wp / 0.35);
	vec2 pf = fract(wp / 0.35) - 0.5;
	float cluster = smoothstep(0.78, 0.86, fbm(wp * 0.35 + 40.0));
	float petal_r = mix(0.08, 0.2, hash1(pc + 2.0)) / 0.35 * 0.5;
	float petal = step(length(pf - (vec2(hash1(pc), hash1(pc + 1.0)) - 0.5) * 0.5), petal_r) * step(hash1(pc + 4.0), 0.35);
#ifndef PAINT
	c = mix(c, petal_color, petal * cluster * (1.0 - smoothstep(0.15, 0.6, edge)) * (1.0 - joint) * (1.0 - under));
#endif
	// wet: in front of the portal and round the fire bowls only
	vec2 wz = step(wet_zone.xy, wp) * step(wp, wet_zone.zw);
	float wet = wz.x * wz.y * smoothstep(0.3, 0.6, fbm(wp * 0.5 + 5.0));
	for (int i = 0; i < 8; i++) {
		if (i >= wet_spot_count) { break; }
		vec4 s = wet_spots[i];
		float d = length(wp - s.xy) + (fbm(wp * 0.8 + float(i)) - 0.5) * 1.2;
		wet = max(wet, 1.0 - smoothstep(s.z, s.w, d));
	}
	wet *= 1.0 - joint * 0.5;
#ifdef PAINT
	c *= mix(1.0, paint_wet_dark, wet);
#else
	c *= mix(1.0, 0.8, wet);
#endif
#ifdef PAINT
	float rough = mix(mix(0.92, 0.97, hash1(id + 31.0)), wet_roughness, wet);
	vec3 emit = vec3(0.0);
#else
	float rough = mix(mix(dry_roughness.x, dry_roughness.y, hash1(id + 31.0)), wet_roughness, wet);
	vec3 emit = gold_light * rose.y * ring_glow;
#endif
	// the normal: the slab's own slight tilt, its bevel leaning out toward the joint, the medallion's relief
	vec2 lean = (vec2(hash1(id + 41.0), hash1(id + 43.0)) - 0.5) * 2.0 * tan(radians(slab_tilt)) * (1.0 - on_band);
	float b = (1.0 - smoothstep(bevel * 0.6, bevel, edge)) * (1.0 - joint) * joint_k;
	lean += out_dir * b * bevel_tilt;
	lean += tilt_m * under;
	lean += vec2(rn.x, -rn.y) * rock_relief_ * (1.0 - joint);
#ifdef CHAMBER
	chamber_floor(wp, id, rect, joint, c, emit, lean, rough);
#endif
#ifdef RUNES
	rune_floor(wp, rect, edge, joint, c, emit, lean, rough);
#endif
	ALBEDO = c;
	ROUGHNESS = rough;
#ifdef PAINT
	SPECULAR = 0.15;
#else
	SPECULAR = 0.2;
#endif
	EMISSION = emit;
	vec3 nw = normalize(vec3(lean.x, 1.0, lean.y));
	NORMAL = normalize((VIEW_MATRIX * vec4(nw, 0.0)).xyz);
}
