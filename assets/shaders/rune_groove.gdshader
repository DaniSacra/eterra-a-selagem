shader_type spatial;
// The gold grooves up a rune pillar (RunesLook._pillar): old gold, warming to amber with the floor (glow, set every
// frame the tiles change), and opening round the paladin behind the pillar as the pillar does, but whole: nothing of
// them is kept in the hole (keep 0; C18, QW-108: the lit grooves left a drizzle of amber dots round him).
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 gold : source_color = vec3(0.66, 0.5, 0.26);
uniform vec3 glow : source_color = vec3(0.0);
uniform float metallic = 0.6;
uniform float roughness = 0.5;
uniform float see_through = 1.0;
uniform float see_radius = 2.2;
uniform float see_height = 1.3;
uniform float see_gap = 0.4;

#include "res://assets/shaders/see_through.gdshaderinc"

void fragment() {
	if (see_through_hole(VERTEX, FRAGCOORD.xy, VIEW_MATRIX, PROJECTION_MATRIX, see_through, see_radius, see_height, 0.0, see_gap)) {
		discard;
	}
	ALBEDO = gold;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	EMISSION = glow;
}
