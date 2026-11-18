// Eterra Stylized (STY-06, T23; docs/art/stylized_spec.md 3.3): the tail of a sword arc as broken brush strokes, shared
// by its light (slash.gdshader) and its ink (slash_ink.gdshader). Over the back half of the ribbon the arc is cut
// into strokes running along it, stroke_pitch meters apart across it, each 0.08 to 0.18 m wide (stroke_width), each
// ending at its own point of the tail; as the slash dies (rest) the ends draw back toward the head, so the strokes
// go from the tail first. The front half and the leading edge stay whole. Read only with the global art_style at 1.

uniform float stroke_pitch = 0.2;
uniform vec2 stroke_width = vec2(0.08, 0.18);
// Where along the tail (k: 0 at the head, 1 at its end) the strokes take over, and how far back a stroke may end.
uniform float stroke_from = 0.42;
uniform vec2 stroke_end = vec2(0.6, 1.0);

float stroke_hash(vec2 p) {
	return fract(sin(dot(p, vec2(41.3, 289.1))) * 43758.5453);
}

// 1 where the ribbon is kept at (y_m meters across the band from its inner side, k along the tail, rest of its life),
// 0 between the strokes and past their ends. px_m: a pixel in meters across (for a soft side).
float slash_strokes(float y_m, float k, float rest, float px_m) {
	float id = floor(y_m / stroke_pitch);
	float width = mix(stroke_width.x, stroke_width.y, stroke_hash(vec2(id, 3.0)));
	float centre = (id + 0.3 + 0.4 * stroke_hash(vec2(id, 11.0))) * stroke_pitch;
	float soft = max(px_m, 0.005);
	float in_stroke = 1.0 - smoothstep(width * 0.5 - soft, width * 0.5 + soft, abs(y_m - centre));
	float end = mix(stroke_end.x, stroke_end.y, stroke_hash(vec2(id, 23.0))) - rest * 0.5;
	float kept = in_stroke * (1.0 - smoothstep(end - 0.04, end, k));
	float back = smoothstep(stroke_from, stroke_from + 0.08, k);
	return mix(1.0, kept, back);
}
