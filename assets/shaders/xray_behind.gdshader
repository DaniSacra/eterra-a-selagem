shader_type spatial;
// The paladin behind stone (an obelisk, a balustrade, a statue): the same body as xray.gdshader, but only where the
// crowd did not draw (crowd.gdshader writes CROWD_STENCIL), and with Player.XRAY_BEHIND_* numbers: fainter and
// without the extra light, so with the rim around him he reads as a figure behind the stone, never as one standing
// on top of it (cycle 8, B3 of the cycle 7 review).
render_mode blend_mix, cull_back, depth_draw_always;
stencil_mode read, compare_not_equal, 1;

#include "res://assets/shaders/xray_body.gdshaderinc"
