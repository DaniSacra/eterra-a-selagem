shader_type spatial;
// A pillar of light (or of shadow): brightest at the base, fading upwards and with life.
// GP-01 of cycle C12c: it lays its light over what is behind it (premultiplied: what it adds, what it covers) instead of
// adding to it, so the screen never goes past its cap, however many faces and however bright the floor or the paladin
// under it: with a = light / cap, out = light + behind * (1 - a) stays under cap wherever behind does. Additive, its two
// faces and the lit floor summed past the tone map's white (255 on the screen with a cap of 1.0). Around the paladin, where
// it stands in front of him, it opens (hero_hole), so he is never lost in it.
// C12d (VX-COL): it reads as light, not as a tube of yellow plastic. Its light is a share of the cap (body), never all of
// it, so the floor and the walls behind show through (a = light / cap stays well under 1); soft sides (side_soft), a
// paler core in the middle of each face (core_width, core_white) and the reward's colour toward the sides, a gradient
// that is gone before the top (top_from), and faint streaks of light rising through it (streaks).
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled;

global uniform vec3 hero_pos;

uniform vec4 color : source_color = vec4(1.0, 0.9, 0.5, 1.0);
uniform float life = 0.0;
uniform float intensity = 2.5;
// The brightest channel of its light, linear before the exposure (Fx.beam: ScreenTone.linear_peak of its colour, the
// most it may write and stay at ScreenTone.SCREEN_MAX on the screen). Hue kept: the light is scaled down, never clipped.
uniform float cap = 1000.0;
// How far its core goes toward white (its sides keep the colour of the reward: 0.6 over all of it turned every column
// white).
uniform float whiten = 0.25;
// The most of the cap one face lays at its brightest (the core at the base): the two faces together leave about a
// third of what is behind showing through.
uniform float body = 0.68;
// The sides: how soft (a power on how squarely the face looks at the camera; higher is a thinner, softer pillar).
uniform float side_soft = 1.6;
// The core: how narrow (the same measure, higher is narrower), how much brighter than the sides and how pale.
uniform float core_width = 8.0;
uniform float core_light = 0.6;
uniform float core_white = 0.45;
// Where on its height (0 base, 1 top) it starts to fade, and the share of its light the base keeps at the very bottom
// (a soft foot on the floor, not a cut).
uniform float top_from = 0.15;
uniform float foot = 0.55;
// Faint streaks rising through it: how many round it, how fast (heights a second) and how much of the light they move.
uniform float streak_count = 7.0;
uniform float streak_speed = 0.35;
uniform float streaks = 0.2;
// The opening around the paladin: half its width and height in metres at his distance, how much of the light stays
// in it, and the soft edge (a fraction of the size).
uniform vec2 hero_hole = vec2(0.75, 1.5);
uniform float hero_keep = 0.15;
uniform float hero_soft = 0.5;
// Where the middle of his body is over his feet.
const float HERO_MID = 1.3;

// Height on the pillar: 0 at its foot on the floor, 1 at its top (Fx.beam's mesh is 1 tall round its middle).
varying float height_of;

void vertex() {
	height_of = VERTEX.y + 0.5;
}

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
	float up = clamp(height_of, 0.0, 1.0);
	float facing = abs(dot(NORMAL, VIEW));
	float side = pow(facing, side_soft);
	float core = pow(facing, core_width);
	float fade = 1.0 - smoothstep(0.3, 1.0, life);
	// gone before the top, a soft foot at the base
	float height = (1.0 - smoothstep(top_from, 1.0, up)) * mix(foot, 1.0, smoothstep(0.0, 0.06, up));
	// light rising through it
	float rise = noise(vec2(UV.x * streak_count, up * 3.0 - TIME * streak_speed * 3.0));
	float move = 1.0 - streaks + streaks * 2.0 * rise;
	// its brightest channel: what it asks for (intensity), never past the cap; this point lays down a share of it
	float bright = min(cap, intensity * max(color.r, max(color.g, color.b)));
	float share = body * (side + core * core_light) * height * move * fade;
	vec3 tint = mix(color.rgb, vec3(max(color.r, max(color.g, color.b))), core * core_white + side * whiten * 0.3);
	float top = max(tint.r, max(tint.g, tint.b));
	vec3 light = tint / max(top, 0.0001) * bright * share;
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
