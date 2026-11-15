shader_type spatial;
// Emeth, the sword of truth (EmethSword): the Meshy model's own painting, a little of it as light everywhere (the
// hero's fill: guard, grip and pommel keep their colours away from the torches) and the crystal blade lit from
// inside in emerald. The blade's light stays under the glow threshold of the WorldEnvironment, so it keeps its
// shape and its gold veins; only the pale edge down its middle (EmethSword.CORE) blooms.

uniform sampler2D albedo : source_color, filter_linear_mipmap;
// The painting as light, on the whole sword.
uniform float fill = 0.28;
// The blade: the model's height (its own space) where it starts, the emerald its painting is seen through and how
// bright that is.
uniform float blade_from = -0.1;
uniform vec3 blade_color : source_color = vec3(0.08, 0.85, 0.27);
uniform float blade_glow = 1.0;
// A swing lifts the blade's light for an instant (EmethSword.set_pulse): added to blade_glow.
uniform float pulse = 0.0;
// A boss's curse on the paladin (EmethSword.set_corrupt, 0..1): veins of dark violet creep up the crystal from the
// guard and dull the emerald where they run; the upper part of the blade and its gold veins stay Emeth's.
uniform float corrupt = 0.0;
uniform vec3 corrupt_color : source_color = vec3(0.42, 0.1, 0.62);
// How far up the blade (share of its length) the corruption reaches at its fullest.
uniform float corrupt_reach = 0.7;
// How much of the painting's own colour (the gold veins, the pale crystal) the blade's light keeps.
uniform float blade_paint = 0.35;
uniform float roughness = 0.4;
uniform float metallic = 0.3;

varying float along;
varying vec3 local;

void vertex() {
	along = VERTEX.y;
	local = VERTEX;
}

void fragment() {
	vec3 c = texture(albedo, UV).rgb;
	float blade = smoothstep(blade_from, blade_from + 0.06, along);
	float value = max(c.r, max(c.g, c.b));
	ALBEDO = c * (1.0 - 0.5 * blade);
	ROUGHNESS = roughness;
	METALLIC = metallic * (1.0 - blade);
	vec3 lit = blade_color * value;
	if (corrupt > 0.0) {
		// how far up the blade this point is (0 at the guard, 1 at the tip), with a ragged front that drifts
		float up = clamp((along - blade_from) / (0.95 - blade_from), 0.0, 1.0);
		float wave = sin(local.x * 61.0 + local.z * 47.0 + TIME * 1.7) * 0.5 + sin(local.x * 23.0 - local.z * 31.0 + along * 19.0) * 0.5;
		float front = corrupt_reach * corrupt + wave * 0.08;
		float veins = 1.0 - smoothstep(front - 0.18, front, up);
		// the crystal's own darker lines turn violet first: the corruption follows the painting's veins
		float k = clamp(veins * (0.55 + 0.45 * (1.0 - value)), 0.0, 1.0) * corrupt;
		lit = mix(lit, corrupt_color * (0.35 + 0.65 * value), k);
		ALBEDO = mix(ALBEDO, corrupt_color * 0.25, k * blade);
	}
	EMISSION = c * fill + mix(lit, c, blade_paint) * (blade_glow + pulse) * blade;
}
