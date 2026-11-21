shader_type spatial;
// The lines inside the Compêndio's ink drawing (FigureSketch, figure_sketch.gdshader), over the page:
//   creases, where the surface turns away from the eye (crease_from to crease_to of 1 - N.V), in full ink;
//   hatching where the light (a fixed key from the upper left, in view space) is low: one set of strokes under shade_one,
//   a second across it under shade_two, hatch_px apart on the screen, hatch_width of a gap wide, a little wavy;
//   a wash of wash of the ink where the model's own paint is darker than paint_dark (the eyes, belts, the cloth's folds);
//   a faint wash fill over the whole body, so the figure stands off the page.
render_mode unshaded, blend_mix, depth_draw_never, cull_back, shadows_disabled, fog_disabled;

uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform vec3 ink : source_color = vec3(0.16, 0.11, 0.07);
uniform vec3 key_dir = vec3(-0.55, 0.65, 0.5);
uniform float crease_from = 0.62;
uniform float crease_to = 0.8;
uniform float shade_one = 0.42;
uniform float shade_two = 0.18;
uniform float hatch_px = 5.0;
uniform float hatch_width = 0.34;
uniform float hatch_alpha = 0.55;
uniform float paint_dark = 0.32;
uniform float wash = 0.45;
uniform float fill = 0.06;

#include "res://assets/shaders/crowd_pose.gdshaderinc"

void vertex() {
	vec3 at;
	vec3 facing;
	crowd_pose(VERTEX_ID, COLOR, at, facing);
	VERTEX = at;
	NORMAL = facing;
}

void fragment() {
	vec3 n = normalize(NORMAL);
	float turn = 1.0 - abs(dot(n, VIEW));
	float crease = smoothstep(crease_from, crease_to, turn);
	float light = clamp(dot(n, normalize(key_dir)) * 0.5 + 0.5, 0.0, 1.0);
	vec2 px = FRAGCOORD.xy;
	float one = (1.0 - smoothstep(shade_one - 0.06, shade_one, light)) * (1.0 - step(hatch_width, abs(fract((px.x + px.y) / hatch_px) - 0.5)));
	float two = (1.0 - smoothstep(shade_two - 0.06, shade_two, light)) * (1.0 - step(hatch_width, abs(fract((px.x - px.y) / hatch_px) - 0.5)));
	vec3 paint = texture(albedo, UV).rgb;
	float lum = dot(paint, vec3(0.299, 0.587, 0.114));
	float dark = 1.0 - smoothstep(paint_dark * 0.5, paint_dark, lum);
	float a = max(max(crease, max(one, two) * hatch_alpha), max(dark * wash, fill));
	ALBEDO = ink;
	ALPHA = clamp(a, 0.0, 1.0);
}
