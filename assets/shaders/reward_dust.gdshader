shader_type spatial;
// The dust falling in a RewardShaft (vfx_pass_spec.md 6.2): thin streaks turned round the vertical to face the camera,
// soft at both ends, laid over what is behind (premultiplied) at `alpha` of the cap; the instance's alpha fades each one
// in at the top and out at the floor.
render_mode unshaded, skip_vertex_transform, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(1.0, 0.94, 0.82);
uniform float cap = 1.0;
uniform float alpha = 0.45;
uniform float strength = 1.0;
uniform float compat_gain = 1.0;

varying float fade;

void vertex() {
	fade = INSTANCE_CUSTOM.a;
	// face the camera round the vertical axis (a streak stays upright); the quad's size is the mesh's
	vec3 centre = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec3 back = INV_VIEW_MATRIX[2].xyz;
	vec3 side = normalize(vec3(back.z, 0.0, -back.x));
	vec3 world = centre + side * VERTEX.x + vec3(0.0, VERTEX.y, 0.0);
	VERTEX = (VIEW_MATRIX * vec4(world, 1.0)).xyz;
	NORMAL = (VIEW_MATRIX * vec4(back, 0.0)).xyz;
}

void fragment() {
	float across = 1.0 - abs(UV.x * 2.0 - 1.0);
	float along = sin(UV.y * 3.14159);
	float a = alpha * across * along * fade * strength;
	vec3 light = color / max(max(color.r, max(color.g, color.b)), 0.0001) * cap * a * compat_gain;
	ALBEDO = light;
	ALPHA = clamp(a, 0.0, 1.0);
}
