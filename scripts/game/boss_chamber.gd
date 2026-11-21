class_name BossChamber
extends Node3D
## The Chamber of the Seal (cycle C11, docs/art/boss_chamber_spec.md; Daniel's request in
## docs/design/boss_arena_brief.md): Morvath's round arena over the abyss, built from the spec's plan (measured on the
## reference image with the game's camera). A round platform of dark stone (walkable to WALK_RADIUS: nothing stands
## inside FLOOR_RADIUS), the seal of old gold carved in its middle with the standing lion and the crack of violet light
## (chamber_floor.gdshader; five states over time, SealLook), a balustrade round it with candles, four violet lanterns,
## four gothic pinnacles and two pairs of sarcophagi in niches; to the north a gothic facade turned to the camera, its
## sealed door of gold and violet, hooded statues, crimson banners with the raised sword, two fire bowls; the long
## stairs in from the south; under the platform a wall of pointed arches dropping into the mist; a dark tower, great
## chains, a far ring of arcades and spires in the blue mist, violet glowing up from the abyss.
## It stands on its own (a Node3D: add it, call build()); the fight reads walk_radius, center, hero_spawn, boss_spawn
## and the footprints in `circles` (all outside the floor), and drives its look with on_cue / on_moment (Boss.cue and
## Boss.moment), set_seal_state, set_corruption, final_phase, open_door, seal_portal and seal_restore.
## Meters, x east, z south (north = -z), the seal's middle at the origin. "Bearing" = degrees from north, clockwise:
## x = r sin(bearing), z = -r cos(bearing).

## The walkable circle (the hero's middle never farther than WALK_RADIUS = FLOOR_RADIUS - Player.RADIUS); the floor's
## edge (the inner face of the balustrade); the platform's lip.
const FLOOR_RADIUS := 12.5
const WALK_RADIUS := 12.0
const LIP_RADIUS := 13.6
## Where the fight starts (spec 2.6): the hero at the mouth of the stairs looking north, Morvath on the seal looking
## south. The point the camera looks at (spec 4), the showcase's distance and pitch (the reference's own frame).
const HERO_SPAWN := Vector2(-0.9, 10.4)
const HERO_FACING := Vector2(0, -1)
const BOSS_SPAWN := Vector2(0, -1.2)
const BOSS_FACING := Vector2(0, 1)
const CAM_TARGET := Vector2(0.40, 0.57)
const SHOWCASE_DIST := 51.0
const SHOWCASE_PITCH := 27.0
## Morvath's place for the stone's see-through hole when there is no Morvath (masonry.gdshader, boss_pos).
const BOSS_FAR := Vector3(0, -1000, 0)
## How deep the platform's walls drop (into the mist).
const DEPTH := 26.0

## ---- the perimeter (spec 2.4): the balustrade's middle radius, the ledge the candles stand on (from FLOOR_RADIUS
## out to LEDGE.x, LEDGE.y tall), the cornice under the lip (top, height, how far it stands out).
const RAIL_RADIUS := 13.08
const LEDGE := Vector2(13.4, 0.26)
const CORNICE := Vector3(-0.0, 0.6, 0.15)
## Balustrade runs (bearing from, to) and the posts every POST_ARC degrees (3 m of arc); what stands at each end is
## its own piece (lantern, pinnacle, post, fire bowl).
const RAILS: Array[Vector2] = [Vector2(22.5, 82.0), Vector2(110.0, 167.0), Vector2(193.0, 264.0), Vector2(292.0, 341.0)]
const POST_ARC := 13.3
## The arc in front of the camera (bearings) whose stone opens round the fighters behind it (see_through).
const FRONT_ARC := Vector2(100.0, 195.0)
## The half of the rim nearer the camera (bearings): tall pieces there (the east sarcophagi) stand between the eye and
## the paladin on the rim, and open round him (_see_through).
const NEAR_HALF := Vector2(55.0, 235.0)
## Sarcophagi: the pairs' bearings (each one this many degrees either side), their size (long, wide, tall), lid
## (height, overhang), the plinth under them (height), the niche (half its arc in degrees, the low parapet's radius,
## height and thickness, the ledge it stands on out to this radius), the sword on the lid (height), the gold edge
## (width), the stone a step lighter. C11 polish: a quarter bigger than the first build (they read small next to the
## reference's chests), still clear of the walkable circle and inside the niche's parapet; the plinth's candles move
## out to NICHE_CANDLES degrees either side so they never stand in a chest.
const SARCOPHAGI: Array[float] = [278.0, 96.0]
const SARC_SPREAD := 5.7
const SARC_SIZE := Vector3(2.45, 1.15, 1.15)
const SARC_LID := TombKit.SARC_LID
const SARC_PLINTH := 0.3
const NICHE_CANDLES := 12.4
const NICHE := Vector4(14.0, 14.1, 0.6, 0.35)
const NICHE_LEDGE := 14.5
const SARC_SWORD := 1.85
const SARC_GOLD := TombKit.SARC_GOLD
## The raised sword (_sword): the guard's width and the blade's length as shares of its length, the blade's width
## at the guard, the grip's, the guard's thickness and the pommel (shares of its length), and how the blade narrows
## in steps from the guard to the point. Proportions of a sword, never of a cross (O-1 of the C11 QA: a blade as
## narrow as the grip with the guard a third of the way up read as a cross): a long blade far wider than the grip,
## tapering to its point, a short slim guard near the hilt end, a thin grip and a round knob of a pommel.
const GUARD_SHARE := TombKit.GUARD_SHARE
const SWORD_BLADE := TombKit.SWORD_BLADE
const SWORD_WIDTH := TombKit.SWORD_WIDTH
const SWORD_TAPER: Array[float] = TombKit.SWORD_TAPER
const SARC_TINT := 1.35
## C12a QW-008 (the west pair read as a block of the parapet): the lid a step lighter than the chest (SARC_LID_LIGHT
## times its stone), and a frieze that reads at 1080 lines: a band of the lid's stone round the chest (height, how far
## it stands out, its middle as a share of the chest's height) with a thread of gold under it (height).
const SARC_LID_LIGHT := 1.8
const SARC_FRIEZE := TombKit.SARC_FRIEZE
const SARC_FRIEZE_GOLD := TombKit.SARC_FRIEZE_GOLD
## The pair on the camera's half of the rim (NEAR_HALF, the east one) stands between the eye and a paladin walking
## the rim: its niche goes back NEAR_SARC.x meters, its chest is NEAR_SARC.y tall (the spec's 0.85, not SARC_SIZE.z)
## on a plinth NEAR_SARC.z tall, so its lid stays under his feet in the camera and its stone opens round him
## (_see_through) where it still covers him (M-2 of the C11 QA: he read as standing on its lid).
const NEAR_SARC := Vector3(0.9, 0.85, 0.12)
## A niche's half arc (degrees either side of its bearing).
const NICHE_HALF := 12.0
## Lanterns of violet fire (bearings), their post (size), cage (width, height), roof, glass, flame and light.
const LANTERNS: Array[float] = [264.0, 292.0, 82.0, 110.0]
const LANTERN_R := 13.0
const LANTERN_POST := TombKit.LANTERN_POST
const LANTERN_CAGE := TombKit.LANTERN_CAGE
const LANTERN_ROOF := TombKit.LANTERN_ROOF
const LANTERN_GLASS := Color(0.62, 0.46, 0.95)
const LANTERN_FLAME := Color(0.9, 0.4, 1.6)
const LANTERN_FLAME_SIZE := TombKit.LANTERN_FLAME_SIZE
const LANTERN_LIGHT := Color(0.66, 0.52, 1.0)
const LANTERN_ENERGY := 1.5
const LANTERN_RANGE := 4.5
const LANTERN_ATTENUATION := 1.3
const IRON := TombKit.IRON
## Gothic pinnacles (bearings): base, body's top, spire; the panel with the raised sword (width, height, its foot
## over the ground) and its gold thread.
const PINNACLES: Array[float] = [125.0, 193.0, 310.0, 332.0]
const PINNACLE_R := 13.1
const PINNACLE := TombKit.PINNACLE
## The hole a front pinnacle opens round the paladin behind it (masonry.gdshader see_radius, see_keep): smaller and
## fainter than the balustrade's, so the narrow pinnacle stays there in stipple (O-3 of the C11 QA: the full hole
## erased it and he read as standing in front of it).
const PINNACLE_SEE := Vector2(1.3, 0.45)
const PANEL := TombKit.PANEL
const PANEL_GOLD := TombKit.PANEL_GOLD
## The east post at the stairs' mouth (bearing), the fire bowls (west on the balustrade's line, east in its own court
## by the facade), the clay pots (x, z, height).
const MOUTH_POST := 167.0
const POTS: Array[Vector3] = [Vector3(-5.53, -12.42, 0.8), Vector3(4.26, -13.12, 1.0)]
## Candles (spec 2.4): bearing, how many, lit (with a light of its own). On the ledge at CANDLE_R; in front of the
## camera (FRONT_ARC) none taller than CANDLE_FRONT_MAX.
const CANDLES: Array[Vector3] = [Vector3(30, 4, 1), Vector3(40, 3, 0), Vector3(56, 5, 1), Vector3(72, 3, 0), Vector3(96, 4, 1),
	Vector3(115, 3, 0), Vector3(129, 4, 0), Vector3(140, 5, 1), Vector3(158, 3, 0), Vector3(200, 4, 0), Vector3(213, 5, 1),
	Vector3(234, 3, 0), Vector3(250, 4, 1), Vector3(268, 3, 0), Vector3(283, 4, 0), Vector3(304, 5, 1), Vector3(318, 3, 0),
	Vector3(328, 4, 1), Vector3(337, 3, 0), Vector3(347, 3, 0)]
const CANDLE_R := Vector2(12.62, 12.92)
## A row's candles: how far apart along the edge (m), their radius (m), and one tall one in each row this much taller.
const CANDLE_GAP := Vector2(0.16, 0.3)
const CANDLE_THICK := Vector2(0.06, 0.11)
## In front of the camera the rows stand back against the balusters (CANDLE_FRONT_R, on the curb) and lower
## (CANDLE_FRONT_MAX): taller and nearer the floor's edge, a paladin on the rim behind them was drawn among their
## flames and read as standing on them (M-2 of the C11 QA).
const CANDLE_FRONT_MAX := 0.28
const CANDLE_FRONT_R := Vector2(12.8, 12.96)
const CANDLE_LIGHT := 1.2

## ---- the facade (spec 2.5), in its own frame: `a` along its front (to bearing 75), `n` out of it (to bearing 165),
## from the middle of the door's sill.
const FACADE_ORIGIN := Vector2(0.37, -16.47)
const FACADE_A := Vector2(0.966, -0.259)
const FACADE_N := Vector2(0.259, 0.966)
## The porch's height, its span (a) and depth (n); the body (a span, how deep behind the front, its top, the gable).
const PORCH_Y := 0.9
const PORCH := Vector2(4.6, 1.4)
const BODY := Vector3(7.5, 4.5, 12.5)
## The door: its opening (width, height; the springing and arcs of its point), its orders (how many, ring width and
## depth, how much wider and farther forward each), the keystone over it (height, size).
const DOOR := Vector2(3.4, 5.0)
const DOOR_ORDERS := 3
const ORDER_RING := Vector2(0.45, 0.45)
const ORDER_STEP := Vector2(0.35, 0.38)
const ORDER_ARC := 0.8
const KEYSTONE := Vector2(6.4, 0.5)
## The door's seam at rest, its throb in the last phase (between .x and .y), and the porch's violet light (at rest,
## in the last phase; range).
const SEAM_REST := 1.4
## The door's gold once it is sealed (its own faint light: old gold, never bright yellow).
const DOOR_GOLD := 0.12
const SEAM_FINAL := Vector2(1.0, 1.6)
const PORCH_LIGHT := Vector3(1.5, 2.5, 5.0)
## The stairs up to the porch: their width (a: half), treads (how many straight ones, their run, the rise), the cheeks
## (a from, a to, height of their coping over the treads).
const STAIR_HALF := 3.0
const STAIR_TREADS := 4
const STAIR_RUN := 0.33
const STAIR_RISE := 0.15
const CHEEK := Vector3(3.0, 3.6, 0.55)
## The hooded statues (a, n, height, value), the buttresses (a, width, depth), banners (a, n, bar height; cloth size).
const STATUE := Vector4(3.9, 0.6, 4.4, 0.8)
const BUTTRESS := Vector3(5.6, 1.4, 1.25)
const BANNER := Vector3(5.6, 1.3, 9.0)
const BANNER_SIZE := Vector2(1.4, 4.2)
## The fire bowls (a, n: west on the platform, east in its court), the east court (a from, a to, n from, n to).
const BRAZIER_AT := Vector2(5.6, 2.4)
const COURT := Vector4(3.3, 7.0, 1.25, 4.0)
## A cold light on the facade alone, from the hall (colour, energy, where from in the facade's frame: a, height, n).
const FACADE_FILL := Color(0.55, 0.6, 0.85)
const FACADE_FILL_ENERGY := 2.2
const FACADE_FILL_FROM := Vector3(-3.0, 14.0, 12.0)

## ---- the stairs in from the south (spec 2.6): half their width, the walls' (from, to), the flights (steps, rise,
## run), the landing (z from, z to); the veil across the mouth (width, height, its runes' colour and opacity).
const ENTRY_HALF := 2.3
const ENTRY_WALL := Vector2(2.3, 2.9)
const ENTRY_MOUTH := 12.9
const FLIGHT_1 := Vector3(6, 0.2, 0.5)
const LANDING := Vector2(15.9, 17.1)
const FLIGHT_2 := Vector3(14, 0.2, 0.5)
const VEIL := Vector2(4.6, 1.2)
const VEIL_FADE := 0.8

## ---- under and far (spec 2.7): the wall under the lip (arches every ARCH_STEP degrees: span, height, top, how far
## back their dark), the tower (bearing, r, side, top, its lit window's height and size), the far ring of arcades
## (radius, crown, foot, bearings it spans, every this many degrees, a lit window one in WINDOW_EVERY), the spires
## (two cards: distance from the camera, haze, column, tops).
const ARCH_STEP := 15.0
const UNDER_ARCH := Vector4(2.4, 5.5, -1.6, 0.8)
const TOWER := Vector4(286.0, 16.0, 3.2, 30.0)
const TOWER_WINDOW := Vector3(3.5, 0.5, 0.9)
const FAR_RING := Vector3(38.0, -4.0, -30.0)
const FAR_SPAN := Vector2(200.0, 470.0)
const FAR_STEP := 10.0
const WINDOW_EVERY := 1
## Art review P6 (2026-11-16): the painting's far ring wraps the chamber on both sides with small warm windows; the
## ring now spans from the west-south-west round the north to the east (FAR_SPAN), a window in every pier, small
## and hot enough to read warm through the blue air (size, colour: past the glow threshold, a small point of glow each).
const FAR_WINDOW := Vector2(0.55, 0.95)
## AP-1 (ART-02.5): each lancet is drawn by far_window.gdshader (a pointed head, a frame of the far stone, a mullion
## and a transom, the glass lit warm from below and fading upward, a cooler amber under the glow threshold); every
## other pair is dark (FAR_WINDOW_DARK_EVERY). Before: flat rectangles of one hot orange (2.4, 1.2, 0.45).
const FAR_WINDOW_LOW := Color(1.05, 0.7, 0.4)
const FAR_WINDOW_HIGH := Color(0.3, 0.18, 0.12)
const FAR_WINDOW_FRAME := Color(0.06, 0.055, 0.08)
const FAR_WINDOW_DARK_EVERY := 2
const FAR_WINDOW_SHADER := preload("res://assets/shaders/far_window.gdshader")
## C12a QW-006 (8 windows in the game camera, and the two in the west mist floated over it as cards with no wall
## behind): each pier carries a pair of lancets this far apart (m) on its face, and none where the violet columns
## (COLUMNS) hide the ring's wall (bearings, FAR_WINDOW_HIDDEN).
const FAR_WINDOW_PAIR := 1.0
const FAR_WINDOW_HIDDEN := Vector2(215.0, 280.0)
const SPIRE_DIST: Array[float] = [86.0, 104.0]
const SPIRE_HAZE: Array[float] = [0.35, 0.55]
const SPIRE_COLUMN: Array[float] = [7.0, 5.0]
const SPIRE_TOPS: Array[Vector2] = [Vector2(2.0, 6.0), Vector2(-2.0, 7.0)]
const SPIRE_SINK: Array[Vector2] = [Vector2(-10.0, -24.0), Vector2(-14.0, -30.0)]
const SPIRE_SIZE := Vector2(320.0, 110.0)
const SPIRE_TOP := 30.0
## C11 polish (the sky read a bright saturated blue at the top): the spires are navy silhouettes in a navy mist, their
## block tops only a little lighter (abyss_ruins: stone, edge, mist). Art review P6: that went to near black (top of
## the frame R 0, G 7, B 36); the painting's top between the chains is a deep blue (about R 12, G 41, B 84), so the
## mist, the sky and the spires' edges go back up to it, the spires still darker than their mist.
const SPIRE_STONE := Color(0.03, 0.045, 0.08)
const SPIRE_EDGE := Color(0.12, 0.16, 0.26)
const SPIRE_MIST := Color(0.07, 0.1, 0.16)
## Two lighter patches of mist on the farthest card (ArenaKit.ruin_card: x, height, radii).
const SPIRE_PATCHES: Array[Vector4] = [Vector4(-30.0, -6.0, 18.0, 8.0), Vector4(20.0, -10.0, 14.0, 6.0)]
const NO_PATCHES: Array[Vector4] = []
## The chains (each: from, to, sag), the links' size (2.5: links a meter long).
## C11 polish: low enough to cross the game camera's upper band (they were above its frame): from the far arcades to
## the tower, the tower to the facade's west buttress, the facade's east side out to the far ring twice.
const CHAINS: Array[Array] = [
	[Vector3(-38.0, -3.0, 0.0), Vector3(-15.4, 5.0, -4.4), 2.5],
	[Vector3(-15.4, 5.5, -4.4), Vector3(-5.3, 6.0, -17.2), 1.5],
	[Vector3(6.6, 6.0, -18.5), Vector3(9.8, -3.0, -36.7), 1.5],
	[Vector3(7.2, 5.0, -17.0), Vector3(24.0, -3.0, -30.0), 2.5],
]
const CHAIN_SIZE := 3.4

## ---- room redesign lot E (docs/art/room_redesign_lotE_spec.md; the stylized look only, the classic as built):
## only the background and the air, nothing inside the circle nor within STY_CLEAR of its middle but the far ring's
## own stones. Nothing here takes the room's _rng (STY_SEED: the classic chamber stays the same).
const STY_SEED := 7_1406
## Nothing of the stylized look nearer the middle than the floor plus 6 m (spec 3).
const STY_CLEAR := FLOOR_RADIUS + 6.0
## E1, broken arches at mid height in the far ring's bays (bearings: each on a bay of FAR_RING, where the ring is seen
## past the platform at the west side, against the violet mist; the east side's ring is black there); a lower tier of the ring
## (spring line height, span, ring width, depth) with the stones of `gap` (m across the opening) gone; one stone hangs
## from a short chain under the gap of the arches listed in STY_ARCH_HANGS (how far under the spring line, its tilt).
const STY_ARCHES: Array[float] = [250.0, 260.0, 270.0, 280.0, 290.0]
const STY_ARCH := Vector4(-12.5, 3.8, 0.65, 1.6)
## Their stone is the far ring's (fade, tint) sinking into the mist lower down (sink from, to: m), so they stand dark
## against the violet mist at the west side of the frame (the ring's own sinks from -3 m: under its arches it is mist).
const STY_ARCH_STONE := Vector2(0.8, STY_FAR_TINT)
const STY_ARCH_SINK := Vector2(-11.0, -34.0)
const STY_ARCH_GAPS: Array[Vector2] = [Vector2(-0.4, 1.4), Vector2(-1.5, 0.2), Vector2(-0.2, 1.6), Vector2(-1.2, 0.6), Vector2(0.1, 2.0)]
const STY_ARCH_HANGS: Array[int] = [3]
const STY_HANG := Vector2(3.4, 0.5)
## E2, two chains across the abyss at the sides (from, to, sag; links CHAIN_SIZE): under the game camera's top band and
## over the sarcophagi's height on the screen, never across Morvath (west from the tower, east from the platform's
## wall out to the far ring).
const STY_CHAINS: Array[Array] = [
	[Vector3(-15.4, 4.0, -4.4), Vector3(-34.0, 1.0, 14.0), 3.0],
	[Vector3(12.2, -1.5, -6.6), Vector3(31.0, 1.0, -21.0), 2.5],
]
## E3, stone blocks hanging still in the abyss: how many, where (two spans, the sides of the frame, never toward the
## camera nor behind the facade or the stairs: bearings from, to, how far out from, to, in m, their middles, so no
## corner comes nearer than STY_CLEAR), how high (m), their size (m, the
## smallest and largest side) and how far from the tower's middle they keep (m). Unlit far stone, no glow.
const STY_SHARDS := 24
const STY_SHARD_SPANS: Array[Vector4] = [Vector4(200.0, 280.0, STY_CLEAR + 2.0, 30.0), Vector4(22.0, 55.0, STY_CLEAR + 2.0, 25.0)]
const STY_SHARD_HEIGHT := Vector2(-12.0, -2.0)
const STY_SHARD_SIZE := Vector2(0.5, 2.4)
const STY_SHARD_TOWER := 5.0
## SW-K1 (docs/art/sworn_reference_ideas.md), empty iron cages hanging from the chains over the abyss at the frame's
## sides, never near Morvath on the screen: each [chain (an index into CHAINS then STY_CHAINS), where along it (0 to 1),
## how far under it on its own chain (m), its yaw (degrees), its door open (degrees, 0 shut), its bent bar (-1 none)].
const STY_CAGES: Array[Array] = [
	[0, 0.4, 1.4, 20.0, 0.0, -1],
	[4, 0.24, 0.9, 200.0, 65.0, -1],
	[2, 0.45, 1.8, 120.0, 0.0, 6],
	[5, 0.24, 3.6, 300.0, 0.0, -1],
]
## The cage (radius, height of the bars, of the dome, the bars' width: m; Masonry.cage_mesh), its bars, its chain's
## links (ArenaKit.chain size), its swing (degrees, seconds a swing; each cage a little slower than the one before).
## K-1 of the Sworn P1 review: a third larger than at first (0.55, 1.6, 0.4, 0.07; a link of the chains was almost the
## cage's width: a ship's chain and a bird's cage), at least 2.5 links wide.
const STY_CAGE := Vector4(0.73, 2.13, 0.53, 0.08)
const STY_CAGE_BARS := 10
const STY_CAGE_LINKS := 1.2
const STY_CAGE_SWING := Vector2(3.0, 7.0)
## K-1: an old bone lying on the floor of one cage (STY_CAGE_BONE_IN, the one with the door open; no lore): its length,
## thickness, the knobs at its ends (a share of the length), its turn (degrees), its colour.
const STY_CAGE_BONE_IN := 1
const STY_CAGE_BONE := Vector4(0.55, 0.07, 0.16, 35.0)
const STY_CAGE_BONE_COLOR := Color(0.42, 0.39, 0.33)
## E4, the far air: the sky a step deeper in value, the spires' lit edges a step lighter.
const STY_SKY := 0.9
const STY_SPIRE_EDGE := 1.15
## and the far ring a step lighter, the middle depth between the near tower and platform and the spires: its stone
## (tint) and the mist it sinks into (the right side of the frame was black: the ring sunk into the dark FOG), a
## navy a step over the spires' mist.
const STY_FAR_TINT := 1.4
const STY_FAR_MIST := Color(0.09, 0.125, 0.2)

## ---- light and air (spec 5.2): the light over the middle (place, colour, energy, range), the violet of the abyss
## (bearings, r, height, colour, energy, range), the blue light on the far stone (bearing, r, height, colour, energy,
## range), the air (background, fog, ambient), the moon.
const KEY_AT := Vector3(0, 9.0, 0)
const KEY_COLOR := Color(0.78, 0.76, 0.95)
const KEY_ENERGY := 3.0
const KEY_RANGE := 17.0
const ABYSS_BEARINGS: Array[float] = [250.0, 80.0]
## C18 (ART P1-2, one tone for the scenery: the frame was a fifth saturated violet and blue): the abyss's light, the
## sky, fog, mist, ambient, moon and lanterns keep their hue under 0.45 of saturation.
const ABYSS_LIGHT := Vector4(22.0, -12.0, 3.5, 26.0)
const ABYSS_COLOR := Color(0.66, 0.52, 1.0)
const BLUE_AT := Vector3(330.0, 45.0, 4.0)
const BLUE_COLOR := Color(0.6, 0.68, 0.92)
const BLUE_ENERGY := 1.2
const BLUE_RANGE := 70.0
const SKY := Color(0.05, 0.1, 0.17)
## The depths' stone (depth_stone.gdshader: body and lit edge), violet grey.
const DEEP_STONE := Color(0.07, 0.065, 0.11)
const DEEP_EDGE := Color(0.17, 0.15, 0.24)
const FOG := Color(0.04, 0.06, 0.11)
const MIST := Color(0.05, 0.065, 0.12)
const FOG_DEPTH := Vector2(64.0, 130.0)
const AMBIENT := Color(0.32, 0.34, 0.44)
const AMBIENT_ENERGY := 0.5
const MOON_COLOR := Color(0.52, 0.58, 0.8)
const MOON_ENERGY := 0.35
const MOON_ROTATION := Vector3(-50, 150, 0)
## Violet glow cards rising from the abyss at the frame's sides (bearing, r, foot height, width, height, energy share).
## Art review 2026-11-21 (the abyss still read a light lilac beside the arena, over the fight): all of them dimmed.
const GLOW_DIM := 0.6
const GLOWS: Array[Array] = [
	[260.0, 24.0, -16.0, 26.0, 20.0, 1.3], [235.0, 22.0, -16.0, 20.0, 16.0, 1.1], [290.0, 26.0, -16.0, 18.0, 13.0, 1.0],
	[75.0, 24.0, -16.0, 26.0, 20.0, 1.3], [100.0, 22.0, -16.0, 20.0, 16.0, 1.1], [50.0, 26.0, -16.0, 18.0, 13.0, 1.0],
	[160.0, 22.0, -18.0, 24.0, 10.0, 0.8], [200.0, 22.0, -18.0, 24.0, 10.0, 0.8],
]
## C11 polish: tall columns of violet mist rising out of the abyss at the frame's sides, far out, up past the far
## arcades (bearing, r, foot height, width, height, energy share), with a long reach and a slow fall-off
## (ArenaKit.abyss_glow shape: reach, falloff, side).
const COLUMNS: Array[Array] = [
	[245.0, 34.0, -24.0, 18.0, 46.0, 0.5], [268.0, 36.0, -24.0, 14.0, 52.0, 0.4], [222.0, 32.0, -24.0, 16.0, 40.0, 0.45],
	[70.0, 34.0, -24.0, 16.0, 46.0, 0.75], [95.0, 36.0, -24.0, 12.0, 52.0, 0.6], [118.0, 32.0, -24.0, 14.0, 40.0, 0.6],
]
const COLUMN_SHAPE := Vector3(0.95, 1.25, 0.42)
## Art review 2026-11-21 item 1 (stylized look): the abyss's violet no lighter than the arena (the left third of the
## frame was a pale lilac at value 0.7): the glow cards' colour, the fog boxes' albedo, emission and density, all dark
## violet (hue 255, saturation 0.45, value up to 0.18 in the fog).
const STY_GLOW := Color(0.12, 0.1, 0.19)  # art review 2026-11-21: was (0.2, 0.17, 0.3), a light lilac beside the fight
const STY_FOG_ALBEDO := Color(0.12, 0.1, 0.18)
const STY_FOG_EMISSION := Color(0.035, 0.03, 0.06)
const STY_FOG_DENSITY := 0.025
## Art review 2026-11-21: the violet climbing the deep piers beside the arena (depth_stone glow_energy, 0.25) read a
## light lilac over the fight in the stylized look.
const STY_DEEP_GLOW := 0.08
## Violet fog boxes in the abyss (Forward+): bearing, r, size.
const FOG_BOXES: Array[Vector4] = [Vector4(265.0, 24.0, 18.0, 40.0), Vector4(85.0, 24.0, 18.0, 40.0)]

## ---- the seal (spec 2.3; the shader's other numbers are its uniforms' defaults): the lion's field, its place.
const LION := preload("res://assets/textures/seal/lion_sdf.res")
const SEAL_RADIUS := 5.3
## The crack, in the seal's frame (x right on the screen, y down; m): segments [from, to, grows from, grows to, width
## at from, width at to]. Grows 0..1 in phase 1 (from the lion's head down to its hind paws), 1..2 in phase 2 (a branch
## from its belly toward the stairs, across the inner ring), 2..3 in phase 3 (that branch to the outer ring, a short
## one north across the inner ring), 3..4 in phase 4 (the south one down the point to its tip, the north one to the
## outer ring).
const CRACK: Array[Array] = [
	[Vector2(-0.81, -2.16), Vector2(-0.75, -1.56), 0.0, 0.15, 0.07, 0.07],
	[Vector2(-0.75, -1.56), Vector2(-0.6, -0.9), 0.15, 0.3, 0.07, 0.065],
	[Vector2(-0.6, -0.9), Vector2(-0.48, -0.36), 0.3, 0.45, 0.065, 0.06],
	[Vector2(-0.48, -0.36), Vector2(-0.27, 0.24), 0.45, 0.6, 0.06, 0.06],
	[Vector2(-0.27, 0.24), Vector2(-0.05, 0.9), 0.6, 0.75, 0.06, 0.05],
	[Vector2(-0.05, 0.9), Vector2(0.09, 1.44), 0.75, 0.88, 0.05, 0.045],
	[Vector2(0.09, 1.44), Vector2(-0.03, 1.98), 0.88, 1.0, 0.045, 0.03],
	[Vector2(-0.6, -0.9), Vector2(-0.95, -0.76), 0.4, 0.6, 0.04, 0.03],
	[Vector2(-0.27, 0.24), Vector2(0.08, 0.36), 0.7, 0.85, 0.04, 0.03],
	[Vector2(0.09, 1.44), Vector2(0.36, 1.56), 0.9, 1.0, 0.035, 0.03],
	[Vector2(-0.4, -0.08), Vector2(-0.9, 0.42), 1.0, 1.25, 0.055, 0.05],
	[Vector2(-0.9, 0.42), Vector2(-1.3, 0.95), 1.25, 1.5, 0.05, 0.05],
	[Vector2(-1.3, 0.95), Vector2(-1.75, 1.5), 1.5, 1.75, 0.05, 0.045],
	[Vector2(-1.75, 1.5), Vector2(-2.2, 2.2), 1.75, 2.0, 0.045, 0.04],
	[Vector2(-2.2, 2.2), Vector2(-2.4, 2.45), 2.0, 2.4, 0.04, 0.04],
	[Vector2(-2.4, 2.45), Vector2(-2.65, 2.65), 2.4, 2.7, 0.04, 0.035],
	[Vector2(-0.6, -0.9), Vector2(0.2, -1.4), 2.0, 2.25, 0.045, 0.045],
	[Vector2(0.2, -1.4), Vector2(1.0, -1.8), 2.25, 2.5, 0.045, 0.04],
	[Vector2(1.0, -1.8), Vector2(1.6, -2.15), 2.5, 2.75, 0.04, 0.04],
	[Vector2(1.6, -2.15), Vector2(2.2, -2.2), 2.75, 3.0, 0.04, 0.035],
	[Vector2(-2.65, 2.65), Vector2(-3.0, 3.05), 3.0, 3.4, 0.035, 0.035],
	[Vector2(-3.0, 3.05), Vector2(-3.5, 3.5), 3.4, 4.0, 0.035, 0.03],
	[Vector2(2.2, -2.2), Vector2(2.65, -2.65), 3.0, 3.6, 0.035, 0.03],
]
## The floor's slate (catacomb_floor: the two ends of its stones' colour), a grey with a little violet. Art review P1
## (2026-11-16): the painting's floor reads a mid grey violet (luminance 53); at 0.2 to 0.28 it read 18 under the
## chamber's cold light, so the slate is lighter and a touch warmer (the blue comes from the light), the joints and
## the seal keep their own dark. The hall's floor is its own (CatacombHall), untouched.
const FLOOR_A := Color(0.36, 0.33, 0.33)
const FLOOR_B := Color(0.46, 0.42, 0.42)
## Where the crack closes to in the victory (the lion's heart, seal's frame).
const CRACK_HEART := Vector2(-0.6, -0.7)
## Morvath's phases: the ritual's and the last one's (BossDef.ritual_phase, final_light_phase).
const RITUAL_PHASE := 2
## C12a BOSS-001: while the storm's lanes are on the floor (from storm_wave until its last storm_blade) the seal's heart
## goes this much darker (seal_inside_dark, as under the ritual's shield), easing in and out over STORM_DARK_FADE
## seconds: the lit heart under the six roots and Morvath was the lightest shape of the frame.
const STORM_DARK := 0.4
const STORM_DARK_FADE := 0.3
const FINAL_PHASE := 4

## Footprints of the pieces round the floor (x, z, radius): all outside FLOOR_RADIUS. Nothing here needs to block (the
## floor's circle is the only bound); they are kept for checks and for whoever wants them.
var circles: Array[Vector3] = []
var center := Vector2.ZERO
var walk_radius := WALK_RADIUS
var floor_radius := FLOOR_RADIUS
var hero_spawn := HERO_SPAWN
var boss_spawn := BOSS_SPAWN
## Where the camera looks (the game's camera keeps it fixed in here).
var cam_target := CAM_TARGET
var kit: ArenaKit
var m: Masonry
## The funerary pieces (sarcophagus, lantern, pinnacle, raised sword), shared with the arenas.
var tomb: TombKit
var seal := SealLook.new()
var _floor_mat: ShaderMaterial
var _door_mat: ShaderMaterial
var _veil_mat: ShaderMaterial
var _porch_light: OmniLight3D
var _rng := RandomNumberGenerator.new()
## The door: open (the last phase throbbing), how far the sealing has gone (-1 not sealing), its seconds.
var _door_final := false
var _sealing := false
var _door_seal := 0.0
var _door_seal_time := SealLook.VICTORY_SEAL
var _veil := 0.0
var _veil_want := 0.0
var _storm_left := 0
var _storm_dark := 0.0
## The spires' cards' materials (lot E: their edges in the stylized look) and the broken arches' stone.
var _spire_mats: Array[ShaderMaterial] = []
var _sty_arch: ShaderMaterial
## SW-K1: the cages' pivots (each at its hook on the chain), swung in _process, and the clock of their swing.
var _cages: Array[Node3D] = []
var _cage_clock := 0.0


## Builds the chamber (call once, in the tree or not). In the fight (Arena._chamber_look) it takes the room's layout
## (RoomLayout: floor, hero_spawn, boss_spawn, cam_target; the plan is built for its 12.5 m circle and stands on its
## centre), dresses the world's air for it and draws the veil over the way in; alone (the lab, tests) the spec's own.
func build(_arena: Node3D = null, layout: RoomLayout = null, seed_: int = 1406) -> void:
	BuildSteps.run(build_steps(layout, seed_))


## The build in steps, in order (QA P1-1: Arena.build_async gives each its own black frame).
func build_steps(layout: RoomLayout = null, seed_: int = 1406) -> Array[Callable]:
	set_process(false)  # (its materials are made by the steps)
	return [
		func() -> void:
			if layout != null:
				if layout.floor != null:
					center = layout.floor.center
					floor_radius = layout.floor.radius
					walk_radius = floor_radius - (FLOOR_RADIUS - WALK_RADIUS)
					if not is_equal_approx(floor_radius, FLOOR_RADIUS):
						push_warning("BossChamber: built for a %.1f m floor, the layout's is %.1f m" % [FLOOR_RADIUS, floor_radius])
				hero_spawn = layout.hero_spawn
				boss_spawn = layout.boss_spawn
				cam_target = layout.cam_target
				position = Vector3(center.x, 0.0, center.y)
			_rng.seed = seed_
			kit = ArenaKit.new(self, seed_)
			m = kit.masonry
			tomb = TombKit.new(m)
			_floor(),
		_under,
		_perimeter,
		_facade,
		_entry,
		_far,
		_light,
		_stylize,
		func() -> Array[Callable]:
			var more := m.merge_steps()
			more.append(func() -> void:
				_apply_seal()
				if layout != null:
					set_veil(true)
					_dress_world.call_deferred()
				set_process(true))
			return more,
	]


## The world's air for the chamber (air_values), once the arena stands in the game's world: given to the owner of
## the air (RoomMood, DT-RS1) for both looks; it puts the one in use and takes it off when the chamber leaves.
func _dress_world() -> void:
	if not is_inside_tree():
		return
	var owner_ := RoomMood.of(self)
	if owner_ != null:
		owner_.dress_room(self, air_values(false), air_values(true))


## After the look changed (F7, the options screen; Arena.restyle): the owner of the air holds both looks of the
## chamber's air and puts the one in use. Its stylized pieces follow by themselves.
func restyle() -> void:
	var owner_ := RoomMood.of(self, false)
	if owner_ != null and owner_.dresser() == self:
		owner_.apply()


## The chamber leaves (a common room after it, without a new scene): the world's air goes back exactly as it was.
func _exit_tree() -> void:
	var owner_ := RoomMood.of(self, false)
	if owner_ != null:
		owner_.undress_room(self)


# ---------- the interface for the fight ----------

## Sets the seal to one of its five states (SealLook.State, or a name of SealLook.NAMES), `t` seconds into it.
func set_seal_state(state: Variant, t := 0.0) -> void:
	var s: int = SealLook.NAMES[StringName(state)] if state is String or state is StringName else int(state)
	seal.enter(s as SealLook.State, t)
	if s == SealLook.State.FINAL:
		final_phase(true)
	elif s == SealLook.State.VICTORY:
		_door_final = false
		_sealing = true
		_door_seal_time = SealLook.VICTORY_SEAL
		_door_seal = t - (SealLook.VICTORY_CALM - SealLook.VICTORY_SEAL)
	_apply_seal()


## Morvath's phase (1 to 4): the crack grows to its length over a second.
func set_phase(phase: int) -> void:
	seal.set_phase(phase)


## How far Morvath's corruption has spread through the floor's joints (0..1; below 0: as the seal's state wants).
func set_corruption(x: float) -> void:
	seal.corruption = x


## The last phase: the seal's state 4 and the door throbbing (on), or back to rest (off).
func final_phase(on: bool) -> void:
	if on and seal.state != SealLook.State.FINAL:
		seal.enter(SealLook.State.FINAL)
	elif not on and seal.state == SealLook.State.FINAL:
		seal.enter(SealLook.State.NORMAL)
	_door_final = on


## Morvath's doors (Arena.open_door, at his coming and through his last phase): the sealed door never opens and its
## colour is its own; it throbs only in the last phase (final_phase), so this only takes the call.
func open_door(_tint: Color = ArenaKit.MORVATH) -> void:
	pass


## Morvath is sealed (Arena.seal_portal): over `seconds` the door's seam closes from the foot up and the seal goes to
## its victory (if not there already, timed so its calm comes when the door is closed).
func seal_portal(seconds: float = SealLook.VICTORY_SEAL, _from := Vector2.ZERO) -> void:
	_sealing = true
	_door_seal = 0.0
	_door_seal_time = maxf(seconds, 0.01)
	_door_final = false
	if seal.state != SealLook.State.VICTORY:
		seal.enter(SealLook.State.VICTORY, maxf(0.0, SealLook.VICTORY_CALM - seconds))


## The victory over `duration` seconds (the seal restored), the door sealing with it.
func seal_restore(duration: float = SealLook.VICTORY_TIME) -> void:
	seal.victory_time = duration
	seal.enter(SealLook.State.VICTORY)
	_door_final = false
	_sealing = true
	_door_seal = -(SealLook.VICTORY_CALM - SealLook.VICTORY_SEAL) * duration / SealLook.VICTORY_TIME
	_door_seal_time = SealLook.VICTORY_SEAL * duration / SealLook.VICTORY_TIME


## The veil across the mouth of the stairs (from Morvath's coming to his sealing).
func set_veil(on: bool, at_once := false) -> void:
	_veil_want = 1.0 if on else 0.0
	if at_once:
		_veil = _veil_want


## Boss.cue: the seal follows the fight (phase shifts, the ritual's shield, the victory).
func on_cue(name_: StringName, at: Vector2, dir: Vector2, size: float, seconds: float) -> void:
	match name_:
		&"phase_shift":
			var phase := int(size)
			seal.set_phase(phase)
			if phase == RITUAL_PHASE:
				seal.first_point = point_toward(at - center if at.distance_to(center) > 0.5 else dir)
				seal.enter(SealLook.State.PREP)
			elif phase >= FINAL_PHASE:
				final_phase(true)
		&"shield_up":
			seal.enter(SealLook.State.RITUAL)
		&"shield_break":
			seal.enter(SealLook.State.BREAK)
		&"storm_wave":
			_storm_left += int(size)
			seal.hush_for(seconds)
		&"storm_blade":
			_storm_left = maxi(0, _storm_left - 1)
			seal.hush_for(0.0)
		&"scythe_raise", &"blades_gather", &"curse_gather", &"dash_aim", &"rune":
			# his warnings and crescents are the brightest thing on the floor: the seal goes quiet under them
			seal.hush_for(seconds)
		&"victory_blow":
			_storm_left = 0
			seal_restore()
		&"victory_done", &"victory_fade":
			set_veil(false)


## Boss.moment (nothing yet: the cues carry the timing).
func on_moment(_name: StringName) -> void:
	pass


## The seal's point (0 = up the screen, then clockwise on the screen) nearest to a direction on the floor.
func point_toward(dir: Vector2) -> int:
	var q := _seal_frame(dir)
	return posmod(roundi(q.angle() / (PI * 0.25)) + 2, 8)


## Whether a body of radius r at pos stands on the walkable floor.
func on_floor(pos: Vector2, radius: float) -> bool:
	return pos.distance_to(center) <= FLOOR_RADIUS - radius + 0.0001


func _process(delta: float) -> void:
	seal.step(delta)
	_storm_dark = move_toward(_storm_dark, STORM_DARK if _storm_left > 0 else 0.0, delta * STORM_DARK / STORM_DARK_FADE)
	_veil = move_toward(_veil, _veil_want, delta / VEIL_FADE)
	_swing_cages(delta)
	if _sealing:
		_door_seal += delta
	_apply_seal()


func _apply_seal() -> void:
	if _floor_mat == null:
		return
	var v := seal.values()
	for k: StringName in v:
		var key := &"seal_turns" if k == &"turn" else (&"seal_violet_left" if k == &"violet" else StringName("seal_" + k))
		_floor_mat.set_shader_parameter(key, v[k])
	if _storm_dark > 0.0:
		_floor_mat.set_shader_parameter(&"seal_inside_dark", maxf(float(v[&"inside_dark"]), _storm_dark))
	if _door_mat == null:
		return
	var light := SEAM_REST
	var blue := 0.0
	if _door_final:
		var beat := 0.5 + 0.5 * sin(TAU * SealLook.PORTAL_PULSE_HZ * seal.clock)
		light = lerpf(SEAM_FINAL.x, SEAM_FINAL.y, beat)
		blue = beat
	var closed := clampf(_door_seal / _door_seal_time, 0.0, 1.0) if _sealing else 0.0
	_door_mat.set_shader_parameter(&"seam_light", light)
	_door_mat.set_shader_parameter(&"seam_blue", blue)
	_door_mat.set_shader_parameter(&"seam_closed", closed)
	_door_mat.set_shader_parameter(&"gold_glow", DOOR_GOLD * closed)
	_porch_light.light_energy = (PORCH_LIGHT.y if _door_final else PORCH_LIGHT.x) * (1.0 - closed * 0.6)
	_veil_mat.set_shader_parameter(&"power", _veil)


# ---------- helpers ----------

## A point on the floor at a bearing and radius.
static func at_bearing(bearing: float, r: float) -> Vector2:
	var b := deg_to_rad(bearing)
	return Vector2(r * sin(b), -r * cos(b))


func _v3(p: Vector2, y := 0.0) -> Vector3:
	return Vector3(p.x, y, p.y)


## The yaw that turns a piece's +Z toward the middle from a bearing (its face to the seal).
func _facing_in(bearing: float) -> float:
	var p := at_bearing(bearing, 1.0)
	return atan2(-p.x, -p.y)


## A point of the facade's frame (a along, n out) at height y.
func _fa(a: float, n: float, y := 0.0) -> Vector3:
	var p := FACADE_ORIGIN + FACADE_A * a + FACADE_N * n
	return Vector3(p.x, y, p.y)


## The facade's yaw (its +Z out of its front, +X along it).
func _facade_yaw() -> float:
	return atan2(FACADE_N.x, FACADE_N.y)


## A floor point in the seal's frame (x right on the screen, y down).
func _seal_frame(p: Vector2) -> Vector2:
	var t := deg_to_rad(Feel.live().cam_yaw)
	return Vector2(cos(t) * p.x - sin(t) * p.y, sin(t) * p.x + cos(t) * p.y)


## A circle of `segments` points.
static func _circle(r: float, segments := 96, c := Vector2.ZERO) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in segments:
		pts.append(c + Vector2.from_angle(TAU * i / segments) * r)
	return pts


# ---------- the floor and the seal ----------

func _floor() -> void:
	_floor_mat = kit.floor_material(0.0, Vector2.ZERO, FLOOR_RADIUS * 0.7, preload("res://assets/shaders/chamber_floor.gdshader"))
	_floor_mat.set_shader_parameter(&"stone_a", FLOOR_A)
	_floor_mat.set_shader_parameter(&"stone_b", FLOOR_B)
	_floor_mat.set_shader_parameter(&"unit", 0.8)
	_floor_mat.set_shader_parameter(&"petal_color", FLOOR_A)
	_floor_mat.set_shader_parameter(&"moss_color", Color(0.12, 0.12, 0.2))
	_floor_mat.set_shader_parameter(&"seal_turn", deg_to_rad(Feel.live().cam_yaw))
	_floor_mat.set_shader_parameter(&"seal_lion", LION)
	_floor_mat.set_shader_parameter(&"seal_radius", SEAL_RADIUS)
	_floor_mat.set_shader_parameter(&"seal_heart", CRACK_HEART)
	_floor_mat.set_shader_parameter(&"edge_radius", FLOOR_RADIUS)
	var segs := PackedVector4Array()
	var times := PackedVector4Array()
	for c: Array in CRACK:
		var a: Vector2 = c[0]
		var b: Vector2 = c[1]
		segs.append(Vector4(a.x, a.y, b.x, b.y))
		times.append(Vector4(c[2], c[3], c[4], c[5]))
	segs.resize(24)
	times.resize(24)
	_floor_mat.set_shader_parameter(&"seal_crack", segs)
	_floor_mat.set_shader_parameter(&"seal_crack_t", times)
	_floor_mat.set_shader_parameter(&"seal_crack_count", CRACK.size())
	# the disc of the floor out to the lip, less the mouth of the stairs (they go down from there), cut in squares so
	# each piece only takes the lights near it
	var disc := _circle(LIP_RADIUS, 128)
	var mouth := PackedVector2Array([Vector2(-ENTRY_HALF, ENTRY_MOUTH), Vector2(ENTRY_HALF, ENTRY_MOUTH), Vector2(ENTRY_HALF, LIP_RADIUS + 1.0),
		Vector2(-ENTRY_HALF, LIP_RADIUS + 1.0)])
	var cut := Geometry2D.clip_polygons(disc, mouth)
	var cell := Masonry.MERGE_CELL
	var n := ceili(LIP_RADIUS / cell)
	for ix in range(-n, n):
		for iz in range(-n, n):
			var sq := PackedVector2Array([Vector2(ix, iz) * cell, Vector2(ix + 1, iz) * cell, Vector2(ix + 1, iz + 1) * cell, Vector2(ix, iz + 1) * cell])
			for poly in cut:
				for piece in Geometry2D.intersect_polygons(sq, poly):
					_floor_piece(piece, 0.0, _floor_mat)


## A flat piece of floor (a polygon on x, z) at height y in a floor material.
func _floor_piece(poly: PackedVector2Array, y: float, mat: Material) -> void:
	var tris := Geometry2D.triangulate_polygon(poly)
	if tris.is_empty():
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0, tris.size(), 3):
		var a := poly[tris[i]]
		var b := poly[tris[i + 1]]
		var c := poly[tris[i + 2]]
		# turned to face up (clockwise seen from above)
		if (b - a).cross(c - a) < 0.0:
			var t := b
			b = c
			c = t
		for p in [a, b, c]:
			st.set_normal(Vector3.UP)
			st.set_uv(p)
			st.add_vertex(Vector3(p.x, y, p.y))
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	add_child(mi)


# ---------- under the lip: the cornice and the wall of arches ----------

func _under() -> void:
	var lip := m.ashlar(-CORNICE.y)
	var steps := 48
	var chord := 2.0 * (LIP_RADIUS + CORNICE.z) * sin(PI / steps) + 0.05
	for i in steps:
		var b := 360.0 * (i + 0.5) / steps
		var p := at_bearing(b, LIP_RADIUS - 0.3 + CORNICE.z * 0.5)
		m.box(_v3(p, -CORNICE.y * 0.5), Vector3(chord, CORNICE.y, 0.6 + CORNICE.z), _facing_in(b), lip, false)
	# the wall of pointed arches under the lip, dropping into the mist (unlit stone of the depths)
	m.layers = ArenaKit.DEPTH_LAYER
	var stone := _deep(0.3, 0.85)
	var dark := _deep(0.2, 0.25)
	var span := UNDER_ARCH.x
	var r := LIP_RADIUS - 0.2
	var bay := 2.0 * r * sin(deg_to_rad(ARCH_STEP * 0.5))
	var pier := bay - span
	var arc := span * 0.75
	var rise := sqrt(arc * arc - (arc - span * 0.5) * (arc - span * 0.5))
	var top := UNDER_ARCH.z
	var spring := top - rise
	var foot := top - UNDER_ARCH.y
	for i in int(360.0 / ARCH_STEP):
		var b := ARCH_STEP * (i + 0.5)
		# none under the facade's dais (it drops on its own)
		if b > 345.0 or b < 15.0:
			continue
		var yaw := _facing_in(b)
		var mid := at_bearing(b, r)
		var edge := at_bearing(b + ARCH_STEP * 0.5, r)
		m.box(_v3(edge, (-CORNICE.y - DEPTH) * 0.5), Vector3(pier, DEPTH - CORNICE.y, 1.2), yaw + deg_to_rad(ARCH_STEP * 0.5), stone, false)
		m.box(_v3(mid, (foot - DEPTH) * 0.5), Vector3(bay, DEPTH + foot, 1.0), yaw, stone, false)
		m.box(_v3(mid, (top - CORNICE.y) * 0.5), Vector3(bay, -CORNICE.y - top + 0.02, 1.0), yaw, stone, false)
		m.arch_ring(_v3(mid, spring), at_bearing(b, 1.0), span, 0.45, 1.0, stone, 0.75)
		var back := at_bearing(b, r - UNDER_ARCH.w)
		m.box(_v3(back, (top + foot) * 0.5), Vector3(bay, top - foot, 0.3), yaw, dark, false)
	m.layers = 1


# ---------- the perimeter ----------

func _perimeter() -> void:
	var front := m.stone(0.0).duplicate() as ShaderMaterial
	front.set_shader_parameter(&"see_through", 1.0)
	var plain := m.stone(0.0)
	# the ledge round the floor's edge (the candles stand on it), and the balustrade in runs between its pieces
	for run in RAILS:
		var spans := maxi(1, roundi((run.y - run.x) / POST_ARC))
		for i in spans:
			var b0: float = lerpf(run.x, run.y, float(i) / spans)
			var b1: float = lerpf(run.x, run.y, float(i + 1) / spans)
			var mid := (b0 + b1) * 0.5
			var mat := front if mid > FRONT_ARC.x and mid < FRONT_ARC.y else plain
			var p0 := at_bearing(b0, RAIL_RADIUS)
			var p1 := at_bearing(b1, RAIL_RADIUS)
			m.balustrade(_v3(p0), _v3(p1), false, mat)
			# the posts: the run's own ends are other pieces
			if i > 0:
				m.post(_v3(p0), _facing_in(b0), Masonry.POST.y, mat)
			_ledge(b0, b1, mat)
			circles.append(Vector3(p0.x, p0.y, Masonry.POST.x * 0.5))
	for s in SARCOPHAGI:
		_niche(s)
	for b in LANTERNS:
		_lantern(b, front if b > FRONT_ARC.x and b < FRONT_ARC.y else plain)
	var slim := front.duplicate() as ShaderMaterial
	slim.set_shader_parameter(&"see_radius", PINNACLE_SEE.x)
	slim.set_shader_parameter(&"see_keep", PINNACLE_SEE.y)
	for b in PINNACLES:
		_pinnacle(b, slim if b > FRONT_ARC.x and b < FRONT_ARC.y else plain)
	var mp := at_bearing(MOUTH_POST, PINNACLE_R)
	m.post(_v3(mp), _facing_in(MOUTH_POST), Masonry.POST.y, front)
	circles.append(Vector3(mp.x, mp.y, Masonry.POST.x * 0.5))
	for p in POTS:
		m.pot(Vector3(p.x, 0, p.y), p.z)
	for c in CANDLES:
		var in_front := c.x > FRONT_ARC.x and c.x < FRONT_ARC.y
		if _in_near_niche(c.x):
			# on the plinth of the near pair, gone back with it
			_candle_row(c.x, NEAR_SARC.z, int(c.y), c.z > 0.0, CANDLE_FRONT_MAX, CANDLE_R + Vector2.ONE * NEAR_SARC.x, true)
			continue
		_candle_row(c.x, LEDGE.y, int(c.y), c.z > 0.0, CANDLE_FRONT_MAX if in_front else CatacombHall.CANDLE_HEIGHT.y,
			CANDLE_FRONT_R if in_front else CANDLE_R, in_front)


## The ledge at the balustrade's foot between two bearings: from the floor's edge out under the rail.
func _ledge(b0: float, b1: float, mat: Material) -> void:
	var pts := PackedVector2Array()
	var n := 3
	for i in n + 1:
		pts.append(at_bearing(lerpf(b0, b1, float(i) / n), FLOOR_RADIUS))
	for i in range(n, -1, -1):
		pts.append(at_bearing(lerpf(b0, b1, float(i) / n), LEDGE.x))
	m.prism(pts, 0.0, LEDGE.y, mat)


## A group of candles along the floor's edge at a bearing (the hall's candles, Masonry.candle, laid along the edge
## in the band `band`, CANDLE_R by default, so none stands on the walkable floor): `count` of them, the first the tallest, a warm halo, a
## light of its own if lit; none taller than max_height. open: wax, flames and halo open round the paladin behind them
## like the front balustrade (Masonry.candle's open; C12a BOSS-002: on the south rim they were drawn over his legs).
func _candle_row(bearing: float, y: float, count: int, lit: bool, max_height: float, band := CANDLE_R, open := false) -> void:
	var along := 0.0
	var top := 0.0
	for i in count:
		var t := 1.0 if i == 0 else _rng.randf_range(0.0, 0.6)
		var r := lerpf(CANDLE_THICK.x, CANDLE_THICK.y, t)
		var side := -1.0 if i % 2 == 1 else 1.0
		if i > 0:
			along += _rng.randf_range(CANDLE_GAP.x, CANDLE_GAP.y)
		var b := bearing + rad_to_deg(side * along / band.x)
		var p := at_bearing(b, _rng.randf_range(band.x + r, band.y - r))
		var h := minf(lerpf(CatacombHall.CANDLE_HEIGHT.x, CatacombHall.CANDLE_HEIGHT.y * 0.8, t), max_height)
		top = maxf(top, h)
		m.candle(_v3(p, y), h, r, open)
	var at := at_bearing(bearing, (band.x + band.y) * 0.5)
	var glow := MeshInstance3D.new()
	glow.mesh = Fx.quad(CatacombHall.CANDLE_HALO, Color(0.8, 0.45, 0.18) * CatacombHall.CANDLE_HALO_ALPHA)
	glow.position = _v3(at, y + top * 0.8)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if open:
		glow.material_override = Masonry.see_open(glow.mesh.surface_get_material(0))
	add_child(glow)
	if not lit:
		return
	var l := OmniLight3D.new()
	l.position = _v3(at, y + 0.9)
	l.light_color = Color(1.0, 0.7, 0.4)
	l.light_energy = CANDLE_LIGHT
	l.omni_range = CatacombHall.CANDLE_RANGE
	l.light_cull_mask = ~Arena.CROWD_LAYER
	add_child(l)


## A pair of sarcophagi in their niche at a bearing: a plinth along the edge, the two on it, a low parapet behind on a
## ledge of the platform.
func _niche(bearing: float) -> void:
	var near := _near(bearing)
	var back := NEAR_SARC.x if near else 0.0
	var plinth_y := NEAR_SARC.z if near else SARC_PLINTH
	var half := NICHE_HALF
	var a := bearing - half
	var b := bearing + half
	# the platform's ledge out to the parapet, and the plinth along the floor's edge
	var ledge := PackedVector2Array()
	var plinth := PackedVector2Array()
	var steps := 8
	for i in steps + 1:
		var t := lerpf(a, b, float(i) / steps)
		ledge.append(at_bearing(t, LIP_RADIUS - 0.2))
		plinth.append(at_bearing(t, FLOOR_RADIUS))
	for i in range(steps, -1, -1):
		var t := lerpf(a, b, float(i) / steps)
		ledge.append(at_bearing(t, NICHE_LEDGE + back))
		plinth.append(at_bearing(t, LIP_RADIUS + back))
	m.prism(ledge, -CORNICE.y, -0.02)
	m.layers = ArenaKit.DEPTH_LAYER
	var drop := PackedVector2Array(ledge)
	m.prism(drop, -DEPTH, -CORNICE.y, _deep(0.3, 0.85))
	m.layers = 1
	m.prism(plinth, 0.0, plinth_y)
	# the low parapet behind, in chords
	var pm := m.stone(0.0, Color.WHITE * 0.95)
	for i in steps:
		var t0 := lerpf(a, b, float(i) / steps)
		var t1 := lerpf(a, b, float(i + 1) / steps)
		var p0 := at_bearing(t0, NICHE.y + back)
		var p1 := at_bearing(t1, NICHE.y + back)
		var mid := (p0 + p1) * 0.5
		var yaw := atan2(p1.x - p0.x, p1.y - p0.y) + PI * 0.5
		m.box(_v3(mid, NICHE.z * 0.5 - 0.02), Vector3(p0.distance_to(p1) + 0.05, NICHE.z, NICHE.w), yaw, pm, false)
		m.box(_v3(mid, NICHE.z + 0.06), Vector3(p0.distance_to(p1) + 0.1, 0.12, NICHE.w + 0.12), yaw, pm, false)
	for sd: float in [-1.0, 1.0]:
		_sarcophagus(bearing + sd * SARC_SPREAD, back, plinth_y, NEAR_SARC.y if near else SARC_SIZE.z)
	# candles on the plinth between the sarcophagi and the lanterns
	for sd: float in [-1.0, 1.0]:
		var cb := bearing + sd * NICHE_CANDLES
		if near:
			_candle_row(cb, plinth_y, 3, false, CANDLE_FRONT_MAX, CANDLE_R + Vector2.ONE * back, true)
		else:
			_candle_row(cb, plinth_y, 3, false, CatacombHall.CANDLE_HEIGHT.y)


## One sarcophagus at a bearing, its long side along the floor's edge (its inner face on it): a chamfered chest with a
## frieze, a lid with a gold edge and the raised sword in low relief, a sunk panel on the face to the middle.
func _sarcophagus(bearing: float, back := 0.0, plinth_y := SARC_PLINTH, tall := SARC_SIZE.z) -> void:
	var size := Vector3(SARC_SIZE.x, SARC_SIZE.y, tall)
	var at := at_bearing(bearing, FLOOR_RADIUS + SARC_SIZE.y * 0.5 + 0.15 + back)
	var stone := _see_through(m.stone(plinth_y, Color.WHITE * SARC_TINT), bearing)
	var light := _see_through(m.stone(plinth_y, Color.WHITE * SARC_TINT * SARC_LID_LIGHT), bearing)
	var hollow := _see_through(m.stone(plinth_y, Color.WHITE * SARC_TINT * 0.7), bearing)
	tomb.sarcophagus(_v3(at, plinth_y), _facing_in(bearing), size, stone, light, hollow, SARC_SWORD)

## The raised sword (spec 5.4) laid at `at` (its middle), its length along `along`, its width along `across` (both in
## the basis' frame), `size` long: the blade (SWORD_BLADE) far wider than the grip narrowing to the point, a short slim
## guard with its tips falling, the thin grip, a knob of a pommel; in stone `mat`, standing `relief` meters out (across x along). No ring, no equal arms: a sword.
func _sword(at: Vector3, basis: Basis, along: Vector3, across: Vector3, size: float, mat: Material, relief: float) -> void:
	tomb.sword_relief(at, basis, along, across, size, mat, relief)

## The stone of a piece at a bearing on the camera's half of the rim (NEAR_HALF) opens round the paladin behind it
## (masonry.gdshader see_through), as the front balustrade does (M-2 of the C11 QA: walking the east rim behind the
## east sarcophagi he was drawn whole over the lid and read as standing on it); elsewhere the stone as it is.
func _see_through(stone: ShaderMaterial, bearing: float) -> ShaderMaterial:
	if not _near(bearing):
		return stone
	var key := stone.get_instance_id()
	if not _open_stone.has(key):
		var open := stone.duplicate() as ShaderMaterial
		open.set_shader_parameter(&"see_through", 1.0)
		_open_stone[key] = open
	return _open_stone[key]


var _open_stone: Dictionary = {}


## In the arc of a niche on the camera's half of the rim (its candles go back and down with its pair).
func _in_near_niche(bearing: float) -> bool:
	for n in SARCOPHAGI:
		if _near(n) and absf(bearing - n) < NICHE_HALF:
			return true
	return false


## On the camera's half of the rim (NEAR_HALF).
func _near(bearing: float) -> bool:
	return bearing > NEAR_HALF.x and bearing < NEAR_HALF.y


## A small block of a relief: its middle at `at` + basis * offset, its size along, across and out.
func _bar(center_: Vector3, size: Vector3, yaw: float, mat: Material) -> void:
	tomb.bar(center_, size, yaw, mat)


## The old gold of the ironwork and the edges (inlaid metal, never bright yellow).
func _gold() -> StandardMaterial3D:
	return tomb.gold()

## A lantern of violet fire at a bearing: a stone post, an iron cage with a pointed roof, violet glass with a small
## flame in it, a violet light on the floor and the stone near it.
func _lantern(bearing: float, mat: Material) -> void:
	var at := at_bearing(bearing, LANTERN_R)
	tomb.lantern(_v3(at), _facing_in(bearing), mat, TombKit.Lamp.new(LANTERN_GLASS, LANTERN_FLAME, LANTERN_LIGHT, LANTERN_ENERGY, LANTERN_RANGE, LANTERN_ATTENUATION))
	circles.append(Vector3(at.x, at.y, (LANTERN_POST.x + 0.12) * 0.5))

func _unlit(c: Color) -> StandardMaterial3D:
	return tomb.unlit(c)


var _windows := {}


## The far ring's lancet (far_window.gdshader), lit or dark: one material each.
func _far_window(lit: bool) -> ShaderMaterial:
	if not _windows.has(lit):
		var w := ShaderMaterial.new()
		w.shader = FAR_WINDOW_SHADER
		w.set_shader_parameter(&"glass_low", FAR_WINDOW_LOW)
		w.set_shader_parameter(&"glass_high", FAR_WINDOW_HIGH)
		w.set_shader_parameter(&"frame_color", FAR_WINDOW_FRAME)
		w.set_shader_parameter(&"lit", 1.0 if lit else 0.0)
		_windows[lit] = w
	return _windows[lit]

## A gothic pinnacle at a bearing: a base, a tall body, a spire; on its face to the middle (and on the one to the
## camera, if another) a pointed panel with the raised sword in relief and a thread of gold.
func _pinnacle(bearing: float, mat: Material) -> void:
	var at := at_bearing(bearing, PINNACLE_R)
	tomb.pinnacle(_v3(at), _facing_in(bearing), mat)
	circles.append(Vector3(at.x, at.y, (PINNACLE.x + 0.16) * 0.5))

# ---------- the facade and the sealed door ----------

func _facade() -> void:
	var yaw := _facade_yaw()
	var ash := m.ashlar(PORCH_Y)
	var body_mat := m.ashlar(PORCH_Y, Color(0.95, 1.0, 1.04))
	# the dais under the porch and the body, down into the abyss
	m.block(_fa(0, (PORCH.y - BODY.y) * 0.5, -DEPTH), Vector3(BODY.x * 2.0 + 0.6, DEPTH + PORCH_Y, PORCH.y + BODY.y), yaw, ash, false)
	var porch := kit.floor_material(0.0, Vector2.ZERO, 0.0)
	porch.set_shader_parameter(&"unit", 0.6)
	porch.set_shader_parameter(&"stone_a", FLOOR_A)
	porch.set_shader_parameter(&"stone_b", FLOOR_B)
	_floor_piece(_fa_poly([Vector2(-BODY.x, 0.0), Vector2(BODY.x, 0.0), Vector2(BODY.x, PORCH.y), Vector2(-BODY.x, PORCH.y)]), PORCH_Y + 0.01, porch)
	# the stairs down to the floor: straight treads, then the bottom one curved to the floor's edge
	for i in STAIR_TREADS:
		var n0 := PORCH.y + STAIR_RUN * i
		var top := PORCH_Y - STAIR_RISE * (i + 1)
		m.block(_fa(0, n0 + STAIR_RUN * 0.5, -0.4), Vector3(STAIR_HALF * 2.0, top + 0.4, STAIR_RUN), yaw, ash, false)
	var n_last := PORCH.y + STAIR_RUN * STAIR_TREADS
	var last := PackedVector2Array()
	last.append(_fa2(-STAIR_HALF, n_last))
	last.append(_fa2(STAIR_HALF, n_last))
	var far_e := _cross(STAIR_HALF, FLOOR_RADIUS)
	var far_w := _cross(-STAIR_HALF, FLOOR_RADIUS)
	last.append(_fa2(STAIR_HALF, far_e))
	var b_e := _bearing_of(_fa2(STAIR_HALF, far_e))
	var b_w := _bearing_of(_fa2(-STAIR_HALF, far_w))
	# the short way round (the west end is just west of north)
	if b_w > b_e + 180.0:
		b_w -= 360.0
	for i in range(1, 12):
		var t := lerpf(b_e, b_w, i / 12.0)
		last.append(at_bearing(t, FLOOR_RADIUS))
	last.append(_fa2(-STAIR_HALF, far_w))
	m.prism(last, -0.4, PORCH_Y - STAIR_RISE * (STAIR_TREADS + 1), ash)
	# under the stairs and beside them, the platform down into the abyss
	m.layers = ArenaKit.DEPTH_LAYER
	m.prism(_fa_poly([Vector2(-BODY.x, PORCH.y), Vector2(BODY.x, PORCH.y), Vector2(BODY.x, COURT.w + 0.4), Vector2(-BODY.x, 3.6)]),
		-DEPTH, -0.42, _deep(0.3, 0.85))
	m.layers = 1
	# the cheeks of the stairs: a coping falling from the porch to the floor, a wall under it
	for sd: float in [-1.0, 1.0]:
		var a := sd * (CHEEK.x + CHEEK.y) * 0.5
		var end_n := _cross(a, RAIL_RADIUS)
		var len := end_n - PORCH.y
		var hi := PORCH_Y + CHEEK.z
		var lo := CHEEK.z + 0.1
		var mid := _fa(a, PORCH.y + len * 0.5, (hi + lo) * 0.5)
		var slope := atan2(hi - lo, len)
		var cop := m.box(mid, Vector3(CHEEK.y - CHEEK.x + 0.1, 0.16, sqrt(len * len + (hi - lo) * (hi - lo))), yaw, ash, false)
		cop.basis = Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, slope)
		var k := 5
		for i in k:
			var t0 := float(i) / k
			var t1 := float(i + 1) / k
			var h := lerpf(hi, lo, t1) - 0.08
			m.block(_fa(a, PORCH.y + len * (t0 + t1) * 0.5, -0.4), Vector3(CHEEK.y - CHEEK.x, h + 0.4, len / k + 0.02), yaw, ash, false)
	# the east end of the cheek: the post where the east balustrade ends; the west one: a short wall to the fire bowl
	var e_end := _fa2((CHEEK.x + CHEEK.y) * 0.5, _cross((CHEEK.x + CHEEK.y) * 0.5, RAIL_RADIUS))
	m.post(_v3(e_end), _facing_in(_bearing_of(e_end)))
	circles.append(Vector3(e_end.x, e_end.y, Masonry.POST.x * 0.5))
	var w_end := _fa2(-(CHEEK.x + CHEEK.y) * 0.5, _cross(-(CHEEK.x + CHEEK.y) * 0.5, RAIL_RADIUS))
	var west_bowl := _fa2(-BRAZIER_AT.x, BRAZIER_AT.y)
	m.balustrade(_v3(w_end), _v3(west_bowl), false)
	# the court of the east fire bowl, at the floor's level, with its balustrade on the abyss side
	m.prism(_fa_poly([Vector2(COURT.x, COURT.z), Vector2(COURT.y, COURT.z), Vector2(COURT.y, COURT.w), Vector2(COURT.x, COURT.w + 1.4)]), -0.4, -0.01, ash)
	_floor_piece(_fa_poly([Vector2(COURT.x, COURT.z), Vector2(COURT.y, COURT.z), Vector2(COURT.y, COURT.w), Vector2(COURT.x, COURT.w + 1.4)]), 0.0, porch)
	m.balustrade(_v3(e_end), _fa(COURT.y - 0.1, COURT.w), false)
	m.balustrade(_fa(COURT.y - 0.1, COURT.w), _fa(COURT.y - 0.1, COURT.z), true)
	# the fire bowls: west on the balustrade's line (its shadow), east in the court (no shadow)
	kit.brazier(west_bowl, 0.0, false)
	var east := kit.brazier(_fa2(BRAZIER_AT.x, BRAZIER_AT.y), 0.0, false)
	east.shadow_enabled = false
	circles.append(Vector3(west_bowl.x, west_bowl.y, ArenaKit.BRAZIER_RADIUS))
	# the body of the facade: the wall with the door's gap, buttresses with pinnacles, the gable over the door
	_facade_body(yaw, body_mat)
	_door(yaw, ash)
	# the statues beside the door, the banners on the buttresses
	for sd: float in [-1.0, 1.0]:
		var s := _fa(sd * STATUE.x, STATUE.y)
		kit.statue(Vector2(s.x, s.z), yaw, STATUE.z, PORCH_Y, STATUE.w, false)
		kit.banner(_fa(sd * BANNER.x, BANNER.y, BANNER.z), yaw, BANNER_SIZE, 1, ArenaKit.Emblem.SWORD)
	# a cold light from the hall on the facade alone
	var fill := SpotLight3D.new()
	add_child(fill)
	fill.look_at_from_position(_fa(FACADE_FILL_FROM.x, FACADE_FILL_FROM.z, FACADE_FILL_FROM.y), _fa(0, 0, 4.0))
	fill.light_color = FACADE_FILL
	fill.light_energy = FACADE_FILL_ENERGY
	fill.spot_range = 40.0
	fill.spot_angle = 35.0
	fill.spot_attenuation = 0.5
	fill.light_cull_mask = ArenaKit.FACADE_LAYER


## The facade's wall: left and right of the door's orders up to the gable's foot, the block over the door, the gable,
## the buttresses with pinnacles, dark pointed windows.
func _facade_body(yaw: float, mat: Material) -> void:
	m.layers = 1 | ArenaKit.FACADE_LAYER
	var y := PORCH_Y
	var outer := DOOR.x * 0.5 + ORDER_STEP.x * (DOOR_ORDERS - 1) + ORDER_RING.x
	var wall := BODY.z - y - 2.0
	for sd: float in [-1.0, 1.0]:
		var a := sd * (outer + BODY.x) * 0.5
		m.block(_fa(a, -BODY.y * 0.5, y), Vector3(BODY.x - outer, wall, BODY.y), yaw, mat)
	m.block(_fa(0, -BODY.y * 0.5 - 0.3, y + DOOR.y + 0.6), Vector3(outer * 2.0, wall - DOOR.y - 0.6, BODY.y - 0.6), yaw, mat)
	# the gable over the middle, its sloped copings
	var slope := tan(deg_to_rad(CatacombHall.GABLE_SLOPE))
	var gw := outer + 0.6
	var top := y + wall
	var steps := 6
	for i in steps:
		var hb := gw * slope / steps
		var half := gw * (1.0 - float(i) / steps)
		m.block(_fa(0, -0.5, top + hb * i), Vector3(half * 2.0, hb, 1.4), yaw, mat)
	for sd: float in [-1.0, 1.0]:
		var len := gw / cos(deg_to_rad(CatacombHall.GABLE_SLOPE))
		var cop := m.box(_fa(sd * gw * 0.5, 0.25, top + gw * slope * 0.5), Vector3(len + 0.3, 0.3, 0.7), yaw, mat, false)
		cop.basis = Basis(Vector3.UP, yaw) * Basis(Vector3.BACK, -sd * deg_to_rad(CatacombHall.GABLE_SLOPE))
	# buttresses standing out of the wall, pinnacles on top
	for sd: float in [-1.0, 1.0]:
		var bx := sd * BUTTRESS.x
		m.block(_fa(bx, BUTTRESS.z * 0.5 - 0.3, y), Vector3(BUTTRESS.y, BODY.z - y, BUTTRESS.z + 0.6), yaw, mat)
		m.block(_fa(bx, BUTTRESS.z * 0.5, y), Vector3(BUTTRESS.y + 0.2, 1.6, BUTTRESS.z + 0.8), yaw, mat)
		m.point(_fa(bx, BUTTRESS.z * 0.5, y + 1.6), BUTTRESS.y + 0.2, 0.5, yaw, 0.3, mat)
		m.pinnacle(_fa(bx, BUTTRESS.z * 0.5 - 0.3, BODY.z), CatacombHall.PINNACLE.x, CatacombHall.PINNACLE.y, mat)
		# a dark pointed window high in each bay
		var wa := sd * (BUTTRESS.x + BODY.x) * 0.5 + sd * 0.4
		var hollow := m.stone(y, Color.WHITE * 0.25)
		m.box(_fa(wa, 0.02, y + 6.6), Vector3(0.9, 2.2, 0.08), yaw, hollow, false)
		m.pointed_arch(_fa(wa, 0.06, y + 5.5), Vector2(FACADE_N.x, FACADE_N.y), 0.9, 2.6, 0.16, 0.2, mat)
	# a cornice along the wall
	m.box(_fa(0, 0.1, y + 8.2), Vector3(BODY.x * 2.0, 0.25, 0.4), yaw, mat, false)
	m.layers = 1


## The sealed door in its deep pointed doorway: three orders of voussoirs stepping out, jambs, the keystone with the
## raised sword, the two leaves (chamber_door.gdshader), the porch's violet light.
func _door(yaw: float, mat: Material) -> void:
	var y := PORCH_Y
	var arc := DOOR.x * ORDER_ARC
	var cx := arc - DOOR.x * 0.5
	var spring := DOOR.y - sqrt(arc * arc - cx * cx)
	var order := m.ashlar(y, CatacombHall.PORTAL_ORDER_TINT)
	var facing := Vector2(FACADE_N.x, FACADE_N.y)
	var apex := 0.0
	for k in DOOR_ORDERS:
		var span := DOOR.x + ORDER_STEP.x * 2.0 * k
		var n := ORDER_RING.y * 0.5 + ORDER_STEP.y * k - 0.1
		var r := span * ORDER_ARC
		var c := r - span * 0.5
		var sp := spring - (sqrt(r * r - c * c) - sqrt(arc * arc - cx * cx)) * 0.0
		for sd: float in [-1.0, 1.0]:
			m.block(_fa(sd * (span + ORDER_RING.x) * 0.5, n, y), Vector3(ORDER_RING.x, sp, ORDER_RING.y), yaw, order)
		var a := m.voussoir_arch(_fa(0, n, y), facing, span, sp, ORDER_RING.x, ORDER_RING.y, order, ORDER_ARC)
		if k == 0:
			apex = a
	# the keystone: a lozenge of stone with the raised sword, no glow
	var ks := _fa(0, ORDER_RING.y + 0.05, KEYSTONE.x)
	var lz := m.box(ks, Vector3(KEYSTONE.y, KEYSTONE.y, 0.2), yaw, order, false)
	lz.basis = Basis(Vector3.UP, yaw) * Basis(Vector3.BACK, PI * 0.25)
	var basis := Basis(Vector3.UP, yaw)
	_sword(ks + basis * Vector3(0, 0, 0.12), basis, Vector3(0, 1, 0), Vector3(1, 0, 0), KEYSTONE.y * 0.95, order, 0.03)
	# the leaves
	var door := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = DOOR
	door.mesh = q
	_door_mat = ShaderMaterial.new()
	_door_mat.shader = preload("res://assets/shaders/chamber_door.gdshader")
	_door_mat.set_shader_parameter(&"size", DOOR)
	_door_mat.set_shader_parameter(&"arch", Vector2(spring, arc))
	_door_mat.set_shader_parameter(&"seam_light", SEAM_REST)
	door.material_override = _door_mat
	door.transform = Transform3D(basis, _fa(0, 0.02, y + DOOR.y * 0.5))
	door.layers = 1 | ArenaKit.FACADE_LAYER
	add_child(door)
	# the dark behind it (around the arch's point, where the leaves stop)
	m.box(_fa(0, -0.15, y + DOOR.y * 0.5), Vector3(DOOR.x + 0.2, DOOR.y + 0.2, 0.2), yaw, m.stone(y, Color.WHITE * 0.2), false)
	_porch_light = OmniLight3D.new()
	_porch_light.position = _fa(0, 1.2, y + 1.6)
	_porch_light.light_color = LANTERN_LIGHT
	_porch_light.light_energy = PORCH_LIGHT.x
	_porch_light.omni_range = PORCH_LIGHT.z
	_porch_light.light_cull_mask = ArenaKit.WARM_MASK
	add_child(_porch_light)
	var _unused := apex


## A polygon of facade points (a, n) on the floor.
func _fa_poly(pts: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p: Vector2 in pts:
		out.append(_fa2(p.x, p.y))
	return out


func _fa2(a: float, n: float) -> Vector2:
	return FACADE_ORIGIN + FACADE_A * a + FACADE_N * n


## How far out of the facade (n) its line at `a` meets the circle of radius r.
func _cross(a: float, r: float) -> float:
	var p := FACADE_ORIGIN + FACADE_A * a
	var b := p.dot(FACADE_N)
	var c := p.length_squared() - r * r
	return -b - sqrt(maxf(b * b - c, 0.0))


static func _bearing_of(p: Vector2) -> float:
	return fposmod(rad_to_deg(atan2(p.x, -p.y)), 360.0)


# ---------- the stairs in from the south ----------

func _entry() -> void:
	var stone := m.stone(-1.2)
	var up := Vector2(0, -1)
	var w := ENTRY_HALF * 2.0
	# flight 1 from the mouth down to the landing, the landing, flight 2 down into the mist
	var f1_foot := ENTRY_MOUTH + FLIGHT_1.x * FLIGHT_1.z
	m.stairs(Vector3(0, -FLIGHT_1.x * FLIGHT_1.y - FLIGHT_1.y, f1_foot), up, w, int(FLIGHT_1.x), FLIGHT_1.y, FLIGHT_1.z)
	var land_y := -FLIGHT_1.x * FLIGHT_1.y
	m.block(Vector3(0, land_y - 0.6, (LANDING.x + LANDING.y) * 0.5), Vector3(w, 0.6, LANDING.y - LANDING.x), 0.0, stone, false)
	var f2_top := land_y
	var f2_foot := LANDING.y + FLIGHT_2.x * FLIGHT_2.z
	m.stairs(Vector3(0, f2_top - FLIGHT_2.x * FLIGHT_2.y - FLIGHT_2.y, f2_foot), up, w, int(FLIGHT_2.x), FLIGHT_2.y, FLIGHT_2.z)
	# the walls beside it, their coping falling with the flights; posts on the landing
	var wall_mid := (ENTRY_WALL.x + ENTRY_WALL.y) * 0.5
	var wall_w := ENTRY_WALL.y - ENTRY_WALL.x
	for sd: float in [-1.0, 1.0]:
		var x := sd * wall_mid
		_sloped_wall(Vector3(x, 0.6, ENTRY_MOUTH), Vector3(x, land_y + 0.6, LANDING.x), wall_w, stone)
		m.box(Vector3(x, land_y + 0.3 - 3.0, (LANDING.x + LANDING.y) * 0.5), Vector3(wall_w, 6.6, LANDING.y - LANDING.x), 0.0, stone, false)
		_sloped_wall(Vector3(x, land_y + 0.6, LANDING.y), Vector3(x, land_y - FLIGHT_2.x * FLIGHT_2.y + 0.6, f2_foot), wall_w, stone)
		m.post(Vector3(x, land_y, (LANDING.x + LANDING.y) * 0.5), 0.0, Masonry.POST.y, stone)
	# the viaduct under it: a body down into the mist with pointed arches along both sides
	m.layers = ArenaKit.DEPTH_LAYER
	var deep := _deep(0.3, 0.85)
	var dark := _deep(0.2, 0.25)
	var span := 2.4
	var z := LANDING.x - 1.2
	var bottom := -DEPTH
	while z < f2_foot + 1.0:
		var top_y := _entry_under(z) - 0.7
		for sd: float in [-1.0, 1.0]:
			var face := Vector2(sd, 0)
			m.arch_ring(Vector3(sd * (wall_mid - 0.1), top_y - 2.4, z + span * 0.5 + 0.5), face, span, 0.4, 0.6, deep, 0.75)
			m.box(Vector3(sd * (wall_mid - 0.1), (top_y - 2.4 - 5.0 + bottom) * 0.5, z + span * 0.5 + 0.5), Vector3(0.6, -bottom + top_y - 7.4, span), 0.0, deep, false)
		m.box(Vector3(0, (top_y + bottom) * 0.5, z), Vector3(w + 1.0, top_y - bottom, 1.0), 0.0, deep, false)
		m.box(Vector3(0, (top_y + bottom) * 0.5, z + span * 0.5 + 0.5), Vector3(w - 0.4, top_y - bottom, span), 0.0, dark, false)
		z += span + 1.0
	m.layers = 1
	# the veil across the mouth, on the sill
	var veil := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = VEIL
	veil.mesh = q
	_veil_mat = ShaderMaterial.new()
	_veil_mat.shader = preload("res://assets/shaders/chamber_veil.gdshader")
	_veil_mat.set_shader_parameter(&"size", VEIL)
	_veil_mat.set_shader_parameter(&"power", 0.0)
	veil.material_override = _veil_mat
	veil.position = Vector3(0, VEIL.y * 0.5, ENTRY_MOUTH)
	veil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(veil)


## The height of the stairs' underside at z (under the steps, along both flights).
func _entry_under(z: float) -> float:
	var land_y := -FLIGHT_1.x * FLIGHT_1.y
	if z < LANDING.x:
		return -(z - ENTRY_MOUTH) / FLIGHT_1.z * FLIGHT_1.y - 0.6
	if z < LANDING.y:
		return land_y - 0.6
	return land_y - (z - LANDING.y) / FLIGHT_2.z * FLIGHT_2.y - 0.6


## A wall beside a flight: its coping running from `a` to `b` (their tops), solid under it.
func _sloped_wall(a: Vector3, b: Vector3, width: float, mat: Material) -> void:
	var len := Vector2(b.x - a.x, b.z - a.z).length()
	var yaw := atan2(b.x - a.x, b.z - a.z)
	var slope := atan2(a.y - b.y, len)
	var cop := m.box((a + b) * 0.5, Vector3(width + 0.1, 0.18, sqrt(len * len + (a.y - b.y) * (a.y - b.y)) + 0.1), yaw, mat, false)
	cop.basis = Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, slope)
	var k := maxi(2, ceili(len / 1.0))
	for i in k:
		var t := (i + 0.5) / k
		var p := a.lerp(b, t)
		var h := p.y - 0.1 + 1.5
		m.box(Vector3(p.x, p.y - 0.1 - h * 0.5, p.z), Vector3(width, h, len / k + 0.02), yaw, mat, false)


## The unlit stone of the depths (Masonry.depth_stone) in the chamber's violet grey instead of the hall's teal (these
## materials belong to this chamber's Masonry, so the hall's are untouched).
func _deep(fade: float, tint := 1.0) -> ShaderMaterial:
	var d := m.depth_stone(FOG, fade, tint)
	d.set_shader_parameter(&"stone_color", DEEP_STONE)
	d.set_shader_parameter(&"edge_color", DEEP_EDGE)
	d.set_shader_parameter(&"glow_color", ABYSS_COLOR)
	d.set_shader_parameter(&"glow_energy", 0.25)  # the shader's own, written so the classic look can go back to it
	VisualProfile.vary(d, {&"shader_parameter/glow_energy": STY_DEEP_GLOW})
	return d


# ---------- the depths and the far ----------

func _far() -> void:
	kit.abyss(Vector2(LIP_RADIUS, LIP_RADIUS), DEPTH, false, MIST)
	# the tower to the west-north-west, its lit window on the side to the camera
	m.layers = ArenaKit.DEPTH_LAYER
	var tp := at_bearing(TOWER.x, TOWER.y)
	var tower := _deep(0.5, 1.6)
	var tyaw := deg_to_rad(Feel.live().cam_yaw)
	m.box(Vector3(tp.x, (TOWER.w - 20.0) * 0.5 - 0.0, tp.y), Vector3(TOWER.z, TOWER.w + 20.0, TOWER.z), tyaw, tower, false)
	for h: float in [-2.0, 8.0, 16.0, 24.0]:
		m.box(Vector3(tp.x, h, tp.y), Vector3(TOWER.z + 0.4, 0.4, TOWER.z + 0.4), tyaw, tower, false)
	m.layers = 1
	var wpos := Vector3(tp.x, TOWER_WINDOW.x, tp.y) + Basis(Vector3.UP, tyaw) * Vector3(0, 0, TOWER.z * 0.5 + 0.03)
	var win := MeshInstance3D.new()
	var wq := QuadMesh.new()
	wq.size = Vector2(TOWER_WINDOW.y, TOWER_WINDOW.z)
	win.mesh = wq
	win.material_override = _far_window(true)
	win.transform = Transform3D(Basis(Vector3.UP, tyaw), wpos + Vector3(0, TOWER_WINDOW.z * 0.5, 0))
	add_child(win)
	m.layers = ArenaKit.DEPTH_LAYER
	m.pointed_arch(wpos - Vector3(0, 0, 0), Vector2(sin(tyaw), cos(tyaw)), TOWER_WINDOW.y, TOWER_WINDOW.z, 0.14, 0.2, tower)
	# the far ring of arcades, only on the far side
	var far := _deep(0.8)
	var b := FAR_SPAN.x
	var i := 0
	var bay := 2.0 * FAR_RING.x * sin(deg_to_rad(FAR_STEP * 0.5))
	while b < FAR_SPAN.y:
		var at := at_bearing(b, FAR_RING.x)
		var yaw := _facing_in(b)
		var edge := at_bearing(b + FAR_STEP * 0.5, FAR_RING.x)
		m.box(_v3(edge, (FAR_RING.y + FAR_RING.z) * 0.5), Vector3(bay - 4.0, FAR_RING.y - FAR_RING.z, 2.0), yaw + deg_to_rad(FAR_STEP * 0.5), far, false)
		m.box(_v3(at, FAR_RING.y - 0.8), Vector3(bay + 0.2, 1.6, 2.2), yaw, far, false)
		m.arch_ring(_v3(at, FAR_RING.y - 4.5), at_bearing(b, 1.0), 4.0, 0.7, 1.8, far, 0.75)
		m.box(_v3(at_bearing(b, FAR_RING.x + 3.0), (FAR_RING.y + FAR_RING.z) * 0.5 - 2.0), Vector3(bay, FAR_RING.y - FAR_RING.z, 1.0), yaw, _deep(0.9, 0.3), false)
		var wb := b + FAR_STEP * 0.5
		if i % WINDOW_EVERY == WINDOW_EVERY - 1 and (wb < FAR_WINDOW_HIDDEN.x or wb > FAR_WINDOW_HIDDEN.y):
			var wyaw := yaw + deg_to_rad(FAR_STEP * 0.5)
			var wbasis := Basis(Vector3.UP, wyaw)
			var wp := _v3(at_bearing(wb, FAR_RING.x - 1.05), FAR_RING.y - 3.0)
			var lq := QuadMesh.new()
			lq.size = FAR_WINDOW
			var glass := _far_window(i % FAR_WINDOW_DARK_EVERY == 0)
			for sd: float in [-0.5, 0.5]:
				var lw := MeshInstance3D.new()
				lw.mesh = lq
				lw.material_override = glass
				lw.transform = Transform3D(wbasis, wp + wbasis * Vector3(sd * FAR_WINDOW_PAIR, 0, 0))
				add_child(lw)
		b += FAR_STEP
		i += 1
	m.layers = 1
	# the spires in the blue mist, two cards across the view
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	var eye := Vector3(CAM_TARGET.x, 0, CAM_TARGET.y) + Feel.cam_offset_of(Feel.live().cam_distance, Feel.live().cam_pitch, Feel.live().cam_yaw)
	var ahead := Vector3(-sin(yaw), 0, -cos(yaw))
	for k in SPIRE_DIST.size():
		var d: float = SPIRE_DIST[k]
		var c := Vector3(eye.x, SPIRE_TOP - SPIRE_SIZE.y * 0.5, eye.z) + ahead * d
		kit.ruin_card(c, SPIRE_SIZE, yaw, SPIRE_MIST, SPIRE_HAZE[k], SPIRE_COLUMN[k], 11.0 + k * 13.0, SPIRE_TOPS[k], SPIRE_SINK[k],
			Vector4.ZERO, SPIRE_PATCHES if k == SPIRE_DIST.size() - 1 else NO_PATCHES)
		var card := get_child(get_child_count() - 1) as MeshInstance3D
		var cm := card.material_override as ShaderMaterial
		cm.set_shader_parameter(&"stone_color", SPIRE_STONE)
		cm.set_shader_parameter(&"edge_color", SPIRE_EDGE)
		_spire_mats.append(cm)
	# the chains
	for ch in CHAINS:
		kit.chain(ch[0], ch[1], ch[2], CHAIN_SIZE)
	# violet glowing up from the abyss at the sides and violet fog low in it
	for g in GLOWS:
		var p := at_bearing(g[0], g[1])
		kit.abyss_glow(Vector3(p.x, g[2], p.y), Vector2(g[3], g[4]), yaw, ArenaKit.ABYSS_GLOW_ENERGY * GLOW_DIM * float(g[5]))
	for g in COLUMNS:
		var p := at_bearing(g[0], g[1])
		kit.abyss_glow(Vector3(p.x, g[2], p.y), Vector2(g[3], g[4]), yaw, ArenaKit.ABYSS_GLOW_ENERGY * GLOW_DIM * float(g[5]), COLUMN_SHAPE)
	for f in FOG_BOXES:
		var p := at_bearing(f.x, f.y)
		var fm := kit.abyss_fog(Vector3(p.x, -12.0, p.y), Vector3(f.z, 10.0, f.w))
		if fm != null:
			VisualProfile.vary(fm, {&"albedo": STY_FOG_ALBEDO, &"emission": STY_FOG_EMISSION, &"density": STY_FOG_DENSITY})
	for gm: ShaderMaterial in kit._glow_mats.values():
		VisualProfile.vary(gm, {&"shader_parameter/color": STY_GLOW})


# ---------- the stylized look (room redesign lot E) ----------

## The background and the air of the stylized look (spec 3, E1 to E4): the pieces on the kit's stylized Masonry,
## hidden in the classic look; the spires' edges through VisualProfile; the sky in dress. Its own random numbers
## (STY_SEED), never the room's.
func _stylize() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = STY_SEED
	var sm := kit.styled()
	sm.layers = ArenaKit.DEPTH_LAYER
	for i in STY_ARCHES.size():
		_broken_arch(sm, i)
	_shards(sm, rng)
	sm.layers = 1
	for ch: Array in STY_CHAINS:
		kit.styled_build(func() -> void: kit.chain(ch[0], ch[1], ch[2], CHAIN_SIZE))
	for c in STY_CAGES.size():
		_cage(sm, c)
	var edge := Color(SPIRE_EDGE.r * STY_SPIRE_EDGE, SPIRE_EDGE.g * STY_SPIRE_EDGE, SPIRE_EDGE.b * STY_SPIRE_EDGE)
	for cm in _spire_mats:
		VisualProfile.vary(cm, {&"shader_parameter/edge_color": edge})
	VisualProfile.vary(_deep(0.8), {&"shader_parameter/tint": STY_FAR_TINT, &"shader_parameter/mist_color": STY_FAR_MIST})
	sm.merge()


## E1: a broken arch at mid height in the far ring's bay at STY_ARCHES[i], in the ring's own stone; one stone of the
## listed ones hangs from a short chain under its gap.
func _broken_arch(sm: Masonry, i: int) -> void:
	var b := STY_ARCHES[i]
	var at := at_bearing(b, FAR_RING.x)
	var facing := at_bearing(b, 1.0)
	var spring := 2.0
	var foot := _v3(at, STY_ARCH.x - spring)
	var gap := STY_ARCH_GAPS[i]
	var mat := _arch_stone()
	sm.broken_arch(foot, facing, STY_ARCH.y, spring, STY_ARCH.z, STY_ARCH.w, mat, gap)
	if not STY_ARCH_HANGS.has(i):
		return
	var right := Basis(Vector3.UP, atan2(facing.x, facing.y)) * Vector3.RIGHT
	var top := foot + right * (gap.x + gap.y) * 0.5 + Vector3.UP * (spring + STY_ARCH.y * 0.75)
	var stone := top + Vector3.DOWN * STY_HANG.x
	var mi := sm.box(stone, Vector3(STY_ARCH.z, STY_ARCH.z * 1.3, STY_ARCH.w * 0.8), 0.0, mat, false)
	mi.basis = Basis(Vector3.UP, atan2(facing.x, facing.y)) * Basis(Vector3.BACK, STY_HANG.y)
	kit.styled_build(func() -> void: kit.chain(top, stone + Vector3.UP * STY_ARCH.z * 0.6, 0.05, CHAIN_SIZE * 0.3))


## SW-K1: the cage STY_CAGES[c] on its short chain under its hook on the big chain, both under a pivot at the hook
## that _process swings; dark iron (ArenaKit.STY_IRON) with the chains' rim, no light, no shadow.
func _cage(sm: Masonry, c: int) -> void:
	var spec: Array = STY_CAGES[c]
	var hook := cage_hook(c)
	var drop := float(spec[2])
	var pivot := Node3D.new()
	pivot.name = "Cage%d" % c
	sm.root.add_child(pivot)
	pivot.position = hook
	var links := kit.styled_build(func() -> void: kit.chain(hook, hook + Vector3.DOWN * drop, 0.0, STY_CAGE_LINKS), hook)
	links.get_parent().remove_child(links)
	pivot.add_child(links)
	links.transform = Transform3D()
	var mi := MeshInstance3D.new()
	mi.mesh = Masonry.cage_mesh(STY_CAGE, STY_CAGE_BARS, float(spec[4]), int(spec[5]))
	mi.material_override = _cage_iron()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.layers = sm.layers
	mi.transform = Transform3D(Basis(Vector3.UP, deg_to_rad(float(spec[3]))), Vector3.DOWN * drop)
	pivot.add_child(mi)
	if c == STY_CAGE_BONE_IN:
		_cage_bone(mi)
	_cages.append(pivot)


## K-1: the bone on the cage's floor (STY_CAGE_BONE): a shaft and a knob at each end, one mesh, matte, no shadow.
func _cage_bone(cage: MeshInstance3D) -> void:
	var b := STY_CAGE_BONE
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var knob := b.x * b.z
	for part: Array in [[Vector3.ZERO, Vector3(b.x, b.y, b.y)], [Vector3(b.x * 0.5, 0, 0), Vector3(knob, b.y * 1.8, b.y * 2.2)],
			[Vector3(-b.x * 0.5, 0, 0), Vector3(knob, b.y * 1.8, b.y * 2.2)]]:
		var box := BoxMesh.new()
		box.size = part[1]
		st.append_from(box, 0, Transform3D(Basis.IDENTITY, part[0]))
	var bone := MeshInstance3D.new()
	bone.mesh = st.commit()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = STY_CAGE_BONE_COLOR
	mat.roughness = 0.9
	bone.material_override = mat
	bone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bone.layers = cage.layers
	var floor_y := -STY_CAGE.z - STY_CAGE.y + b.y * 1.2
	bone.transform = Transform3D(Basis(Vector3.UP, deg_to_rad(b.w)) * Basis(Vector3.BACK, 0.12), Vector3(0.1, floor_y, -0.05))
	cage.add_child(bone)


## Where the cage STY_CAGES[c] hangs from its chain (ArenaKit.chain's curve).
static func cage_hook(c: int) -> Vector3:
	var spec: Array = STY_CAGES[c]
	var i := int(spec[0])
	var ch: Array = CHAINS[i] if i < CHAINS.size() else STY_CHAINS[i - CHAINS.size()]
	var t := float(spec[1])
	return (ch[0] as Vector3).lerp(ch[1], t) + Vector3.DOWN * float(ch[2]) * 4.0 * t * (1.0 - t)


func _cage_iron() -> StandardMaterial3D:
	if _sty_iron == null:
		_sty_iron = StandardMaterial3D.new()
		_sty_iron.albedo_color = ArenaKit.STY_IRON
		_sty_iron.roughness = ArenaKit.STY_METAL.x
		_sty_iron.metallic = ArenaKit.STY_METAL.y
		_sty_iron.rim_enabled = true
		_sty_iron.rim = ArenaKit.CHAIN_RIM
		_sty_iron.rim_tint = 0.2
		_sty_iron.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _sty_iron


var _sty_iron: StandardMaterial3D


## The cages swinging slowly round their hooks (only while they are seen: the stylized look).
func _swing_cages(delta: float) -> void:
	if _cages.is_empty() or not _cages[0].is_visible_in_tree():
		return
	_cage_clock += delta
	var amp := deg_to_rad(STY_CAGE_SWING.x)
	for k in _cages.size():
		var w := TAU / (STY_CAGE_SWING.y * (1.0 + 0.13 * k))
		var ph := k * 1.7
		_cages[k].rotation = Vector3(sin(_cage_clock * w + ph) * amp, 0.0, sin(_cage_clock * w * 0.71 + ph * 2.0) * amp * 0.6)


## The broken arches' stone (STY_ARCH_STONE, STY_ARCH_SINK): the far ring's, its own material (only the stylized
## look uses it), sinking lower.
func _arch_stone() -> ShaderMaterial:
	if _sty_arch == null:
		_sty_arch = (_deep(STY_ARCH_STONE.x)).duplicate() as ShaderMaterial
		_sty_arch.set_shader_parameter(&"tint", STY_ARCH_STONE.y)
		_sty_arch.set_shader_parameter(&"mist_color", STY_FAR_MIST)
		_sty_arch.set_shader_parameter(&"sink_top", STY_ARCH_SINK.x)
		_sty_arch.set_shader_parameter(&"sink_bottom", STY_ARCH_SINK.y)
		# a copy keeps the glow of the look it was made in: its own classic and stylized glow, as _deep's
		_sty_arch.set_shader_parameter(&"glow_energy", 0.25)
		VisualProfile.vary(_sty_arch, {&"shader_parameter/glow_energy": STY_DEEP_GLOW})
	return _sty_arch


## E3: stone blocks hanging still in the abyss at the frame's sides, turned every way, in the tower's unlit stone.
func _shards(sm: Masonry, rng: RandomNumberGenerator) -> void:
	var tower := at_bearing(TOWER.x, TOWER.y)
	var mat := _deep(0.5, 1.6)
	var made := 0
	var tries := 0
	while made < STY_SHARDS and tries < STY_SHARDS * 20:
		tries += 1
		var span := STY_SHARD_SPANS[made % STY_SHARD_SPANS.size()]
		var p := at_bearing(rng.randf_range(span.x, span.y), rng.randf_range(span.z, span.w))
		if p.distance_to(tower) < STY_SHARD_TOWER:
			continue
		var size := Vector3(rng.randf_range(STY_SHARD_SIZE.x, STY_SHARD_SIZE.y), rng.randf_range(STY_SHARD_SIZE.x, STY_SHARD_SIZE.y),
			rng.randf_range(STY_SHARD_SIZE.x, STY_SHARD_SIZE.y))
		var mi := sm.box(_v3(p, rng.randf_range(STY_SHARD_HEIGHT.x, STY_SHARD_HEIGHT.y)), size, 0.0, mat, false)
		mi.basis = Basis.from_euler(Vector3(rng.randf() * TAU, rng.randf() * TAU, rng.randf() * TAU))
		made += 1


# ---------- light ----------

func _light() -> void:
	var key := OmniLight3D.new()
	key.position = KEY_AT
	key.light_color = KEY_COLOR
	key.light_energy = KEY_ENERGY
	key.omni_range = KEY_RANGE
	key.omni_attenuation = 1.0
	key.light_cull_mask = ArenaKit.WARM_MASK
	add_child(key)
	for b in ABYSS_BEARINGS:
		var p := at_bearing(b, ABYSS_LIGHT.x)
		var l := OmniLight3D.new()
		l.position = Vector3(p.x, ABYSS_LIGHT.y, p.y)
		l.light_color = ABYSS_COLOR
		l.light_energy = ABYSS_LIGHT.z
		l.omni_range = ABYSS_LIGHT.w
		l.omni_attenuation = 1.1
		l.light_cull_mask = ArenaKit.DEPTH_LAYER
		add_child(l)
	var bp := at_bearing(BLUE_AT.x, BLUE_AT.y)
	var blue := OmniLight3D.new()
	blue.position = Vector3(bp.x, BLUE_AT.z, bp.y)
	blue.light_color = BLUE_COLOR
	blue.light_energy = BLUE_ENERGY
	blue.omni_range = BLUE_RANGE
	blue.light_cull_mask = ArenaKit.DEPTH_LAYER
	add_child(blue)


## What the chamber's air changes, as it is now (tests compare the hall's air before and after).
static func air_of(e: Environment, moon: DirectionalLight3D = null) -> Dictionary:
	var d := {
		&"background_mode": e.background_mode, &"background_color": e.background_color,
		&"ambient_light_source": e.ambient_light_source, &"ambient_light_color": e.ambient_light_color,
		&"ambient_light_energy": e.ambient_light_energy, &"fog_enabled": e.fog_enabled, &"fog_mode": e.fog_mode,
		&"fog_light_color": e.fog_light_color, &"fog_depth_begin": e.fog_depth_begin, &"fog_depth_end": e.fog_depth_end,
	}
	if moon != null:
		d[&"moon"] = [moon.rotation_degrees, moon.light_color, moon.light_energy, moon.shadow_enabled]
	return d


## The chamber's air as values of the air (RoomMood.read's keys) for a look: a deep blue night, a little cold
## ambient, distance fog from past the platform, height fog filling the abyss, the moon from its own side.
static func air_values(stylized: bool) -> Dictionary:
	return {
		&"background_mode": Environment.BG_COLOR,
		# lot E 3 (E4): in the stylized look the sky a step deeper, so the lighter spires' edges stand off it
		&"background_color": Color(SKY.r * STY_SKY, SKY.g * STY_SKY, SKY.b * STY_SKY) if stylized else SKY,
		&"ambient_light_source": Environment.AMBIENT_SOURCE_COLOR, &"ambient_light_color": AMBIENT,
		&"ambient_light_energy": AMBIENT_ENERGY, &"fog_enabled": true, &"fog_mode": Environment.FOG_MODE_DEPTH,
		&"fog_light_color": FOG, &"fog_depth_begin": FOG_DEPTH.x, &"fog_depth_end": FOG_DEPTH.y,
		&"moon/rotation_degrees": MOON_ROTATION, &"moon/light_color": MOON_COLOR, &"moon/light_energy": MOON_ENERGY,
		&"moon/shadow_enabled": true,
	}


## The chamber's air written straight on an env and moon, for the look in use (the chamber lab, which has no world
## air of its own; in the game the owner of the air does it, _dress_world).
static func dress(e: Environment, moon: DirectionalLight3D = null) -> void:
	RoomMood.write(e, moon, air_values(VisualProfile.stylized()))
