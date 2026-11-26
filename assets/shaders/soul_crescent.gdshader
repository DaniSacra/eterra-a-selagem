shader_type spatial;
// A boss's spectral crescent (Morvath's Blades of the Souls and the Storm of the Six Souls): a half-moon of cold
// violet fire flying flat over the floor (art pack 2026-11-17: cold violet with a pale core; it was blue-green). A pale
// leading edge (the side it flies to), a pale core running along the middle of its body (`core_color`, the brightest
// part), a smoky body in the cold violet that turns deep violet toward its trailing side and thins to the tips,
// the smoke streaming backwards (its way reads in a still frame). It flares for an instant when it leaves and
// fades as it ends (`fade`). Its size is its collision (Projectiles.touches_soul): only the look changed (cycle 9).
// Drawn on Projectiles' crescent mesh: UV.x 0.3 at the tips to 0.7 in the middle, UV.y 0 on the inner (trailing)
// side to 1 on the outer (leading) edge.
// vfx_pass_spec.md V-17: never the smooth pale edge of the paladin's wave: the leading edge gnawed by noise (gnaw, as the
// scythe's), a dark violet body laid over the floor (ink), the lilac core only in the middle third, three smoke tails
// behind (Projectiles._place_soul); laid over what is behind (premultiplied) under `peak` (the screen's 226).
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled;
uniform float peak = 0.7;
uniform float ink = 0.5;
uniform float gnaw = 0.22;

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
	// the gnawed leading edge: the outside eaten by noise along the arc
	float bite = (noise(vec2(UV.x * 26.0, TIME * 2.0)) * 0.7 + noise(vec2(UV.x * 60.0, 3.0)) * 0.3) * gnaw;
	if (y > 1.0 - bite) discard;
	// GP-3 (signature 5): the soul is corroded: holes eaten in the body (not in the middle line) that drift with the smoke
	float rot = noise(vec2(UV.x * 14.0 + TIME * 0.6, y * 7.0 - TIME * 1.1));
	if (rot > 0.8 && abs(across - 0.5) > 0.2) discard;
	float line = (1.0 - smoothstep(0.0, 0.08, 1.0 - bite - y)) * smoothstep(0.0, 0.35, mid);
	// the lilac core: only the middle third of the body's thickness
	float thread = (1.0 - smoothstep(0.1, 0.17, abs(across - 0.5))) * smoothstep(0.15, 0.6, mid);
	float tips = smoothstep(0.0, 0.25, mid);
	vec3 soft = color.rgb / max(max(color.r, max(color.g, color.b)), 1.0);
	vec3 dusk = smoke_color.rgb / max(max(smoke_color.r, max(smoke_color.g, smoke_color.b)), 1.0);
	vec3 cloth = mix(dusk, soft, smoothstep(0.2, 0.85, across)) * 0.45;
	vec3 heart = mix(soft, core_color.rgb, 0.55);
	vec3 lit = (cloth * fumes * body * tips + heart * thread * core * 0.6 + soft * line * edge * 0.45) * intensity * fade * (1.0 + 0.4 * flare);
	float top = max(lit.r, max(lit.g, lit.b));
	if (top > peak) {
		lit *= peak / top;
		top = peak;
	}
	float cover = ink * fumes * tips * fade;
	float a = clamp(top / max(peak, 0.0001), 0.0, 1.0);
	float alpha = clamp(a + cover * (1.0 - a), 0.0, 1.0);
	if (alpha <= 0.003) discard;
	ALBEDO = lit;
	ALPHA = alpha;
}
