shader_type spatial;
// A boss's spectral crescent (Morvath's Blades of the Souls): a half-moon of cold, pale green fire flying flat over
// the floor. A bright leading edge (the side it flies to), a smoky translucent body that thins to the tips and
// trails behind, the smoke crawling with time. Drawn on Projectiles' crescent mesh: UV.x 0.3 at the tips to 0.7 in
// the middle, UV.y 0 on the inner (trailing) side to 1 on the outer (leading) edge.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(0.38, 1.55, 1.1, 1.0);
uniform float intensity = 1.0;
// How bright the leading edge is (above 1: it glows) and the smoky body (under the glow).
uniform float edge = 1.6;
uniform float body = 1.0;

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
	// 0 at the tips, 1 in the middle
	float mid = clamp((UV.x - 0.3) / 0.4, 0.0, 1.0);
	float y = UV.y;
	// the crescent is thick in the middle and comes to a point at each tip
	float thick = pow(mid, 0.45) * 0.97;
	float inner = 1.0 - thick;
	if (y < inner) discard;
	float across = (y - inner) / max(thick, 0.001);
	// smoke: noise flowing backwards from the edge
	vec2 q = vec2(UV.x * 9.0, y * 4.0 + TIME * 2.2);
	float smoke = noise(q) * 0.65 + noise(q * 2.7 + 3.0) * 0.35;
	float fumes = (0.3 + 0.7 * smoothstep(0.0, 0.6, across)) * (0.55 + 0.7 * smoke);
	// the leading edge: a bright line along the outside, softer toward the tips
	float line = (1.0 - smoothstep(0.02, 0.16, 1.0 - y)) * smoothstep(0.0, 0.35, mid);
	float tips = smoothstep(0.0, 0.25, mid);
	// the body in the colour brought under the glow threshold, the edge in the full colour (it glows)
	vec3 soft = color.rgb / max(max(color.r, max(color.g, color.b)), 1.0);
	vec3 rim = mix(color.rgb, vec3(1.0, 1.15, 1.05), 0.35);
	ALBEDO = (soft * fumes * body * tips + rim * line * edge) * intensity;
}
