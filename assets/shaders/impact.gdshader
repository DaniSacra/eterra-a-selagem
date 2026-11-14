shader_type spatial;
// The star of a blow landing: a white core with sharp rays, popping out and fading in a tenth of a second.
// Drawn on a quad that always faces the camera.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.8, 0.4, 1.0);
uniform float life = 0.0;
uniform float seed = 0.0;
uniform float intensity = 3.0;

float hash(float n) { return fract(sin(n * 91.3 + seed * 47.7) * 43758.5453); }

uniform float size = 1.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	VERTEX *= size;
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float a = atan(p.y, p.x);
	// 7 rays of random length and width
	float rays = 0.0;
	for (int i = 0; i < 7; i++) {
		float ang = (float(i) + hash(float(i))) / 7.0 * 6.28318;
		float d = abs(mod(a - ang + 3.14159, 6.28318) - 3.14159);
		float len = mix(0.45, 1.0, hash(float(i) + 9.0)) * (0.5 + life * 0.8);
		float wid = mix(0.06, 0.16, hash(float(i) + 3.0)) * (1.0 - r / max(len, 0.01));
		rays = max(rays, step(r, len) * smoothstep(wid, wid * 0.3, d));
	}
	float core = 1.0 - smoothstep(0.12, 0.3 + (1.0 - life) * 0.1, r);
	float ring = smoothstep(0.05, 0.0, abs(r - life * 0.9)) * (1.0 - life);
	float fade = 1.0 - smoothstep(0.35, 1.0, life);
	vec3 c = mix(color.rgb, vec3(1.0), 0.6);
	ALBEDO = c * (rays * 0.9 + core * 1.5 + ring * 0.8) * fade * intensity;
}
