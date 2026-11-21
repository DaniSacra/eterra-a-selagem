shader_type canvas_item;
// The leather cover of the open book (BookSpread, AP-4 1.1): a fine grain (value varies 6% at most), the leather worn
// at the corners and the middle of the edges (lighter and a little less saturated), a blind-tooled double line (a dark
// and a pale pixel each) and a row of stitches near the edge. Sizes are in the rect's own pixels at 720 lines; `unit`
// is the pixel at 1080 lines (two thirds of one), so the strokes stay the width the spec gives at 1080.

uniform vec2 size_px = vec2(1200.0, 640.0);
uniform vec3 leather : source_color = vec3(0.14, 0.1, 0.08);
uniform vec3 stitch : source_color = vec3(0.4, 0.29, 0.17);
uniform float unit = 0.6667;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	vec2 p = UV * size_px;
	vec2 q = min(p, size_px - p);
	float d = min(q.x, q.y);
	// the grain: cells of 2 to 3 px at 1080 and a finer one over it
	float g = noise(p / (2.5 * unit)) * 0.6 + hash(floor(p / (1.2 * unit))) * 0.4;
	vec3 c = leather * (1.0 + (g - 0.5) * 0.12);
	// the wear: at the four corners and the middle of each edge, 40 px at 1080
	float r = 40.0 * unit;
	float worn = 0.0;
	for (int i = 0; i < 4; i++) {
		vec2 corner = vec2(float(i % 2), float(i / 2)) * size_px;
		worn = max(worn, 1.0 - smoothstep(0.0, r, distance(p, corner)));
	}
	worn = max(worn, (1.0 - smoothstep(0.0, r, abs(p.x - size_px.x * 0.5))) * (1.0 - smoothstep(0.0, r * 0.5, q.y)));
	worn = max(worn, (1.0 - smoothstep(0.0, r, abs(p.y - size_px.y * 0.5))) * (1.0 - smoothstep(0.0, r * 0.5, q.x)));
	worn *= 0.6 + 0.4 * noise(p / (6.0 * unit));
	float lum = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(c, vec3(lum), 0.1 * worn) * (1.0 + 0.1 * worn);
	// the blind tooling: two lines at 10 and 14 px from the outer edge, each a dark pixel with a pale one beside it
	float px = unit;
	for (int i = 0; i < 2; i++) {
		float at = (10.0 + float(i) * 4.0) * unit;
		c *= 1.0 - 0.45 * (1.0 - smoothstep(0.0, px * 0.6, abs(d - at)));
		c += 0.05 * (1.0 - smoothstep(0.0, px * 0.6, abs(d - at - px)));
	}
	// the stitches: dashes of 4 px and gaps of 3 px at 1080, 6 px from the edge
	float along = (q.x < q.y) ? p.y : p.x;
	float dash = step(mod(along, 7.0 * unit), 4.0 * unit);
	float line = 1.0 - smoothstep(0.0, px * 0.7, abs(d - 6.0 * unit));
	c = mix(c, stitch, line * dash * 0.9);
	COLOR = vec4(c, 1.0);
}
