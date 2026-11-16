shader_type spatial;
// Everything drawn flat on the floor: enemy warnings (a ring that fills before the hit), burning ground, holy ground,
// marks and steam. shape: 0 circle, 1 line (UV.y along the length), 2 arc (angle opening in arc_half).
// Cycle C11: nothing is drawn past the edge of a round floor (the global floor_round: x, z of its middle and its
// radius; radius 0 is no edge, as in the hall); Morvath's warnings carry his signature (signed, ART-001): a calmer
// red fill with a thin front, a narrower red rim, a fine violet thread just outside it and a band of spectral runes
// past the thread, running along the edge; the storm's lanes show their order of leaving (order_marks, order_level).
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
// Morvath's signature (ART-001): 1 on his warnings. pad_m: meters the quad reaches past the area for the thread and
// the runes (across a line, past a circle's or an arc's curve); nothing past the area hurts.
uniform float signed = 0.0;
uniform float pad_m = 0.0;
uniform float sign_fill = 0.35;
uniform float sign_front_m = 0.12;
uniform float sign_front = 0.6;
uniform vec3 thread_color = vec3(0.496, 0.176, 0.96);
uniform float thread_px = 2.0;
uniform vec3 rune_color = vec3(0.16, 0.3, 0.5);
uniform float rune_gap_m = 0.04;
uniform float rune_band_m = 0.3;
uniform float rune_speed = 0.4;
// The storm's order (lines only): marks at the root (0: none), from mark_from_m meters along it, and the share of its
// rim's light (the next to leave 1.0, the later ones dimmer).
uniform float order_marks = 0.0;
uniform float order_level = 1.0;
uniform float mark_from_m = 2.2;
uniform float mark_step_m = 0.32;
uniform float mark_r_m = 0.09;
uniform vec3 mark_color = vec3(0.32, 0.6, 1.0);

global uniform vec3 floor_round;

varying vec3 world;

#include "res://assets/shaders/rune_glyph.gdshaderinc"

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), u.x), u.y);
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// The thread and the runes past the edge of a signed warning: out_m meters out of the area, at run_m meters along
// its edge. Returns (thread, runes).
vec2 signature(float out_m, float run_m) {
	float px = max(fwidth(out_m), 0.0005);
	float w = px * thread_px;
	float thread = (1.0 - smoothstep(w, w + px, out_m)) * step(0.0, out_m);
	float band0 = w + rune_gap_m;
	float across = out_m - band0;
	float runes = 0.0;
	if (across > 0.0 && across < rune_band_m) {
		float cell = rune_band_m * 0.8;
		float along = run_m - TIME * rune_speed;
		float id = floor(along / cell);
		vec2 q = vec2(fract(along / cell) * cell, across);
		float dist = rune_glyph(q, vec2(cell, rune_band_m), id);
		runes = 1.0 - smoothstep(0.012, 0.012 + px * 1.5, dist);
	}
	return vec2(thread, runes);
}

void fragment() {
	if (floor_round.z > 0.0 && length(world.xz - floor_round.xy) > floor_round.z) {
		discard;
	}
	vec2 uv = UV * 2.0 - 1.0;
	float a = 0.0;
	float rim_light = 1.0;
	vec3 extra = vec3(0.0);
	bool sign = signed > 0.5;
	if (shape == 1) {
		float along = UV.y;
		float side_m = abs(uv.x) * (size_m + pad_m);
		float side = side_m / size_m;
		float rim = clamp(rim_m / size_m, 0.04, 0.2);
		float edge = smoothstep(1.0 - rim, 1.0 - rim * 0.3, side);
		if (side > 1.0) {
			// past the lane's long sides: only the signature
			if (!sign) discard;
			vec2 sg = signature(side_m - size_m, along * length_m);
			extra = thread_color * sg.x + rune_color * sg.y;
		} else if (style == 0) {
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
			if (sign) {
				// his: an even fill (the joints of the floor show through) and a thin bright front
				fill = step(tip, front) * sign_fill;
				float fw = max(fwidth(tip), 0.001);
				head = (1.0 - smoothstep(sign_front_m * 0.5, sign_front_m * 0.5 + fw, abs(tip - front))) * step(0.02, progress) * sign_front / 0.6;
				rim_light = order_level;
				if (order_marks > 0.5) {
					// the order of leaving: as many spectral marks in a row at the root as its place in the order
					float at_m = along * length_m - mark_from_m;
					float k = floor(at_m / mark_step_m + 0.5);
					vec2 c = vec2(at_m - k * mark_step_m, x_m);
					float dot_m = length(c);
					float fw2 = max(fwidth(dot_m), 0.001);
					float on = step(-0.5, k) * step(k, order_marks - 0.5);
					extra += mark_color * on * (1.0 - smoothstep(mark_r_m, mark_r_m + fw2, dot_m)) * 0.9;
				}
			}
			a = max(max(edge, far) * 0.9 * rim_light, near * 0.3) + fill + head * 0.6 + marks * 0.16 + 0.08;
		} else {
			a = (1.0 - side * side) * (0.5 + 0.5 * noise(vec2(uv.x * 3.0, along * 8.0 - TIME * 2.0)));
		}
	} else {
		float dm = length(uv) * (size_m + pad_m);
		float d = dm / size_m;
		if (dm > size_m + pad_m) discard;
		float ang = abs(atan(uv.x, -uv.y));
		if (shape == 2 && ang > arc_half) discard;
		if (d > 1.0) {
			// past the curve: only the signature
			if (!sign) discard;
			vec2 sg = signature(dm - size_m, atan(uv.x, -uv.y) * size_m);
			extra = thread_color * sg.x + rune_color * sg.y;
		} else if (style == 0) {
			float rim = clamp(rim_m / size_m, 0.025, 0.14);
			float ring = smoothstep(1.0 - rim, 1.0 - rim * 0.3, d) * (1.0 - smoothstep(0.985, 1.0, d));
			float fill = step(d, progress) * 0.38 + smoothstep(progress - 0.06, progress, d) * step(d, progress) * 0.6;
			if (sign) {
				float fw = max(fwidth(dm), 0.001);
				float front_m = progress * size_m;
				fill = step(d, progress) * sign_fill
					+ (1.0 - smoothstep(sign_front_m * 0.5, sign_front_m * 0.5 + fw, abs(dm - front_m))) * step(0.02, progress) * sign_front;
			}
			if (shape == 2) {
				// the arc's straight sides get the same rim as its curve (until cycle 8 only the curve had one, and a
				// wide arc read as a blot): the slice of floor the blow sweeps, and which way it opens
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
	ALBEDO = color.rgb * a * strength * fade + extra * fade;
}
