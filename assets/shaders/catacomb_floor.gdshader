shader_type spatial;
// The floor of the catacomb platforms: big flagstones of blue-grey slate laid in a hopscotch pattern (big slabs with
// small ones at their corners, some big ones split in two or three, so no joint runs straight across the hall), each
// slab its own value, tint and slight tilt, a bevel along its edge that catches the light on one side (an analytic
// normal, no screen derivatives), rounded and nicked edges, a corner missing here and there, cracks, a few red
// petals. Wet only in front of the portal and round the fire bowls. The middle stays calm so the fighters read on it;
// the medallion is carved in the slabs (a ring of sixteen stones with worn runes, bevelled rims, a broken thread of
// dark bronze, cracks, eight points). World space, so a platform of any size takes it.
render_mode diffuse_lambert, specular_schlick_ggx;

#include "res://assets/shaders/catacomb_floor.gdshaderinc"
