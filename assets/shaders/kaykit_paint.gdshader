shader_type spatial;
// The KayKit dungeon props in the stylized look (STY-05; assets/models/kaykit_paint.tres, put by
// ArenaKit.paint_look in place of kaykit_material.tres): the kit's one palette, matte, the painted light of the scenery
// (paint.gdshaderinc, three bands) and its faint warm rim. No flattening of the texture: the palette's cells are flat
// colours already, and a lower mip would mix neighbouring cells.
render_mode diffuse_lambert;

#define PAINT_RIM
#include "res://assets/shaders/paint.gdshaderinc"

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform float value = 0.85;
// STY-09 (art-director): the kit's palette is toy-bright under the stylized key (terracotta pots at saturation 0.69,
// luma 120, the most saturated thing of the hall): its colours pulled toward their grey, like the reference's pots.
uniform float saturation = 0.55;

void fragment() {
	vec3 c = texture(albedo_texture, UV).rgb;
	float grey = dot(c, vec3(0.2126, 0.7152, 0.0722));
	ALBEDO = mix(vec3(grey), c, saturation) * value;
	ROUGHNESS = 0.95;
	SPECULAR = 0.1;
}
