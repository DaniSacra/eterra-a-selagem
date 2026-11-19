shader_type spatial;
// Painted decals on the floor of the stylized look (room redesign, lot A; docs/art/room_redesign_lotA_spec.md 3.3,
// 3.4): one flat quad a centimetre over the slabs, lit like the stone, never glowing. `kind` picks the drawing:
//   0 the shop's rug: an umber cloth with an ochre border and a worn diamond of old gold in its middle (UV: 0..1 over
//     the rug; nothing round, no red);
//   1 the fountain's moss: a ragged ring of grey-green moss round the basin, denser to the north (-z), with pale ivory
//     and faint lilac flowers in it (UV: -1..1 over a square of side 2 * ring.y).
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
uniform vec2 ring = vec2(1.95, 3.2);
uniform vec3 moss : source_color = vec3(0.205, 0.22, 0.19);
uniform vec3 flower_pale : source_color = vec3(0.72, 0.7, 0.62);
uniform vec3 flower_lilac : source_color = vec3(0.55, 0.52, 0.6);
uniform float flower_cell = 0.42;
uniform float flower_share = 0.18;
uniform float flower_size = 0.03;
uniform float alpha = 0.92;

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
	} else {
		vec2 m = (UV - 0.5) * 2.0 * ring.y;
		float r = length(m);
		float north = smoothstep(ring.y, -ring.y, m.y);
		float n = fbm(m * 1.4 + 7.0);
		float outer = mix(ring.x + 0.35, ring.y, mix(0.25, 1.0, north)) + (n - 0.5) * 0.9;
		float cover = smoothstep(ring.x - 0.02, ring.x + 0.06, r) * (1.0 - smoothstep(outer - 0.12, outer, r));
		cover *= smoothstep(0.3, 0.55, fbm(m * 3.3) + north * 0.25);
		c = moss * mix(0.8, 1.15, fbm(m * 6.0));
		vec2 cell = floor(m / flower_cell);
		vec2 at = (cell + vec2(hash(cell), hash(cell + 3.1)) * 0.8 + 0.1) * flower_cell;
		float f = step(hash(cell + 9.7), flower_share) * (1.0 - step(flower_size, length(m - at)));
		c = mix(c, hash(cell + 5.3) < 0.7 ? flower_pale : flower_lilac, f);
		a = alpha * max(cover, f * step(ring.x, r) * step(r, outer));
	}
	ALBEDO = c;
	ROUGHNESS = 1.0;
	ALPHA = a;
}
