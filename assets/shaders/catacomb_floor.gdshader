shader_type spatial;
// The floor of the catacomb platforms: big flagstones of blue-grey slate laid in a hopscotch pattern (big slabs with
// small ones at their corners, some big ones split in two or three, so no joint runs straight across the hall), each
// slab its own value, tint and slight tilt, a bevel along its edge that catches the light on one side (an analytic
// normal, no screen derivatives), rounded and nicked edges, a corner missing here and there, cracks, a few red
// petals. Wet only in front of the portal and round the fire bowls. The middle stays calm so the fighters read on it;
// the medallion is carved in relief. World space, so a platform of any size takes it.
render_mode diffuse_lambert, specular_schlick_ggx;

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
// The medallion in the middle (0 = none): its radius in meters (the long points' tips); the joints under it.
uniform float ring_radius = 6.5;
uniform vec2 ring_center = vec2(0.0);
uniform float ring_glow = 0.0;
uniform float rose_turn = 0.0;
uniform float ring_joints = 0.4;
uniform vec3 gold_dark : source_color = vec3(0.478, 0.416, 0.298);
uniform vec3 gold_light : source_color = vec3(0.627, 0.541, 0.369);
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

// The medallion carved in relief (a compass rose of eight points): returns x = the dark grooves, y = the old gold
// thread in them, z = the raised stone (band and points), w = the shade across a point (-1 dark half, 1 light half).
// Also its outward normal tilt on the floor (in medallion space) through tilt.
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
	// the band between the two rings: raised, its rims bevelled
	float band = smoothstep(inner - 0.03, inner + 0.03, d) * (1.0 - smoothstep(outer - 0.03, outer + 0.03, d));
	float groove = max(line_at(d - outer, 0.08), line_at(d - inner, 0.08));
	float gold = max(line_at(d - outer, 0.035), line_at(d - inner, 0.035));
	tilt += radial * (line_at(d - outer + 0.09, 0.07) - line_at(d - inner - 0.09, 0.07)) * 0.6;
	// volutes in the band: an S of two half circles in each sixteenth
	float band_mid = (outer + inner) * 0.5;
	float step16 = 6.2831853 / 16.0;
	float a16 = (floor(ang / step16) + 0.5) * step16;
	vec2 ax = vec2(cos(a16), sin(a16));
	vec2 l = vec2(dot(q, ax) - band_mid, dot(q, vec2(-ax.y, ax.x)));
	float sr = (outer - inner) * 0.24;
	vec2 c1 = l - vec2(0.0, sr);
	vec2 c2 = l + vec2(0.0, sr);
	float s1 = line_at(length(c1) - sr, 0.03) * step(0.0, c1.x);
	float s2 = line_at(length(c2) - sr, 0.03) * step(c2.x, 0.0);
	float curl = line_at(length(c1 - vec2(-sr * 0.5, 0.0)) - sr * 0.4, 0.025) * step(c1.y, 0.0);
	curl = max(curl, line_at(length(c2 - vec2(sr * 0.5, 0.0)) - sr * 0.4, 0.025) * step(0.0, c2.y));
	groove = max(groove, max(max(s1, s2), curl) * band);
	// the eight points: each a long diamond's outer half, born on the outer ring, full: a light half and a dark half
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
	float inside = step(0.0, edge) * step(outer, u);
	groove = max(groove, step(outer, u) * line_at(edge, 0.08));
	gold = max(gold, step(outer, u) * line_at(edge, 0.035));
	groove = max(groove, inside * line_at(v, 0.02) * 0.7);
	// the ridge along the point's middle: each half leans away from it
	vec2 perp = vec2(-axis.y, axis.x);
	tilt += inside * perp * sign(v) * 0.35 * smoothstep(0.0, 0.08, edge);
	// a leaf in each gap between the points, outside the ring
	float a_gap = (floor(ang / step8) + 0.5) * step8;
	vec2 g = q - vec2(cos(a_gap), sin(a_gap)) * (outer + 0.75);
	vec2 gl = vec2(dot(g, vec2(cos(a_gap), sin(a_gap))), dot(g, vec2(-sin(a_gap), cos(a_gap))));
	float leaf = length(gl / vec2(0.4, 0.17)) - 1.0;
	groove = max(groove, line_at(leaf * 0.17, 0.035));
	// the soft rosette of eight petals in the middle
	float petal = d - 1.2 * (0.55 + 0.45 * abs(cos(ang * 4.0)));
	groove = max(groove, line_at(petal, 0.035) * 0.6 * step(d, 1.25));
	// back to floor space
	tilt = vec2(c * tilt.x + sn * tilt.y, -sn * tilt.x + c * tilt.y);
	return vec4(groove, gold, max(band, inside), inside * (v < 0.0 ? -1.0 : 1.0));
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 wp = world.xz;
	vec4 rect;
	vec2 id;
	slab(wp / unit, rect, id);
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
	vec3 c = mix(stone_a, stone_b, rnd);
	c *= mix(slab_value.x, slab_value.y, hash1(id + 9.0));
	float tint = hash1(id + 13.0);
	if (tint < tinted * 0.5) { c *= vec3(0.92, 1.0, 1.08); } else if (tint < tinted) { c *= vec3(1.08, 1.0, 0.92); }
	// the real stone's relief, shifted on each slab so no two match
	vec2 ruv = wp * rock_scale + id * 0.37;
	float rh = texture(rock_height, ruv).r;
	vec3 rn = texture(rock_normal, ruv).rgb * 2.0 - 1.0;
	c *= mix(1.0 - rock_value, 1.0 + rock_value * 0.5, smoothstep(0.2, 0.8, rh));
	// painted wash inside each slab
	float wash = fbm(wp * 0.45 + id * 3.1);
	c *= 0.78 + 0.44 * wash;
	c = mix(c, moss_color, smoothstep(0.62, 0.8, fbm(wp * 0.3 + 11.0)) * 0.3);
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
	float crack = (1.0 - smoothstep(0.0, mix(0.02, 0.008, smoothstep(0.1, 0.7, edge)), abs(cn - 0.5))) * step(hash1(id + 3.0), cracked);
	c = mix(c, crack_color, crack * 0.85);
	// big painted washes across the whole floor
	float big = fbm(wp * 0.07 + 3.0);
	c *= 0.7 + 0.6 * big;
	c = mix(c, c * vec3(0.85, 1.0, 1.08), smoothstep(0.4, 0.7, fbm(wp * 0.12 + 20.0)));
	// the calm middle: less contrast where the fight is
	float calm = 1.0 - smoothstep(calm_radius * 0.6, calm_radius, length(wp));
	vec3 mean = (stone_a + stone_b) * 0.5;
	c = mix(c, mix(mean, c, calm_contrast), calm);
	// the medallion carved in relief over the slabs
	vec2 tilt_m = vec2(0.0);
	vec4 rose = ring_radius > 0.0 ? medallion(wp - ring_center, ring_radius, tilt_m) : vec4(0.0);
	float under = ring_radius > 0.0 ? 1.0 - smoothstep(ring_radius * 0.95, ring_radius * 1.05, length(wp - ring_center)) : 0.0;
	c *= mix(1.0, 1.15 * (rose.w < 0.0 ? 0.82 : 1.0), rose.z);
	// the bevel and the joint (weaker under the medallion)
	float joint_k = mix(1.0, ring_joints, under * rose.z);
	c *= mix(1.0, mix(0.6, 1.0, smoothstep(joint_width, joint_width + bevel, edge)), joint_k);
	float joint = (1.0 - smoothstep(joint_width * 0.5, joint_width, edge)) * joint_k;
	vec3 gravel = joint_color * (0.7 + 0.9 * noise(wp * 30.0));
	c = mix(c, gravel, max(joint, gone));
	// the grooves and their thread of old gold
	c = mix(c, joint_color * 0.8, rose.x * 0.85);
	c = mix(c, mix(gold_dark, gold_light, noise(wp * 6.0)), rose.y * 0.9);
	// red petals in rare clusters, near the slabs' edges
	vec2 pc = floor(wp / 0.35);
	vec2 pf = fract(wp / 0.35) - 0.5;
	float cluster = smoothstep(0.78, 0.86, fbm(wp * 0.35 + 40.0));
	float petal_r = mix(0.08, 0.2, hash1(pc + 2.0)) / 0.35 * 0.5;
	float petal = step(length(pf - (vec2(hash1(pc), hash1(pc + 1.0)) - 0.5) * 0.5), petal_r) * step(hash1(pc + 4.0), 0.35);
	c = mix(c, petal_color, petal * cluster * (1.0 - smoothstep(0.15, 0.6, edge)) * (1.0 - joint));
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
	c *= mix(1.0, 0.8, wet);
	ALBEDO = c;
	ROUGHNESS = mix(mix(dry_roughness.x, dry_roughness.y, hash1(id + 31.0)), wet_roughness, wet);
	SPECULAR = 0.2;
	EMISSION = gold_light * rose.y * ring_glow;
	// the normal: the slab's own slight tilt, its bevel leaning out toward the joint, the medallion's relief
	vec2 lean = (vec2(hash1(id + 41.0), hash1(id + 43.0)) - 0.5) * 2.0 * tan(radians(slab_tilt));
	float b = (1.0 - smoothstep(bevel * 0.6, bevel, edge)) * (1.0 - joint) * joint_k;
	lean += out_dir * b * bevel_tilt;
	lean += tilt_m * under;
	lean += vec2(rn.x, -rn.y) * rock_relief * (1.0 - joint);
	vec3 nw = normalize(vec3(lean.x, 1.0, lean.y));
	NORMAL = normalize((VIEW_MATRIX * vec4(nw, 0.0)).xyz);
}
