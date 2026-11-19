shader_type spatial;
// Pale fungus of the stylized look (room redesign lot C, docs/art/room_redesign_lotC_spec.md section 1;
// Masonry.fungus): clusters of flat caps on lids, column feet and sills, never on the open floor. Ivory grey, lit as
// the stone is (the painted light), with a faint glow of its own only along the cap's rim (the vertex colour's red: 1
// on the rim, 0 on the cap's top and the stem), its largest channel at most `rim_peak` (under the glow's threshold).
render_mode diffuse_burley, specular_disabled;

#define PAINT_RIM
#include "res://assets/shaders/paint.gdshaderinc"

uniform vec3 cap : source_color = vec3(0.62, 0.6, 0.55);
uniform vec3 gill : source_color = vec3(0.38, 0.36, 0.33);
uniform float rim_peak = 0.6;
uniform float rim_share = 0.35;

varying float rim;
varying float under;

void vertex() {
	rim = COLOR.r;
	under = COLOR.g;
}

void fragment() {
	ALBEDO = mix(cap, gill, under);
	ROUGHNESS = 0.8;
	vec3 g = cap / max(cap.r, max(cap.g, cap.b));
	EMISSION = g * rim_peak * rim_share * rim * (1.0 - under);
}
