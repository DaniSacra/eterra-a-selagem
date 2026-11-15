shader_type spatial;
// The floor of the catacomb platforms: big irregular flagstones of blue-grey slate, painted by hand (flat shades
// per stone, a darker bevel at each edge, deep joints, cracks and worn spots), in world space so a platform of any
// size and shape takes it. The middle stays dark and calm so the fighters read on it; an engraved ring marks it.
render_mode diffuse_lambert, specular_schlick_ggx;

uniform vec3 stone_a : source_color = vec3(0.29, 0.25, 0.28);
uniform vec3 stone_b : source_color = vec3(0.42, 0.37, 0.39);
uniform vec3 joint_color : source_color = vec3(0.025, 0.03, 0.045);
uniform vec3 crack_color : source_color = vec3(0.05, 0.055, 0.07);
uniform vec3 moss_color : source_color = vec3(0.12, 0.2, 0.2);
uniform vec3 engrave_color : source_color = vec3(0.62, 0.46, 0.22);
// Meters between the centres of two flagstones.
uniform float stone_size = 1.9;
uniform float joint_width = 0.055;
// The calm middle: radius in meters, and how much of the stones' contrast it keeps.
uniform float calm_radius = 9.0;
uniform float calm_contrast = 0.55;
// The engraved ring in the middle (0 = none): its radius in meters.
uniform float ring_radius = 6.5;
uniform vec2 ring_center = vec2(0.0);
uniform float ring_glow = 0.0;
// A rectangle of floor (x min, z min, x max, z max) that is always wet.
uniform vec4 wet_zone = vec4(0.0);

varying vec3 world;

vec2 hash2(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return fract(sin(p) * 43758.5453);
}

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

// Big flagstones, almost square, laid in rows of uneven depth: each row its own depth (0.8 to 1.25 units), each
// stone its own length (0.8 to 1.7), the joints of one row never lining up with the next. p in stone units.
// Returns (distance to the nearest joint in units, stone id, row).
vec3 stones(vec2 p) {
	// rows: the boundary of row k sits at k + a jitter, so rows differ in depth
	float k = floor(p.y);
	float y0 = k + (hash1(vec2(k, 3.0)) - 0.5) * 0.35;
	float row = k;
	if (p.y < y0) { row = k - 1.0; }
	float a = row + (hash1(vec2(row, 3.0)) - 0.5) * 0.35;
	float b = row + 1.0 + (hash1(vec2(row + 1.0, 3.0)) - 0.5) * 0.35;
	float depth = b - a;
	float fy = (p.y - a) / depth;
	float len = 1.0;
	float x = p.x / len + hash1(vec2(row, 7.0)) * 3.0;
	float i = floor(x);
	float jit = 0.35;
	float b0 = i + (hash1(vec2(i, row)) - 0.5) * jit;
	float b1 = i + 1.0 + (hash1(vec2(i + 1.0, row)) - 0.5) * jit;
	float id = i;
	if (x < b0) { b1 = b0; b0 = i - 1.0 + (hash1(vec2(i - 1.0, row)) - 0.5) * jit; id = i - 1.0; }
	else if (x > b1) { b0 = b1; b1 = i + 2.0 + (hash1(vec2(i + 2.0, row)) - 0.5) * jit; id = i + 1.0; }
	float dx = min(x - b0, b1 - x) * len;
	float dy = min(fy, 1.0 - fy) * depth;
	// some big stones are split in two across (the small slabs between the big ones)
	if (hash1(vec2(id, row) + 11.0) > 0.72) {
		float mid = mix(b0, b1, 0.35 + 0.3 * hash1(vec2(id, row) + 2.0));
		dx = min(dx, abs(x - mid) * len);
		id += x < mid ? 0.5 : 0.25;
	}
	return vec3(min(dx, dy), id, row);
}

// The engraved medallion in the middle (the reference picture): a compass rose of eight points in inlaid stone, the
// long points at r (meters), the short ones on the diagonals; a double ring with sixteen little scrolls between its
// two lines, a leaf in each gap between the points outside it, a soft rosette in the middle. No straight line crosses
// the middle. Returns (engraved line 0 to 1, inside a point 0 or 1, on the point's darker half 0 or 1).
uniform float rose_turn = 0.0;

float line_at(float d, float half_width) {
	return 1.0 - smoothstep(half_width * 0.6, half_width, abs(d));
}

vec3 medallion(vec2 p, float r) {
	float c = cos(rose_turn);
	float sn = sin(rose_turn);
	p = vec2(c * p.x - sn * p.y, sn * p.x + c * p.y);
	float d = length(p);
	float ang = atan(p.y, p.x);
	float outer = r * 0.627;
	float inner = r * 0.507;
	float m = max(line_at(d - outer, 0.05), line_at(d - inner, 0.05));
	// sixteen little scrolls in the band between the two rings
	float band_mid = (outer + inner) * 0.5;
	float step16 = 6.2831853 / 16.0;
	float a16 = (floor(ang / step16) + 0.5) * step16;
	vec2 scroll = p - vec2(cos(a16), sin(a16)) * band_mid;
	float scroll_r = (outer - inner) * 0.3;
	m = max(m, line_at(length(scroll) - scroll_r, 0.03));
	// the eight points: each a long diamond's outer half, born on the outer ring
	float step8 = 0.7853982;
	float k = floor(ang / step8 + 0.5);
	float a8 = k * step8;
	vec2 axis = vec2(cos(a8), sin(a8));
	float u = dot(p, axis);
	float v = dot(p, vec2(-axis.y, axis.x));
	bool long_point = mod(k, 2.0) < 0.5;
	float tip = long_point ? r : r * 0.747;
	float half_base = long_point ? 0.7 : 0.5;
	float slope = half_base / (tip - outer);
	float edge = (half_base * (tip - u) / (tip - outer) - abs(v)) / sqrt(1.0 + slope * slope);
	float inside = step(0.0, edge) * step(outer, u);
	m = max(m, inside * (1.0 - smoothstep(0.05, 0.08, edge)));
	m = max(m, inside * line_at(v, 0.025) * 0.6);
	// a leaf in each gap between the points, outside the ring
	float a_gap = (floor(ang / step8) + 0.5) * step8;
	vec2 g = p - vec2(cos(a_gap), sin(a_gap)) * (outer + 0.75);
	vec2 gl = vec2(dot(g, vec2(cos(a_gap), sin(a_gap))), dot(g, vec2(-sin(a_gap), cos(a_gap))));
	float leaf = length(gl / vec2(0.4, 0.17)) - 1.0;
	m = max(m, line_at(leaf * 0.17, 0.03));
	// the soft rosette of eight petals in the middle
	float petal = d - 1.2 * (0.55 + 0.45 * abs(cos(ang * 4.0)));
	m = max(m, line_at(petal, 0.03) * 0.4 * step(d, 1.25));
	return vec3(m, inside, inside * step(v, 0.0));
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world.xz / stone_size;
	// a little wobble so the joints are drawn by hand, not by ruler
	p += (vec2(fbm(world.xz * 0.7), fbm(world.xz * 0.7 + 7.3)) - 0.5) * 0.06;
	vec3 s = stones(p);
	float edge = s.x * stone_size;
	float rnd = hash1(s.yz);
	vec3 c = mix(stone_a, stone_b, rnd);
	// painted wash inside each stone: soft blotches, lighter worn spots
	float wash = fbm(world.xz * 0.45 + s.yz * 3.1);
	c *= 0.7 + 0.6 * wash;
	c *= 0.85 + 0.3 * hash1(s.yz + 9.0);
	c = mix(c, moss_color, smoothstep(0.62, 0.8, fbm(world.xz * 0.3 + 11.0)) * 0.35);
	// a darker bevel along each edge, then the deep joint
	c *= mix(0.55, 1.0, smoothstep(joint_width, joint_width + 0.14, edge));
	float joint = 1.0 - smoothstep(joint_width * 0.5, joint_width, edge);
	// cracks: thin dark lines across some stones
	float cn = fbm(world.xz * 1.3 + s.yz * 5.0);
	float crack = (1.0 - smoothstep(0.0, 0.02, abs(cn - 0.5))) * step(0.72, hash1(s.yz + 3.0));
	c = mix(c, crack_color, crack * 0.85);
	// big painted washes across the whole floor, so the courses never read as a brick wall
	float big = fbm(world.xz * 0.07 + 3.0);
	c *= 0.65 + 0.7 * big;
	c = mix(c, c * vec3(0.85, 1.0, 1.08), smoothstep(0.4, 0.7, fbm(world.xz * 0.12 + 20.0)));
	// the calm middle: less contrast where the fight is
	float calm = 1.0 - smoothstep(calm_radius * 0.6, calm_radius, length(world.xz));
	vec3 mean = (stone_a + stone_b) * 0.5;
	c = mix(c, mix(mean, c, calm_contrast), calm);
	c = mix(c, joint_color, joint);
	// the engraved medallion: dark grooves with old gold in them
	vec3 rose = ring_radius > 0.0 ? medallion(world.xz - ring_center, ring_radius) : vec3(0.0);
	c *= mix(1.0, 1.12 * mix(1.0, 0.85, rose.z), rose.y);
	float ring = rose.x * (0.7 + 0.3 * fbm(world.xz * 2.0));
	c = mix(c, engrave_color * 0.6, ring * 0.8);
	// wet patches: smooth enough to mirror the fire and the portal (screen-space reflections on desktop)
	float wet = smoothstep(0.55, 0.72, fbm(world.xz * 0.16 + 31.0));
	// the wet floor in front of the portal's steps, always (it mirrors the green)
	vec2 wz = step(wet_zone.xy, world.xz) * step(world.xz, wet_zone.zw);
	wet = max(wet, wz.x * wz.y * smoothstep(0.3, 0.6, fbm(world.xz * 0.5 + 5.0)));
	c *= mix(1.0, 0.8, wet);
	ALBEDO = c;
	ROUGHNESS = mix(mix(0.82, 0.22, wet), 0.9, joint);
	SPECULAR = 0.2;
	EMISSION = engrave_color * ring * ring_glow;
}
