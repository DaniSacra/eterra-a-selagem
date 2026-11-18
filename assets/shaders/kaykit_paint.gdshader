shader_type spatial;
// The KayKit dungeon props in the stylized look (STY-05; assets/models/kaykit_paint.tres, put by
// ArenaKit.paint_look in place of kaykit_material.tres): the kit's one palette, matte, the painted light of the scenery
// (paint.gdshaderinc, three bands) and its faint warm rim. No flattening of the texture: the palette's cells are flat
// colours already, and a lower mip would mix neighbouring cells.
render_mode diffuse_lambert;

#define PAINT_RIM
#include "res://assets/shaders/paint.gdshaderinc"

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform float value = 1.0;

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb * value;
	ROUGHNESS = 0.95;
	SPECULAR = 0.1;
}
