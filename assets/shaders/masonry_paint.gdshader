shader_type spatial;
// The dressed stone of the stylized look (STY-04; VisualProfile puts it on Masonry's materials in place of
// masonry.gdshader): the same blocks, painted warm with the brush, a light lip on each block's top, drawn joints,
// little rock relief, the painted light (paint.gdshaderinc).
render_mode diffuse_lambert;

#define PAINT
#include "res://assets/shaders/masonry.gdshaderinc"
