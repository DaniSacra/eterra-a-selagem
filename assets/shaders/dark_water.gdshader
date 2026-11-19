shader_type spatial;
// Dark water of the stylized look (room redesign lot C, docs/art/room_redesign_lotC_spec.md section 1): the fountain's
// water (fountain_water.gdshader: `deep`, `pale`, slow `rings`) out of its basin, never on the walkable floor.
//   form 0, a sheet (the garden's lake and the pools at the foot of the falls): a flat plane, UV 0..1 over `size` m,
//     still dark blue with slow ripples crossing it, a broken band of foam along its edges where it meets the stone
//     and a patch of foam where a fall lands (`foam_at`, in UV, `foam_reach` m; x < 0: none), fading out at the
//     border (`fade` m);
//   form 1, a fall (the cascades behind the garden's windows, the bridge's far falls): a vertical card, UV.y 0 at its
//     top, streaks of foam running down it, its sides soft, its top fading in, its foot a band of mist.
// Hue 200 to 210 (the deep (0.05, 0.09, 0.12), the foam (0.7, 0.8, 0.85)): never the turquoise of the hero's petrol
// (170 to 190); the foam's light under the glow's threshold (its largest channel at most `peak`).
render_mode blend_mix, depth_draw_never, cull_disabled, shadows_disabled, specular_schlick_ggx;

uniform int form = 0;
uniform vec3 deep : source_color = vec3(0.05, 0.09, 0.12);
uniform vec3 pale : source_color = vec3(0.7, 0.8, 0.85);
uniform vec2 size = vec2(8.0, 8.0);
uniform float peak = 0.9;
// the sheet: ripples (a meter's cycles, cycles a second, light), foam along the edge (m wide, light), the fall's foam
uniform float rings = 1.3;
uniform float ring_rate = 0.12;
uniform float ring_light = 0.1;
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
		float r = pow(0.5 + 0.5 * sin((m.x * 0.7 + m.y * 0.4 + w * 2.0) * rings * 6.2832 - TIME * ring_rate * 6.2832), 8.0);
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
	ROUGHNESS = 0.1;
	SPECULAR = 0.4;
	EMISSION = capped(glow);
	ALPHA = clamp(a, 0.0, 1.0);
}
