shader_type spatial;
// The strike of a rune tile (E5 spec 3.4, RunesLook): a sheet of ivory-amber light rising 0.4 m off the whole tile
// while it fires (rune_state's g falls from 1 to 0 in 0.25 s), one square a tile in one mesh (UV2 the tile's column and
// row; a tile not firing folds to nothing). Laid over what is behind it, never adding past the screen's cap (cap =
// ScreenTone.linear_peak of the colour; a = light / cap, as the columns of light), brighter along its square rim than
// in its middle, opening round the paladin where it stands in front of him (hero_hole). Square, never round (D-29).
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

global uniform vec3 hero_pos;

uniform sampler2D rune_state : filter_nearest, repeat_disable;
uniform vec3 color : source_color = vec3(1.0, 0.88, 0.70);
uniform float cap = 1.0;
// How high it rises (m), how much of the cap its rim and its middle lay down, the rim's width (share of the tile).
uniform float lift = 0.4;
uniform float rim_share = 0.5;
uniform float middle_share = 0.04;
uniform float rim = 0.12;
uniform vec2 hero_hole = vec2(0.75, 1.5);
uniform float hero_keep = 0.15;
uniform float hero_soft = 0.5;
const float HERO_MID = 1.3;

varying float fire;

void vertex() {
	fire = texelFetch(rune_state, ivec2(UV2), 0).g;
	if (fire <= 0.001) {
		VERTEX = vec3(0.0);
	} else {
		VERTEX.y += lift * (1.0 - fire);
	}
}

void fragment() {
	vec2 q = abs(UV - 0.5) * 2.0;
	float d = 1.0 - max(q.x, q.y);
	float edge = 1.0 - smoothstep(0.0, rim, d);
	float share = mix(middle_share, rim_share, edge) * smoothstep(0.0, 0.02, d) * fire;
	vec3 light = color / max(color.r, max(color.g, color.b)) * cap * share;
	vec3 hero = (VIEW_MATRIX * vec4(hero_pos + vec3(0.0, HERO_MID, 0.0), 1.0)).xyz;
	if (hero.z < 0.0 && VERTEX.z > hero.z) {
		vec2 off = (VERTEX.xy / -VERTEX.z - hero.xy / -hero.z) * -hero.z / hero_hole;
		light *= mix(hero_keep, 1.0, smoothstep(1.0 - hero_soft, 1.0, length(off)));
	}
	float peak = max(light.r, max(light.g, light.b));
	ALBEDO = light;
	ALPHA = clamp(peak / max(cap, 0.0001), 0.0, 1.0);
}
