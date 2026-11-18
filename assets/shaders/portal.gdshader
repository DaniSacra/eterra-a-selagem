shader_type spatial;
// The way on to the next room: a sheet of otherworldly light deep in a doorway (green; red for Morvath, gold for a
// reward). Cycle 7: it has structure and is not a blown-out panel. AP-1 (ART-03.7): before, still a flat sheet of pure
// green (the hall's only green, a chapa with no form). Now it reads as a way going in: a dark hollow in the middle
// that recedes (rings of light drifting inward toward a small pale heart, deep and far), a lit border that hugs the
// arch's outline, and slow veins of pale light crawling inward from the border. Its green is pulled toward a deep
// dark emerald, the heart pale; under the screen's cap (no channel past `cap`). Unlit and added on top; power dims it
// while the room is not cleared. The teeth hanging from the lintel are stone, not painted.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec3 color : source_color = vec3(0.25, 1.0, 0.45);
uniform float power = 1.0;
// The sheet's size in meters.
uniform vec2 size = vec2(3.8, 4.6);
// The hollow's middle (shares of the sheet's size; the heart sits there) and the darkness of the hollow (its value).
uniform vec2 core_at = vec2(0.5, 0.36);
uniform float hollow = 0.0;
// The border: its light where it meets the arch and how far in it fades (m).
uniform float rim_light = 0.42;
uniform float rim_width = 0.55;
// The rings drifting in: how many per unit of log-distance, how fast (per second), their light, how far out they show.
uniform float ring_density = 5.0;
uniform float ring_speed = 0.35;
uniform float ring_light = 0.22;
// How much of each ring the noise breaks away (so they read as currents, not a target).
uniform float ring_break = 0.75;
// The veins crawling in from the border: how many round the heart, how fast, their light and thinness.
uniform float vein_count = 11.0;
uniform float vein_speed = 0.22;
uniform float vein_light = 0.85;
uniform float vein_thin = 0.72;
// The heart: radius (share of the sheet's height) and its value; its pale colour.
uniform float heart_radius = 0.05;
uniform float heart_light = 0.24;
uniform vec3 heart_color : source_color = vec3(0.72, 0.95, 0.82);
// Away from the heart the colour deepens: its channels raised to this power (the weak ones fall, the strong one stays)
// and dimmed toward the deep emerald.
uniform float deep = 2.2;
// The body's saturation (share of the colour kept over its grey; 1 = the plain colour) and its brightness: a dark
// emerald, not a sheet of pure green (the hall's only green, ART-03.7).
uniform float body_saturation = 0.55;
uniform float body_value = 0.8;
// The body's tint toward emerald (the red falls a little: a cold green, not lime).
uniform vec3 body_tint = vec3(0.7, 1.0, 1.05);
// No channel past this (the screen's cap through the tonemap, ScreenTone).
uniform float cap = 0.72;
// The sheet cut to a pointed arch: x = the springing's height over the sheet's foot, y = the span, z = the radius of
// the two arcs (m; their centres on the springing line). Zero span: the whole rectangle glows.
uniform vec3 arch = vec3(0.0);
// Morvath's last phase (cycle 9, ArenaKit.portal_mood): unrest 0..1 adds a faster twist to the veins, a small flicker
// and a slow violet pulse through the body (the heart keeps its colour); seal 0..1 (his sealing) draws a ring of light
// closing from the sheet's edge onto the heart. Both 0: the plain portal.
uniform float unrest = 0.0;
uniform vec3 unrest_color : source_color = vec3(0.42, 0.14, 0.9);
uniform float unrest_pulse = 0.55;
uniform float unrest_rate = 0.45;
uniform float seal = 0.0;
uniform float seal_light = 0.55;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
}

void fragment() {
	vec2 m = vec2(UV.x, 1.0 - UV.y) * size;
	vec2 n = m / size;
	// how far in from the opening's outline (m): the rectangle's sides, foot and, over the springing, the arcs
	float inside = min(min(m.x, size.x - m.x), min(m.y, size.y - m.y));
	float d = -inside;
	if (arch.y > 0.0) {
		float off = abs(m.x - size.x * 0.5);
		float cx = arch.z - arch.y * 0.5;
		d = m.y > arch.x ? length(vec2(off + cx, m.y - arch.x)) - arch.z : off - arch.y * 0.5;
		d = max(d, -m.y);
		inside = -d;
	}
	// the hollow: polar round the heart, in units of the sheet's height
	vec2 o = (n - core_at) * vec2(size.x / size.y, 1.0);
	float r = length(o) + 0.0001;
	float ang = atan(o.y, o.x);
	float lr = log(r);
	float twist = unrest * sin(lr * 3.0 + TIME * 1.7) * 0.5;
	// rings drifting inward (log-distance moving outward in time: they come toward the heart and shrink)
	float rings = pow(0.5 + 0.5 * sin((lr * ring_density + ang * 0.5 + TIME * ring_speed) * 6.2831853), 3.0);
	rings *= 1.0 - ring_break * smoothstep(0.3, 0.7, noise(vec2(ang * 2.2 + 3.0, lr * 3.0 - TIME * ring_speed * 2.0)));
	rings *= smoothstep(0.03, 0.18, r);
	// veins crawling in from the border along the angle, broken by noise
	float a = ang / 6.2831853 * vein_count + twist;
	float lane = abs(fract(a) - 0.5) * 2.0;
	float wiggle = noise(vec2(floor(a) * 7.1, lr * 2.0 + TIME * vein_speed * 3.0));
	float vein = smoothstep(vein_thin, 1.0, 1.0 - abs(lane - wiggle * 0.8 - 0.1));
	vein *= smoothstep(0.35, 0.75, noise(vec2(floor(a) * 3.3 + 1.0, lr * 1.5 + TIME * vein_speed)));
	vein *= smoothstep(0.08, 0.3, r);
	// the border: lit where the stone meets it, fading in
	float rim = 1.0 - smoothstep(0.0, rim_width, inside);
	float v = hollow + rim_light * rim + ring_light * rings + vein_light * vein * (0.5 + 0.5 * rim);
	if (unrest > 0.0) {
		v *= 1.0 + unrest * 0.3 * (noise(vec2(TIME * 5.0, 0.0)) - 0.5);
	}
	float heart = exp(-pow(r / heart_radius, 2.0));
	if (seal > 0.0) {
		// the sealing: a ring of light closing from the sheet's edge onto the heart
		vec2 so = (n - core_at) / vec2(0.55, 0.75);
		float ring = exp(-pow((length(so) - (1.0 - seal)) / 0.06, 2.0));
		v += seal_light * ring * sin(seal * 3.14159);
	}
	// the arch's cut (soft by 5 cm)
	float keep = 1.0 - smoothstep(-0.05, 0.0, d);
	// deep dark emerald in the body (the plain colour on the border's light), the pale heart over it
	vec3 body = pow(color, vec3(mix(deep, 1.0, rim * 0.6)));
	float grey = dot(body, vec3(0.3, 0.59, 0.11));
	body = mix(vec3(grey), body, mix(body_saturation, 1.0, rim * 0.4)) * body_value * body_tint;
	float throb = 0.5 + 0.5 * sin(TIME * unrest_rate * 6.2831853);
	body = mix(body, unrest_color, unrest * unrest_pulse * throb);
	vec3 col = body * v + heart_color * heart * heart_light;
	col = min(col, vec3(cap));
	ALBEDO = col * keep * power * (0.96 + 0.04 * sin(TIME * 1.3));
}
