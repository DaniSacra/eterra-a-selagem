shader_type spatial;
// The glint of a finisher: the blade gathers light before the blow. A thin cross of four points (the upright one
// longer), one very long diagonal streak through it and a thin ring around it, growing while the swing holds
// (life 0 -> hold), then bursting when the blow lands (hold -> 1): the cross stretches, the ring opens a little and
// everything fades. Drawn on a quad that always faces the camera, centred on the tip of the sword; p runs -1..1
// across it (size meters).
// C12d (VX-02): the glint never covers the paladin. The ring is measured in meters (ring_m, at most ring_m +
// ring_burst_m when it bursts: under 0.6 of his height across), the middle of the cross is hollow (hollow_m: no ball
// of light, the blade shows through it), and over his body (hero_pos, a column body_half_m wide and body_height_m
// tall, seen from the camera) every part of it keeps only over_body of its light.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled, fog_disabled;

uniform vec4 color : source_color = vec4(0.85, 0.82, 1.0, 1.0);
uniform float life = 0.0;
// Share of the life spent holding (the rest is the burst).
uniform float hold = 0.6;
uniform float size = 12.0;
uniform float intensity = 1.6;
// The most the parts add up to at any point (before the intensity).
uniform float max_light = 1.2;
// Angle of the long streak, radians from the screen's horizontal.
uniform float streak_angle = 0.35;
// The ring's radius in meters while it holds, and how much it opens when the blow lands.
uniform float ring_m = 0.5;
uniform float ring_burst_m = 0.3;
// Reach of the cross and the streak in units of the half quad (1 = its edge).
uniform float spike_long = 0.3;
uniform float spike_short = 0.12;
uniform float streak_length = 1.0;
// The hollow middle of the cross, in meters (nothing of the glint inside it but a faint halo).
uniform float hollow_m = 0.14;
// The paladin's body as the camera sees it: a column this wide (half, m) and tall over hero_pos; the glint keeps
// over_body of its light there, fading in over body_soft_m around it.
global uniform vec3 hero_pos;
uniform float body_half_m = 0.5;
uniform float body_height_m = 2.8;
uniform float body_soft_m = 0.25;
uniform float over_body = 0.2;

varying vec3 hero_feet;
varying vec3 hero_head;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	VERTEX *= size;
	hero_feet = (VIEW_MATRIX * vec4(hero_pos, 1.0)).xyz;
	hero_head = (VIEW_MATRIX * vec4(hero_pos + vec3(0.0, body_height_m, 0.0), 1.0)).xyz;
}

// A thin pointed ray along the axis: bright at the centre, tapering to nothing at len.
float spike(float along, float across, float len, float width) {
	float k = clamp(abs(along) / max(len, 0.001), 0.0, 1.0);
	float w = width * (1.0 - k) * (1.0 - k);
	return (1.0 - smoothstep(0.0, max(w, 0.0005), abs(across))) * step(k, 0.999);
}

// How much of the glint shows at this view-space point: over_body over the paladin's body, all of it away from it.
// Compared on the screen (x and y over the depth), so it holds for any camera.
float clear_of_body(vec3 v) {
	vec2 at = v.xy / max(-v.z, 0.01);
	vec2 a = hero_feet.xy / max(-hero_feet.z, 0.01);
	vec2 b = hero_head.xy / max(-hero_head.z, 0.01);
	vec2 ab = b - a;
	float h = clamp(dot(at - a, ab) / max(dot(ab, ab), 1e-8), 0.0, 1.0);
	float d = length(at - (a + ab * h));
	float per_m = 1.0 / max(-mix(hero_feet.z, hero_head.z, h), 0.01);
	return mix(over_body, 1.0, smoothstep(body_half_m * per_m, (body_half_m + body_soft_m) * per_m, d));
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float half_m = size * 0.5;
	float charge = smoothstep(0.0, 1.0, clamp(life / max(hold, 0.001), 0.0, 1.0));
	float burst = clamp((life - hold) / max(1.0 - hold, 0.001), 0.0, 1.0);
	// grows during the hold, stretches out when the blow lands
	float grow = mix(0.25, 1.0, charge) * (1.0 + burst * 0.6);
	// a quick pulse while it gathers, a white flash at the instant of the blow
	float pulse = 0.85 + 0.15 * sin(life * 70.0);
	float flash = burst > 0.0 ? (1.0 - smoothstep(0.0, 0.35, burst)) * 0.2 : 0.0;
	float fade = 1.0 - smoothstep(0.0, 0.75, burst);

	// (hairlines: at 13 m across, a wider spike is a ball of white over the paladin and whoever he strikes)
	float cross = spike(p.y, p.x, spike_long * grow, 0.016) + spike(p.x, p.y, spike_short * grow, 0.013);
	float c = cos(streak_angle);
	float s = sin(streak_angle);
	vec2 q = vec2(c * p.x + s * p.y, -s * p.x + c * p.y);
	float streak = spike(q.x, q.y, streak_length * mix(0.35, 1.0, charge) * (1.0 + burst * 0.3), 0.008);
	float r_m = length(p) * half_m;
	float ring_r = ring_m * mix(0.6, 1.0, charge) + burst * ring_burst_m;
	float ring_w = 0.04 + burst * 0.03;
	float ring = (1.0 - smoothstep(0.0, ring_w, abs(r_m - ring_r))) * (1.0 - burst);
	// the hollow middle: the lines start hollow_m out, a faint halo is all that is left inside
	float open = smoothstep(hollow_m * 0.6, hollow_m, r_m);
	float halo = (1.0 - smoothstep(0.0, 0.3 * grow, length(p))) * 0.05;
	// a soft smear of light along the streak
	float smear = exp(-q.y * q.y * 2500.0) * (1.0 - smoothstep(0.0, 0.8, abs(q.x))) * 0.2;

	float v = min((cross * 1.2 + streak * 0.9 + smear) * open + ring * 0.9 + halo, max_light) * pulse * (1.0 + flash) * fade;
	v *= clear_of_body(VERTEX);
	// the blow's colour, pale but never white: the paladin behind it must still read
	vec3 tint = mix(color.rgb, vec3(1.0), 0.35);
	ALBEDO = tint * v * intensity * mix(0.5, 1.0, charge);
}
