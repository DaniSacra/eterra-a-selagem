shader_type spatial;
// The dodge's trail (vfx_pass_spec.md V-08, AP-2; Fx._animate_ghosts): three or four silhouettes of the paladin left
// along the blink, in the ink of the cut (slash_ink.gdshader), each from `alpha` down to nothing over its life, with
// a hair of ivory only on its top edge (the faces turned up and away from the eye). Never white, never his colours:
// an ink shadow of where he was. Laid over what is behind (no depth written, no shadow, no fog).
render_mode unshaded, blend_mix, cull_back, depth_draw_never, shadows_disabled, fog_disabled;

uniform vec3 ink : source_color = vec3(0.02, 0.028, 0.034);
uniform vec3 rim_color : source_color = vec3(0.86, 0.82, 0.7);
// 0 just made, 1 gone
uniform float life = 0.0;
uniform float alpha = 0.25;
uniform float alpha_end = 0.1;
// how much of the grazing faces carry the rim, and how far up a face must turn to have it
uniform float rim_width = 0.3;
uniform float rim_alpha = 0.55;
uniform vec2 rim_up = vec2(0.15, 0.55);

varying vec3 world_normal;

void vertex() {
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	float fade = mix(alpha, alpha_end, life) * (1.0 - smoothstep(0.7, 1.0, life));
	float graze = 1.0 - abs(dot(NORMAL, VIEW));
	float rim = smoothstep(1.0 - rim_width, 1.0, graze) * smoothstep(rim_up.x, rim_up.y, world_normal.y);
	ALBEDO = mix(ink, rim_color, rim);
	ALPHA = clamp(mix(fade, fade / max(alpha, 0.001) * rim_alpha, rim), 0.0, 1.0);
}
