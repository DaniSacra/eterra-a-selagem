shader_type spatial;
// A thrust of the sword (Fx.thrust): a thin beam that shoots out along the quad and thins to a point at its tip,
// a pale thread down the middle inside a faint sheath as wide as the blow reaches. No streaks across it.
// UV.y runs along the thrust (0 at the paladin, 1 at the tip), UV.x across it. t goes 0 -> 1 over its life.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(0.3, 1.0, 0.45, 1.0);
uniform float t = 0.0;
// Share of the life the point takes to reach the tip.
uniform float sweep = 0.3;
uniform float intensity = 1.7;
// The thread down the middle and the sheath around it, as shares of the width.
uniform float thread = 0.16;
uniform float sheath = 0.3;
// How far the thread goes from the blow's colour toward white.
uniform float core = 0.4;

void fragment() {
	float along = UV.y;
	float side = abs(UV.x * 2.0 - 1.0);
	float head = clamp(t / sweep, 0.0, 1.0);
	if (along > head) discard;
	float rest = clamp((t - sweep) / max(1.0 - sweep, 0.001), 0.0, 1.0);
	// it leaves the paladin as it fades: the back end follows the point
	float back = smoothstep(rest * 0.85 - 0.12, rest * 0.85 + 0.02, along);
	// a point at the paladin's hand, widest a little ahead, a long point at the tip
	// (the point leads while it flies out: never a blunt end)
	float width = smoothstep(0.0, 0.07, along) * pow(1.0 - along / max(head, 0.001), 0.7);
	float d = side / max(width, 0.001);
	float line = 1.0 - smoothstep(thread * 0.35, thread, d);
	float veil = (1.0 - smoothstep(0.0, 1.0, d)) * sheath;
	float value = (line + veil) * back * (1.0 - rest);
	if (value <= 0.003) discard;
	vec3 c = mix(color.rgb, vec3(1.0), core * line);
	ALBEDO = c * value * intensity;
}
