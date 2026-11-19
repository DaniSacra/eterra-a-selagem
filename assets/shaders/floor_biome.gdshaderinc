// The painted floor's biome (docs/art/sworn_reference_ideas.md 3.1, SW-G1 and SW-G2), only in the stylized look:
// included by catacomb_floor.gdshaderinc under PAINT, after its noise (hash1, noise, fbm). Every amount is 0 by
// default, so a floor whose room sets nothing (the runes' chamber, the Chamber of the Seal) is the floor it was. A room's
// numbers come from the `floor` dictionary of its style() (ArenaKit.paint_look: shader parameter name to value).
// Two steps called by the floor's fragment():
// - floor_patches(): SW-G1, the biome's second colour (moss, pale dust, grey salt, cold damp) in low patches of 3 to 8 m,
//   stronger within patch_reach of the floor's edge. Paint only, no relief.
// - floor_gobo(): SW-G2, the mottled shade of what hangs over the floor (the garden's canopy, the sanctuary's broken
//   vault ribs in its shafts), drifting slowly. Drawn in the albedo, so it is the same in the browser's renderer
//   (no light_projector).
// Later floor layers of the redesign (framed slabs, SW-G3) go here too, each its own function and uniforms.

// ---------- the edge of the walkable floor ----------
// ArenaRoom._floor writes each vertex's distance to the floor's edge in its colour's red, over FLOOR_EDGE_NORM m
// (ArenaRoom.FLOOR_EDGE_NORM); a floor without vertex colours (the hall's plate) reads 1, far from any edge, and may
// give its walkable box instead (centre x and z, half size x and z; 0 none).
const float FLOOR_EDGE_NORM = 8.0;
uniform vec4 floor_box = vec4(0.0);

float floor_edge_m(vec2 wp, vec4 vcolor) {
	float d = vcolor.r * FLOOR_EDGE_NORM;
	if (floor_box.z > 0.0) {
		vec2 b = floor_box.zw - abs(wp - floor_box.xy);
		d = min(d, max(min(b.x, b.y), 0.0));
	}
	return d;
}

// ---------- SW-G1: the biome's patches ----------
// The patch's colour where the floor's painted stone (floor_stone) would be: each slab keeps its own value and relief
// under it (the patch scales with the slab's value). Its share at a patch's heart in the middle of the room (x) and at
// the floor's edge (y, full within patch_reach m and fading to x by twice that). The noise's scale (m: patches of
// about patch_scale * 0.6 to * 1.6), where it starts and is full, and how much lower it starts at the edge (more of the
// floor taken there).
uniform vec3 patch_color : source_color = vec3(0.3, 0.3, 0.3);
uniform vec2 patch_share = vec2(0.0, 0.0);
uniform float patch_reach = 3.0;
uniform float patch_scale = 5.0;
uniform vec2 patch_cut = vec2(0.46, 0.6);
// The value of the floor between the patches, at the same share (a little darker under pale patches, a little lighter
// between dark ones: the floor's mean value stays and its range opens both ways).
uniform float patch_rest = 1.0;
uniform float patch_cut_edge = 0.1;

vec3 floor_patches(vec3 c, vec2 wp, float edge_m, vec3 stone) {
	if (patch_share.x <= 0.0 && patch_share.y <= 0.0) {
		return c;
	}
	float near = 1.0 - smoothstep(patch_reach, patch_reach * 2.0, edge_m);
	// a low noise for the patches' bodies, a finer one breaking their outline
	float n = fbm(wp / patch_scale + vec2(57.0, 13.0)) + (noise(wp * 0.9 + 71.0) - 0.5) * 0.1;
	float lower = patch_cut_edge * near;
	float m = smoothstep(patch_cut.x - lower, patch_cut.y - lower, n);
	vec3 patched = patch_color * (paint_luma(c) / max(paint_luma(stone), 1e-3));
	float share = mix(patch_share.x, patch_share.y, near);
	return mix(c * mix(1.0, patch_rest, share), patched, m * share);
}

// ---------- SW-G2: the mottled shade ----------
// gobo_kind: 0 none, 1 leaves (the canopy: dapples, denser toward the spots), 2 ribs (the vault's broken ribs: a
// quadripartite bay of gobo_scale m, stretched gobo_stretch times along gobo_along, the light's lean on the floor, some
// diagonals gone and gaps along the rest). gobo_strength: the most it darkens (0.15 to 0.25). gobo_base: its weight on
// the whole floor; gobo_spots (x, z, radius, weight; full inside half the radius): where it is stronger (under the tree,
// on a shaft's floor). gobo_width: a rib's half width (in bays). gobo_drift (m/s) and gobo_sway (m) move it slowly;
// gobo_soft is the shade's edge (in the pattern's units); fires' pools (the wet spots round the bowls) stay clear.
uniform int gobo_kind = 0;
uniform float gobo_strength = 0.0;
uniform float gobo_base = 0.0;
uniform vec4 gobo_spots[4];
uniform int gobo_spot_count = 0;
uniform float gobo_scale = 1.0;
uniform vec2 gobo_along = vec2(0.0, 1.0);
uniform float gobo_stretch = 1.0;
uniform vec2 gobo_drift = vec2(0.0);
uniform float gobo_sway = 0.0;
uniform float gobo_soft = 0.1;
uniform float gobo_cover = 0.5;
uniform float gobo_width = 0.06;

float gobo_weight(vec2 wp) {
	float w = gobo_base;
	for (int i = 0; i < 4; i++) {
		if (i >= gobo_spot_count) { break; }
		vec4 s = gobo_spots[i];
		w = max(w, s.w * (1.0 - smoothstep(s.z * 0.5, s.z, length(wp - s.xy))));
	}
	return w;
}

// Leaves: two noises drifting at different speeds and swaying, cut to dapples; denser where the weight is high.
float gobo_leaves(vec2 wp, float w, float t) {
	vec2 sway = vec2(sin(t * 0.7 + wp.y * 0.21), cos(t * 0.53 + wp.x * 0.17)) * gobo_sway;
	vec2 q = (wp + sway) / gobo_scale + gobo_drift * t;
	float a = fbm(q + 23.0);
	float b = noise(q * 2.6 - gobo_drift * t * 1.7 + 9.0);
	float v = a * 0.62 + b * 0.38;
	float from = mix(0.62, 0.62 - gobo_cover * 0.3, w);
	return smoothstep(from - gobo_soft, from + gobo_soft, v);
}

// Ribs: the distance to the nearest rib of the bay (its borders and both diagonals), broken.
float gobo_ribs(vec2 wp, float t) {
	vec2 a = normalize(gobo_along);
	vec2 sway = vec2(sin(t * 0.31), cos(t * 0.23)) * gobo_sway;
	vec2 p = wp + sway;
	vec2 q = vec2(dot(p, vec2(-a.y, a.x)), dot(p, a) / gobo_stretch) / gobo_scale;
	vec2 cell = floor(q);
	vec2 f = fract(q) - 0.5;
	float border = min(0.5 - abs(f.x), 0.5 - abs(f.y));
	float diag = min(abs(f.x - f.y), abs(f.x + f.y)) * 0.7071;
	// a share of the bays lost their diagonals, a few their whole vault (the tear)
	float keep_diag = step(gobo_cover * 0.6, hash1(cell + 3.0));
	float keep_bay = step(0.15, hash1(cell + 7.0));
	float d = min(border, mix(1.0, diag, keep_diag));
	float rib = 1.0 - smoothstep(gobo_width, gobo_width + gobo_soft, d);
	// gaps along the ribs (broken stones)
	rib *= smoothstep(0.25, 0.4, noise(q * 3.1 + 41.0));
	return rib * keep_bay;
}

vec3 floor_gobo(vec3 c, vec2 wp, float clear, float t) {
	if (gobo_kind == 0 || gobo_strength <= 0.0) {
		return c;
	}
	float w = gobo_weight(wp);
	if (w <= 0.0) {
		return c;
	}
	float shade = gobo_kind == 1 ? gobo_leaves(wp, w, t) * w : gobo_ribs(wp, t) * w;
	return c * (1.0 - gobo_strength * shade * (1.0 - clear));
}
