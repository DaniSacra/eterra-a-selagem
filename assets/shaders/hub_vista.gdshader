shader_type spatial;
// Santuario da Vigilia (hub refine round 1): the view in the Portao da Aventura's opening, the art's violet mountains and
// a pale road under a gold dusk sky. One unlit card (UV.y 0 at the top): a sky gradient, a low sun glow, two layers of
// ridge, a road winding to the sun. The sheet of light (portal.gdshader, additive) sits in front of it.
render_mode unshaded, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 sky_top : source_color = vec3(0.3, 0.2, 0.52);
uniform vec3 sky_low : source_color = vec3(0.98, 0.7, 0.45);
uniform vec3 far_ridge : source_color = vec3(0.5, 0.34, 0.6);
uniform vec3 near_ridge : source_color = vec3(0.26, 0.18, 0.4);
uniform vec3 road_color : source_color = vec3(0.92, 0.78, 0.66);
uniform float seed = 4.0;

float hash(float n) {
	return fract(sin(n * 127.1 + seed * 17.3) * 43758.5453);
}

float noise(float x) {
	float i = floor(x);
	float f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(hash(i), hash(i + 1.0), f);
}

void fragment() {
	float y = 1.0 - UV.y;
	float x = UV.x;
	vec3 c = mix(sky_low, sky_top, smoothstep(0.3, 0.95, y));
	// the sun's glow, low and a little to the right
	float d = distance(vec2(x * 0.7, y), vec2(0.6 * 0.7, 0.34));
	c += vec3(1.0, 0.72, 0.4) * 0.45 * (1.0 - smoothstep(0.0, 0.34, d));
	float far_line = 0.3 + 0.2 * (noise(x * 3.0) * 0.65 + noise(x * 8.0) * 0.35);
	float near_line = 0.14 + 0.16 * (noise(x * 4.5 + 7.0) * 0.6 + noise(x * 11.0) * 0.4);
	c = mix(c, mix(far_ridge, sky_low, 0.25), step(y, far_line));
	c = mix(c, near_ridge, step(y, near_line));
	// the road: a pale ribbon from the foot up to the sun, narrowing, bending
	float t = clamp(y / 0.36, 0.0, 1.0);
	float centre = 0.5 + 0.1 * sin(t * 4.0 + 1.0) * (0.3 + t);
	float width = mix(0.18, 0.012, t);
	float road = (1.0 - smoothstep(width * 0.6, width, abs(x - centre))) * step(y, 0.36);
	c = mix(c, road_color, road * 0.85);
	ALBEDO = c;
}
