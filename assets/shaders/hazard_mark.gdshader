shader_type spatial;
// The marks of a hazard piece (docs/art/sw_g7_hazard_grammar.md 1 and 3; HazardPiece), multiplied over the stone they
// lie on (a quad on the floor or on a face): the dark joint round a loose slab, its sinking (the joint darker and wider,
// the inside a shade down, a shadow along the edges nearest the light) and the chevrons cut in dark old gold, the one
// word of the grammar. Lengths in metres over the quad (size). Multiplied, so it works the same on both looks and on
// the Compatibility renderer, and it never lights anything.
render_mode blend_mul, unshaded, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec2 size = vec2(3.0, 3.0);
// the joint round the quad's border (0: none) and how dark it is at rest; sink 0..1 (4 cm down: darker, wider)
uniform float joint = 0.0;
uniform float joint_mul = 0.42;
uniform float joint_sunk = 0.09;
uniform float sink = 0.0;
uniform float sink_inside = 0.9;
uniform float sink_edge = 0.62;
uniform float sink_edge_width = 0.1;
// the light's side, in the quad's own axes (x, y): the edges facing it take the sinking's shadow
uniform vec2 light_side = vec2(-0.5, -0.85);
// chevrons: four pointing in (one a side) or `chev_count` nested at chev_at pointing chev_dir (metres, quad axes)
uniform float chev_four = 0.0;
uniform int chev_count = 0;
uniform vec2 chev_at = vec2(0.0);
uniform vec2 chev_dir = vec2(0.0, 1.0);
uniform float chev_open = 0.42;
uniform float chev_stroke = 0.07;
uniform float chev_gap = 0.17;
uniform float chev_in = 0.5;
uniform vec3 chev_mul : source_color = vec3(0.66, 0.54, 0.36);
// pale dust in the chevrons of a sleeping piece (towards no mark)
uniform float dust = 0.0;

float chevron(vec2 p, vec2 tip, vec2 d) {
	vec2 q = p - tip;
	vec2 n = vec2(-d.y, d.x);
	vec2 lq = vec2(dot(q, d), abs(dot(q, n)));
	vec2 arm = vec2(-0.7071, 0.7071);
	float t = clamp(dot(lq, arm), 0.0, chev_open * 0.7071);
	float dist = length(lq - arm * t);
	return 1.0 - smoothstep(chev_stroke * 0.38, chev_stroke * 0.5, dist);
}

void fragment() {
	vec2 p = (UV - 0.5) * size;
	vec2 half_size = size * 0.5;
	vec3 mul = vec3(1.0);
	if (joint > 0.0) {
		vec2 e = half_size - abs(p);
		float edge = min(e.x, e.y);
		float w = mix(joint, joint_sunk, sink);
		float in_joint = 1.0 - smoothstep(w * 0.75, w, edge);
		mul *= mix(1.0, mix(joint_mul, joint_mul * 0.6, sink), in_joint);
		// sunk: the inside a shade down, a shadow inside the edges facing the light (the step down)
		vec2 ls = normalize(light_side);
		float lit_edge = max(step(0.0, p.x * ls.x) * (1.0 - smoothstep(0.0, sink_edge_width, e.x - w)) * abs(ls.x),
			step(0.0, p.y * ls.y) * (1.0 - smoothstep(0.0, sink_edge_width, e.y - w)) * abs(ls.y));
		float inside = 1.0 - in_joint;
		mul *= mix(1.0, sink_inside, sink * inside);
		mul *= mix(1.0, sink_edge, sink * inside * clamp(lit_edge * 1.4, 0.0, 1.0));
	}
	float c = 0.0;
	if (chev_four > 0.5) {
		c = max(c, chevron(p, vec2(half_size.x - chev_in - chev_open * 0.35, 0.0), vec2(-1.0, 0.0)));
		c = max(c, chevron(p, vec2(-half_size.x + chev_in + chev_open * 0.35, 0.0), vec2(1.0, 0.0)));
		c = max(c, chevron(p, vec2(0.0, half_size.y - chev_in - chev_open * 0.35), vec2(0.0, -1.0)));
		c = max(c, chevron(p, vec2(0.0, -half_size.y + chev_in + chev_open * 0.35), vec2(0.0, 1.0)));
	}
	vec2 d = normalize(chev_dir);
	for (int k = 0; k < chev_count; k++) {
		c = max(c, chevron(p, chev_at + d * (float(k) - float(chev_count - 1) * 0.5) * chev_gap, d));
	}
	mul *= mix(vec3(1.0), mix(chev_mul, vec3(1.0), dust * 0.7), c);
	ALBEDO = mul;
}
