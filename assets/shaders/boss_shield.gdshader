shader_type spatial;
// The shield of Morvath's ritual (cycle 9, after Daniel's reference "ritual_escudo_erupcoes"): a sphere of spectral
// glass in his corrupted emerald (cold and dark, BossShield.COLOR), nearly clear where it faces the eye (his silhouette always reads through it), a fine
// bright rim, slow veins crawling over it, two bands of his runes drifting around it and breathing in and out, violet
// pooling at its foot. The far side shows faintly (the sphere has a volume). Added light: never white, never gold;
// only the rim touches the glow threshold. power: 0..1 as it grows in (Boss drives it); shatter: 0..1 as it breaks
// (BossShield drives it): the rim flares a little and the glass falls apart in shards.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

#include "res://assets/shaders/rune_glyph.gdshaderinc"

uniform vec4 color : source_color = vec4(0.315, 0.7, 0.604, 1.0);
// The violet pooling at its foot and the spectral blue of its veins.
uniform vec3 deep : source_color = vec3(0.36, 0.12, 0.78);
uniform vec3 spirit : source_color = vec3(0.3, 0.6, 1.0);
uniform float power = 1.0;
uniform float shatter = 0.0;
uniform float rim_strength = 0.95;
uniform float veins = 0.32;
uniform float fill = 0.03;
// The far side's share of the light (it shows through the near side).
uniform float far_side = 0.4;
// The runes: two bands at these heights (share of the radius, -1 foot to 1 top), their height (share), how many
// glyphs go around, their light and how fast they drift around (turns a second).
uniform vec2 rune_bands = vec2(0.22, -0.18);
uniform float rune_height = 0.16;
uniform float rune_count = 22.0;
uniform float rune_light = 0.55;
uniform float rune_drift = 0.018;
// The slow breath (cycles a second) and how deep it goes.
uniform float breath_rate = 0.3;
uniform float breath = 0.22;
// How much brighter the rim gets as the shield breaks, at most.
uniform float flare = 0.5;

varying vec3 local;

float hash3(vec3 p) {
	p = fract(p * 0.3183099 + 0.1);
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise3(vec3 x) {
	vec3 i = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(hash3(i), hash3(i + vec3(1, 0, 0)), f.x), mix(hash3(i + vec3(0, 1, 0)), hash3(i + vec3(1, 1, 0)), f.x), f.y),
		mix(mix(hash3(i + vec3(0, 0, 1)), hash3(i + vec3(1, 0, 1)), f.x), mix(hash3(i + vec3(0, 1, 1)), hash3(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}

void vertex() {
	local = VERTEX;
}

void fragment() {
	// guarded (cycle 10, BUG-005): a NaN or a value over 1 here would bloom as a white blot through the glow
	vec3 s = local / max(length(local), 0.0001);
	float facing = clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0);
	float rim = pow(1.0 - facing, 2.6);
	float side = FRONT_FACING ? 1.0 : far_side;
	// veins: thin lines where a slow noise crosses its middle
	vec3 p = s * 2.6 + vec3(0.0, TIME * 0.12, TIME * 0.07);
	float n = noise3(p) * 0.6 + noise3(p * 2.3) * 0.4;
	float vein = 1.0 - smoothstep(0.0, 0.045, abs(n - 0.5));
	// runes: two bands drifting around the sphere, each glyph fading in and out on its own
	float lon = atan(s.z, s.x + 0.00001) / 6.2831853 + 0.5;
	float runes = 0.0;
	for (int b = 0; b < 2; b++) {
		float h = (s.y - rune_bands[b]) / rune_height;
		if (abs(h) < 0.5) {
			float turn = lon + (b == 0 ? 1.0 : -1.0) * TIME * rune_drift + float(b) * 0.37;
			float cell = floor(turn * rune_count);
			vec2 q = vec2(fract(turn * rune_count), h + 0.5);
			float g = 1.0 - smoothstep(0.05, 0.09, rune_glyph(q, vec2(1.0, 1.0), cell + float(b) * 41.0));
			float wake = 0.5 + 0.5 * sin(TIME * 0.7 + rune_hash(vec2(cell, float(b))) * 6.28);
			runes += g * smoothstep(0.15, 0.7, wake);
		}
	}
	float breathe = 1.0 - breath * (0.5 + 0.5 * sin(TIME * breath_rate * 6.2831853));
	float grown = min(power, 1.0);
	float broken = shatter;
	// breaking: the glass falls apart in shards (cells of the vein noise going out one by one)
	float shard = step(broken * 1.05, noise3(s * 5.0 + 3.0));
	vec3 tint = mix(deep, color.rgb, smoothstep(-0.7, 0.2, s.y));
	vec3 c = tint * (fill + rim * rim_strength * (1.0 + flare * broken));
	c += spirit * vein * veins * (0.25 + rim);
	c += color.rgb * runes * rune_light * (0.6 + 0.4 * facing);
	ALBEDO = c * side * breathe * grown * shard;
}
