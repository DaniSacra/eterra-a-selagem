shader_type spatial;
// The crowd: baked poses drawn by MultiMesh (the pose between two of them by the instance's colour,
// crowd_pose.gdshaderinc). INSTANCE_CUSTOM carries the per-enemy state:
// r = hit flash (0..1): the figure's own body, lighter and warmer for an instant (never a flat white: a strong blow
//     reaches white_from only on its first frame, and even then it keeps its shading under the glow threshold);
//     below 0, a blow its armor took: old gold gleams on its edges, no white (it was not wounded),
// g = frost (1) plus 0.5 when its armor is broken (the armored edge light goes out),
// b = burning (1) plus half of how far its wind-up is (0..0.5: the orb of a staff swells),
// a = dissolve on death. (CrowdRenderer.state packs them.)
//
// The crowd is not lit by the torches (too many lights for hundreds of characters), so it carries its own
// painted light: a fixed key from the top left of the screen (light bone, dark crevices), darker feet, and a thin
// dark edge where the body turns away, so each one reads as a shaded figure against the dark floor (reference
// docs/art/ref/arena_catacumbas_1672.png), never a flat cut-out.
render_mode cull_back, diffuse_lambert, specular_disabled;
// Where a figure of the crowd is the front surface, the stencil says so (CROWD_STENCIL = 1): the paladin's x-ray
// shows him in full through the crowd and faint through stone (xray.gdshader, xray_behind.gdshader; cycle 8, B3).
stencil_mode write, compare_always, 1;

uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(1.0);
uniform vec3 rim_color : source_color = vec3(0.4, 0.55, 1.0);
uniform float rim_power = 0.0;
// 1 = the texture's colours in grey; a little calms the saturated leathers of the KayKit atlas.
uniform float desaturate = 0.0;
// How much the scene's own light (the cold ambient and the moon) still lights the body: it tints, the key shapes.
uniform float scene_light = 1.0;
// The painted key light: direction in view space (top left of the screen, toward the camera), colour, strength
// on the lit side and what is left on the side away from it.
uniform vec3 key_dir = vec3(-0.45, 0.75, 0.5);
uniform vec3 key_color : source_color = vec3(1.0, 0.95, 0.86);
uniform float key = 0.0;
uniform float key_fill = 0.0;
// Feet darker than the head (the floor's shadow climbing the legs): brightness at the feet, height in the model's
// meters where it is full.
uniform float foot_shade = 1.0;
uniform float foot_height = 1.2;
// The dark edge where the body turns away from the camera: how dark (0 = none) and where it starts (0..1 of the
// grazing angle).
uniform float ink = 0.0;
uniform float ink_from = 0.55;
// The palette's glowing cells (tools/make_palettes.gd: the last four of its bottom row, eyes, embers, gems) shine
// this much by themselves.
uniform float glow = 2.2;
// Figures with a magic of their own (EnemyDef.magic_color, here with its largest channel at 1): those cells and the
// painting's glowing spots shine in that colour, never in the white of an overexposed texel. The cells (the orb of
// a staff) are always lit at orb, under the glow's threshold, and swell to orb_tell while it winds up.
uniform vec3 magic = vec3(0.0);
uniform float orb = 1.2;
uniform float orb_tell = 1.8;
// The lamp's colour is the magic's raised to this (more saturated), and its edge is this dark (a ball, not a disc).
uniform float orb_depth = 1.7;
uniform float orb_edge = 0.4;
// How much of a glowing spot's own colour gives way to the magic's.
uniform float magic_tint = 0.75;
// Where those cells start (BakedModel.glow_from).
uniform vec2 glow_from = vec2(0.5, 0.75);
// Painted figures (the Meshy models, BakedModel.painted) have no cells: what shines is read from the painting, its
// bright saturated spots (eyes, gems, orbs, embers) glow this much. From which colourfulness (the largest channel
// minus the smallest) and where it is full: red cloth and gold trims stay under it.
uniform float paint_glow = 0.0;
uniform float paint_glow_from = 0.55;
uniform float paint_glow_full = 0.8;
// A painted figure's dark cloth lifted off the dark floor (1 = as painted, less = lighter shadows, same hues).
uniform float paint_gamma = 1.0;
// Elites of a painted figure (EnemyDef.gild): its steel (grey, not warm like bone, not as dark as the cloth) takes
// this much old gold, keeping the painting's light and shadow; the rest of the figure takes gild_rest of that (a
// warm cast, so the elite of a figure without steel still reads apart).
uniform float gild = 0.0;
uniform float gild_rest = 0.3;
uniform vec3 gild_color : source_color = vec3(0.62, 0.46, 0.22);
uniform float gild_light = 1.7;
// Armor that takes a blow: the edges gleam this much in the gild colour for the time of the flash.
uniform float absorb_light = 1.8;
// The death dissolve (state.a): only the specks about to go smoulder, in old gold under the glow threshold (C11
// polish: the old whole-body orange at 3.2 lit Morvath's fall as a saturated yellow blot over the seal).
uniform vec3 dissolve_color : source_color = vec3(0.62, 0.42, 0.18);
uniform float dissolve_band = 0.08;
// A pale light on the edges of the top of the figure (EnemyDef.crest: Morvath's crown cut out of the dark floor):
// strength, and the height in the model's meters from which it is full.
uniform float crest = 0.0;
uniform float crest_from = 1.4;
uniform vec3 crest_color : source_color = vec3(0.86, 0.84, 1.0);
// The flash of a struck figure (cycle 8, B4 of the cycle 7 review: struck enemies were flat white blots, and on an
// Omega one covered the paladin): at its peak the body shows flash_light more of its own painting as light, in a
// warm cast, plus a little warm floor so dark cloth flashes too. Above white_from (the first frame of a strong blow)
// it goes flash_white of the way to a pale ivory, still shaded. Nothing passes flash_cap, under the glow threshold
// (Game.GLOW_THRESHOLD 1.3): a struck figure never blooms into a ball of light.
uniform float flash_light = 0.6;
uniform vec3 flash_warm : source_color = vec3(1.0, 0.9, 0.74);
uniform float flash_floor = 0.1;
uniform float white_from = 0.85;
uniform float flash_white = 0.35;
uniform vec3 flash_ivory : source_color = vec3(0.95, 0.9, 0.8);
uniform float flash_cap = 1.0;
// Burning (a fire gift; cycle 10, N4 of the cycle 9 review: the old burn lit the whole body gold and orange, which hid
// the figure and read like an elite's gild): the painting keeps its colours, only embers live on it. A rim of fire
// where the body turns away (burn_rim at most, on the silhouette), and small coals crawling up the body, each one
// flaring and fading on its own: burn_coals of the cells (burn_grid across the texture, burn_rows a meter of height)
// glow, climbing burn_climb cells a second. All under the glow threshold (Game.GLOW_THRESHOLD 1.3), never yellow.
// The fire's rim takes the place of the cool rim and the crest's edge while it burns (M-1 of the C11 QA: added on
// top of them it outlined a burning Morvath's hood and shoulders in white).
uniform vec3 burn_color : source_color = vec3(1.0, 0.36, 0.08);
uniform float burn_rim = 0.5;
uniform vec3 coal_color : source_color = vec3(1.1, 0.42, 0.1);
uniform float burn_coals = 0.07;
uniform float burn_grid = 42.0;
uniform float burn_rows = 7.0;
uniform float burn_climb = 1.6;
// C12d (VX-08): a figure with a rim of its own (rim_power > 0: elites, the guardians, Morvath) keeps its colour while it
// burns: its fire rim at most burn_rim_own, its coals at burn_coals_own of theirs, and its own rim and crest kept at
// burn_keep_own (Morvath's violet robe turned orange under a fire gift; the cool rim is never added on top of the fire
// at full: M-1 of the C11 QA, a white outline).
uniform float burn_rim_own = 0.25;
uniform float burn_coals_own = 0.5;
uniform float burn_keep_own = 0.7;

// The paladin carries the light of Elun: the warm light around the hero is added here.
global uniform vec3 hero_pos;
uniform vec3 hero_color : source_color = vec3(1.0, 0.72, 0.42);
uniform float hero_range = 11.0;
// How much of that warm light the figure takes (Morvath, always beside the hero, read grey and brown under it).
uniform float hero_light = 1.0;

varying vec4 state;
varying vec3 world_pos;
varying float height;

#include "res://assets/shaders/crowd_pose.gdshaderinc"

void vertex() {
	vec3 at;
	vec3 facing;
	crowd_pose(VERTEX_ID, COLOR, at, facing);
	VERTEX = at;
	NORMAL = facing;
	state = INSTANCE_CUSTOM;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = VERTEX.y;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float speck = hash(floor(UV * 96.0));
	if (state.a > 0.0 && speck < state.a) {
		discard;
	}
	// the cells just about to go (dissolve_band above the cut) smoulder in dissolve_color; the rest keeps its painting
	float smoulder = state.a > 0.0 ? 1.0 - smoothstep(state.a, state.a + dissolve_band, speck) : 0.0;
	float flash = max(state.r, 0.0);
	float absorbed = max(-state.r, 0.0);
	float frost = step(0.75, state.g);
	float armored = 1.0 - clamp((state.g - frost) * 2.0, 0.0, 1.0);
	float burn = step(0.75, state.b);
	float tell = clamp((state.b - burn) * 2.0, 0.0, 1.0);
	vec3 raw = texture(albedo, UV).rgb;
	float top = max(raw.r, max(raw.g, raw.b));
	float colourful = top - min(raw.r, min(raw.g, raw.b));
	float steel = (1.0 - smoothstep(0.1, 0.22, colourful / max(top, 0.001))) * (1.0 - smoothstep(0.0, 0.06, raw.r - raw.b))
		* smoothstep(0.1, 0.2, top);
	raw = mix(raw, gild_color * top * gild_light, max(steel, gild_rest) * gild);
	vec3 c = pow(raw, vec3(paint_gamma));
	c = max(mix(c, vec3(dot(c, vec3(0.3, 0.55, 0.15))), desaturate), vec3(0.0));
	c *= tint.rgb;
	c = mix(c, vec3(0.6, 0.85, 1.0), frost * 0.65);
	float has_magic = step(0.001, magic.r + magic.g + magic.b);
	// the cells that glow (a staff's gem, its orb): with a magic of its own they are that light and nothing else
	float cell = step(glow_from.x, fract(UV.x)) * step(glow_from.y, fract(UV.y));
	float lamp = cell * has_magic;
	c *= 1.0 - lamp;
	// deeper than the magic's own colour (a lamp that is only bright reads white), and darker where it turns away
	vec3 lamp_color = pow(magic, vec3(orb_depth));
	float facing = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float shade = mix(foot_shade, 1.0, smoothstep(0.0, foot_height, height))
		* (1.0 - ink * smoothstep(ink_from, 1.0, 1.0 - facing));
	ALBEDO = c * scene_light * shade;
	float near = 1.0 - clamp(distance(world_pos.xz, hero_pos.xz) / hero_range, 0.0, 1.0);
	float lit = key_fill + key * max(dot(NORMAL, normalize(key_dir)), 0.0);
	float rim = pow(1.0 - facing, 3.0);
	// a crisp edge for elites (rim_power > 0): sharper than the soft rim, so it reads as an outline
	float edge = smoothstep(0.35, 0.6, pow(1.0 - facing, 1.5));
	// the painting's own lights (eyes, gems, embers), leaning to the colour of its magic
	vec3 spot = mix(raw, mix(raw, magic * top, magic_tint), has_magic);
	// burning: a rim of fire and coals flaring up the body (the painting itself untouched)
	vec2 coal_at = vec2(fract(UV.x) * burn_grid, height * burn_rows - TIME * burn_climb);
	float coal_seed = hash(floor(coal_at));
	float coal_dot = 1.0 - smoothstep(0.15, 0.45, length(fract(coal_at) - 0.5));
	float coal = step(1.0 - burn_coals, coal_seed) * coal_dot * (0.5 + 0.5 * sin(TIME * 7.0 + coal_seed * 40.0));
	float own = step(0.001, rim_power);
	float fire_rim = mix(burn_rim, min(burn_rim, burn_rim_own), own);
	float coals = mix(1.0, burn_coals_own, own);
	EMISSION = vec3(0.35, 0.7, 1.4) * frost * 0.5 + (burn_color * rim * fire_rim + coal_color * coal * coals) * burn
		+ (rim_color * (rim * 0.5 + edge) * rim_power * armored
		+ crest_color * (rim * 0.6 + edge) * crest * smoothstep(crest_from * 0.6, crest_from, height)) * (1.0 - burn * (1.0 - burn_keep_own * own))
		+ dissolve_color * smoulder + gild_color * (rim + edge) * absorbed * absorb_light
		+ c * shade * (key_color * lit + hero_color * near * near * 0.55 * hero_light)
		+ raw * glow * cell * (1.0 - has_magic)
		+ lamp_color * mix(orb, orb_tell, tell) * mix(orb_edge, 1.0, facing * facing) * lamp
		+ spot * paint_glow * smoothstep(paint_glow_from, paint_glow_full, colourful) * (1.0 - lamp);
	if (flash > 0.0) {
		// the body itself, lighter and warmer: its painting as light, more where it is already lit; what it adds
		// stops at flash_cap (the figure's own lights, an orb winding up, keep theirs)
		vec3 lighter = (c * shade * (0.45 + lit) * flash_light + vec3(flash_floor)) * flash_warm * flash;
		EMISSION += min(lighter, max(vec3(flash_cap) - EMISSION, vec3(0.0)));
		float white = step(white_from, flash) * flash_white;
		EMISSION = mix(EMISSION, min(flash_ivory * shade * (0.75 + 0.25 * facing), vec3(flash_cap)), white);
		ALBEDO *= 1.0 - white;
	}
}
