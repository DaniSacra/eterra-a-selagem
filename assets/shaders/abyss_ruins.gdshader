shader_type spatial;
// The far ruins of the abyss, painted on an upright card (three of them stand one behind the other, so they slide
// against each other when the camera moves): broken towers of two or three stacked blocks that narrow upward (flat,
// chipped or crenellated tops), a pointed arch or a broken deck joining some neighbours, a stump of a deck on some
// lonely ones and, on the farthest card, a cave's roof with stalactites, lower to the west. Columns of silhouettes are
// drawn by a hash of the column, so no three in a row match. Unlit, out of the fog, and cut by alpha scissor in the
// opaque pass: one depth test, no blending over the screen.
render_mode unshaded, fog_disabled, cull_disabled, shadows_disabled;

#include "res://assets/shaders/room_air.gdshaderinc"

uniform vec3 stone_color : source_color = vec3(0.039, 0.11, 0.149);
// The cold light of the mist on the top of each block, and how much of it.
uniform vec3 edge_color : source_color = vec3(0.086, 0.47, 0.545);
uniform float edge = 0.25;
uniform float edge_height = 0.5;
// soften > 0 (the bridge's far ruins): the cold edge fades out and the stone melts into the mist near its tops, so the
// silhouette is a layer of fog, not a hard contour.
uniform float soften = 0.0;
// The mist the stone fades into; haze: the share of it in the stone (the farther the card, the more).
uniform vec3 mist_color : source_color = vec3(0.07, 0.28, 0.31);
uniform float haze = 0.35;
// Heights (m) where the feet start to sink into the mist and where they are gone; the mist itself darkens over the
// same heights, down to this share (the bright mist hangs up high; deep down the abyss is dark, so the violet that
// rises there keeps its colour).
uniform vec2 sink = vec2(-14.0, -32.0);
uniform float deep = 0.35;
// Width of a column of silhouettes (m), the card's seed, the share of columns with a tower, the share of gaps
// between two towers that are bridged, the share of lonely towers with a stump of a deck.
uniform float column = 9.0;
uniform float seed = 0.0;
uniform float towers = 0.6;
// The share of the other columns with a slender shaft instead (rising out of the picture), and its half width (m).
uniform float shafts = 0.5;
uniform vec2 shaft_width = vec2(0.25, 0.5);
uniform float bridged = 0.8;
uniform float stumps = 0.35;
// The towers' mean top (m) and how much it varies.
uniform vec2 top = vec2(-7.0, 5.0);
// Half the card's width (m): no tower in the last columns, so the card's sides never show.
uniform float half_width = 150.0;
// The courses of stone (m), how much darker their joints are, how much the blocks differ in value.
uniform float course = 1.6;
uniform float joint = 0.08;
uniform float spread = 0.12;
// Painted stone (0: flat): how much a coarse mottle breaks each block and how much the stone darkens toward its
// foot (the top keeps its value), so a far tower is a gradient, not a flat silhouette.
uniform float paint = 0.0;
uniform float paint_foot = 0.45;
// The cave's roof (0, 0: none): its height (m) and how much lower it hangs to the west; where along the card it
// starts to drop and where it is at its lowest (m from the card's middle).
uniform vec2 roof = vec2(0.0);
uniform vec2 roof_fall = vec2(-10.0, -32.0);
// The mist itself, painted where no stone stands (only on the farthest card, the backdrop of the abyss: so no
// blended veil over the screen): 0 none; its mottle (darkest and lightest value), how fast it drifts, and two lighter
// patches (x = m from the card's middle, y = height, z and w = their radii) with how much lighter they are.
uniform float backdrop = 0.0;
uniform vec2 mottle = vec2(0.55, 1.5);
uniform float drift = 0.006;
uniform float mottle_fine = 0.2;
uniform vec4 patch_a = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec4 patch_b = vec4(0.0, 0.0, 1.0, 1.0);
uniform float patch_light = 0.9;

varying vec3 world;
varying float lat;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
}

// The mist's value at a place on the card: broad drifting banks and a finer mottle.
float mist_value(vec2 p) {
	float n = noise(vec2(p.x * 0.035 + TIME * drift, p.y * 0.08)) * 0.55 + noise(vec2(p.x * 0.09 - TIME * drift * 1.7, p.y * 0.2 + 7.0)) * 0.3
		+ noise(vec2(p.x * 0.3, p.y * 0.5 - TIME * drift * 3.0)) * 0.15;
	// a finer curl on top (cycle 7: no patch of the veil the size of a hand is one flat value)
	n += (noise(vec2(p.x * 0.8 + TIME * drift * 4.0, p.y * 1.3)) - 0.5) * mottle_fine;
	return mix(mottle.x, mottle.y, n);
}

// The tower of column c: x = its axis off the column's middle (m), y = its top, z = half its base width, w = 1 if
// it stands.
vec4 tower(float c) {
	float stands = step(hash1(vec2(c, seed)), towers) * step(abs((c + 0.5) * column), half_width - column * 2.0);
	float t = top.x + (hash1(vec2(c, seed + 1.7)) * 2.0 - 1.0) * top.y;
	float hw = column * mix(0.13, 0.27, hash1(vec2(c, seed + 3.1)));
	float off = (hash1(vec2(c, seed + 5.3)) - 0.5) * column * 0.25;
	return vec4(off, t, hw, stands);
}

// 1 inside the tower t of column c at x meters from its axis and height y; under: how far under the top of the block
// the point is in (for the cold edge).
float in_tower(vec4 t, float c, float x, float y, out float under) {
	float b1 = mix(2.5, 5.0, hash1(vec2(c, seed + 7.7)));
	float b2 = mix(3.0, 7.0, hash1(vec2(c, seed + 9.1))) * step(0.4, hash1(vec2(c, seed + 13.9)));
	float kind = hash1(vec2(c, seed + 11.3));
	float ty = t.y;
	if (kind > 0.67) {
		// merlons
		ty -= step(0.5, fract(x / (t.z * 0.55) + 0.25)) * 0.9;
	} else if (kind > 0.34) {
		// broken off on a slant, jagged
		float lean = hash1(vec2(c, seed + 15.1)) > 0.5 ? 1.0 : -1.0;
		ty -= (x / t.z * lean * 0.5 + 0.5) * 2.6 + noise(vec2(x * 1.5, c)) * 0.9;
	}
	float y1 = t.y - b1;
	float y2 = y1 - b2;
	float hw = y > y1 ? t.z * 0.58 : (y > y2 ? t.z * 0.78 : t.z);
	under = y > y1 ? ty - y : (y > y2 ? y1 - y : y2 - y);
	return step(abs(x), hw) * step(y, ty);
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	lat = VERTEX.x;
}

void fragment() {
	float y = world.y;
	float u = lat / column;
	float c = floor(u);
	float x = (fract(u) - 0.5) * column;
	vec4 t = tower(c);
	float under = 100.0;
	float solid = 0.0;
	if (t.w > 0.5) {
		solid = in_tower(t, c, x - t.x, y, under);
	} else if (hash1(vec2(c, seed + 41.0)) < shafts && abs((c + 0.5) * column) < half_width - column * 2.0) {
		// a slender shaft with a collar now and then
		float sw = mix(shaft_width.x, shaft_width.y, hash1(vec2(c, seed + 43.0)));
		float collar = step(fract(y / 7.0 + hash1(vec2(c, seed + 45.0))), 0.07);
		solid = step(abs(x - t.x), sw * (1.0 + 0.6 * collar));
	}
	// what joins this tower and its neighbour on this side
	float side = x - t.x > 0.0 ? 1.0 : -1.0;
	float cn = c + side;
	vec4 n = tower(cn);
	float gap = min(c, cn);
	float pick = hash1(vec2(gap, seed + 21.0));
	float both = t.w * n.w;
	float one = t.w + n.w - 2.0 * both;
	if (solid < 0.5 && ((both > 0.5 && pick < bridged) || (one > 0.5 && pick < stumps))) {
		float xa = t.x + side * t.z;
		float xb = side * column + n.x - side * n.z;
		float g = abs(xb - xa);
		float xr = x - (xa + xb) * 0.5;
		float low = both > 0.5 ? min(t.y, n.y) : (t.w > 0.5 ? t.y : n.y);
		float deck = low - mix(3.0, 8.0, hash1(vec2(gap, seed + 23.0)));
		float thick = mix(1.0, 2.0, hash1(vec2(gap, seed + 25.0)));
		// a pointed arch under the deck: two arcs of radius r, their centres on the springing line
		float r = g * 0.75;
		float cx = r - g * 0.5;
		float spring = deck - thick - sqrt(r * r - cx * cx);
		float open = step(length(vec2(abs(xr) + cx, max(y - spring, 0.0))), r);
		float body = step(y, deck) * step(spring, y) * (1.0 - open) * step(abs(xr), g * 0.5);
		float jag = (noise(vec2(y * 0.9, gap + seed)) - 0.5) * 1.2;
		if (both < 0.5) {
			// a stump of the deck left on the tower that stands
			float from = t.w > 0.5 ? abs(x - xa) : abs(x - xb);
			body *= step(from + jag, g * mix(0.2, 0.4, pick / stumps));
		} else if (hash1(vec2(gap, seed + 29.0)) < 0.4) {
			// the middle fallen
			body *= step(g * 0.16, abs(xr - (pick - 0.4) * g * 0.3) + jag);
		}
		if (body > 0.5) {
			solid = 1.0;
			under = deck - y;
		}
	}
	float dark = 1.0;
	if (roof.x != 0.0) {
		// the cave's roof, lower to the west, and its stalactites
		float west = smoothstep(roof_fall.x, roof_fall.y, lat);
		float ry = roof.x - roof.y * west + (noise(vec2(lat * 0.04, seed)) - 0.5) * 7.0;
		float sw = 3.4;
		float sc = floor(lat / sw);
		float sx = fract(lat / sw) - 0.5 + (hash1(vec2(sc, seed + 33.0)) - 0.5) * 0.3;
		float len = pow(hash1(vec2(sc, seed + 31.0)), 2.0) * mix(6.0, 15.0, west);
		if (y > ry - len * max(0.0, 1.0 - abs(sx) * 2.8)) {
			solid = 1.0;
			under = 100.0;
			dark = 0.0;
		}
	}
	// courses of blocks, each a little lighter or darker, and the cold edge on the tops
	float row = floor(y / course);
	float bx = lat / (course * 1.7) + hash1(vec2(row, seed + 3.3));
	float value = 1.0 - spread + 2.0 * spread * hash1(vec2(floor(bx), row + seed));
	value *= 1.0 - joint * step(fract(y / course), 0.12);
	float mottle_stone = noise(vec2(lat * 0.9, y * 0.55) + seed) * 0.65 + noise(vec2(lat * 2.7, y * 1.6)) * 0.35;
	value *= 1.0 + paint * (mottle_stone - 0.5) * 2.0;
	value *= 1.0 - paint * paint_foot * smoothstep(0.0, 10.0, min(under, 10.0));
	vec3 col = stone_color * value;
	col = mix(col, edge_color, edge * (1.0 - soften) * (1.0 - smoothstep(0.0, edge_height, under)));
	float sunk = smoothstep(sink.x, sink.y, y);
	vec3 mist = mist_color * mist_value(vec2(lat, y)) * mix(1.0, deep, sunk);
	// mixed as painted (in the square root of the light), so a share of mist reads as that share; the cave's roof
	// (dark 0) stays near black
	float fade = max(haze, sunk) * mix(0.35, 1.0, step(0.5, dark));
	fade = mix(fade, 1.0, soften * (1.0 - smoothstep(0.0, 4.5, under)) * 0.85);
	col = mix(sqrt(col), sqrt(mist), fade);
	col *= col;
	if (solid < 0.5 && backdrop > 0.5) {
		vec2 a = (vec2(lat, y) - patch_a.xy) / patch_a.zw;
		vec2 b = (vec2(lat, y) - patch_b.xy) / patch_b.zw;
		col = mist * (1.0 + patch_light * (exp(-dot(a, a)) + exp(-dot(b, b))));
		solid = 1.0;
	}
	ALBEDO = room_air_tint(col);
	ALPHA = solid;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
