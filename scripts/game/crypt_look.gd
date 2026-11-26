class_name CryptLook
extends ArenaRoom
## The look of the Cripta dos Esquecidos (the crypt of the forgotten), spec docs/art/cycle12_arenas_spec.md section 2:
## a small closed crypt, no abyss in sight. Walls of cut stone 6.5 m high on the north and west (the back of the
## picture) with funerary niches (shelves of pots and bones, or a hooded statue with empty hands), the door of X1 in an
## arch between two fire bowls in recesses and two banners with the lion over them, the way in through an arcade in
## the west wall with its gold sill; to the north-east a heap of fallen blocks; south and east (the front) the walls
## cut at 0.9 m like a model opened up, their section on top, their outer face dropping into the dark. Small cold
## slabs, plain grave slabs, candles in pools on the pieces (some burnt out in variant B), a single cold shaft of
## light from a crack in the vault over the tomb (A) or the dividing wall's end (B), its dust falling. What blocks is
## the layout's (ArenaObstacle), drawn by ArenaRoom.piece; this draws the rest and the air.

## The walls of the back: height, thickness, how far the face stands behind the floor's edge (a ledge fills it, LEDGE
## high), a string course and the cornice (height, how far out).
const WALL_HEIGHT := 6.5
const WALL_THICK := 1.4
const WALL_SET := 0.3
const LEDGE := 0.9
const COURSE := Vector2(3.6, 0.12)
const CORNICE := Vector2(0.3, 0.18)
## The walls of the front, cut: height, thickness, how far their outer face drops into the dark, the dark fill seen on
## their cut top (share of the thickness) and fallen blocks outside them (per meter).
const FRONT := Vector2(0.9, 0.8)
const FRONT_DROP := 3.0
const FRONT_FILL := 0.55
const FRONT_FALLEN := 0.25
## Funerary niches (width, height, depth into the wall), their sill on the ledge: on the north wall at these x, on the
## west at these z; those in STATUE_NICHES (by order: north then west) hold a hooded statue instead of shelves.
const NICHE := Vector3(1.7, 3.1, 0.9)
const NORTH_NICHES: Array[float] = [-9.6, -6.4]
const WEST_NICHES: Array[float] = [-7.5, 8.5]
const STATUE_NICHES: Array[int] = [1, 2]
const STATUE := 2.1
## The recess of a fire bowl beside the north door (width, height, depth behind the face).
const RECESS := Vector3(1.5, 3.2, 1.25)
## The arcade of the way in, in the west wall (z from, to), its stairs going up out of the room.
const ENTRY := Vector2(2.5, 6.5)
const ENTRY_STEPS := 6
## The arcade of the way in as dressed (z from, to): ENTRY, or 4 m round the paladin's way in when the layout puts it
## elsewhere (the guardians' houses, whose way in is the west wall's middle).
var entry := ENTRY
## Banners with the lion over the fire bowls (their top, size).
const BANNER_TOP := 6.0
const BANNER_SIZE := Vector2(1.1, 2.4)
## The heap of fallen blocks in the north-east corner: blocks (count, size range), its height from the floor's edge
## (LOW) to the walls (HIGH).
const HEAP := 46
const HEAP_BLOCK := Vector2(0.35, 1.2)
const HEAP_HEIGHT := Vector2(0.3, 3.5)
## The stone: cut stone a step colder and darker than the floor (spec 2.5), the niches' dark, the bones' grey.
const STONE := Color(0.92, 0.95, 1.02)
const WALL_TINT := 0.9
const HOLLOW := Color(0.24, 0.2, 0.26)
const BONE := Color(1.6, 1.55, 1.4)
## Grave slabs in the floor (width, length), in rows north and south of the middle (x of each, z of the row).
const SLAB := Vector2(0.9, 1.9)
const SLAB_ROWS: Array[Vector3] = [Vector3(-9.0, -8.3, 0), Vector3(-3.2, -8.3, 0), Vector3(3.2, -8.3, 0),
	Vector3(-8.6, 8.3, 0), Vector3(0.6, 8.3, 0), Vector3(7.2, 8.3, 0)]
const SLAB_STONE := 0.8
const SLAB_FRAME := 0.4
## The dark sunk border round each grave slab (ART_REVIEW C-4: a step deeper, so they can be counted): how far it
## reaches past the slab, its height, its stone.
const SLAB_BORDER := Vector2(0.1, 0.006)
const SLAB_BORDER_TINT := 0.35
## The steps of the way in and of the doors (ART_REVIEW C-3: they read as planks, lighter than all round them): their
## stone in the value of the walls' cut stone.
const STAIR_TINT := 0.8
## The floor (spec 2.5): small cold slabs, a step lighter than the walls' cut stone so the fight's ground reads 45 to 60
## away from the candles (ENV-01: was 0.24 and 0.34, the fight's floor at 27 to 42).
const FLOOR := {
	&"unit": 0.8, &"stone_a": Color(0.31, 0.31, 0.36), &"stone_b": Color(0.44, 0.43, 0.49),
	&"joint_color": Color(0.08, 0.08, 0.1), &"moss_color": Color(0.22, 0.22, 0.25), &"petal_color": Color(0.24, 0.24, 0.28),
	&"missing": 0.08, &"cracked": 0.3,
}
## The air (spec 2.5): no sky, a dark brown-black, the ambient a little over half the hall's, no moon to speak of.
const AIR := {
	&"sky": Color(0.14, 0.13, 0.14), &"fog": Color(0.13, 0.125, 0.13), &"fog_depth": Vector2(40.0, 80.0),
	&"ambient": Color(0.32, 0.30, 0.30), &"ambient_gain": 2.1, &"moon": Color(0.62, 0.64, 0.7), &"moon_energy": 0.6,
	&"moon_shadow": false,
}
## The cold shaft from the vault: colour, energy, cone, how high it starts, how far off the plumb (toward the back).
const COLD := Color(0.62, 0.74, 0.9)
## (ART_REVIEW C-1: at 2.5 the great tomb's lid went near white; the shaft stays the frame's middle.)
const COLD_ENERGY := 1.6
## The great tomb's lid under the shaft: lighter than its stone by this much (ArenaRoom.SARC_LID_LIGHT is 1.5 for the
## other sarcophagi; under the shaft that went white, ART_REVIEW C-1).
const TOMB_LID_LIGHT := 1.0
const COLD_ANGLE := 18.0
const COLD_HEIGHT := 14.0
const COLD_LEAN := Vector2(-2.0, -2.5)
## The soft key over the middle (no shadow): its colour and energy (the pools of fire stay the brighter).
const KEY := Color(0.85, 0.78, 0.74)
## ENV-01: the key hangs higher (KEY_HEIGHT; the hall's is 9 m) and falls off slower (KEY_FALLOFF, its attenuation, was
## 1.0; KEY_REACH, its range, was 19 m), so its pool spreads flat over the whole floor of the fight instead of a bright
## middle and dark bays (the fight's floor was 27 to 42 away from the candles, the aim 45 to 60).
const KEY_ENERGY := 1.8
const KEY_HEIGHT := 11.0
const KEY_FALLOFF := 0.5
const KEY_REACH := 26.0
## ...and stands this far off the floor's middle (x, z), toward the west bays the candles leave dark.
const KEY_SHIFT := Vector2(-3.0, 2.5)
## The browser's renderer (Compatibility) leaves the crypt darker than the desktop (ART_REVIEW G-1): there the key and
## the ambient are this much stronger.
const COMPAT_KEY := 1.4
const COMPAT_AMBIENT := 1.4
## M-1 (QA-02): the fight's floor in the west and north bays, far from the candles and the key, read 19 to 34 (the aim
## 45 or more). A soft fill over them that lights the floor alone (ArenaRoom.FLOOR_LAYER; the walls stay as dark as
## they were) and casts no shadow: its colour (the key's), energy, height, reach, falloff and where it stands (x, z).
const FLOOR_FILL := Color(0.8, 0.76, 0.78)
const FLOOR_FILL_ENERGY := 1.8
const FLOOR_FILL_HEIGHT := 6.0
const FLOOR_FILL_REACH := 16.0
const FLOOR_FILL_FALLOFF := 0.6
const FLOOR_FILL_AT := Vector2(-9.0, -1.5)
## Candle lights with shadow (energy) and the plain ones (spec 2.5: at most 6 without shadow).
const CANDLE_SHADOW_ENERGY := 1.6
const CANDLE_PLAIN := 6
## A hooded statue's own light (energy, reach, cone).
const STATUE_GLOW := Vector3(1.4, 5.0, 40.0)

## Room redesign, lot A (docs/art/room_redesign_lotA_spec.md part 2): the crypt's biome in the stylized look, petrol
## stone, cold shadow, dry floor (one slab in 33 to the olive), the candles' pools, a cold air, the key and the
## floor's fill off (in the painted light an omni with no fire draws rings on the floor), the backdrop in mist.
## The cycle of 2026-11-20 (ART_REVIEW.md, the Salão's method replicated by biome): the crypt in a deep green petrol
## (hue 184 to 194 on the screen, docs/art/benchmark_hades2_style.md 7.2 row 1; a step darker than the hall's petrol), the stone, the floor, the shadow, the air and
## the backdrop moved there.
const STYLE := {
	&"stone": Color(0.222, 0.275, 0.29), &"shadow": Color(0.85, 0.93, 0.96), &"floor_stone": Color(0.21, 0.25, 0.265),
	&"joint_cold": Color(0.9, 0.97, 1.0), &"olive_share": 0.03, &"slab_hue": 4.0, &"metal": true, &"pool_gain": 1.4, &"pool_saturation": 1.0,
	&"fire": {&"candle_range": 3.4, &"candle_gain": 2.2, &"bowl_range": 4.5, &"bowl_attenuation": 0.7, &"bowl_gain": 1.5,
		&"compat": 0.4},
	&"air": {&"sky": Color(0.04, 0.062, 0.068), &"fog": Color(0.085, 0.12, 0.128), &"fog_depth": Vector2(40.0, 85.0),
		&"ambient": Color(0.75, 0.78, 0.79), &"ambient_gain": 2.7, &"moon": Color(0.94, 0.97, 1.0), &"moon_energy": 0.9,
		&"moon_shadow": true},
	&"backdrop": {&"mist": Color(0.09, 0.14, 0.15), &"stone": Color(0.045, 0.068, 0.073), &"edge": Color(0.15, 0.21, 0.225)},
	&"shadow_glow": STY_SHADOW_GLOW, &"vignette": CatacombHall.STY_VIGNETTE,
}
## C1V N2 (docs/art/identidade_c1v.md 2.1, the hall's recipe, only in the stylized look): the key's shadow band takes this
## green petrol on top (hue 184 to 194 like the room), the warm key's pool (the hall's colour and energy) over the middle
## of the room, shifted by STY_WARM_SHIFT (x, z in m) and its radius.
const STY_SHADOW_GLOW := Color(0.20, 0.50, 0.55)
const STY_WARM_SHIFT := Vector2(-4.0, 0.0)
const STY_WARM_RADIUS := 7.0
## SW-G1 (docs/art/sworn_reference_ideas.md 3.1): the painted floor's second colour of the biome, in patches of 3 to 8 m,
## stronger near the edge (floor_biome.gdshaderinc; ArenaKit.paint_look's `floor`, put by style()).
## Cold damp: a pale cold bloom of salts on the slate, 1.4 times its value (the floor between them at patch_rest).
## The cycle of 2026-11-20: the patches soft (ArenaKit.SOFT_PATCHES) and the floor calm (ArenaKit.CALM_FLOOR) as in the
## Salão; the frame is the walls themselves: the floor darker at their foot (edge_value from edge_span times the calm
## radius out), the candles' pools on it a little warmer.
const STY_FLOOR_BIOME := {&"patch_color": Color(0.28, 0.355, 0.375), &"edge_value": 0.55, &"edge_span": Vector2(1.0, 1.6),
	&"paint_pool_saturation": 1.0}
## SW-C1 (docs/art/sworn_reference_ideas.md 3.2; ArenaKit.framed, GRAVE): grave slabs in the painted floor, the size
## of the old ones (SLAB), filling their rows (SLAB_ROWS: z -8.3 and 8.3) between the sarcophagi; x of each, its lion
## (z: 1, one in five counting the old ones). B leaves out the north-west one by its sarcophagus.
const STY_GRAVES_NORTH: Array[Vector2] = [Vector2(-7.75, 0), Vector2(-4.45, 0), Vector2(-1.95, 1), Vector2(-0.7, 0),
	Vector2(1.95, 0), Vector2(4.45, 1)]
const STY_GRAVES_SOUTH: Array[Vector2] = [Vector2(-9.85, 0), Vector2(-7.35, 1), Vector2(-0.65, 0), Vector2(1.85, 1),
	Vector2(3.1, 0), Vector2(5.95, 0), Vector2(8.45, 0)]
const STY_GRAVES_B_SKIP := -4.45
## The grave slabs' value (times the floor's).
const STY_GRAVE_VALUE := 1.06
## C-1 of the Sworn P1 review: the old grave slabs (SLAB_ROWS, built in both looks) read as a trapdoor or a hole in the
## stylized look (inside luma about 0.3 of the floor's beside them, a light frame round a black field): their stone
## painted at their own paint_ref (the plain stone's is STY_PAINT_REF 0.36; lower is lighter): the slab at 0.9 to 1.0
## of the floor's value, the frame a step lighter as the new ones' lip, the dark border a groove, not a pit; w: the
## worn inscription's (A7) a step under the slab.
const STY_OLD_SLAB := Vector4(0.22, 0.1, 0.03, 0.2)
## SW-G3: a pair of raised frames (RAISED) on the great tomb's axis in A, and between B's two south sarcophagi:
## middles and side (m).
const STY_FRAMES_A: Array[Vector2] = [Vector2(-3.4, 0.0), Vector2(4.4, 0.0)]
const STY_FRAME_A := 2.2
const STY_FRAMES_B: Array[Vector2] = [Vector2(-1.45, 3.0), Vector2(0.55, 3.0)]
const STY_FRAME_B := 1.9
## Art pack 2026-11-23 (the Cripta B painting's lion emblem, as a square frame like the Salao's, never a disc): in
## variant B the first of the pair is a lion slab (GRAVE with its mark) and the second stays a plain raised frame.
const STY_LION_FRAME_B := true
## The small sarcophagi in the stylized look: their lighter stone painted at the plain stone's value (paint_ref of the
## painted stone, paint.gdshaderinc, times their tint) and their candles' pools softer.
const STY_PAINT_REF := 0.36
## The stylized air in the Compatibility renderer (the browser): its ambient and key lower, where the painted stone lit
## grey-white at the desktop's numbers (frame luma 79 against 56 on desktop).
const STY_COMPAT_AMBIENT := 0.7
const STY_COMPAT_MOON := 0.5
const STY_LIGHT_STONE := 1.35
const STY_LID_POOL := 0.45
## B: the light of the small sarcophagi's lit candles, a share of the room's stylized candles (lot A review item 7:
## with the candles at 1.8 the west floor beside the lid burnt to luma 92).
const STY_LID_LIGHT := 0.4
## The cold shaft in the stylized look (hue 200, saturation 0.28).
const STY_COLD := Color(0.66, 0.82, 0.92)
## The cold glow far behind the north door (spec 2.3): how far behind the wall's face (and at least 0.3 m past the
## door's mouth), its foot and top (y), its colour
## at the foot (A; B: the distant light of the concept), at the top.
const DOOR_GLOW := Vector3(1.0, -0.5, 3.5)
const DOOR_GLOW_FOOT := Color(0.32, 0.40, 0.44)
const DOOR_GLOW_FOOT_B := Color(0.38, 0.46, 0.50)
const DOOR_GLOW_TOP := Color(0.02, 0.03, 0.04)
const COLD_GLOW_SHADER := preload("res://assets/shaders/cold_glow.gdshader")
## The mist beyond the cut front walls (spec 2.3): how far out of the outer face, its middle's height, height, colour
## (times 2 on the card), alpha. ENV-HB4: lower, flatter and fainter (at 5 m high and 0.5 it read as a tall pale band
## beside the east front, over the far ruins).
const FRONT_MIST := Vector4(2.5, -4.0, 3.0, 0.25)
const FRONT_MIST_COLOR := Color(0.10, 0.15, 0.18)
## The shrouded effigy on the great tomb (A1): its length, the share of the tomb's length its middle stands off west
## (from x -0.6 to 1.6 on the tomb at 0.5), how much lighter its stone is.
const EFFIGY := Vector2(2.2, 0.0)
const EFFIGY_LIGHT := 1.05
## Urns on the ledges (A2, A3; x or z along the north or west ledge, height). Places that a blocking piece stands within
## URN_CLEAR of are left out (variant B's low wall).
const NORTH_URNS: Array[Vector2] = [Vector2(-10.75, 0.42), Vector2(-10.45, 0.3), Vector2(-1.2, 0.5)]
const WEST_URNS: Array[Vector2] = [Vector2(-2.55, 0.48), Vector2(-2.25, 0.32), Vector2(0.9, 0.4), Vector2(-0.75, 0.36), Vector2(-0.45, 0.5)]
const URN_CLEAR := 0.25
## A burnt-out stub beside the north urn at x -1.2 (A2).
## SL-02: how deep the doorway's recess goes into the north wall (m), where the dim light of a door in use hangs (height, out in front of the wall).
const DOOR_DEPTH := 1.2
const DOOR_LIGHT_UP := 3.0
const DOOR_LIGHT_OUT := 0.8
const NORTH_STUB := Vector2(-0.95, 0.12)
## Candles at the statues' feet (A4): how many lit on the sill in front of each statue niche, how far out of the
## wall's face; their light (one for each niche).
const STATUE_CANDLES := 5
const SILL_OUT := 0.12
## The shelved niches' sill (A5): two urns and three burnt-out candles.
const SHELF_URNS: Array[float] = [0.36, 0.44]
## Burnt-out candles at the other end of the small sarcophagi's lids that burn (A6).
const LID_STUBS := 3
## The grave slabs' worn inscription (A7): a frame inset this far, its line, three strokes (share of the inside's
## width), the stone's value, how far over the slab.
const INSCRIPTION := Vector3(0.16, 0.03, 0.6)
const INSCRIPTION_TINT := 0.5
const INSCRIPTION_LIFT := 0.006
## Variant B: the veiled figure on the ossuary wall's north end (B1: height, how far in from the north end), the urns
## along its top (B2: z, height), its cold light (B3: energy, reach, cone; from this high over the wall and this far
## south of the figure).
const VEILED := Vector2(3.0, 0.9)
const WALL_URNS: Array[Vector2] = [Vector2(-8.5, 0.42), Vector2(-7.0, 0.36), Vector2(-5.5, 0.5), Vector2(-4.5, 0.38)]
const VEILED_GLOW := Vector3(3.2, 7.0, 30.0)
## The veiled figure's stone this much lighter than the walls' statues (it read as the wall behind it).
const VEILED_VALUE := 1.35
const VEILED_GLOW_FROM := Vector2(4.0, 3.5)

## RS-C1 (docs/art/rs_c1_crypt_spec.md), only in the stylized look: one funerary piece rules each variant. A, the
## crowned tomb: a crown of candles hanging over the great tomb, its middle CROWN_Y high; the outer ring (radius,
## section), the inner ring (radius, rise over the outer, section), its segments and spokes; candles on dishes (size,
## thickness) round the outer ring, the burnt-out ones by index (never two together), their height and radius ranges.
const CROWN_Y := 6.0
const CROWN_RING := Vector2(1.5, 0.07)
const CROWN_INNER := Vector3(1.2, 0.06, 0.04)
const CROWN_SEGMENTS := 24
const CROWN_SPOKES := 8
const CROWN_CANDLES := 16
const CROWN_OUT: Array[int] = [1, 5, 8, 12, 14]
const CROWN_CANDLE := Vector4(0.12, 0.22, 0.04, 0.05)
const CROWN_DISH := Vector2(0.1, 0.02)
## Three chains from the ring (at these turns) to the hook, one from the hook up to CROWN_TOP where it ends (screen y 64,
## under the HUD's clock); the links' size.
const CROWN_CHAIN_AT: Array[float] = [0.0, 120.0, 240.0]
const CROWN_HOOK := 9.2
const CROWN_TOP := 10.0
const CROWN_CHAIN := 0.5
## The crown's own light, CROWN_LIGHT_DROP under the ring: energy (times the style's compat share in the browser's
## renderer), reach, attenuation; no shadow. A fire (its pool painted), its numbers its own (ArenaKit.NOT_FIRE).
## (Its attenuation under the spec's 1.0: at 5.7 m over the floor a fall-off of 1/d left N.L times it under the painted
## pool's edge, paint_pool 0.1, and the floor round the tomb took no warm at all.)
const CROWN_LIGHT_DROP := 0.3
const CROWN_ENERGY := 2.2
## Its colour: the room's candle warm a little yellower (CANDLE_COLOR painted the pool at hue 19 to 23 on the petrol
## stone, the aim 25 to 40). The cycle of 2026-11-20: a little less green in it, on the greener petrol floor it painted
## an olive pool.
const CROWN_COLOR := Color(1.0, 0.66, 0.34)
const CROWN_LIGHT := Vector2(9.5, 0.4)
## A warm halo round each lit crown candle (size, alpha of CROWN_HALO_COLOR), added on what is behind, under the glow.
const CROWN_HALO := Vector2(0.65, 0.55)
const CROWN_HALO_COLOR := Color(0.8, 0.45, 0.18)
## The crown's pieces stand on a render layer of their own that its light leaves out (a hand's breadth from the wax,
## it burnt the candles white: 1.5% of the crown over 235 on screen).
const CROWN_LAYER := 128
## A: the pall on the great tomb, hung on the body's south face and its east end, from under the lid (PALL_TOP under
## the lid's foot) down to PALL_FOOT over the floor, PALL_OUT past the frieze; widths (south, east); its petrol, gold,
## the gold thread (in from the sides, width; shares of the width), the fringe's depth and teeth; the old gold lion
## (decided by Daniel, 2026-11-19) on the south one between these shares of its height.
const PALL_WIDTH := Vector2(2.0, 1.2)
const PALL_TOP := 0.02
const PALL_FOOT := 0.45
const PALL_OUT := 0.012
const PALL_CLOTH := Color(0.06, 0.14, 0.15)
## The cloth's faint glow of its own (the reliquary's is 0.12: under the cold shaft the pall read 65, the aim 25 to 50).
const PALL_GLOW := 0.04
const PALL_THREAD := Vector2(0.035, 0.012)
const PALL_FRINGE := Vector2(0.05, 0.05)
const PALL_LION_V := Vector2(0.16, 0.97)
const PALL_SHADER := preload("res://assets/shaders/reliquary_cloth.gdshader")
## A, what falls quiet in the stylized look (shares of each fire's stylized energy, ArenaKit.FIRE_SHARE): the north
## sarcophagus's candles, the candles at the statues' feet, the north door's fire bowls; the cold shaft's energy. The
## light of the tomb's west step goes out (the crown lights there).
const STY_NORTH_LID := 0.6
const STY_STATUE_CANDLES := 0.5
const STY_BOWLS := 0.5
const STY_TOMB_SHAFT := 1.5
## R-1 of the Sworn P1 review (the warm in a dozen spots competed with the crown): every other candle group on the small
## sarcophagi's lids, the columns' feet and the back ledges goes out in the stylized look (its flames and its light; the
## crown, the great tomb's and the statues' stay), as VX-13 did in the hall. Which of each two (0 or 1).
const STY_GROUPS_OUT := 1
## B, the veiled one of the ossuary: a plinth (size) on the wall's north end with two stepped corbels under its flaps
## (their two steps: top, middle, foot heights; widths), the figure on it VEILED_RS high; its cold lantern hanging
## from its hands (the lantern's size, its middle under the hands and out in front of the robe, its light: energy,
## reach, attenuation); the cold shaft re-aimed from (STY_SHAFT_FROM) at the figure's chest (height over its foot):
## cone, energy; the figure's own light.
const PLINTH := Vector3(1.3, 0.4, 1.1)
const CORBEL := Vector4(3.2, 3.0, 2.75, 0.25)
const CORBEL_DEPTH := 0.6
const VEILED_RS := 4.4
const VEILED_RS_VALUE := 1.75
const LANTERN := Vector3(0.32, 0.42, 0.32)
const LANTERN_UNDER := 0.62
const LANTERN_OUT := 0.3
const LANTERN_GLASS := Color(0.70, 0.86, 0.95)
const LANTERN_LIGHT := Vector3(1.5, 9.0, 1.2)
const STY_SHAFT_FROM := Vector3(2.5, 14.0, -3.0)
const STY_SHAFT_AIM := 2.8
const STY_SHAFT := Vector2(14.0, 1.6)
const STY_VEILED_GLOW := 4.0
## Item 4 of the cycle (B: the niches and the urns rule the frame): a cold wash grazing the ossuary wall's face toward the
## camera (from: out of the face, height, along the wall from its middle; aim height; energy, cone, reach), diffuse, no
## shadow, never on the crowd.
const STY_OSSUARY_WASH_FROM := Vector3(5.0, 7.0, 2.0)
const STY_OSSUARY_WASH_AIM := 1.4
const STY_OSSUARY_WASH := Vector3(5.0, 34.0, 14.0)

## AT-CB1 (variant B, stylized only): the one warm interruption in the cold ossuary, a candle-coloured light at the
## west entry (in from the wall, height, energy, reach), diffuse, no shadow, never on the crowd.
const STY_ENTRY_WARM := Vector4(1.6, 1.9, 2.2, 7.0)

var _key: OmniLight3D
var _fill: OmniLight3D
var _shaft: SpotLight3D
var _north := 0.0
var _west := 0.0
var _south := 0.0
var _east := 0.0
var _plain_lights := 0
## RS-C1: the light of the great tomb's west step, the lit small sarcophagi's lights (their middle), the banners over
## the fire bowls (their x, their nodes), the cold shaft's dust.
var _tomb_light: OmniLight3D
var _lid_lights: Array = []
## R-1: A's candle groups on the small sarcophagi's lids, the columns and the ledges, each [flames, its light or null].
var _groups: Array = []
var _banners: Array = []
var _shaft_dust: Node3D


func floor_look() -> Dictionary:
	return FLOOR


func floor_layers() -> int:
	return 1 | FLOOR_LAYER


func stone_tint() -> Color:
	return STONE


## True in the browser's renderer (Compatibility).
static func _compat() -> bool:
	return RenderingServer.get_current_rendering_method() == "gl_compatibility"


func air() -> Dictionary:
	if not _compat():
		return AIR
	var a := AIR.duplicate()
	a[&"ambient_gain"] = float(AIR[&"ambient_gain"]) * COMPAT_AMBIENT
	return a


## ENV-HB4 (ArenaRoom.under_look, only in the stylized look): the camera's side of the floor's edge on arches going
## down into the mist instead of a plain coursed wall.
## Here the face is the cut front walls' outer one (FRONT.y out), the arches' tops under their coping, and the crypt
## has no depths' stone of its own: a dark petrol one fading into the front's mist.
const STY_UNDER := {&"set": FRONT.y, &"top": FRONT.x - 0.4, &"colors": {&"stone_color": Color(0.04, 0.066, 0.07),
	&"edge_color": Color(0.1, 0.16, 0.17), &"mist_color": FRONT_MIST_COLOR * 2.0}}


func under_look() -> Dictionary:
	return STY_UNDER


## The north door (X1) opens in the wall.
func in_wall(i: int) -> bool:
	return layout.exits[i].inward.y > 0.5


## No cliffs: the walls and the heap are drawn in dress; a door's mouth drops into the dark.
func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		cliff(a, b, out, faces, EXIT_STEPS * EXIT_RISE + 0.6)


## No abyss in a crypt.
func _abyss() -> void:
	pass


## The far walls' fill (ArenaRoom.wall_fill, C18): its colour and energy.
const WALL_FILL_COLOR := Color(0.78, 0.78, 0.84)
const WALL_FILL_ENERGY := 1.6


func dress() -> void:
	BuildSteps.run(dress_steps())


## dress in steps (ArenaRoom.dress_steps; QA P1-1).
func dress_steps() -> Array[Callable]:
	return [
		func() -> void:
			wall_fill(WALL_FILL_COLOR, WALL_FILL_ENERGY)
			if layout.guardian_home:
				entry = Vector2(-2.0, 2.0)  # PT-6: the old west arch stays (sealed); he now comes in from the south
			var b := layout.floor.polys[0]
			var box := Rect2(b[0], Vector2.ZERO)
			for p in b:
				box = box.expand(p)
			_north = box.position.y
			_west = box.position.x
			_south = box.end.y
			_east = box.end.x
			_back_walls(),
		_back_wall_west,
		_back_niches,
		_front_walls,
		func() -> void:
			_heap()
			_entry(),
		_slabs,
		_fountain,
		func() -> void:
			_candles()
			_cold_shaft()
			_lights(),
		func() -> Array[Callable]: return _dress_styled_steps(),
	]


func _lights() -> void:
	var key := key_light(KEY, KEY_ENERGY * (COMPAT_KEY if _compat() else 1.0), KEY_HEIGHT)
	_key = key
	key.omni_attenuation = KEY_FALLOFF
	key.omni_range = KEY_REACH
	key.position += Vector3(KEY_SHIFT.x, 0.0, KEY_SHIFT.y)
	var fill := OmniLight3D.new()
	fill.position = Vector3(FLOOR_FILL_AT.x, FLOOR_FILL_HEIGHT, FLOOR_FILL_AT.y)
	fill.light_color = FLOOR_FILL
	fill.light_energy = FLOOR_FILL_ENERGY * (COMPAT_KEY if _compat() else 1.0)
	fill.omni_range = FLOOR_FILL_REACH
	fill.omni_attenuation = FLOOR_FILL_FALLOFF
	fill.light_cull_mask = FLOOR_LAYER
	add_child(fill)
	_fill = fill
	# the doors' stairs (ArenaRoom._doors) take Masonry's plain stone at their foot: this room's is darker
	var plain := m.stone(-EXIT_RISE * EXIT_STEPS)
	var dark := _stair_stone(-EXIT_RISE * EXIT_STEPS)
	for k: StringName in [&"stone_a", &"stone_b"]:
		plain.set_shader_parameter(k, dark.get_shader_parameter(k))


## The stone of the steps: Masonry's plain stone at their foot in the value of the walls (STAIR_TINT).
func _stair_stone(base_y: float) -> ShaderMaterial:
	return m.stone(base_y, STONE * STAIR_TINT)


## The great tomb (under the cold shaft) keeps its lid in the value of its stone; the other sarcophagi as ArenaRoom
## draws them.
func sarcophagus(o: ArenaObstacle) -> Vector3:
	var long_x := o.half.x >= o.half.y
	var half := o.half if long_x else Vector2(o.half.y, o.half.x)
	if half.x * 2.0 < TOMB_FROM:
		var top := super.sarcophagus(o)
		_bone()
		return top
	var yaw := -o.yaw + (0.0 if long_x else PI * 0.5)
	var lid := m.stone(0.0, stone_tint() * TOMB_LID_LIGHT)
	var st := stone()
	var hollow := m.stone(0.0, stone_tint() * 0.6)
	if o.see_through:
		st = see(st)
		lid = see(lid)
		hollow = see(hollow)
	return tomb.tomb(o.center, half, yaw, o.height, st, lid, hollow)


## A whole column gets a round moulded capital and a curved springer (column_head); the rest as ArenaRoom draws it.
func piece(o: ArenaObstacle) -> void:
	if o.piece == &"column" and o.height >= WHOLE_COLUMN:
		round_column(o)
		return
	super.piece(o)


# ---------- the walls ----------

## The north and the west walls, with their openings: niches, the fire bowls' recesses, the north door, the arcade.
## The back walls in three steps (_back_wall_west, _back_niches; BuildSteps, QA P1-1): the north wall.
func _back_walls() -> void:
	var t := WALL_SET + WALL_THICK
	var north_a := Vector2(_west - t, _north)
	var north: Array[Vector4] = []
	var deep: Array[float] = []
	var niche_low := LEDGE
	var niche_high := LEDGE + NICHE.y - NICHE.x * 0.4
	for x in NORTH_NICHES:
		north.append(Vector4(x - north_a.x - NICHE.x * 0.5, x - north_a.x + NICHE.x * 0.5, niche_low, niche_high))
		deep.append(-1.0)
	for i in layout.exits.size():
		var e := layout.exits[i]
		if not in_wall(i):
			continue
		var w := absf(e.mouth.size.x)
		var cx := e.mouth.get_center().x - north_a.x
		if i >= exits_used:
			continue  # SL-02: a way not in use is plain wall
		# SL-02 (PT-25-10): the doorway's recess is cut up to its springing line; the pointed top is drawn on the wall (HallDoor.doorway)
		north.append(Vector4(cx - CatacombHall.DOOR_CLEAR.x * 0.5 - CatacombHall.DOOR_FRAME, cx + CatacombHall.DOOR_CLEAR.x * 0.5 + CatacombHall.DOOR_FRAME,
			0.0, HallDoor.spring_of(CatacombHall.DOOR_CLEAR.x, CatacombHall.DOOR_CLEAR.y, CatacombHall.DOOR_ARC)))
		deep.append(0.0)
	for o in layout.obstacles:
		if o.piece == &"brazier" and o.center.y < _north:
			var s := o.center.x - north_a.x
			north.append(Vector4(s - RECESS.x * 0.5, s + RECESS.x * 0.5, 0.0, RECESS.y))
			deep.append(RECESS.z)
	_wall(north_a, Vector2(_east + 1.2, _north), Vector2(0, -1), north, deep)


func _back_wall_west() -> void:
	var niche_low := LEDGE
	var niche_high := LEDGE + NICHE.y - NICHE.x * 0.4
	var west_a := Vector2(_west, _south + FRONT.y)
	var west: Array[Vector4] = []
	var wdeep: Array[float] = []
	for z in WEST_NICHES:
		west.append(Vector4(west_a.y - z - NICHE.x * 0.5, west_a.y - z + NICHE.x * 0.5, niche_low, niche_high))
		wdeep.append(-1.0)
	west.append(Vector4(west_a.y - entry.y - JAMB, west_a.y - entry.x + JAMB, 0.0, WALL_DOOR.y + 0.4))
	wdeep.append(0.0)
	_wall(west_a, Vector2(_west, _north), Vector2(-1, 0), west, wdeep)


func _back_niches() -> void:
	# the niches themselves, their shelves or statues
	var mat := ashlar()
	var hollow := m.stone(0.0, HOLLOW)
	var bone := _bone()
	var k := 0
	for x in NORTH_NICHES:
		_niche(Vector2(x, _north), Vector2(0, 1), STATUE_NICHES.has(k), mat, hollow, bone)
		k += 1
	for z in WEST_NICHES:
		_niche(Vector2(_west, z), Vector2(1, 0), STATUE_NICHES.has(k), mat, hollow, bone)
		k += 1
	# the arches of the north door, the banners with the lion over the fire bowls
	for i in layout.exits.size():
		var e := layout.exits[i]
		if in_wall(i) and i < exits_used:
			_north_door(e.mouth.get_center().x)
	for o in layout.obstacles:
		if o.piece == &"brazier" and o.center.y < _north:
			var from := kit.root.get_child_count()
			kit.banner(Vector3(o.center.x, BANNER_TOP, _north - WALL_SET + 0.06), 0.0, BANNER_SIZE, 1, ArenaKit.Emblem.LION)
			var nodes: Array[Node] = []
			for i in range(from, kit.root.get_child_count()):
				nodes.append(kit.root.get_child(i))
			_banners.append([o.center.x, nodes])


## SL-02 (PT-25-10, docs/art/ref/sala02_2026-11-25): the doors are the hall's big closed ones (HallDoor.doorway: two leaves
## in a pointed arch, black inside, no stairs), in the north wall's face; the chosen one opens (Arena.open_exit).
var _doors_built: Array[HallDoor] = []


func _north_door(x: float) -> void:
	var order := m.ashlar(0.0, STONE * WALL_TINT * CatacombHall.PORTAL_ORDER_TINT)
	_doors_built.append(HallDoor.doorway(m, kit.root, order, Vector3(x, 0.0, _north - WALL_SET), CatacombHall.DOOR_CLEAR,
		CatacombHall.DOOR_ARC, CatacombHall.DOOR_FRAME, DOOR_DEPTH, CatacombHall.DOOR_FACE_OUT))


## The way's light only (a dim cool one in front of each door in use, which Arena.light_exit wakes): no stairs, no grille,
## no medallion rod (the medallion hangs in the doorway).
func _doors() -> void:
	arena.exit_rod = false
	for i in mini(exits_used, layout.exits.size()):
		var e := layout.exits[i]
		var l := OmniLight3D.new()
		l.position = Vector3(e.mouth.get_center().x, DOOR_LIGHT_UP, _north + DOOR_LIGHT_OUT)
		l.light_color = Color(0.5, 0.45, 0.6)
		l.light_energy = DOOR_DIM
		l.omni_range = 7.0
		l.light_cull_mask = ~Arena.CROWD_LAYER
		add_child(l)
		arena._exit_lights.append(l)


## Opens the leaves of door i, in the order of the doors in use.
func open_door_leaves(i: int) -> void:
	if i >= 0 and i < _doors_built.size():
		_doors_built[i].open()


## SL-02 (docs/art/ref/sala02_2026-11-25, "water_feature"): the broken fountain of the north-east corner. A ruined wall of the
## crypt's stone stands behind the east edge (its middle z, its width, height, the lower height of its broken end, its depth
## and how far out of the floor's edge x), a spout in it (height) and a thin fall to a shallow basin on the floor (centre,
## size x and z; its water the canal's, shallow and walkable, only a dressing) with a low broken rim (height, the share of its
## stones standing), and a run-off to the south-west. Everything here is under the knee on the floor or behind the edge:
## nothing collides, nothing slows, nothing hurts. The pack's basin (10, -4.4) moved south-east to clear the slab at
## (8..11, -7.5..-4.5) and the oil urn at (11.2, -1.6).
const FOUNTAIN_WALL := Vector4(-3.4, 3.0, 3.5, 2.3)  # (centre z, width, height, the broken end's height)
const FOUNTAIN_OUT := 0.9
const FOUNTAIN_DEPTH := 0.9
const FOUNTAIN_SPOUT := 1.9
const FOUNTAIN_FALL := Vector2(0.7, 0.25)
const FOUNTAIN_BASIN := Vector4(10.6, -3.4, 2.4, 2.4)
const FOUNTAIN_RIM := Vector2(0.22, 0.7)
const FOUNTAIN_RUNOFF: Array[Vector2] = [Vector2(9.6, -2.5), Vector2(8.7, -1.5), Vector2(7.9, -0.4)]
const FOUNTAIN_RUNOFF_WIDTH := Vector2(0.9, 0.35)
const FOUNTAIN_LIGHT := Color(0.5, 0.7, 0.85)
const FOUNTAIN_LIGHT_AT := Vector3(10.4, 1.6, -3.3)
const FOUNTAIN_ENERGY := 0.9
const FOUNTAIN_SEED := 7733
const FALL_SHADER := preload("res://assets/shaders/waterfall.gdshader")


func _fountain() -> void:
	var edge := _east + FOUNTAIN_OUT
	var stone := m.ashlar(0.0, STONE * WALL_TINT)
	var wall := FOUNTAIN_WALL
	# the wall in three stepped parts (its north end the lowest, broken): z centre, length, height
	for part: Vector3 in [Vector3(wall.x - 1.0, 1.0, wall.w), Vector3(wall.x + 0.1, 1.2, wall.z), Vector3(wall.x + 1.1, 0.8, wall.z * 0.88)]:
		m.block(Vector3(edge, 0.0, part.x), Vector3(FOUNTAIN_DEPTH, part.z, part.y), 0.0, stone)
	var sz := wall.x + 0.1
	# the spout: a carved block jutting from the wall's face and a dark mouth in it
	var face := edge - FOUNTAIN_DEPTH * 0.5
	m.block(Vector3(face - 0.2, FOUNTAIN_SPOUT - 0.2, sz), Vector3(0.5, 0.4, 0.45), 0.0, stone)
	var hollow := m.stone(0.0, HOLLOW * 0.4)
	m.box(Vector3(face - 0.46, FOUNTAIN_SPOUT - 0.12, sz), Vector3(0.08, 0.22, 0.26), 0.0, hollow, false)
	# the fall: a quad from the spout to the basin, facing the room
	var fall := MeshInstance3D.new()
	var quad := QuadMesh.new()
	var drop := FOUNTAIN_SPOUT - FOUNTAIN_FALL.y
	quad.size = Vector2(FOUNTAIN_FALL.x, drop)
	fall.mesh = quad
	var fm := ShaderMaterial.new()
	fm.shader = FALL_SHADER
	fall.material_override = fm
	fall.position = Vector3(face - 0.62, FOUNTAIN_FALL.y + drop * 0.5, sz)
	fall.rotation.y = -PI * 0.5
	fall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	kit.root.add_child(fall)
	# the basin and the run-off: the canal's water (shallow, walkable)
	var water := Canal.water(Vector2(FOUNTAIN_BASIN.x, FOUNTAIN_BASIN.y), false, _compat())
	water.set_shader_parameter(&"deep", Color(0.05, 0.1, 0.13))
	water.set_shader_parameter(&"shallow", Color(0.1, 0.19, 0.23))
	var b := FOUNTAIN_BASIN
	var lens := PackedVector2Array()
	var lens_w := PackedFloat32Array()
	var lens_wide := PackedFloat32Array()
	for k in 9:
		var u := float(k) / 8.0
		lens.append(Vector2(b.x, b.y + (u - 0.5) * b.w))
		var w := b.z * pow(sin(PI * clampf(u, 0.05, 0.95)), 0.5)
		lens_w.append(w)
		lens_wide.append(w * Canal.BANK)
	kit.root.add_child(CatacombHall.floor_strip(lens, 1.0, Canal.DAMP_Y, HallLife.decal(HallLife.WATER_DAMP, 0.55), false, lens_wide))
	kit.root.add_child(CatacombHall.floor_strip(lens, 1.0, Canal.WATER_Y, water, false, lens_w))
	var run := PackedVector2Array([Vector2(b.x - 0.4, b.y + b.w * 0.4)])
	run.append_array(PackedVector2Array(FOUNTAIN_RUNOFF))
	var run_w := PackedFloat32Array()
	var run_wide := PackedFloat32Array()
	for k in run.size():
		run_w.append(lerpf(FOUNTAIN_RUNOFF_WIDTH.x, FOUNTAIN_RUNOFF_WIDTH.y, float(k) / (run.size() - 1)))
		run_wide.append(run_w[k] * Canal.BANK)
	kit.root.add_child(CatacombHall.floor_strip(run, 1.0, Canal.DAMP_Y, HallLife.decal(HallLife.WATER_DAMP, 0.6), false, run_wide))
	kit.root.add_child(CatacombHall.floor_strip(run, 1.0, Canal.WATER_Y + 0.001, water, false, run_w))
	kit.root.add_child(CatacombHall.floor_strip(PackedVector2Array([Vector2(b.x - 0.6, b.y), Vector2(b.x - 2.4, b.y + 1.2)]), 2.6, Canal.DAMP_Y - 0.002,
		HallLife.decal(HallLife.WATER_MOSS, 0.7, true), false))
	# the broken rim: stones round the basin's edge, some fallen away
	var r := RandomNumberGenerator.new()
	r.seed = FOUNTAIN_SEED
	for k in 14:
		if r.randf() > FOUNTAIN_RIM.y:
			continue
		var a := TAU * float(k) / 14.0
		var at := Vector2(b.x + cos(a) * (b.z * 0.5 + 0.1), b.y + sin(a) * (b.w * 0.5 + 0.1))
		if at.x > _east - 0.4:
			continue
		var h := FOUNTAIN_RIM.x * r.randf_range(0.55, 1.0)
		m.box(Vector3(at.x, h * 0.5 - 0.01, at.y), Vector3(0.45, h, 0.34), -a + PI * 0.5, null, true)
	# the cold accent (no shadow, never on the crowd): water the colour of the room, not magic
	var l := OmniLight3D.new()
	l.position = FOUNTAIN_LIGHT_AT
	l.light_color = FOUNTAIN_LIGHT
	l.light_energy = FOUNTAIN_ENERGY
	l.omni_range = 5.0
	l.shadow_enabled = false
	l.light_cull_mask = ~Arena.CROWD_LAYER
	add_child(l)


func _niche(at: Vector2, facing: Vector2, statue: bool, mat: Material, hollow: Material, bone: Material) -> void:
	var face := at - facing * WALL_SET
	var floor_mid := tomb.niche(Vector3(face.x, LEDGE, face.y), facing, NICHE.x, NICHE.y, NICHE.z, mat, hollow, bone, not statue)
	if not statue:
		return
	kit.statue(Vector2(floor_mid.x, floor_mid.z), atan2(facing.x, facing.y), STATUE, floor_mid.y, ArenaKit.STATUE_VALUE, false)
	var front := Vector3(floor_mid.x + facing.x * 2.5, LEDGE + STATUE + 1.0, floor_mid.z + facing.y * 2.5)
	kit.statue_glow(front, floor_mid + Vector3(0, STATUE * 0.6, 0), STATUE_GLOW.x, STATUE_GLOW.y, STATUE_GLOW.z)


## A wall along a to b, its face WALL_SET behind the floor's edge (out: away from the room) with a ledge LEDGE high in
## front, WALL_HEIGHT tall; openings (x, y: from and to along it from a; z, w: from and to in height) where there is no
## wall, each a recess `deep` behind the face (0: through; below 0: the niche fills it).
func _wall(a: Vector2, b: Vector2, out: Vector2, openings: Array[Vector4], deep: Array[float]) -> void:
	var mat := m.ashlar(0.0, STONE * WALL_TINT)
	var length := a.distance_to(b)
	var t0 := WALL_SET
	var t1 := WALL_SET + WALL_THICK
	# the stretches with no opening: the whole height
	var cuts: Array[Vector2] = []
	for o in openings:
		cuts.append(Vector2(o.x, o.y))
	cuts.sort_custom(func(p: Vector2, q: Vector2) -> bool: return p.x < q.x)
	var s := 0.0
	for c in cuts:
		if c.x > s:
			_part(a, b, out, s, c.x, t0, t1, 0.0, WALL_HEIGHT, mat)
			_part(a, b, out, s, c.x, 0.0, t0, 0.0, LEDGE, mat)
		s = maxf(s, c.y)
	if s < length:
		_part(a, b, out, s, length, t0, t1, 0.0, WALL_HEIGHT, mat)
		_part(a, b, out, s, length, 0.0, t0, 0.0, LEDGE, mat)
	# round each opening: under it, over it, its back
	for i in openings.size():
		var o := openings[i]
		if o.z > 0.0:
			_part(a, b, out, o.x, o.y, t0, t1, 0.0, o.z, mat)
			_part(a, b, out, o.x, o.y, 0.0, t0, 0.0, minf(o.z, LEDGE), mat)
		if o.w < WALL_HEIGHT:
			_part(a, b, out, o.x, o.y, t0, t1, o.w, WALL_HEIGHT, mat)
		if deep[i] > 0.0:
			_part(a, b, out, o.x, o.y, t0 + deep[i], t1, o.z, o.w, mat)
		elif deep[i] < 0.0:
			_part(a, b, out, o.x, o.y, t0 + NICHE.z, t1, o.z, o.w, mat)
	# a string course and the cornice, the whole length
	# (the string course stops at a doorway: its leaves and arch stand in the face)
	var doors: Array[Vector2] = []
	for i in openings.size():
		if deep[i] == 0.0 and openings[i].z == 0.0:
			doors.append(Vector2(openings[i].x, openings[i].y))
	doors.sort_custom(func(p: Vector2, q: Vector2) -> bool: return p.x < q.x)
	var runs: Array[Vector2] = []
	var at := 0.0
	for d in doors:
		runs.append(Vector2(at, d.x))
		at = d.y
	runs.append(Vector2(at, length))
	for r in runs:
		_part(a, b, out, r.x, r.y, t0 - COURSE.y, t0, COURSE.x, COURSE.x + 0.22, mat)
	_part(a, b, out, 0.0, length, t0 - CORNICE.y, t1, WALL_HEIGHT - CORNICE.x, WALL_HEIGHT, mat)


## One block of a wall: from s0 to s1 along a to b, from d0 to d1 out of the edge, from y0 to y1.
func _part(a: Vector2, b: Vector2, out: Vector2, s0: float, s1: float, d0: float, d1: float, y0: float, y1: float, mat: Material) -> void:
	if s1 - s0 < 0.02 or y1 - y0 < 0.02:
		return
	var along := (b - a).normalized()
	var c := a + along * (s0 + s1) * 0.5 + out * (d0 + d1) * 0.5
	m.box(Vector3(c.x, (y0 + y1) * 0.5, c.y), Vector3(s1 - s0, y1 - y0, d1 - d0), atan2(-along.y, along.x), mat, false)


## The south and east walls cut at FRONT.x (spec 2.1): cut stone on both faces, the dark fill between them on the
## cut, the outer face dropping into the dark, the doors' gaps, fallen blocks outside.
func _front_walls() -> void:
	var skin := m.ashlar(0.0, STONE * WALL_TINT)
	var fill := m.stone(0.0, HOLLOW * 1.4)
	var runs: Array = [[Vector2(_west - WALL_SET - WALL_THICK, _south), Vector2(_east + FRONT.y, _south), Vector2(0, 1)],
		[Vector2(_east, _south), Vector2(_east, _north - 0.5), Vector2(1, 0)]]
	for run: Array in runs:
		var a: Vector2 = run[0]
		var b: Vector2 = run[1]
		var out: Vector2 = run[2]
		var along := (b - a).normalized()
		var length := a.distance_to(b)
		var gaps: Array[Vector2] = []
		for e in layout.exits:
			if e.inward.dot(-out) > 0.9:
				var w := absf(e.mouth.size.dot(along))
				var s := (e.mouth.get_center() - a).dot(along)
				gaps.append(Vector2(s - w * 0.5 - EXIT_CHEEK.x, s + w * 0.5 + EXIT_CHEEK.x))
		var s0 := 0.0
		gaps.append(Vector2(length, length))
		for g in gaps:
			if g.x > s0:
				var skin_w := FRONT.y * (1.0 - FRONT_FILL) * 0.5
				_part(a, b, out, s0, g.x, 0.0, skin_w, -FRONT_DROP, FRONT.x, skin)
				_part(a, b, out, s0, g.x, FRONT.y - skin_w, FRONT.y, -FRONT_DROP, FRONT.x - 0.06, skin)
				_part(a, b, out, s0, g.x, skin_w, FRONT.y - skin_w, -FRONT_DROP, FRONT.x - 0.1, fill)
				_fallen(a, along, out, s0, g.x)
			s0 = g.y


## Blocks fallen outside a front wall between s0 and s1.
func _fallen(a: Vector2, along: Vector2, out: Vector2, s0: float, s1: float) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i((a + along * s0) * 10.0))
	for k in floori((s1 - s0) * FRONT_FALLEN):
		var p := a + along * r.randf_range(s0 + 0.3, s1 - 0.3) + out * (FRONT.y + r.randf_range(0.3, 1.2))
		var size := r.randf_range(0.3, 0.7)
		var blk := m.box(Vector3(p.x, -r.randf_range(0.6, 2.2), p.y), Vector3(size, size * 0.7, size * 0.9), r.randf() * TAU, ashlar())
		blk.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.6, 0.6))


## The heap of fallen blocks over the cut corner (spec 2.1): from HEAP_HEIGHT.x at the floor's edge to HEAP_HEIGHT.y
## at the walls, its foot the edge (no block on the floor).
func _heap() -> void:
	var poly := layout.floor.polys[0]
	# the cut: the edge of the outline that is neither along x nor along z
	var p := Vector2.ZERO
	var q := Vector2.ZERO
	for i in poly.size():
		var a := poly[i]
		var c := poly[(i + 1) % poly.size()]
		if absf(a.x - c.x) > 0.5 and absf(a.y - c.y) > 0.5:
			p = a
			q = c
	if p == q:
		return
	var along := (q - p).normalized()
	var out := Vector2(along.y, -along.x)
	if layout.floor.covers((p + q) * 0.5 + out * 0.3):
		out = -out
	var corner := Vector2(maxf(p.x, q.x), minf(p.y, q.y))
	var reach := (corner - p).dot(out)
	var r := RandomNumberGenerator.new()
	r.seed = 9127
	var mat := ashlar()
	# a mound under it, a little back from the edge
	var off := out * 0.5
	m.prism(PackedVector2Array([p + off, q + off, corner + Vector2(1.5, -1.5)]), -0.2, HEAP_HEIGHT.y * 0.45, m.stone(0.0, HOLLOW * 1.6))
	for k in HEAP:
		var size := r.randf_range(HEAP_BLOCK.x, HEAP_BLOCK.y)
		var d := r.randf_range(size * 0.75 + 0.05, reach + 1.2)
		var c := p + along * r.randf_range(0.0, p.distance_to(q)) + out * d
		var h := lerpf(HEAP_HEIGHT.x, HEAP_HEIGHT.y, clampf(d / (reach + 1.2), 0.0, 1.0))
		var blk := m.box(Vector3(c.x, h - size * 0.4, c.y), Vector3(size, size * 0.6, size * 0.8), r.randf() * TAU, mat)
		blk.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.5, 0.5))
		blk.rotate_object_local(Vector3.BACK, r.randf_range(-0.4, 0.4))


## The way in (spec 2.4): stairs going up out of the arcade in the west wall, its arch, the gold sill on the edge.
func _entry() -> void:
	var mid := Vector2(_west, (entry.x + entry.y) * 0.5)
	var w := entry.y - entry.x
	door_arch(mid, Vector2(1, 0), w, WALL_SET + 0.45)
	m.stairs(Vector3(_west - 0.05, 0.0, mid.y), Vector2(-1, 0), w, ENTRY_STEPS, 0.2, 0.45, _stair_stone(0.0))
	tomb.bar(Vector3(_west + 0.04, 0.004, mid.y), Vector3(0.05, 0.008, w), 0.0, tomb.gold())


# ---------- the floor's slabs, candles and light ----------

func _slabs() -> void:
	var st := _own_paint(m.stone(0.0, STONE * SLAB_STONE), STY_OLD_SLAB.x)
	var fr := _own_paint(m.stone(0.0, STONE * SLAB_FRAME), STY_OLD_SLAB.y)
	var border := _own_paint(m.stone(0.0, HOLLOW * SLAB_BORDER_TINT), STY_OLD_SLAB.z)
	for s in SLAB_ROWS:
		var at := Vector2(s.x, s.y)
		if not _clear(at, SLAB.length() * 0.5):
			continue
		var h := SLAB * 0.5 + Vector2.ONE * SLAB_BORDER.x
		m.prism(PackedVector2Array([at - h, at + Vector2(h.x, -h.y), at + h, at + Vector2(-h.x, h.y)]), 0.0, SLAB_BORDER.y, border)
		tomb.slab(at, SLAB, 0.0, st, fr)


## C-1 of the Sworn P1 review: the old grave slabs' own stone (a twin of `mat`, the classic the same; the slab's stone
## is the stairs' too) painted at paint_ref `ref` in the stylized look (ArenaKit.PAINT_OWN).
func _own_paint(mat: ShaderMaterial, ref: float) -> ShaderMaterial:
	var own := mat.duplicate() as ShaderMaterial
	own.set_meta(ArenaKit.PAINT_OWN, {&"paint_ref": ref})
	return own


## True when nothing of the layout stands within `r` of p.
func _clear(p: Vector2, r: float) -> bool:
	for o in layout.obstacles:
		if o.blocks_move and o.depth(p, r) > 0.0:
			return false
	return true


## Candles on the pieces (spec 2.2 and 2.3): on the lids, the tomb's steps, the columns' bases, the ledges; three groups
## light the floor with shadows (A: the north sarcophagus, the tomb's west step, the south column; B: the two south
## sarcophagi and the dividing wall's foot), up to CANDLE_PLAIN more without. In B the west bay's are burnt out.
func _candles() -> void:
	var divider := _divider()
	var ossuary := divider != null
	for o in layout.obstacles:
		match o.piece:
			&"sarcophagus":
				var long_x := o.half.x >= o.half.y
				var half := o.half if long_x else Vector2(o.half.y, o.half.x)
				var axis := Vector3(1, 0, 0) if long_x else Vector3(0, 0, 1)
				var c := Vector3(o.center.x, o.height, o.center.y)
				if half.x * 2.0 >= ArenaRoom.TOMB_FROM:
					# the great tomb: candles on the upper step at its west end, and at its east end
					var west := c - axis * (half.x - 0.45)
					west.y = TombKit.TOMB_STEP * 2.0
					var side := Vector3(axis.z, 0, axis.x) * (half.y - 0.35)
					candle_line(west - side, west + side, 4)
					_tomb_light = _light_at(west + Vector3(0, 0.6, 0), true)
					var east := c + axis * (half.x - 0.45)
					east.y = TombKit.TOMB_STEP * 2.0
					candle_line(east - side * 0.6, east + side * 0.6, 3)
					continue
				var against := arena.shape().edge_distance(o.center) < half.y + 0.4
				var end := c + axis * (half.x - 0.35) * (1.0 if o.center.x > 0.0 else -1.0)
				var lit := not (ossuary and against)
				var from := m.root.get_child_count()
				candle_line(end - Vector3(axis.z, 0, axis.x) * 0.25, end + Vector3(axis.z, 0, axis.x) * 0.25, 3, lit)
				var group := [_flames_since(from), null]
				if not ossuary:
					_groups.append(group)
				if lit:
					var shadow := (o.center.y < 0.0 and not against) if not ossuary else o.center.y > 0.0
					var l := _light_at(end + Vector3(0, 0.5, 0), shadow)
					if ossuary and l != null:
						l.set_meta(ArenaKit.FIRE_SHARE, STY_LID_LIGHT)
					if l != null:
						_lid_lights.append([o.center, l])
					group[1] = l
			&"column":
				var ring := o.radius * 0.86
				var foot := Vector3(o.center.x, TombKit.COLUMN_BASE, o.center.y)
				var toward := Vector3(0.57, 0, 0.82)
				var a := foot + toward.rotated(Vector3.UP, 0.6) * ring
				var b := foot + toward.rotated(Vector3.UP, -0.6) * ring
				var from := m.root.get_child_count()
				candle_line(a, b, 3)
				var group := [_flames_since(from), null]
				# the column nearest the camera lights its foot with shadows (A)
				if not ossuary and o.center.y > 0.0:
					group[1] = _light_at(foot + toward * ring + Vector3(0, 0.5, 0), true)
				if not ossuary:
					_groups.append(group)
	if ossuary:
		var tip := Vector3(divider.center.x, LEDGE * 0.5, divider.center.y + divider.half.y + 0.3)
		_light_at(tip + Vector3(0, 0.6, 0), true)
	# along the ledges of the back walls, plain
	for x: float in [-5.6, 0.6]:
		var from := m.root.get_child_count()
		candle_line(Vector3(x - 0.3, LEDGE, _north - WALL_SET * 0.5), Vector3(x + 0.3, LEDGE, _north - WALL_SET * 0.5), 3, not ossuary or x > 0.5)
		if not ossuary:
			_groups.append([_flames_since(from), null])
	for z: float in [-3.6, 1.8]:
		var from := m.root.get_child_count()
		candle_line(Vector3(_west - WALL_SET * 0.5, LEDGE, z - 0.3), Vector3(_west - WALL_SET * 0.5, LEDGE, z + 0.3), 3, not ossuary)
		if not ossuary:
			_groups.append([_flames_since(from), null])


## The candle flames (and cores) built on m since child `from` (R-1: they are never merged, so they can be hidden).
func _flames_since(from: int) -> Array:
	var out := []
	for i in range(from, m.root.get_child_count()):
		var mi := m.root.get_child(i) as MeshInstance3D
		if mi != null and mi.mesh is QuadMesh:
			out.append(mi)
	return out


## A warm light over candles: with shadow (counted) or plain (at most CANDLE_PLAIN).
func _light_at(at: Vector3, shadow: bool) -> OmniLight3D:
	if shadow:
		return warm_light(at, CANDLE_SHADOW_ENERGY, true)
	if _plain_lights < CANDLE_PLAIN:
		_plain_lights += 1
		return warm_light(at)
	return null


## The dividing wall of the ossuary (variant B), if any: a tall wall-like block.
func _divider() -> ArenaObstacle:
	for o in layout.obstacles:
		if o.piece == &"block" and o.height > 2.0 and o.shape == ArenaObstacle.Shape.BOX:
			return o
	return null


## The dividing wall (variant B): cut stone with rows of shallow ossuary niches on both faces and, at its south end, a
## pillar with the raised sword on its panel (the Seal Chamber's pinnacle, slimmer).
func ruin_wall(o: ArenaObstacle) -> void:
	if o.height <= 2.0:
		super.ruin_wall(o)
		return
	var mat := see(ashlar())
	var long_x := o.half.x >= o.half.y
	var length := maxf(o.half.x, o.half.y) * 2.0
	var width := minf(o.half.x, o.half.y) * 2.0
	var yaw := 0.0 if long_x else PI * 0.5
	var basis := Basis(Vector3.UP, yaw)
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	var pillar := width
	m.block(foot - basis * Vector3(pillar * 0.5, 0, 0) * (1.0 if long_x else -1.0), Vector3(length - pillar, o.height, width), yaw, mat, false)
	var hollow := see(m.stone(0.0, HOLLOW))
	var bone := see(_bone())
	# the shallow niches: three rows of dark arched panels, a bundle of bones in each
	for sd: float in [-1.0, 1.0]:
		for row in 3:
			var y := 0.6 + row * 0.85
			var n := floori((length - pillar - 0.6) / 0.9)
			for k in n:
				var s := -length * 0.5 + 0.45 + 0.9 * (k + 0.5)
				var along := Vector3(s, 0, 0) if long_x else Vector3(0, 0, s)
				var face := Vector3(0, 0, sd * width * 0.5) if long_x else Vector3(sd * width * 0.5, 0, 0)
				m.box(foot + along + face * 0.99 + Vector3(0, y, 0), Vector3(0.62, 0.55, 0.02) if long_x else Vector3(0.02, 0.55, 0.62), 0.0, hollow, false)
				m.box(foot + along + face * 0.97 + Vector3(0, y - 0.18, 0), Vector3(0.45, 0.08, 0.08) if long_x else Vector3(0.08, 0.08, 0.45), 0.0, bone, false)
	# the pillar at the south end (the end toward +z when it runs along z), facing the room
	var tip := foot + (Vector3(o.half.x - pillar * 0.5, 0, 0) if long_x else Vector3(0, 0, o.half.y - pillar * 0.5))
	tomb.pinnacle(tip, 0.0 if not long_x else PI * 0.5, mat, Vector3(width - 0.16, o.height - 0.2, 0.45))


## The cold shaft of light from a crack in the vault (spec 2.5), on the great tomb (A) or the dividing wall's end (B),
## with its dust falling.
func _cold_shaft() -> void:
	var target := Vector2.ZERO
	var found := false
	var divider := _divider()
	if divider != null:
		target = divider.center + Vector2(0, divider.half.y + 0.8)
		found = true
	else:
		for o in layout.obstacles:
			if o.piece == &"sarcophagus" and maxf(o.half.x, o.half.y) * 2.0 >= ArenaRoom.TOMB_FROM:
				target = o.center
				found = true
	if not found:
		return
	var spot := SpotLight3D.new()
	add_child(spot)
	var to := Vector3(target.x, 0.0, target.y)
	spot.look_at_from_position(to + Vector3(COLD_LEAN.x, COLD_HEIGHT, COLD_LEAN.y), to)
	spot.light_color = COLD
	spot.light_energy = COLD_ENERGY
	spot.spot_angle = COLD_ANGLE
	# no fall-off with distance (only the range's window): the energy is what reaches the floor
	spot.spot_range = COLD_HEIGHT * 2.0
	spot.spot_attenuation = 0.0
	spot.shadow_enabled = true
	spot.light_cull_mask = ~Arena.CROWD_LAYER
	_shaft = spot
	arena._dust(to)
	_shaft_dust = arena.get_child(arena.get_child_count() - 1) as Node3D


# ---------- the stylized look (room redesign, lot A part 2) ----------

func style() -> Dictionary:
	var st := STYLE.duplicate(true)
	st[&"floor"] = ArenaKit.framed(ArenaKit.CALM_FLOOR.merged(ArenaKit.SOFT_PATCHES).merged(STY_FLOOR_BIOME), _graves(_divider() != null))
	if _compat():
		st[&"air"][&"ambient_gain"] = float(st[&"air"][&"ambient_gain"]) * STY_COMPAT_AMBIENT
		st[&"air"][&"moon_energy"] = float(st[&"air"][&"moon_energy"]) * STY_COMPAT_MOON
	st[&"off"] = [_key, _fill]
	if _shaft != null:
		VisualProfile.vary(_shaft, {&"light_color": STY_COLD})
	var divider := _divider()
	if divider == null:
		_quiet_a(st)
	else:
		_quiet_b(divider)
	return st


## SW-C1 and SW-G3: the grave slabs of the rows and the pair of raised frames (STY_GRAVES_*, STY_FRAMES_*).
func _graves(ossuary: bool) -> Array:
	var out := []
	var k := 0
	for row: Array in [[STY_GRAVES_NORTH, SLAB_ROWS[0].y], [STY_GRAVES_SOUTH, SLAB_ROWS[3].y]]:
		for g: Vector2 in row[0]:
			if ossuary and is_equal_approx(g.x, STY_GRAVES_B_SKIP):
				continue
			if not clear_of_plates(Vector2(g.x, row[1]), SLAB) or not _slab_free(Vector2(g.x, row[1]), SLAB):
				continue  # never a grave slab on or by a slab that strikes (RP-06), nor under a piece (an urn, AT-Q)
			out.append(ArenaKit.framed_slab(Vector2(g.x, row[1]), SLAB,
				ArenaKit.Framed.GRAVE, g.y > 0.5, STY_GRAVE_VALUE, k))
			k += 1
	var frames: Array[Vector2] = STY_FRAMES_B if ossuary else STY_FRAMES_A
	var side := STY_FRAME_B if ossuary else STY_FRAME_A
	for f in frames:
		if not clear_of_plates(f, Vector2.ONE * side) or not _slab_free(f, Vector2.ONE * side):
			continue
		var lion := ossuary and STY_LION_FRAME_B and f == frames[0]
		out.append(ArenaKit.framed_slab(f, Vector2.ONE * side, ArenaKit.Framed.GRAVE if lion else ArenaKit.Framed.RAISED,
			lion, STY_GRAVE_VALUE if lion else 1.0, k))
		k += 1
	return out


## True when a drawn slab of this middle and size lies under no piece of the room (its corners, sides' middles, middle).
func _slab_free(at: Vector2, size: Vector2) -> bool:
	for u: float in [-1.0, 0.0, 1.0]:
		for v: float in [-1.0, 0.0, 1.0]:
			if arena.overlaps(at + Vector2(u * size.x, v * size.y) * 0.5, 0.0):
				return false
	return true


## RS-C1, A in the stylized look: the crown makes the light of the tomb's west step (out), the north sarcophagus's
## candles, the statues' (on their light, _sill) and the fire bowls a step under it, the cold shaft softer.
func _quiet_a(st: Dictionary) -> void:
	if _tomb_light != null:
		(st[&"off"] as Array).append(_tomb_light)
	var tomb_at := _great_tomb().center if _great_tomb() != null else Vector2.ZERO
	var north: OmniLight3D
	var near := INF
	for e: Array in _lid_lights:
		var c: Vector2 = e[0]
		if c.y < tomb_at.y and c.distance_to(tomb_at) < near:
			near = c.distance_to(tomb_at)
			north = e[1]
	if north != null:
		north.set_meta(ArenaKit.FIRE_SHARE, STY_NORTH_LID)
	for n in find_children("*", "OmniLight3D", true, false):
		if n.has_meta(ArenaKit.BOWL):
			n.set_meta(ArenaKit.FIRE_SHARE, STY_BOWLS)
	if _shaft != null:
		VisualProfile.vary(_shaft, {&"light_energy": STY_TOMB_SHAFT})
	# R-1: every other group of candles out
	for i in _groups.size():
		if i % 2 != STY_GROUPS_OUT:
			continue
		var group: Array = _groups[i]
		for f: Node in group[0]:
			if is_instance_valid(f):
				VisualProfile.vary(f, {&"visible": false})
		if group[1] != null:
			(st[&"off"] as Array).append(group[1])


## RS-C1, B in the stylized look: the north door's fire bowls cold, the banner beside the veiled figure gone, the cold
## shaft on the figure (its dust hidden: it fell on the floor where no light is now).
func _quiet_b(divider: ArenaObstacle) -> void:
	for o in layout.obstacles:
		if o.piece == &"brazier" and o.center.y < _north:
			kit.quench(o.center)
	var nearest: Array = []
	for b: Array in _banners:
		if nearest.is_empty() or absf(float(b[0]) - divider.center.x) < absf(float(nearest[0]) - divider.center.x):
			nearest = b
	if not nearest.is_empty():
		for n: Node in nearest[1]:
			VisualProfile.vary(n, {&"visible": false})
	if _shaft != null:
		var foot := _veiled_foot(divider)
		var aimed := Transform3D.IDENTITY.translated(STY_SHAFT_FROM).looking_at(foot + Vector3(0, STY_SHAFT_AIM, 0))
		VisualProfile.vary(_shaft, {&"transform": aimed, &"spot_angle": STY_SHAFT.x, &"light_energy": STY_SHAFT.y})
	if _shaft_dust != null:
		VisualProfile.vary(_shaft_dust, {&"visible": false})
	_ossuary_wash(divider)
	_entry_warm()


## AT-CB1: the warm light at the way in (see STY_ENTRY_WARM).
func _entry_warm() -> void:
	var w := STY_ENTRY_WARM
	var l := warm_light(Vector3(_west + w.x, w.y, (entry.x + entry.y) * 0.5), w.z, false, w.w)
	l.light_specular = 0.0
	l.set_meta(ArenaKit.NOT_FIRE, true)
	ArenaKit.style_only(l)


## Item 4 of the cycle: the cold wash on the ossuary wall's niches (STY_OSSUARY_WASH_*), only in the stylized look.
func _ossuary_wash(divider: ArenaObstacle) -> void:
	var long_x := divider.half.x >= divider.half.y
	var face := Vector3(0, 0, 1) if long_x else Vector3(1, 0, 0)
	var along := Vector3(1, 0, 0) if long_x else Vector3(0, 0, 1)
	var mid := Vector3(divider.center.x, STY_OSSUARY_WASH_AIM, divider.center.y)
	var f := STY_OSSUARY_WASH_FROM
	var spot := SpotLight3D.new()
	add_child(spot)
	ArenaKit.style_only(spot)
	spot.look_at_from_position(mid + face * f.x + Vector3.UP * f.y + along * f.z, mid)
	spot.light_color = STY_COLD
	spot.light_energy = STY_OSSUARY_WASH.x
	spot.spot_angle = STY_OSSUARY_WASH.y
	spot.spot_range = STY_OSSUARY_WASH.z
	spot.light_specular = 0.0
	spot.shadow_enabled = false
	spot.light_cull_mask = ~Arena.CROWD_LAYER
	spot.set_meta(ArenaKit.NOT_FIRE, true)


## The great tomb of variant A (null in B).
func _great_tomb() -> ArenaObstacle:
	for o in layout.obstacles:
		if o.piece == &"sarcophagus" and maxf(o.half.x, o.half.y) * 2.0 >= ArenaRoom.TOMB_FROM:
			return o
	return null


## The bones' stone. Masonry keys its materials by the tint's html, which clamps at 1: BONE, the small sarcophagi's
## body (SARC_TINT) and lid (SARC_LID_LIGHT) are one material, whichever made it first (the classic look as it always
## was). In the stylized look that light stone is painted at the plain stone's value and its candles' pools soft (the
## warm pool over the cold air burnt the lids cream); the bones stay a light stone, not ivory (ArenaKit.PAINT_OWN; the
## see-through twins copy the meta).
func _bone() -> ShaderMaterial:
	var b := m.stone(0.0, BONE)
	b.set_meta(ArenaKit.PAINT_OWN, {&"paint_ref": STY_PAINT_REF * STY_LIGHT_STONE, &"paint_pool_gain": STY_LID_POOL})
	return b


## The pieces only the stylized look shows (spec 2.3 to 2.5), all on kit.styled() (never the room's random numbers:
## the classic pieces stay where they were): the effigy, urns, candles, the slabs' inscriptions, the cold glow behind
## the north door, the mist beyond the cut walls; in B the veiled figure and the urns on the ossuary wall.
func _dress_styled() -> void:
	BuildSteps.run(_dress_styled_steps())


## _dress_styled in steps (BuildSteps; QA P1-1: a frame each on a new room's black screen).
func _dress_styled_steps() -> Array[Callable]:
	var v := {}
	return [
		func() -> void:
			var sm := kit.styled()
			var st := TombKit.new(sm)
			var urn := sm.carved(LEDGE, STONE)
			var divider := _divider()
			v[&"sm"] = sm
			v[&"st"] = st
			v[&"urn"] = urn
			v[&"divider"] = divider
			# A1: the effigy on the great tomb
			for o in layout.obstacles:
				if o.piece == &"sarcophagus" and maxf(o.half.x, o.half.y) * 2.0 >= ArenaRoom.TOMB_FROM:
					var long_x := o.half.x >= o.half.y
					st.effigy(Vector3(o.center.x + EFFIGY.y, o.height, o.center.y), EFFIGY.x, 0.0 if long_x else PI * 0.5,
						sm.carved(o.height, STONE * EFFIGY_LIGHT))
					_crown(sm, o)
					_pall(sm, o)
			# A2, A3: urns on the ledges
			var ny := _north - WALL_SET * 0.5
			for u in NORTH_URNS:
				if _clear(Vector2(u.x, _north), URN_CLEAR):
					sm.urn(Vector3(u.x, LEDGE, ny), u.y, urn)
			sm.candle_out(Vector3(NORTH_STUB.x, LEDGE, ny), NORTH_STUB.y, 0.06)
			var wx := _west - WALL_SET * 0.5
			var placed := 0
			for u in WEST_URNS:
				if placed < 3 and _clear(Vector2(_west, u.x), URN_CLEAR) and absf(u.x - (entry.x + entry.y) * 0.5) > 2.6:
					sm.urn(Vector3(wx, LEDGE, u.x), u.y, urn)
					placed += 1,
		func() -> void:
			var sm: Masonry = v[&"sm"]
			var urn: Material = v[&"urn"]
			var divider: Variant = v[&"divider"]
			# A4, A5: the niches' sills
			var k := 0
			for x in NORTH_NICHES:
				_sill(sm, Vector2(x, _north), Vector2(0, 1), STATUE_NICHES.has(k), urn, divider != null)
				k += 1
			for z in WEST_NICHES:
				_sill(sm, Vector2(_west, z), Vector2(1, 0), STATUE_NICHES.has(k), urn)
				k += 1
			# A6: burnt-out candles at the other end of the lit small sarcophagi's lids
			for o in layout.obstacles:
				if o.piece != &"sarcophagus" or maxf(o.half.x, o.half.y) * 2.0 >= ArenaRoom.TOMB_FROM or o.shape != ArenaObstacle.Shape.BOX:
					continue
				var long_x := o.half.x >= o.half.y
				var half := o.half if long_x else Vector2(o.half.y, o.half.x)
				if arena.shape().edge_distance(o.center) < half.y + 0.4 or o.height > 2.0:
					continue
				var axis := Vector3(1, 0, 0) if long_x else Vector3(0, 0, 1)
				var across := Vector3(axis.z, 0, axis.x)
				var end := Vector3(o.center.x, o.height, o.center.y) - axis * (half.x - 0.35) * (1.0 if o.center.x > 0.0 else -1.0)
				for i in LID_STUBS:
					sm.candle_out(end + across * (i - 1) * 0.2, 0.08 + 0.04 * (i % 2), 0.055),
		func() -> void:
			var sm: Masonry = v[&"sm"]
			var divider: Variant = v[&"divider"]
			# A7: the grave slabs' worn inscriptions
			var ink := _own_paint(sm.stone(0.0, STONE * INSCRIPTION_TINT), STY_OLD_SLAB.w)
			for sl in SLAB_ROWS:
				var at := Vector2(sl.x, sl.y)
				if _clear(at, SLAB.length() * 0.5):
					_inscription(sm, at, ink)
			# the cold glow behind the north door, the mist beyond the cut walls
			for i in layout.exits.size():
				if in_wall(i) and i < exits_used:
					_door_glow(layout.exits[i], divider != null)
			var mist := FRONT_MIST_COLOR * 2.0
			var c := Vector2((_west + _east) * 0.5, (_north + _south) * 0.5)
			var before := kit.root.get_child_count()
			kit.mist_bank(Vector3(c.x, FRONT_MIST.y, _south + FRONT.y + FRONT_MIST.x), Vector2(_east - _west + 8.0, FRONT_MIST.z), mist, FRONT_MIST.w)
			kit.mist_bank(Vector3(_east + FRONT.y + FRONT_MIST.x, FRONT_MIST.y, c.y), Vector2(_south - _north + 8.0, FRONT_MIST.z), mist, FRONT_MIST.w)
			for i in range(before, kit.root.get_child_count()):
				ArenaKit.style_only(kit.root.get_child(i) as Node3D)
			if divider != null:
				_ossuary_crown(sm, divider),
		func() -> void:
			var mid := arena.shape().bounds().get_center() + STY_WARM_SHIFT
			key_pool(Vector3(mid.x, mid.y, STY_WARM_RADIUS), CatacombHall.STY_WARM_KEY, CatacombHall.STY_WARM_ENERGY)
			_edge_pieces(),
		func() -> Array[Callable]:
			return _ossuary(v[&"sm"]),
	]


## Sworn P2 SW-C2: stacks of thigh bones on the ledge against the north and west walls (FEMUR_STACKS: x on the north
## wall, FEMUR_STACKS_WEST: z on the west; each FEMUR_STACK wide), rows of heads looking out of the wall as in an
## ossuary (FEMUR_ROWS rows of femurs lying into the wall, their heads just behind the floor's edge) and a few lying
## along the wall on top; FEMUR: shaft radius, length, head radius, head length. SW-C3: groups of urns of warm clay and
## burnt-out candles on the ledge beside the niches (ArenaRoom.offerings; C3_NORTH x, C3_WEST z). Skulls are a model
## (SW-A1, Meshy): none here.
const FEMUR_STACKS: Array[float] = [-5.5, -0.35]
const FEMUR_STACKS_WEST: Array[float] = [-4.6]
const FEMUR_STACK := 0.95
const FEMUR_ROWS := 7
const FEMUR := Vector4(0.02, 0.42, 0.038, 0.07)
const FEMUR_SIDES := 6
const C3_NORTH: Array[float] = [-7.1, -3.9]
const C3_WEST: Array[float] = [-5.85, -9.15]


## (in steps, a stack or a ledge each: BuildSteps, QA P1-1)
func _ossuary(sm: Masonry) -> Array[Callable]:
	var bone := sm.stone(0.0, BONE)
	bone.set_meta(ArenaKit.PAINT_OWN, {&"paint_ref": STY_PAINT_REF * STY_LIGHT_STONE, &"paint_pool_gain": STY_LID_POOL})
	var steps: Array[Callable] = []
	var k := 0
	for x in FEMUR_STACKS:
		steps.append(_femurs.bind(sm, Vector2(x, _north), Vector2(0, -1), bone, k))
		k += 1
	for z in FEMUR_STACKS_WEST:
		steps.append(_femurs.bind(sm, Vector2(_west, z), Vector2(-1, 0), bone, k))
		k += 1
	for x in C3_NORTH:
		steps.append(offerings.bind(Vector2(x, _north - WALL_SET * 0.5), Vector2(1, 0), LEDGE, 3, 91 + k))
		k += 1
	for z in C3_WEST:
		steps.append(offerings.bind(Vector2(_west - WALL_SET * 0.5, z), Vector2(0, 1), LEDGE, 3, 91 + k))
		k += 1
	return steps


## One stack of femurs on the ledge at the floor's edge point `at`, the wall `out` of it.
func _femurs(sm: Masonry, at: Vector2, out: Vector2, bone: Material, seed_: int) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 5501 + seed_
	var along := Vector2(-out.y, out.x)
	var o3 := Vector3(out.x, 0, out.y)
	var a3 := Vector3(along.x, 0, along.y)
	var lying := Basis(a3, PI * 0.5) if absf(out.y) > 0.5 else Basis(a3, -PI * 0.5)
	var step := FEMUR.z * 2.05
	for row in FEMUR_ROWS:
		var y := LEDGE + FEMUR.z + row * FEMUR.z * 1.75
		var n := int(FEMUR_STACK / step) - (1 if row % 2 == 1 else 0) - int(row / 3.0)
		for i in n:
			var s := -n * step * 0.5 + step * (i + 0.5)
			var head := Vector3(at.x, y, at.y) + a3 * s + o3 * (0.04 + r.randf_range(0.0, 0.03))
			_femur(sm, head, o3, bone, lying)
	# a few lying along the wall on top
	var top := LEDGE + FEMUR.z + FEMUR_ROWS * FEMUR.z * 1.75 + FEMUR.z * 0.6
	for i in 3:
		var c := Vector3(at.x, top + i * FEMUR.z * 1.6, at.y) + o3 * (0.12 + 0.02 * i) + a3 * r.randf_range(-0.2, 0.2)
		_femur(sm, c - a3 * FEMUR.y * 0.5, a3, bone, Basis(o3, PI * 0.5))


## A femur from its head at `head` running `dir`: the shaft and a knob at each end, few sides.
func _femur(sm: Masonry, head: Vector3, dir: Vector3, bone: Material, lying: Basis) -> void:
	for part in 3:
		var radius := FEMUR.x if part == 0 else FEMUR.z * (1.0 if part == 1 else 0.85)
		var length := FEMUR.y if part == 0 else FEMUR.w
		var along := FEMUR.y * 0.5 if part == 0 else (FEMUR.w * 0.5 if part == 1 else FEMUR.y - FEMUR.w * 0.5)
		var mi := sm.shaft(Vector3.ZERO, radius, length, bone)
		var c := mi.mesh as CylinderMesh
		c.radial_segments = FEMUR_SIDES
		c.bottom_radius = radius
		mi.basis = lying
		mi.position = head + dir * along


## TA-HB2 (docs/gallery/hb/ART_REVIEW.md item 2, Cripta), in the north bays, away from the crown (A) and the veiled
## figure (B): ivy hanging over the north wall's crest between the niches (EDGE_IVY_AT: x; EDGE_IVY: out of the face,
## down from the crest, width, length), a little ivy under the head of the bare niche and a heap of fallen blocks on its
## floor (EDGE_NICHE: the niche of NORTH_NICHES; EDGE_NICHE_IVY: in from its face, down from its head, width, length;
## EDGE_NICHE_RUBBLE: in from the face, along it, size).
const EDGE_IVY_AT: Array[float] = [-5.5, -11.0]
const EDGE_IVY := Vector4(0.04, 0.05, 1.6, 2.6)
const EDGE_NICHE := 0
const EDGE_NICHE_IVY := Vector4(0.3, 0.08, 1.1, 1.1)
const EDGE_NICHE_RUBBLE := Vector3(0.5, 0.35, 0.6)


func _edge_pieces() -> void:
	var edge := edge_kit()
	var face := _north - WALL_SET
	for x in EDGE_IVY_AT:
		edge.ivy(Vector3(x, WALL_HEIGHT - EDGE_IVY.y, face + EDGE_IVY.x), EDGE_IVY.z if x > _west + 2.0 else EDGE_IVY.z * 0.6,
			EDGE_IVY.w, Vector2(1, 0), Vector2(0, 1), int(x * 10.0))
	var nx: float = NORTH_NICHES[EDGE_NICHE]
	edge.ivy(Vector3(nx, LEDGE + NICHE.y - EDGE_NICHE_IVY.y, face - EDGE_NICHE_IVY.x), EDGE_NICHE_IVY.z, EDGE_NICHE_IVY.w,
		Vector2(1, 0), Vector2(0, 1), 3)
	edge.rubble(Vector3(nx + EDGE_NICHE_RUBBLE.y, LEDGE, face - EDGE_NICHE_RUBBLE.x), EDGE_NICHE_RUBBLE.z, 5)


## The sill in front of a niche: five lit candles at a statue's feet (and their light), or two urns and three burnt-out
## candles before the shelves. out: the statue's candles burnt out and no light (RS-C1, B's north statue beside the
## veiled figure); in A (no ossuary) their light a step under the crown (STY_STATUE_CANDLES).
func _sill(sm: Masonry, at: Vector2, facing: Vector2, statue: bool, urn: Material, out := false) -> void:
	var face := at - facing * WALL_SET
	var y := LEDGE + 0.16
	var across := Vector2(-facing.y, facing.x)
	var base := face + facing * SILL_OUT
	if statue:
		for i in STATUE_CANDLES:
			var t := (i - (STATUE_CANDLES - 1) * 0.5) * 0.22
			var p := base + across * t
			var h := 0.1 + 0.2 * absf(sin(float(i) * 2.3))
			var r := 0.045 + 0.02 * float(i % 2)
			if out:
				sm.candle_out(Vector3(p.x, y, p.y), h * 0.7, r)
			else:
				sm.candle(Vector3(p.x, y, p.y), h, r)
		if out:
			return
		var l := OmniLight3D.new()
		if _divider() == null:
			l.set_meta(ArenaKit.FIRE_SHARE, STY_STATUE_CANDLES)
		l.position = Vector3(base.x, y + 0.6, base.y) + Vector3(facing.x, 0, facing.y) * 0.4
		l.light_color = CANDLE_COLOR
		l.light_energy = CANDLE_LIGHT
		l.omni_range = CANDLE_RANGE
		l.light_cull_mask = ~Arena.CROWD_LAYER
		sm.root.add_child(l)
		return
	for i in SHELF_URNS.size():
		var p := base + across * (-0.55 + 1.1 * i)
		sm.urn(Vector3(p.x, y, p.y), SHELF_URNS[i], urn)
	for i in 3:
		var p := base + across * (-0.2 + 0.16 * i)
		sm.candle_out(Vector3(p.x, y, p.y), 0.07 + 0.05 * (i % 2), 0.05)


## A grave slab's worn inscription: an inset frame and three strokes, no letters (spec 2.4 A7).
func _inscription(sm: Masonry, at: Vector2, ink: Material) -> void:
	var h := SLAB * 0.5 - Vector2.ONE * INSCRIPTION.x
	var w := INSCRIPTION.y
	var y0 := TombKit.SLAB_LIFT * 1.6
	var y1 := y0 + INSCRIPTION_LIFT
	var rect := func(c: Vector2, half: Vector2) -> PackedVector2Array:
		return PackedVector2Array([c - half, c + Vector2(half.x, -half.y), c + half, c + Vector2(-half.x, half.y)])
	for sd: float in [-1.0, 1.0]:
		sm.prism(rect.call(at + Vector2(sd * h.x, 0), Vector2(w * 0.5, h.y)), y0, y1, ink)
		sm.prism(rect.call(at + Vector2(0, sd * h.y), Vector2(h.x, w * 0.5)), y0, y1, ink)
	for i in 3:
		var z := at.y - h.y * 0.45 + h.y * 0.3 * i
		var len_ := h.x * INSCRIPTION.z * (1.0 - 0.25 * (i % 2))
		sm.prism(rect.call(Vector2(at.x, z), Vector2(len_, w * 0.4)), y0, y1, ink)


## The cold glow far behind a door in the north wall: a card in the arch, a metre behind the wall's face, never on
## the floor (spec 2.3).
func _door_glow(e: ArenaExit, ossuary: bool) -> void:
	var card := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(absf(e.mouth.size.x), DOOR_GLOW.z - DOOR_GLOW.y)
	card.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = COLD_GLOW_SHADER
	mat.set_shader_parameter(&"bottom", DOOR_GLOW_FOOT_B if ossuary else DOOR_GLOW_FOOT)
	mat.set_shader_parameter(&"top", DOOR_GLOW_TOP)
	card.material_override = mat
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# beyond the door's mouth (it turns to floor when the door is taken), never across the way out
	var z := minf(_north - WALL_SET - DOOR_GLOW.x, minf(e.mouth.position.y, e.mouth.end.y) - DOOR_GLOW.x * 0.3)
	card.position = Vector3(e.mouth.get_center().x, (DOOR_GLOW.y + DOOR_GLOW.z) * 0.5, z)
	kit.styled().root.add_child(card)


## Variant B: the veiled figure standing on the ossuary wall's north end, facing the camera's side, the urns along its
## top, its cold light; all opening round the paladin behind the wall, as the wall does. RS-C1: raised on a plinth
## over the wall's top (corbels under its flaps), VEILED_RS high so its hood passes the north wall's cornice, a cold
## lantern hanging from its hands.
func _ossuary_crown(sm: Masonry, o: ArenaObstacle) -> void:
	var top := o.height
	var at := _veiled_foot(o)
	var wall := see(ashlar())
	sm.box(Vector3(at.x, top + PLINTH.y * 0.5, at.z), PLINTH, 0.0, wall, false)
	var flap := (PLINTH.x - minf(o.half.x, o.half.y) * 2.0) * 0.5
	for sd: float in [-1.0, 1.0]:
		var x := at.x + sd * (PLINTH.x * 0.5 - flap * 0.5)
		sm.box(Vector3(x, (CORBEL.x + CORBEL.y) * 0.5, at.z), Vector3(flap, CORBEL.x - CORBEL.y, CORBEL_DEPTH), 0.0, wall, false)
		var inner := at.x + sd * (PLINTH.x * 0.5 - flap + CORBEL.w * flap * 0.5)
		sm.box(Vector3(inner, (CORBEL.y + CORBEL.z) * 0.5, at.z), Vector3(CORBEL.w * flap, CORBEL.y - CORBEL.z, CORBEL_DEPTH * 0.7), 0.0, wall, false)
	sm.layers = ArenaKit.STATUE_LAYER
	var fig := sm.hooded_statue(at, 0.0, VEILED_RS, ArenaKit.STATUE_VALUE * VEILED_RS_VALUE)
	fig.material_override = see(fig.material_override as ShaderMaterial)
	sm.layers = 1
	var urn := see(sm.carved(top, STONE))
	for u in WALL_URNS:
		if u.x > at.z + PLINTH.z * 0.5 + 0.3:
			sm.urn(Vector3(o.center.x, top, u.x), u.y, urn)
	# the lantern hanging under the hands, out in front of the robe
	var hands := at + Vector3(0, Masonry.HANDS_AT * VEILED_RS, (Masonry.ROBE_CHEST + 0.02) * VEILED_RS)
	var hang := Vector3(hands.x, hands.y, at.z + (Masonry.ROBE_CHEST + 0.02) * VEILED_RS + LANTERN_OUT)
	var lamp := TombKit.Lamp.new(ScreenTone.fit(LANTERN_GLASS), ScreenTone.fit(LANTERN_GLASS), STY_COLD)
	var ring_y := hands.y - LANTERN_UNDER + LANTERN.y * 0.5 + 0.06
	var l := hanging_lantern(hang, ring_y, LANTERN, Vector2(LANTERN_LIGHT.x, LANTERN_LIGHT.y), true, lamp)
	l.omni_attenuation = LANTERN_LIGHT.z
	l.light_specular = 0.0
	l.shadow_enabled = false
	l.set_meta(ArenaKit.NOT_FIRE, true)
	var before := kit.root.get_child_count()
	kit.statue_glow(at + Vector3(0, VEILED_GLOW_FROM.x, VEILED_GLOW_FROM.y), at + Vector3(0, VEILED_RS * 0.6, 0), STY_VEILED_GLOW,
		VEILED_GLOW.y, VEILED_GLOW.z, STY_COLD)
	for i in range(before, kit.root.get_child_count()):
		ArenaKit.style_only(kit.root.get_child(i) as Node3D)


## Where the veiled figure stands: on the plinth over the ossuary wall's north end.
func _veiled_foot(o: ArenaObstacle) -> Vector3:
	var north := o.center.y - maxf(o.half.x, o.half.y)
	return Vector3(o.center.x, o.height + PLINTH.y, north + VEILED.y)


## RS-C1, A: the crown of candles hanging over the great tomb (spec A-D1): iron rings, spokes and dishes, sixteen
## candles (five burnt out), all opening round the paladin under it (the stippled see-through of the chamber's front
## candles), four chains in one MultiMesh up to CROWN_TOP, its own warm light. Nothing casts a shadow. One mesh per
## material, the flames and halos in MultiMeshes: iron, wax, burnt wax, flames, cores, halos, chains.
func _crown(sm: Masonry, o: ArenaObstacle) -> void:
	var mid := Vector3(o.center.x, CROWN_Y, o.center.y)
	var built := sm.built_count()
	sm.layers = CROWN_LAYER
	var iron := _see_iron()
	var r := CROWN_RING.x - CROWN_RING.y * 0.5
	var step := TAU / CROWN_SEGMENTS
	for i in CROWN_SEGMENTS:
		var a := step * (i + 0.5)
		var yaw := -a - PI * 0.5
		var seg := 2.0 * PI / CROWN_SEGMENTS * 1.04
		sm.box(mid + Vector3(cos(a), 0, sin(a)) * r, Vector3(seg * r, CROWN_RING.y, CROWN_RING.y), yaw, iron, false)
		sm.box(mid + Vector3(cos(a) * CROWN_INNER.x, CROWN_INNER.y, sin(a) * CROWN_INNER.x),
			Vector3(seg * CROWN_INNER.x, CROWN_INNER.z, CROWN_INNER.z), yaw, iron, false)
	for i in CROWN_SPOKES:
		var a := TAU / CROWN_SPOKES * i
		var rm := (CROWN_INNER.x + r) * 0.5
		sm.box(mid + Vector3(cos(a) * rm, CROWN_INNER.y * 0.5, sin(a) * rm),
			Vector3(r - CROWN_INNER.x, CROWN_INNER.y + CROWN_INNER.z, CROWN_INNER.z), -a, iron, false)
	var from := sm.root.get_child_count()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(mid)
	var dish_y := CROWN_Y + CROWN_RING.y * 0.5
	var halo: QuadMesh
	for i in CROWN_CANDLES:
		var a := TAU / CROWN_CANDLES * (i + 0.25)
		var p := mid + Vector3(cos(a), 0, sin(a)) * r
		p.y = dish_y
		sm.box(p + Vector3(0, CROWN_DISH.y * 0.5, 0), Vector3(CROWN_DISH.x, CROWN_DISH.y, CROWN_DISH.x), -a, iron, false)
		var h := rng.randf_range(CROWN_CANDLE.x, CROWN_CANDLE.y)
		var cr := rng.randf_range(CROWN_CANDLE.z, CROWN_CANDLE.w)
		var foot := p + Vector3(0, CROWN_DISH.y, 0)
		if CROWN_OUT.has(i):
			sm.candle_out(foot, h * 0.6, cr)
			continue
		sm.candle(foot, h, cr, true)
		# the warm halo round its flame (Fx.quad, opening round the paladin as the flame does)
		if halo == null:
			halo = Fx.quad(CROWN_HALO.x, CROWN_HALO_COLOR * CROWN_HALO.y)
		var g := MeshInstance3D.new()
		g.mesh = halo
		g.material_override = Masonry.see_open(halo.material)
		g.position = foot + Vector3(0, h + Masonry.CANDLE_FLAME * 0.3, 0)
		g.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		g.layers = CROWN_LAYER
		sm.root.add_child(g)
	sm.gather_billboards(from)
	var hook := Vector3(mid.x, CROWN_HOOK, mid.z)
	var pairs: Array = [[hook, Vector3(mid.x, CROWN_TOP, mid.z)]]
	for deg in CROWN_CHAIN_AT:
		var a := deg_to_rad(deg)
		pairs.append([mid + Vector3(cos(a), 0, sin(a)) * r, hook])
	kit.styled_build(func() -> void: kit.chains(pairs, 0.0, CROWN_CHAIN))
	sm.box(hook, Vector3.ONE * CROWN_CHAIN * 0.12, 0.0, iron, false)
	# one mesh per material for the whole crown (it spans four of the merge's squares), casting no shadow
	for mi in sm.merge(built, false):
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sm.layers = 1
	var l := OmniLight3D.new()
	l.position = mid - Vector3(0, CROWN_LIGHT_DROP, 0)
	l.light_color = CROWN_COLOR
	var compat: float = (STYLE[&"fire"] as Dictionary)[&"compat"] if _compat() else 1.0
	l.light_energy = CROWN_ENERGY * compat
	l.omni_range = CROWN_LIGHT.x
	l.omni_attenuation = CROWN_LIGHT.y
	l.light_cull_mask = ~(Arena.CROWD_LAYER | CROWN_LAYER)
	l.set_meta(ArenaKit.NOT_FIRE, true)
	sm.root.add_child(l)


## The crown's iron, opening round the paladin under it (the candles' see-through wax shader in the stylized iron).
func _see_iron() -> ShaderMaterial:
	if _crown_iron == null:
		_crown_iron = ShaderMaterial.new()
		_crown_iron.shader = Masonry.CANDLE_WAX_SEE
		_crown_iron.set_shader_parameter(&"wax", ArenaKit.STY_IRON)
		_crown_iron.set_shader_parameter(&"roughness", ArenaKit.STY_METAL.x)
		_crown_iron.set_shader_parameter(&"rim", 0.0)
		_crown_iron.set_shader_parameter(&"glow", Color.BLACK)
	return _crown_iron


var _crown_iron: ShaderMaterial


## RS-C1, A: the pall on the great tomb (spec A-D2): two cloths hung flat on the upper body's south face and east end,
## petrol with the gold thread and a short gold fringe, the old gold lion on the south one (reliquary_cloth.gdshader,
## the reward reliquary's cloth); one mesh, one material, no shadow, never past the tomb's outline.
func _pall(sm: Masonry, o: ArenaObstacle) -> void:
	var long_x := o.half.x >= o.half.y
	var half := o.half if long_x else Vector2(o.half.y, o.half.x)
	var axis := Vector3(1, 0, 0) if long_x else Vector3(0, 0, 1)
	var across := Vector3(axis.z, 0, axis.x)
	# the tomb's upper body (TombKit.tomb): its half length and depth, past the frieze
	var body := Vector2(half.x - 0.5, half.y - 0.45) + Vector2.ONE * (TombKit.SARC_FRIEZE.y + PALL_OUT)
	var top := o.height - TombKit.SARC_LID.x * 0.9 - PALL_TOP
	var c := Vector3(o.center.x, 0.0, o.center.y)
	var hang := top - PALL_FOOT
	var span := PALL_LION_V.y - PALL_LION_V.x
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# south: across the long side, facing +across; east: across the end, facing +axis (its v short of the lion)
	var south := c + across * body.y
	_cloth_quad(st, south - axis * PALL_WIDTH.x * 0.5, axis * PALL_WIDTH.x, top, hang, 1.0)
	var east := c + axis * body.x
	_cloth_quad(st, east + across * PALL_WIDTH.y * 0.5, -across * PALL_WIDTH.y, top, hang, PALL_LION_V.x - 0.02)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var mat := ShaderMaterial.new()
	mat.shader = PALL_SHADER
	mat.set_shader_parameter(&"cloth", PALL_CLOTH)
	mat.set_shader_parameter(&"gold", ArenaKit.STY_GOLD)
	mat.set_shader_parameter(&"lion", ArenaKit.LION_FIELD)
	mat.set_shader_parameter(&"lion_v", PALL_LION_V)
	# the lion square on the cloth: its height on v (0.82 of the span, the shader's) over the south cloth's width
	mat.set_shader_parameter(&"lion_size", 0.82 * span * hang / PALL_WIDTH.x)
	mat.set_shader_parameter(&"thread_in", PALL_THREAD.x)
	mat.set_shader_parameter(&"thread_w", PALL_THREAD.y)
	mat.set_shader_parameter(&"glow", PALL_GLOW)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sm.root.add_child(mi)


## One hanging cloth into st: from `a` along `along` (its width), from `top` down `hang` metres, its v from 0 to
## `v_end` (1: the whole, with the lion and the foot's thread); a fringe of PALL_FRINGE teeth under it in the gold
## thread's colour (the shader's foot thread at its v). Its normal along x up: `along` runs so that is out of the tomb.
func _cloth_quad(st: SurfaceTool, a: Vector3, along: Vector3, top: float, hang: float, v_end: float) -> void:
	var b := a + along
	var up := Vector3.UP
	var n := along.normalized().cross(up)
	var p := [Vector3(a.x, top, a.z), Vector3(b.x, top, b.z), Vector3(b.x, top - hang, b.z), Vector3(a.x, top - hang, a.z)]
	var uv := [Vector2(0, 0), Vector2(1, 0), Vector2(1, v_end), Vector2(0, v_end)]
	for k: int in [0, 1, 2, 0, 2, 3]:
		st.set_normal(n)
		st.set_uv(uv[k])
		st.add_vertex(p[k])
	# the fringe: a row of teeth hanging under the cloth
	var foot := 1.0 - PALL_THREAD.x * 0.7
	var teeth := maxi(4, roundi(along.length() / PALL_FRINGE.y))
	var y := top - hang
	for i in teeth:
		var t0 := a + along * (float(i) / teeth)
		var t1 := a + along * (float(i + 1) / teeth)
		var tip := (t0 + t1) * 0.5
		for q: Vector3 in [Vector3(t0.x, y + 0.005, t0.z), Vector3(t1.x, y + 0.005, t1.z), Vector3(tip.x, y - PALL_FRINGE.x, tip.z)]:
			st.set_normal(n)
			st.set_uv(Vector2(0.5, foot))
			st.add_vertex(q)
