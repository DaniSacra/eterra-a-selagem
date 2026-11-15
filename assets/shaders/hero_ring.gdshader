shader_type spatial;
// A thin ring on the floor around the paladin's feet, in the petrol of his scarf: faint on the open floor, clearer
// through whoever stands over it, so the eye finds him in a crowd. A wedge of it on the side he faces is a little
// brighter (docs/art/cycle7_spec.md 3.2: the ring says where he looks; no arrow). Never red (warnings) nor filled
// (areas). This pass draws it on the open floor only; hero_ring_through.gdshader draws it where the crowd stands over
// it (the stencil crowd.gdshader writes). Under stone it is hidden: on top of an obelisk it said he stood there
// (cycle 8, B3).
render_mode unshaded, blend_mix, cull_disabled, shadows_disabled, depth_draw_never, depth_test_disabled;

#include "res://assets/shaders/hero_ring.gdshaderinc"
