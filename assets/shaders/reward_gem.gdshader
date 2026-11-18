shader_type spatial;
// One face of a reward's medallion (RewardGem, QW-106 of cycle C18): a disc of old gold, lit by the room, with the
// reward's painted medallion set in it (assets/ui/events) or, where there is no painting, its mark struck in relief on
// dark enamel of the reward's colour (DoorGlyph's marks: the cards' ring and diamond for a Blessing, a coin, a heart,
// the Magia's cut gem, a drop, chevrons for the guardian and Morvath). A rim of gold bevelled outward catches the light.
// It glows a little by itself so it reads in the dark rooms, never past the glow threshold (glow).
render_mode cull_back;

uniform sampler2D medallion : source_color, filter_linear_mipmap, repeat_disable;
uniform bool has_medallion = false;
// 0 none, 1 Blessing, 2 coin, 3 heart, 4 Magia's gem, 5 drop, 6 one chevron, 7 two, 8 three.
uniform int mark = 0;
uniform vec3 enamel : source_color = vec3(0.3, 0.1, 0.1);
uniform vec3 gold : source_color = vec3(0.66, 0.5, 0.26);
// Where the gold rim starts (share of the disc's radius) and how wide its bevel is.
uniform float face_r = 0.84;
uniform float bevel = 0.1;
// How much of its own colour it gives back unlit (the painting and the enamel; the gold a little less).
uniform float glow = 0.32;
uniform float gold_glow = 0.12;
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

// The mark's field: negative inside the struck gold, positive on the enamel.
float mark_sd(vec2 p) {
	if (mark == 1) {
		float ring = abs(length(p) - 0.62) - 0.07;
		return min(ring, sd_diamond(p, 0.36));
	} else if (mark == 2) {
		float coin = abs(length(p) - 0.5) - 0.06;
		return min(coin, sd_box(p, vec2(0.08, 0.28)));
	} else if (mark == 3) {
		vec2 q = vec2(abs(p.x), -p.y + 0.12);
		float lobes = length(q - vec2(0.22, 0.12)) - 0.24;
		float tip = sd_diamond(vec2(p.x, p.y + 0.06) * vec2(1.0, 0.85), 0.42);
		return min(lobes, max(tip, -p.y - 0.42));
	} else if (mark == 4) {
		float g = sd_diamond(p * vec2(1.25, 0.85), 0.5);
		return min(g, max(abs(p.y - 0.1) - 0.025, g - 0.1));
	} else if (mark == 5) {
		vec2 q = p + vec2(0.0, 0.14);
		float bulb = length(q) - 0.32;
		float point = sd_diamond(vec2(p.x * 1.3, p.y - 0.12), 0.42);
		return min(bulb, max(point, -p.y - 0.05));
	} else if (mark >= 6) {
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
		if (has_medallion) {
			vec4 tex = texture(medallion, q * vec2(0.5, -0.5) + 0.5);
			albedo = mix(gold * 0.35, tex.rgb, tex.a);
		} else {
			float d = mark_sd(q);
			// the enamel field, darker toward the rim; the struck mark in gold with a lit and a shaded edge
			vec3 field = enamel * mix(1.0, 0.6, smoothstep(0.4, 1.0, length(q)));
			float inside = 1.0 - smoothstep(-0.01, 0.01, d);
			albedo = mix(field, gold, inside);
			metal = mix(0.0, 0.85, inside);
			rough = mix(0.7, 0.35, inside);
			self_light = mix(glow, gold_glow, inside);
			// relief: the slope of the field across the mark's edge
			float e = 0.01;
			float dx = mark_sd(q + vec2(e, 0.0)) - mark_sd(q - vec2(e, 0.0));
			float dy = mark_sd(q + vec2(0.0, e)) - mark_sd(q - vec2(0.0, e));
			float slope = (1.0 - smoothstep(0.0, edge, abs(d))) * relief;
			n = normalize(vec3(vec2(dx, dy) / (2.0 * e) * slope, 1.0));
		}
	}
	// the face's relief in tangent space (OpenGL convention: +y is up on the face, as p)
	NORMAL_MAP = n * 0.5 + 0.5;
	ALBEDO = albedo;
	METALLIC = metal;
	ROUGHNESS = rough;
	EMISSION = albedo * self_light;
}
