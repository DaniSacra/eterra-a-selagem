shader_type spatial;
// The ribbon of a finisher and of the spin (vfx_pass_spec.md V-02; was a closed thin ellipse that read as interface):
// it sweeps the arc in `sweep` of its life (the head running from UV.x 0 to 1), wide at the head (head_m) and thin at
// the tail (tail_m), drawn against the outer edge of the band; an emerald body over dark ink, the ivory-mint edge only
// on the head's third; the tail goes first (the ribbon closes behind the blade). Laid over what is behind
// (premultiplied) under `peak` (Fx: ScreenTone.linear_peak of its edge, 226 on the screen), its hue kept.
// UV.x runs along the swing, UV.y from the inner (0) to the outer edge (1). t goes 0 -> 1 over its life.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled, fog_disabled;

uniform vec4 color : source_color = vec4(0.3, 1.0, 0.45, 1.0);
uniform vec4 ink : source_color = vec4(0.02, 0.02, 0.035, 1.0);
uniform float t = 0.0;
uniform float ink_opacity = 0.3;
// Share of the life the head takes to sweep the arc, and when the tail starts to follow.
uniform float sweep = 0.17;
// Widths at the head and the tail (metres), and the band of the mesh (metres, Fx: reach x (1 - CRESCENT_INNER)).
uniform float head_m = 0.35;
uniform float tail_m = 0.08;
uniform float band_m = 0.7;
uniform float body_light = 0.28;
uniform float edge_light = 0.95;
uniform float edge_pale = 0.45;
uniform float body_sat = 0.5;
uniform float peak = 0.6;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	float x = UV.x;
	float y = UV.y;
	float head = clamp(t / max(sweep, 0.001), 0.0, 1.0);
	// the tail follows once the head is through: the ribbon closes behind the blade
	float tail_end = clamp((t - sweep) / max(1.0 - sweep, 0.001), 0.0, 1.0) * head;
	if (x > head || x < tail_end) discard;
	// 0 at the head, 1 at the tail end
	float k = (head - x) / max(head - tail_end, 0.001);
	float width = mix(head_m, tail_m, pow(k, 0.7)) / max(band_m, 0.001);
	float inner = 1.0 - width * (0.85 + 0.3 * noise(vec2(x * 24.0, 1.7)));
	float body = smoothstep(inner, inner + 0.08, y) * (1.0 - smoothstep(0.97, 1.0, y));
	// the head's point: round the head, a short taper
	body *= smoothstep(0.0, 0.03, head - x + 0.005);
	float fade = 1.0 - smoothstep(0.5, 1.0, t);
	float edge = (1.0 - smoothstep(0.0, 0.05, abs(y - 0.95))) * (1.0 - smoothstep(0.2, 0.33, k)) * fade;
	if (body + edge <= 0.01) discard;
	vec3 hue = color.rgb / max(max(color.r, max(color.g, color.b)), 0.0001);
	float grey = dot(hue, vec3(0.333));
	vec3 green = mix(vec3(grey), hue, body_sat);
	vec3 light = green * body * body_light * (1.0 - 0.6 * k) * fade + mix(hue, vec3(1.0), edge_pale) * edge * edge_light;
	float top = max(light.r, max(light.g, light.b));
	light *= min(1.0, peak / max(top, 0.0001));
	float ink_a = body * ink_opacity * fade;
	ALBEDO = ink.rgb * ink_a + light;
	ALPHA = clamp(ink_a + min(top, peak) / max(peak, 0.0001), 0.0, 1.0);
}
