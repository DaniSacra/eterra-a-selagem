shader_type spatial;
// A sword arc: UV.x runs along the swing (0 start, 1 end), UV.y across the blade (0 inner, 1 outer edge).
// t goes 0 -> 1 over the life of the slash: the bright head sweeps through, the tail fades behind it.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.85, 0.4, 1.0);
uniform float t = 0.0;
uniform float intensity = 2.5;
uniform bool flip = false;

void fragment() {
	float head = clamp(t * 1.6, 0.0, 1.0);
	float along = flip ? 1.0 - UV.x : UV.x;
	if (along > head) discard;
	float tail = clamp(1.0 - (head - along) * 2.2, 0.0, 1.0);
	float edge = pow(UV.y, 2.5);
	float core = smoothstep(0.8, 1.0, UV.y);
	float life = 1.0 - smoothstep(0.55, 1.0, t);
	vec3 c = mix(color.rgb, vec3(1.0), core * 0.85);
	ALBEDO = c * (edge * 0.9 + core) * tail * life * intensity;
}
