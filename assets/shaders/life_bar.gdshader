shader_type spatial;
// A thin life bar over an enemy's head, as in Hades II: drawn by MultiMesh, always facing the camera, on top of
// everything. INSTANCE_CUSTOM: r = life left (0..1), g = armor left (0..1, a yellow strip over the life),
// b = opacity (1; less when the floor is crowded, CrowdRenderer.BAR_CROWD_FADE).
render_mode unshaded, cull_disabled, depth_test_disabled, shadows_disabled;

uniform vec3 life_color : source_color = vec3(0.86, 0.12, 0.14);
uniform vec3 armor_color : source_color = vec3(1.0, 0.82, 0.25);
uniform vec3 back_color : source_color = vec3(0.04, 0.03, 0.05);
// Share of the bar's height the dark frame takes on each side.
uniform float frame = 0.22;

varying vec2 fill;
varying float fade;

void vertex() {
	fill = INSTANCE_CUSTOM.rg;
	fade = INSTANCE_CUSTOM.b;
	// billboard: keep the instance's size and place, turn the quad to the camera
	vec3 scale = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), 1.0);
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(scale.x, 0, 0, 0), vec4(0, scale.y, 0, 0), vec4(0, 0, 1, 0), vec4(0, 0, 0, 1));
}

void fragment() {
	vec2 uv = UV;
	float fy = frame;
	float fx = frame * 0.06;
	vec3 c = back_color;
	bool inside = uv.x > fx && uv.x < 1.0 - fx && uv.y > fy && uv.y < 1.0 - fy;
	if (inside) {
		float x = (uv.x - fx) / (1.0 - 2.0 * fx);
		float y = (uv.y - fy) / (1.0 - 2.0 * fy);
		c = back_color * 2.5;
		if (x < fill.r) {
			c = life_color;
		}
		if (fill.g > 0.0 && y < 0.45 && x < fill.g) {
			c = armor_color;
		}
	}
	ALBEDO = c;
	ALPHA = 0.95 * fade;
}
