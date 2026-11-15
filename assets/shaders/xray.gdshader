shader_type spatial;
// The paladin seen through the crowd in front of him: his own body again, lit as the body itself is (the same
// painting, the same lights and fill), only where an enemy covers him, so going into a pack does not change his
// colours (docs/art/cycle7_spec.md 3.2; he was a flat cyan ghost). Shadows are lifted a little (`floor_light`), never
// recoloured. Only where the crowd drew (crowd.gdshader writes CROWD_STENCIL): behind stone he is drawn by
// xray_behind.gdshader instead, fainter, so he reads as behind the obelisk and not standing on it (cycle 8, B3).
// The passes on his meshes, drawn after everything else (Player.XRAY_PRIORITY): xray_depth lays his own depth in a
// layer right in front of the camera, this one and xray_behind paint the frontmost of his surfaces there, xray_edge
// draws the thin rim around them.
render_mode blend_mix, cull_back, depth_draw_always;
stencil_mode read, compare_equal, 1;

#include "res://assets/shaders/xray_body.gdshaderinc"
