shader_type spatial;
// dark_water.gdshader without the sky's reflection (the cycle of 2026-11-20, P2-A9): a pool seen from above under the
// hub's open sky mirrored the radiance map's lowest mips, blocky grey clouds that read as marble whatever the roughness;
// here no ambient light nor reflection reaches it, the water is its own dark colour, the lights and its ripples.
render_mode blend_mix, depth_draw_never, cull_disabled, shadows_disabled, specular_schlick_ggx, ambient_light_disabled;

#include "res://assets/shaders/dark_water.gdshaderinc"
