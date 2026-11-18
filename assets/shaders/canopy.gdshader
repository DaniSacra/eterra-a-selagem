shader_type spatial;
// The stone tree's crown of leaves (GardenLook._canopy, C18 ART P1-7, Q-21 (a): procedural cards, no model): each card
// a clump of small leaves cut out of noise (alpha scissor, in the opaque pass), in a muted violet (never past 0.45 of
// saturation: the scenery stays in one tone), darker inside the clump and toward its foot, lit by the room with a
// little light through it (backlight). It opens round the paladin as the stone does (see_through), so a card never
// covers him.
render_mode diffuse_burley, specular_disabled, cull_disabled, depth_prepass_alpha;

uniform vec3 leaf_a : source_color = vec3(0.22, 0.17, 0.27);
uniform vec3 leaf_b : source_color = vec3(0.4, 0.33, 0.46);
// How many leaves across the card, how much of the card the clump fills, how ragged its outline.
uniform float leaves = 9.0;
uniform float fill = 0.62;
uniform float ragged = 0.35;
uniform float backlight = 0.35;
uniform float see_through = 1.0;
uniform float see_radius = 2.4;
uniform float see_height = 1.3;
uniform float see_keep = 0.0;
uniform float see_gap = 0.4;

#include "res://assets/shaders/see_through.gdshaderinc"

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
}

varying float seed;

void vertex() {
	seed = INSTANCE_CUSTOM.x;
}

void fragment() {
	if (see_through_hole(VERTEX, FRAGCOORD.xy, VIEW_MATRIX, PROJECTION_MATRIX, see_through, see_radius, see_height, see_keep, see_gap)) {
		discard;
	}
	vec2 p = (UV - 0.5) * 2.0;
	// the clump: a ragged blob, then leaves inside it (each a small pointed oval in its own cell)
	float blob = length(p * vec2(1.0, 1.25)) + (noise(p * 2.3 + seed * 17.0) - 0.5) * ragged * 2.0;
	vec2 q = UV * leaves + seed * 31.0;
	vec2 cell = floor(q);
	vec2 f = fract(q) - 0.5;
	float turn = hash1(cell) * 6.2832;
	vec2 r = mat2(vec2(cos(turn), sin(turn)), vec2(-sin(turn), cos(turn))) * f;
	float leaf = length(r * vec2(1.0, 2.1)) - 0.42 + abs(r.x) * 0.3;
	float keep = step(blob, fill) * step(leaf, 0.0) + step(blob, fill * 0.55);
	if (keep < 0.5) {
		discard;
	}
	float shade = clamp(1.0 - blob / fill, 0.0, 1.0);
	vec3 c = mix(leaf_a, leaf_b, hash1(cell + 3.0) * 0.6 + (1.0 - shade) * 0.4);
	c *= mix(0.7, 1.0, UV.y < 0.5 ? 1.0 : 1.0 - (UV.y - 0.5));
	ALBEDO = c;
	ROUGHNESS = 0.9;
	BACKLIGHT = c * backlight;
}
