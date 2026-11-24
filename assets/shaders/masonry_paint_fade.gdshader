shader_type spatial;
// masonry_paint.gdshader whose see-through pieces fade for real (alpha, not stipple): see_through.gdshaderinc see_through_alpha.
render_mode diffuse_lambert, depth_prepass_alpha;

#define SEE_FADE
#define PAINT
#include "res://assets/shaders/masonry.gdshaderinc"
