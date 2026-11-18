shader_type spatial;
// The tree's crystals (StoneTree, C18 ART P1-7): dark corrupted emerald glass that glows only along its edges, where a
// facet turns away from the eye (a fresnel on the facets' flat normals), never as a flat lit patch: the faces keep
// face_glow of the light, the grazing ones all of it. Its brightest channel is `peak` (under the glow's threshold).
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 albedo : source_color = vec3(0.03, 0.08, 0.07);
uniform vec3 glow : source_color = vec3(0.315, 0.7, 0.604);
uniform float peak = 0.15;
uniform float edge_power = 2.5;
uniform float face_glow = 0.12;
uniform float roughness = 0.45;
uniform float specular = 0.3;

void fragment() {
	ALBEDO = albedo;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	float edge = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), edge_power);
	vec3 g = glow / max(glow.r, max(glow.g, glow.b));
	EMISSION = g * peak * mix(face_glow, 1.0, edge) * 2.0;
}
