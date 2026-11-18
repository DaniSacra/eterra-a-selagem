shader_type spatial;
// The water of the fountain's basin (ArenaKit.fountain, AP-1 ART-01.6): before, a disc of yellow light on the floor
// and a white spray. Now still dark water in a stone basin, cold ivory-blue (the Fonte's family, art_direction 6.3),
// slow rings spreading from the spout, a pale glow under the surface near the middle (the light of Elun in it), all
// under the glow threshold. `spent` 0..1 after the hero drinks: the glow goes out and the water stills.
render_mode cull_back;

uniform vec3 deep : source_color = vec3(0.035, 0.06, 0.08);
uniform vec3 pale : source_color = vec3(0.62, 0.74, 0.8);
// The disc's radius (m) and the inner glow's radius (share of it), its light (under 1).
uniform float radius = 1.7;
uniform float glow_share = 0.55;
uniform float glow = 0.38;
// Rings: how many across the radius, how fast they spread (cycles a second), how bright.
uniform float rings = 5.0;
uniform float ring_rate = 0.25;
uniform float ring_light = 0.22;
uniform float spent = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float r = length(p);
	if (r > 1.0) {
		discard;
	}
	float calm = 1.0 - spent;
	float inner = exp(-pow(r / glow_share, 2.0));
	float ring = pow(0.5 + 0.5 * sin((r * rings - TIME * ring_rate) * 6.2831853), 6.0) * smoothstep(1.0, 0.25, r) * smoothstep(0.05, 0.2, r);
	vec3 col = mix(deep, pale * 0.5, inner * 0.6 * calm);
	ALBEDO = col;
	ROUGHNESS = 0.08;
	METALLIC = 0.0;
	SPECULAR = 0.7;
	EMISSION = pale * (glow * inner + ring_light * ring) * calm;
}
