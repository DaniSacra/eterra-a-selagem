shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix, skip_vertex_transform;
// State pips over enemies: one billboard quad per pip. INSTANCE_CUSTOM.x = shape (0 diamond, 1 flake, 2 spark);
// the instance color tints it. Never red: the colors come from ElementLook.
varying flat float shape;
varying flat vec4 tint;

void vertex() {
	shape = INSTANCE_CUSTOM.x;
	tint = COLOR;
	vec4 center = MODELVIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0);
	float s = length(MODEL_MATRIX[0].xyz);
	VERTEX = (center.xyz + vec3(VERTEX.xy * s, 0.0));
	NORMAL = vec3(0.0, 0.0, 1.0);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d;
	if (shape < 0.5) {
		d = abs(p.x) + abs(p.y) - 0.85; // diamond
	} else if (shape < 1.5) {
		vec2 a = abs(p);
		float arms = min(min(a.x, a.y), abs(a.x - a.y) * 0.7071) - 0.13; // flake: cross plus diagonals
		d = max(arms, length(p) - 0.9);
	} else {
		vec2 a = abs(p);
		d = pow(a.x, 0.5) + pow(a.y, 0.5) - 0.95; // four-point spark (astroid)
	}
	float edge = fwidth(d) + 0.02;
	float alpha = 1.0 - smoothstep(0.0, edge, d);
	ALBEDO = tint.rgb;
	ALPHA = alpha * tint.a;
	if (ALPHA < 0.02) discard;
}
