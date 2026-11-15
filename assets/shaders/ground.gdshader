shader_type spatial;
// Everything drawn flat on the floor: enemy warnings (a ring that fills before the hit), burning ground, holy ground,
// marks and steam. shape: 0 circle, 1 line (UV.y along the length), 2 arc (angle opening in arc_half).
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled, depth_prepass_alpha;

uniform vec4 color : source_color = vec4(1.0, 0.2, 0.1, 1.0);
uniform float progress = 0.0;
uniform int shape = 0;
uniform float arc_half = 1.0;
// 0 = warning (outline + filling), 1 = area (soft animated fill), 2 = the paladin's circle of light (rim and marks)
uniform int style = 0;
uniform float strength = 1.0;
uniform float fade = 1.0;
// Meters from the middle to the edge (circle and arc) or half the width (line), and the width of the bright rim
// in meters: the rim stays thin on big areas instead of growing with them. The area itself is the attack's.
uniform float size_m = 1.0;
uniform float rim_m = 0.28;
// A line warning's length in meters (its chevrons keep their size on short and long lines).
uniform float length_m = 4.0;
// The paladin's circle (style 2): how much of its light fills the inside, and how many marks turn inside its rim.
uniform float circle_veil = 0.02;
uniform float circle_marks = 7.0;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), u.x), u.y);
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float a = 0.0;
	if (shape == 1) {
		float along = UV.y;
		float side = abs(uv.x);
		float rim = clamp(rim_m / size_m, 0.04, 0.2);
		float edge = smoothstep(1.0 - rim, 1.0 - rim * 0.3, side) * step(side, 1.0);
		if (style == 0) {
			// which way the blow goes (cycle 8): the far end is the bright one, the near end only a faint line, the
			// filling front is a chevron pointing ahead, and faint chevrons wait in the part still to fill
			float far = smoothstep(0.96, 0.995, along);
			float near = 1.0 - smoothstep(0.005, 0.04, along);
			float x_m = side * size_m;
			float front = progress * (length_m + size_m * 0.7);
			float tip = along * length_m + x_m * 0.7;
			float head = smoothstep(rim_m * 1.4, rim_m * 0.4, abs(tip - front)) * step(0.02, progress);
			float step_m = max(size_m * 1.6, 0.9);
			float lane = fract((tip - front) / step_m);
			float marks = smoothstep(0.0, 0.08, lane) * (1.0 - smoothstep(0.16, 0.24, lane)) * step(front + rim_m, tip);
			marks *= step(tip, length_m - rim_m * 1.5) * (1.0 - edge);
			// the fill brightens toward its front, as the circle's does: the eye follows it to where the blow lands
			float fill = step(tip, front) * (0.3 + 0.35 * smoothstep(front - 1.2, front, tip));
			a = max(max(edge, far) * 0.9, near * 0.3) + fill + head * 0.6 + marks * 0.16 + 0.08;
		} else {
			a = (1.0 - side * side) * (0.5 + 0.5 * noise(vec2(uv.x * 3.0, along * 8.0 - TIME * 2.0)));
		}
	} else {
		float d = length(uv);
		if (d > 1.0) discard;
		if (shape == 2) {
			float ang = abs(atan(uv.x, -uv.y));
			if (ang > arc_half) discard;
		}
		if (style == 0) {
			float rim = clamp(rim_m / size_m, 0.025, 0.14);
			float ring = smoothstep(1.0 - rim, 1.0 - rim * 0.3, d) * (1.0 - smoothstep(0.985, 1.0, d));
			float fill = step(d, progress) * 0.38 + smoothstep(progress - 0.06, progress, d) * step(d, progress) * 0.6;
			if (shape == 2) {
				// the arc's straight sides get the same rim as its curve (until cycle 8 only the curve had one, and a
				// wide arc read as a blot): the slice of floor the blow sweeps, and which way it opens
				float ang = abs(atan(uv.x, -uv.y));
				float side_m = (arc_half - ang) * d * size_m;
				ring = max(ring, smoothstep(rim_m, rim_m * 0.3, side_m) * step(0.08, d) * 0.85);
			}
			a = ring + fill + 0.06;
		} else if (style == 2) {
			// the paladin's circle of light: a veil thin enough for the floor to show through, read by its rim
			// (a fine line of fixed width) and a few short marks turning slowly just inside it
			float rim = clamp(rim_m * 0.5 / size_m, 0.012, 0.08);
			float ring = smoothstep(1.0 - rim * 1.6, 1.0 - rim * 0.8, d) * (1.0 - smoothstep(1.0 - rim * 0.4, 1.0, d));
			float turn = fract((atan(uv.y, uv.x) + TIME * 0.3) / 6.28318 * circle_marks);
			float mark = smoothstep(0.0, 0.03, turn) * (1.0 - smoothstep(0.17, 0.2, turn));
			float lane = 1.0 - rim * 4.5;
			mark *= smoothstep(lane - rim * 1.1, lane - rim * 0.6, d) * (1.0 - smoothstep(lane + rim * 0.1, lane + rim * 0.6, d));
			a = ring + mark * 0.55 + circle_veil * (0.6 + 0.4 * d);
		} else {
			float n = noise(uv * 4.0 + vec2(TIME * 0.7, -TIME * 0.5)) * 0.6 + noise(uv * 9.0 - TIME) * 0.4;
			float edge = smoothstep(1.0 - clamp(rim_m * 2.0 / size_m, 0.06, 0.25), 1.0, d);
			a = (0.25 + 0.55 * n) * (1.0 - smoothstep(0.9, 1.0, d)) + edge * 0.35 * (1.0 - smoothstep(0.97, 1.0, d));
		}
	}
	ALBEDO = color.rgb * a * strength * fade;
}
