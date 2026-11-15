shader_type canvas_item;
render_mode blend_premul_alpha;
// The air of the title screen, one pass over the whole screen on top of the painting (docs/art/title_screen_spec.md,
// section 4): three layers of drifting mist and the breathing halo of the portal. Everything is placed in pixels of
// the painting (1672 x 941), so it stays locked to the art whatever the window. Three reads of one noise texture.
// The painted bodies never move: this only adds a little colour over them, and none over the Explorer's face, the
// blade of the Emeth and the logo.

// Where the painting sits in this rectangle (its own units) and how many units one pixel of the painting takes.
uniform vec2 rect_size = vec2(1280.0, 720.0);
uniform vec2 art_origin = vec2(0.0);
uniform float art_scale = 0.7656;
uniform float time = 0.0;
// Three unrelated tiling noises, one per channel.
uniform sampler2D noise : repeat_enable, filter_linear;

const vec2 ART = vec2(1672.0, 941.0);

// N1, the low mist of the army.
uniform vec3 low_color : source_color = vec3(0.416, 0.310, 0.784);
uniform float low_alpha = 0.18;
uniform float low_speed = 8.0;
// What is left of it left of the heroes (only along the bottom) and on the bands outside the painting.
uniform float low_left_alpha = 0.06;
uniform float low_band_alpha = 0.10;
// N2, the mist of the valley and the bridge.
uniform vec3 valley_color : source_color = vec3(0.290, 0.227, 0.627);
uniform float valley_alpha = 0.12;
uniform float valley_speed = 4.0;
// N3, the green haze on the steps of the portal.
uniform vec3 haze_color : source_color = vec3(0.235, 1.0, 0.478);
uniform float haze_alpha = 0.10;
uniform float haze_speed = 5.0;
// Size in painting pixels of one tile of noise for each layer: wide and flat, mist lies down.
uniform vec2 low_tile = vec2(620.0, 280.0);
uniform vec2 valley_tile = vec2(900.0, 380.0);
uniform vec2 haze_tile = vec2(260.0, 330.0);
// The noise below and above these becomes clear air and full mist.
uniform vec2 density = vec2(0.34, 0.74);

// The halo of the portal.
uniform vec3 halo_color : source_color = vec3(0.212, 1.0, 0.431);
uniform vec2 halo_center = vec2(1515.0, 370.0);
uniform float halo_radius = 110.0;
uniform vec2 halo_alpha = vec2(0.10, 0.18);
uniform float halo_period = 3.2;

// No mist inside these (x0, y0, x1, y1); it comes back over `protect_feather` pixels outside them.
uniform vec4 protect_face = vec4(430.0, 300.0, 600.0, 485.0);
uniform vec4 protect_blade = vec4(145.0, 655.0, 640.0, 935.0);
uniform vec4 protect_logo = vec4(880.0, 20.0, 1432.0, 368.0);
uniform float protect_feather = 28.0;
// Pixels over which the mist of the painting turns into the mist of the bands.
uniform float band_feather = 70.0;

// 0 inside the rectangle, 1 from `protect_feather` pixels away.
float outside(vec2 p, vec4 r) {
	vec2 d = max(max(r.xy - p, p - r.zw), vec2(0.0));
	return smoothstep(0.0, protect_feather, length(d));
}

// 1 inside the rectangle, fading to 0 over `feather` pixels inside each edge.
float inside(vec2 p, vec4 r, float feather) {
	vec2 d = min(p - r.xy, r.zw - p);
	return smoothstep(0.0, feather, d.x) * smoothstep(0.0, feather, d.y);
}

void fragment() {
	// this pixel in pixels of the painting (outside 0..ART on the bands)
	vec2 p = (UV * rect_size - art_origin) / art_scale;
	vec2 q = clamp(p, vec2(0.0), ART);
	float band = smoothstep(0.0, band_feather, length(p - q));

	vec3 a = texture(noise, (p - vec2(time * low_speed, 0.0)) / low_tile).rgb;
	vec3 b = texture(noise, (p + vec2(time * valley_speed, 0.0)) / valley_tile + vec2(0.37, 0.61)).rgb;
	vec3 c = texture(noise, (p + vec2(0.0, time * haze_speed)) / haze_tile + vec2(0.13, 0.29)).rgb;
	// each layer is its own read crossed with another one going elsewhere, so it churns instead of sliding
	float low = smoothstep(density.x, density.y, mix(a.r, b.g, 0.4));
	float valley = smoothstep(density.x, density.y, mix(b.r, a.g, 0.35));
	float haze = smoothstep(density.x, density.y, mix(c.r, a.b, 0.3));

	float keep = outside(q, protect_face) * outside(q, protect_blade) * outside(q, protect_logo);
	float right = smoothstep(600.0, 760.0, q.x);
	float low_mask = right * smoothstep(700.0, 780.0, q.y) * low_alpha
		+ (1.0 - right) * smoothstep(900.0, ART.y, q.y) * low_left_alpha;
	float a1 = low * mix(low_mask * keep, low_band_alpha, band);
	// the right side of both is the edge of the painting itself
	float a2 = valley * valley_alpha * keep * (1.0 - band) * inside(q, vec4(780.0, 520.0, ART.x + 80.0, 760.0), 80.0);
	float a3 = haze * haze_alpha * (1.0 - band) * inside(q, vec4(1380.0, 400.0, 1640.0, 520.0), 50.0);

	float pulse = mix(halo_alpha.x, halo_alpha.y, 0.5 + 0.5 * sin(time * TAU / halo_period));
	float glow = 1.0 - smoothstep(0.0, halo_radius, distance(p, halo_center));
	vec3 halo = halo_color * glow * glow * pulse * (1.0 - band);

	// the three veils one over the other (premultiplied), the halo added as light
	vec3 rgb = low_color * a1;
	float alpha = a1;
	rgb = rgb * (1.0 - a2) + valley_color * a2;
	alpha = alpha * (1.0 - a2) + a2;
	rgb = rgb * (1.0 - a3) + haze_color * a3;
	alpha = alpha * (1.0 - a3) + a3;
	COLOR = vec4(rgb + halo, alpha);
}
