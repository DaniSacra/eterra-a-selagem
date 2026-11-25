shader_type spatial;
// The Guerreiro's contour in the stylized look (STY-06, T20; docs/art/stylized_spec.md 2.3): the next pass of
// hero_paint.gdshader, his skinned body pushed out along its normals by width meters of the world and drawn from
// behind, a thin cold dark ink (0.045 m, a hair wider than the crowd's 0.04, petrol-black, never pure black). Only in
// the stylized look (HeroBody puts it there).
render_mode unshaded, cull_front, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(0.05, 0.07, 0.08);
uniform float width = 0.045;
// The shell is pushed this many meters away from the camera: on his open, two-sided cloth the inflated back faces
// showed through the body as dark blots; pushed back, only the edge past the silhouette is left.
uniform float push_back = 0.25;

// H-2: the shell follows the cape cut and narrowing of hero_paint (same numbers, set by HeroBody.painted); without
// the texture (the Maga) cape_cut is 0 and nothing is cut.
uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform float cape_cut = 0.0;
uniform float cape_narrow = 1.0;
uniform float flatten = 0.35;

varying float local_y;

void vertex() {
	local_y = VERTEX.y * 0.01;
	vec3 t = textureLod(albedo, UV, 3.0).rgb;
	float cv = smoothstep(0.015, 0.06, t.g - t.r) * (1.0 - smoothstep(0.0, 0.04, t.b - t.g - 0.02));
	VERTEX.x *= mix(1.0, cape_narrow, cv * step(0.001, cape_cut));
	float scale = max(length(MODEL_MATRIX[0].xyz), 0.001);
	VERTEX += NORMAL * width / scale;
	// away from the camera, in the model's own space (uniform scale: the transpose undoes the turn)
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 away = normalize(world - CAMERA_POSITION_WORLD) * push_back;
	VERTEX += transpose(mat3(MODEL_MATRIX)) * away / (scale * scale);
}

void fragment() {
	if (cape_cut > 0.0) {
		vec3 c = mix(texture(albedo, UV).rgb, textureLod(albedo, UV, 3.0).rgb, flatten);
		float cape = smoothstep(0.015, 0.06, c.g - c.r) * (1.0 - smoothstep(0.0, 0.04, c.b - c.g - 0.02));
		if (cape > 0.5 && local_y < cape_cut) {
			discard;
		}
	}
	ALBEDO = color;
}
