shader_type spatial;
// Second pass on elites and the boss in the crowd: the body pushed out along its normals and drawn from behind,
// a thick glowing outline (Hades-style read of "this one matters"). Same per-instance state as crowd.gdshader:
// it flashes white with the body and goes away while the body dissolves.
render_mode unshaded, cull_front, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(1.0, 0.2, 0.25);
// Meters in the model's own space (the instance's size scales it).
uniform float width = 0.05;
uniform float intensity = 2.4;

varying vec4 state;

void vertex() {
	state = INSTANCE_CUSTOM;
	VERTEX += normalize(NORMAL) * width;
}

void fragment() {
	if (state.a > 0.0) {
		discard;
	}
	ALBEDO = mix(color * intensity, vec3(3.0), clamp(state.r, 0.0, 1.0));
}
