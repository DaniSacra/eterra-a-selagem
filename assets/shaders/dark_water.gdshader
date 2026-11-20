shader_type spatial;
// Dark water of the stylized look (room redesign lot C, docs/art/room_redesign_lotC_spec.md section 1): the fountain's
// water (fountain_water.gdshader: `deep`, `pale`, slow `rings`) out of its basin, never on the walkable floor.
//   form 0, a sheet (the garden's lake and the pools at the foot of the falls): a flat plane, UV 0..1 over `size` m,
//     still dark blue with slow ripples crossing it, a broken band of foam along its edges where it meets the stone
//     and a patch of foam where a fall lands (`foam_at`, in UV, `foam_reach` m; x < 0: none), fading out at the
//     border (`fade` m);
//   form 1, a fall (the cascades behind the garden's windows, the bridge's far falls): a vertical card, UV.y 0 at its
//     top, streaks of foam running down it, its sides soft, its top fading in, its foot a band of mist.
// Hue 200 to 210 (the deep (0.05, 0.09, 0.12), the foam (0.7, 0.8, 0.85)): never the turquoise of the hero's petrol
// (170 to 190); the foam's light under the glow's threshold (its largest channel at most `peak`).
render_mode blend_mix, depth_draw_never, cull_disabled, shadows_disabled, specular_schlick_ggx;

#include "res://assets/shaders/dark_water.gdshaderinc"
