shader_type spatial;
// The Voragem on the floor (U-2; ultimate_u2_proposals.md A.3, warrior_spec.md 3.2; Ultimates): a faint emerald veil
// (its opacity at most `veil`, 0.3, thicker toward the middle), three fine ivory arms in a spiral that turn inward
// (the pattern runs from the rim to the middle as `turn` grows) and a thin rim of old gold at its edge. At the end the
// rim closes on the middle (`close` 0 to 1) with the arms wound tight: the implosion, never a column. Nothing passes
// the glow threshold (Game.GLOW_THRESHOLD 1.3): each part's brightest channel is its own peak, kept under
// ScreenTone.SAFE by Ultimates. It lays its light over the floor (premultiplied, as ult_rift.gdshader) and opens
// around the paladin where it is nearer the camera than he is (hero_hole). It draws before the enemies' warnings
// (render_priority, set by Ultimates), so their red always reads over it; it only lies on the floor, so it never
// hides a body. Drawn on a flat quad (PlaneMesh 1 x 1) set here to the area in meters.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled;

global uniform vec3 hero_pos;

// The veil's emerald, the arms' ivory and the rim's old gold (only their hues: each brightest channel is its peak).
uniform vec4 color : source_color = vec4(0.3, 1.0, 0.45, 1.0);
uniform vec4 ivory : source_color = vec4(0.95, 0.92, 0.82, 1.0);
uniform vec4 gold : source_color = vec4(0.95, 0.72, 0.3, 1.0);
uniform float veil_peak = 1.0;
uniform float arm_peak = 1.0;
uniform float rim_peak = 1.0;
// The veil: its opacity at most (in the middle), at the rim, and the share of its peak it lights.
uniform float veil = 0.3;
uniform float veil_edge = 0.08;
uniform float veil_light = 0.16;
// The area's radius in meters, the rim's width, the arms' width at the rim and in the middle (meters).
uniform float radius_m = 6.0;
uniform float rim_m = 0.1;
uniform float arm_m = 0.16;
uniform float arm_core_m = 0.06;
// Three arms, how many turns each makes from the rim to the middle, how far it turns (radians, grows with time), the
// share of their light they keep at the rim and in the core (they rise toward the middle, then thin into it).
uniform float arms = 3.0;
uniform float twist = 0.9;
uniform float turn = 0.0;
uniform float arm_light = 0.85;
uniform float arm_rim_share = 0.35;
uniform float core_m = 0.5;
// A second faint thread beside each arm (the wind it drags), its share of the arm's light and its lag (radians).
uniform float trail = 0.35;
uniform float trail_lag = 0.22;
// The rim's share of its peak.
uniform float rim_light = 0.6;
// Its fade in and out (1 whole) and the implosion (0 open, 1 closed on the middle).
uniform float fade = 1.0;
uniform float close = 0.0;
// The opening around the paladin: half its width and height in meters at his distance, the light kept in it, soft edge.
uniform vec2 hero_hole = vec2(0.7, 1.45);
uniform float hero_keep = 0.35;
uniform float hero_soft = 0.5;
const float HERO_MID = 1.3;
const float PAD = 0.2;

varying vec2 at;

void vertex() {
	at = VERTEX.xz * (radius_m + PAD) * 2.0;
	VERTEX = vec3(at.x, 0.0, at.y);
}

// How close x is to a thread of width w (1 on it, 0 past it), soft.
float thread(float x, float w) {
	return 1.0 - smoothstep(w * 0.35, w, x);
}

void fragment() {
	// the implosion: the whole area shrinks into its middle, the arms wind tighter
	float shrink = mix(1.0, 0.04, close * close);
	float r_m = max(radius_m * shrink, 0.05);
	float d = length(at);
	float r = d / r_m;
	if (r > 1.0 + rim_m * 2.0 / r_m) discard;
	float inside = 1.0 - smoothstep(1.0 - 0.02, 1.0, r);
	// the veil: thicker toward the middle
	float va = mix(veil, veil_edge, smoothstep(0.0, 1.0, r)) * inside;
	// the arms: a spiral angle = turn + twist * 2pi * (1 - r); with turn growing the pattern runs inward
	float ang = atan(at.y, at.x);
	float wind = twist * (1.0 + close * 1.5) * 6.2832 * (1.0 - r);
	float sector = 6.2832 / arms;
	float ph = mod(ang - turn - wind, sector);
	ph = min(ph, sector - ph);
	// the angular offset as meters along the circle there
	float off_m = ph * d;
	float w = mix(arm_core_m, arm_m, smoothstep(0.0, 1.0, r));
	float arm = thread(off_m, w);
	float ph2 = mod(ang - turn - wind + trail_lag, sector);
	ph2 = min(ph2, sector - ph2);
	arm = max(arm, thread(ph2 * d, w * 0.7) * trail);
	// brighter toward the middle, thinning into the core, gone past the rim
	float rise = mix(arm_rim_share, 1.0, 1.0 - smoothstep(0.15, 1.0, r)) * smoothstep(0.0, core_m / r_m, r) * inside;
	arm *= rise * arm_light;
	float rim = thread(abs(d - r_m), rim_m) * rim_light;
	vec3 e = color.rgb / max(max(color.r, color.g), max(color.b, 0.001));
	vec3 iv = ivory.rgb / max(max(ivory.r, ivory.g), max(ivory.b, 0.001));
	vec3 g = gold.rgb / max(max(gold.r, gold.g), max(gold.b, 0.001));
	vec3 light = e * veil_peak * veil_light * va / max(veil, 0.001);
	light = mix(light, iv * arm_peak, arm);
	light = mix(light, g * rim_peak, rim);
	float cover = max(va, max(arm, rim));
	// the paladin seen through it
	vec3 hero = (VIEW_MATRIX * vec4(hero_pos + vec3(0.0, HERO_MID, 0.0), 1.0)).xyz;
	float keep = 1.0;
	if (hero.z < 0.0 && VERTEX.z > hero.z) {
		vec2 o = (VERTEX.xy / -VERTEX.z - hero.xy / -hero.z) * -hero.z / hero_hole;
		keep = mix(hero_keep, 1.0, smoothstep(1.0 - hero_soft, 1.0, length(o)));
	}
	float k = fade * keep;
	light *= k;
	float a = clamp(cover * k, 0.0, 1.0);
	if (a <= 0.003) discard;
	ALBEDO = light;
	ALPHA = a;
}
