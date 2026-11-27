shader_type spatial;
// GP-8 technique A prototype (PaintedHall): the room's painting projected from the painter's camera onto simple
// geometry. The colour is the painting's own (no ambient, no lights); lights only do two small things: the moon's
// shadows (the hero's and the fighters') tint it cold, and the scene's omni lights (torches, fires) add a little warmth.
render_mode ambient_light_disabled, specular_disabled, fog_disabled, cull_disabled;

uniform sampler2D painting : source_color, filter_linear_mipmap, repeat_disable;
// world -> clip of the painter's camera (PaintedHall.projector)
uniform mat4 projector;
uniform float exposure = 1.0;
uniform float shadow_strength = 0.6;
uniform vec3 shade_tint = vec3(0.5, 0.6, 0.82);
uniform float torch_boost = 0.35;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec4 c = projector * vec4(world_pos, 1.0);
	vec2 uv = c.xy / c.w * vec2(0.5, -0.5) + 0.5;
	vec3 col = texture(painting, uv).rgb * exposure;
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
