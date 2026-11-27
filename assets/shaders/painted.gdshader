shader_type spatial;
// GP-8 (PaintedHall): the room's painting projected from the painter's camera onto simple
// geometry. The colour is the painting's own (no ambient, no lights); lights only do two small things: the moon's
// shadows (the hero's and the fighters') tint it cold, and the scene's omni lights (torches, fires) add a little warmth.
render_mode ambient_light_disabled, specular_disabled, fog_disabled, cull_disabled;

uniform sampler2D painting : source_color, filter_linear_mipmap, repeat_disable;
// world -> clip of the painter's camera (PaintedHall.projector)
uniform mat4 projector;
uniform float exposure = 1.0;
uniform float shadow_strength = 0.15;
uniform vec3 shade_tint = vec3(0.5, 0.6, 0.82);
uniform float torch_boost = 0.15;
// A little unsharp mask on the painting (it is shown 1.5 to 2.5 times larger than its pixels at the game's camera).
uniform float sharpen = 0.5;
// The pieces the paladin walks behind open round him, as the room's stone does (see_through.gdshaderinc).
uniform float see_through = 0.0;
uniform float see_radius = 2.2;
uniform float see_height = 1.3;
uniform float see_keep = 0.1;
uniform float see_gap = 0.4;

#include "res://assets/shaders/see_through.gdshaderinc"

varying vec3 world_pos;


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec4 c = projector * vec4(world_pos, 1.0);
	vec2 uv = c.xy / c.w * vec2(0.5, -0.5) + 0.5;
	if (see_through > 0.0 && see_through_hole(VERTEX, FRAGCOORD.xy, VIEW_MATRIX, PROJECTION_MATRIX, see_through, see_radius, see_height, see_keep, see_gap)) {
		discard;
	}
	vec3 own = texture(painting, uv).rgb;
	vec3 col = (own + (own - textureLod(painting, uv, 1.5).rgb) * sharpen) * exposure;
	ALBEDO = col;
	EMISSION = col;
	ROUGHNESS = 1.0;
}

void light() {
	if (LIGHT_IS_DIRECTIONAL) {
		DIFFUSE_LIGHT += ALBEDO * (shade_tint - 1.0) * shadow_strength * (1.0 - ATTENUATION);
	} else {
		DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION * torch_boost;
	}
}
