shader_type spatial;
// The necromantic shield of a boss's ritual: a sphere of cold spectral green, clear in the middle (the boss reads
// through it) with a bright rim and slow veins crawling over it. Added light, below the glow threshold except the rim.
render_mode unshaded, blend_add, cull_back, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(0.38, 1.0, 0.75, 1.0);
// 0..1: grows in when the ritual starts, flares and fades when it breaks.
uniform float power = 1.0;
uniform float rim_strength = 1.4;
uniform float veins = 0.5;
uniform float fill = 0.06;

varying vec3 local;

void vertex() {
	local = VERTEX;
}

float hash(vec3 p) {
	p = fract(p * 0.3183099 + 0.1);
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise(vec3 x) {
	vec3 i = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(hash(i), hash(i + vec3(1, 0, 0)), f.x), mix(hash(i + vec3(0, 1, 0)), hash(i + vec3(1, 1, 0)), f.x), f.y),
		mix(mix(hash(i + vec3(0, 0, 1)), hash(i + vec3(1, 0, 1)), f.x), mix(hash(i + vec3(0, 1, 1)), hash(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}

void fragment() {
	float facing = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float rim = pow(1.0 - facing, 3.0);
	vec3 p = normalize(local) * 3.0 + vec3(0.0, TIME * 0.35, TIME * 0.2);
	float n = noise(p) * 0.6 + noise(p * 2.3) * 0.4;
	// thin bright lines where the noise crosses its middle: the veins
	float vein = 1.0 - smoothstep(0.0, 0.06, abs(n - 0.5));
	float pulse = 0.85 + 0.15 * sin(TIME * 3.0);
	vec3 c = color.rgb * (fill + rim * rim_strength + vein * veins * (0.3 + rim)) * pulse;
	ALBEDO = c * power;
}
