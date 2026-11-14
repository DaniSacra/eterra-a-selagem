shader_type spatial;
// A sword arc made of many thin bright streaks: UV.x runs along the swing (0 start, 1 end),
// UV.y across the blade (0 inner, 1 outer edge). t goes 0 -> 1 over its life: the head sweeps through fast,
// the streaks stay behind and thin out. Ends taper so it reads as a crescent.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.85, 0.4, 1.0);
uniform float t = 0.0;
uniform float intensity = 3.0;
uniform bool flip = false;
uniform float seed = 0.0;

float hash(float n) { return fract(sin(n * 127.1 + seed * 311.7) * 43758.5453); }

void fragment() {
	float along = flip ? 1.0 - UV.x : UV.x;
	float head = clamp(t * 2.6, 0.0, 1.0);
	if (along > head) discard;
	// crescent: thick in the middle of the swing, thin at both ends
	float env = pow(sin(3.14159 * along), 0.6);
	float across = (UV.y - (1.0 - env)) / max(env, 0.001);
	if (across < 0.0) discard;
	// streaks: bands across the blade, each with its own brightness, length and thickness
	float bands = 11.0;
	float b = floor(across * bands);
	float f = fract(across * bands);
	float w = mix(0.12, 0.45, hash(b));
	float line = smoothstep(0.5 - w * 0.5, 0.5, f) * (1.0 - smoothstep(0.5, 0.5 + w * 0.5, f));
	float start = hash(b + 17.0) * 0.35;
	float stop = 1.0 - hash(b + 31.0) * 0.25;
	line *= smoothstep(start, start + 0.1, along) * (1.0 - smoothstep(stop - 0.1, stop, along));
	line *= mix(0.35, 1.0, hash(b + 5.0)) * pow(across, 0.7);
	// the outer edge is one hot white line
	float rim = smoothstep(0.86, 0.97, across) * (1.0 - smoothstep(0.97, 1.0, across));
	// behind the head the streaks fade and thin; near the head they burn white
	float trail = clamp(1.0 - (head - along) * 1.4, 0.0, 1.0);
	float hot = smoothstep(0.82, 1.0, trail);
	float life = 1.0 - smoothstep(0.45, 1.0, t);
	vec3 c = mix(color.rgb, vec3(1.0), 0.55 + hot * 0.45);
	ALBEDO = c * (line * (0.35 + trail) + rim * 1.6 * trail) * life * intensity;
}
