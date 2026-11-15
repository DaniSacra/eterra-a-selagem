shader_type spatial;
// Old dressed stone for every built thing of the catacombs (balustrades, obelisks, the portal's facade, plinths,
// stairs, the kit's walls and pillars): world-space blocks laid in courses on the upright faces, worn slabs on the
// tops, darker joints with a little relief, grime that climbs from the foot, and a painted wash of slate and violet
// so no two blocks match. Triplanar, so any box of any size takes it without UVs.
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 stone_a : source_color = vec3(0.21, 0.22, 0.27);
uniform vec3 stone_b : source_color = vec3(0.3, 0.3, 0.35);
uniform vec3 joint_color : source_color = vec3(0.07, 0.07, 0.09);
uniform vec3 grime_color : source_color = vec3(0.07, 0.065, 0.08);
// Height of a course and length of a block, in meters.
uniform float course = 0.85;
uniform float block_len = 1.7;
uniform float joint_width = 0.045;
// World height where the grime is thickest (the floor the piece stands on), and how high it climbs.
uniform float base_y = 0.0;
uniform float grime_height = 1.2;
// Lighter worn edges on the tops.
uniform float top_light = 1.3;

varying vec3 world;
varying vec3 wnormal;

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
		p *= 2.07;
		a *= 0.5;
	}
	return s;
}

// Blocks in courses on a plane (u along, v up): distance to the nearest joint and the block's id.
vec3 blocks(vec2 uv) {
	float row = floor(uv.y / course);
	float fy = fract(uv.y / course);
	float x = uv.x / block_len + hash1(vec2(row, 1.7)) * 2.0;
	float i = floor(x);
	float jit = 0.45;
	float b0 = i + (hash1(vec2(i, row)) - 0.5) * jit;
	float b1 = i + 1.0 + (hash1(vec2(i + 1.0, row)) - 0.5) * jit;
	float id = i;
	if (x < b0) { b1 = b0; b0 = i - 1.0 + (hash1(vec2(i - 1.0, row)) - 0.5) * jit; id = i - 1.0; }
	else if (x > b1) { b0 = b1; b1 = i + 2.0 + (hash1(vec2(i + 2.0, row)) - 0.5) * jit; id = i + 1.0; }
	float dx = min(x - b0, b1 - x) * block_len;
	float dy = min(fy, 1.0 - fy) * course;
	return vec3(min(dx, dy), id, row);
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnormal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = abs(wnormal);
	vec3 s;
	float top = smoothstep(0.6, 0.85, n.y);
	if (n.y > 0.7) {
		// tops: big worn slabs
		s = blocks(world.xz * vec2(1.0, 1.0) * 0.6);
	} else if (n.x > n.z) {
		s = blocks(vec2(world.z, world.y));
	} else {
		s = blocks(vec2(world.x, world.y));
	}
	float rnd = hash1(s.yz);
	vec3 c = mix(stone_a, stone_b, rnd);
	vec2 wp = n.y > 0.7 ? world.xz : (n.x > n.z ? world.zy : world.xy);
	float wash = fbm(wp * 0.9 + s.yz * 2.3);
	c *= 0.72 + 0.56 * wash;
	// a violet cast on some blocks, a cold one on others (painted, never flat)
	c = mix(c, c * vec3(1.08, 0.95, 1.15), smoothstep(0.45, 0.8, fbm(wp * 0.25 + 4.0)));
	// chips and cracks
	float crack = 1.0 - smoothstep(0.0, 0.025, abs(fbm(wp * 2.2 + s.yz * 3.0) - 0.5));
	c = mix(c, joint_color * 1.5, crack * step(0.65, hash1(s.yz + 5.0)) * 0.8);
	// bevel: blocks darken toward their joints, the joints are deep
	float edge = s.x;
	c *= mix(0.62, 1.0, smoothstep(joint_width, joint_width + 0.09, edge));
	float joint = 1.0 - smoothstep(joint_width * 0.4, joint_width, edge);
	c = mix(c, joint_color, joint);
	// worn, lighter tops; grime climbing from the foot
	c *= mix(1.0, top_light, top);
	float grime = 1.0 - smoothstep(0.0, grime_height, world.y - base_y + (fbm(wp * 1.5) - 0.5) * 0.6);
	c = mix(c, grime_color, grime * 0.55 * (1.0 - top));
	ALBEDO = c;
	ROUGHNESS = mix(0.88, 0.97, joint);
	SPECULAR = 0.25;
	float h = smoothstep(0.0, 0.12, edge);
	NORMAL = normalize(NORMAL + vec3(dFdx(h), dFdy(h), 0.0) * -5.0);
}
