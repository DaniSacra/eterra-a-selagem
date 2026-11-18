shader_type spatial;
// The catacomb floor of the stylized look (STY-04; VisualProfile puts it on the floors in place of
// catacomb_floor.gdshader): the same slabs, warm umber with a value of their own, the brush along each slab, joints
// drawn at a share of the slab's value, the medallion's lines in that value (no gold, no glow), little rock relief,
// darker toward the room's edge, the painted light (paint.gdshaderinc).
render_mode diffuse_lambert;

#define PAINT
#include "res://assets/shaders/catacomb_floor.gdshaderinc"
