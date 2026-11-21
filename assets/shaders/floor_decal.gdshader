shader_type spatial;
// Painted decals on the floor of the stylized look (room redesign, lot A; docs/art/room_redesign_lotA_spec.md 3.3,
// 3.4): one flat quad a centimetre over the slabs, lit like the stone, never glowing. `kind` picks the drawing:
//   0 the shop's rug: an umber cloth with an ochre border and a worn diamond of old gold in its middle (UV: 0..1 over
//     the rug; nothing round, no red);
//   1 the fountain's moss: a ragged ring of grey-green moss round the basin, denser to the north (-z), with pale ivory
//     and faint lilac flowers in tufts in it (UV: 0..1 over a square of side 2 * (ring.y + north_reach + ragged + 0.1),
//     CatacombHall.dress_fountain);
//   2 moss and ivy on a wall (room redesign lot B, the sanctuary's S5): a card on the stone, dense along its top edge
//     (UV.y 0) and hanging down in ragged tongues, a few darker leaves in it (UV 0..1 over the card, `rug_size` its
//     size in m).
//   3 fallen leaves (room redesign lot C, the garden's J2): dead leaves in rust, each a small pointed oval in its own
//     cell, at most `litter_cover` of the card, densest along one side (UV.y 0: the wall's foot) and thinning to none
//     at the other; with `litter_ring.y` > 0 instead between two radii round the card's middle (m: the trunk's foot).
//   4 the trial's lozenges (room redesign lot D, T1): grooves of `groove_width` m in `groove_color` along squares turned
//     45 degrees, all round the card's middle (their sides `lozenges` m; 0: none), worn away in stretches (`groove_worn`);
//     nothing round (UV 0..1 over the card, `rug_size` its size in m).
//   5 a wet run (Sworn P2 SW-H2, the fountain's water down the joints): a strip built along a path (UV.x along it in m,
//     UV.y 0..1 across, COLOR.a its strength fading to the end), `wet` in its middle with a broken edge, or with
//     `wet_moss` > 0 the moss beside it (the strip's sides only);
//   6 a worn trail (SW-H3, the shop): the same kind of strip, the slabs under it darker in cells of `trail_cell` m (each
//     its own wear), soft at its sides, COLOR.a its strength.
render_mode blend_mix, depth_draw_never, cull_disabled, diffuse_lambert, specular_disabled;

uniform int kind = 0;
uniform vec3 cloth : source_color = vec3(0.16, 0.11, 0.08);
uniform vec3 border : source_color = vec3(0.34, 0.24, 0.12);
uniform vec3 gold : source_color = vec3(0.42, 0.31, 0.13);
// the rug: its size in m (x, y), the border's width (m), the diamond's half size (share of the short side)
uniform vec2 rug_size = vec2(2.6, 1.8);
uniform float border_width = 0.12;
uniform float diamond = 0.22;
uniform float wear = 0.35;
// the moss: its ring (inner, outer radius in m), colour, flower colours, how many flowers a square meter, their size
// (lot A review item 9: the outer radius is the mean one, broken by `ragged` m of noise along the edge and swung
// `north_reach` m out to the north and in to the south, so no stretch of the edge reads as a regular arc; the flowers
// in tufts of 3 to 6 in cells of `flower_cell` m, `flower_share` of the cells, each flower `flower_size` m across, at
// most `tuft_reach` m from its tuft's middle)
uniform vec2 ring = vec2(1.95, 3.0);
uniform float ragged = 0.5;
uniform float north_reach = 0.3;
uniform vec3 moss : source_color = vec3(0.17, 0.20, 0.15);
uniform vec3 flower_pale : source_color = vec3(0.72, 0.7, 0.62);
uniform vec3 flower_lilac : source_color = vec3(0.55, 0.52, 0.6);
uniform float flower_cell = 0.95;
uniform float flower_share = 0.32;
uniform vec2 flower_size = vec2(0.09, 0.14);
uniform float tuft_reach = 0.28;
uniform float alpha = 0.92;
// the fallen leaves: their two rusts (hue 15 to 25, value up to 0.4), the cell (m), a leaf's length range (m), the
// share of cells with a leaf where it is densest, the ring (inner, outer radius m; y 0: the band along UV.y 0)
uniform vec3 leaf_dark : source_color = vec3(0.24, 0.14, 0.09);
uniform vec3 leaf_light : source_color = vec3(0.36, 0.22, 0.14);
uniform float litter_cell = 0.16;
uniform vec2 litter_size = vec2(0.09, 0.15);
uniform float litter_cover = 0.3;
uniform vec2 litter_ring = vec2(0.0, 0.0);
// the lozenges: their sides (m), the groove's width (m, across it), its colour and the share of it worn away
uniform vec3 lozenges = vec3(4.0, 7.0, 10.0);
uniform float groove_width = 0.08;
uniform vec3 groove_color : source_color = vec3(0.12, 0.115, 0.13);
uniform float groove_worn = 0.2;
// the lit lip along each groove's outer side (its colour, its width as a share of the groove's), so it reads cut
uniform vec3 groove_lip : source_color = vec3(0.3, 0.29, 0.32);
uniform float groove_lip_width = 0.7;
// kinds 5 and 6
uniform vec3 wet : source_color = vec3(0.05, 0.06, 0.07);
uniform float wet_moss = 0.0;
uniform vec3 trail : source_color = vec3(0.08, 0.09, 0.11);
uniform float trail_cell = 0.9;
uniform vec2 trail_wear = vec2(0.35, 0.75);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	return noise(p) * 0.55 + noise(p * 2.1) * 0.3 + noise(p * 4.3) * 0.15;
}

void fragment() {
	vec3 c = cloth;
	float a = alpha;
	if (kind == 0) {
		vec2 m = (UV - 0.5) * rug_size;
		vec2 d = rug_size * 0.5 - abs(m);
		float edge = min(d.x, d.y);
		float n = fbm(m * 3.0);
		c = cloth * mix(0.85, 1.12, n);
		c = mix(c, border * mix(0.85, 1.1, n), step(edge, border_width) * step(border_width * 0.3, edge));
		float dm = abs(m.x) / rug_size.y + abs(m.y) / rug_size.y;
		float dia = step(dm, diamond) * (1.0 - step(dm, diamond - 0.045));
		c = mix(c, gold, dia * (1.0 - wear * n));
		// frayed ends: the short sides a little ragged
		a *= step(0.0, d.x - noise(vec2(m.y * 9.0, 3.0)) * 0.05);
	} else if (kind == 2) {
		vec2 m = UV * rug_size;
		float n = fbm(vec2(m.x * 2.2, 1.7));
		// how far down the tongue at this x hangs (m), and a ragged edge at its foot
		float reach = rug_size.y * mix(0.12, 1.0, pow(n, 1.6)) * (0.8 + 0.4 * noise(vec2(m.x * 7.0, 4.0)));
		float cover = 1.0 - smoothstep(reach - 0.12, reach, m.y + (fbm(m * 6.0) - 0.5) * 0.25);
		cover *= smoothstep(0.0, 0.06, min(m.x, rug_size.x - m.x));
		cover *= smoothstep(0.32, 0.5, fbm(m * 4.0) + 0.25 * (1.0 - UV.y));
		c = moss * mix(0.7, 1.15, fbm(m * 9.0));
		a = alpha * cover;
	} else if (kind == 3) {
		vec2 m = UV * rug_size;
		float dense;
		if (litter_ring.y > 0.0) {
			float r = length(m - rug_size * 0.5);
			dense = smoothstep(litter_ring.x - 0.05, litter_ring.x + 0.1, r) * (1.0 - smoothstep(litter_ring.y - 0.4, litter_ring.y, r));
		} else {
			dense = 1.0 - smoothstep(0.1, 1.0, UV.y);
		}
		// clumps: the noise thins the cells out in drifts
		dense *= smoothstep(0.3, 0.6, fbm(m * 1.4));
		float leaf = 0.0;
		float tone = 0.0;
		vec2 home = floor(m / litter_cell);
		for (int i = -1; i <= 1; i++) {
			for (int j = -1; j <= 1; j++) {
				vec2 cell = home + vec2(float(i), float(j));
				if (hash(cell + 2.3) > litter_cover * 2.0 * dense) {
					continue;
				}
				vec2 mid = (cell + 0.5 + (vec2(hash(cell + 5.1), hash(cell + 7.7)) - 0.5) * 0.8) * litter_cell;
				float turn = hash(cell + 1.1) * 6.2832;
				vec2 d = mat2(vec2(cos(turn), sin(turn)), vec2(-sin(turn), cos(turn))) * (m - mid);
				float len = mix(litter_size.x, litter_size.y, hash(cell + 3.3)) * 0.5;
				// a pointed oval: narrower toward both tips
				float wide = len * 0.45 * (1.0 - pow(clamp(abs(d.x) / len, 0.0, 1.0), 2.0));
				if (abs(d.x) < len && abs(d.y) < wide) {
					leaf = 1.0;
					tone = hash(cell + 9.9);
				}
			}
		}
		c = mix(leaf_dark, leaf_light, tone) * mix(0.85, 1.1, noise(m * 9.0));
		a = alpha * leaf;
	} else if (kind == 4) {
		vec2 m = (UV - 0.5) * rug_size;
		// a square of side s turned 45 degrees: |x| + |y| = s / sqrt(2); across its side the distance is that / sqrt(2)
		float k = abs(m.x) + abs(m.y);
		float line = 0.0;
		float lip = 0.0;
		for (int i = 0; i < 3; i++) {
			float s = lozenges[i];
			if (s <= 0.0) { continue; }
			float off = (k - s * 0.7071) * 0.7071;
			line = max(line, 1.0 - smoothstep(groove_width * 0.4, groove_width * 0.5 + 0.004, abs(off)));
			float lw = groove_width * groove_lip_width;
			lip = max(lip, 1.0 - smoothstep(lw * 0.4, lw * 0.5 + 0.004, abs(off - groove_width * 0.5 - lw * 0.5)));
		}
		float kept = step(groove_worn, noise(m * 1.3 + 4.0) * 0.7 + noise(m * 5.0) * 0.3);
		c = mix(groove_lip, groove_color, line) * mix(0.85, 1.1, noise(m * 20.0));
		a = alpha * max(line, lip * 0.35) * kept;
	} else if (kind == 5) {
		float across = abs(UV.y - 0.5) * 2.0;
		float n = noise(vec2(UV.x * 3.0, UV.y * 2.0)) * 0.6 + noise(vec2(UV.x * 11.0, UV.y * 5.0)) * 0.4;
		if (wet_moss > 0.0) {
			// moss either side of the run, in tufts
			float side = smoothstep(0.25, 0.45, across) * (1.0 - smoothstep(0.75, 1.0, across));
			c = moss * mix(0.8, 1.15, fbm(vec2(UV.x * 6.0, UV.y * 3.0)));
			a = alpha * wet_moss * side * smoothstep(0.45, 0.6, n) * COLOR.a;
		} else {
			c = wet * mix(0.85, 1.15, n);
			a = alpha * (1.0 - smoothstep(0.35 + n * 0.3, 0.7 + n * 0.3, across)) * smoothstep(0.15, 0.35, n + COLOR.a * 0.4) * COLOR.a;
		}
	} else if (kind == 6) {
		vec2 m = vec2(UV.x, UV.y * rug_size.y);
		vec2 cell = floor(m / trail_cell);
		float worn = mix(trail_wear.x, trail_wear.y, hash(cell + 2.3));
		vec2 f = abs(fract(m / trail_cell) - 0.5) * 2.0;
		float slab = 1.0 - smoothstep(0.82, 0.97, max(f.x, f.y));
		float across = abs(UV.y - 0.5) * 2.0;
		c = trail * mix(0.85, 1.1, noise(m * 4.0));
		a = alpha * worn * mix(0.55, 1.0, slab) * (1.0 - smoothstep(0.55, 1.0, across + (noise(m * 1.7) - 0.5) * 0.3)) * COLOR.a;
	} else {
		float reach = ring.y + north_reach + ragged + 0.1;
		vec2 m = (UV - 0.5) * 2.0 * reach;
		float r = length(m);
		vec2 dir = m / max(r, 1e-4);
		float north = clamp(-dir.y, -1.0, 1.0);
		// the edge: two scales of noise round the ring (cells of about 0.7 and 0.3 m along it) and a little in 2D
		float n = noise(dir * ring.y / 0.7 + 7.0) * 0.6 + noise(dir * ring.y / 0.3 + 3.0) * 0.25 + noise(m * 1.7) * 0.15;
		float outer = ring.y + north * north_reach + (n - 0.5) * 2.0 * ragged;
		float cover = smoothstep(ring.x - 0.02, ring.x + 0.06, r) * (1.0 - smoothstep(outer - 0.1, outer, r));
		cover *= smoothstep(0.3, 0.55, fbm(m * 3.3) + (north * 0.5 + 0.5) * 0.25);
		c = moss * mix(0.8, 1.15, fbm(m * 6.0));
		// the flowers, in tufts: the 3 x 3 cells round this one, 3 to 6 flowers in each tuft
		float f = 0.0;
		bool lilac = false;
		vec2 home = floor(m / flower_cell);
		for (int i = -1; i <= 1; i++) {
			for (int j = -1; j <= 1; j++) {
				vec2 cell = home + vec2(float(i), float(j));
				if (hash(cell + 9.7) > flower_share) {
					continue;
				}
				vec2 mid = (cell + 0.5 + (vec2(hash(cell), hash(cell + 3.1)) - 0.5) * 0.5) * flower_cell;
				int count = 3 + int(hash(cell + 1.9) * 3.99);
				for (int k = 0; k < 6; k++) {
					if (k >= count) {
						break;
					}
					vec2 key = cell + vec2(float(k) * 1.37, float(k) * 2.11);
					vec2 at = mid + (vec2(hash(key + 4.4), hash(key + 6.6)) - 0.5) * 2.0 * tuft_reach;
					float size = mix(flower_size.x, flower_size.y, hash(key + 8.8)) * 0.5;
					if (length(m - at) < size) {
						f = 1.0;
						lilac = hash(key + 5.3) > 0.7;
					}
				}
			}
		}
		f *= step(ring.x, r) * step(r, outer);
		c = mix(c, lilac ? flower_lilac : flower_pale, f);
		a = alpha * max(cover, f);
	}
	ALBEDO = c;
	ROUGHNESS = 1.0;
	ALPHA = a;
}
