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
