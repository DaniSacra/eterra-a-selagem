shader_type spatial;
// First pass of the paladin's x-ray (xray.gdshader): his depth alone, in the layer right in front of the camera, so
// that the next passes paint only the frontmost of his surfaces (an arm behind the chest stays behind it).
render_mode unshaded, blend_add, cull_back, shadows_disabled, depth_draw_always;

const float LAYER = 0.05;

void vertex() {
	POSITION = PROJECTION_MATRIX * vec4((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz * LAYER, 1.0);
}

void fragment() {
	ALBEDO = vec3(0.0);
}
