shader_type spatial;
// The ring of energy round a door's medallion (DoorRing): a thin band of the room's colour facing the camera, pulsing
// slowly, with a soft glow on both sides of it; `near` (0 to 1: the hero stands by the door) makes it brighter, faster
// and wider. Additive, no light, no depth write: cheap, the same in Compatibility.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec3 color : source_color = vec3(1.0, 0.8, 0.4);
uniform float near = 0.0;
// The band's middle and half width in the quad's units (1 is the quad's edge), its brightest channel.
uniform float radius = 0.74;
uniform float width = 0.045;
uniform float peak = 0.7;
// 1 as the door lights, falling to 0: a flash and a second ring spreading out past the first.
uniform float flare = 0.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	float r = length((UV - 0.5) * 2.0);
	float pulse = 0.5 + 0.5 * sin(TIME * TAU * mix(0.35, 0.9, near));
	float w = width * (1.0 + 0.6 * near);
	float d = abs(r - radius - 0.01 * pulse);
	float band = smoothstep(w, w * 0.25, d);
	float glow = exp(-d * d / (w * w * 14.0)) * 0.45;
	// the glow fades to nothing before the quad's edge (else its square shows)
	float k = (band + glow) * (0.55 + 0.45 * pulse) * (0.55 + 0.45 * near) * smoothstep(1.0, 0.86, r);
	vec3 c = color / max(max(color.r, max(color.g, color.b)), 0.001) * peak;
	// the light-up: the band burns brighter and a wave leaves it outwards (SW-C9)
	float wave_r = radius + (1.0 - flare) * 0.2;
	float wave = smoothstep(w * 2.0, 0.0, abs(r - wave_r)) * flare * smoothstep(0.98, 0.9, r);
	k = k * (1.0 + 1.2 * flare) + wave * 0.9;
	ALBEDO = c * k;
}
