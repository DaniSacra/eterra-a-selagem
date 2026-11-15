shader_type spatial;
// The stone of the depths (the piers, arches and the tower far out in the abyss): dark shapes standing in the lighter
// teal mist, as in the picture's background. Unlit, so no light of the hall or of the sky flattens it: a dark stone in
// courses, a cold edge on the faces turned to the mist's light, its own fading into the mist with distance (each row
// behind paler than the one in front) and with depth, and violet light rising from below at the sides of the hall.
render_mode unshaded, fog_disabled, cull_back;

uniform vec3 stone_color : source_color = vec3(0.052, 0.095, 0.12);
// The tops of capitals, arches and cornices take a thin cold edge (the mist's light from above); the upright faces
// only a faint one on the side turned to the light (from the north-west, high).
uniform vec3 edge_color : source_color = vec3(0.07, 0.24, 0.3);
uniform vec3 light_dir = vec3(-0.6, 0.5, -0.4);
// The mist the stone fades into: the colour of the abyss behind it (Game.FOG, which also covers the background).
uniform vec3 mist_color : source_color = vec3(0.07, 0.28, 0.31);
// Distance from the camera (m) where the fading starts and where it reaches `fade_max`.
uniform float fade_near = 70.0;
uniform float fade_far = 115.0;
uniform float fade_max = 0.8;
// Height (m) under which the stone sinks into the mist, and where it is gone.
uniform float sink_top = -3.0;
uniform float sink_bottom = -26.0;
// Violet from below at the sides: its colour, how high it climbs (from glow_bottom up to glow_top) and from which
// distance off the hall's middle (|x|) it starts.
uniform vec3 glow_color : source_color = vec3(0.45, 0.3, 0.95);
uniform float glow_energy = 0.25;
uniform float glow_top = -8.0;
uniform float glow_bottom = -14.0;
uniform float glow_side = 18.0;
// Courses of blocks, so the near piers are built stone and not flat paint.
uniform float course = 1.1;
uniform float block_len = 1.9;
// How much the blocks differ in value, how weathered each is (noise), the fine grit on them (amount, per meter), how
// dark the joints are.
uniform float block_spread = 1.0;
uniform float weather = 0.8;
uniform float grit = 0.5;
uniform float grit_scale = 4.0;
uniform float joint_dark = 0.75;

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

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnormal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = abs(wnormal);
	vec2 uv = n.y > 0.7 ? world.xz : (n.x > n.z ? world.zy : world.xy);
	float row = floor(uv.y / course);
	float bx = uv.x / block_len + hash1(vec2(row, 3.1));
	float id = hash1(vec2(floor(bx), row));
	float joint = max(1.0 - smoothstep(0.0, 0.05, min(fract(uv.y / course), 1.0 - fract(uv.y / course)) * course),
		1.0 - smoothstep(0.0, 0.05, min(fract(bx), 1.0 - fract(bx)) * block_len));
	vec3 c = stone_color * (1.0 - block_spread * 0.5 + block_spread * id) * (1.0 - weather * 0.5 + weather * noise(uv * 1.3)) * (1.0 - grit * 0.5 + grit * noise(uv * grit_scale + 17.0));
	// the cold edge of the mist's light on the faces turned to it, stronger up high
	float lit = clamp(dot(wnormal, normalize(light_dir)), 0.0, 1.0) * (1.0 - smoothstep(0.3, 0.6, wnormal.y));
	float top = smoothstep(0.6, 0.9, wnormal.y);
	c = mix(c, edge_color * (0.7 + 0.3 * id), max(top * 0.85, lit * 0.45) * smoothstep(-10.0, 8.0, world.y));
	c *= 1.0 - joint * joint_dark;
	float dist = length(world - CAMERA_POSITION_WORLD);
	float fade = smoothstep(fade_near, fade_far, dist) * fade_max;
	fade = max(fade, smoothstep(sink_top, sink_bottom, world.y));
	c = mix(c, mist_color, fade);
	float side = smoothstep(glow_side - 4.0, glow_side + 4.0, abs(world.x));
	float rise = smoothstep(glow_top, glow_bottom, world.y);
	c += glow_color * glow_energy * rise * rise * side * (0.7 + 0.3 * lit) * (1.0 - top);
	ALBEDO = c;
}
