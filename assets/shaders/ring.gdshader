shader_type spatial;
// A flat shockwave: a bright band near the edge of the quad that fades as life goes 0 -> 1.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.85, 0.4, 1.0);
uniform float life = 0.0;
uniform float band = 0.08;
uniform float intensity = 1.5;
// How much the inside of the ring is lit (0: a line only).
uniform float fill = 0.18;

void fragment() {
	float d = length(UV * 2.0 - 1.0);
	if (d > 1.0) discard;
	float ring = smoothstep(1.0 - band, 1.0 - band * 0.3, d) * (1.0 - smoothstep(0.97, 1.0, d));
	float inner = smoothstep(0.0, 1.0, d) * fill;
	float fade = 1.0 - life;
	ALBEDO = mix(color.rgb, vec3(1.0), ring * 0.4) * (ring + inner) * fade * fade * intensity;
}
