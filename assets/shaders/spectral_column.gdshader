shader_type spatial;
// The column of spectral fire that rises out of one of Morvath's ritual circles when it lands (cycle 9): an open
// cylinder of tongues licking upward, violet at the foot, his corrupted emerald in the body, spectral blue at the
// tips. `life` (0 to 1) shoots it up, holds it a moment and thins it away. Added light, below the glow threshold
// but for the hot foot of the blow. Cycle 10 (ART-006): the corrupted emerald is cold and dark (BossShield.COLOR),
// never the Emeth's mint. BossShield raises a faint one around the ritual's shield (its curtain).
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec3 color : source_color = vec3(0.315, 0.7, 0.604);
uniform vec3 foot : source_color = vec3(0.4, 0.12, 0.8);
uniform vec3 tip : source_color = vec3(0.3, 0.55, 1.0);
uniform float life = 0.0;
// The mesh's own height (Ground draws a cylinder 1 high and scales it) and how bright the column is.
uniform float height_m = 1.0;
uniform float strength = 1.0;
// Share of its life spent shooting up, and where it starts fading.
uniform float rise = 0.16;
uniform float fade_from = 0.3;
// Tongues around the column, and how fast they climb (cycles a second).
uniform float tongues = 5.0;
uniform float climb = 2.6;
uniform float seed = 0.0;

varying vec3 local;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), u.x), u.y);
}

void vertex() {
	local = VERTEX;
}

void fragment() {
	float t = clamp(local.y / height_m + 0.5, 0.0, 1.0);
	float a = atan(local.z, local.x) / 6.2831853 + 0.5;
	float reach = smoothstep(0.0, rise, life);
	// tongues: noise climbing up the column, wrapped around it, thinning toward the top
	float n = noise(vec2(a * tongues + seed, t * 3.0 - TIME * climb)) * 0.65 + noise(vec2(a * tongues * 2.3 - seed, t * 7.0 - TIME * climb * 1.8)) * 0.35;
	float body = smoothstep(t * 0.75, t * 0.75 + 0.3, n);
	// soft sides: the column is denser where it faces the eye
	float facing = abs(dot(normalize(NORMAL), normalize(VIEW)));
	float soft = mix(0.35, 1.0, facing);
	float top = 1.0 - smoothstep(reach * 0.55, reach, t);
	float fade = 1.0 - smoothstep(fade_from, 1.0, life);
	vec3 c = mix(foot, color, smoothstep(0.0, 0.25, t));
	c = mix(c, tip, smoothstep(0.5, 0.95, t));
	// the hot foot where it breaks the floor, only while it rises
	float hot = (1.0 - smoothstep(0.0, 0.12, t)) * (1.0 - smoothstep(0.0, 0.4, life)) * 0.35;
	ALBEDO = c * (body * soft * 0.85 + hot) * top * fade * strength;
}
