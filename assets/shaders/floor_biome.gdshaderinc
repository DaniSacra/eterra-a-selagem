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

// ---------- SW-G3 and SW-C1: framed slabs and grave slabs ----------
// A few slabs laid in the floor by hand (axis aligned, in world metres): framed_rects (x, z, half x, half z) and
// framed_info (kind, lion, value, seed), framed_count of them (0: none). The fragment takes the frame for its slab
// (framed_at: the floor's own slabs and joints give way to one slab the size of the frame, its joint at the frame's
// edge) and then draws the relief (floor_framed) in the paint and the normal only, nothing raised: 0.04 to 0.08 m read
// from the shading. kind 0, SW-G3: a raised moulding framed_rim wide (its outer slope lit or shaded by relief_light,
// its top a step lighter, its inner foot dark) round a worn slab (lighter and smoother toward its middle). kind 1,
// SW-C1, a grave slab: a sunk groove framed_groove (from, width) in from its edge, the slab inside flat and worn, never
// a word; lion 1: the seal's lion (lion_sdf) small in raised relief in its middle, framed_lion_span m high, its head
// to the north. Never a disc, a ring or a cross: the frames are rectangles.
const int FRAMED_MAX = 16;
uniform vec4 framed_rects[16];
uniform vec4 framed_info[16];
uniform int framed_count = 0;
// the moulding (kind 0): its width, its slopes' width, its top's value, the dark at its inner foot, the slopes' tilt
uniform float framed_rim = 0.2;
uniform float framed_slope = 0.05;
uniform float framed_lip = 1.22;
uniform float framed_foot = 0.55;
uniform float framed_tilt = 0.9;
// how much a slope facing the light (relief_light) is lighter, one facing away darker (share of its value)
uniform float framed_face = 0.45;
// the worn slab inside: how much lighter its middle, how smooth (share of the rock relief left)
uniform float framed_worn = 0.16;
uniform float framed_smooth = 0.4;
// the grave slab's groove (kind 1): from its edge (m), its width (m), its dark
uniform vec2 framed_groove = vec2(0.1, 0.08);
uniform float framed_groove_dark = 0.85;
// the lion: its field (lion_sdf.res: red = signed distance to its outline, 0.5 on the edge, spread px to the full
// swing on a px texture), its height on the slab (m), its value raised, the shade on its lee side
uniform sampler2D framed_lion : filter_linear_mipmap, repeat_disable;
uniform float framed_lion_span = 0.8;
uniform float framed_lion_px = 512.0;
uniform float framed_lion_spread = 24.0;
uniform float framed_lion_value = 1.35;
uniform float framed_lion_shade = 0.5;

// The frame under wp: its rect and info, 1.0 when there is one.
float framed_at(vec2 wp, out vec4 rect, out vec4 info) {
	rect = vec4(0.0);
	info = vec4(0.0);
	for (int i = 0; i < FRAMED_MAX; i++) {
		if (i >= framed_count) { break; }
		vec4 r = framed_rects[i];
		vec2 d = abs(wp - r.xy);
		if (d.x <= r.z && d.y <= r.w) {
			rect = r;
			info = framed_info[i];
			return 1.0;
		}
	}
	return 0.0;
}

// The lion's signed distance (m, + inside) at local q (from the slab's middle), -1 off its field.
float framed_lion_at(vec2 q) {
	vec2 uv = q / framed_lion_span + 0.5;
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
		return -1.0;
	}
	float to_m = framed_lion_spread * 2.0 * framed_lion_span / framed_lion_px;
	return (texture(framed_lion, uv).r - 0.5) * to_m;
}

// The relief of the frame (info from framed_at) at wp: local position from its middle (lp), how far in from its edge
// (edge, m: the joint's own, wobble and nicks included), the cold hollow colour of the floor's cuts.
void floor_framed(inout vec3 c, inout vec2 lean, vec2 lp, vec2 half_size, float edge, vec4 info, vec3 hollow) {
	vec2 q = abs(lp) - half_size;
	vec2 out_dir = (q.x > q.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0)) * sign(lp + 1e-5);
	// the moulding and the groove follow the frame's own outline, clean of the joint's nicks (the joint keeps them)
	vec2 qr = abs(lp) - (half_size - corner_round);
	edge = corner_round - length(max(qr, 0.0)) - min(max(qr.x, qr.y), 0.0);
	vec2 lit = normalize(relief_light);
	// a slope facing out of the frame (+1) or in (-1) is lit by its facing on the light
	float facing = dot(out_dir, lit);
	c *= info.z;
	// the worn middle: lighter and smoother away from the edge
	float inner = smoothstep(0.0, min(half_size.x, half_size.y), edge);
	c *= 1.0 + framed_worn * inner * inner;
	lean *= mix(1.0, framed_smooth, inner);
	if (info.x < 0.5) {
		// SW-G3: the raised moulding
		float j = joint_width;
		float up = smoothstep(j, j + framed_slope, edge);
		float down = smoothstep(framed_rim - framed_slope, framed_rim, edge);
		float outer_slope = up * (1.0 - smoothstep(j + framed_slope, j + framed_slope * 1.2, edge));
		float inner_slope = down * (1.0 - smoothstep(framed_rim, framed_rim + framed_slope * 0.6, edge));
		float top = up * (1.0 - down);
		c *= mix(1.0, framed_lip, top);
		c *= 1.0 + framed_face * facing * (outer_slope - inner_slope);
		// the slab sits lower: a dark line at the moulding's inner foot
		float foot = smoothstep(framed_rim, framed_rim + 0.02, edge) * (1.0 - smoothstep(framed_rim + 0.02, framed_rim + 0.07, edge));
		c *= mix(1.0, framed_foot, foot);
		lean += out_dir * framed_tilt * (outer_slope - inner_slope);
	} else {
		// SW-C1: the grave slab's sunk groove
		float g0 = framed_groove.x;
		float g1 = g0 + framed_groove.y;
		float groove = smoothstep(g0 - 0.01, g0 + 0.01, edge) * (1.0 - smoothstep(g1 - 0.01, g1 + 0.01, edge));
		c = mix(c, mix(c, hollow, framed_groove_dark), groove);
		// its outer wall faces in, its inner wall out: one lit, one in shade
		float wall_out = smoothstep(g0 - 0.015, g0 + 0.015, edge) * (1.0 - smoothstep(g0 + 0.015, g0 + 0.03, edge));
		float wall_in = smoothstep(g1 - 0.03, g1 - 0.015, edge) * (1.0 - smoothstep(g1 - 0.015, g1 + 0.015, edge));
		c *= 1.0 + framed_face * facing * (wall_in - wall_out);
		lean += out_dir * framed_tilt * (wall_in - wall_out);
		if (info.y > 0.5) {
			float d = framed_lion_at(lp);
			if (d > -0.08) {
				float body = smoothstep(-0.006, 0.006, d);
				// the relief's lee: the outline shifted toward the light shades the stone beside it
				float lee = smoothstep(-0.006, 0.006, framed_lion_at(lp + lit * 0.025)) * (1.0 - body);
				c *= mix(1.0, framed_lion_value, body);
				c *= mix(1.0, framed_lion_shade, lee);
				vec2 e = vec2(0.012, 0.0);
				vec2 grad = vec2(framed_lion_at(lp + e.xy) - framed_lion_at(lp - e.xy), framed_lion_at(lp + e.yx) - framed_lion_at(lp - e.yx));
				float rim = body * (1.0 - smoothstep(0.0, 0.02, d));
				if (length(grad) > 1e-5) {
					lean += -normalize(grad) * rim * framed_tilt * 0.6;
				}
			}
		}
	}
}
