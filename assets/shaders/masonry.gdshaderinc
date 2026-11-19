// The body of the dressed stone (masonry.gdshader; with PAINT defined, the stylized look's twin masonry_paint.gdshader:
// warm painted stone, the brush, a light lip on each block's top, drawn joints, little rock relief, and the painted
// light of paint.gdshaderinc).
#ifdef PAINT
#include "res://assets/shaders/paint.gdshaderinc"
#endif

uniform vec3 stone_a : source_color = vec3(0.21, 0.22, 0.27);
uniform vec3 stone_b : source_color = vec3(0.3, 0.3, 0.35);
uniform vec3 joint_color : source_color = vec3(0.07, 0.07, 0.09);
uniform vec3 grime_color : source_color = vec3(0.07, 0.065, 0.08);
// Height of a course and length of a block, in meters; course_var moves each course's joints up or down (a share of
// the course: courses from course * (1 - 2 var) to course * (1 + 2 var)), block_var the blocks' joints (lengths from
// block_len * (1 - var) to block_len * (1 + var)).
uniform float course = 0.85;
uniform float course_var = 0.0;
uniform float block_len = 1.7;
uniform float block_var = 0.45;
uniform float joint_width = 0.045;
// A share of the blocks has one corner knocked off (a dark rounded chip of chip_size meters, min to max).
uniform float chipped = 0.25;
uniform vec2 chip_size = vec2(0.08, 0.2);
// World height where the grime is thickest (the floor the piece stands on), and how high it climbs.
uniform float base_y = 0.0;
uniform float grime_height = 1.2;
// Lighter worn edges on the tops; the bevels turned up catch more (bevel_light), the upright bevels on the side of
// the light a little (side_light; light_from: where the light comes from, on the floor).
uniform float top_light = 1.3;
uniform float bevel_light = 1.45;
uniform float side_light = 1.15;
uniform vec2 light_from = vec2(0.5, -0.85);
// Relief of real stone (CC0 rock surface): its normal and height, repeats per meter, normal strength, how much its
// hollows darken the colour.
uniform sampler2D rock_normal : filter_linear_mipmap, repeat_enable;
uniform sampler2D rock_height : filter_linear_mipmap, repeat_enable;
uniform float rock_scale = 0.5;
uniform float rock_relief = 0.45;
uniform float rock_value = 0.35;
// Upright cracks on the upright faces (the standing stones): share of the columns that crack, the crack's length (m).
uniform float upright_cracks = 0.0;
uniform float upright_crack_length = 1.5;
// What is left of the value in the joints and chips (cavities).
uniform float cavity = 0.35;
// Carved pieces (the statues) paint their own shading in the mesh's vertex colour: the value is the red channel
// times this (0: the vertex colour is ignored, as on every built block).
uniform float vertex_shade = 0.0;
// How dark the fine cracks on the cracked blocks are (a carved statue keeps only a trace of them).
uniform float cracks = 0.8;
// A tall piece the paladin can walk behind (cycle 9, the obelisks: Masonry.obelisk sets see_through 1): where its stone
// stands between the eye and him, a round hole is stippled out of it around him (see_radius m at his distance, round
// his middle see_height m over his feet), keeping see_keep of the stone in its middle, so he reads behind the stone
// and never on top of it. Only for the camera's own view (the shadows keep the whole stone).
// (hero_pos and boss_pos: see_through.gdshaderinc)
uniform float see_through = 0.0;
uniform float see_radius = 2.2;
uniform float see_height = 1.3;
uniform float see_keep = 0.1;
// Stone nearer the eye than him by less than this (m) is left whole (he brushes against it, he is not behind it).
uniform float see_gap = 0.4;

#ifdef PAINT
// The stylized look (stylized_spec 4.3): the rock relief and its value as a share of the classic material's, the chance
// of a chipped block as a share too; each block's value range and hue swing (degrees); one block in olive_share pulls
// to the olive; the light lip on the top of each block (its width in m, its value, its warm hue turn); the joints and
// cracks at this share of the block's value, a little cold; a material that keeps its own colour (wood: 1).
uniform float paint_rock = 0.34;
uniform float paint_chips = 1.6;
uniform vec2 block_value = vec2(0.85, 1.12);
uniform float block_hue = 5.0;
uniform float olive_share = 0.125;
uniform float lip_width = 0.055;
uniform float lip_value = 1.35;
uniform float lip_hue = 4.0;
uniform float joint_value = 0.35;
uniform vec3 joint_cold : source_color = vec3(0.93, 0.96, 1.05);
uniform float paint_keep = 0.0;
// STY-10 (art review: the crates read as toys): the wood that keeps its colour, pulled toward its grey and a step
// darker, and its planks' light lip at a share of the stone's.
uniform float wood_saturation = 0.5;
uniform float wood_value = 0.8;
uniform float wood_lip = 0.35;
#endif

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

// The course's edge k (its joint's height in courses), moved up or down by course_var.
float course_edge(float k) {
	return k + (hash1(vec2(k, 0.37)) - 0.5) * 2.0 * course_var;
}

// Blocks in courses on a plane (u along, v up): distance to the nearest joint, the block's id and row, and the
// distance to the block's chipped corner (big if it has none).
vec4 blocks(vec2 uv, out float to_top) {
	float y = uv.y / course;
	float k = floor(y);
	float row = k;
	if (y < course_edge(k)) { row = k - 1.0; } else if (y > course_edge(k + 1.0)) { row = k + 1.0; }
	float y0 = course_edge(row);
	float y1 = course_edge(row + 1.0);
	float x = uv.x / block_len + hash1(vec2(row, 1.7)) * 2.0;
	float i = floor(x);
	float jit = block_var;
	float b0 = i + (hash1(vec2(i, row)) - 0.5) * jit;
	float b1 = i + 1.0 + (hash1(vec2(i + 1.0, row)) - 0.5) * jit;
	float id = i;
	if (x < b0) { b1 = b0; b0 = i - 1.0 + (hash1(vec2(i - 1.0, row)) - 0.5) * jit; id = i - 1.0; }
	else if (x > b1) { b0 = b1; b1 = i + 2.0 + (hash1(vec2(i + 2.0, row)) - 0.5) * jit; id = i + 1.0; }
	float dl = (x - b0) * block_len;
	float dr = (b1 - x) * block_len;
	float db = (y - y0) * course;
	float dt = (y1 - y) * course;
	float d = min(min(dl, dr), min(db, dt));
	// the chipped corner: one of the four, picked by the block
	float chip = 99.0;
	float h = hash1(vec2(id, row) + 17.0);
#ifdef PAINT
	if (h < chipped * paint_chips) {
#else
	if (h < chipped) {
#endif
		float corner = floor(hash1(vec2(id, row) + 23.0) * 4.0);
		vec2 to = vec2(mod(corner, 2.0) < 0.5 ? dl : dr, corner < 2.0 ? db : dt);
		float size = mix(chip_size.x, chip_size.y, hash1(vec2(id, row) + 29.0));
		chip = length(to) - size;
	}
	to_top = dt;
	return vec4(d, id, row, chip);
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnormal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

#include "res://assets/shaders/see_through.gdshaderinc"

void fragment() {
	if (see_through_hole(VERTEX, FRAGCOORD.xy, VIEW_MATRIX, PROJECTION_MATRIX, see_through, see_radius, see_height, see_keep, see_gap)) {
		discard;
	}
	vec3 n = abs(wnormal);
	vec4 s;
	float to_top;
	float top = smoothstep(0.6, 0.85, n.y);
	if (n.y > 0.7) {
		// tops: big worn slabs
		s = blocks(world.xz * 0.6, to_top);
	} else if (n.x > n.z) {
		s = blocks(vec2(world.z, world.y), to_top);
	} else {
		s = blocks(vec2(world.x, world.y), to_top);
	}
	float rnd = hash1(s.yz);
#ifdef PAINT
	vec3 c = mix(stone_a, stone_b, rnd);
	if (paint_keep < 0.5) {
		c = paint_recolor(c);
	} else {
		c = mix(vec3(paint_luma(c)), c, wood_saturation) * wood_value;
	}
	// each block its own value and hue, one in eight toward the olive
	c *= mix(block_value.x, block_value.y, hash1(s.yz + 41.0));
	c = paint_hue(c, (hash1(s.yz + 43.0) - 0.5) * 2.0 * block_hue);
	if (hash1(s.yz + 47.0) < olive_share) {
		c = paint_olive(c);
	}
	float rock_value_ = rock_value * paint_rock;
	float rock_relief_ = rock_relief * paint_rock;
#else
	vec3 c = mix(stone_a, stone_b, rnd);
	float rock_value_ = rock_value;
	float rock_relief_ = rock_relief;
#endif
	vec2 wp = n.y > 0.7 ? world.xz : (n.x > n.z ? world.zy : world.xy);
	vec3 tu = n.y > 0.7 ? vec3(1.0, 0.0, 0.0) : (n.x > n.z ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0));
	vec3 tv = n.y > 0.7 ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
	vec2 ruv = wp * rock_scale + s.yz * 0.31;
	float rh = texture(rock_height, ruv).r;
	// the normal is stored in two channels (BC5, compress/normal_map): its z is rebuilt
	vec2 rxy = texture(rock_normal, ruv).rg * 2.0 - 1.0;
	vec3 rn = vec3(rxy, sqrt(max(1.0 - dot(rxy, rxy), 0.0)));
	c *= mix(1.0 - rock_value_, 1.0 + rock_value_ * 0.5, smoothstep(0.2, 0.8, rh));
#ifdef PAINT
	// the brush, along the course (on the tops along x), and the hollows a share of the block, a little cold
	c = paint_brushed(c, wp + s.yz * 1.7, vec2(1.0, 0.0));
	vec3 hollow_c = c * joint_value * joint_cold;
	float crack = 1.0 - smoothstep(0.0, 0.012, abs(fbm(wp * 2.2 + s.yz * 3.0) - 0.5));
	c = mix(c, hollow_c, crack * step(0.65, hash1(s.yz + 5.0)) * cracks);
#else
	float wash = fbm(wp * 0.9 + s.yz * 2.3);
	c *= 0.72 + 0.56 * wash;
	// a violet cast on some blocks, a cold one on others (painted, never flat)
	c = mix(c, c * vec3(1.08, 0.95, 1.15), smoothstep(0.45, 0.8, fbm(wp * 0.25 + 4.0)));
	// chips and cracks
	float crack = 1.0 - smoothstep(0.0, 0.025, abs(fbm(wp * 2.2 + s.yz * 3.0) - 0.5));
	c = mix(c, joint_color * 1.5, crack * step(0.65, hash1(s.yz + 5.0)) * cracks);
#endif
	// upright cracks on the upright faces, a few columns, each one course long
	if (upright_cracks > 0.0 && n.y < 0.5) {
		float cu = wp.x * 1.4 + (noise(wp * 3.0) - 0.5) * 0.35;
		float seg = floor((world.y - base_y) / upright_crack_length);
		float on = step(hash1(vec2(floor(cu), seg) + 51.0), upright_cracks);
		float line = 1.0 - smoothstep(0.0, 0.035, abs(fract(cu) - 0.5));
#ifdef PAINT
		c = mix(c, hollow_c, line * on * 0.9);
#else
		c = mix(c, joint_color, line * on * 0.9);
#endif
	}
	// bevel: blocks darken toward their joints, the joints are deep; small nicks along the joints
	float edge = s.x - (fbm(wp * 6.0 + s.yz) - 0.5) * 0.05;
	c *= mix(0.62, 1.0, smoothstep(joint_width, joint_width + 0.09, edge));
	float joint = 1.0 - smoothstep(joint_width * 0.4, joint_width, edge);
	float chip = 1.0 - smoothstep(-0.015, 0.015, s.w + (noise(wp * 9.0) - 0.5) * 0.04);
	float hollow = max(joint, chip);
	// the chip's lit lip (its upper rim catches the light)
	c *= 1.0 + 0.35 * (1.0 - smoothstep(0.0, 0.04, abs(s.w - 0.02))) * (1.0 - chip);
#ifdef PAINT
	// the light lip along the top of each block on the upright faces, chipped where the block is
	float lip = (1.0 - smoothstep(lip_width * 0.75, lip_width, to_top)) * step(n.y, 0.5) * (1.0 - hollow);
	lip *= mix(1.0, wood_lip, step(0.5, paint_keep));
	c = mix(c, paint_hue(c * lip_value, lip_hue), lip);
	c = mix(c, hollow_c, hollow);
#else
	c = mix(c, min(c * cavity, joint_color), hollow);
#endif
	// worn, lighter tops; the bevels turned up lighter still, the upright ones on the light's side a little
	c *= mix(1.0, top_light, top);
	float up_bevel = smoothstep(0.45, 0.6, wnormal.y) * (1.0 - smoothstep(0.8, 0.9, wnormal.y));
	c *= mix(1.0, bevel_light, up_bevel);
	float side_bevel = step(0.45, min(n.x, n.z)) * step(n.y, 0.3) * step(0.0, dot(wnormal.xz, normalize(light_from)));
	c *= mix(1.0, side_light, side_bevel);
	float grime = 1.0 - smoothstep(0.0, grime_height, world.y - base_y + (fbm(wp * 1.5) - 0.5) * 0.6);
#ifdef PAINT
	c = mix(c, c * 0.6, grime * 0.55 * (1.0 - top));
#else
	c = mix(c, grime_color, grime * 0.55 * (1.0 - top));
#endif
	if (vertex_shade > 0.0) {
		c *= COLOR.r * vertex_shade;
	}
	ALBEDO = c;
#ifdef PAINT
	ROUGHNESS = mix(0.92, 0.98, hollow);
	SPECULAR = 0.15;
#else
	ROUGHNESS = mix(0.88, 0.97, hollow);
	SPECULAR = 0.25;
#endif
	vec3 nw = normalize(wnormal + (tu * rn.x - tv * rn.y) * rock_relief_ * (1.0 - hollow));
	NORMAL = normalize((VIEW_MATRIX * vec4(nw, 0.0)).xyz);
}
