shader_type spatial;
// The small lights of the enemies' wind-ups and of their armor (EnemyFx): one MultiMesh of quads, added over the
// scene. COLOR is the instance's colour (rgb, a = opacity). INSTANCE_CUSTOM: x = shape (0 soft dot, 1 thin ring,
// 2 streak along the quad's x, 3 hard shard), y = 1 turns the quad to the camera (0: as it was placed, e.g. flat
// on the floor), z = the ring's thickness (share of its radius), w = a turn in the screen's plane (radians,
// billboards only).
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

#include "res://assets/shaders/enemy_tell.gdshaderinc"
