shader_type spatial;
// The ground under the Compêndio's ink drawing (FigureSketch, AP-4 spec 2.1 item 1): three to five level strokes of
// ink under the feet, of unequal lengths, line_px thick on the screen, at alpha, no gradient. A quad facing the camera,
// its top at the soles; strokes[i] = (left, right, height) in its UV (0 to 1 across, 0 at the top), count used.
render_mode unshaded, blend_mix, depth_draw_never, depth_test_disabled, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 ink : source_color = vec3(0.16, 0.11, 0.07);
uniform float alpha = 0.5;
uniform float line_px = 1.0;
uniform int count = 4;
uniform vec3 strokes[5];

void vertex() {
	// facing the camera, as drawn on the page
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	float a = 0.0;
	vec2 d = fwidth(UV);
	for (int i = 0; i < 5; i++) {
		if (i >= count) {
			break;
		}
		vec3 s = strokes[i];
		float across = abs(UV.y - s.z) / max(d.y, 1e-5);
		float line = 1.0 - smoothstep(line_px * 0.5, line_px * 0.5 + 0.75, across);
		float along = step(s.x, UV.x) * step(UV.x, s.y);
		a = max(a, line * along);
	}
	ALBEDO = ink;
	ALPHA = a * alpha;
}
