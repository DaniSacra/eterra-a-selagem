shader_type spatial;
// A pillar of light (or of shadow): brightest at the base, fading upwards and with life.
// GP-01 of cycle C12c: it lays its light over what is behind it (premultiplied: what it adds, what it covers) instead of
// adding to it, so the screen never goes past its cap, however many faces and however bright the floor or the paladin
// under it: with a = light / cap, out = light + behind * (1 - a) stays under cap wherever behind does. Additive, its two
// faces and the lit floor summed past the tone map's white (255 on the screen with a cap of 1.0). Around the paladin, where
// it stands in front of him, it opens (hero_hole), so he is never lost in it.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled;

global uniform vec3 hero_pos;

uniform vec4 color : source_color = vec4(1.0, 0.9, 0.5, 1.0);
uniform float life = 0.0;
uniform float intensity = 2.5;
// The brightest channel of its light, linear before the exposure (Fx.beam: ScreenTone.linear_peak of its colour, the
// most it may write and stay at ScreenTone.SCREEN_MAX on the screen). Hue kept: the light is scaled down, never clipped.
uniform float cap = 1000.0;
// How far its sides go toward white (the colour of the reward stays: 0.6 turned every column white).
uniform float whiten = 0.25;
// The opening around the paladin: half its width and height in metres at his distance, how much of the light stays
// in it, and the soft edge (a fraction of the size).
uniform vec2 hero_hole = vec2(0.75, 1.5);
uniform float hero_keep = 0.15;
uniform float hero_soft = 0.5;
// Where the middle of his body is over his feet.
const float HERO_MID = 1.3;

void fragment() {
	float up = 1.0 - UV.y;
	float side = pow(abs(dot(NORMAL, VIEW)), 1.5);
	float fade = 1.0 - smoothstep(0.3, 1.0, life);
	vec3 c = mix(color.rgb, vec3(1.0), side * whiten);
	vec3 light = c * side * (1.0 - up * 0.85) * fade * intensity;
	// the paladin seen through it: only where this face is nearer the camera than he is
	vec3 hero = (VIEW_MATRIX * vec4(hero_pos + vec3(0.0, HERO_MID, 0.0), 1.0)).xyz;
	if (hero.z < 0.0 && VERTEX.z > hero.z) {
		vec2 off = (VERTEX.xy / -VERTEX.z - hero.xy / -hero.z) * -hero.z / hero_hole;
		float d = length(off);
		light *= mix(hero_keep, 1.0, smoothstep(1.0 - hero_soft, 1.0, d));
	}
	float peak = max(light.r, max(light.g, light.b));
	if (peak > cap) {
		light *= cap / peak;
		peak = cap;
	}
	ALBEDO = light;
	ALPHA = clamp(peak / max(cap, 0.0001), 0.0, 1.0);
}
