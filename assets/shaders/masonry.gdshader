shader_type spatial;
// Old dressed stone for every built thing of the catacombs (balustrades, obelisks, the portal's facade, plinths,
// stairs, the kit's walls and pillars): world-space blocks laid in courses on the upright faces, worn slabs on the
// tops, darker joints with a little relief, grime that climbs from the foot, and a painted wash of slate and violet
// so no two blocks match. Triplanar, so any box of any size takes it without UVs.
render_mode diffuse_burley, specular_schlick_ggx;

#include "res://assets/shaders/masonry.gdshaderinc"
