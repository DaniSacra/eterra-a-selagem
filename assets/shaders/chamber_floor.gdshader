shader_type spatial;
// The floor of the Chamber of the Seal (BossChamber; docs/art/boss_chamber_spec.md 2.2 and 2.3): the catacomb floor's
// slabs with the seal carved in the middle (its five states, chamber_seal.gdshaderinc), the edge of the walkable circle
// (a band of darker kerb stones with a thread of old gold where the paladin stops), worn inscriptions on some slabs
// and, in Morvath's last phase, veins of corruption running out along the joints.
render_mode diffuse_lambert, specular_schlick_ggx;

#define CHAMBER
#include "res://assets/shaders/catacomb_floor.gdshaderinc"
