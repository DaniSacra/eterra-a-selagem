shader_type spatial;
// A straight wake on the floor: Morvath's dash (Fx.boss_dash: the lane it hurts, revealed as he runs it and
// breaking into ashes after) and the short trail behind each of his crescents (Projectiles, `head` 1 and `trail`
// mode). Violet smoke in the middle, blue-green along both sides (the edges of the lane). Drawn on Fx.strip(): UV.x
// across (0 to 1), UV.y along (0 where it starts, 1 where it ends): it never leaves the lane it is given.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 body : source_color = vec4(0.62, 0.22, 1.2, 1.0);
uniform vec4 edge : source_color = vec4(0.38, 1.55, 1.1, 1.0);
// Life 0 -> 1; the head runs the length during the first `sweep` of it (the wake is whole after).
uniform float t = 0.0;
uniform float sweep = 0.4;
// Share of the length the bright part covers behind the head.
uniform float tail = 0.5;
// A crescent's trail: no head running, just a fade from its back (0) to the crescent (1), smoke flowing back.
uniform bool trail_mode = false;
uniform float fade = 1.0;
uniform float intensity = 1.0;
uniform float edge_light = 0.7;
uniform float body_light = 0.6;

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
	float x = abs(UV.x - 0.5) * 2.0;
	float along = UV.y;
	float glow;
	float rest = 0.0;
	if (trail_mode) {
		// narrower toward its back, like smoke left behind
		if (x > 0.35 + 0.65 * along) discard;
		glow = along * along;
	} else {
		float head = clamp(t / sweep, 0.0, 1.0);
		float behind = head - along;
		if (behind < 0.0) discard;
		rest = clamp((t - sweep) / max(1.0 - sweep, 0.001), 0.0, 1.0);
		float grain = noise(vec2(UV.x * 6.0, along * 40.0 - t * 3.0));
		if (grain < rest * 1.05) discard;
		glow = mix(0.25, 1.0, 1.0 - smoothstep(0.0, tail, behind));
	}
	float side = 1.0 - smoothstep(0.0, 0.12, 1.0 - x);
	float smoke = 0.5 + 0.7 * noise(vec2(UV.x * 5.0, along * 9.0 + TIME * (trail_mode ? 4.0 : 1.0)));
	float fill = (1.0 - x * 0.6) * smoke;
	vec3 soft = body.rgb / max(max(body.r, max(body.g, body.b)), 1.0);
	vec3 c = soft * fill * body_light + edge.rgb * side * edge_light;
	ALBEDO = c * glow * (1.0 - rest) * fade * intensity;
}
