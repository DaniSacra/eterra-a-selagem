shader_type spatial;
// The abyss beside the platforms: layers of slow purple mist at different depths over a faint glow far below.
// Each layer is a flat plane; drawn see-through and unlit (the light down there is the mist's own).
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec3 color : source_color = vec3(0.32, 0.16, 0.5);
uniform float density = 0.5;
// Meters per second the mist drifts, and the size of its swirls.
uniform vec2 drift = vec2(0.25, 0.08);
uniform float scale = 0.06;
// 1 for the bottom layer: opaque, a deep glow under everything.
uniform float floor_layer = 0.0;
// Share of the plane (UV) at each of its four edges where the mist fades to nothing, so the card's straight edges never
// show (art review 2026-11-21 item 1; 0: off, the classic look).
uniform float edge_fade = 0.0;

// Round 3 (hub): the colour the plane goes to with the distance from the room's middle (m, from rim_range.x to .y), the
// horizon's haze over a dark depth; rim_range.y 0 is off (every other room).
uniform vec3 rim_color : source_color = vec3(0.0);
uniform vec2 rim_range = vec2(0.0, 0.0);

varying vec3 world;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	float s = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		s += noise(p) * a;
		p = p * 2.07 + 1.7;
		a *= 0.5;
	}
	return s;
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 tint = color;
	if (rim_range.y > 0.0) {
		tint = mix(color, rim_color * (color.r + color.g + color.b) / max(0.01, 0.34), smoothstep(rim_range.x, rim_range.y, length(world.xz)));
	}
	vec2 p = world.xz * scale;
	float t = TIME;
	float m = fbm(p + drift * t * scale * 4.0);
	m = mix(m, fbm(p * 1.9 - drift.yx * t * scale * 6.0), 0.4);
	if (floor_layer > 0.5) {
		ALBEDO = tint * (0.25 + 0.9 * m * m);
		ALPHA = 1.0;
	} else {
		vec2 ed = min(UV, 1.0 - UV);
		float a = smoothstep(0.35, 0.85, m) * density;
		if (edge_fade > 0.0) {
			a *= smoothstep(0.0, edge_fade, ed.x) * smoothstep(0.0, edge_fade, ed.y);
		}
		ALBEDO = tint * (0.8 + 0.6 * m);
		ALPHA = a;
	}
}
