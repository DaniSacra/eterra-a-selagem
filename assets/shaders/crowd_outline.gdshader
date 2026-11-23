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

// Eterra Stylized (STY-06, T20): with the global art_style at 1 every figure of the crowd has this shell (CrowdRenderer
// gives the common ones one too), style_width meters wide in style_color; the classic look keeps width and color.
global uniform float art_style;
uniform float style_width = 0.04;
uniform vec3 style_color : source_color = vec3(0.07, 0.06, 0.06);
// In that look the shell is also pushed style_push meters away from the camera, so on open cloth (Morvath's cloak, a
// robe's hem) its inflated back faces stay behind the body and only the edge past the silhouette shows.
uniform float style_push = 0.25;
// Elites and guardians (style_elite 1, never the boss): the shell is a dark old gold, style_elite_width meters wide, so
// they read as elites at a glance in that look (the dark ink took the place of the classic's gold edge).
uniform float style_elite = 0.0;
uniform float style_elite_width = 0.05;
uniform vec3 style_elite_color : source_color = vec3(0.36, 0.27, 0.12);

varying vec4 state;

#include "res://assets/shaders/crowd_pose.gdshaderinc"

void vertex() {
	vec3 at;
	vec3 facing;
	crowd_pose(VERTEX_ID, COLOR, at, facing);
	NORMAL = facing;
	state = INSTANCE_CUSTOM;
	float w = art_style > 0.5 ? mix(style_width, style_elite_width, style_elite) : width;
	VERTEX = crowd_away(VERTEX_ID, INSTANCE_CUSTOM.a, at + facing * w / max(length(MODEL_MATRIX[0].xyz), 0.001));
	if (art_style > 0.5) {
		// away from the camera, in the model's own space (uniform scale: the transpose undoes the turn)
		float scale = max(length(MODEL_MATRIX[0].xyz), 0.001);
		vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		VERTEX += transpose(mat3(MODEL_MATRIX)) * (normalize(world - CAMERA_POSITION_WORLD) * style_push) / (scale * scale);
	}
}

void fragment() {
	if (state.a > 0.0) {
		discard;
	}
	vec3 ink = art_style > 0.5 ? mix(style_color, style_elite_color, style_elite) : color * intensity;
	ALBEDO = mix(mix(ink, flash_color, clamp(state.r, 0.0, 1.0)), absorb_color * absorb_light, clamp(-state.r, 0.0, 1.0));
}
