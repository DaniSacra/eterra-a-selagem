shader_type spatial;
// A thin life bar over an enemy's head, as in Hades II: drawn by MultiMesh, always facing the camera, on top of
// everything. INSTANCE_CUSTOM: r = life left (0..1), g = armor left (0..1), b = opacity (1; less when the floor is
// crowded, CrowdRenderer.BAR_CROWD_FADE) plus 2 for an elite (its frame in old gold), a = where the pale trail of a
// recent loss ends (>= r; CrowdRenderer.BarTrails).
// Cycle 8: armor no longer covers the top of the life. An armored bar is taller (CrowdRenderer.BAR_ARMOR_HEIGHT):
// the armor's own strip on top, a line of ink, the life under it; both read whole.
render_mode unshaded, cull_disabled, depth_test_disabled, shadows_disabled;

uniform vec3 life_color : source_color = vec3(0.86, 0.12, 0.14);
uniform vec3 armor_color : source_color = vec3(1.0, 0.82, 0.25);
uniform vec3 back_color : source_color = vec3(0.04, 0.03, 0.05);
uniform vec3 trail_color : source_color = vec3(1.0, 0.9, 0.78);
uniform vec3 elite_frame : source_color = vec3(0.56, 0.45, 0.27);
// Meters of the frame on each side (as thick on the ends as on the long sides, and on a tall armored bar).
uniform float frame_m = 0.03;
// The armored bar's split: the armor's strip takes this share of the inside (from the top).
uniform float armor_share = 0.42;

varying vec3 fill;
varying float fade;
varying float elite;
varying vec2 size_m;

void vertex() {
	fill = vec3(INSTANCE_CUSTOM.r, INSTANCE_CUSTOM.g, INSTANCE_CUSTOM.a);
	elite = INSTANCE_CUSTOM.b > 1.5 ? 1.0 : 0.0;
	fade = INSTANCE_CUSTOM.b - 2.0 * elite;
	// billboard: keep the instance's size and place, turn the quad to the camera
	vec3 scale = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), 1.0);
	size_m = scale.xy;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(scale.x, 0, 0, 0), vec4(0, scale.y, 0, 0), vec4(0, 0, 1, 0), vec4(0, 0, 0, 1));
}

void fragment() {
	vec2 uv = UV;
	bool armored = fill.g > 0.0;
	float fy = frame_m / max(size_m.y, 0.001);
	float fx = frame_m / max(size_m.x, 0.001);
	vec3 c = mix(back_color, elite_frame, elite);
	bool inside = uv.x > fx && uv.x < 1.0 - fx && uv.y > fy && uv.y < 1.0 - fy;
	if (inside) {
		float x = (uv.x - fx) / (1.0 - 2.0 * fx);
		float y = (uv.y - fy) / (1.0 - 2.0 * fy);
		c = back_color * 2.5;
		if (armored && y < armor_share) {
			// the armor's own strip; a line of ink under it
			if (y > armor_share - 0.12) {
				c = back_color;
			} else if (x < fill.g) {
				c = armor_color;
			}
		} else {
			if (x < fill.r) {
				c = life_color;
			} else if (x < fill.b) {
				c = trail_color;
			}
		}
	}
	ALBEDO = c;
	ALPHA = 0.95 * fade;
}
