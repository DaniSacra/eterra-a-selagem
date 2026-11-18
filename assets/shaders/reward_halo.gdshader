shader_type spatial;
// The soft halo behind a reward's medallion (RewardGem): a disc facing the camera in the reward's colour, fading to
// nothing at its edge, laid over what is behind it (premultiplied) with its brightest channel at `peak`, under the glow
// threshold and the screen's cap. No light: the room's lights and the medallion's own glow do the rest.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec3 color : source_color = vec3(1.0, 0.8, 0.4);
// The most it lays at its middle (a share of what is behind kept) and its brightest channel there.
uniform float alpha = 0.45;
uniform float peak = 0.6;
// How fast it fades toward its edge (a power on 1 - r).
uniform float falloff = 2.2;
// It breathes slowly (share of its light, cycles a second).
uniform float breathe = 0.12;
uniform float breathe_rate = 0.35;

void vertex() {
	// face the camera
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	float r = length((UV - 0.5) * 2.0);
	float k = pow(clamp(1.0 - r, 0.0, 1.0), falloff);
	k *= 1.0 - breathe + breathe * sin(TIME * TAU * breathe_rate);
	vec3 c = color / max(max(color.r, max(color.g, color.b)), 0.001) * peak;
	ALBEDO = c * k;
	ALPHA = alpha * k;
}
