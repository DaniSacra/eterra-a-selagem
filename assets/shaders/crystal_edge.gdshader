shader_type spatial;
// The tree's crystals (StoneTree, C18 ART P1-7): dark corrupted emerald glass that glows only along its edges, where a
// facet turns away from the eye (a fresnel on the facets' flat normals), never as a flat lit patch: the faces keep
// face_glow of the light, the grazing ones all of it. Its brightest channel is `peak` (under the glow's threshold).
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 albedo : source_color = vec3(0.03, 0.08, 0.07);
uniform vec3 glow : source_color = vec3(0.315, 0.7, 0.604);
uniform float peak = 0.15;
uniform float edge_power = 2.0;
uniform float face_glow = 0.05;
// Sweep 2026-11-25: a slow shimmer through the stone (share of the glow it dims, its speed, the world spread), so the
// crystals are not one flat green.
uniform float shimmer = 0.3;
uniform float shimmer_speed = 0.9;
uniform float shimmer_spread = 2.3;
uniform float roughness = 0.45;
uniform float specular = 0.3;

varying vec3 world_at;

void vertex() {
	world_at = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	ALBEDO = albedo;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	float edge = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), edge_power);
	vec3 g = glow / max(glow.r, max(glow.g, glow.b));
	float wave = 1.0 - shimmer * (0.5 + 0.5 * sin(TIME * shimmer_speed + dot(world_at, vec3(1.0, 1.7, 1.3)) * shimmer_spread));
	EMISSION = g * peak * mix(face_glow, 1.0, edge) * 2.0 * wave;
}
