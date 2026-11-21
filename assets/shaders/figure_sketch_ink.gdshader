shader_type spatial;
// The lines inside the Compêndio's ink drawing (FigureSketch, figure_sketch.gdshader), over the page:
//   creases, where the surface turns away from the eye (crease_from to crease_to of 1 - N.V), in full ink;
//   hatching where the light (a fixed key from the upper left, in view space) is low: one set of strokes under shade_one,
//   a second across it under shade_two, hatch_px apart on the screen;
//   a wash where the model's own paint is darker than paint_dark (eye sockets, nose, mouth, belts, the cloth's folds),
//   deeper the darker it is (wash at black);
//   the paper tinted by fill all over the body (head too), so the figure stands off the page in one tone;
//   on an elite (gild, as the crowd's EnemyDef.gild) its steel washed in the Livro's gilt (gilt_alpha), lines over it.
render_mode unshaded, blend_mix, depth_draw_never, cull_back, shadows_disabled, fog_disabled;

uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform vec3 ink : source_color = vec3(0.16, 0.11, 0.07);
uniform vec3 gilt : source_color = vec3(0.5, 0.36, 0.15);
uniform vec3 key_dir = vec3(-0.55, 0.65, 0.5);
uniform float crease_from = 0.62;
uniform float crease_to = 0.8;
uniform float shade_one = 0.5;
uniform float shade_two = 0.26;
uniform float hatch_px = 5.0;
uniform float hatch_width = 0.34;
uniform float hatch_alpha = 0.7;
uniform float paint_dark = 0.22;
uniform float wash = 0.35;
uniform float fill = 0.26;
uniform float gild = 0.0;
// the cells of the model's paint that glow in the game (eyes, gems: BakedModel.glow_from): dots of ink here
uniform vec2 glow_from = vec2(0.5, 0.75);
uniform float glow_ink = 0.5;
uniform float gilt_alpha = 0.55;
// a light hatching on pale paint (bone, a skull) turned from the light: without it a skull with no dark paint stayed
// paper-white over a hatched body; the dark cells (eyes) keep their wash, this only adds where the paint is light
uniform float bone_from = 0.5;
uniform float bone_shade = 0.78;
uniform float bone_alpha = 0.4;
// the body's tint (fill, wash of the dark paint, the glowing cells): a neutral grey of the ink, so the paper under it
// darkens without turning more yellow (only an elite's gilt reads gold)
uniform vec3 wash_ink : source_color = vec3(0.3, 0.29, 0.28);
// the rest of an elite takes this share of the gilt (the crowd's gild_rest)
uniform float gilt_rest = 0.45;

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
	float top = max(paint.r, max(paint.g, paint.b));
	float lum = dot(paint, vec3(0.299, 0.587, 0.114));
	float dark = (1.0 - smoothstep(0.0, paint_dark, lum));
	float cell = step(glow_from.x, fract(UV.x)) * step(glow_from.y, fract(UV.y));
	float pale = smoothstep(bone_from - 0.08, bone_from, lum);
	float bone = pale * (1.0 - smoothstep(bone_shade - 0.06, bone_shade, light))
		* (1.0 - step(hatch_width, abs(fract((px.x + px.y) / hatch_px) - 0.5)));
	float lines = max(max(crease, max(one, two) * hatch_alpha), bone * bone_alpha);
	float body = max(max(dark * wash, fill), cell * glow_ink);
	// the crowd's steel mask (crowd.gdshader): grey, not warm, not too dark
	float colourful = top - min(paint.r, min(paint.g, paint.b));
	float steel = (1.0 - smoothstep(0.1, 0.22, colourful / max(top, 0.001))) * (1.0 - smoothstep(0.0, 0.06, paint.r - paint.b))
		* smoothstep(0.1, 0.2, top);
	float g = clamp(max(steel, gilt_rest) * gild * gilt_alpha, 0.0, 1.0);
	// gilt under the body's tint under the lines
	float a12 = 1.0 - (1.0 - g) * (1.0 - body);
	vec3 c12 = (wash_ink * body + gilt * g * (1.0 - body)) / max(a12, 0.001);
	float out_a = 1.0 - (1.0 - a12) * (1.0 - lines);
	ALBEDO = (ink * lines + c12 * a12 * (1.0 - lines)) / max(out_a, 0.001);
	ALPHA = clamp(out_a, 0.0, 1.0);
}
