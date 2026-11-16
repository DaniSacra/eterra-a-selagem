shader_type spatial;
// A candle's wax (Masonry.candle's material) for the candles in front of the camera in the Chamber of the Seal: the
// same look, and they open round the paladin behind them like the balustrade they stand on (see_through.gdshaderinc;
// C12a BOSS-002: their flames and stubs were drawn over his legs on the south rim).
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 wax : source_color = vec3(1.0, 0.8, 0.55);
uniform float roughness = 0.6;
uniform float rim = 0.3;
// The wax's own glow (emission), times glow_share (side top to foot, the caps).
uniform vec3 glow : source_color = vec3(0.36, 0.14, 0.04);
uniform sampler2D glow_share : filter_linear;
uniform float see_through = 1.0;
uniform float see_radius = 2.2;
uniform float see_height = 1.3;
uniform float see_keep = 0.1;
uniform float see_gap = 0.4;

#include "res://assets/shaders/see_through.gdshaderinc"

void fragment() {
	if (see_through_hole(VERTEX, FRAGCOORD.xy, VIEW_MATRIX, PROJECTION_MATRIX, see_through, see_radius, see_height, see_keep, see_gap)) {
		discard;
	}
	ALBEDO = wax;
	ROUGHNESS = roughness;
	RIM = rim;
	EMISSION = glow * texture(glow_share, UV).rgb;
}
