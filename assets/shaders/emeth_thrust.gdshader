shader_type spatial;
// A thrust of the sword (Fx.thrust; vfx_pass_spec.md V-04: a blade, never a neon tube): a blade's profile, as wide as
// the blow reaches at its base and tip_width of that at its point, with a hard ivory-mint edge of edge_px pixels on
// both sides, a dark emerald middle (core_value of the edge) and dark ink under it (ink_alpha), so it reads as cut
// light over the floor, not a lit tube. The light runs in from the base to the point in `sweep` of its life and leaves
// from the base to the point over the last `leave` of it (the tail goes first). The Omega (omega = 1, the held thrust)
// keeps the two veins of old gold of Emeth along its edges and a broader paler edge. Laid over what is behind
// (premultiplied) under `peak` (Fx: ScreenTone.linear_peak of its edge, 226 on the screen).
// UV.y runs along the thrust (0 at the paladin, 1 at the tip), UV.x across it. t goes 0 -> 1 over its life.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(0.3, 1.0, 0.45, 1.0);
uniform float t = 0.0;
uniform float sweep = 0.3;
uniform float leave = 0.75;
uniform float intensity = 1.7;
uniform float tip_width = 0.15;
// The blade's base as a share of the quad (the width the blow reaches): drawn whole it read as a green sheet.
uniform float blade_share = 0.4;
uniform float edge_px = 2.0;
uniform float edge_pale = 0.45;
uniform float core_value = 0.55;
// the dark emerald middle's light (of the edge's): low, the edge is the light of the blade
uniform float core_light = 0.12;
uniform float ink_alpha = 0.4;
uniform vec4 ink : source_color = vec4(0.02, 0.03, 0.03, 1.0);
uniform float peak = 0.6;
// kept for the callers (Fx sets them): the old thread's look
uniform float thread = 0.16;
uniform float sheath = 0.3;
uniform float core = 0.4;
uniform float omega = 0.0;
uniform float omega_thread = 1.6;
uniform float omega_core = 0.7;
uniform vec3 gold : source_color = vec3(0.95, 0.72, 0.3);
uniform float vein_at = 0.62;
uniform float vein_gain = 0.7;
// The Onda de Luz's path (Fx.thrust band = true): a blade of light, not a bar. A thin near-white HDR core down the middle
// (band_hdr: past the world glow threshold, so it blooms), a body of saturated colour thickest at the core and thinning to
// the edge, a gold-green rim that fades out, a brighter pointed head, and a tail that breaks into streaks and fades.
uniform float band_mode = 0.0;
uniform float band_hdr = 3.2;
uniform float band_body = 0.9;
uniform vec3 band_gold : source_color = vec3(0.95, 0.85, 0.35);

float bhash(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

void fragment() {
	float along = UV.y;
	float side = abs(UV.x * 2.0 - 1.0);
	float head = clamp(t / max(sweep, 0.001), 0.0, 1.0);
	if (along > head) discard;
	float gone = clamp((t - (1.0 - leave)) / max(leave, 0.001), 0.0, 1.0);
	if (along < gone) discard;
	// the blade: full at the base, tapering to tip_width, the last 15% to a point
	float width = blade_share * mix(1.0, tip_width, along) * (1.0 - smoothstep(0.85, 1.0, along / max(head, 0.001)) * 0.85);
	width *= smoothstep(0.0, 0.04, along);
	if (side > width) discard;
	if (band_mode > 0.5) {
		float s = side / max(width, 0.001);
		float r = along / max(head, 0.001);
		// the tail: from the base up to gone + 0.4 of the length the body breaks into streaks along the flight
		float behind = clamp((along - gone) / 0.4, 0.0, 1.0);
		float lane = floor(UV.x * 18.0 + 3.0);
		float keep = smoothstep(bhash(lane) * 0.9, bhash(lane) * 0.9 + 0.1, behind);
		float fade_b = 1.0 - smoothstep(0.6, 1.0, gone);
		vec3 h = color.rgb / max(max(color.r, max(color.g, color.b)), 0.0001);
		float tip = smoothstep(0.55, 1.0, r);
		float core_w = 0.07 + 0.05 * tip;
		float core_i = exp(-pow(s / core_w, 2.0));
		float body_i = pow(1.0 - s, 1.3);
		float rim = (1.0 - smoothstep(0.0, 0.18, abs(s - 0.82))) * (1.0 - s * 0.4);
		vec3 body = mix(h, band_gold, 0.25) * body_i * band_body * (0.8 + 0.6 * tip);
		vec3 rimc = mix(h, band_gold, 0.55) * rim * 0.9;
		vec3 coreg = mix(vec3(1.0), h, 0.12) * core_i * band_hdr * (1.0 + 0.8 * tip);
		float vis = keep * fade_b;
		vec3 lit = (body * 1.5 + rimc + coreg) * vis;
		float cov = clamp(body_i * 0.92 + rim * 0.5 + core_i, 0.0, 1.0) * vis;
		ALBEDO = lit;
		ALPHA = cov;
	} else {
	// the edge in pixels on both sides
	float px = fwidth(UV.x * 2.0);
	float ew = edge_px * mix(1.0, 1.6, omega) * px;
	float edge = 1.0 - smoothstep(ew * 0.5, ew, width - side);
	float vein = (1.0 - smoothstep(0.0, 0.07, abs(side / max(width, 0.001) - vein_at))) * omega * vein_gain;
	float fade = 1.0 - smoothstep(0.6, 1.0, gone);
	vec3 hue = color.rgb / max(max(color.r, max(color.g, color.b)), 0.0001);
	vec3 rim = mix(hue, vec3(1.0), mix(edge_pale, 0.65, omega));
	vec3 light = rim * edge * intensity * 0.5 + hue * core_value * core_light * (1.0 - edge) * smoothstep(0.0, 0.5, 1.0 - side / max(width, 0.001)) + gold * vein * 0.6;
	light *= fade;
	float top = max(light.r, max(light.g, light.b));
	light *= min(1.0, peak / max(top, 0.0001));
	float ink_a = ink_alpha * (1.0 - edge) * fade;
	ALBEDO = ink.rgb * ink_a + light;
	ALPHA = clamp(ink_a + min(top, peak) / max(peak, 0.0001), 0.0, 1.0);
	}
}
