class_name CatacombHall
extends RefCounted
## The catacomb hall of Daniel's reference image ("Arena das Catacumbas", 2026-11-14; analysis in
## docs/art/arena_reference.md), rebuilt piece by piece where the picture has them. The positions come from the
## picture itself: its landmarks were cast onto the floor through the game's camera (fov 24, turned 35, 30 above the
## floor), so seen through that camera each piece lands where the painting has it. Seen from the south-east, the room
## is the diamond of the picture:
## - north: a raised dais with a wide flight of steps, the green portal in a gothic facade on the right half of the
##   steps, hooded statues beside it, red banners on its buttresses, pots and crates at the foot of the steps;
## - north-west corner: a pier out in the abyss with a fire bowl and a hooded statue behind it;
## - west: a long balustrade with candles and clay pots, and out in the abyss a giant hooded statue on its tower with
##   a fire bowl at its feet; an arcade and chains in the depths behind;
## - south: a standing stone in the middle of the south edge; west of it a landing, the way in (steps down);
## - east: a standing stone with a fire bowl, and a flight of stairs going down out of the hall (a way on), a fire
##   bowl on a pier north of it;
## - the engraved medallion, a little west of the middle.
## Meters, x east, z south, from the middle of the room. Doors: 0 the portal, 1 the east stairs, 2 the south stairs; the first two stand together in the north-east
## corner (PT-6b: the choice needs no walking from one door to the other).

## Half the room (the fight happens inside it, less the Arena margin).
const HALF := Vector2(16.0, 15.0)
const MEDALLION_AT := Vector2(-2.5, 1.0)
const MEDALLION := 7.5
## The dais: its height; the flight of steps up to it (x range on the north edge), its steps and their run.
const DAIS_Y := 1.0
const DAIS_STEPS := 4
const STEP_RUN := 0.6
## The facade: its x range, its front (z), its height; the portal's middle (x) and opening.
const FACADE_X := Vector2(-6.5, 20.0)
const FACADE_Z := -20.0
const FACADE_HEIGHT := 10.5
const PORTAL_X := 10.5
## The flight of steps up to the portal: x range on the north edge (centred on the portal).
const FLIGHT := Vector2(PORTAL_X - 6.6, PORTAL_X + 2.8)
const PORTAL_SIZE := Vector2(3.4, 4.4)
## How deep in the doorway the sheet of light hangs, behind the facade's front.
const PORTAL_DEPTH := 2.2
## The landing west of the south standing stone (the way in): its x range and how far south it reaches; the gap of
## its steps down (x range).
const LANDING := Vector2(-16.0, -3.6)
const LANDING_END := 20.5
const WAY_IN := Vector2(-13.6, -9.6)
const SOUTH_STONE := Vector2(-2.6, 15.3)
## The east standing stone, and the stairs down north of it (door 1: z range of the gap).
const EAST_STONE := Vector2(16.3, 2.1)
const EAST_GAP := Vector2(-13.6, -10.0)
## The south stairs down (door 2, only with three doors): x range of the gap.
const SOUTH_GAP := Vector2(6.4, 10.8)
## The north-west pier (fire bowl, statue) and the giant's pier and tower out to the west.
const NW_PIER := Vector2(-12.4, -18.3)
## The statue on the north-west pier: its height and its stone's value.
const NW_STATUE := Vector2(3.8, 1.0)
## The weak warm light of its bowl on it (the bowl's own light leaves it out: it turned the statue ochre): energy,
## range, cone.
const NW_GLOW := Vector3(0.8, 5.0, 40.0)
const GIANT_BOWL := Vector2(-23.0, -4.4)
const GIANT := Vector3(-26.0, -4.4, 8.3)
## Height of the giant's feet (its tower and plinth end just under it): the hood's top lands near the picture's top.
const GIANT_FOOT := -0.4
## The fire bowl's light on the giant (cycle 6: the giant is out of the bowl's own light, so it stays dark neutral
## stone and only the side turned to the fire is warm; cycle 7: weaker, the giant's mean colour stays cold): energy,
## range, cone, and the share of the giant's height it aims at.
const GIANT_UPLIGHT := 1.5
const GIANT_UPLIGHT_RANGE := 8.0
const GIANT_UPLIGHT_CONE := 30.0
const GIANT_UPLIGHT_AIM := 0.45
const GIANT_VALUE := 1.0
## A cold light on the two statues out in the abyss alone (cycle 7; the colour of the facade's, so all the statues
## are the same cold stone and the giant has a lit side): its energy, where it shines from, its cone and range. It
## aims between the two.
const STATUE_FILL_ENERGY := 2.4
const STATUE_FILL_FROM := Vector3(-8.0, 18.0, 6.0)
const STATUE_FILL_CONE := 32.0
const STATUE_FILL_RANGE := 48.0
## The pile of rough blocks the giant and its bowl stand on, out of the abyss (dark, out of the fires' light): the
## stone's tint; the courses from the top down (each: height of its top, then its blocks as x middle, x width, z depth).
const PILE_TINT := 0.55
const PILE_FOOT := -6.2
const PILE_COURSES: Array[Array] = [
	[-1.25, [Vector3(-26.2, 4.3, 4.5), Vector3(-22.9, 2.3, 3.4)]],
	[-2.9, [Vector3(-27.0, 2.9, 4.8), Vector3(-24.4, 2.2, 4.3), Vector3(-22.4, 1.9, 3.9)]],
	[-4.5, [Vector3(-26.6, 3.4, 5.0), Vector3(-23.3, 3.3, 4.5)]],
]
const DEPTH := 26.0
## Where the fixed showcase camera looks: the floor point at the middle of the reference image.
const SHOWCASE := Vector3(-2.0, 0, 0)
## Candles: their height and radius ranges (m), the warm halo over a cluster, one warm light per cluster. VX-13 (visual
## review V-C1): warm is an accent, not the whole edge: half the clusters of the edge are burnt out, the east and south
## ones (by the east stone, the north-east corner, the south stone, the landing) and one of the west balustrade; the
## dais's, the west balustrade's other four, the north corner's and the fire bowls stay. C18 (ART P1-2, one tone for
## the scenery): half of those left are burnt out too, the west balustrade's northmost and southmost and the west
## nook's; the dais's, the landing foot's, two of the west balustrade's and the fire bowls stay lit.
const CANDLE_HEIGHT := Vector2(0.3, 1.1)
const CANDLE_RADIUS := Vector2(0.12, 0.22)
## A cluster has 3 to CANDLE_MAX candles (one tall and thick, one or two of middle height, the rest stubs); those
## standing on something (a plinth, a crate) are this share of the size and may be fewer.
const CANDLE_MAX := 5
## C-3: the three drawings of a candle group, x how far the stubs spread, y their height, z at most how many (0: all).
const CANDLE_VARIANTS: Array[Vector3] = [Vector3(1.0, 1.0, 0.0), Vector3(2.2, 0.6, 0.0), Vector3(0.6, 1.5, 3.0)]
const CANDLE_ON_TOP := 0.6
## ENV-HB7 (benchmark_hades2_style.md 4.1): in the stylized look every candle is this share of its height and radius
## (the tallest 0.5 m, under a fifth of the hero's drawn 2.75 m; the clusters read near half of him), its halo and
## light lowered with it. The classic candles (on their own Masonry, classic only) and the stylized twins (on
## kit.styled()) take the same random sizes.
const STY_CANDLE_HEIGHT := 0.45
const STY_CANDLE_RADIUS := 0.85
## The stone stand-in of a fight-field crate (_field_crate): the block left on it, a share of its size.
const FIELD_CRATE_CHIP := Vector3(0.45, 0.3, 0.4)
const CANDLE_HALO := 0.5
## A heap of fallen stones (_rubble): how many blocks, their width range and height range (m, under the knee), how far
## from the heap's middle.
const RUBBLE := 4
## The candles by the east stone: the circle that blocks round them (m).
const EAST_CLUTTER := 0.7
const RUBBLE_SIZE := Vector2(0.3, 0.6)
const RUBBLE_HEIGHT := Vector2(0.14, 0.26)
const RUBBLE_SPREAD := 0.55
const CANDLE_HALO_ALPHA := 0.35
const CANDLE_LIGHT := 1.5
const CANDLE_RANGE := 2.8
const ABYSS_LIGHT := Color(0.66, 0.52, 1.0)
const ABYSS_LIGHT_ENERGY := 5.0
## The abyss in the stylized look (lot A spec 3.2): the slate's blue, not violet (a colour kept for Morvath), on the
## lights from below and on the glow cards (STYLE.abyss_glow).
const STY_ABYSS_LIGHT := Color(0.5, 0.66, 0.9)
const STY_ABYSS_GLOW := Color(0.5, 0.6, 0.76)
## The violet lights stand this low, so only the foot of the cliffs and piers turns violet.
const ABYSS_LIGHT_Y := -12.0
## Width of the two standing stones (thick and blunt, as in the picture).
const OBELISK_SOUTH := 2.2
## GR-24: the entrance stele 45% lower (it stood behind the HUD's buttons, a tenth of the frame; the collision circle is the same).
const OBELISK_SOUTH_HEIGHT := 2.6
const OBELISK_EAST := 2.3
## The floor in front of the portal's steps, always wet (x, z rect).
const WET := Rect2(-1.0, -15.0, 13.0, 6.0)
## The portal (cycle 4, a deep gothic doorway): the lintel over the opening (height); the hooded statues beside it;
## its orders, each a pointed arch of voussoirs (ring width, depth), each this much wider on each side and farther
## forward than the one inside (the inmost's front this far behind the facade's front), their stone darker than the
## wall's (the picture parts them by the shadow between them); the radius of their arcs (share of the span).
const PORTAL_LINTEL := 0.6
const PORTAL_STATUE := 5.0
const PORTAL_STATUE_VALUE := 1.25
const PORTAL_ORDERS := 4
const PORTAL_ORDER_RING := Vector2(0.45, 0.7)
const PORTAL_ORDER_STEP := Vector2(0.35, 0.6)
const PORTAL_INNER_Z := -1.6
## The whole doorway stands this far out of the wall, a porch (the picture's opening sits at the facade's face).
const PORTAL_PORCH := 1.6
const PORTAL_ORDER_TINT := Color(1.15, 1.15, 1.15)
const PORTAL_ARC := 0.8
## Slender shafts in the steps between the orders (radius, which orders have them), with a base and a capital.
const COLONNETTE := 0.13
const COLONNETTE_ORDERS: Array[int] = [1, 3]
## The dark teeth hanging from the lintel against the light (share of the opening's width across, length, root width),
## their stone's darkness.
const PENDANTS: Array[Vector3] = [Vector3(-0.3, 0.7, 0.5), Vector3(0.03, 1.5, 0.7), Vector3(0.24, 0.9, 0.5),
	Vector3(0.41, 0.4, 0.35)]
## The opening is a pointed arch (cycle 6; the picture's, not a square doorway): the springing's height as a share of
## the opening's, the ring of stone under the lintel that draws it (width, depth) and its stone's darkness.
const PORTAL_SPRING := 0.5
const PORTAL_INNER_RING := Vector2(0.32, 0.5)
const PORTAL_INNER_TINT := 0.6
const PENDANT_TINT := 0.4
## The tympanum over the lintel, set back behind the inmost order; the lit diamond window in it: its size (m, width and
## height), its frame and the stone cross dividing the glass, its glow.
const TYMPANUM_BACK := 0.25
const PORTAL_WINDOW := Vector2(1.0, 1.2)
const PORTAL_WINDOW_FRAME := 0.15
const PORTAL_WINDOW_CROSS := 0.06
const PORTAL_WINDOW_GLOW := 1.2
## The gable over the outer order (slope in degrees, its coping's thickness and how far it stands out) and the
## pinnacles of the buttresses beside the portal (shaft width, spire height).
const GABLE_SLOPE := 60.0
const GABLE := Vector2(0.4, 0.2)
const PINNACLE := Vector2(1.3, 1.8)
## The spill of the portal's light down the steps (energy, range, cone): it lights the floor, the steps and the
## fighters, not the facade nor the statues (FACADE_LAYER).
const SPILL := Vector3(6.5, 16.0, 60.0)
## Where the spill aims: this far into the hall from its north edge (the steps and the wet floor at their foot).
const SPILL_AIM := 0.8
## Its colour: the portal's green, a little toward teal (cycle 6: less cyan, the picture's steps are a purer green).
const SPILL_COLOR := Color(0.3, 1.0, 0.5)
## The cold light on the facade alone (its colour, energy, and where it shines from: x off the portal, height, z out
## of the facade), so the stone and the statues read dark teal against the green.
const FACADE_FILL := Color(0.55, 0.74, 0.82)
const FACADE_FILL_ENERGY := 3.0
const FACADE_FILL_FROM := Vector3(-7.0, 16.0, 11.0)
## Where along the facade it aims (m east of the portal) and its cone (degrees): the whole facade east of the portal.
const FACADE_FILL_AIM := 2.0
const FACADE_FILL_CONE := 70.0
## The facade's relief: a plinth along its foot (height, how far out), two cornices (heights over the dais, height,
## how far out), blind pointed niches between the buttresses (width, height, how far over the dais; their dark back),
## and the tall windows over them (width, height, over the dais) with a mullion.
const PLINTH := Vector2(1.0, 0.25)
const CORNICES: Array[float] = [4.2, 8.0]
const CORNICE := Vector2(0.25, 0.2)
const NICHE := Vector3(0.9, 2.4, 1.2)
const NICHE_DARK := 0.3
const HIGH_WINDOW := Vector3(1.2, 2.6, 4.6)
const MULLION := 0.1
## The buttresses along the facade (x), and the bays between them that take a niche and a window (x).
const BUTTRESSES: Array[float] = [-5.9, -3.6, 0.8, PORTAL_X - 4.7, PORTAL_X + 4.7, 19.0]
const BAYS: Array[float] = [-1.4, 3.3, 17.1]
## The banners on the buttresses (plain: no emblem until Daniel names Eterra's): x, height of the bar over the dais,
## width, length; how far in front of the facade's face they hang.
const BANNERS: Array[Vector4] = [Vector4(-5.9, 5.9, 2.1, 4.6), Vector4(PORTAL_X + 5.0, 6.8, 2.6, 5.8)]
const BANNER_OUT := 1.5
## The key light over the hall (the picture's middle of the room is a greyed mauve, its edges dark teal).
const KEY_LIGHT := Color(0.92, 0.8, 0.78)
const KEY_ENERGY := 5.6
const KEY_HEIGHT := 9.0
const KEY_RANGE := 16.0
## Tint of the walls under the platform (dark against the lighter mist).
const CLIFF_TINT := 0.9
## The depths (cycle 6: three uneven masses near, cards of painted silhouettes far; no rows of equal piers). Everything
## out there is placed across the showcase camera's view: d meters ahead of it, l meters right of its middle (left is
## negative), at a height. How much the near masses fade into the mist (the tower of the chains least: dark iron).
const NEAR_FADE := 0.5
const PYLON_FADE := 0.12
const PYLON_TINT := 0.55
## The west bridge, running from the giant's tower out of the picture: its distance, the lateral range of its deck,
## the deck (top height, thickness, depth).
const BRIDGE_DIST := 69.0
const BRIDGE := Vector2(-37.0, -18.6)
const BRIDGE_DECK := Vector3(0.6, 1.2, 2.6)
## On it: a tower of three stacked blocks (lateral, base width; each block's share of that width and its height), a
## loose block (lateral, width, height), stumps of a broken parapet (lateral, length; their height).
const BRIDGE_TOWER := Vector2(-22.4, 2.5)
const BRIDGE_TOWER_BLOCKS: Array[Vector2] = [Vector2(1.0, 1.0), Vector2(0.78, 0.9), Vector2(0.58, 0.8)]
const BRIDGE_CUBE := Vector3(-25.7, 1.7, 1.0)
const BRIDGE_PARAPET: Array[Vector2] = [Vector2(-33.5, 3.0), Vector2(-28.4, 1.6), Vector2(-19.9, 1.4)]
const BRIDGE_PARAPET_HEIGHT := 0.55
## Under it, open to the violet behind: piers out of the mist (lateral, width), a pointed arch in each gap between
## two of them (its apex this far under the deck, its ring's width); the pier with the lit window is the wide one.
const BRIDGE_PIERS: Array[Vector2] = [Vector2(-18.9, 0.8), Vector2(-21.8, 0.8), Vector2(-24.1, 1.7), Vector2(-28.6, 1.1),
	Vector2(-32.6, 1.4), Vector2(-36.4, 1.2)]
const BRIDGE_ARCH := Vector2(0.35, 0.4)
## Cycle 7, so no pier draws one long straight edge against the violet behind it: string courses round each pier
## (how far apart down the pier, in m, least and most; how far they stand out; their height), a wider footing low
## down (its top, how much wider), and broken dark shafts standing free in front of the widest gaps (lateral,
## width, top; how far in front of the bridge).
const PIER_COURSES := Vector2(2.6, 4.2)
const PIER_COURSE := Vector2(0.3, 0.45)
const PIER_COURSES_DOWN := 5
const PIER_FOOTING := Vector2(-9.5, 0.45)
const BRIDGE_SHAFTS: Array[Vector3] = [Vector3(-30.9, 0.5, -2.2), Vector3(-26.2, 0.38, -4.6), Vector3(-34.3, 0.42, -6.0),
	Vector3(-20.3, 0.36, -3.4)]
const BRIDGE_SHAFT_AHEAD := 1.8
## The middle gate, a wide dark block behind the hall's north-west corner: its distance, lateral range, top, depth;
## its pointed arch (lateral of its middle, span, springing height, arc radius as a share of the span) and the ring
## of stone over it; uneven merlons on top (lateral, width, height); a low wing west of it with a lancet (lateral of
## its middle, opening width, sill height, apex height) and how far its top stands over that apex.
const GATE_DIST := 88.0
const GATE := Vector2(-16.3, -5.4)
const GATE_TOP := -5.2
const GATE_DEPTH := 2.4
const GATE_ARCH := Vector4(-10.5, 5.2, -9.6, 0.68)
const GATE_RING := 0.9
## The spandrels, the stone between the ring, the masses and the lintel (width as a share of the span, height): small
## enough to stay outside the ring, so the opening follows its curve.
const GATE_SPANDREL := Vector2(0.165, 0.9)
## The dark of the passage behind the gate's arches (the violet glows against it), and how far behind them it stands.
const GATE_PASSAGE := Color(0.02, 0.012, 0.045)
const GATE_PASSAGE_BACK := 4.5
## Its top this far under the gate's (so it never shows over it).
const GATE_PASSAGE_UNDER := 3.0
## Two thin dark shafts standing in the passage, before the violet (lateral from the arch's middle, width; how far
## behind the gate; their top under the gate's).
const GATE_SHAFTS: Array[Vector2] = [Vector2(-1.05, 0.34), Vector2(0.7, 0.26)]
const GATE_SHAFT_BACK := 1.6
const GATE_SHAFT_UNDER := 0.8
const GATE_MERLONS: Array[Vector3] = [Vector3(-15.4, 1.5, 0.9), Vector3(-12.6, 2.2, 0.5), Vector3(-9.6, 1.3, 1.1), Vector3(-6.5, 1.9, 0.6)]
const GATE_WING := Vector4(-17.6, 1.5, -14.0, -8.6)
## Cycle 7, so the gate's two masses are not flat faces: string courses (their height under its top) and a dark
## slit in each mass (lateral; then its width, height and how far under the top it starts).
const GATE_COURSES: Array[float] = [1.7, 4.6, 7.9]
const GATE_SLITS: Array[float] = [-14.6, -6.7]
const GATE_SLIT := Vector3(0.4, 1.9, 2.3)
const GATE_WING_OVER := 1.0
## The far ruins: three cards of silhouettes drawn by abyss_ruins.gdshader (broken towers of stacked blocks, arches
## and decks between some, a cave's roof and stalactites on the farthest), fixed across the view so they slide against
## each other when the game's camera moves. Per card: distance; share of mist in its stone; width of a column of its
## silhouettes (m); the towers' mean top and how much it varies (m: low, since the camera looks down on them); the
## heights where its feet start to sink into the mist and where they are gone. All of it nearer than the camera's far
## plane (160 m) from any place the game's camera stands. The cards' size (they reach from RUIN_TOP down), how far left
## of the view's middle their middle is (share of their distance), the cave's roof on the last card (its height, how
## much lower it hangs to the west, where along the card it starts to drop and is lowest).
const RUIN_DIST: Array[float] = [98.0, 108.0, 120.0]
const RUIN_HAZE: Array[float] = [0.25, 0.45, 0.65]
const RUIN_COLUMN: Array[float] = [9.0, 6.5, 5.0]
const RUIN_TOPS: Array[Vector2] = [Vector2(-6.5, 3.0), Vector2(-10.0, 3.5), Vector2(-14.5, 4.0)]
const RUIN_SINK: Array[Vector2] = [Vector2(-9.0, -22.0), Vector2(-13.0, -26.0), Vector2(-18.0, -31.0)]
const RUIN_SIZE := Vector2(300.0, 110.0)
const RUIN_TOP := 24.0
const RUIN_LEFT := 0.1
const RUIN_ROOF := Vector4(-8.0, 12.0, -10.0, -32.0)
## Banks of pale mist between the planes (distance from the camera, height of their middle, size, opacity from the
## nearest to the farthest: the far planes sink deeper into it).
const MIST_BANKS: Array[float] = [94.0, 103.0, 114.0]
const MIST_YS: Array[float] = [-15.0, -19.0, -24.0]
const MIST_SIZE := Vector2(150.0, 12.0)
const MIST_ALPHAS: Array[float] = [0.18, 0.28, 0.35]
## The veil of mist behind everything is painted by the last card of ruins where no stone stands (opaque: no blended
## card over the screen): how much lighter than the fog it is, and its two lighter patches (the picture's bright spots
## up high: lateral on that card's distance, height, radii).
const VEIL_LIGHT := 1.35
const VEIL_PATCHES: Array[Vector4] = [Vector4(-27.1, -11.6, 6.5, 4.5), Vector4(-15.2, -14.6, 3.4, 3.8)]
## The violet glow cards (cycle 6: only low down, never over the mist up high): in the gate's arches, under the
## bridge, at the foot of the west side, and the east ones. West ones: distance, lateral, foot height, then width,
## height, energy share, then its shape (ArenaKit.abyss_glow: reach, falloff, soft share of each side).
const GLOW_WEST: Array[Array] = [
	[90.6, -10.5, -16.0, 9.0, 11.0, 0.8, 1.0, 2.0, 0.2],
	[90.3, -17.6, -19.0, 3.0, 10.0, 0.7, 1.0, 1.2, 0.3],
	[72.5, -32.5, -22.0, 15.0, 21.5, 0.8, 1.0, 1.8, 0.15],
	[62.0, -27.0, -25.0, 16.0, 25.0, 0.9, 0.9, 1.3, 0.25],
	[56.0, -19.5, -25.0, 10.0, 23.0, 0.85, 0.9, 1.3, 0.3],
]
## East ones: rising from the mist (foot) to at most GLOW_TOP; their energy share.
const GLOW_FOOT := -10.0
const GLOW_TOP := -4.0
const GLOW_EAST := 1.4
## A glow card low beside the east cliff (foot; width, height; energy share), seen right of the east stairs.
const EAST_FOOT_GLOW := Vector3(HALF.x + 2.5, -7.0, -11.0)
const EAST_FOOT_GLOW_SIZE := Vector2(12.0, 9.0)
const EAST_FOOT_GLOW_ENERGY := 1.6
## Cycle 7, the near plane of the abyss (dark stone standing out of the mist close under the hall's sides, where
## the corners of the frame were a flat teal): groups of three ruins, each a broken tower of stacked blocks, a pointed
## arch on two piers and a fallen pillar leaning on a stump. Per group: where its tower stands (x, z), the height of
## its tallest top (under the floor: it never hides the hall), and the way its pieces are strung out from there
## (yaw: 0 to the south, a quarter turn to the east, half a turn to the north).
const RUIN_GROUPS: Array[Vector4] = [Vector4(-6.5, 23.0, -1.8, PI * 0.5), Vector4(18.9, 3.4, -1.6, 0.0), Vector4(21.6, -8.2, -1.9, PI)]
## Their pieces, along the group's line (m from its middle) and across it: the tower (along, across, base width; its
## blocks as in BRIDGE_TOWER_BLOCKS), the arch (along, across, span; its opening's height, its top under the group's),
## the pillar (along, across, length; its width, its lean in radians, its top under the group's).
const RUIN_TOWER := Vector3(0.0, 0.3, 2.0)
const RUIN_TOWER_BLOCKS: Array[Vector2] = [Vector2(1.0, 2.4), Vector2(0.8, 1.6), Vector2(0.62, 1.1)]
const RUIN_ARCH := Vector3(4.6, 0.9, 2.2)
const RUIN_ARCH_SHAPE := Vector2(3.4, 0.9)
const RUIN_PILLAR := Vector3(9.6, 0.8, 4.2)
const RUIN_PILLAR_SHAPE := Vector3(0.85, 0.62, 1.4)
## A low bank of pale mist in level streaks behind each group (cycle 7: the flat teal under the hall's sides): how
## far behind the group's middle it hangs (m to the north and to the west: behind, as the camera sees it), its
## middle's height under the group's top, its size, opacity and how much it parts into streaks.
const RUIN_MIST := Vector2(1.2, 2.6)
const RUIN_MIST_SIZE := Vector2(24.0, 6.0)
const RUIN_MIST_ALPHA := 0.4
const RUIN_MIST_BANDS := 0.85
## The arch that carries each flight of stairs down out of the hall (cycle 7: the space under a flight was empty):
## its ring's width and depth, the radius of its arcs (share of the span); its crown meets the flight's underside
## (STAIR_UNDER below the lowest step, as Masonry.stairs builds it).
const STAIR_ARCH := Vector3(0.55, 0.7, 0.7)
const STAIR_UNDER := 0.6
## The iron pylon the chains hang from (behind the giant, standing on the gate): its place, top and width; collars
## round it (heights, how much wider) and the arm the chains hang from (height, length).
const TOWER := Vector3(-35.0, 0, -23.0)
const TOWER_TOP := 12.0
const TOWER_WIDTH := 1.5
const TOWER_COLLARS: Array[float] = [-3.0, 2.5, 7.0]
const TOWER_COLLAR := 0.5
const TOWER_ARM := Vector2(9.5, 4.2)
## The lit window under the bridge (the picture's lantern): its size and height, its frame, its warm glass (the
## top of the pane this share of the bottom's colour) and the halo round it.
const LANTERN := Vector2(0.95, 1.7)
const LANTERN_Y := -3.2
const LANTERN_FRAME := 0.12
const LANTERN_TOP := 0.5
const LANTERN_HALO := 0.9
## Where the wall with the window stands under the bridge (share of the bridge's distance, left of the view's middle).
const LANTERN_LAT := -0.349
const LANTERN_GLASS := Color(1.25, 0.36, 0.08)
const LANTERN_HALO_COLOR := Color(0.24, 0.1, 0.03)
## The lead of its glazing, dark against the glass: bar width, upright bars, cross bars.
const LANTERN_BAR := 0.05
const LANTERN_UPRIGHTS := 1
const LANTERN_CROSSES := 1

## The stylized look (STY-04; docs/art/stylized_spec.md 1.3, T4): the fires make short pools with a drawn edge (the
## painted light's bands cut the falloff into rings): range of a fire bowl's and of a candle cluster's light, the
## bowls' steeper falloff (the candles keep theirs: a steeper one burnt their own wax white), their energy as a share
## of the classic one. The key light over the middle is off (the hall's light is the
## warm ambient and the key from behind the camera, VisualProfile; an omni over the middle drew rings on the floor).
## STY-10 (art review, criterion 3: no pools): a fire paints a flat pool inside a drawn edge, brighter than its light
## (paint.gdshaderinc, paint_pool_gain), so its falloff only sets how far the edge reaches: the bowls' gentler (their
## light stands 2.8 m up, on the pedestal); the candles' energy up again; the bowls cast no shadow in this look (the
## bowl's own rim shadowed the floor out to 2.3 m round the pedestal: the pool was a thin ring outside a dark disc; the
## key from behind the camera draws the figures' shadows). ENV-HB1 (2026-11-20): the bowls' pools a metre wider (4.5 to
## 5.5), the amber marking the areas of the hall on the petrol slate.
const STY_BOWL_RANGE := 5.5
const STY_CANDLE_RANGE := 3.5
const STY_BOWL_ATTENUATION := 0.5
const STY_BOWL_GAIN := 0.9
const STY_CANDLE_GAIN := 1.5
## The fires' pools on the hall's blue slate keep more of their warm (lot A review item 8: the hall had lost its heat,
## warm share of the scene 6.5% to 1.8%; paint_pool_saturation, 0.65 elsewhere).
const STY_POOL_SATURATION := 0.6
## The browser's renderer (Compatibility) paints the pools near white at those energies (laje 217 beside the east bowl):
## the fires a share of them there (as VisualProfile.COMPAT_KEY does for the key).
const STY_COMPAT_FIRE := 0.4
## P2-A5: in Compatibility (no linear to sRGB on the way out) the edge's darkening went to a quarter of the middle and
## the pushed pools went lime under the paladin: there the edge darkens less and the pools keep the fire's own colour.
const STY_COMPAT_FLOOR := {&"edge_value": 0.62, &"paint_pool_saturation": 1.0}
## P2-A4: the portal's spill held on the steps and the floor at their foot in the stylized look (cone in degrees,
## reach): on the petrol floor its green by the north-east candles read as an emerald stain (the emerald is the Emeth's).
const STY_SPILL := Vector2(32.0, 12.0)
## Room redesign (lot A 3.2, decision L-1): the hall's biome in the stylized look, blue slate instead of the STY's warm
## umber (docs/art/room_redesign_lotA_spec.md 3.2; ArenaKit.paint_look, stylize_fires). The fires are STY-10's.
## ENV-HB1 (docs/art/benchmark_hades2_style.md 4.1; the hall's finish test of 2026-11-20, docs/design/
## ciclo_visual_2026-11-20.md item 1): the slate a petrol blue again, its colour the air of the hall (the scene's
## saturation p50 0.14 was greybox), at the same value: stone, floor, the shadow band's tint.
const STYLE := {
	&"stone": STY_STONE, &"shadow": STY_SHADOW, &"floor_stone": STY_FLOOR_STONE,
	&"joint_cold": Color(0.88, 0.91, 1.0), &"olive_share": 0.06, &"abyss_glow": STY_ABYSS_GLOW, &"pool_saturation": STY_POOL_SATURATION,
	&"fire": {&"bowl_range": STY_BOWL_RANGE, &"candle_range": STY_CANDLE_RANGE, &"bowl_attenuation": STY_BOWL_ATTENUATION,
		&"bowl_gain": STY_BOWL_GAIN, &"candle_gain": STY_CANDLE_GAIN, &"compat": STY_COMPAT_FIRE},
	&"floor": STY_FLOOR_BIOME, &"shadow_glow": STY_SHADOW_GLOW, &"vignette": STY_VIGNETTE,
}
## C1V (docs/art/identidade_c1v.md 2.1, only in the stylized look). The coloured shadow: the key's shadow band takes this
## cold violet on top (around #1E2236 lit by the ambient; hue 225 to 240, saturation 0.25 to 0.4 on the floor).
const STY_SHADOW_GLOW := Color(0.50, 0.42, 1.0)
## The scene's vignette on the stone, floor and kit (paint.gdshaderinc: how much darker, where it starts and where it is
## full, 0 the middle of the screen, 1 the middle of an edge): the edge boxes at 0.55 to 0.70 of the middle.
const STY_VIGNETTE := Vector3(0.75, 0.4, 1.2)
## The warm key (a faint amber from high up to the left, diffuse, no shadow, never on the crowd): its colour (#F2C890),
## energy, where it lands on the floor (x, z), the radius of the pool (m), and where it comes from over that spot
## (x, height, z). The pool covers 10 to 18 % of the walkable floor, about 7 m round.
const STY_WARM_KEY := Color(0.949, 0.784, 0.565)
const STY_WARM_ENERGY := 7.0
const STY_WARM_AT := Vector2(-6.5, 1.5)
const STY_WARM_RADIUS := 7.0
const STY_WARM_FROM := Vector3(-13.0, 16.0, 0.5)
const STY_WARM_SOFT := 2.0
## C-4 (AD2-09): two more warm pools of the candles on the floor, x, z, radius, energy (the fight's middle stays the
## brightest: the cold key and the warm key over it).
const STY_POOLS: Array[Vector4] = [Vector4(-9.5, -5.5, 3.4, 2.6), Vector4(6.5, 7.5, 3.4, 2.4)]
## The shaft of Elun (beam.gdshader, the hall's): ivory gold (hue 40), where its foot stands in the upper half of the
## frame (x, z; it opens round the paladin by itself), its radius at the foot, its height, the light it asks for and its cap
## (linear), the share of what is behind that one face covers, how frayed its sides are (brush_break) and the brush's
## size, the dust (brightness, cells round and up, rise, dot) and how pale its core goes.
const ELUN_LIGHT := Color(1.0, 0.86, 0.58)
const STY_SHAFT_AT := Vector2(-9.5, 2.0)
const STY_SHAFT_RADIUS := 2.2
const STY_SHAFT_HEIGHT := 15.0
## ... and how far it leans (degrees from the vertical, the top toward the west: light from high up to the left).
const STY_SHAFT_LEAN := 25.0
const STY_SHAFT := Vector2(3.0, 2.5)
const STY_SHAFT_BODY := 0.08
const STY_SHAFT_CORE := Vector2(0.5, 0.35)
const STY_SHAFT_BRUSH := Vector2(0.3, 0.9)
const STY_SHAFT_DUST := Vector4(1.4, 9.0, 7.0, 0.14)
## The mist banks in the stylized look: how brushed (abyss_mist.gdshader's brush) and the share of the nearest plane's
## colour kept (the near is darker; the far keeps its own).
const STY_MIST_BRUSH := 1.0
const STY_MIST_NEAR := 0.7
const STY_STONE := Color(0.27, 0.35, 0.44)
const STY_FLOOR_STONE := Color(0.25, 0.325, 0.415)
const STY_SHADOW := Color(0.78, 0.87, 1.0)
## ENV-HB2 (benchmark 4.1; Daniel's two scales): the floor calm at the scale of a few slabs (a 3 x 2 m patch of
## bare floor up to 30 of luma from p10 to p90, it was 39 to 72): the joints, cracks and missing corners near the slab's
## own value (joint_lift, catacomb_floor.gdshaderinc), a soft bevel, slabs of near values (the classic stone_a and
## stone_b closer, the painted swing and the brush narrower), less rock grain, the slabs barely tilted (the key from
## behind the camera turned each tilt into a lighter or darker slab). The large scale stays: the biome's patches, the
## washes, the clearings, the framed slabs and the medallion (its grooves keep the joint's value), the fires' pools and
## the floor darker toward the hall's edge. The calm numbers shared by every room are ArenaKit.CALM_FLOOR; the hall's own:
## its classic slabs closer, the edge and the pools.
const STY_CALM := {&"stone_a": Color(0.35, 0.29, 0.32), &"stone_b": Color(0.42, 0.35, 0.38), &"edge_value": STY_EDGE_VALUE,
	&"edge_span": STY_EDGE_SPAN, &"paint_pool_gain": STY_POOL_GAIN, &"paint_pool_saturation": STY_FLOOR_POOL_SATURATION}
## ... the floor darker toward the hall's edge than elsewhere (from STY_EDGE_SPAN times the calm radius out; ENV-HB3,
## the bottom of the screen darker than the fight), and the fires' pools on the floor amber, not beige: less bright than
## the default gain (2.5 burnt them to white) and their colour pushed past the fire's (1 is the fire's own; ENV-HB7: 1.9, a
## saturation p50 of 0.45 or more in the pool, was 0.26 to 0.37 at 1.35).
const STY_EDGE_VALUE := 0.38
const STY_EDGE_SPAN := Vector2(0.5, 1.25)
const STY_POOL_GAIN := 1.5
const STY_FLOOR_POOL_SATURATION := 1.0
## S-1: the hall's mouldings lower and its slabs less worn pale than the defaults (1.22, 0.16): noble floor, no buttons.
const STY_FRAMED_LIP := 1.08
const STY_FRAMED_WORN := 0.05
## SW-G1 (docs/art/sworn_reference_ideas.md 3.1): the painted floor's second colour of the biome, in patches of 3 to 8 m,
## stronger near the edge (floor_biome.gdshaderinc; ArenaKit.paint_look's `floor`).
## The hall: pale worn dust on the blue slate; its plate carries no edge distance, so its walkable box is given.
## P1-A1 of the cycle's art review: the patches were the floor's strongest texture once the joints went quiet (damp
## stains with serrated edges all over the field): now ArenaKit.SOFT_PATCHES (fewer, bigger, soft, faint) and the big
## washes faint (ArenaKit.CALM_FLOOR). The large scale comes from the fires' pools, the edge, the framed slabs and the
## medallion.
const STY_FLOOR_BIOME := {&"patch_color": Color(0.36, 0.45, 0.55),
	&"floor_box": Vector4(0.0, 0.0, HALF.x, HALF.y), &"framed_lip": STY_FRAMED_LIP, &"framed_worn": STY_FRAMED_WORN,
	&"framed_lion_span": EMBLEM_LION_SPAN}
## ENV-HB3 (benchmark 4.1): the frame dark and full. The hall's own stone below the floor (the lips, the buttresses and
## the cliffs) a deep petrol in the stylized look, so the bottom of the screen is no lighter than the fight; and out in
## the abyss toward the camera, south and east of the hall, broken columns of the depths' stone rising out of the mist
## (each: x, z, top over the floor, radius), never over the walkable floor nor a way out on the screen (a point at
## height h hides the floor 1.73 h m behind it along the view: x - 0.99 h, z - 1.42 h, kept off the room and the
## stairs), opening in a stipple round the paladin behind them; a fallen drum (x, z, size) and a chain between two.
const STY_FRAME_STONE := Color(0.11, 0.17, 0.22)
## ... and the balustrades nearest the camera (south, the landing's, the east one by the corner) a step darker than the
## hall's stone, so their lit tops do not make a light band at the bottom of the screen.
const STY_NEAR_STONE := Color(0.13, 0.18, 0.24)
const STY_FRAME_COLUMNS: Array[Vector4] = [Vector4(19.6, 19.4, 3.4, 0.75), Vector4(22.0, 12.5, 4.6, 0.8),
	Vector4(21.6, 8.0, 3.6, 0.65), Vector4(15.5, 21.5, 3.6, 0.7), Vector4(4.6, 22.6, 3.0, 0.6), Vector4(2.0, 21.4, 3.2, 0.75)]
const STY_FRAME_FOOT := -12.0
const STY_FRAME_DRUM := Vector4(18.2, 22.6, 1.3, 0.6)
const STY_FRAME_CHAIN: Array[int] = [1, 0]
## The columns' broken tops (the shaft stops this share of a radius under the top, where an askew drum of CAP times the
## radius sits, tilted up to TILT rad), a ring of fallen stone at RING_AT of the height down (RING: width in radii,
## height), the drum's length in its diameters and its lean (rad), the chain's drop under the tops, sag and link size;
## the columns' own dice (never the room's _rng: the classic look stays the same).
const STY_FRAME_BREAK := 0.6
const STY_FRAME_CAP := Vector3(1.7, 0.6, 1.7)
const STY_FRAME_TILT := 0.25
const STY_FRAME_RING_AT := 0.55
const STY_FRAME_RING := Vector2(2.4, 0.5)
const STY_FRAME_DRUM_LONG := 1.6
const STY_FRAME_DRUM_LEAN := 1.2
const STY_FRAME_CHAIN_DROP := 0.55
const STY_FRAME_CHAIN_SAG := 2.2
const STY_FRAME_CHAIN_SIZE := 1.6
const STY_FRAME_SEED := 4417
## SW-H1, SW-G3 (docs/art/sworn_reference_ideas.md 3.2): two pairs of slabs (ArenaKit.framed) flanking the axis of
## the dais's flight (its middle, x) on the way from the medallion to the portal. S-1 of the Sworn P1 review: four equal
## square frames lighter than the floor read as pressure plates (the runes' room has slabs that strike): each its own
## size, value (never over the floor's) and kind, one a grave slab with the lion, one with a corner of its moulding
## broken. Each: x from the axis, z, size x, size z (m), kind, mark (lion or broken corner), value.
const STY_FRAMES: Array[Array] = [
	[-2.3, -9.3, 2.0, 2.0, ArenaKit.Framed.RAISED, false, 0.95],
	[2.4, -9.4, 2.6, 2.2, ArenaKit.Framed.RAISED, true, 1.0],
	[-2.5, -12.0, 2.8, 2.2, ArenaKit.Framed.GRAVE, false, 0.97],
	[2.2, -12.0, 2.2, 2.0, ArenaKit.Framed.RAISED, false, 0.92],
]
## The decals of the stylized look (floor_decal.gdshader: the shop's rugs, the fountain's moss), a centimetre over the
## slabs.
const DECAL_SHADER := preload("res://assets/shaders/floor_decal.gdshader")
const SHOP_RUG := Vector2(2.6, 1.8)
const SHOP_RUG_Y := 0.012
## PT-11: the column behind each wall item (size) and how far behind the item it stands.
const SHOP_COLUMN := Vector3(0.45, 2.4, 0.45)
const SHOP_COLUMN_BACK := 1.1
## The shop's lanterns: from the item's point, how far back (away from the camera) and to the right the bracket's rod
## stands on the reliquary's side, how far the arm reaches on into the gap; the arm's height, where the lantern's
## foot hangs, its little post (none to speak of), its lamp (warm, a little past a candle's reach, SHOP_LAMP_RANGE, and
## brighter: a pool of amber on every rug, lot A review item 3; glass and flame no brighter than the screen's ceiling).
const SHOP_LANTERN := Vector3(0.8, 0.8, 0.9)
const SHOP_ARM := 2.3
const SHOP_LANTERN_FOOT := 1.0
const SHOP_LANTERN_POST := Vector3(0.05, 0.02, 0.05)
const SHOP_LAMP_RANGE := 4.5
const SHOP_LAMP_ENERGY := 4.0
## GR-25: the link from a shop lantern's roof to the arm (its width, m): the lantern hung from nothing.
const SHOP_LINK := 0.06
## ... amber, deeper than a candle's (its pool is painted at a share of a fire's saturation). ENV-HB1: nearer the
## bowls' amber (the floor's pools at STY_FLOOR_POOL_SATURATION turned the old 1.0 / 0.7 / 0.25 a vivid yellow, hue 48).
const SHOP_LAMP_LIGHT := Color(1.0, 0.66, 0.36)
static var SHOP_LAMP := TombKit.Lamp.new(ScreenTone.fit(Color(1.0, 0.62, 0.3)), ScreenTone.fit(Color(1.9, 1.0, 0.35)),
	SHOP_LAMP_LIGHT, SHOP_LAMP_ENERGY, SHOP_LAMP_RANGE, 1.3)
## The provisions' cloth (umber, folded over the crates: x, z, size, y of its top) and its colour (times the stone's),
## and their two urns (x, z, height, y).
const SHOP_CLOTH := Color(0.55, 0.38, 0.28)
const SHOP_CLOTHS: Array[Vector4] = [Vector4(7.3, -14.0, 0.75, 1.46), Vector4(-5.35, -14.2, 0.85, 0.56)]
## Art review 2026-11-21 item 8 (stylized look): the urns' stone tinted to about (0.62, 0.57, 0.5), not white.
const STY_URN_TINT := Color(0.45, 0.40, 0.34)
const SHOP_URNS: Array[Vector4] = [Vector4(8.3, -13.8, 0.3, 0.8), Vector4(-6.25, -13.75, 0.26, 0.45)]
## The fountain's moss (inner, mean outer radius from the basin's middle; how far its edge breaks either way, how far
## it swings out to the north and in to the south: lot A review item 9, 2.6 to 3.4 m), its candles on the rim
## (angles; the first FOUNTAIN_LIT burn).
const FOUNTAIN_MOSS := Vector2(1.95, 3.0)
const FOUNTAIN_MOSS_RAGGED := 0.5
const FOUNTAIN_MOSS_NORTH := 0.3
const FOUNTAIN_CANDLES: Array[float] = [-2.2, -1.95, -0.9, 0.7, 2.4, 2.65]
const FOUNTAIN_LIT := 4
## Item 4 of the cycle of 2026-11-20 (the fountain read at the near camera's edge): the cold pool over it, from straight
## above (over the basin's middle; energy, cone, reach), its node's name and what is left of it when spent.
const FOUNTAIN_POOL_FROM := Vector3(0.0, 8.0, 0.0)
const FOUNTAIN_POOL := Vector3(11.0, 36.0, 11.0)
const FOUNTAIN_POOL_NAME := &"FountainPool"
const FOUNTAIN_POOL_SPENT := 0.3
## The stylized look's urns (x, z, height, y of what they stand on): by the west balustrade's two pot groups, between
## the pots and the balustrade (its posts fill the lip over the abyss), never over 0.28 m (nothing new above 0.3 m on
## the walkable floor), and on the lower step of the portal statues' plinths (in front, toward the steps).
const URNS: Array[Vector4] = [Vector4(-15.3, -12.2, 0.28, 0.0), Vector4(-15.35, -11.5, 0.22, 0.0),
	Vector4(-15.3, 0.95, 0.28, 0.0), Vector4(-15.35, 1.75, 0.22, 0.0),
	Vector4(PORTAL_X - 4.31, -17.58, 0.48, DAIS_Y + 0.3), Vector4(PORTAL_X + 4.51, -17.58, 0.48, DAIS_Y + 0.3)]

var arena: Arena
var kit: ArenaKit
var _key: OmniLight3D
var m: Masonry
var _rng := RandomNumberGenerator.new()
## How many candle groups were laid (C-3: the drawing of the next one).
var _clusters := 0
## The classic look's candles and fight-field crates (hidden in the stylized look, where kit.styled() holds their
## stand-ins).
var _classic: Masonry


func _init(a: Arena, seed_: int) -> void:
	arena = a
	kit = ArenaKit.new(a, seed_)
	m = kit.masonry
	_rng.seed = seed_


## Builds the hall with this many ways on (0 to 3) and tells the arena where its doors, floor and way in are.
func build(exit_count: int) -> void:
	BuildSteps.run(build_steps(exit_count))


## The build in steps, in order (QA P1-1: Arena.build_async gives each its own black frame).
func build_steps(exit_count: int) -> Array[Callable]:
	return [
		func() -> void:
			var a := arena
			a.half = HALF
			a.pillars = []
			a.shafts = []
			# the landing's floor reaches well into the room, so their walkable parts overlap (a body is kept 1.2 m
			# plus its radius from each rectangle's edge)
			a.walk = [Rect2(LANDING.x, HALF.y - 6.0, LANDING.y - LANDING.x, LANDING_END - HALF.y + 6.0)]
			a.start = Vector2((WAY_IN.x + WAY_IN.y) * 0.5, LANDING_END - 2.4)
			a.start_facing = Vector2(1, -1).normalized()
			a.door_pos = Vector2((FLIGHT.x + FLIGHT.y) * 0.5, -HALF.y - 1.5)
			a.showcase = SHOWCASE
			_floor(),
		_dais,
		_facade,
		_dais_props,
		_north_west,
		_north_west_props,
		_west,
		_landing,
		func() -> void: _south(exit_count >= 3),
		func() -> void: _east(exit_count >= 2),
		_depths,
		func() -> void: _doors(exit_count),
		func() -> Array[Callable]:
			var more := m.merge_steps()
			if _classic != null:
				more.append_array(_classic.merge_steps())
			more.append(func() -> void:
				arena.pillars.append_array(kit.circles)
				arena.boxes.append_array(kit.boxes))
			return more,
		_urns,
		_frame,
		func() -> void: HallLife.dress(kit.root, kit.styled()),
		_stylize_rest,
	]


## The stylized look's numbers (VisualProfile): the painted stone, floor and kit (ArenaKit.stylize with STYLE), the
## fires' pools, the key off (the stylized-only urns and frame are the step before). Nothing here moves a piece or touches what blocks.
func _stylize_rest() -> Array[Callable]:
	var style := STYLE.duplicate()
	style[&"off"] = [_key]
	var ground := ArenaKit.CALM_FLOOR.merged(ArenaKit.SOFT_PATCHES).merged(STY_FLOOR_BIOME).merged(STY_CALM)
	if ArenaRoom.compat():
		ground.merge(STY_COMPAT_FLOOR, true)
	style[&"floor"] = ArenaKit.framed(ground, _frames())
	var more := kit.stylize_steps(style, arena)
	more.append(_elun)
	more.append(func() -> void:
		if _spill != null:
			VisualProfile.vary(_spill, {&"spot_angle": STY_SPILL.x, &"spot_range": STY_SPILL.y}))
	return more


## C1V, only in the stylized look: the warm key's pool (a diffuse spot like ArenaRoom.key_pool, no shadow) and the shaft of
## Elun with its dust (beam.gdshader). Nothing collides; neither touches the run.
func _elun() -> void:
	var spot := SpotLight3D.new()
	arena.add_child(spot)
	var to := Vector3(STY_WARM_AT.x, 0.0, STY_WARM_AT.y)
	spot.look_at_from_position(STY_WARM_FROM, to)
	spot.light_color = STY_WARM_KEY
	spot.light_energy = STY_WARM_ENERGY
	spot.light_specular = 0.0
	spot.spot_angle = rad_to_deg(atan(STY_WARM_RADIUS / STY_WARM_FROM.y))
	spot.spot_range = STY_WARM_FROM.length() * 1.6
	spot.spot_attenuation = 0.0
	spot.spot_angle_attenuation = ArenaRoom.KEY_POOL_SOFT
	spot.shadow_enabled = false
	spot.light_cull_mask = ~Arena.CROWD_LAYER
	spot.set_meta(ArenaKit.NOT_FIRE, true)
	ArenaKit.style_only(spot)
	elun_shaft(arena, Vector2(STY_SHAFT_AT.x, STY_SHAFT_AT.y))
	for p: Vector4 in STY_POOLS:
		ArenaRoom.pool_spot(arena, Vector2(p.x, p.y), p.z, ArenaRoom.POOL_WARM, p.w)
	# the mist banks of the depths, brushed (their strokes and a darker near plane)
	for bank in _banks:
		var bm := bank.material_override as ShaderMaterial
		var near: float = bank.get_meta(&"near", 0.0)
		VisualProfile.vary(bm, {&"shader_parameter/brush": STY_MIST_BRUSH,
			&"shader_parameter/color": (bm.get_shader_parameter(&"color") as Color) * lerpf(1.0, STY_MIST_NEAR, near)})


## The shaft of Elun (the hall's numbers) standing at `at` (x, z) under `parent`, only in the stylized look; other rooms
## put theirs through ArenaRoom's `c1v` style key.
static func elun_shaft(parent: Node3D, at: Vector2) -> void:
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.7
	cyl.bottom_radius = 1.0
	cyl.height = 1.0
	cyl.radial_segments = 16
	cyl.cap_top = false
	cyl.cap_bottom = false
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://assets/shaders/beam.gdshader")
	mat.set_shader_parameter(&"color", ELUN_LIGHT)
	mat.set_shader_parameter(&"intensity", STY_SHAFT.x)
	mat.set_shader_parameter(&"cap", STY_SHAFT.y)
	mat.set_shader_parameter(&"body", STY_SHAFT_BODY)
	mat.set_shader_parameter(&"from_above", 1.0)
	mat.set_shader_parameter(&"side_soft", 3.0)
	mat.set_shader_parameter(&"core_light", STY_SHAFT_CORE.x)
	mat.set_shader_parameter(&"core_white", STY_SHAFT_CORE.y)
	mat.set_shader_parameter(&"brush_break", STY_SHAFT_BRUSH.x)
	mat.set_shader_parameter(&"brush_size", STY_SHAFT_BRUSH.y)
	mat.set_shader_parameter(&"dust", STY_SHAFT_DUST.x)
	mat.set_shader_parameter(&"dust_cells", Vector2(STY_SHAFT_DUST.y, STY_SHAFT_DUST.z))
	mat.set_shader_parameter(&"dust_dot", STY_SHAFT_DUST.w)
	var mi := MeshInstance3D.new()
	mi.mesh = cyl
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var lean := deg_to_rad(STY_SHAFT_LEAN)
	mi.position = Vector3(at.x - sin(lean) * STY_SHAFT_HEIGHT * 0.5, cos(lean) * STY_SHAFT_HEIGHT * 0.5, at.y)
	mi.rotation.z = lean
	mi.scale = Vector3(STY_SHAFT_RADIUS, STY_SHAFT_HEIGHT, STY_SHAFT_RADIUS)
	mi.extra_cull_margin = STY_SHAFT_HEIGHT
	mi.set_meta(&"air", true)  # light, not stone: the floor checks skip it
	parent.add_child(mi)
	ArenaKit.style_only(mi)


## ENV-HB3: the stone under the floor a deep petrol (its own painted numbers, ArenaKit.PAINT_OWN) and the broken
## columns of the frame (STY_FRAME_*), only in the stylized look.
func _frame() -> void:
	for mat: Material in _under:
		mat.set_meta(ArenaKit.PAINT_OWN, {&"paint_stone": STY_FRAME_STONE})
	if _near_mat != null:
		_near_mat.set_meta(ArenaKit.PAINT_OWN, {&"paint_stone": STY_NEAR_STONE})
	var sm := kit.styled()
	var dark := (sm.depth_stone(Game.FOG) as ShaderMaterial).duplicate() as ShaderMaterial
	dark.set_shader_parameter(&"see_through", 1.0)
	var r := RandomNumberGenerator.new()
	r.seed = STY_FRAME_SEED
	for c: Vector4 in STY_FRAME_COLUMNS:
		var h := c.z - STY_FRAME_FOOT
		sm.shaft(Vector3(c.x, STY_FRAME_FOOT, c.y), c.w, h - c.w * STY_FRAME_BREAK, dark)
		# the broken top: a drum set askew on it; a ring of fallen stone round the shaft lower down
		var cap := STY_FRAME_CAP * c.w
		var top := sm.box(Vector3(c.x, c.z - cap.y * 0.5, c.y), cap, r.randf() * TAU, dark, false)
		top.rotate_object_local(Vector3.RIGHT, r.randf_range(-STY_FRAME_TILT, STY_FRAME_TILT))
		sm.box(Vector3(c.x, c.z - h * STY_FRAME_RING_AT, c.y), Vector3(c.w * STY_FRAME_RING.x, STY_FRAME_RING.y, c.w * STY_FRAME_RING.x),
			r.randf() * TAU, dark, false)
	var d := STY_FRAME_DRUM
	var drum := sm.shaft(Vector3(d.x, d.w - d.z * 0.5, d.y), d.z * 0.5, d.z * STY_FRAME_DRUM_LONG, dark)
	drum.rotate_object_local(Vector3.FORWARD, STY_FRAME_DRUM_LEAN)
	var a: Vector4 = STY_FRAME_COLUMNS[STY_FRAME_CHAIN[0]]
	var b: Vector4 = STY_FRAME_COLUMNS[STY_FRAME_CHAIN[1]]
	kit.styled_build(func() -> void: kit.chain(Vector3(a.x, a.z - STY_FRAME_CHAIN_DROP, a.y), Vector3(b.x, b.z - STY_FRAME_CHAIN_DROP, b.y),
		STY_FRAME_CHAIN_SAG, STY_FRAME_CHAIN_SIZE))


## Art pack 2026-11-23 (the hall lab): the lion emblem of the middle, a square grave slab with the seal's lion inside the
## medallion's square band (never a disc: round floor marks are Morvath's alone). Its side (m, inside the band's inner
## edge, which is MEDALLION * 0.507 * SQUARE_FIT from the middle), its value and the lion's height on it (m).
const EMBLEM_SIDE := 3.2
const EMBLEM_VALUE := 1.0
const EMBLEM_LION_SPAN := 1.7


## SW-H1: the four slabs of the way to the portal (STY_FRAMES), and the emblem of the middle.
func _frames() -> Array:
	var axis := (FLIGHT.x + FLIGHT.y) * 0.5
	var out := [ArenaKit.framed_slab(MEDALLION_AT, Vector2(EMBLEM_SIDE, EMBLEM_SIDE), ArenaKit.Framed.GRAVE, true, EMBLEM_VALUE, 7)]
	for k in STY_FRAMES.size():
		var f: Array = STY_FRAMES[k]
		out.append(ArenaKit.framed_slab(Vector2(axis + float(f[0]), float(f[1])), Vector2(float(f[2]), float(f[3])), f[4], f[5],
			float(f[6]), k))
	return out


## The urns of the stylized look (room redesign, lot A 3.2): beside the two groups of pots on the west balustrade, on
## the abyss's side of it, and at the foot of the portal's two statues, on their plinths. Nothing on the floor.
func _urns() -> void:
	var sm := kit.styled()
	var mat := sm.carved(0.0, Color.WHITE)
	for u: Vector4 in URNS:
		sm.urn(Vector3(u.x, u.w, u.y), u.z, mat)


## The shop's dressing in the stylized look (room redesign lot A 3.3; Arena.dress_shop, after Rooms lays out the row of
## items at `points`): a painted rug under each item along the row, an iron lantern hung from the side of every
## reliquary but the last into the gap toward the next item (under the signs, never over them), and the provisions (the crates and
## pots at the dais' east foot and in the west nook) under a folded umber cloth with two urns. Nothing blocks.
func dress_shop(points: Array[Vector2]) -> void:
	if points.is_empty():
		return
	var node := Node3D.new()
	node.name = "ShopDress"
	arena.add_child(node)
	ArenaKit.style_only(node)
	var mason := Masonry.new(node)
	var tomb := TombKit.new(mason)
	var right := Feel.screen_to_floor(Vector2.RIGHT, Feel.live().cam_yaw)
	var rug := ShaderMaterial.new()
	rug.shader = DECAL_SHADER
	rug.set_shader_parameter(&"rug_size", SHOP_RUG)
	for k in points.size():
		var p := points[k]
		var mi := MeshInstance3D.new()
		var q := PlaneMesh.new()
		q.size = SHOP_RUG
		mi.mesh = q
		mi.material_override = rug
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.transform = Transform3D(Basis(Vector3.UP, atan2(-right.y, right.x)), Vector3(p.x, SHOP_RUG_Y, p.y))
		node.add_child(mi)
		if k == 0:
			continue  # the highlight stands free on the medallion
		# PT-11: a thin stone column behind the item, against the nearest wall (back or side), under its bubble of light
		var wall := Vector2(0.0, -1.0) if p.y < -8.0 else Vector2(signf(p.x), 0.0)
		var c := p + wall * SHOP_COLUMN_BACK
		mason.box(Vector3(c.x, SHOP_COLUMN.y * 0.5, c.y), SHOP_COLUMN, 0.0, mason.stone(0.0, SHOP_CLOTH), false)
	# the provisions under their cloth
	for c: Vector4 in SHOP_CLOTHS:
		mason.box(Vector3(c.x, c.w, c.y), Vector3(c.z, 0.04, c.z * 0.7), 0.4, mason.stone(0.0, SHOP_CLOTH), false)
	var urn := mason.carved(0.0, STY_URN_TINT if VisualProfile.stylized() else Color.WHITE)
	for u: Vector4 in SHOP_URNS:
		mason.urn(Vector3(u.x, u.w, u.y), u.z, urn)
	mason.merge()
	_trail(node, points)
	var k2 := ArenaKit.new(node, 0)
	k2.paint_look(STYLE)


## Sworn P2 SW-H3: a worn trail of darker slabs from the way in to the row of reliquaries and along it (floor_decal
## kind 6, one strip): TRAIL (its width, how far from the paladin's spawn it starts, its strength), TRAIL_Y over the
## floor (under the rugs).
const TRAIL := Vector3(1.5, 1.5, 0.55)
const TRAIL_Y := 0.008
const TRAIL_COLOR := Color(0.07, 0.08, 0.1)


func _trail(node: Node3D, points: Array[Vector2]) -> void:
	var near := points[0]
	for p in points:
		if p.distance_to(arena.start) < near.distance_to(arena.start):
			near = p
	var row := points.duplicate()
	row.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.distance_to(near) < b.distance_to(near))
	var from := arena.start + (near - arena.start).normalized() * TRAIL.y
	var path := PackedVector2Array([from])
	for p in row:
		path.append(p)
	var mat := ShaderMaterial.new()
	mat.shader = DECAL_SHADER
	mat.set_shader_parameter(&"kind", 6)
	mat.set_shader_parameter(&"rug_size", Vector2(1.0, TRAIL.x))
	mat.set_shader_parameter(&"trail", TRAIL_COLOR)
	mat.set_shader_parameter(&"alpha", TRAIL.z)
	node.add_child(floor_strip(path, TRAIL.x, TRAIL_Y, mat, false))


## A flat strip a hair over the floor along `path` (x, z), `width` wide: UV.x the metres along it, UV.y 0..1 across,
## the vertex colour's alpha 1 at its start and, with `fade`, 0 at its end (floor_decal kinds 5 and 6).
static func floor_strip(path: PackedVector2Array, width: float, y: float, mat: Material, fade: bool) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var total := 0.0
	for i in range(1, path.size()):
		total += path[i - 1].distance_to(path[i])
	var s := 0.0
	var prev_l := Vector3.ZERO
	var prev_r := Vector3.ZERO
	var prev_s := 0.0
	for i in path.size():
		var d := (path[mini(i + 1, path.size() - 1)] - path[maxi(i - 1, 0)]).normalized()
		var n := Vector2(-d.y, d.x) * width * 0.5
		if i > 0:
			s += path[i - 1].distance_to(path[i])
		var l := Vector3(path[i].x + n.x, y, path[i].y + n.y)
		var r := Vector3(path[i].x - n.x, y, path[i].y - n.y)
		if i > 0:
			var a0 := 1.0 - (prev_s / total if fade else 0.0)
			var a1 := 1.0 - (s / total if fade else 0.0)
			for v: Array in [[prev_l, prev_s, 0.0, a0], [r, s, 1.0, a1], [prev_r, prev_s, 1.0, a0],
					[prev_l, prev_s, 0.0, a0], [l, s, 0.0, a1], [r, s, 1.0, a1]]:
				st.set_color(Color(1, 1, 1, v[3]))
				st.set_uv(Vector2(v[1], v[2]))
				st.set_normal(Vector3.UP)
				st.add_vertex(v[0])
		prev_l = l
		prev_r = r
		prev_s = s
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


## Sworn P2 SW-H2: the fountain's water run out of the basin down the floor's joints in RIVULETS (their bearing from
## north, clockwise, degrees) wet dark runs that turn at right angles as joints do (RIVULET_LEG: a leg's length range,
## m), fading by RIVULET_REACH m from the rim, moss beside them (only painting, nothing over the floor).
const RIVULETS: Array[float] = [118.0, 205.0, 262.0]
const RIVULET_LEG := Vector2(0.35, 0.85)
const RIVULET_REACH := 3.0
const RIVULET := Vector2(0.16, 0.55)
const RIVULET_WET := Color(0.045, 0.06, 0.07)
const RIVULET_ALPHA := 0.8


static func _rivulets(node: Node3D) -> void:
	var wet := ShaderMaterial.new()
	wet.shader = DECAL_SHADER
	wet.set_shader_parameter(&"kind", 5)
	wet.set_shader_parameter(&"wet", RIVULET_WET)
	wet.set_shader_parameter(&"alpha", RIVULET_ALPHA)
	var moss := wet.duplicate() as ShaderMaterial
	moss.set_shader_parameter(&"wet_moss", 1.0)
	var r := RandomNumberGenerator.new()
	r.seed = 2207
	var rim := ArenaKit.FOUNTAIN_BASIN.x + 0.05
	for b in RIVULETS:
		var way := Vector2(sin(deg_to_rad(b)), -cos(deg_to_rad(b)))
		var p := way * rim
		var path := PackedVector2Array([p])
		var run := 0.0
		var on_x := absf(way.x) > absf(way.y)
		while run < RIVULET_REACH:
			var leg := r.randf_range(RIVULET_LEG.x, RIVULET_LEG.y)
			var step := Vector2(signf(way.x) * leg, 0.0) if on_x else Vector2(0.0, signf(way.y) * leg)
			p += step
			path.append(p)
			run += leg
			on_x = not on_x if r.randf() < 0.6 else on_x
		node.add_child(floor_strip(path, RIVULET.y, SHOP_RUG_Y + 0.002, moss, true))
		node.add_child(floor_strip(path, RIVULET.x, SHOP_RUG_Y + 0.003, wet, true))


## The fountain's dressing in the stylized look (room redesign lot A 3.4; ArenaKit.fountain): its stone painted as the
## hall's, a ragged ring of moss with pale flowers painted on the floor round the basin (denser to the north), four
## candles burning on the basin's rim and two burnt out. No new light (the fountain's own lights them).
static func dress_fountain(parent: Node3D) -> void:
	var node := Node3D.new()
	node.name = "FountainDress"
	parent.add_child(node)
	ArenaKit.style_only(node)
	var mi := MeshInstance3D.new()
	var q := PlaneMesh.new()
	q.size = Vector2.ONE * (FOUNTAIN_MOSS.y + FOUNTAIN_MOSS_NORTH + FOUNTAIN_MOSS_RAGGED + 0.1) * 2.0
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = DECAL_SHADER
	mat.set_shader_parameter(&"kind", 1)
	mat.set_shader_parameter(&"ring", FOUNTAIN_MOSS)
	mat.set_shader_parameter(&"ragged", FOUNTAIN_MOSS_RAGGED)
	mat.set_shader_parameter(&"north_reach", FOUNTAIN_MOSS_NORTH)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position.y = SHOP_RUG_Y
	node.add_child(mi)
	var mason := Masonry.new(node)
	var r := ArenaKit.FOUNTAIN_BASIN.x - ArenaKit.FOUNTAIN_BASIN.z * 0.5
	for k in FOUNTAIN_CANDLES.size():
		var a: float = FOUNTAIN_CANDLES[k]
		var at := Vector3(cos(a) * r, ArenaKit.FOUNTAIN_BASIN.y, sin(a) * r)
		if k < FOUNTAIN_LIT:
			mason.candle(at, 0.16 + 0.05 * (k % 2), 0.05)
		else:
			mason.candle_out(at, 0.1, 0.05)
	mason.merge()
	_rivulets(node)
	# item 4 of the cycle of 2026-11-20: a cold pool of light over it (diffuse, no shadow, never on the crowd), so it
	# reads at the edge of the near camera's frame among the warm candles' pools; it fades when he drinks
	var pool := SpotLight3D.new()
	pool.name = FOUNTAIN_POOL_NAME
	node.add_child(pool)
	pool.position = FOUNTAIN_POOL_FROM
	pool.rotation.x = -PI * 0.5  # straight down (a spot shines along its -z)
	pool.light_color = ArenaKit.FOUNTAIN_LIGHT
	pool.light_energy = FOUNTAIN_POOL.x
	pool.spot_angle = FOUNTAIN_POOL.y
	pool.spot_range = FOUNTAIN_POOL.z
	pool.spot_angle_attenuation = 1.6
	pool.light_specular = 0.0
	pool.shadow_enabled = false
	pool.light_cull_mask = ~Arena.CROWD_LAYER
	var kit := ArenaKit.new(parent, 0)
	kit.paint_look(STYLE)


# ---------- the floor, its lip and the cliffs under it ----------

func _floor() -> void:
	kit.wet_zone = WET
	kit.floor_plate(Vector3.ZERO, HALF * 2.0 + Vector2(0.6, 0.6), MEDALLION, MEDALLION_AT)
	kit.abyss(HALF, DEPTH, false)
	_cliff(Rect2(-HALF, HALF * 2.0))
	var key := OmniLight3D.new()
	_key = key
	key.position = Vector3(MEDALLION_AT.x, KEY_HEIGHT, MEDALLION_AT.y)
	key.light_color = KEY_LIGHT
	key.light_energy = KEY_ENERGY
	key.omni_range = KEY_RANGE
	key.omni_attenuation = 1.0
	key.light_cull_mask = ArenaKit.WARM_MASK
	arena.add_child(key)
	# buttresses under the lip on the open sides, so the drop reads as built stone
	for i in 8:
		var t := -HALF.y + 2.0 + i * 3.8
		_under_of(m.box(Vector3(-HALF.x - 0.7, -3.5, t), Vector3(1.0, 6.0, 1.4)))
		_under_of(m.box(Vector3(HALF.x + 0.7, -3.5, t), Vector3(1.0, 6.0, 1.4)))
		var s := -HALF.x + 2.0 + i * 4.0
		if s > LANDING.y:
			_under_of(m.box(Vector3(s, -3.5, HALF.y + 0.7), Vector3(1.4, 6.0, 1.0)))


## The stone under the floor (ENV-HB3: its materials take the frame's dark petrol in the stylized look).
var _under: Array[Material] = []


func _under_of(mi: MeshInstance3D) -> void:
	if not _under.has(mi.material_override):
		_under.append(mi.material_override)


## The balustrades nearest the camera (the south edge, the landing's, the east one up to its standing stone): their own
## copy of the hall's stone, the same in the classic look, a darker petrol in the stylized one (ENV-HB3, STY_NEAR_STONE).
var _near_mat: ShaderMaterial
## The portal's spill down the steps (P2-A4 narrows it in the stylized look).
var _spill: SpotLight3D


func _near() -> ShaderMaterial:
	if _near_mat == null:
		_near_mat = m.stone(0.0).duplicate() as ShaderMaterial
	return _near_mat


## A block of platform: its walls dropping into the abyss under a floor (x, z rect), and a thick lip under its edge.
func _cliff(r: Rect2) -> void:
	var c := r.get_center()
	m.layers = ArenaKit.DEPTH_LAYER
	_under_of(m.box(Vector3(c.x, -DEPTH * 0.5 - 0.05, c.y), Vector3(r.size.x + 0.4, DEPTH, r.size.y + 0.4), 0.0, m.ashlar(-DEPTH, Color.WHITE * CLIFF_TINT)))
	m.layers = 1
	_under_of(m.box(Vector3(c.x, -0.4, c.y), Vector3(r.size.x + 1.0, 0.7, r.size.y + 1.0)))


# ---------- north: the dais and the portal ----------

func _dais() -> void:
	var steps_z := -HALF.y - STEP_RUN * DAIS_STEPS
	var mid := (FLIGHT.x + FLIGHT.y) * 0.5
	# the dais block (its top at DAIS_Y), from the top of the steps back behind the facade
	var back := FACADE_Z - 6.0
	m.block(Vector3((FACADE_X.x + FACADE_X.y) * 0.5, -DEPTH, (steps_z + back) * 0.5), Vector3(FACADE_X.y - FACADE_X.x, DEPTH + DAIS_Y, steps_z - back))
	kit.floor_plate(Vector3((FACADE_X.x + FACADE_X.y) * 0.5, DAIS_Y + 0.01, (steps_z + FACADE_Z) * 0.5), Vector2(FACADE_X.y - FACADE_X.x, steps_z - FACADE_Z))
	# the steps, and the stone cheeks beside them up to the dais' height
	m.stairs(Vector3(mid, 0, -HALF.y), Vector2(0, -1), FLIGHT.y - FLIGHT.x, DAIS_STEPS, DAIS_Y / DAIS_STEPS, STEP_RUN)
	var cheek_z := -HALF.y - STEP_RUN * DAIS_STEPS * 0.5
	m.block(Vector3((FACADE_X.x + FLIGHT.x) * 0.5, -0.4, cheek_z), Vector3(FLIGHT.x - FACADE_X.x, DAIS_Y + 0.4, STEP_RUN * DAIS_STEPS))
	m.block(Vector3((FLIGHT.y + FACADE_X.y) * 0.5, -0.4, cheek_z), Vector3(FACADE_X.y - FLIGHT.y, DAIS_Y + 0.4, STEP_RUN * DAIS_STEPS))


## The dais' statues, candles and props (a step of their own after _facade: build_steps, QA P1-1).
func _dais_props() -> void:
	var steps_z := -HALF.y - STEP_RUN * DAIS_STEPS
	# the hooded statues beside the portal, lit green by it; small plinths with candles at the top of the steps
	m.layers = ArenaKit.FACADE_LAYER
	kit.statue(Vector2(PORTAL_X - 4.6, FACADE_Z + 1.3), 0.25, PORTAL_STATUE, DAIS_Y, PORTAL_STATUE_VALUE, false)
	kit.statue(Vector2(PORTAL_X + 4.8, FACADE_Z + 1.3), -0.25, PORTAL_STATUE, DAIS_Y, PORTAL_STATUE_VALUE, false)
	m.layers = 1
	for px: float in [PORTAL_X - 2.6, PORTAL_X + 2.9]:
		m.block(Vector3(px, DAIS_Y, steps_z - 0.45), Vector3(0.8, 0.9, 0.8))
		_candles(Vector3(px, DAIS_Y + 0.9, steps_z - 0.45), 2, false)
	# pots, crates and candles at the west foot of the steps
	var foot := Vector3(FLIGHT.x - 1.6, 0, -HALF.y + 1.0)
	kit.crate(foot, 0.3, Vector3.ONE * 0.9)
	kit.crate(foot + Vector3(0.1, 0.75, 0), 0.1, Vector3.ONE * 0.7)
	kit.crate(foot + Vector3(1.1, 0, 0.2), -0.2, Vector3.ONE * 0.8)
	m.pot(foot + Vector3(-1.0, 0, -0.1), 1.0)
	m.pot(foot + Vector3(-0.5, 0, 0.6), 0.8)
	_candles(foot + Vector3(-1.7, 0, 0.3), 3)
	arena.boxes.append(Rect2(foot.x - 1.4, -HALF.y - 0.5, 3.4, 2.2))


## The gothic facade with the portal in it: a thick wall of big ashlar on a plinth, two cornices, buttresses with
## red banners, blind niches and tall windows; the portal a deep doorway: four pointed orders of voussoirs stepping in,
## slender shafts between them, a gable with pinnacles beside it, a dark tympanum with the lit diamond window over the
## lintel, dark teeth hanging against the green sheet of light deep inside. All of it on FACADE_LAYER (the portal's
## spill down the steps leaves it out, so only the portal's own light greens its inner faces).
func _facade() -> void:
	m.layers = ArenaKit.FACADE_LAYER
	var y := DAIS_Y
	var w := PORTAL_SIZE.x
	var h := PORTAL_SIZE.y
	var back := FACADE_Z - 1.6
	var mat := m.ashlar(y)
	var ring := PORTAL_ORDER_RING.x
	var deep := PORTAL_ORDER_RING.y
	var spans: Array[float] = []
	var fronts: Array[float] = []
	for k in PORTAL_ORDERS:
		spans.append(w + PORTAL_ORDER_STEP.x * 2.0 * k)
		fronts.append(FACADE_Z + PORTAL_PORCH + PORTAL_INNER_Z + PORTAL_ORDER_STEP.y * k)
	var outer := spans[PORTAL_ORDERS - 1] * 0.5 + ring
	var gap := outer - 0.1
	var top := FACADE_HEIGHT
	# the wall, with the portal's gap left free (left, right), and behind the orders a block above the opening
	var left := Vector2(FACADE_X.x, PORTAL_X - gap)
	var right := Vector2(PORTAL_X + gap, FACADE_X.y)
	m.block(Vector3((left.x + left.y) * 0.5, y, back), Vector3(left.y - left.x, top, 3.2), 0.0, mat)
	m.block(Vector3((right.x + right.y) * 0.5, y, back), Vector3(right.y - right.x, top, 3.2), 0.0, mat)
	var behind := fronts[0] - deep + 0.3
	m.block(Vector3(PORTAL_X, y + h, (behind + FACADE_Z - 3.2) * 0.5), Vector3(gap * 2.0, top - h, behind - FACADE_Z + 3.2), 0.0, mat)
	# the doorway's depth: dark stone behind the light, a threshold the light pools on
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.02, 0.06, 0.04)
	var sheet_z := FACADE_Z + PORTAL_PORCH - PORTAL_DEPTH
	m.block(Vector3(PORTAL_X, y - 0.2, sheet_z - 0.6), Vector3(w + 1.0, h + 1.0, 0.4), 0.0, dark)
	m.block(Vector3(PORTAL_X, y, (sheet_z + fronts[0]) * 0.5), Vector3(w + 0.2, 0.08, fronts[0] - sheet_z + 0.4))
	# the orders: jambs up to the springing line (the opening's top) and pointed arches of voussoirs
	var order := m.ashlar(y, PORTAL_ORDER_TINT)
	var apexes: Array[float] = []
	for k in PORTAL_ORDERS:
		var span: float = spans[k]
		var z: float = fronts[k] - deep * 0.5
		var jamb_deep := deep if k > 0 else fronts[0] - sheet_z + 0.3
		for sd: float in [-1.0, 1.0]:
			m.block(Vector3(PORTAL_X + sd * (span + ring) * 0.5, y, fronts[k] - jamb_deep * 0.5), Vector3(ring, h, jamb_deep), 0.0, order)
		apexes.append(m.voussoir_arch(Vector3(PORTAL_X, y, z), Vector2(0, 1), span, h, ring, deep, order, PORTAL_ARC))
		if k in COLONNETTE_ORDERS:
			for sd: float in [-1.0, 1.0]:
				var at := Vector3(PORTAL_X + sd * (span * 0.5 - COLONNETTE + 0.04), y, fronts[k - 1] + COLONNETTE - 0.02)
				m.block(at, Vector3(0.4, 0.25, 0.4), 0.0, order)
				m.shaft(at + Vector3(0, 0.25, 0), COLONNETTE, h - 0.55, order)
				m.block(at + Vector3(0, h - 0.3, 0), Vector3(0.42, 0.3, 0.42), 0.0, order)
	# the lintel and the tympanum set back over it, the lit diamond window in it
	var tymp := fronts[0] - TYMPANUM_BACK
	m.box(Vector3(PORTAL_X, y + h + PORTAL_LINTEL * 0.5, fronts[0] - deep * 0.5), Vector3(w + 0.1, PORTAL_LINTEL, deep), 0.0, order)
	m.block(Vector3(PORTAL_X, y + h, tymp - 0.2), Vector3(w + 0.4, apexes[0] - h, 0.4), 0.0, mat)
	var win_y := y + h + PORTAL_LINTEL + (apexes[0] - ring - h - PORTAL_LINTEL) * 0.36
	_portal_window(Vector3(PORTAL_X, win_y, tymp))
	# the dark teeth hanging from the lintel, in front of the sheet of light
	var teeth := m.stone(y, Color.WHITE * PENDANT_TINT)
	# the opening itself a pointed arch: its apex at the lintel, its arcs' centres on the springing line
	var spring := h * PORTAL_SPRING
	var arc := ((h - spring) * (h - spring) + w * w * 0.25) / w
	m.voussoir_arch(Vector3(PORTAL_X, y, sheet_z + 0.2 + PORTAL_INNER_RING.y * 0.5), Vector2(0, 1), w, spring, PORTAL_INNER_RING.x, PORTAL_INNER_RING.y,
		m.stone(y, Color.WHITE * PORTAL_INNER_TINT), arc / w)
	for p: Vector3 in PENDANTS:
		var px := absf(p.x) * w + arc - w * 0.5
		m.pendant(Vector3(PORTAL_X + p.x * w, y + spring + sqrt(maxf(0.0, arc * arc - px * px)) + 0.05, sheet_z + 0.35), p.y, p.z, teeth)
	var sheet := Vector2(w + 0.4, h + 0.2)
	kit.portal_glow(Vector3(PORTAL_X, y + h * 0.5, sheet_z), 0.0, sheet, Vector3(spring + (sheet.y - h) * 0.5, w, arc))
	# over the outer order: the spandrels in courses up to a gable (its sloped copings), the wall above it
	var slope := tan(deg_to_rad(GABLE_SLOPE))
	var oc := spans[PORTAL_ORDERS - 1]
	var r := oc * PORTAL_ARC
	var cx := r - oc * 0.5
	var band := 0.4
	var yy := h
	while yy < top - 0.01:
		var hb := minf(band, top - yy)
		var t := yy + hb - h
		var ext := 0.0
		if (r + ring) * (r + ring) - t * t > 0.0:
			ext = maxf(0.0, sqrt((r + ring) * (r + ring) - t * t) - cx)
		var gx := outer + 0.2 - (yy - h) / slope
		for sd: float in [-1.0, 1.0]:
			var a := ext - 0.05
			var b := minf(gx, gap + 0.2)
			if b > a + 0.05:
				m.box(Vector3(PORTAL_X + sd * (a + b) * 0.5, y + yy + hb * 0.5, FACADE_Z + PORTAL_PORCH - 0.85), Vector3(b - a, hb, 2.0), 0.0, mat, false)
			var c := maxf(gx, ext - 0.05)
			if gap + 0.2 > c + 0.05:
				m.box(Vector3(PORTAL_X + sd * (c + gap + 0.2) * 0.5, y + yy + hb * 0.5, FACADE_Z - 1.0), Vector3(gap + 0.2 - c, hb, 2.0), 0.0, mat, false)
		yy += hb
	var gable_len := (outer + 0.2) / cos(deg_to_rad(GABLE_SLOPE))
	for sd: float in [-1.0, 1.0]:
		var mid := Vector3(PORTAL_X + sd * (outer + 0.2) * 0.5, y + h + (outer + 0.2) * slope * 0.5, FACADE_Z + PORTAL_PORCH + 0.15 + GABLE.y - 0.3)
		var cop := m.box(mid, Vector3(gable_len + GABLE.x, GABLE.x, 0.6), 0.0, order, false)
		cop.basis = Basis(Vector3.BACK, -sd * deg_to_rad(GABLE_SLOPE))
	# plinth and cornices along the wall, broken by the portal
	for side: Vector2 in [Vector2(FACADE_X.x, PORTAL_X - outer - 0.1), Vector2(PORTAL_X + outer + 0.1, FACADE_X.y)]:
		m.block(Vector3((side.x + side.y) * 0.5, y, FACADE_Z + PLINTH.y * 0.5 - 0.05), Vector3(side.y - side.x, PLINTH.x, PLINTH.y + 0.1), 0.0, mat, false)
	for ch: float in CORNICES:
		var half := minf(outer + 0.1, outer + 0.2 - (ch - h) / slope + GABLE.x) if ch > h else outer + 0.1
		for side: Vector2 in [Vector2(FACADE_X.x, PORTAL_X - half), Vector2(PORTAL_X + half, FACADE_X.y)]:
			m.box(Vector3((side.x + side.y) * 0.5, y + ch, FACADE_Z + CORNICE.y * 0.5 - 0.05), Vector3(side.y - side.x, CORNICE.x, CORNICE.y + 0.1), 0.0, mat, false)
	# buttresses: piers standing out of the wall; the two beside the portal end in pinnacles, the rest in points
	for bx: float in BUTTRESSES:
		m.block(Vector3(bx, y, FACADE_Z + 0.2), Vector3(1.3, top - 1.5, 1.4), 0.0, mat)
		m.block(Vector3(bx, y, FACADE_Z + 0.6), Vector3(1.5, 2.2, 1.0), 0.0, mat)
		m.point(Vector3(bx, y + 2.2, FACADE_Z + 0.6), 1.5, 0.5, 0.0, 0.3, mat)
		if absf(bx - PORTAL_X) < 6.0:
			m.pinnacle(Vector3(bx, y + top - 1.5, FACADE_Z + 0.2), PINNACLE.x, PINNACLE.y, mat)
		else:
			m.point(Vector3(bx, y + top - 1.5, FACADE_Z + 0.2), 1.3, 1.2)
	m.layers = 1
	for b: Vector4 in BANNERS:
		kit.banner(Vector3(b.x, y + b.y, FACADE_Z + BANNER_OUT), 0.0, Vector2(b.z, b.w), ArenaKit.FACADE_LAYER, ArenaKit.Emblem.LION)
	m.layers = ArenaKit.FACADE_LAYER
	# blind pointed niches low between the buttresses, tall windows over them, both dark and deep with a stone frame
	var hollow := m.stone(y, Color.WHITE * NICHE_DARK)
	for wx: float in BAYS:
		_niche(Vector3(wx, y + NICHE.z, FACADE_Z), NICHE.x, NICHE.y, mat, hollow, false)
		_niche(Vector3(wx, y + HIGH_WINDOW.z, FACADE_Z), HIGH_WINDOW.x, HIGH_WINDOW.y, mat, hollow, true)
	# the portal's light spilling down the steps and over the wet floor in front of them (not on the facade)
	m.layers = 1
	var spill := SpotLight3D.new()
	_spill = spill
	arena.add_child(spill)
	spill.look_at_from_position(Vector3(PORTAL_X, y + h * 0.6, FACADE_Z + PORTAL_PORCH - 0.5), Vector3(PORTAL_X - 0.5, 0, -HALF.y + SPILL_AIM))
	spill.light_color = SPILL_COLOR
	spill.light_energy = SPILL.x
	spill.spot_range = SPILL.y
	spill.spot_angle = SPILL.z
	spill.light_cull_mask = ~(Arena.CROWD_LAYER | ArenaKit.FACADE_LAYER)
	# it is the portal's light: red when Morvath's doors open, the reward's colour when the way is lit
	kit.tint_with_portal(kit.portals.size() - 1, spill)
	# a cold light from the hall on the facade alone: its stone and statues read dark teal, never black
	var fill := SpotLight3D.new()
	arena.add_child(fill)
	fill.look_at_from_position(Vector3(PORTAL_X + FACADE_FILL_FROM.x, FACADE_FILL_FROM.y, FACADE_Z + FACADE_FILL_FROM.z),
		Vector3(PORTAL_X + FACADE_FILL_AIM, y + 4.0, FACADE_Z))
	fill.light_color = FACADE_FILL
	fill.light_energy = FACADE_FILL_ENERGY
	fill.spot_range = 40.0
	fill.spot_angle = FACADE_FILL_CONE
	fill.spot_attenuation = 0.5
	fill.light_cull_mask = ArenaKit.FACADE_LAYER


## A dark pointed niche in the facade's face: its foot (middle, on the wall's front), width and height; a stone frame
## round it and, if mullion, a slender upright dividing it.
func _niche(foot: Vector3, width: float, height: float, mat: Material, hollow: Material, mullion: bool) -> void:
	m.box(foot + Vector3(0, (height - width * 0.4) * 0.5, -0.02), Vector3(width, height - width * 0.4, 0.1), 0.0, hollow, false)
	var head := m.box(foot + Vector3(0, height - width * 0.4, -0.02), Vector3(width * 0.7071, width * 0.7071, 0.1), 0.0, hollow, false)
	head.basis = Basis.from_scale(Vector3(1.0, 1.1, 1.0)) * Basis(Vector3.BACK, PI * 0.25)
	m.pointed_arch(foot + Vector3(0, 0, 0.08), Vector2(0, 1), width, height, 0.16, 0.22, mat)
	m.box(foot + Vector3(0, 0.08, 0.1), Vector3(width + 0.5, 0.16, 0.3), 0.0, mat)
	if mullion:
		m.box(foot + Vector3(0, (height - width * 0.4) * 0.5, 0.05), Vector3(MULLION, height - width * 0.4, 0.12), 0.0, mat)


## The lit diamond window in the tympanum: green glass, a frame of four bevelled bars, a thin stone cross.
func _portal_window(at: Vector3) -> void:
	var win := MeshInstance3D.new()
	var wq := QuadMesh.new()
	wq.size = Vector2.ONE * 0.7071
	win.mesh = wq
	var wm := StandardMaterial3D.new()
	wm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	wm.albedo_color = ArenaKit.PORTAL_SHEET * PORTAL_WINDOW_GLOW
	win.material_override = wm
	win.transform = Transform3D(Basis.from_scale(Vector3(PORTAL_WINDOW.x, PORTAL_WINDOW.y, 1.0)) * Basis(Vector3.BACK, PI * 0.25), at + Vector3(0, 0, 0.03))
	arena.add_child(win)
	var frame := m.ashlar(DAIS_Y, PORTAL_ORDER_TINT)
	var half := PORTAL_WINDOW * 0.5
	var edge := sqrt(half.x * half.x + half.y * half.y)
	var tilt := atan2(half.y, half.x)
	for sx: float in [-1.0, 1.0]:
		for sy: float in [-1.0, 1.0]:
			var out := Vector3(sx * half.y, sy * half.x, 0).normalized() * PORTAL_WINDOW_FRAME * 0.5
			var bar := m.box(at + Vector3(sx * half.x * 0.5, sy * half.y * 0.5, 0.08) + out, Vector3(edge + PORTAL_WINDOW_FRAME, PORTAL_WINDOW_FRAME, 0.16), 0.0, frame, false)
			bar.basis = Basis(Vector3.BACK, -sx * sy * tilt)
	m.box(at + Vector3(0, 0, 0.06), Vector3(PORTAL_WINDOW_CROSS, PORTAL_WINDOW.y, 0.06), 0.0, frame, false)
	m.box(at + Vector3(0, 0, 0.06), Vector3(PORTAL_WINDOW.x, PORTAL_WINDOW_CROSS, 0.06), 0.0, frame, false)


## North-west: the balustrade on the abyss, and out beyond it a pier with a fire bowl and a hooded statue.
func _north_west() -> void:
	var z := -HALF.y + 0.1
	m.balustrade(Vector3(-HALF.x, 0, z), Vector3(FACADE_X.x, 0, z))
	m.block(Vector3(NW_PIER.x, -DEPTH, NW_PIER.y - 1.0), Vector3(3.6, DEPTH, 6.0))
	kit.brazier(NW_PIER, 0.0, false)
	m.block(Vector3(NW_PIER.x, 0, NW_PIER.y - 2.4), Vector3(1.8, 0.6, 1.8))
	m.layers = ArenaKit.STATUE_LAYER
	kit.statue(Vector2(NW_PIER.x, NW_PIER.y - 2.4), 0.5, NW_STATUE.x, 0.6, NW_STATUE.y, false)
	m.layers = 1
	kit.statue_glow(Vector3(NW_PIER.x, 1.8, NW_PIER.y), Vector3(NW_PIER.x, 0.6 + NW_STATUE.x * 0.5, NW_PIER.y - 2.4), NW_GLOW.x, NW_GLOW.y, NW_GLOW.z)


## The north-west's candles, pots and crates (a step of their own: build_steps, QA P1-1).
func _north_west_props() -> void:
	var z := -HALF.y + 0.1
	_candles(Vector3(-9.0, 0, z + 0.9), 5)
	m.pot(Vector3(-11.6, 0, z + 0.8), 1.0)
	m.pot(Vector3(-10.9, 0, z + 1.2), 0.8)
	# at the west foot of the dais (the picture's: low crates, a pot and candles; nothing here blocks the way)
	var nook := Vector3(FACADE_X.x + 0.8, 0, z + 0.8)
	kit.crate(nook + Vector3(0.35, 0, -0.1), 0.4, Vector3(0.9, 0.55, 0.9))
	kit.crate(nook + Vector3(-0.55, 0, 0.35), -0.15, Vector3(0.75, 0.45, 0.75))
	m.pot(nook + Vector3(0.5, 0, 0.75), 0.75)
	_candles(nook + Vector3(-0.3, 0, 1.0), 3, false, false, true)


# ---------- west: the long balustrade and the giant in the abyss ----------

func _west() -> void:
	var x := -HALF.x + 0.1
	m.balustrade(Vector3(x, 0, -HALF.y), Vector3(x, 0, LANDING_END))
	# the giant: a pier out to its fire bowl, a tower of stone out of the depths, the hooded figure on it looking
	# over the hall
	var tower_top := GIANT_FOOT - GIANT.z * ArenaKit.STATUE_PLINTH
	# the pile and the giant on the depths' layer: the fires of the hall leave them dark, only the spot below warms
	# the side of the giant turned to its bowl
	m.layers = ArenaKit.DEPTH_LAYER
	var rough := m.stone(PILE_FOOT, Color.WHITE * PILE_TINT)
	for i in PILE_COURSES.size():
		var top: float = PILE_COURSES[i][0]
		var bottom: float = PILE_COURSES[i + 1][0] if i + 1 < PILE_COURSES.size() else PILE_FOOT
		for b: Vector3 in PILE_COURSES[i][1]:
			m.block(Vector3(b.x, bottom, GIANT.y), Vector3(b.y, top - bottom, b.z), 0.0, rough)
	m.block(Vector3(-24.9, -DEPTH, GIANT.y), Vector3(6.4, DEPTH + PILE_FOOT, 4.2), 0.0, rough)
	m.block(Vector3(GIANT_BOWL.x, PILE_COURSES[0][0], GIANT_BOWL.y), Vector3(2.0, -PILE_COURSES[0][0], 2.0), 0.0, rough)
	m.layers = ArenaKit.STATUE_LAYER
	kit.statue(Vector2(GIANT.x, GIANT.y), PI * 0.5, GIANT.z, tower_top, GIANT_VALUE, false)
	m.layers = 1
	kit.brazier(GIANT_BOWL, 0.0, false, 5.5)
	kit.statue_glow(Vector3(GIANT_BOWL.x + 0.5, 2.0, GIANT_BOWL.y), Vector3(GIANT.x, GIANT_FOOT + GIANT.z * GIANT_UPLIGHT_AIM, GIANT.y),
		GIANT_UPLIGHT, GIANT_UPLIGHT_RANGE, GIANT_UPLIGHT_CONE)
	var between := (Vector3(GIANT.x, GIANT_FOOT + GIANT.z * 0.5, GIANT.y) + Vector3(NW_PIER.x, NW_STATUE.x * 0.5, NW_PIER.y - 2.4)) * 0.5
	kit.statue_glow(STATUE_FILL_FROM, between, STATUE_FILL_ENERGY, STATUE_FILL_RANGE, STATUE_FILL_CONE, FACADE_FILL, 0.5)
	# candles and clay pots along the balustrade (the picture's groups; VX-13: the one at z 2.2 burnt out), a small altar
	# of a crate with candles and two pots on it
	kit.crate(Vector3(x + 1.0, 0, -10.4), 0.2, Vector3(1.3, 0.8, 1.3))
	_candles(Vector3(x + 1.0, 0.8, -10.4), 4, false, false, true)
	m.pot(Vector3(x + 1.0, 0, -11.9), 1.0)
	m.pot(Vector3(x + 1.6, 0, -12.5), 0.8)
	_candles(Vector3(x + 1.2, 0, -6.3), 5)
	m.pot(Vector3(x + 0.9, 0, 0.6), 1.05)
	m.pot(Vector3(x + 1.5, 0, 1.3), 0.85)
	_candles(Vector3(x + 1.3, 0, 2.2), 4, false, false, true)
	_candles(Vector3(x + 1.2, 0, 7.1), 6)
	m.pot(Vector3(x + 0.9, 0, 9.4), 0.9)
	_candles(Vector3(x + 0.9, 0, 12.4), 3, true, false, true)


# ---------- south-west: the landing and the way in ----------

func _landing() -> void:
	var r := Rect2(LANDING.x, HALF.y, LANDING.y - LANDING.x, LANDING_END - HALF.y)
	kit.floor_plate(Vector3(r.get_center().x, 0, r.get_center().y + 0.3), r.size + Vector2(0.6, 0.6))
	_cliff(r)
	var z := LANDING_END - 0.1
	m.balustrade(Vector3(LANDING.x, 0, z), Vector3(WAY_IN.x, 0, z), true, _near())
	m.balustrade(Vector3(WAY_IN.y, 0, z), Vector3(LANDING.y, 0, z), true, _near())
	m.balustrade(Vector3(LANDING.y - 0.1, 0, HALF.y + 0.8), Vector3(LANDING.y - 0.1, 0, z), false, _near())
	_stairs_down(Vector3((WAY_IN.x + WAY_IN.y) * 0.5, 0, LANDING_END), Vector2(0, 1), WAY_IN.y - WAY_IN.x)
	# the standing stone in the middle of the south edge, where the landing meets the hall
	m.obelisk(Vector3(SOUTH_STONE.x, 0, SOUTH_STONE.y), OBELISK_SOUTH_HEIGHT, OBELISK_SOUTH, Vector2(1, 1).normalized())
	kit.circles.append(Vector3(SOUTH_STONE.x, SOUTH_STONE.y, OBELISK_SOUTH * 0.68))
	_candles(Vector3(SOUTH_STONE.x + 2.4, 0, HALF.y - 2.0), 7, false, true, true)
	m.pot(Vector3(SOUTH_STONE.x + 3.6, 0, HALF.y - 0.8), 0.9)
	_candles(Vector3(LANDING.x + 2.4, 0, HALF.y + 0.4), 4, false, false, true)


# ---------- south and east ----------

func _south(stairs_down: bool) -> void:
	var z := HALF.y - 0.1
	var a := Vector3(SOUTH_STONE.x + 1.0, 0, z)
	var b := Vector3(HALF.x, 0, z)
	if not stairs_down:
		m.balustrade(a, b, true, _near())
		return
	m.balustrade(a, Vector3(SOUTH_GAP.x, 0, z), true, _near())
	m.balustrade(Vector3(SOUTH_GAP.y, 0, z), b, true, _near())
	_stairs_down(Vector3((SOUTH_GAP.x + SOUTH_GAP.y) * 0.5, 0, HALF.y), Vector2(0, 1), SOUTH_GAP.y - SOUTH_GAP.x)


func _east(stairs_down: bool) -> void:
	var x := HALF.x - 0.1
	# from the south-east corner up to the standing stone, its fire bowl and clutter on the inside
	m.balustrade(Vector3(x, 0, HALF.y), Vector3(x, 0, EAST_STONE.y + 1.2), true, _near())
	m.obelisk(Vector3(EAST_STONE.x, 0, EAST_STONE.y), 5.6, OBELISK_EAST, Vector2(-1, 1).normalized())
	kit.circles.append(Vector3(EAST_STONE.x - 0.3, EAST_STONE.y, OBELISK_EAST * 0.62))
	kit.brazier(Vector2(x - 1.7, EAST_STONE.y + 0.6))
	_field_crate(Vector3(x - 1.9, 0, EAST_STONE.y + 2.6), 0.4, Vector3.ONE * 0.9, 1.0)
	_candles(Vector3(x - 2.4, 0, EAST_STONE.y + 1.8), 4, false, false, true)
	# the clutter by the stone stops the way as it reads (C18, ENV P2-6: a phantom of 2.5 m² at x 13 to 15)
	kit.circles.append(Vector3(x - 2.4, EAST_STONE.y + 1.8, EAST_CLUTTER))
	# fallen stones of the hall's own masonry (C18, ENV P2-6: the KayKit rubble was the one kit piece left in sight)
	_rubble(Vector2(x - 2.4, EAST_STONE.y + 4.2))
	_rubble(Vector2(x - 1.3, EAST_STONE.y + 4.8))
	# north of the stone: the stairs down out of the hall (or a plain balustrade), a fire bowl on a pier past them
	if stairs_down:
		m.balustrade(Vector3(x, 0, EAST_STONE.y - 1.0), Vector3(x, 0, EAST_GAP.y))
		_stairs_down(Vector3(HALF.x, 0, (EAST_GAP.x + EAST_GAP.y) * 0.5), Vector2(1, 0), EAST_GAP.y - EAST_GAP.x)
	else:
		m.balustrade(Vector3(x, 0, EAST_STONE.y - 1.0), Vector3(x, 0, EAST_GAP.x))
	var pier := Vector2(HALF.x + 1.0, EAST_GAP.x - 1.2)
	m.block(Vector3(pier.x, -DEPTH, pier.y), Vector3(2.0, DEPTH + 0.5, 2.0))
	kit.brazier(pier, 0.5, false)
	m.balustrade(Vector3(x, 0, EAST_GAP.x), Vector3(x, 0, -HALF.y))
	m.pot(Vector3(x - 0.9, 0, -7.4), 0.9)
	_candles(Vector3(x - 0.9, 0, -8.6), 3, false, false, true)


## A flight of stairs going down out of the hall from its edge at `edge`, along `out`, `width` wide, with posts at its
## sides and a landing at the bottom over the abyss.
func _stairs_down(edge: Vector3, out: Vector2, width: float) -> void:
	var o := Vector3(out.x, 0, out.y)
	var steps := 7
	var rise := 0.38
	var run := 0.55
	var bottom := edge + o * (steps * run) + Vector3(0, -steps * rise, 0)
	m.stairs(bottom, -out, width, steps, rise, run)
	var across := out.y != 0.0
	# the pier under the landing drops into the abyss with the cliffs (lit violet from below, not by the fires)
	m.layers = ArenaKit.DEPTH_LAYER
	var cliff := m.ashlar(-DEPTH, Color.WHITE * CLIFF_TINT)
	m.box(bottom + o * 2.0 + Vector3(0, -DEPTH * 0.5, 0), Vector3(width if across else 4.0, DEPTH, 4.0 if across else width), 0.0, cliff)
	# the flight is carried by a pointed arch between the cliff and that pier, one ring under each of its sides
	var run_out := steps * run
	var arc := run_out * STAIR_ARCH.z
	var spring := bottom.y - STAIR_UNDER - STAIR_ARCH.x - sqrt(arc * arc - (arc - run_out * 0.5) * (arc - run_out * 0.5))
	var mid := edge + o * (run_out * 0.5)
	for s: float in [-1.0, 1.0]:
		var face := Vector3(-out.y, 0, out.x) * s
		m.arch_ring(Vector3(mid.x, spring, mid.z) + face * (width - STAIR_ARCH.y) * 0.5, Vector2(face.x, face.z), run_out, STAIR_ARCH.x, STAIR_ARCH.y, cliff, STAIR_ARCH.z)
	m.layers = 1
	var side := Vector3(-out.y, 0, out.x)
	for s in [-1.0, 1.0]:
		m.post(edge + side * (width * 0.5 + 0.3) * s)
		m.post(bottom + side * (width * 0.5 + 0.3) * s)


# ---------- the depths ----------

## Far below and around, all in the unlit stone of the depths (dark against the teal mist). Near, three uneven masses:
## the west bridge running out from the giant's tower (a tower of blocks and a loose block on it, narrow arches and
## the lit window under it), the wide gate behind the north-west corner (a pointed arch with violet in it) and the
## iron pylon of the chains standing on it. Far, three cards of painted ruins sliding against each other, banks of
## pale mist between them, a lighter veil behind. Violet light rises only low down: in the arches, under the bridge,
## at the foot of the sides.
func _depths() -> void:
	m.layers = ArenaKit.DEPTH_LAYER
	var near := m.depth_stone(Game.FOG, NEAR_FADE)
	# everything stands across the showcase camera's view (arches face it), left of the hall and behind it
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	var eye := SHOWCASE + Feel.cam_offset_of(Game.SHOWCASE_DISTANCE, Feel.live().cam_pitch, Feel.live().cam_yaw)
	var ahead := Vector3(-sin(yaw), 0, -cos(yaw))
	var right := Vector3(cos(yaw), 0, -sin(yaw))
	var facing := Vector2(-ahead.x, -ahead.z)
	# the place d meters ahead of the camera, l meters right of its view's middle, at height y
	var at := func(d: float, l: float, y: float) -> Vector3:
		return Vector3(eye.x, y, eye.z) + ahead * d + right * l
	_bridge(at, yaw, facing, near)
	_gate(at, yaw, facing, near)
	_pylon(m.depth_stone(Game.FOG, PYLON_FADE, PYLON_TINT))
	# arches to the north, behind the facade
	var far := m.depth_stone(Game.FOG)
	for i in 4:
		var x := -10.0 + i * 9.0
		m.box(Vector3(x, -10.0, -40.0), Vector3(2.4, 40.0, 2.4), 0.0, far)
		if i < 3:
			m.pointed_arch(Vector3(x + 4.5, 2.0, -40.0), Vector2(0, 1), 6.6, 8.0, 1.0, 1.8, far)
	for g: Vector4 in RUIN_GROUPS:
		_ruins(Vector3(g.x, g.z, g.y), g.w, near)
		var mid := Vector3(g.x - RUIN_MIST.x, g.z - RUIN_MIST.y, g.y - RUIN_MIST.x) + Basis(Vector3.UP, g.w) * Vector3(0, 0, RUIN_PILLAR.x * 0.5)
		kit.mist_bank(mid, RUIN_MIST_SIZE, Game.FOG * VEIL_LIGHT, RUIN_MIST_ALPHA, 0.0, RUIN_MIST_BANDS)
		_note_bank(1.0)
	m.layers = 1
	var wall: Vector3 = at.call(BRIDGE_DIST, LANTERN_LAT * BRIDGE_DIST, LANTERN_Y)
	_lantern(wall - ahead * (BRIDGE_DECK.z * 0.4 + 0.05), yaw, near)
	var giant_top := Vector3(GIANT.x, GIANT_FOOT + GIANT.z * 0.95, GIANT.y)
	var hook := TOWER + Vector3(0, TOWER_ARM.x, 0)
	# the great chains of the picture's top: from the giant across to the pylon and on to the facade, and one from the
	# giant out over the abyss
	kit.chain(giant_top + Vector3(0, -1.0, 0), hook + Vector3(0, 0.5, 0), 2.5, 2.2)
	kit.chain(hook + Vector3(0, -0.5, 0), Vector3(FACADE_X.x + 0.6, DAIS_Y + FACADE_HEIGHT - 2.0, FACADE_Z), 3.0, 2.2)
	kit.chain(giant_top + Vector3(0, -2.0, 0), Vector3(-6.0, 9.0, -26.0), 3.5, 2.2)
	kit.chain(giant_top + Vector3(0, -1.5, 0), Vector3(-40.0, 8.0, 14.0), 4.0, 2.2)
	# violet from far below, only at the sides (west and east of the frame) and low, lighting only the depths
	for p: Vector3 in [Vector3(-HALF.x - 6.0, ABYSS_LIGHT_Y, 2.0), Vector3(-HALF.x - 14.0, ABYSS_LIGHT_Y, -16.0), Vector3(-28.0, ABYSS_LIGHT_Y, 10.0),
			Vector3(HALF.x + 6.0, ABYSS_LIGHT_Y, 6.0), Vector3(HALF.x + 6.0, ABYSS_LIGHT_Y, -8.0)]:
		var l := OmniLight3D.new()
		l.position = p
		l.light_color = ABYSS_LIGHT
		l.light_energy = ABYSS_LIGHT_ENERGY
		l.omni_range = 22.0
		l.omni_attenuation = 1.1
		l.light_cull_mask = ArenaKit.DEPTH_LAYER
		VisualProfile.vary(l, {&"light_color": STY_ABYSS_LIGHT})
		arena.add_child(l)
	# the glow itself: inside the gate's arches, under the bridge and low at the west side (the masses stand dark
	# against it), and at the east side; on desktop a violet fog filling the sides low down
	for g: Array in GLOW_WEST:
		kit.abyss_glow(at.call(g[0], g[1], g[2]), Vector2(g[3], g[4]), yaw, ArenaKit.ABYSS_GLOW_ENERGY * float(g[5]), Vector3(g[6], g[7], g[8]))
	for g: Vector3 in [Vector3(HALF.x + 3.0, GLOW_FOOT, -12.0), Vector3(HALF.x + 4.0, GLOW_FOOT, -22.0), Vector3(8.0, GLOW_FOOT, HALF.y + 5.0),
			Vector3(HALF.x + 2.5, GLOW_FOOT, 9.0), Vector3(HALF.x + 2.5, GLOW_FOOT, 15.5)]:
		kit.abyss_glow(g, Vector2(16.0, GLOW_TOP - GLOW_FOOT), yaw, ArenaKit.ABYSS_GLOW_ENERGY * GLOW_EAST)
	# and low at the foot of the east cliff, beside the stairs down (the picture's violet at the bottom right)
	kit.abyss_glow(EAST_FOOT_GLOW, EAST_FOOT_GLOW_SIZE, yaw, ArenaKit.ABYSS_GLOW_ENERGY * EAST_FOOT_GLOW_ENERGY)
	# the far ruins, the mist they sink into the colour of the veil over the background
	var mist := Game.FOG * VEIL_LIGHT
	for i in RUIN_DIST.size():
		var d: float = RUIN_DIST[i]
		var last := i == RUIN_DIST.size() - 1
		var patches: Array[Vector4] = []
		if last:
			for p: Vector4 in VEIL_PATCHES:
				patches.append(p + Vector4(RUIN_LEFT * d, 0, 0, 0))
		kit.ruin_card(at.call(d, -RUIN_LEFT * d, RUIN_TOP - RUIN_SIZE.y * 0.5), RUIN_SIZE, yaw, mist, RUIN_HAZE[i], RUIN_COLUMN[i], float(i) * 17.0 + 3.0,
			RUIN_TOPS[i], RUIN_SINK[i], RUIN_ROOF if last else Vector4.ZERO, patches)
	# banks of pale mist between the planes, so each stands out against the one behind
	for i in MIST_BANKS.size():
		var md: float = MIST_BANKS[i]
		kit.mist_bank(at.call(md, -0.2 * md, MIST_YS[i]), MIST_SIZE, mist, MIST_ALPHAS[i])
		_note_bank(1.0 - float(i) / float(MIST_BANKS.size() - 1))
	kit.abyss_fog(Vector3(-HALF.x - 14.0, -12.0, 0.0), Vector3(24.0, 10.0, 50.0))
	kit.abyss_fog(Vector3(HALF.x + 10.0, -12.0, 0.0), Vector3(16.0, 10.0, 40.0))


## The mist banks the depths built (the last card of the kit), with how near they are (1 the nearest plane, 0 the farthest),
## for the stylized look's brush (_elun).
var _banks: Array[MeshInstance3D] = []


func _note_bank(near: float) -> void:
	var card := kit.root.get_child(kit.root.get_child_count() - 1) as MeshInstance3D
	card.set_meta(&"near", near)
	_banks.append(card)


## The west bridge (BRIDGE_*): a deck out of the picture's left edge, on it a tower of three blocks, a loose block and
## stumps of a parapet; under it narrow pointed arches, the wall of the lit window and a wider arch.
func _bridge(at: Callable, yaw: float, facing: Vector2, mat: Material) -> void:
	var d := BRIDGE_DIST
	var deck_y := BRIDGE_DECK.x - BRIDGE_DECK.y * 0.5
	var under := BRIDGE_DECK.x - BRIDGE_DECK.y
	var deep := BRIDGE_DECK.z
	m.box(at.call(d, (BRIDGE.x + BRIDGE.y) * 0.5, deck_y), Vector3(BRIDGE.y - BRIDGE.x, BRIDGE_DECK.y, deep), yaw, mat, false)
	# a string course under the deck's edge
	m.box(at.call(d, (BRIDGE.x + BRIDGE.y) * 0.5, under - 0.15), Vector3(BRIDGE.y - BRIDGE.x, 0.3, deep + 0.3), yaw, mat, false)
	var y := BRIDGE_DECK.x
	for b: Vector2 in BRIDGE_TOWER_BLOCKS:
		m.box(at.call(d, BRIDGE_TOWER.x, y + b.y * 0.5), Vector3(BRIDGE_TOWER.y * b.x, b.y - 0.05, BRIDGE_TOWER.y * b.x * 0.9), yaw, mat)
		y += b.y
	var cube := m.box(at.call(d - 0.3, BRIDGE_CUBE.x, BRIDGE_DECK.x + BRIDGE_CUBE.z * 0.5), Vector3(BRIDGE_CUBE.y, BRIDGE_CUBE.z, BRIDGE_CUBE.y), yaw + 0.3, mat)
	cube.rotate_object_local(Vector3.BACK, 0.05)
	for p: Vector2 in BRIDGE_PARAPET:
		m.box(at.call(d - deep * 0.5 + 0.25, p.x, BRIDGE_DECK.x + BRIDGE_PARAPET_HEIGHT * 0.5), Vector3(p.y, BRIDGE_PARAPET_HEIGHT, 0.4), yaw, mat)
	# piers under it and a pointed arch in each gap
	var prev := Vector2.ZERO
	for i in BRIDGE_PIERS.size():
		var p := BRIDGE_PIERS[i]
		_wall(at.call(d, p.x, 0.0), p.y, under, deep * 0.8, yaw, mat)
		# string courses at uneven heights (each pier its own), some only a stub on one side, and a wider footing
		var cy := under
		for k in PIER_COURSES_DOWN:
			var h := fposmod(sin(float(i) * 12.9898 + float(k) * 78.233) * 43758.5453, 1.0)
			cy -= lerpf(PIER_COURSES.x, PIER_COURSES.y, h)
			var lean := 0.0 if h < 0.4 else (PIER_COURSE.x if h < 0.7 else -PIER_COURSE.x)
			m.box(at.call(d, p.x + lean * 0.5, cy), Vector3(p.y + PIER_COURSE.x * 2.0 - absf(lean), PIER_COURSE.y, deep * 0.8 + PIER_COURSE.x), yaw, mat, false)
		_wall(at.call(d, p.x, 0.0), p.y + PIER_FOOTING.y * 2.0, PIER_FOOTING.x, deep * 0.8 + PIER_FOOTING.y, yaw, mat)
		if prev != Vector2.ZERO:
			var span := (prev.x - prev.y * 0.5) - (p.x + p.y * 0.5)
			var mid := ((prev.x - prev.y * 0.5) + (p.x + p.y * 0.5)) * 0.5
			var rise := sqrt(0.75 * 0.75 - 0.25 * 0.25) * span
			m.arch_ring(at.call(d, mid, under - BRIDGE_ARCH.x - rise - BRIDGE_ARCH.y), facing, span, BRIDGE_ARCH.y + BRIDGE_ARCH.x + 0.3, deep * 0.7, mat, 0.75)
		prev = p
	# broken shafts standing free in front of the widest gaps, dark against the violet
	for sh: Vector3 in BRIDGE_SHAFTS:
		_wall(at.call(d - BRIDGE_SHAFT_AHEAD, sh.x, 0.0), sh.y, sh.z, sh.y, yaw, mat)
		m.box(at.call(d - BRIDGE_SHAFT_AHEAD, sh.x, sh.z - 1.3), Vector3(sh.y + 0.3, 0.3, sh.y + 0.3), yaw, mat, false)


## The middle gate (GATE_*): two uneven masses, a pointed arch between them under a ring of stone and a lintel, uneven
## merlons on top (one corner broken off), a low wing with a lancet to the west.
func _gate(at: Callable, yaw: float, facing: Vector2, mat: Material) -> void:
	var d := GATE_DIST
	var a := GATE_ARCH
	var lintel := 1.0
	var open := Vector2(a.x - a.y * 0.5, a.x + a.y * 0.5)
	_wall(at.call(d, (GATE.x + open.x) * 0.5, 0.0), open.x - GATE.x, GATE_TOP, GATE_DEPTH, yaw, mat)
	_wall(at.call(d, (open.y + GATE.y) * 0.5, 0.0), GATE.y - open.y, GATE_TOP, GATE_DEPTH, yaw, mat)
	m.arch_ring(at.call(d, a.x, a.z), facing, a.y, GATE_RING, GATE_DEPTH * 0.9, mat, a.w)
	m.box(at.call(d, a.x, GATE_TOP - lintel * 0.5), Vector3(a.y + 0.2, lintel, GATE_DEPTH), yaw, mat, false)
	# the spandrels: the corners between the ring, the masses and the lintel
	var corner := Vector2(a.y * GATE_SPANDREL.x, GATE_SPANDREL.y)
	for s: float in [-1.0, 1.0]:
		m.box(at.call(d, a.x + s * (a.y * 0.5 - corner.x * 0.5), GATE_TOP - lintel - corner.y * 0.5 + 0.1), Vector3(corner.x, corner.y, GATE_DEPTH * 0.9), yaw, mat, false)
	for b: Vector3 in GATE_MERLONS:
		m.box(at.call(d, b.x, GATE_TOP + b.z * 0.5), Vector3(b.y, b.z, GATE_DEPTH * 0.8), yaw, mat)
	# the broken corner: a block fallen askew on the east end
	var chip := m.box(at.call(d - 0.2, GATE.y - 0.5, GATE_TOP + 0.25), Vector3(1.6, 0.9, 1.6), yaw, mat)
	chip.rotate_object_local(Vector3.BACK, -0.45)
	# the dark of the passage behind the arches
	var dark := StandardMaterial3D.new()
	dark.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dark.albedo_color = GATE_PASSAGE
	dark.disable_fog = true
	m.box(at.call(d + GATE_PASSAGE_BACK, a.x, GATE_TOP - GATE_PASSAGE_UNDER - 20.0), Vector3(a.y + 2.0, 40.0, 0.4), yaw, dark, false)
	for s: Vector2 in GATE_SHAFTS:
		m.box(at.call(d + GATE_SHAFT_BACK, a.x + s.x, GATE_TOP - GATE_SHAFT_UNDER - 20.0), Vector3(s.y, 40.0, s.y), yaw, dark, false)
	# string courses along both masses and a dark slit in each
	for under: float in GATE_COURSES:
		m.box(at.call(d, (GATE.x + open.x) * 0.5, GATE_TOP - under), Vector3(open.x - GATE.x + 0.3, 0.35, GATE_DEPTH + 0.3), yaw, mat, false)
		m.box(at.call(d, (open.y + GATE.y) * 0.5, GATE_TOP - under), Vector3(GATE.y - open.y + 0.3, 0.35, GATE_DEPTH + 0.3), yaw, mat, false)
	for slit: float in GATE_SLITS:
		m.box(at.call(d - GATE_DEPTH * 0.5, slit, GATE_TOP - GATE_SLIT.z - GATE_SLIT.y * 0.5), Vector3(GATE_SLIT.x, GATE_SLIT.y, 0.3), yaw, dark, false)
	# the low wing with its lancet
	var w := GATE_WING
	var jamb := 0.7
	m.pointed_arch(at.call(d + 0.3, w.x, w.z), facing, w.y, w.w - w.z - jamb * 0.4, jamb, GATE_DEPTH * 0.7, mat)
	_wall(at.call(d + 0.3, w.x, 0.0), w.y + jamb * 2.0, w.z, GATE_DEPTH * 0.7, yaw, mat)
	m.box(at.call(d + 0.3, w.x - 0.3, w.w + GATE_WING_OVER * 0.5), Vector3(w.y + jamb * 2.0 + 0.6, GATE_WING_OVER, GATE_DEPTH * 0.7), yaw, mat)


## A group of near ruins standing out of the mist (RUIN_*): top = x, the height of its tallest top, z; its pieces
## strung out from its tower along +z turned by yaw.
func _ruins(top: Vector3, yaw: float, mat: Material) -> void:
	var basis := Basis(Vector3.UP, yaw)
	var place := func(along: float, across: float, y: float) -> Vector3:
		return Vector3(top.x, y, top.z) + basis * Vector3(across, 0, along)
	# the broken tower: blocks narrowing upward, the last one askew
	var t := RUIN_TOWER
	var height := 0.0
	for b in RUIN_TOWER_BLOCKS:
		height += b.y
	var y := top.y - height
	_wall(place.call(t.x, t.y, 0.0), t.z * 1.15, y, t.z * 1.15, yaw, mat)
	for i in RUIN_TOWER_BLOCKS.size():
		var b := RUIN_TOWER_BLOCKS[i]
		var block := m.box(place.call(t.x, t.y, y + b.y * 0.5), Vector3(t.z * b.x, b.y - 0.06, t.z * b.x), yaw + 0.2 * i, mat, false)
		if i == RUIN_TOWER_BLOCKS.size() - 1:
			block.rotate_object_local(Vector3.BACK, 0.16)
		y += b.y
	# the arch on its two piers, one of them taller and broken off
	var a := RUIN_ARCH
	var arch_top := top.y - RUIN_ARCH_SHAPE.y
	var foot: Vector3 = place.call(a.x, a.y, arch_top - RUIN_ARCH_SHAPE.x)
	var facing := basis * Vector3(1, 0, 0)
	m.pointed_arch(foot, Vector2(facing.x, facing.z), a.z, RUIN_ARCH_SHAPE.x, 0.6, 1.0, mat)
	for s: float in [-1.0, 1.0]:
		_wall(place.call(a.x + s * (a.z * 0.5 + 0.3), a.y, 0.0), 1.0, foot.y, 1.2, yaw + PI * 0.5, mat)
	m.box(place.call(a.x - a.z * 0.5 - 0.3, a.y, arch_top + RUIN_ARCH_SHAPE.y * 0.5), Vector3(0.9, RUIN_ARCH_SHAPE.y, 1.0), yaw + 0.1, mat, false)
	# the fallen pillar leaning on a stump
	var f := RUIN_PILLAR
	var shape := RUIN_PILLAR_SHAPE
	var lean_top := top.y - shape.z
	_wall(place.call(f.x + f.z * 0.32, f.y, 0.0), 1.3, lean_top - 0.5, 1.3, yaw, mat)
	var pillar := m.box(place.call(f.x, f.y, lean_top - sin(shape.y) * f.z * 0.32), Vector3(shape.x, shape.x, f.z), yaw, mat, false)
	pillar.rotate_object_local(Vector3.RIGHT, -shape.y)
	_wall(place.call(f.x - f.z * 0.4, f.y, 0.0), 1.1, lean_top - sin(shape.y) * f.z * 0.75, 1.1, yaw, mat)


## The iron pylon the chains hang from: a slender shaft out of the mist with collars round it, a cap, and the arm
## the chains hang from.
func _pylon(mat: Material) -> void:
	var top := TOWER + Vector3(0, TOWER_TOP, 0)
	m.box(top + Vector3(0, -20.0, 0), Vector3(TOWER_WIDTH, 40.0, TOWER_WIDTH), 0.0, mat)
	for y: float in TOWER_COLLARS:
		m.box(TOWER + Vector3(0, y, 0), Vector3(TOWER_WIDTH + TOWER_COLLAR, 0.4, TOWER_WIDTH + TOWER_COLLAR), 0.0, mat)
	m.box(top + Vector3(0, 0.25, 0), Vector3(TOWER_WIDTH + TOWER_COLLAR, 0.5, TOWER_WIDTH + TOWER_COLLAR), 0.0, mat)
	m.point(top + Vector3(0, 0.5, 0), TOWER_WIDTH, TOWER_WIDTH * 1.4, 0.0, 0.0, mat)
	m.box(TOWER + Vector3(0, TOWER_ARM.x, 0), Vector3(TOWER_ARM.y, 0.45, 0.45), PI * 0.25, mat)


## A wall of the depths standing out of the mist: its middle on the ground plan (`foot`, y ignored), width, the height
## of its top, depth.
func _wall(foot: Vector3, width: float, top: float, deep: float, yaw: float, mat: Material) -> void:
	m.box(Vector3(foot.x, top - 20.0, foot.z), Vector3(width, 40.0, deep), yaw, mat, false)


## The lit window of the abyss (the picture's, under the west bridge): a pointed opening of warm glass, lighter low
## down, in a stone frame, a small halo round it and a little warm light.
func _lantern(at: Vector3, yaw: float, frame: Material) -> void:
	var basis := Basis(Vector3.UP, yaw)
	var glass := StandardMaterial3D.new()
	glass.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glass.vertex_color_use_as_albedo = true
	glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	glass.albedo_color = LANTERN_GLASS
	# the pane: a lancet (upright sides, a pointed head of two arcs), warm at its foot, dimmer up top
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := LANTERN.x * 0.5
	var spring := LANTERN.y - LANTERN.x * 0.75
	var outline: Array[Vector2] = [Vector2(-half, 0.0), Vector2(half, 0.0), Vector2(half, spring)]
	for i in range(1, 6):
		var a := PI * 0.5 * i / 6.0
		outline.append(Vector2(half - LANTERN.x * (1.0 - cos(a)) * 0.5, spring + (LANTERN.y - spring) * sin(a)))
	outline.append(Vector2(0.0, LANTERN.y))
	for i in range(5, 0, -1):
		var a := PI * 0.5 * i / 6.0
		outline.append(Vector2(-half + LANTERN.x * (1.0 - cos(a)) * 0.5, spring + (LANTERN.y - spring) * sin(a)))
	outline.append(Vector2(-half, spring))
	var centre := Vector2(0.0, LANTERN.y * 0.45)
	for i in outline.size():
		var pts: Array[Vector2] = [centre, outline[(i + 1) % outline.size()], outline[i]]
		for q in pts:
			st.set_color(Color.WHITE * lerpf(1.0, LANTERN_TOP, q.y / LANTERN.y))
			st.add_vertex(Vector3(q.x, q.y, 0.0))
	var pane := MeshInstance3D.new()
	pane.mesh = st.commit()
	pane.material_override = glass
	pane.transform = Transform3D(basis, at)
	arena.add_child(pane)
	m.layers = ArenaKit.DEPTH_LAYER
	var face := basis * Vector3.BACK
	m.pointed_arch(at + face * 0.05, Vector2(face.x, face.z), LANTERN.x, LANTERN.y, LANTERN_FRAME, 0.2, frame)
	m.box(at + face * 0.08 + Vector3(0, -0.06, 0), Vector3(LANTERN.x + 0.4, 0.12, 0.25), yaw, frame)
	# the glazing bars, dark against the warm glass
	for i in LANTERN_UPRIGHTS:
		var x := LANTERN.x * ((i + 1.0) / (LANTERN_UPRIGHTS + 1.0) - 0.5)
		m.box(at + basis * Vector3(x, LANTERN.y * 0.5, 0.04), Vector3(LANTERN_BAR, LANTERN.y, LANTERN_BAR), yaw, frame, false)
	for i in LANTERN_CROSSES:
		var y := LANTERN.y * (i + 1.0) / (LANTERN_CROSSES + 1.0)
		m.box(at + basis * Vector3(0, y, 0.04), Vector3(LANTERN.x, LANTERN_BAR, LANTERN_BAR), yaw, frame, false)
	m.layers = 1
	var halo := MeshInstance3D.new()
	halo.mesh = Fx.quad(LANTERN.y + LANTERN_HALO, LANTERN_HALO_COLOR)
	halo.position = at + Vector3(0, LANTERN.y * 0.5, 0) + face * 0.3
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arena.add_child(halo)
	var l := OmniLight3D.new()
	l.position = at + basis * Vector3(0, 0.8, 1.0)
	l.light_color = ArenaKit.FIRE
	l.light_energy = 1.5
	l.omni_range = 4.0
	l.light_cull_mask = ArenaKit.DEPTH_LAYER
	arena.add_child(l)


# ---------- doors ----------

## Where each way on is: the spot in front of it on the floor (Arena.exits), the way into the room from it, and the
## zone that leaves the room when stepped in.
func _doors(count: int) -> void:
	var a := arena
	var inner := HALF - Vector2(1.2, 1.2)
	var mid := (FLIGHT.x + FLIGHT.y) * 0.5
	var spots: Array[Vector2] = [Vector2(PORTAL_X, -inner.y + 0.6), Vector2(inner.x - 0.6, (EAST_GAP.x + EAST_GAP.y) * 0.5),
		Vector2((SOUTH_GAP.x + SOUTH_GAP.y) * 0.5, inner.y - 0.6)]
	var inward: Array[Vector2] = [Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
	var zones: Array[Rect2] = [Rect2(FLIGHT.x + 0.6, -HALF.y - 2.0, FLIGHT.y - FLIGHT.x - 1.2, 4.4),
		Rect2(inner.x - 1.0, EAST_GAP.x + 0.4, 4.0, EAST_GAP.y - EAST_GAP.x - 0.8),
		Rect2(SOUTH_GAP.x + 0.4, inner.y - 1.0, SOUTH_GAP.y - SOUTH_GAP.x - 0.8, 4.0)]
	for i in mini(count, 3):
		a.exits.append(spots[i])
		a.exit_inward.append(inward[i])
		a.exit_zones.append(zones[i])


# ---------- candles ----------

## A heap of fallen stones of the hall's masonry round `at` on the floor: RUBBLE blocks (size range, all under the
## knee so none reads as a barrier), each askew, the same heap at the same place.
func _rubble(at: Vector2) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i(at * 10.0))
	for k in RUBBLE:
		var size := Vector3(r.randf_range(RUBBLE_SIZE.x, RUBBLE_SIZE.y), r.randf_range(RUBBLE_HEIGHT.x, RUBBLE_HEIGHT.y),
			r.randf_range(RUBBLE_SIZE.x, RUBBLE_SIZE.y))
		var p := at + Vector2.from_angle(r.randf() * TAU) * r.randf_range(0.0, RUBBLE_SPREAD)
		var b := m.box(Vector3(p.x, size.y * 0.5 - 0.03, p.y), size, r.randf() * TAU)
		b.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.2, 0.2))


## The Masonry of the pieces only the classic look shows (made on first use, joined at the end of build()).
func classic() -> Masonry:
	if _classic == null:
		var node := Node3D.new()
		node.name = "ClassicOnly"
		kit.root.add_child(node)
		VisualProfile.vary(node, {&"visible": false})
		_classic = Masonry.new(node)
		_classic.layers = m.layers
	return _classic


## ENV-HB7: a KayKit crate in the fight field (the east stone's) drawn only in the classic look; in the stylized one a
## block of the hall's stone of the same size and place (its blocking box the same) with a broken corner block on it.
func _field_crate(pos: Vector3, yaw: float, size: Vector3, solid: float) -> void:
	kit.crate(pos, yaw, size, solid, classic())
	var f := kit.crate_frame(pos, yaw, size)
	var foot: Vector3 = f[0]
	var dims: Vector3 = f[1]
	var sty := kit.styled()
	sty.box(foot + Vector3(0, dims.y * 0.5, 0), dims, yaw)
	var chip := dims * FIELD_CRATE_CHIP
	sty.box(foot + Vector3(dims.x * 0.2, dims.y + chip.y * 0.5, -dims.z * 0.15), chip, yaw + 0.5)


## One candle (lit or burnt out) in both looks: the classic one on _classic, its shorter stylized twin on kit.styled().
func _candle(p: Vector3, height: float, radius: float, burnt: bool) -> void:
	var sty := kit.styled()
	var h := height * STY_CANDLE_HEIGHT
	var r := radius * STY_CANDLE_RADIUS
	if burnt:
		classic().candle_out(p, height, radius)
		sty.candle_out(p, h, r)
	else:
		classic().candle(p, height, radius)
		sty.candle(p, h, r)


## A cluster of thick candles on the floor (or on top of something at `at`: then smaller), a warm halo over them and
## one warm light unless light is false: one tall thick candle in the middle, one or two of middle height and stubs
## round it (the taller, the thicker). tall: the stubs are left out (the south stone's cluster). burnt: the cluster is
## burnt out (VX-13): the same candles, dark wax and wicks, no flame, halo nor light.
func _candles(at: Vector3, count: int, light := true, tall := false, burnt := false) -> void:
	var on_top := at.y > 0.3
	var size := CANDLE_ON_TOP if on_top else 1.0
	var n := mini(count, CANDLE_MAX) if on_top else clampi(count, 3, CANDLE_MAX)
	# C-3 (AD2-08): three drawings in turn, so no two groups beside each other are the same set: the usual cluster,
	# a spill of low stubs with a burnt one at its edge, a few tall ones close together
	var variant: Vector3 = CANDLE_VARIANTS[_clusters % CANDLE_VARIANTS.size()]
	_clusters += 1
	if variant.z > 0.0:
		n = mini(n, int(variant.z))
	var turn := _rng.randf() * TAU
	for i in n:
		var t := 1.0
		if i > 0:
			t = _rng.randf_range(0.4, 0.65) if (i <= (n - 1) / 2 or tall) else _rng.randf_range(0.0, 0.2)
		var r := lerpf(CANDLE_RADIUS.x, CANDLE_RADIUS.y, t) * size
		var p := at
		if i > 0:
			var a := turn + TAU * float(i) / float(n - 1) + _rng.randf_range(-0.3, 0.3)
			p += Vector3(cos(a), 0, sin(a)) * (CANDLE_RADIUS.y * size + r + _rng.randf_range(0.04, 0.22) * size) * variant.x
		var out := burnt or (variant.y < 1.0 and i == n - 1 and n > 3)
		_candle(p, lerpf(CANDLE_HEIGHT.x, CANDLE_HEIGHT.y, t) * size * variant.y, r, out)
	if burnt:
		return
	var glow := MeshInstance3D.new()
	glow.mesh = Fx.quad(CANDLE_HALO, Color(0.8, 0.45, 0.18) * CANDLE_HALO_ALPHA)
	glow.position = at + Vector3(0, CANDLE_HEIGHT.y * 0.8 * size, 0)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arena.add_child(glow)
	VisualProfile.vary(glow, {&"position": at + Vector3(0, CANDLE_HEIGHT.y * 0.8 * size * STY_CANDLE_HEIGHT, 0)})
	if not light:
		return
	var l := OmniLight3D.new()
	l.position = at + Vector3(0, 0.9, 0)
	l.light_color = Color(1.0, 0.7, 0.4)
	l.light_energy = CANDLE_LIGHT
	l.omni_range = CANDLE_RANGE
	l.light_cull_mask = ~Arena.CROWD_LAYER
	arena.add_child(l)
