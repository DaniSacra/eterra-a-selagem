// The body of the edge and foreground pieces that are not cut stone (EdgeKit, TA-HB2: hanging roots, ivy, the
// iron of a chain with its weight): the vertex colour times `color`, a little grain by place so a strand is not one
// flat colour, matte, and the stippled hole round the paladin (and Morvath) behind it (see_through.gdshaderinc), as
// the stone pieces have. edge_piece.gdshader is the classic look, edge_piece_paint.gdshader the stylized one (PAINT:
// the painted light of the scenery, paint.gdshaderinc), swapped by VisualProfile.

uniform vec3 color : source_color = vec3(0.3, 0.26, 0.2);
uniform float grain = 0.12;
uniform float roughness = 0.95;
uniform float metal = 0.0;
uniform float see_through = 1.0;
uniform float see_radius = 2.2;
uniform float see_height = 1.3;
uniform float see_keep = 0.15;
uniform float see_gap = 0.4;

#include "res://assets/shaders/see_through.gdshaderinc"

varying vec3 world_at;

float edge_hash(vec3 p) {
	return fract(sin(dot(floor(p), vec3(12.9898, 78.233, 37.719))) * 43758.5453);
}

void vertex() {
	world_at = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	if (see_through_hole(VERTEX, FRAGCOORD.xy, VIEW_MATRIX, PROJECTION_MATRIX, see_through, see_radius, see_height, see_keep, see_gap)) {
		discard;
	}
	float g = mix(edge_hash(world_at * 9.0), edge_hash(world_at * 23.0), 0.5);
	ALBEDO = color * COLOR.rgb * (1.0 + (g - 0.5) * grain * 2.0);
	ROUGHNESS = roughness;
	METALLIC = metal;
#ifdef PAINT
	SPECULAR = 0.1;
#endif
}
