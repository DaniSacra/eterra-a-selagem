shader_type spatial;
// A thrust of the sword (Fx.thrust): a thin beam that shoots out along the quad and thins to a point at its tip,
// a pale thread down the middle inside a faint sheath as wide as the blow reaches. No streaks across it.
// The Omega (omega = 1, the held thrust) is the whole blade let loose: a broader, whiter thread, and the two veins of
// old gold of Emeth running along the edges of its sheath, so it never reads as a common thrust or as the special's
// dart (cycle 8: attack, special and Omega told apart at a glance).
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
// The Omega: a thread this many times broader and this much paler, and the veins of old gold on the sheath's edges
// (where across it, as a share of the width, and how bright).
uniform float omega = 0.0;
uniform float omega_thread = 1.6;
uniform float omega_core = 0.7;
uniform vec3 gold : source_color = vec3(0.95, 0.72, 0.3);
uniform float vein_at = 0.62;
uniform float vein_gain = 0.7;

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
	float th = thread * mix(1.0, omega_thread, omega);
	float line = 1.0 - smoothstep(th * 0.35, th, d);
	float veil = (1.0 - smoothstep(0.0, 1.0, d)) * sheath;
	float vein = (1.0 - smoothstep(0.0, 0.07, abs(d - vein_at))) * omega * vein_gain * smoothstep(0.08, 0.2, along);
	float value = (line + veil) * back * (1.0 - rest);
	if (value + vein <= 0.003) discard;
	vec3 c = mix(color.rgb, vec3(1.0), mix(core, omega_core, omega) * line) * value + gold * vein * back * (1.0 - rest);
	ALBEDO = c * intensity;
}
