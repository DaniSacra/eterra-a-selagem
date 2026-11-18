// The body of ground.gdshader and ground_fill.gdshader (C12d, VX-03): everything drawn flat on the floor. Enemy
// warnings (a ring that fills before the hit), burning ground, holy ground, marks and steam. shape: 0 circle, 1 line
// (UV.y along the length), 2 arc (angle opening in arc_half).
// Cycle C11: nothing is drawn past the edge of a round floor (the global floor_round: x, z of its middle and its
// radius; radius 0 is no edge, as in the hall); Morvath's warnings carry his signature (signed, ART-001): a calmer
// red fill with a thin front, a narrower red rim, a fine violet thread just outside it and a band of spectral runes
// past the thread, running along the edge; the storm's lanes show their order of leaving (order_marks, order_level).
// C12d (VX-03): an enemy's (unsigned) warning draws its rim, its front and its chevrons in the first pass
// (ground.gdshader) and its red fill in the second (ground_fill.gdshader, with FILL_PASS): the fill is faint
// (fill_early) while the blow is far off and comes up to fill_max only over the last fill_late of the wind-up, and
// where warnings overlap only the first fill drawn there shows (the stencil), so three of them never add up to more
// than one: the paladin's ring and the way out still read inside them. Morvath's keep their own fill in the first pass.

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
// C12d (VX-09): the circle's rim and marks are a fine line, not a mark of the interface over the bodies: the rim's
// share of the strength, its width as a share of the warnings' rim_m, and the marks' share of the strength and of a turn.
uniform float circle_rim = 0.8;
uniform float circle_rim_width = 0.25;
uniform float circle_mark_light = 0.45;
uniform float circle_mark_span = 0.1;
// Morvath's signature (ART-001): 1 on his warnings. pad_m: meters the quad reaches past the area for the thread and
// the runes (across a line, past a circle's or an arc's curve); nothing past the area hurts.
uniform float signed = 0.0;
uniform float pad_m = 0.0;
uniform float sign_fill = 0.35;
uniform float sign_front_m = 0.12;
uniform float sign_front = 0.6;
uniform vec3 thread_color = vec3(0.496, 0.176, 0.96);
uniform float thread_px = 2.0;
// A dark gap (pixels) between the red rim and the thread (C12a QW-007: touching the rim, the thread blended into it as
// a pink edge and did not read as his violet), and how strongly the thread is drawn (additive on the dark floor).
uniform float thread_gap_px = 2.0;
uniform float thread_light = 1.0;
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
// The storm's lanes share the floor round him (art review P2: six lanes added up to a near white pink in the middle,
// over the order marks and over Morvath): each lane draws only its wedge, out to half the angle to its neighbour on
// either side (wedge.x on the +x side of the quad, wedge.y on the other; 0: the whole lane), so no two ever add, and
// nothing within root_clear_m of its root (him); the fill comes up from root_fill of itself there to all of it
// root_soft_m further out (the lanes' roots meet round him: a solid red disc over the seal hid him and the marks).
uniform vec2 wedge = vec2(0.0);
uniform float root_clear_m = 0.0;
uniform float root_soft_m = 0.0;
uniform float root_fill = 1.0;
// How much of the rims is left at the root (C12a BOSS-001: their bright ends met round him); 1: all of it.
uniform float root_rim = 1.0;
// The faint floor of a line warning's whole area (its share of the colour), and the most light any channel of it adds
// (C12a BOSS-001: the storm's six lanes keep their rims under the glow threshold and their middles let the floor's
// joints show; everything else keeps no cap).
uniform float base_fill = 0.08;
uniform float rim_scale = 1.0;
uniform float light_cap = 64.0;
// C12d (VX-03): an enemy's warning's fill (the second pass), as light added to the floor (not times strength): its
// most at the end of the wind-up, what it shows before that, and the share of the wind-up over which it comes up.
uniform float fill_max = 0.35;
uniform float fill_early = 0.1;
uniform float fill_late = 0.3;
// E5 (the runes, style 3, lines only): the floor that strikes on its own. Every tile of the band (tile_m long) gets a
// frame on its four sides that warms with the wind-up (from 35% of its light), and the band a faint fill (fill_early)
// coming up to fill_max over the last fill_late; amber (its colour), never a circle (D-29).
uniform float tile_m = 0.0;
// C17, QW-107 (ART P1-6: the crossbow's aim and the soldier's pounce read as an opaque red band end to end, the
// strongest thing on the screen): aim_px > 0 draws an unsigned line warning as an aim instead: a thread aim_px pixels
// wide down its middle at aim_light, brighter toward its far end (the last aim_tip of it, up to 1), a bar across that
// end, the filling front on the thread, and the band's own fill (the second pass) only over the end of the wind-up.
uniform float aim_px = 0.0;
uniform float aim_light = 0.5;
uniform float aim_tip = 0.15;

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
	float gap = px * thread_gap_px;
	float w = px * thread_px;
	float thread = smoothstep(gap - px * 0.5, gap + px * 0.5, out_m) * (1.0 - smoothstep(gap + w - px * 0.5, gap + w + px * 0.5, out_m));
	float band0 = gap + w + rune_gap_m;
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

// An unsigned warning's fill as light (the second pass): fill_early over the part already swept (swept 1), coming up
// to fill_max over the last fill_late of the wind-up, and its faint floor (base_fill of the strength) everywhere.
float warning_fill(float swept) {
	float level = mix(fill_early, fill_max, smoothstep(1.0 - fill_late, 1.0, progress));
	return max(swept * level, base_fill * strength);
}

void fragment() {
	if (floor_round.z > 0.0 && length(world.xz - floor_round.xy) > floor_round.z) {
		discard;
	}
	bool sign = signed > 0.5;
#ifdef FILL_PASS
	// only an enemy's own warning has a fill of its own here
	if (sign || style != 0) {
		discard;
	}
#endif
	vec2 uv = UV * 2.0 - 1.0;
	float a = 0.0;
	// light of the fill pass (already times strength)
	float filled = 0.0;
	float rim_light = 1.0;
	vec3 extra = vec3(0.0);
	float root_k = 1.0;
	if (shape == 1) {
		float along = UV.y;
		if (wedge.x > 0.0 || root_clear_m > 0.0) {
			vec2 from_root = vec2(along * length_m, uv.x * (size_m + pad_m));
			if (length(from_root) < root_clear_m) discard;
			root_k = mix(root_fill, 1.0, smoothstep(root_clear_m, root_clear_m + root_soft_m, length(from_root)));
			float turn = atan(from_root.y, max(from_root.x, 1e-4));
			if (wedge.x > 0.0 && (turn > wedge.x || -turn > wedge.y)) discard;
		}
		float side_m = abs(uv.x) * (size_m + pad_m);
		float side = side_m / size_m;
		float rim = clamp(rim_m / size_m, 0.04, 0.2);
		float edge = smoothstep(1.0 - rim, 1.0 - rim * 0.3, side);
		if (side > 1.0) {
			// past the lane's long sides: only the signature
			if (!sign) discard;
			vec2 sg = signature(side_m - size_m, along * length_m);
			extra = (thread_color * sg.x * thread_light + rune_color * sg.y) * root_k;
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
			float fill = 0.0;
			float base = 0.0;
			if (sign) {
				// his: an even fill (the joints of the floor show through) and a thin bright front
				fill = step(tip, front) * sign_fill * root_k;
				base = base_fill * root_k;
				float fw = max(fwidth(tip), 0.001);
				head = (1.0 - smoothstep(sign_front_m * 0.5, sign_front_m * 0.5 + fw, abs(tip - front))) * step(0.02, progress) * sign_front / 0.6;
				rim_light = order_level * rim_scale;
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
			} else {
				filled = warning_fill(step(tip, front));
			}
			a = max(max(edge, far) * 0.9 * rim_light * mix(root_rim, 1.0, root_k), near * 0.3) + fill + head * 0.6 + marks * 0.16 + base;
			if (aim_px > 0.0 && !sign) {
				float px = max(fwidth(x_m), 0.0005);
				float half_w = aim_px * 0.5 * px;
				float thread = 1.0 - smoothstep(half_w - px * 0.5, half_w + px * 0.5, x_m);
				float toward_tip = smoothstep(1.0 - aim_tip, 1.0, along);
				a = max(thread * mix(aim_light, 1.0, toward_tip), far * 0.9) + head * thread * (0.6 - aim_light);
			}
		} else if (style == 3) {
			float along_m = along * length_m;
			float cell = tile_m > 0.0 ? tile_m : length_m;
			float seam = min(mod(along_m, cell), cell - mod(along_m, cell));
			float frame = max(edge, smoothstep(rim_m, rim_m * 0.3, seam));
			float level = mix(fill_early, fill_max, smoothstep(1.0 - fill_late, 1.0, progress));
			a = frame * (0.35 + 0.65 * progress) + level;
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
			extra = thread_color * sg.x * thread_light + rune_color * sg.y;
		} else if (style == 0) {
			float rim = clamp(rim_m / size_m, 0.025, 0.14);
			float ring = smoothstep(1.0 - rim, 1.0 - rim * 0.3, d) * (1.0 - smoothstep(0.985, 1.0, d));
			// the filling front: a bright band where the fill has reached
			float front = smoothstep(progress - 0.06, progress, d) * step(d, progress) * 0.6;
			float fill = 0.0;
			float base = 0.0;
			if (sign) {
				float fw = max(fwidth(dm), 0.001);
				float front_m = progress * size_m;
				fill = step(d, progress) * sign_fill;
				front = (1.0 - smoothstep(sign_front_m * 0.5, sign_front_m * 0.5 + fw, abs(dm - front_m))) * step(0.02, progress) * sign_front;
				base = 0.06;
			} else {
				filled = warning_fill(step(d, progress));
			}
			if (shape == 2) {
				// the arc's straight sides get the same rim as its curve (until cycle 8 only the curve had one, and a
				// wide arc read as a blot): the slice of floor the blow sweeps, and which way it opens
				float side_m = (arc_half - ang) * d * size_m;
				ring = max(ring, smoothstep(rim_m, rim_m * 0.3, side_m) * step(0.08, d) * 0.85);
			}
			a = ring + fill + front + base;
		} else if (style == 2) {
			// the paladin's circle of light: a veil thin enough for the floor to show through, read by its rim
			// (a fine line of fixed width) and a few short marks turning slowly just inside it
			float rim = clamp(rim_m * circle_rim_width / size_m, 0.005, 0.04);
			float ring = smoothstep(1.0 - rim * 1.6, 1.0 - rim * 0.8, d) * (1.0 - smoothstep(1.0 - rim * 0.4, 1.0, d));
			float turn = fract((atan(uv.y, uv.x) + TIME * 0.3) / 6.28318 * circle_marks);
			float mark = smoothstep(0.0, 0.02, turn) * (1.0 - smoothstep(circle_mark_span - 0.02, circle_mark_span, turn));
			float lane = 1.0 - rim * 6.0;
			mark *= smoothstep(lane - rim * 1.1, lane - rim * 0.6, d) * (1.0 - smoothstep(lane + rim * 0.1, lane + rim * 0.6, d));
			a = ring * circle_rim + mark * circle_mark_light + circle_veil * (0.6 + 0.4 * d);
		} else {
			float n = noise(uv * 4.0 + vec2(TIME * 0.7, -TIME * 0.5)) * 0.6 + noise(uv * 9.0 - TIME) * 0.4;
			float edge = smoothstep(1.0 - clamp(rim_m * 2.0 / size_m, 0.06, 0.25), 1.0, d);
			a = (0.25 + 0.55 * n) * (1.0 - smoothstep(0.9, 1.0, d)) + edge * 0.35 * (1.0 - smoothstep(0.97, 1.0, d));
		}
	}
#ifdef FILL_PASS
	if (filled <= 0.0) discard;
	ALBEDO = color.rgb * filled * fade;
#else
	ALBEDO = min(color.rgb * a * strength, vec3(light_cap)) * fade + extra * fade;
#endif
}
