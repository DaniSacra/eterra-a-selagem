shader_type spatial;
// The floor of the catacomb platforms: big irregular flagstones of blue-grey slate, painted by hand (flat shades
// per stone, a darker bevel at each edge, deep joints, cracks and worn spots), in world space so a platform of any
// size and shape takes it. The middle stays dark and calm so the fighters read on it; an engraved ring marks it.
render_mode diffuse_lambert, specular_schlick_ggx;

uniform vec3 stone_a : source_color = vec3(0.15, 0.165, 0.19);
uniform vec3 stone_b : source_color = vec3(0.25, 0.25, 0.28);
uniform vec3 joint_color : source_color = vec3(0.025, 0.03, 0.045);
uniform vec3 crack_color : source_color = vec3(0.05, 0.055, 0.07);
uniform vec3 moss_color : source_color = vec3(0.12, 0.2, 0.2);
uniform vec3 engrave_color : source_color = vec3(0.55, 0.42, 0.22);
// Meters between the centres of two flagstones.
uniform float stone_size = 1.3;
uniform float joint_width = 0.025;
// The calm middle: radius in meters, and how much of the stones' contrast it keeps.
uniform float calm_radius = 9.0;
uniform float calm_contrast = 0.55;
// The engraved ring in the middle (0 = none): its radius in meters.
uniform float ring_radius = 6.5;
uniform float ring_glow = 0.0;

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

// Flagstones laid in courses (rows along x): each course its own depth, each stone its own length, the joints of
// one course never lining up with the next. p in stone units. Returns (distance to the nearest joint, stone id).
vec3 stones(vec2 p) {
	// courses of two depths: most one unit, some a unit and a half (big slabs)
	float band = floor(p.y / 2.5);
	float split = 0.9 + hash1(vec2(band, 3.0)) * 0.7;
	float ly = p.y - band * 2.5;
	float row = band * 2.0 + (ly < split ? 0.0 : 1.0);
	float fy = ly < split ? ly / split : (ly - split) / (2.5 - split);
	float depth = ly < split ? split : 2.5 - split;
	// stagger each course, and give its stones uneven lengths around 1.4 units
	float len = 1.1 + depth * 0.7;
	float x = p.x / len + hash1(vec2(row, 7.0)) * 3.0;
	float i = floor(x);
	float jit = 0.55;
	float b0 = i + (hash1(vec2(i, row)) - 0.5) * jit;
	float b1 = i + 1.0 + (hash1(vec2(i + 1.0, row)) - 0.5) * jit;
	float id = i;
	if (x < b0) {
		b1 = b0;
		b0 = i - 1.0 + (hash1(vec2(i - 1.0, row)) - 0.5) * jit;
		id = i - 1.0;
	} else if (x > b1) {
		b0 = b1;
		b1 = i + 2.0 + (hash1(vec2(i + 2.0, row)) - 0.5) * jit;
		id = i + 1.0;
	}
	float dx = min(x - b0, b1 - x) * len;
	float dy = min(fy, 1.0 - fy) * depth;
	return vec3(min(dx, dy), id, row);
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
	c *= mix(0.7, 1.0, smoothstep(joint_width, joint_width + 0.12, edge));
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
	// the engraved ring: two thin circles and eight spokes between them, a faint old gold
	float r = length(world.xz);
	float ring = 0.0;
	if (ring_radius > 0.0) {
		ring = 1.0 - smoothstep(0.03, 0.08, abs(r - ring_radius));
		ring = max(ring, 1.0 - smoothstep(0.03, 0.07, abs(r - ring_radius * 0.82)));
		float a = atan(world.z, world.x);
		float spoke = 1.0 - smoothstep(0.02, 0.06, abs(sin(a * 4.0)) * r);
		ring = max(ring, spoke * step(ring_radius * 0.82, r) * step(r, ring_radius));
		ring *= 0.75 + 0.25 * fbm(world.xz * 2.0);
	}
	c = mix(c, engrave_color * 0.45, ring * 0.7);
	ALBEDO = c;
	ROUGHNESS = mix(0.85, 0.6, joint);
	SPECULAR = 0.2;
	// relief: the stone tops bulge, the joints sink (a normal bent by the edge distance)
	float h = smoothstep(0.0, 0.2, edge);
	vec2 grad = vec2(dFdx(h), dFdy(h));
	NORMAL = normalize(NORMAL + vec3(grad.x, grad.y, 0.0) * -6.0);
	EMISSION = engrave_color * ring * ring_glow;
}
