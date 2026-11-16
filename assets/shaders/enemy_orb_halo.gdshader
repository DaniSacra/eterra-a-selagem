shader_type spatial;
// The soft halo around an enemy's shot (cycle 10, BUG-006): a disc facing the camera, as wide as the halo's quad
// (Projectiles.HALO: 1.5 times the shot's radius), blended, not added: many halos over each other stay the shooter's
// hue and never pile up to white.
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

instance uniform vec3 hue = vec3(0.53, 0.39, 1.0);
uniform float light = 0.8;
uniform float opacity = 0.4;

void vertex() {
	// always facing the camera, at the node's place, at the quad's own size
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	float d = length(UV * 2.0 - 1.0);
	float soft = 1.0 - smoothstep(0.2, 1.0, d);
	ALBEDO = hue * light;
	ALPHA = soft * soft * opacity;
}
