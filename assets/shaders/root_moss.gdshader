shader_type spatial;
// Moss on the garden's floor (GardenLook._moss; art pack 2026-11-17, section 4: the bark, the moss and the masonry
// meet): a flat band a hair over the slabs along each big root, round the trunk's foot and along the walls' feet, in
// patches thickest where the root or the wall meets the floor and thinning out into the paving. Lit like the floor
// (it lies in the same light), a dull grey green under the floor's value: old moss in the damp, never a lawn.
// The vertex colour's alpha: 1 where the band meets the root or wall, 0 at its outer border.
render_mode blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

#include "res://assets/shaders/root_moss.gdshaderinc"
