shader_type spatial;
// The ring at the paladin's feet seen through the crowd that stands over it (hero_ring.gdshader is the open floor):
// only where an enemy is the front surface (the stencil crowd.gdshader writes), never through stone.
render_mode unshaded, blend_mix, cull_disabled, shadows_disabled, depth_draw_never, depth_test_disabled;
stencil_mode read, compare_equal, 1;

#define THROUGH
#include "res://assets/shaders/hero_ring.gdshaderinc"
