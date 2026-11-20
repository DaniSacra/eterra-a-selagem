shader_type spatial;
// EdgeKit's roots, ivy and iron in the stylized look: the scenery's painted light (paint.gdshaderinc, three bands and
// its faint warm rim), the same body (edge_piece.gdshaderinc).
render_mode cull_disabled, diffuse_lambert;

#define PAINT
#define PAINT_RIM
#include "res://assets/shaders/paint.gdshaderinc"
#include "res://assets/shaders/edge_piece.gdshaderinc"
