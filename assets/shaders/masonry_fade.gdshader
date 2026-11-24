shader_type spatial;
// masonry.gdshader whose see-through pieces fade for real (alpha, not stipple): see_through.gdshaderinc see_through_alpha.
render_mode diffuse_burley, specular_schlick_ggx, depth_prepass_alpha;

#define SEE_FADE
#include "res://assets/shaders/masonry.gdshaderinc"
