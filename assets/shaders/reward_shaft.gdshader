shader_type spatial;
// The light of Elun over what the paladin may take (vfx_pass_spec.md 6, RewardShaft): a frustum of faint light from
// above the screen down to the reliquary, laid over what is behind it (premultiplied, a = light / cap: it never adds past
// its cap, two crossing never pass it), the body a share of the cap (body), soft sides, a narrow paler core, full at the
// floor and fading to `top_keep` at its top (it reads as coming from above, its top never seen), faint streaks falling.
// `reveal` (0..1) runs its lower edge from the top to the floor as it comes down; `lift` (0..1) runs it back up when the
// thing is taken. Within NEAR of the axis of the paladin it falls to `near_keep` (he is taking it: nothing bright over
// him) and it opens round him where it stands in front of him (hero_hole, as the beam).
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

global uniform vec3 hero_pos;

uniform vec3 color : source_color = vec3(1.0, 0.94, 0.82);
// The brightest channel it may write (linear, before the exposure: ScreenTone.linear_peak of its colour times 0.85).
uniform float cap = 1.0;
// Its strength now (RewardShaft: 1, the shop's 0.75 or 0.3, the breath 0.88..1).
uniform float strength = 1.0;
uniform float body = 0.3;
uniform float side_soft = 2.2;
uniform float core_width = 10.0;
uniform float core_light = 0.4;
uniform float core_white = 0.3;
// Full from the floor to full_to of its height, down to top_keep of it at the top.
uniform float full_to = 0.15;
uniform float top_keep = 0.35;
uniform float streak_count = 9.0;
uniform float streak_speed = 0.25;
uniform float streaks = 0.15;
uniform float reveal = 1.0;
uniform float lift = 0.0;
// The paladin near its axis (metres): from near_from it starts to fall, at near_to it keeps near_keep.
uniform float near_from = 2.8;
uniform float near_to = 2.3;
uniform float near_keep = 0.35;
uniform vec2 hero_hole = vec2(0.75, 1.5);
uniform float hero_keep = 0.15;
uniform float hero_soft = 0.5;
// The Compatibility renderer shows its light darker (no linear to sRGB on the way out): RewardShaft sets this there.
uniform float compat_gain = 1.0;
const float HERO_MID = 1.3;

varying float height_of;
varying vec3 axis_of;

void vertex() {
	height_of = VERTEX.y + 0.5;
	axis_of = NODE_POSITION_WORLD;
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
	float along = mix(1.0, top_keep, smoothstep(full_to, 1.0, up)) * smoothstep(0.0, 0.02, up + 0.005);
	// coming down: shown above 1 - reveal, a soft lower edge; going up: shown above lift
	float shown = smoothstep(1.0 - reveal - 0.04, 1.0 - reveal + 0.04, up) * smoothstep(lift - 0.04, lift + 0.04, up);
	float fall = noise(vec2(UV.x * streak_count, up * 4.0 + TIME * streak_speed * 4.0));
	float move = 1.0 - streaks + streaks * 2.0 * fall;
	float near = length(hero_pos.xz - axis_of.xz);
	float keep = mix(near_keep, 1.0, smoothstep(near_to, near_from, near));
	float share = body * (side + core * core_light) * along * move * shown * strength * keep;
	vec3 tint = mix(color, vec3(max(color.r, max(color.g, color.b))), core * core_white);
	vec3 light = tint / max(max(tint.r, max(tint.g, tint.b)), 0.0001) * cap * share * compat_gain;
	vec3 hero = (VIEW_MATRIX * vec4(hero_pos + vec3(0.0, HERO_MID, 0.0), 1.0)).xyz;
	if (hero.z < 0.0 && VERTEX.z > hero.z) {
		vec2 off = (VERTEX.xy / -VERTEX.z - hero.xy / -hero.z) * -hero.z / hero_hole;
		light *= mix(hero_keep, 1.0, smoothstep(1.0 - hero_soft, 1.0, length(off)));
	}
	float peak = max(light.r, max(light.g, light.b));
	if (peak > cap) {
		light *= cap / peak;
		peak = cap;
	}
	ALBEDO = light;
	ALPHA = clamp(peak / max(cap, 0.0001), 0.0, 1.0);
}
