shader_type spatial;
// One face of a reward's medallion (RewardGem, QW-106 of cycle C18): a disc of old gold, lit by the room, with the
// reward's painted medallion set in it (assets/ui/events) or, where there is no painting, its mark struck in relief on
// dark enamel of the reward's colour (DoorGlyph's marks: the cards' ring and diamond for a Blessing, a coin, a heart,
// the Magia's cut gem, a drop, chevrons for the guardian and Morvath). A rim of gold bevelled outward catches the light.
// It glows a little by itself so it reads in the dark rooms, never past the glow threshold (glow).
// AP-1 (ART-01.2): the enamel is its family's (RewardGem.ENAMEL_*, under saturation 0.5 and value 0.45), the mark is
// struck at mark_size of the face (each mark scaled to it), in ivory on the Blessing's petrol (mark_metal); gold's face
// is the coin itself (all_gold: the field in a darker old gold, the mark raised in the plain gold, milled edge).
// It takes no shadows: lit from the side its own rim shadowed half of its face along a straight line (AP-1).
render_mode cull_back, shadows_disabled;

uniform sampler2D medallion : source_color, filter_linear_mipmap, repeat_disable;
uniform bool has_medallion = false;
// 0 none, 1 Blessing, 2 coin, 3 heart, 4 Magia's gem, 5 drop, 6 one chevron, 7 two, 8 three, 9 an ingot (Prata
// Antiga), 10 a torn written leaf (Fragmento de Memória).
uniform int mark = 0;
uniform vec3 enamel : source_color = vec3(0.3, 0.1, 0.1);
uniform vec3 gold : source_color = vec3(0.66, 0.5, 0.26);
// The struck mark's metal (gold, or ivory on the Blessing) and gold's own face (the whole face the coin).
uniform vec3 mark_metal : source_color = vec3(0.66, 0.5, 0.26);
uniform bool all_gold = false;
// Fatia 1: the Memória's face is a leaf of parchment (enamel holds its colour) written in ink (mark_metal): matt, no
// relief, the ink not glowing. Prata Antiga is all_gold with gold the old silver.
uniform bool parchment = false;
uniform float coin_field = 0.62;
// How far across the face the mark reaches (its half-width as a share of the face's radius).
uniform float mark_size = 0.6;
// Where the gold rim starts (share of the disc's radius) and how wide its bevel is.
uniform float face_r = 0.84;
uniform float bevel = 0.1;
// How much of its own colour it gives back unlit (the painting and the enamel; the gold a little less).
uniform float glow = 0.32;
uniform float gold_glow = 0.12;
// The enamel takes less of the room's light and gives more of its own colour back (a warm lamp by a door washed the
// Blessing's petrol to cream): its share of the light and what it adds of its own.
uniform float enamel_diffuse = 0.5;
uniform float enamel_own = 0.3;
// How deep the struck mark looks (normal tilt at its edges) and how wide its edge is (share of the radius).
uniform float relief = 0.7;
uniform float edge = 0.05;

float sd_box(vec2 p, vec2 b) {
	vec2 d = abs(p) - b;
	return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sd_diamond(vec2 p, float r) {
	p = abs(p);
	return (p.x + p.y - r) * 0.7071;
}

float sd_chevron(vec2 p, float w) {
	// an upright chevron (a roof): two bars meeting at the top
	p.x = abs(p.x);
	vec2 a = vec2(0.0, 0.18);
	vec2 b = vec2(0.42, -0.2);
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return length(pa - ba * h) - w;
}

// Each mark's own half extent as drawn below (to scale it to mark_size).
float mark_extent() {
	if (mark == 1) return 0.69;
	if (mark == 2) return 0.56;
	if (mark == 3) return 0.5;
	if (mark == 4) return 0.42;
	if (mark == 5) return 0.46;
	if (mark == 6) return 0.45;
	if (mark == 7) return 0.45;
	if (mark == 8) return 0.48;
	if (mark == 9) return 0.48;
	if (mark == 10) return 0.5;
	return 1.0;
}

// The mark's field: negative inside the struck gold, positive on the enamel.
float mark_sd(vec2 p) {
	if (mark == 1) {
		float ring = abs(length(p) - 0.62) - 0.07;
		return min(ring, sd_diamond(p, 0.36));
	} else if (mark == 2) {
		float coin = abs(length(p) - 0.5) - 0.06;
		return min(coin, sd_box(p, vec2(0.08, 0.28)));
	} else if (mark == 3) {
		// two lobes on top, the point down (y is up on the face)
		float lobes = length(vec2(abs(p.x) - 0.2, p.y - 0.12)) - 0.22;
		float tip = sd_diamond(vec2(p.x, p.y + 0.04) * vec2(1.0, 0.85), 0.42);
		return min(lobes, max(tip, p.y - 0.1));
	} else if (mark == 4) {
		float g = sd_diamond(p * vec2(1.25, 0.85), 0.5);
		return min(g, max(abs(p.y - 0.1) - 0.025, g - 0.1));
	} else if (mark == 5) {
		vec2 q = p + vec2(0.0, 0.14);
		float bulb = length(q) - 0.32;
		float point = sd_diamond(vec2(p.x * 1.3, p.y - 0.12), 0.42);
		return min(bulb, max(point, -p.y - 0.05));
	} else if (mark == 9) {
		// an ingot seen from the front and a little above: its sloped sides, the top's edge a groove across it
		float w = 0.46 - (p.y + 0.22) * 0.45;
		float ingot = max((abs(p.x) - w) * 0.91, abs(p.y) - 0.22);
		return max(ingot, -(abs(p.y - 0.09) - 0.022));
	} else if (mark == 10) {
		// a leaf a little askew, its lower right corner torn away along a ragged line, three lines written on it
		float a = 0.14;
		vec2 q = vec2(cos(a) * p.x - sin(a) * p.y, sin(a) * p.x + cos(a) * p.y);
		float tri = abs(fract((q.x + q.y) * 7.0) - 0.5) * 0.09;
		float leaf = max(sd_box(q, vec2(0.32, 0.42)), (q.x - q.y) * 0.7071 - 0.36 + tri);
		float frame = abs(leaf + 0.02) - 0.035;
		float lines = 10.0;
		for (int i = 0; i < 3; i++) {
			float y = 0.2 - float(i) * 0.15;
			lines = min(lines, sd_box(q - vec2(-0.04 - float(i) * 0.03, y), vec2(0.19 - float(i) * 0.03, 0.025)));
		}
		return min(frame, max(lines, leaf + 0.06));
	} else if (mark >= 6 && mark <= 8) {
		int n = mark - 5;
		float d = 10.0;
		for (int i = 0; i < 3; i++) {
			if (i >= n) {
				break;
			}
			float y = (float(i) - float(n - 1) * 0.5) * 0.3;
			d = min(d, sd_chevron(p - vec2(0.0, y), 0.075));
		}
		return d;
	}
	return 10.0;
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y = -p.y;
	float r = length(p);
	if (r > 1.0) {
		discard;
	}
	vec3 albedo;
	float metal = 0.0;
	float enamel_part = 0.0;
	float rough = 0.6;
	float self_light = glow;
	vec3 n = vec3(0.0, 0.0, 1.0);
	if (r > face_r) {
		// the rim: gold, bevelled outward toward the edge, a dark groove where it meets the face
		float t = clamp((r - face_r) / max(1.0 - face_r, 0.001), 0.0, 1.0);
		vec2 out_dir = p / max(r, 0.001);
		float tilt = smoothstep(1.0 - bevel * 4.0, 1.0, t) - smoothstep(0.0, bevel * 3.0, t) * 0.4;
		n = normalize(vec3(out_dir * tilt * 0.9, 1.0));
		albedo = gold * mix(0.55, 1.0, smoothstep(0.0, 0.25, t));
		metal = 0.85;
		rough = 0.32;
		self_light = gold_glow;
	} else {
		vec2 q = p / face_r;
		float k = mark_extent() / mark_size;
		if (has_medallion) {
			vec4 tex = texture(medallion, q * vec2(0.5, -0.5) + 0.5);
			albedo = mix(gold * 0.35, tex.rgb, tex.a);
		} else {
			vec2 mq = q * k;
			float d = mark_sd(mq) / k;
			// the enamel field, darker toward the rim (gold's: the coin's darker gold, a milled ring inside the rim);
			// the struck mark in its metal with a lit and a shaded edge
			vec3 field = enamel * mix(1.0, 0.6, smoothstep(0.4, 1.0, length(q)));
			float field_metal = 0.0;
			if (all_gold) {
				float mill = step(0.5, fract(atan(q.y, q.x) * 28.0 / 6.2831853)) * smoothstep(0.86, 0.9, length(q));
				field = gold * coin_field * (1.0 - 0.25 * mill);
				field_metal = 0.8;
			}
			if (parchment) {
				// fibres along the leaf and a darker stain toward the rim
				float fib = fract(sin(dot(floor(q * vec2(40.0, 9.0)), vec2(12.9898, 78.233))) * 43758.5453);
				field = enamel * mix(0.92, 1.05, fib) * mix(1.0, 0.8, smoothstep(0.5, 1.0, length(q)));
			}
			float inside = 1.0 - smoothstep(-0.01, 0.01, d);
			enamel_part = all_gold ? 0.0 : 1.0 - inside;
			albedo = mix(field, mark_metal, inside);
			metal = mix(field_metal, parchment ? 0.0 : 0.85, inside);
			rough = mix(all_gold ? 0.45 : 0.7, parchment ? 0.9 : 0.35, inside);
			self_light = mix(all_gold ? gold_glow : glow, parchment ? 0.0 : gold_glow, inside);
			// relief: the slope of the field across the mark's edge
			float e = 0.01;
			float dx = (mark_sd((q + vec2(e, 0.0)) * k) - mark_sd((q - vec2(e, 0.0)) * k)) / k;
			float dy = (mark_sd((q + vec2(0.0, e)) * k) - mark_sd((q - vec2(0.0, e)) * k)) / k;
			float slope = (1.0 - smoothstep(0.0, edge, abs(d))) * (parchment ? 0.0 : relief);
			n = normalize(vec3(vec2(dx, dy) / (2.0 * e) * slope, 1.0));
		}
	}
	// the face's relief in tangent space (OpenGL convention: +y is up on the face, as p)
	NORMAL_MAP = n * 0.5 + 0.5;
	ALBEDO = albedo * mix(1.0, enamel_diffuse, enamel_part);
	METALLIC = metal;
	ROUGHNESS = rough;
	EMISSION = albedo * (self_light + enamel_own * enamel_part);
}
