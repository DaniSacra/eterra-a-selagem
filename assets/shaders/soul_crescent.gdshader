shader_type spatial;
// A boss's spectral crescent (Morvath's Blades of the Souls and the Storm of the Six Souls): a half-moon of cold
// violet fire flying flat over the floor (art pack 2026-11-17: cold violet with a pale core; it was blue-green). A pale
// leading edge (the side it flies to), a pale core running along the middle of its body (`core_color`, the brightest
// part), a smoky body in the cold violet that turns deep violet toward its trailing side and thins to the tips,
// the smoke streaming backwards (its way reads in a still frame). It flares for an instant when it leaves and
// fades as it ends (`fade`). Its size is its collision (Projectiles.touches_soul): only the look changed (cycle 9).
// Drawn on Projectiles' crescent mesh: UV.x 0.3 at the tips to 0.7 in the middle, UV.y 0 on the inner (trailing)
// side to 1 on the outer (leading) edge.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(0.62, 0.44, 1.3, 1.0);
// The violet of the smoke on its trailing side.
uniform vec4 smoke_color : source_color = vec4(0.36, 0.12, 0.8, 1.0);
// The pale core and leading edge (a lilac white).
uniform vec4 core_color : source_color = vec4(0.94, 0.9, 1.0, 1.0);
// How far the leading edge goes from the body's violet to the pale core colour.
uniform float edge_pale = 0.6;
uniform float intensity = 1.0;
// How bright the leading edge is (above 1: it glows), the core line and the smoky body (under the glow).
uniform float edge = 1.6;
uniform float core = 0.9;
uniform float body = 1.0;
// 1 while it flies, down to 0 as it ends; flare: 1 as it leaves, 0 a moment later.
uniform float fade = 1.0;
uniform float flare = 0.0;

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
	// smoke: noise flowing backwards from the edge, fast (the way it flies)
	vec2 q = vec2(UV.x * 9.0, y * 4.0 + TIME * 3.4);
	float smoke = noise(q) * 0.65 + noise(q * 2.7 + 3.0) * 0.35;
	// as it ends the smoke breaks up from the trailing side
	if (smoke < (1.0 - fade) * (1.2 - across)) discard;
	float fumes = (0.3 + 0.7 * smoothstep(0.0, 0.6, across)) * (0.55 + 0.7 * smoke);
	// the leading edge: a bright line along the outside, softer toward the tips
	float line = (1.0 - smoothstep(0.02, 0.16, 1.0 - y)) * smoothstep(0.0, 0.35, mid);
	// the core: a luminous thread through the thick of the body
	float thread = exp(-pow((across - 0.62) / 0.12, 2.0)) * smoothstep(0.15, 0.6, mid);
	float tips = smoothstep(0.0, 0.25, mid);
	// the body from violet (trailing side) to the spectral colour, both brought under the glow threshold
	vec3 soft = color.rgb / max(max(color.r, max(color.g, color.b)), 1.0);
	vec3 dusk = smoke_color.rgb / max(max(smoke_color.r, max(smoke_color.g, smoke_color.b)), 1.0);
	vec3 cloth = mix(dusk, soft, smoothstep(0.2, 0.85, across));
	vec3 rim = mix(soft, core_color.rgb, edge_pale);
	vec3 heart = core_color.rgb;
	ALBEDO = (cloth * fumes * body * tips + heart * thread * core + rim * line * edge) * intensity * fade * (1.0 + 0.6 * flare);
}
