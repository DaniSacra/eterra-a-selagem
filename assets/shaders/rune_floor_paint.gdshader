shader_type spatial;
// The floor of the Câmara das Runas Instáveis in the stylized look (room redesign lot D, spec 1.1; ArenaKit.paint_look
// puts it in place of rune_floor.gdshader on the same material): the painted catacomb floor (catacomb_floor_paint) with
// the rune tiles read the same (rune_tiles.gdshaderinc: the same state texture, uniforms and timing; only the stone
// round them and the frames at rest are painted).
render_mode diffuse_lambert;

#define PAINT
#define RUNES
#include "res://assets/shaders/catacomb_floor.gdshaderinc"
