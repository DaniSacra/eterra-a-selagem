shader_type spatial;
// LC-1 (docs/backlog.md 9): the same lights as enemy_tell.gdshader, drawn over what is in front of them (EnemyFx
// over: the crossbow drawn in light, which the crossbowman's own body hid whenever it aimed away from the camera).
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled, fog_disabled;

#include "res://assets/shaders/enemy_tell.gdshaderinc"
