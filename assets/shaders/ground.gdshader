shader_type spatial;
// Everything drawn flat on the floor (the body is ground.gdshaderinc). This first pass draws all of it but an enemy's
// own warning's fill, which ground_fill.gdshader draws as its next pass (C12d, VX-03: overlapping fills never add).
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled, depth_prepass_alpha;

#include "res://assets/shaders/ground.gdshaderinc"
