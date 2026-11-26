// The body of dark_water.gdshader (see it for what it draws).

uniform int form = 0;
uniform vec3 deep : source_color = vec3(0.05, 0.09, 0.12);
uniform vec3 pale : source_color = vec3(0.7, 0.8, 0.85);
uniform vec2 size = vec2(8.0, 8.0);
uniform float peak = 0.9;
// the sheet: ripples (a meter's cycles, cycles a second, light), foam along the edge (m wide, light), the fall's foam
uniform float rings = 1.3;
uniform float ring_rate = 0.12;
uniform float ring_light = 0.1;
// How thin the ripples' bright bands are (the power of their sine: 8 thin lines, about 2 to 3 broad soft swells).
uniform float ring_sharp = 8.0;
// The surface: its roughness and specular (a pool under many lights, the hub's fountain, wants them duller: its
// mirrored sky read as veins of marble).
uniform float gloss_roughness = 0.1;
uniform float gloss_specular = 0.4;
// The body's own light, a share of its colour (0: lit only by what it mirrors; the hub's matte pool wants some, or it
// reads as a hole).
uniform float body_light = 0.0;
uniform float edge_foam = 0.25;
uniform float edge_light = 0.12;
uniform vec2 foam_at = vec2(-1.0, -1.0);
uniform float foam_reach = 1.6;
uniform float fade = 0.6;
uniform float alpha = 0.95;
// the fall: streaks (across a meter), how fast they run (m a second), their light, the foot's mist (m)
uniform float streaks = 3.0;
uniform float fall_speed = 2.2;
uniform float fall_light = 0.55;
uniform float foot = 2.5;
// Compatibility only: the body's own light, a share of its colour (no reflections there to show it)
uniform float compat_body = 1.0;
// and the ripples' and foam's light (measured: luma p90 139 at 1.0 against the desktop's 97)
uniform float compat_glow = 0.7;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	return noise(p) * 0.55 + noise(p * 2.1 + 3.7) * 0.3 + noise(p * 4.3 + 1.3) * 0.15;
}

vec3 capped(vec3 c) {
	return c * min(1.0, peak / max(max(c.r, c.g), max(c.b, 1e-4)));
}

void fragment() {
	vec2 m = UV * size;
	vec3 c = deep;
	vec3 glow = vec3(0.0);
	float a = alpha;
	if (form == 0) {
		// slow ripples: two sets of bands crossing, warped by noise
		float w = fbm(m * 0.6 + vec2(TIME * 0.05, -TIME * 0.03));
		float r = pow(0.5 + 0.5 * sin((m.x * 0.7 + m.y * 0.4 + w * 2.0) * rings * 6.2832 - TIME * ring_rate * 6.2832), ring_sharp);
		c = deep * mix(0.8, 1.15, w);
		glow = pale * r * ring_light;
		vec2 d = min(m, size - m);
		float edge = min(d.x, d.y);
		float broken = fbm(m * 2.5 + TIME * 0.08);
		float foam = (1.0 - smoothstep(0.0, edge_foam, edge + (broken - 0.5) * edge_foam)) * step(0.45, broken);
		if (foam_at.x >= 0.0) {
			float f = 1.0 - smoothstep(foam_reach * 0.3, foam_reach, length(m - foam_at * size) + (broken - 0.5) * 0.6);
			foam = max(foam, f * smoothstep(0.35, 0.6, fbm(m * 3.0 - TIME * 0.4)));
		}
		c = mix(c, pale * 0.5, foam * 0.6);
		glow += pale * foam * edge_light;
		a *= smoothstep(0.0, fade, edge);
	} else {
		// streaks running down; the card's sides soft, its top fading in, its foot a band of mist
		float s = fbm(vec2(m.x * streaks, (m.y - TIME * fall_speed) * 0.35));
		float sheet = smoothstep(0.25, 0.65, s);
		c = mix(deep, pale * 0.6, sheet * 0.7);
		glow = pale * sheet * fall_light;
		float side = smoothstep(0.0, 0.3, min(UV.x, 1.0 - UV.x) * size.x);
		float top = smoothstep(0.0, 0.15, UV.y);
		float mist = smoothstep(size.y - foot, size.y, m.y);
		glow += pale * mist * fall_light * 0.5 * fbm(vec2(m.x * 1.5, m.y * 0.8 - TIME * 0.3));
		a *= side * top * mix(0.9, 0.0, smoothstep(size.y - foot * 0.3, size.y, m.y)) * mix(0.7, 1.0, sheet);
	}
	ALBEDO = c;
	ROUGHNESS = gloss_roughness;
	SPECULAR = gloss_specular;
	EMISSION = capped(glow + c * body_light);
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	// the browser's renderer (HUB-E P2-9): no reflections to light the dark albedo (it went black) and its light reaches
	// the screen without the linear-to-sRGB step (a glow v showed as about v^2.2); the body glows a little in its own
	// colour and the ripples and foam come back to the desktop's values
	EMISSION = capped(pow(EMISSION, vec3(1.0 / 2.2)) * compat_glow + c * compat_body);
#endif
	ALPHA = clamp(a, 0.0, 1.0);
}
