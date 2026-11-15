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
// How much of the painting's own colour (the gold veins, the pale crystal) the blade's light keeps.
uniform float blade_paint = 0.35;
uniform float roughness = 0.4;
uniform float metallic = 0.3;

varying float along;

void vertex() {
	along = VERTEX.y;
}

void fragment() {
	vec3 c = texture(albedo, UV).rgb;
	float blade = smoothstep(blade_from, blade_from + 0.06, along);
	float value = max(c.r, max(c.g, c.b));
	ALBEDO = c * (1.0 - 0.5 * blade);
	ROUGHNESS = roughness;
	METALLIC = metallic * (1.0 - blade);
	EMISSION = c * fill + mix(blade_color * value, c, blade_paint) * blade_glow * blade;
}
