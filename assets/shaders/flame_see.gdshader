shader_type spatial;
// A candle's flame or warm halo (ArenaKit.tongue, Fx.quad: a white shape in its alpha, added on what is behind) for
// the candles in front of the camera in the Chamber of the Seal: the same look, opening round the paladin behind them
// (see_through.gdshaderinc; C12a BOSS-002). facing: 0 turns round its upright only (the tongue), 1 faces the eye (the halo).
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0);
uniform sampler2D shape : source_color, filter_linear;
uniform int facing = 0;
uniform float see_through = 1.0;
uniform float see_radius = 2.2;
uniform float see_height = 1.3;
uniform float see_keep = 0.1;
uniform float see_gap = 0.4;

#include "res://assets/shaders/see_through.gdshaderinc"

void vertex() {
	vec3 up = MODEL_MATRIX[1].xyz;
	vec3 side = INV_VIEW_MATRIX[0].xyz * length(MODEL_MATRIX[0].xyz);
	if (facing == 1) {
		up = INV_VIEW_MATRIX[1].xyz * length(MODEL_MATRIX[1].xyz);
	}
	vec3 out_ = normalize(cross(side, up));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(side, 0.0), vec4(up, 0.0), vec4(out_, 0.0), MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	if (see_through_hole(VERTEX, FRAGCOORD.xy, VIEW_MATRIX, PROJECTION_MATRIX, see_through, see_radius, see_height, see_keep, see_gap)) {
		discard;
	}
	vec4 s = texture(shape, UV);
	ALBEDO = color.rgb * s.rgb;
	ALPHA = color.a * s.a;
}
