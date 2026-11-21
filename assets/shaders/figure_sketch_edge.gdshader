shader_type spatial;
// The contour of the Compêndio's ink drawing (FigureSketch, figure_sketch.gdshader): the body pushed out width metres
// along its normals and drawn from behind, in the Livro's ink, behind the body's depth.
render_mode unshaded, blend_mix, depth_draw_never, cull_front, shadows_disabled, fog_disabled;

uniform vec3 ink : source_color = vec3(0.16, 0.11, 0.07);
uniform float width = 0.03;
uniform float strength = 0.92;

#include "res://assets/shaders/crowd_pose.gdshaderinc"

void vertex() {
	vec3 at;
	vec3 facing;
	crowd_pose(VERTEX_ID, COLOR, at, facing);
	VERTEX = at + facing * width / max(length(MODEL_MATRIX[0].xyz), 0.001);
	NORMAL = facing;
}

void fragment() {
	ALBEDO = ink;
	ALPHA = strength;
}
