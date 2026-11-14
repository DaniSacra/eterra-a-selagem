shader_type spatial;
// The glint of a finisher: the blade gathers light before the blow. A thin cross of four points (the upright one
// longer), one very long diagonal streak through it and a thin ring around it, growing while the swing holds
// (life 0 -> hold), then bursting when the blow lands (hold -> 1): the cross stretches, the ring flies out and
// everything fades. Drawn on a quad that always faces the camera; p runs -1..1 across it.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled, fog_disabled;

uniform vec4 color : source_color = vec4(0.85, 0.82, 1.0, 1.0);
uniform float life = 0.0;
// Share of the life spent holding (the rest is the burst).
uniform float hold = 0.6;
uniform float size = 12.0;
uniform float intensity = 3.2;
// Angle of the long streak, radians from the screen's horizontal.
uniform float streak_angle = 0.35;
// Reach of each part in units of the half quad (1 = its edge).
uniform float ring_radius = 0.2;
uniform float spike_long = 0.4;
uniform float spike_short = 0.17;
uniform float streak_length = 1.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	VERTEX *= size;
}

// A thin pointed ray along the axis: bright at the centre, tapering to nothing at len.
float spike(float along, float across, float len, float width) {
	float k = clamp(abs(along) / max(len, 0.001), 0.0, 1.0);
	float w = width * (1.0 - k) * (1.0 - k);
	return (1.0 - smoothstep(0.0, max(w, 0.0005), abs(across))) * step(k, 0.999);
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float charge = smoothstep(0.0, 1.0, clamp(life / max(hold, 0.001), 0.0, 1.0));
	float burst = clamp((life - hold) / max(1.0 - hold, 0.001), 0.0, 1.0);
	// grows during the hold, stretches out when the blow lands
	float grow = mix(0.25, 1.0, charge) * (1.0 + burst * 0.6);
	// a quick pulse while it gathers, a white flash at the instant of the blow
	float pulse = 0.85 + 0.15 * sin(life * 70.0);
	float flash = burst > 0.0 ? (1.0 - smoothstep(0.0, 0.35, burst)) * 1.6 : 0.0;
	float fade = 1.0 - smoothstep(0.15, 1.0, burst);

	float cross = spike(p.y, p.x, spike_long * grow, 0.045) + spike(p.x, p.y, spike_short * grow, 0.035);
	float c = cos(streak_angle);
	float s = sin(streak_angle);
	vec2 q = vec2(c * p.x + s * p.y, -s * p.x + c * p.y);
	float streak = spike(q.x, q.y, streak_length * mix(0.35, 1.0, charge) * (1.0 + burst * 0.3), 0.012);
	float r = length(p);
	float ring_r = ring_radius * mix(0.6, 1.0, charge) + burst * 0.45;
	float ring = (1.0 - smoothstep(0.0, 0.009 + burst * 0.01, abs(r - ring_r))) * (1.0 - burst);
	float core = 1.0 - smoothstep(0.0, 0.05 * grow, r);
	float halo = (1.0 - smoothstep(0.0, 0.3 * grow, r)) * 0.12;
	// a soft smear of light along the streak
	float smear = exp(-q.y * q.y * 900.0) * (1.0 - smoothstep(0.0, 0.8, abs(q.x))) * 0.35;

	float v = (cross * 1.2 + streak * 0.9 + ring * 0.9 + core * 1.5 + halo + smear) * pulse * (1.0 + flash) * fade;
	vec3 tint = mix(color.rgb, vec3(1.0), 0.65);
	ALBEDO = tint * v * intensity * mix(0.5, 1.0, charge);
}
