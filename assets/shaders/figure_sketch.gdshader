shader_type spatial;
// The Compêndio's enemy as a drawing in ink on the Livro's paper (AP-4, ART-07.4; FigureSketch): our own baked figure
// (crowd_pose.gdshaderinc), no AI. Three passes, all over the page (see-through between the lines): this one writes only
// depth (the near body hides what is behind it), figure_sketch_edge.gdshader the contour (the body pushed out and drawn
// from behind) and figure_sketch_ink.gdshader the lines inside: creases where the surface turns away, hatching in the
// shade and a light wash where the model's own paint is dark (eyes, belts, cloth).
render_mode unshaded, blend_mix, depth_draw_always, cull_back, shadows_disabled, fog_disabled;

#include "res://assets/shaders/crowd_pose.gdshaderinc"

void vertex() {
	vec3 at;
	vec3 facing;
	crowd_pose(VERTEX_ID, COLOR, at, facing);
	VERTEX = at;
	NORMAL = facing;
}

void fragment() {
	ALBEDO = vec3(0.0);
	ALPHA = 0.0;
}
