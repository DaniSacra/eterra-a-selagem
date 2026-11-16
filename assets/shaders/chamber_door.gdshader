shader_type spatial;
// The sealed door of the Chamber of the Seal (docs/art/boss_chamber_spec.md 2.5 and 7): two leaves of dark wood and
// iron with a violet cast, in a pointed opening; ironwork of old gold drawing the seal (a ring, eight spokes from it
// out to the frame, the frame round the leaves); the seam between the leaves is the violet bolt: a broken line from
// the porch up to the arch's point, with short branches and a gem where it crosses the ring. It never opens. In the
// last phase the seam throbs from violet toward the spectral blue; when Morvath is sealed it closes from the foot up
// and the gold keeps a faint light. The quad's middle is the opening's middle; UV.y runs down.
render_mode diffuse_burley, specular_schlick_ggx, cull_disabled;

// The opening (m): width, height; the arch's springing over the foot and the radius of its two arcs.
uniform vec2 size = vec2(3.4, 5.0);
uniform vec2 arch = vec2(2.48, 2.72);
// Wood and iron of the leaves, the planks' width, the old gold of the ironwork (its width, the ring's radius and height).
uniform vec3 wood : source_color = vec3(0.2, 0.12, 0.22);
uniform vec3 iron : source_color = vec3(0.08, 0.07, 0.1);
uniform float plank = 0.28;
uniform vec3 gold : source_color = vec3(0.478, 0.384, 0.22);
uniform vec3 gold_light : source_color = vec3(1.0, 0.8, 0.44);
uniform float band = 0.12;
uniform vec2 ring = vec2(1.3, 2.6);
// The seam: its width (m), its colour at full light (greatest channel 1), its light (rest 1.4), how far up it is
// closed (0 open, 1 closed to the top), how much toward the spectral blue (0 violet), the gem's size; the ironwork's
// own faint light (after the sealing).
uniform float seam_width = 0.06;
uniform vec3 seam_color : source_color = vec3(0.52, 0.18, 1.0);
uniform vec3 seam_spirit : source_color = vec3(0.32, 0.6, 1.0);
uniform float seam_light = 1.4;
uniform float seam_closed = 0.0;
uniform float seam_blue = 0.0;
uniform float gem = 0.12;
uniform float gold_glow = 0.0;

float hash1(float x) {
	return fract(sin(x * 12.9898) * 43758.5453);
}

float line(float d, float w) {
	return 1.0 - smoothstep(w * 0.35, w * 0.5, d);
}

float seg(vec2 p, vec2 a, vec2 b) {
	vec2 ab = b - a;
	return length(p - a - ab * clamp(dot(p - a, ab) / dot(ab, ab), 0.0, 1.0));
}

// How far inside the opening p is (m; negative outside): the jambs and the two arcs of the point.
float inside(vec2 p) {
	float off = abs(p.x);
	float cx = arch.y - size.x * 0.5;
	return p.y > arch.x ? arch.y - length(vec2(off + cx, p.y - arch.x)) : size.x * 0.5 - off;
}

// The seam's x at height y: a broken line, kinked every so often.
float seam_x(float y) {
	float k = floor(y / 0.35);
	float f = fract(y / 0.35);
	float a = (hash1(k) - 0.5) * 0.12;
	float b = (hash1(k + 1.0) - 0.5) * 0.12;
	return mix(a, b, f);
}

void fragment() {
	vec2 p = vec2((UV.x - 0.5) * size.x, (1.0 - UV.y) * size.y);
	float in_d = inside(p);
	if (in_d < 0.0 || p.y < 0.0) {
		discard;
	}
	// the leaves: upright planks, iron straps across, the frame of gold round them
	float pl = fract(p.x / plank);
	vec3 c = wood * (0.85 + 0.3 * hash1(floor(p.x / plank) + 3.0)) * (0.8 + 0.2 * smoothstep(0.0, 0.08, min(pl, 1.0 - pl)));
	float straps = line(abs(fract(p.y / 1.25) - 0.5) * 1.25 - 0.55, 0.14);
	c = mix(c, iron, straps);
	float frame = line(in_d - band * 0.5, band);
	// the ring and its eight spokes out to the frame
	vec2 rc = p - vec2(0.0, ring.y);
	float rd = length(rc);
	float g = max(frame, line(abs(rd - ring.x), band));
	float sp = 0.0;
	for (int i = 0; i < 8; i++) {
		float a = float(i) * 0.7853982;
		vec2 dir = vec2(cos(a), sin(a));
		vec2 from = vec2(0.0, ring.y) + dir * ring.x;
		sp = max(sp, line(seg(p, from, from + dir * 4.0), band) * step(ring.x, rd));
	}
	g = max(g, sp * step(0.02, in_d));
	c = mix(c, gold * (0.8 + 0.4 * hash1(floor(p.y * 7.0) + floor(p.x * 7.0) * 13.0)), g);
	// the seam: the violet bolt between the leaves, with short branches, closed from the foot up when sealed
	float sx = seam_x(p.y);
	float sd = abs(p.x - sx);
	float k = floor(p.y / 0.7);
	float br_y = (k + 0.5) * 0.7;
	float side = hash1(k + 7.0) > 0.5 ? 1.0 : -1.0;
	vec2 br_a = vec2(seam_x(br_y), br_y);
	vec2 br_b = br_a + vec2(side * 0.28, 0.18);
	float branch = step(0.45, hash1(k + 11.0)) * line(seg(p, br_a, br_b), seam_width * 0.6);
	float bolt = max(line(sd, seam_width), branch);
	float open = step(seam_closed * size.y, p.y);
	vec3 col = mix(seam_color, seam_spirit, seam_blue);
	float halo = (1.0 - smoothstep(0.0, 0.25, sd)) * 0.25;
	// the gem where the seam crosses the ring (its upper crossing)
	float gm = 1.0 - smoothstep(gem * 0.4, gem * 0.5, length(p - vec2(sx, ring.y + ring.x)));
	c = mix(c, c * 0.3, bolt);
	ALBEDO = c;
	ROUGHNESS = mix(0.8, 0.45, g);
	METALLIC = 0.4 * g;
	vec3 e = col * (bolt + halo + gm) * seam_light * open;
	e += gold_light * g * gold_glow;
	EMISSION = e;
}
