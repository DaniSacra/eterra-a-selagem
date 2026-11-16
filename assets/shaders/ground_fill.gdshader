shader_type spatial;
// The second pass of a floor area (GroundLook.new_node: the next pass of ground.gdshader, the same uniforms): only an
// enemy's own (unsigned) warning's red fill. Where one fill is already on the floor this frame (the stencil holds
// FILL_STENCIL there), no other is drawn: three warnings over the same floor show the fill of one, never their sum
// (C12d, VX-03). Its rims, fronts and chevrons stay in the first pass and all of them show.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;
// FILL_STENCIL = 2 (the crowd writes 1, CROWD_STENCIL; the floor under a figure never takes a fill: the figure is in front).
stencil_mode read, write, compare_not_equal, 2;

#define FILL_PASS
#include "res://assets/shaders/ground.gdshaderinc"
