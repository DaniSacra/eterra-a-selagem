shader_type spatial;
// The gold inscription cut in the garden's floor round the tree (GardenLook, cycle C12; spec 4.6): broken arcs, never a
// closed ring, a carving without any glow: two thin border lines and a row of worn angular glyphs between them, in a
// dull old gold a little darker than the slabs (contrast under 15%). Only drawn, never a danger.
// UV.x: meters along the arc; UV.y: 0 on its inner edge, 1 on its outer.
render_mode blend_mix, depth_draw_never, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 gold : source_color = vec3(0.306, 0.247, 0.149);
// How much of the gold covers the slab where a stroke is (its contrast with the floor).
uniform float strength = 0.5;
// Width of the border lines and of a glyph's stroke (shares of the band's width), the glyphs' cell (m).
uniform float border = 0.07;
uniform float stroke = 0.075;
uniform float cell = 0.5;
// How worn: the share of each stroke left (noise), and the arcs' ends fading out (m).
uniform float worn = 0.35;
uniform float fade_ends = 0.6;
uniform float arc_length = 10.0;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
}

// Distance from p to the segment a-b.
float seg(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a;
	vec2 ba = b - a;
	return length(pa - ba * clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0));
}

void fragment() {
	float v = UV.y;
	float u = UV.x;
	float lines = max(1.0 - smoothstep(border * 0.6, border, v), smoothstep(1.0 - border, 1.0 - border * 0.6, v));
	// a glyph in each cell: a few strokes picked by the cell, between the border lines
	float id = floor(u / cell);
	vec2 g = vec2(fract(u / cell), (v - 0.22) / 0.56);
	float d = 9.0;
	if (g.y > -0.1 && g.y < 1.1 && hash1(vec2(id, 3.0)) > 0.12) {
		vec2 pts[6] = vec2[](vec2(0.25, 0.0), vec2(0.75, 0.0), vec2(0.25, 0.5), vec2(0.75, 0.5), vec2(0.25, 1.0), vec2(0.75, 1.0));
		d = seg(g, vec2(0.5, 0.0), vec2(0.5, 1.0));
		for (int k = 0; k < 4; k++) {
			float h = hash1(vec2(id, float(k) + 7.0));
			int a = int(floor(h * 6.0));
			int b = int(floor(fract(h * 13.7) * 6.0));
			if (a != b) {
				d = min(d, seg(g, pts[a], pts[b]));
			}
		}
	}
	float glyph = 1.0 - smoothstep(stroke * 0.6, stroke, d * 0.56);
	float mark = max(lines, glyph);
	mark *= smoothstep(worn - 0.15, worn + 0.15, noise(vec2(u * 2.3, v * 3.0)));
	mark *= smoothstep(0.0, fade_ends, u) * smoothstep(0.0, fade_ends, arc_length - u);
	ALBEDO = gold;
	ALPHA = mark * strength;
	ROUGHNESS = 0.8;
	SPECULAR = 0.3;
}
