shader_type spatial;
// The floor of the Câmara das Runas Instáveis (RunesLook; E5 spec 3.4, 3.6): the catacomb floor's body, one slab a
// rune tile of 3 m, each tile framed in old gold with its state read from rune_state (rune_tiles.gdshaderinc).
render_mode diffuse_lambert, specular_schlick_ggx;

#define RUNES
#include "res://assets/shaders/catacomb_floor.gdshaderinc"
