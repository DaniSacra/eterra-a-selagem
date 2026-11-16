shader_type spatial;
// Second pass on elites and the boss in the crowd: the body pushed out along its normals and drawn from behind,
// a thin dark ink stroke around the figure (CrowdRenderer.OUTLINE_COLOR; until cycle 5 a glowing gold halo). Same
// per-instance state as crowd.gdshader:
// on a blow it warms a little toward flash_color (old gold when the blow landed on its armor: state.r below 0) and
// goes away while the body dissolves. Never white: drawn from behind, on an open mesh (Morvath's torn cloak) the
// stroke shows as wide patches inside the body, and a white flash there (it went to 3.0, over the glow threshold)
// left a burning boss nearly white (M-1).
render_mode unshaded, cull_front, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(1.0, 0.2, 0.25);
// Meters in the world: the same thin rim on a skeleton and on a guardian twice its size.
uniform float width = 0.05;
uniform float intensity = 2.4;
// The gleam of armor that took a blow.
uniform vec3 absorb_color : source_color = vec3(0.62, 0.46, 0.22);
uniform float absorb_light = 2.0;
// The stroke at the peak of a blow's flash: a warm dark, under the body's own flash (crowd.gdshader flash_cap).
uniform vec3 flash_color : source_color = vec3(0.3, 0.22, 0.14);

varying vec4 state;

void vertex() {
	state = INSTANCE_CUSTOM;
	VERTEX += normalize(NORMAL) * width / max(length(MODEL_MATRIX[0].xyz), 0.001);
}

void fragment() {
	if (state.a > 0.0) {
		discard;
	}
	ALBEDO = mix(mix(color * intensity, flash_color, clamp(state.r, 0.0, 1.0)), absorb_color * absorb_light, clamp(-state.r, 0.0, 1.0));
}
