class_name HubScenery
extends RefCounted
## The Santuário da Vigília's finish (SV-R, 2026-11-25, environment-artist): what dresses HubBlockout's masses and the
## plan's floor, drawn in HubLook's frame (u to the right of the screen, v up it) and never on the walkable floor's
## collision: roofs, windows and corner stones on the buildings; the water of the three basins and their kerbs; the bridge
## of the south way (balustrades, arches under it, two falls); the Videira's pergola; the Ponto de Vigília's post; the
## future rooms' sunken yards; lamps, shrubs, flowers, cypresses and round trees along the floor's edges, off every
## route; the lion and the fish, small, in the stone; the far ridges. Display only: nothing here collides (the floor is
## flat in the simulation), so what stands near a route is low or at its edge.
##   HubScenery.new(look).build(layout)

# ---------- palette (docs/art/ref/hub01_2026-11-25/eterra_hub/04-paleta-e-iluminacao.md) ----------
const LIMESTONE := Color("D3C5A7")
const SHADED_STONE := Color("8F8775")
const CYPRESS_GREEN := Color("52683D")
## The cypress' shadow side as a share of its green (PM-2: was 0.95, near black on screen).
const CYPRESS_SHADE := 1.2
const VINE_GREEN := Color("94A76A")
const WATER_BLUE := Color("527F8C")
const OLD_GOLD := Color("B68A48")
const SUN_WARM := Color("F4DBAB")
const TERRACOTTA := Color(1.05, 0.5, 0.38)
## Round 2: the roofs are darker, duller clay with a dark fascia and tile rows of their own tint.
const FASCIA_COLOR := Color(0.11, 0.07, 0.07)
const IRON := Color(0.1, 0.1, 0.11)
const WISTERIA_A := Color(0.34, 0.26, 0.46)
const WISTERIA_B := Color(0.6, 0.52, 0.72)
const LEAF_DARK := Color(0.27, 0.39, 0.19)
const LEAF_LIGHT := Color(0.42, 0.54, 0.26)
const TREE_DARK := Color(0.38, 0.52, 0.25)  # PM-2: the leaf shadow olive, not black (was 0.29, 0.44, 0.21)
const TREE_LIGHT := Color(0.5, 0.62, 0.3)
const RED_LEAF_A := Color(0.46, 0.08, 0.1)
const RED_LEAF_B := Color(0.84, 0.26, 0.16)
const MAGENTA_A := Color(0.4, 0.2, 0.34)
const MAGENTA_B := Color(0.68, 0.5, 0.64)
const WINDOW_GLOW := Color(1.0, 0.72, 0.38)

# ---------- roofs, windows, corners ----------
## Eaves out of the wall, the rise as a share of the short side (and its limits), the fascia's thickness.
const EAVE := 0.5
const ROOF_RISE := Vector3(0.3, 0.9, 1.5)
const FASCIA := 0.2
const CORNER_STONE := Vector2(0.45, 0.2)  # width and how far it stands out
## A window: width, sill height (low houses: the second), height cap, frame and glass depth, how far from the wall.
const WINDOW := Vector4(0.85, 1.25, 1.7, 0.16)
const WINDOW_LOW_SILL := 0.9
const WINDOW_EVERY := 3.4
const WINDOW_CLEAR := Vector2(1.3, 0.9)  # how far from a door or a piece along the wall, and out from it
const GLASS_GLOW := 1.5
const WINDOW_TOP := 0.06  # round 6: a window's head is nearly dark (the gradient's dark end)
const WINDOW_MID := 0.25  # and the middle still dim: the light pools at the sill
const MULLION := 0.05
const SHUTTER_WOOD := Color(0.26, 0.15, 0.09)

# ---------- water ----------
const WATER_LEVEL := -0.5
const WATER_DEEP := Color(0.17, 0.33, 0.39)
const WATER_SHALLOW := Color(0.3, 0.5, 0.55)
const WATER_SHEEN_AT := Vector2(-6.0, 10.0)
const KERB := Vector2(0.3, 0.2)  # width, height
const FISH := Vector2(0.34, 0.16)  # the fish carved on a kerb: length, height

# ---------- bridge (the south way, v -15.5 to -10.5) ----------
const BRIDGE_U := Vector2(6.75, 26.0)
const BRIDGE_V := Vector2(-15.5, -10.5)
const BRIDGE_ARCHES: Array[float] = [10.8, 16.4, 22.0]
const ARCH_SPAN := 4.0
## Round 5: the arches under the way sprang from +2.2 m and stood above the deck in front of the camera; now the whole ring is
## under the cornice (apex about -0.7 m), the recess behind them dark stone (ARCH_BACK) and never a flat black panel.
const ARCH_SPRING := -4.1
const ARCH_BACK := 0.38
const ARCH_RING := 0.4
const ARCH_FOOT := -6.2
const FALL_SHADER := preload("res://assets/shaders/waterfall.gdshader")
## The falls: u, v of the cliff face they hang on, width, drop (from just under the lip).
const FALLS: Array[Vector4] = [Vector4(16.4, -15.7, 2.6, 15.0), Vector4(22.0, -15.7, 2.6, 16.0), Vector4(28.1, -13.6, 2.4, 14.0),
	Vector4(35.5, -12.2, 2.6, 17.0)]
const FALL_TURN := 0.0
## Round 3: the falls are white-blue and thin out to nothing in the mist before the foot (FALL_VANISH: the share of the drop).
const FALL_COLOR := Color(0.5, 0.72, 0.84)
const FALL_VANISH := 0.55
## Round 4: the falls are narrow ribbons of pale blue water (FALL_NARROW times the width they had), with see-through gaps between
## the stripes (FALL_GAP), a band of foam at the lip (FALL_LIP, the share of the drop), never a white plate; and only where
## the drop below is open void (FALL_OPEN: how far out, how far to each side, in metres), never a pit or trench in the floor.
const FALL_FOAM := Color(0.8, 0.9, 0.96)
const FALL_ALPHA := 0.6
const FALL_GAP := 0.85
const FALL_LIP := 0.06
const FALL_NARROW := 0.55
const FALL_OPEN := Vector2(12.0, 2.0)
const EXTRA_FALLS := 0  # round 3: the falls are only FALLS (the east, under the Portão's bridge); none in the middle
const EXTRA_FALL_APART := 9.0
const EXTRA_FALL_WIDTH := Vector2(1.5, 2.2)
const EXTRA_FALL_DROP := Vector2(16.0, 21.0)
const FALL_MIST := Color(0.5, 0.46, 0.66)
## Balustrades along the edges that look over the drop (a, b in u, v), inset from the floor's edge.
const RAILS: Array[Vector4] = [
	Vector4(-28.7, -12.75, -19.3, -12.75), Vector4(7.0, -15.25, 25.7, -15.25), Vector4(7.6, -10.75, 23.6, -10.75),
	Vector4(30.4, -11.75, 36.4, -11.75),
]

# ---------- pergola (the Videira) ----------
## Round 3: the Videira is a round gazebo, not a rectangular pergola: a ring of GAZEBO_COLUMNS cream columns (GAZEBO_RADIUS from
## the fountain, PERGOLA_HEIGHT tall) round the fountain, a stone cornice joining them, a wreath of leaves on it (open over
## the fountain: WREATH_HOLE m from the middle, thinner toward the camera by PERGOLA_GAP) with grapes and tassels hanging
## between the columns, on a round stone dais (GAZEBO_DAIS) with a round step.
const GAZEBO_RADIUS := 3.4
const GAZEBO_COLUMNS := 8
const GAZEBO_DAIS := Vector2(4.3, 0.28)  # radius of the floor's stone and of its round step beyond the dais
const PERGOLA_HEIGHT := 2.9
const WREATH_HOLE := 1.9
const RAFTER := Vector2(0.9, 0.12)  # every, thickness
const RAFTER_WOOD := Color(0.3, 0.19, 0.11)
## Round 3: the pergola's roof closed in vine leaves (crown width and height; a leaf crown every PERGOLA_LEAF_EVERY m, the south
## half thinner by up to PERGOLA_GAP so the fountain under it is seen), and grape clusters hanging from the beams.
const PERGOLA_LEAF := Vector2(2.0, 0.9)
const PERGOLA_LEAF_EVERY := 1.05
const PERGOLA_GAP := 0.55
const GRAPE_A := Color(0.2, 0.06, 0.3)
const GRAPE_B := Color(0.46, 0.2, 0.56)
const GRAPE_PER_RAFTER := 3
const GRAPE_HANG := Vector2(0.55, 1.0)
## The fountain's clear water (the basin's own, brighter than the hub's pools).
const FOUNTAIN_DEEP := Color(0.34, 0.62, 0.7)
const FOUNTAIN_SHALLOW := Color(0.62, 0.9, 0.94)
const FOUNTAIN_SPARKLE := 0.4

# ---------- the Ponto de Vigília and the future rooms ----------
const VIGIL_FLAME := Vector3(-22.6, 0.0, -10.2)
## Round 3: the Vigilia's mass is a raised garden bed (a soil bed on top inside a balustrade, flowers, two cypresses,
## wisteria down its faces) with a low niche of voussoirs in its south face holding a standard, and the fire's dais is
## cream stone (the bowl reads as the arrival's centre).
const VIGIL_RECT := Vector4(-28.0, -12.0, -25.2, -5.0)
const VIGIL_BED_INSET := 0.3
const VIGIL_RAIL_INSET := 0.22
## Round 6: the bed's continuous low wall (thickness, height, coping height).
const VIGIL_WALL := Vector3(0.3, 0.5, 0.08)
## Round 3: the arch behind the fire (HubPlan.VIGIL_ARCH is its wall): the opening's span, the outer apex's height over the floor, its
## curve (the share of the span) and the ring's width; the wall's height.
const VIGIL_ARCH_OPENING := Vector4(2.4, 3.0, 0.62, 0.4)
const VIGIL_ARCH_WALL_TALL := 3.5
const VIGIL_PLANT_EVERY := 0.95
const VIGIL_STEP := 0.2  # the dais' second step: its radius share over the third
const FUTURE_YARDS: Array[Vector4] = [Vector4(-21.0, -26.0, -8.0, -17.0), Vector4(-1.0, -26.0, 12.0, -17.0)]
const YARD_DROP := 1.2
const YARD_STEPS := 5
const YARD_WALL := Vector2(0.5, 1.1)
const YARD_FLOOR := Color(0.62, 0.56, 0.48)
## Round 3: the yards' stairs are cream stone with a lighter nosing on every step (not dark boards).
const STEP_NOSING := Color(0.58, 0.5, 0.4)  # round 6: was near white (read as bright bands)
const STEP_TREAD := Color(0.4, 0.34, 0.29)
const STEP_SHADOW := Color(0.07, 0.055, 0.05)  # the dark band under each nosing, on the riser
const STEP_SHADOW_SHARE := 0.6
const STEP_NOSING_H := 0.05

# ---------- plants and lamps along the edges ----------
const EDGE_INSET := 0.7
const SHRUB_EVERY := 6.0
const SHRUB := Vector2(0.9, 1.4)  # tall (min, max)
const FLOWER_EVERY := 6.5
const CYPRESS_EVERY := 14.0
const CYPRESS_TALL := Vector2(3.2, 4.6)
const TREE_EVERY := 10.0
const TREE_ROUND_EVERY := 4
const TREE_TALL := Vector2(3.4, 4.4)
const TREE_TRUNK := Vector2(0.24, 2.3)
const TREE_SHELF := Vector2(1.9, 0.9)  # a rock shelf under a tree: width, how far it stands out under the lip
const LAMP_EVERY := 21.0
const LAMP := Vector3(0.1, 1.9, 0.26)  # post width, height, lantern size
const HANG_CLEAR := 4.0
const PLANT_CLEAR := 2.6  # from a station's use point, a door or the arrival
const PIECE_PAD := 0.9
const SEED := 4417

# ---------- garden, fountain, rails, planters, cliffs, path (hub refine round 1) ----------
## The big basin (WATER_2, a rectangle of water north of the Videira) becomes a raised garden of flowers: the art's plaza
## is a round one with a fountain in the middle, so the water stays small (the other two basins) and the Videira's bed
## takes the fountain. Nobody walks there (it is a hole of the floor): soil this much over the floor, in a stone kerb.
const GARDEN_BASIN := 1
const GARDEN_RAISE := 0.36
const GARDEN_SOIL := Color(0.2, 0.13, 0.09)
const GARDEN_EVERY := 1.15
const GARDEN_EDGE := 0.55
## Round 2: the garden's shares of lilac and magenta clumps (half what they were; the rest is shrub or bare earth).
const GARDEN_LILAC := 0.3
const CREAM_SHARE := 0.15  # round 3: the share of the lilac clumps that are cream-white
const CREAM_A := Color(0.72, 0.66, 0.54)
const CREAM_B := Color(0.97, 0.93, 0.84)
const GARDEN_MAGENTA := 0.2
const GARDEN_BARE := 0.8
const GARDEN_CYPRESS_EDGE := 1.3
## The fountain on the Videira's bed (the middle of the pergola): basin radius, rim height, water radius, pedestal radius.
const FOUNTAIN_BASIN := Vector4(1.9, 0.28, 1.7, 0.3)  # round 3: wider, the light water is the gazebo's centre
const FOUNTAIN_RIM_BLOCKS := 18
const FOUNTAIN_FALLS := 8
## Low balustrades along the outer edges that look at the camera or the sides (the art's low creamy wall with its
## lanterns): inset from the edge, share of the usual height, shortest run, every Nth post carries a lantern.
const RAIL_INSET := 0.6
const RAIL_LOW := 0.8
const RAIL_MIN := 2.5
## Round 3: thin cream rails: posts RAIL_POST wide and RAIL_POST_TALL high (with their cap, 0.8 m in all: the hero's chest is over
## the rail), a rail of RAIL_BAR (height, depth) on top at RAIL_TOP, small turned balusters between, a post every RAIL_GAP m.
const RAIL_POST := Vector3(0.5, 0.64, 0.62)  # width, shaft height, cap width
const RAIL_CAP_TALL := 0.16
const RAIL_BAR := Vector2(0.1, 0.24)
const RAIL_TOP := 0.7
const RAIL_GAP := 2.4
const RAIL_BALUSTER := 0.1
const RAIL_LANTERN_EVERY := 4  # round 3: one lantern every fourth post (was every second)
const RAIL_CLEAR := 1.5
## Round 5: a rail only where the edge looks over a drop (no floor within RAIL_TRENCH beyond it: between two courts one rail
## stays, the south one), and a lantern (on a post or a lamp post) at most every LANTERN_APART m.
const RAIL_TRENCH := Vector2(2.5, 4.5)
const LANTERN_APART := 6.0
const LANTERN_SIZE := 0.2
const LAMP_LANTERN := 0.24  # a lamp post's lantern
## Round 3: the lanterns are amber (never white), each with a small cap of dark iron over it and a soft halo; the pool of
## light each throws on the paving is HubGlow's.
const LANTERN_COLOR := Color(1.0, 0.5, 0.14)
const LANTERN_ENERGY := 1.5
const LANTERN_CAP := Vector3(1.9, 0.9, 1.9)  # times the lantern's size: width, height, depth of the iron cap
const LANTERN_CAP_COLOR := Color(0.07, 0.065, 0.07)
const LANTERN_HALO := 5.5  # the halo's size, times the lantern's
const LANTERN_HALO_COLOR := Color(1.0, 0.55, 0.2, 0.55)
const LANTERN_POOL := Vector2(2.1, 0.34)  # radius of a lantern's pool of light on the paving and its strength
## The squares' warm pools (centre u, v; radius; strength; colour): the arrival and its fire, the Videira, the Aposento's
## carpet, the Mercador, the Dons, the Forja, the Livro, the Portao. The paving is warm in the middle and dark only at the rim.
const FIRE_POOL := Color(1.0, 0.5, 0.2)
const GOLD_POOL := Color(1.0, 0.72, 0.36)
const SQUARE_POOLS: Array[Array] = [
	[Vector2(-22.6, -10.2), 4.8, 0.62, FIRE_POOL], [Vector2(-24.0, -6.0), 3.6, 0.3, GOLD_POOL],
	[Vector2(-7.0, -5.4), 5.2, 0.46, GOLD_POOL], [Vector2(-1.0, 19.0), 5.4, 0.5, GOLD_POOL],
	[Vector2(12.0, 5.6), 4.6, 0.42, GOLD_POOL], [Vector2(10.0, -3.0), 4.6, 0.42, GOLD_POOL],
	[Vector2(-17.6, 15.6), 5.0, 0.5, FIRE_POOL], [Vector2(19.0, 18.6), 4.4, 0.4, GOLD_POOL],
	[Vector2(33.0, -6.0), 5.4, 0.5, GOLD_POOL], [Vector2(3.0, 6.0), 4.8, 0.3, GOLD_POOL],
]
## Planters of stone with flowers along the rails (the art's canteiros), every so many metres of edge.
const PLANTER_EVERY := 13.0  # round 5: was 9
const PLANTER_INSET := 1.55
const PLANTER := Vector3(2.6, 0.45, 0.75)
## The cliffs: tufts of shrub, flowers and hanging wisteria on the face, and ledges of rock (the hub_cliff stone).
const CLIFF_TUFT_EVERY := 2.2
const CLIFF_TUFT_DEPTH := Vector2(0.5, 8.5)
const LEDGE_EVERY := 4.0
## Round 3: stacks of rock stepping out and down the face (the talus), and ivy hanging from the lip.
const ROCK_STEP_EVERY := 3.4
const ROCK_STEPS := Vector2i(2, 4)
const ROCK_CHAMFER := 0.28
const ROCK_TILT := 0.14
const ROCK_TALL_SHARE := 0.35
const ROCK_STEP_OUT := 0.65  # how much further out each step down stands
const ROCK_STEP_DROP := Vector2(0.9, 1.7)
const IVY_EVERY := 4.0  # round 3: was 2.6 (curtains only on the cliff faces, never a column on the paving)
const PATH_CLEAR := 3.0  # no cypress nearer than this to a way (PATH_MAIN, PATH_GATE)
const IVY_TALL := Vector2(2.0, 5.5)
## Round 3: the rock behind the west and north edges: every BACKDROP_EVERY m, blocks (wide, tall over the floor, deep) sunk
## BACKDROP_SINK under it.
const BACKDROP_EVERY := 2.6
const BACKDROP_WIDE := Vector2(3.2, 4.6)
const BACKDROP_TALL := Vector2(4.0, 6.5)
const BACKDROP_MIN_V := 24.0
const BACKDROP_DEEP := Vector2(2.2, 3.4)
const BACKDROP_SINK := 3.0
const IVY_A := Color(0.3, 0.42, 0.17)  # PM-2: olive shadow (was 0.2, 0.32, 0.14)
const IVY_B := Color(0.34, 0.46, 0.2)
const WALL_WISTERIA_EVERY := Vector2(1.7, 2.7)  # round 2: denser than 2.4 to 3.6
const CASCADE_ON: Array[StringName] = [&"book", &"heroes", &"smith", &"tree", &"vendor"]
const CASCADE_COUNT := 3
const CASCADE_TALL := Vector2(2.2, 3.4)
const HANG_WIDTH := 0.95  # a wisteria tassel's width at the top
const HANG_TALL := Vector2(2.0, 3.8)  # a cliff tassel, from the lip down
## Round 2: the dark crowns far down: every so often along the edge, this far out and this deep, this tall.
const DEEP_EVERY := 2.4
const DEEP_OUT := Vector2(1.5, 9.0)
const DEEP_DEPTH := Vector2(7.0, 22.0)
const DEEP_TALL := Vector2(3.0, 6.0)
const DEEP_A := Color(0.25, 0.27, 0.34)  # lote 1: hazy crowns in the lilac mist, not black holes
const DEEP_B := Color(0.35, 0.37, 0.44)
const LEDGE := Vector3(3.2, 1.0, 1.8)  # along the edge, tall, out of the face
const LEDGE_DEPTH := Vector2(1.8, 13.0)
## The main way's glow (Vigilia, Videira, Dons, Aposento, Portao): width, how far apart the samples.
const PATH_WIDTH := 1.5
const PATH_STEP := 0.6
## Round 4: the translucent tiles laid along the way read as a pale band across the floor and are gone (the way is paved
## in HubLook._pave_way); the polylines stay as the way's description.
const PATH_MAIN: Array[Vector2] = [Vector2(-23.0, -7.0), Vector2(-14.0, -7.0), Vector2(-7.0, -6.0), Vector2(2.0, -6.0),
	Vector2(4.0, 0.0), Vector2(4.0, 12.0), Vector2(1.0, 17.5)]
const PATH_GATE: Array[Vector2] = [Vector2(2.0, -6.0), Vector2(5.0, -13.0), Vector2(25.0, -13.0), Vector2(32.0, -6.0), Vector2(36.0, -6.0)]
## The red tree on a shelf at the north-west corner (the art's), its shelf, crown and trunk.
const RED_TREE_AT := Vector2(-30.4, 21.5)
const RED_TREE := Vector3(5.2, 5.0, 3.2)  # crown width, crown tall, trunk tall
const RED_TREE_CLEAR := 7.0
## Round 2: one more crimson tree (the art's second, behind the Alquimista on the west cliff): its place (u, v) and its size
## as a share of RED_TREE.
const RED_TREE_2 := Vector3(-31.6, 6.5, 0.85)

# ---------- the far ridges ----------
const RIDGE_SHADER := preload("res://assets/shaders/hub_ridge.gdshader")
## Each ridge card: distance north of the plan's middle v, width, height, bottom y, colour near the crest, colour at its
## top, ridge base share and amplitude, the seed.
const RIDGES: Array[Dictionary] = [
	{&"v": 160.0, &"w": 700.0, &"h": 170.0, &"y": -60.0, &"low": Color(0.22, 0.2, 0.34), &"top": Color(0.5, 0.4, 0.48), &"base": 0.6, &"amp": 0.3, &"seed": 3.0},
	{&"v": 110.0, &"w": 520.0, &"h": 140.0, &"y": -60.0, &"low": Color(0.14, 0.14, 0.26), &"top": Color(0.3, 0.26, 0.38), &"base": 0.62, &"amp": 0.3, &"seed": 11.0},
	{&"v": 70.0, &"w": 360.0, &"h": 120.0, &"y": -60.0, &"low": Color(0.1, 0.14, 0.18), &"top": Color(0.22, 0.26, 0.28), &"base": 0.6, &"amp": 0.3, &"seed": 21.0},
]
const RIDGE_U := 14.0
## PM-2 (art review 2026-11-26b item 4): the same ridges seen over the west edge, so the void beside the floor is lilac
## mountain and not flat navy: each card stands this far west of the plan's middle (u), centred on `v` (along it, so
## `w` covers the whole west rim), turned to face east.
const RIDGES_WEST: Array[Dictionary] = [
	{&"u": -92.0, &"v": 20.0, &"w": 420.0, &"h": 150.0, &"y": -60.0, &"low": Color(0.3, 0.26, 0.42), &"top": Color(0.58, 0.48, 0.62), &"base": 0.62, &"amp": 0.3, &"seed": 41.0},
	{&"u": -58.0, &"v": 20.0, &"w": 340.0, &"h": 120.0, &"y": -60.0, &"low": Color(0.22, 0.2, 0.34), &"top": Color(0.44, 0.37, 0.5), &"base": 0.66, &"amp": 0.28, &"seed": 47.0},
	{&"u": -38.0, &"v": 20.0, &"w": 260.0, &"h": 90.0, &"y": -60.0, &"low": Color(0.16, 0.15, 0.27), &"top": Color(0.33, 0.29, 0.42), &"base": 0.7, &"amp": 0.25, &"seed": 53.0},
]
## The sky (a standing card behind the ridges) and the sea of cloud under the floor (a flat plane), as gradients.
const SKY_SHADER := preload("res://assets/shaders/hub_sky.gdshader")
const SKY_TOP := Color(0.24, 0.3, 0.58)
const SKY_HORIZON := Color(0.74, 0.6, 0.78)
const SEA_Y := -30.0
const SEA_SIZE := 900.0
const SEA_FAR := Color(0.66, 0.56, 0.72)  # lote 1 capture: the void read as flat navy from the near camera
const SEA_NEAR := Color(0.5, 0.43, 0.6)
const SEA_CLOUD := 1.2
const SEA_CLOUD_SCALE := 0.11  # waves of cloud the near camera can tell apart (a view is only tens of metres wide)
const SKY_CARD := Vector4(260.0, 900.0, 320.0, -60.0)  # v, width, height, bottom y

var look: HubLook
var _rng := RandomNumberGenerator.new()
var _pieces: Array[Rect2] = []  # footprints of the stations' pieces and the doors (local u, v), padded
var _lantern_at: Array[Vector2] = []  # where a rail post or a lamp post already carries a lantern
var _avoid: Array[Vector2] = []  # use points, door centres, the arrival
var _roof_mat: ShaderMaterial
var _window_mat: StandardMaterial3D
var _flower_spots: Array[Vector3] = []
var _flower_tall: Array[float] = []
var _wisteria_spots: Array[Vector3] = []
var _wisteria_tall: Array[float] = []
var _falls_all: Array[Vector4] = []  # the plan's falls and the extra ones (the cliffs leave them bare)
var _ivy_spots: Array[Vector3] = []
var _ivy_tall: Array[float] = []
var _roof_spots: Array[Vector3] = []
var _roof_tall: Array[float] = []
var _grape_spots: Array[Vector3] = []
var _grape_tall: Array[float] = []
var _leaf_spots: Array[Vector3] = []
var _leaf_tall: Array[float] = []
var _cypress_spots: Array[Vector3] = []
var _cypress_tall: Array[float] = []
var _tree_spots: Array[Vector3] = []
var _tree_tall: Array[float] = []
var _deep_spots: Array[Vector3] = []
var _deep_tall: Array[float] = []
var _deep_round_spots: Array[Vector3] = []
var _deep_round_tall: Array[float] = []
var _cream_spots: Array[Vector3] = []
var _cream_tall: Array[float] = []
var _magenta_spots: Array[Vector3] = []
var _magenta_tall: Array[float] = []
var _lantern_xf: Array[Transform3D] = []
var _lantern_mat: StandardMaterial3D
var _water_mat: ShaderMaterial
var _rock: ShaderMaterial
var facades: HubFacades


func _init(owner_look: HubLook) -> void:
	look = owner_look
	_rng.seed = SEED


func build(layout: RoomLayout) -> void:
	_collect(layout)
	facades = HubFacades.new(look, self)
	for b in HubPlan.BUILDINGS:
		var r: Vector4 = b[&"rect"]
		_corners(r, b[&"h"])
		if b[&"id"] == &"vigil":
			continue  # round 2: the Vigília is an open basin under the sky, its wall bare behind it (no roof over the arrival)
		_roof(r, b[&"h"])
		_windows(r, b[&"h"])
	facades.build()
	_water()
	_bridge()
	_pergola()
	_fountain()
	_vigil_post()
	_future_yards()
	_plaza()
	facades.gate()
	_balustrades()
	_edges()
	_planters()
	_cliffs()
	_backdrop()
	_red_tree()
	_wall_flowers()
	_build_lanterns()
	look.add_crowns(_leaf_spots, _leaf_tall, LEAF_DARK, LEAF_LIGHT, 1.5, "Shrubs", false)
	# round 2: clean clumps and tassels (hub_flower.gdshader), not the canopy's speckled cards
	look.add_blooms(_flower_spots, _flower_tall, WISTERIA_A, WISTERIA_B, HubLook.BLOOM_CLUMP, "Flowers")
	look.add_blooms(_magenta_spots, _magenta_tall, MAGENTA_A, MAGENTA_B, HubLook.BLOOM_CLUMP, "Magentas")
	look.add_blooms(_cream_spots, _cream_tall, CREAM_A, CREAM_B, HubLook.BLOOM_CLUMP, "Creams")
	look.add_blooms(_wisteria_spots, _wisteria_tall, WISTERIA_A, WISTERIA_B, HANG_WIDTH, "Wisteria", true)
	look.add_crowns(_ivy_spots, _ivy_tall, IVY_A, IVY_B, 0.8, "Ivy", false, true, 0.7)
	look.add_crowns(_roof_spots, _roof_tall, LEAF_DARK, LEAF_LIGHT, PERGOLA_LEAF.x, "PergolaRoof", true)
	look.add_crowns(_grape_spots, _grape_tall, GRAPE_A, GRAPE_B, 0.42, "Grapes", false, true, 0.4)
	_clear_cypresses()
	look.add_crowns(_cypress_spots, _cypress_tall, CYPRESS_GREEN * CYPRESS_SHADE, CYPRESS_GREEN * 1.35, 1.25, "Cypresses", false)
	look.add_crowns(_deep_spots, _deep_tall, DEEP_A, DEEP_B, 1.6, "DeepCypresses", false)
	look.add_crowns(_deep_round_spots, _deep_round_tall, DEEP_A, DEEP_B, 3.2, "DeepTrees", true)
	look.add_crowns(_tree_spots, _tree_tall, TREE_DARK, TREE_LIGHT, 4.2, "Trees", true)
	_ridges()


# ---------- helpers ----------

func _at(u: float, y: float, v: float) -> Vector3:
	return HubLook.at(u, y, v)


## The stations' pieces (not the masses) and the doors as padded local rects, and the points no plant may crowd.
func _collect(layout: RoomLayout) -> void:
	for o in layout.obstacles:
		if o.piece == &"hub_building" or o.piece == &"hub_gate":
			continue
		var c := HubPlan.to_local(o.center)
		var half := Vector2(o.radius, o.radius) if o.shape == ArenaObstacle.Shape.CIRCLE else o.half
		_pieces.append(Rect2(c - half - Vector2.ONE * PIECE_PAD, half * 2.0 + Vector2.ONE * PIECE_PAD * 2.0))
	for id: StringName in HubPlan.DOORS:
		var d: Vector4 = HubPlan.DOORS[id]
		_pieces.append(Rect2(d.x - d.z - 0.3, d.y - d.w - 0.3, d.z * 2.0 + 0.6, d.w * 2.0 + 0.6))
		_avoid.append(Vector2(d.x, d.y))
	for id: StringName in HubPlan.USE:
		_avoid.append(HubPlan.USE[id])
	_avoid.append(HubPlan.ARRIVAL)
	for r in HubFacades.reserved():
		_pieces.append(r)


## Round 5: a tassel or a curtain hung from the lip is a tall card seen edge-on beside the hero: none within HANG_CLEAR of the
## arrival, a use point or a door.
func _near_avoid(p: Vector2, clear := HANG_CLEAR) -> bool:
	for a in _avoid:
		if a.distance_to(p) < clear:
			return true
	return false


func _blocked(p: Vector2, clear := PLANT_CLEAR) -> bool:
	for a in _avoid:
		if a.distance_to(p) < clear:
			return true
	for r in _pieces:
		if r.has_point(p):
			return true
	for b in HubPlan.BUILDINGS:
		var br: Vector4 = b[&"rect"]
		if Rect2(br.x - 0.7, br.y - 0.7, br.z - br.x + 1.4, br.w - br.y + 1.4).has_point(p):
			return true
	var g := HubPlan.GATE
	return Rect2(g.x - 0.7, g.y - 0.7, g.z - g.x + 1.4, g.w - g.y + 1.4).has_point(p)


func _on_floor(p: Vector2) -> bool:
	var inside := false
	for poly in HubPlan.floor_polys():
		if Geometry2D.is_point_in_polygon(p, poly):
			inside = true
	if not inside:
		return false
	for w in HubPlan.water():
		if Geometry2D.is_point_in_polygon(p, w):
			return false
	return true


## Points along the floor's edges every `step` (jittered), pushed `inset` into the floor, none blocked: [point, outward normal].
func _edge_points(step: float, inset: float, clear := PLANT_CLEAR, with_water := true, free_of_blocks := false) -> Array:
	var out := []
	var loops: Array[PackedVector2Array] = []
	loops.append_array(HubPlan.floor_polys())
	if with_water:
		for w in HubPlan.water():
			loops.append(w)
	for poly in loops:
		var n := poly.size()
		for i in n:
			var a := poly[i]
			var b := poly[(i + 1) % n]
			var len := a.distance_to(b)
			if len < 1.0:
				continue
			var dir := (b - a) / len
			var normal := Vector2(-dir.y, dir.x)
			var s := _rng.randf_range(0.3, step)
			while s < len - 0.3:
				var edge := a + dir * s
				var into := normal
				if not _on_floor(edge + normal * 0.25):
					into = -normal
				var p := edge + into * inset
				# (the lower plaza has its own dressing, _plaza: nothing along its walls)
				if not HubPlan.near_plaza(edge) and _on_floor(p) and (free_of_blocks or not _blocked(p, clear)) and p.y > -16.4:
					out.append([p, -into])
				s += step * _rng.randf_range(0.8, 1.25)
	return out


# ---------- buildings ----------

## A hip roof of terracotta tiles on the mass (the eaves over its cornice); the ridge along the long side.
func _roof(r: Vector4, h: float) -> void:
	if _roof_mat == null:
		_roof_mat = look.fm.stone(0.0, TERRACOTTA).duplicate() as ShaderMaterial
		_roof_mat.set_meta(ArenaKit.PAINT_OWN, ArenaKit.OWN_KEEP)
		_roof_mat.set_shader_parameter(&"course", 0.34)
	var c := Vector2(r.x + r.z, r.y + r.w) * 0.5
	var hx := (r.z - r.x) * 0.5 + HubBlockout.CORNICE.x + EAVE
	var hz := (r.w - r.y) * 0.5 + HubBlockout.CORNICE.x + EAVE
	var rise := clampf(minf(hx, hz) * 2.0 * ROOF_RISE.x, ROOF_RISE.y, ROOF_RISE.z)
	var rx := maxf(hx - hz, 0.0)
	var rz := maxf(hz - hx, 0.0)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var e: Array[Vector3] = [Vector3(-hx, 0, hz), Vector3(hx, 0, hz), Vector3(hx, 0, -hz), Vector3(-hx, 0, -hz)]
	var top: Array[Vector3] = [Vector3(-rx, rise, rz), Vector3(rx, rise, rz), Vector3(rx, rise, -rz), Vector3(-rx, rise, -rz)]
	for i in 4:
		var j := (i + 1) % 4
		var out := Vector3((e[i].x + e[j].x) * 0.5, 0.0, (e[i].z + e[j].z) * 0.5).normalized() + Vector3(0, 0.5, 0)
		_tri(st, e[i], e[j], top[j], out)
		_tri(st, e[i], top[j], top[i], out)
	# the underside, so the eave is never open
	for k: int in [0, 1, 2, 0, 2, 3]:
		st.add_vertex(e[k] + Vector3(0, -0.02, 0))
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.name = "Roof"
	mi.mesh = st.commit()
	mi.material_override = _roof_mat
	mi.position = _at(c.x, h + 0.12, c.y)
	look.frame.add_child(mi)
	# the fascia along the eaves (a darker board)
	var board := look._plain(FASCIA_COLOR, 0.9)
	for s: float in [-1.0, 1.0]:
		look._bar(_at(c.x, h + 0.06, c.y + s * hz), Vector3(hx * 2.0, FASCIA, FASCIA), board)
		look._bar(_at(c.x + s * hx, h + 0.06, c.y), Vector3(FASCIA, FASCIA, hz * 2.0), board)


## One triangle wound clockwise seen from `out` (Godot's front face).
func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, out: Vector3) -> void:
	var n := (b - a).cross(c - a)
	if n.dot(out) < 0.0:
		st.add_vertex(a)
		st.add_vertex(b)
		st.add_vertex(c)
	else:
		st.add_vertex(a)
		st.add_vertex(c)
		st.add_vertex(b)


## Stone at the south corners, a pilaster each.
func _corners(r: Vector4, h: float) -> void:
	var mat: Material = look.facade_stone()
	for u: float in [r.x, r.z]:
		look.fm.block(_at(u, 0.0, r.y - CORNER_STONE.y * 0.5), Vector3(CORNER_STONE.x, h, CORNER_STONE.y), 0.0, mat, false)
		look.fm.block(_at(u, 0.0, r.y - CORNER_STONE.y * 0.5), Vector3(CORNER_STONE.x + 0.14, 0.45, CORNER_STONE.y + 0.1), 0.0, mat, false)
		look.fm.block(_at(u, h - 0.5, r.y - CORNER_STONE.y * 0.5), Vector3(CORNER_STONE.x + 0.12, 0.16, CORNER_STONE.y + 0.1), 0.0, mat, false)


## Windows along the south face: a stone frame, a pointed head, warm glass with a mullion, shutters on every second.
func _windows(r: Vector4, h: float) -> void:
	var glass := _window_material()
	var width := r.z - r.x
	var count := maxi(1, floori(width / WINDOW_EVERY))
	var sill := WINDOW_LOW_SILL if h < 3.5 else WINDOW.y
	var tall := minf(WINDOW.z, h - sill - 0.7)
	if tall < 0.7:
		return
	var stone := look.stone()
	var dark := look._plain(IRON, 0.7)
	var shutter := look._plain(SHUTTER_WOOD, 0.85)
	for k in count:
		var u := r.x + width * (k + 0.5) / count
		var p := Vector2(u, r.y - 0.9)  # in front of the wall, for the flowers
		if _near_piece(Rect2(u - WINDOW_CLEAR.x, r.y - WINDOW_CLEAR.y - 0.5, WINDOW_CLEAR.x * 2.0, WINDOW_CLEAR.y + 0.5)):
			continue
		var w := WINDOW.x
		var depth := WINDOW.w
		var v := r.y - depth * 0.5
		look.fm.box(_at(u, sill + tall * 0.5, v), Vector3(w + 0.3, tall + 0.3, depth), 0.0, stone, false)
		look.fm.box(_at(u, sill - 0.08, r.y - depth * 0.6), Vector3(w + 0.5, 0.12, depth + 0.1), 0.0, stone, false)
		var gv := r.y - depth - 0.01
		look._bar(_at(u, sill + tall * 0.5, gv), Vector3(w, tall, 0.04), glass)
		var head := look._bar(_at(u, sill + tall, gv), Vector3(w * 0.72, w * 0.72, 0.04), glass)
		head.basis = Basis(Vector3.BACK, PI * 0.25)
		look._bar(_at(u, sill + tall * 0.5, gv - 0.01), Vector3(MULLION, tall + w * 0.5, 0.03), dark)
		look._bar(_at(u, sill + tall * 0.55, gv - 0.01), Vector3(w, MULLION, 0.03), dark)
		if k % 2 == 1:
			for s: float in [-1.0, 1.0]:
				look._bar(_at(u + s * (w * 0.5 + 0.2), sill + tall * 0.5, gv + 0.02), Vector3(0.32, tall, 0.05), shutter)
		_window_flowers(u, sill, r.y)


func _near_piece(rect: Rect2) -> bool:
	for r in _pieces:
		if r.intersects(rect):
			return true
	return false


## A flower box under some windows (stone, with two bushes in flower).
func _window_flowers(u: float, sill: float, face: float) -> void:
	if _rng.randf() < 0.7:
		look.fm.block(_at(u, sill - 0.42, face - 0.2), Vector3(WINDOW.x + 0.35, 0.28, 0.3), 0.0, look.stone(), false)
		for s: float in [-0.28, 0.28]:
			plant(_rng.randi() % 2, Vector3(u + s, sill - 0.16, face - 0.3), _rng.randf_range(0.42, 0.62))


## Wisteria hanging from the roof's edge on the south walls, and bushes at the foot, where nothing stands.
func _wall_flowers() -> void:
	for b in HubPlan.BUILDINGS:
		var r: Vector4 = b[&"rect"]
		var h: float = b[&"h"]
		var u := r.x + 0.9
		while u < r.z - 0.5:
			var p := Vector2(u, r.y - 0.4)
			if not _near_piece(Rect2(p.x - 0.6, p.y - 0.6, 1.2, 1.2)):
				var tall := _rng.randf_range(1.2, 2.0)
				_wisteria_spots.append(Vector3(p.x, h - tall, p.y))
				_wisteria_tall.append(tall)
			u += _rng.randf_range(WALL_WISTERIA_EVERY.x, WALL_WISTERIA_EVERY.y)
	_cascades()


## Round 2 (the art's big purple curtains at the roofs' corners: the Biblioteca's east end, the Aposento's two sides, the
## Forja's east end, the Capela's and the Mercador's corners): CASCADE_COUNT long tassels at each of a roof's two south
## corners, staggered across and in depth so they read as one thick curtain, clear of doors, arches and the stations.
func _cascades() -> void:
	for b in HubPlan.BUILDINGS:
		if not CASCADE_ON.has(b[&"id"]):
			continue
		var r: Vector4 = b[&"rect"]
		var h: float = b[&"h"]
		for side: float in [-1.0, 1.0]:
			var edge := r.x + 0.45 if side < 0.0 else r.z - 0.45
			if _near_piece(Rect2(edge - 0.9, r.y - 1.0, 1.8, 1.4)):
				continue
			for k in CASCADE_COUNT:
				var tall := _rng.randf_range(CASCADE_TALL.x, CASCADE_TALL.y)
				var u := edge - side * (0.3 + 0.62 * k) + _rng.randf_range(-0.1, 0.1)
				var v := r.y - 0.4 - 0.09 * k
				_wisteria_spots.append(Vector3(u, h - tall, v))
				_wisteria_tall.append(tall)


# ---------- water ----------

## The three basins: a sunken water (the hub's shallow water, bluer and brighter than the halls'), a stone kerb round each,
## a carved fish on the kerb.
func _water() -> void:
	var mat := Canal.water(WATER_SHEEN_AT, false, HubLook.compat())
	_water_mat = mat
	mat.set_shader_parameter(&"deep", Color(WATER_DEEP.r, WATER_DEEP.g, WATER_DEEP.b))
	mat.set_shader_parameter(&"shallow", Color(WATER_SHALLOW.r, WATER_SHALLOW.g, WATER_SHALLOW.b))
	mat.set_shader_parameter(&"alpha", 1.0)
	mat.set_shader_parameter(&"reflect_color", SUN_WARM)
	mat.set_shader_parameter(&"reflect_amount", 0.18)
	var basins := HubPlan.water()
	for bi in basins.size():
		var poly := basins[bi]
		if bi == GARDEN_BASIN:
			_garden(poly)
			continue
		var idx := Geometry2D.triangulate_polygon(poly)
		if idx.is_empty():
			continue
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in idx:
			var p := poly[i]
			st.set_normal(Vector3.UP)
			st.set_uv(Vector2(p.x * 0.2, 0.5))
			st.add_vertex(_at(p.x, WATER_LEVEL, p.y))
		var mi := MeshInstance3D.new()
		mi.name = "BasinWater"
		mi.mesh = st.commit()
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		look.frame.add_child(mi)
		_kerb(poly)


func _kerb(poly: PackedVector2Array, tall := KERB.y, with_fish := true) -> void:
	var mat := look.stone()
	var n := poly.size()
	var fish_at := -1
	var best := 0.0
	for i in n:
		var l := poly[i].distance_to(poly[(i + 1) % n])
		if l > best:
			best = l
			fish_at = i
	for i in n:
		var a := poly[i]
		var b := poly[(i + 1) % n]
		var l := a.distance_to(b)
		if l < 0.3:
			continue
		var dir := (b - a) / l
		var normal := Vector2(-dir.y, dir.x)
		var mid := (a + b) * 0.5
		# the kerb stands on the floor side
		if Geometry2D.is_point_in_polygon(mid + normal * 0.1, poly):
			normal = -normal
		var c := mid + normal * KERB.x * 0.5
		look.fm.block(_at(c.x, 0.0, c.y), Vector3(l + 0.05, tall, KERB.x), atan2(dir.y, dir.x), mat, false)
		if with_fish and i == fish_at:
			_fish(mid + normal * (KERB.x + 0.02), normal)


## A small fish in old gold on the kerb's face (a body and a tail: only in the stone, never a sign).
func _fish(p: Vector2, normal: Vector2) -> void:
	var gold := look._plain(OLD_GOLD, 0.5)
	var yaw := atan2(normal.x, -normal.y)
	var body := look._bar(_at(p.x, KERB.y * 0.5, p.y), Vector3(FISH.x, FISH.y, 0.02), gold, Basis(Vector3.UP, yaw))
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var side := Vector2(-normal.y, normal.x)
	var tail := p + side * (FISH.x * 0.5 + 0.04)
	var t := look._bar(_at(tail.x, KERB.y * 0.5, tail.y), Vector3(FISH.y * 1.1, FISH.y * 1.1, 0.02), gold, Basis(Vector3.UP, yaw) * Basis(Vector3.BACK, PI * 0.25))
	t.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## The big basin as a raised garden: soil over the hole at GARDEN_RAISE in a taller kerb, lilac and magenta flowers and
## shrubs on a jittered grid (clear of the kerb), a few cypresses deeper in.
func _garden(poly: PackedVector2Array) -> void:
	var idx := Geometry2D.triangulate_polygon(poly)
	if idx.is_empty():
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in idx:
		var p := poly[i]
		st.set_normal(Vector3.UP)
		st.add_vertex(_at(p.x, GARDEN_RAISE, p.y))
	var mi := MeshInstance3D.new()
	mi.name = "Garden"
	mi.mesh = st.commit()
	mi.material_override = look._plain(GARDEN_SOIL, 1.0)
	look.frame.add_child(mi)
	_kerb(poly, GARDEN_RAISE + 0.12, false)
	var lo := poly[0]
	var hi := poly[0]
	for p in poly:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	var x := lo.x
	while x < hi.x:
		var y := lo.y
		while y < hi.y:
			var p := Vector2(x + _rng.randf_range(-0.35, 0.35), y + _rng.randf_range(-0.35, 0.35))
			y += GARDEN_EVERY
			if not Geometry2D.is_point_in_polygon(p, poly):
				continue
			var edge := _edge_distance(p, poly)
			if edge < GARDEN_EDGE:
				continue
			var roll := _rng.randf()
			var spot := Vector3(p.x, GARDEN_RAISE, p.y)
			if roll < 0.08 and edge > GARDEN_CYPRESS_EDGE:
				_cypress_spots.append(spot)
				_cypress_tall.append(_rng.randf_range(2.4, 3.4))
			elif roll < GARDEN_LILAC:
				plant(0, spot, _rng.randf_range(0.7, 1.2))
			elif roll < GARDEN_LILAC + GARDEN_MAGENTA:
				plant(1, spot, _rng.randf_range(0.7, 1.2))
			elif roll < GARDEN_BARE:
				plant(2, spot, _rng.randf_range(0.6, 1.1))
		x += GARDEN_EVERY


func _edge_distance(p: Vector2, poly: PackedVector2Array) -> float:
	var best := INF
	for i in poly.size():
		var c := Geometry2D.get_closest_point_to_segment(p, poly[i], poly[(i + 1) % poly.size()])
		best = minf(best, p.distance_to(c))
	return best


## A plant in a crown list: 0 lilac, 1 magenta, anything else a green shrub.
func plant(kind: int, spot: Vector3, tall: float) -> void:
	match kind:
		0:
			if _rng.randf() < CREAM_SHARE:
				_cream_spots.append(spot)
				_cream_tall.append(tall)
			else:
				_flower_spots.append(spot)
				_flower_tall.append(tall)
		1:
			_magenta_spots.append(spot)
			_magenta_tall.append(tall)
		_:
			_leaf_spots.append(spot)
			_leaf_tall.append(tall)


## Lanterns (transforms, unit box scaled to their size) joined in one MultiMesh at the end.
func add_lanterns(xf: Array[Transform3D]) -> void:
	_lantern_xf.append_array(xf)


func _build_lanterns() -> void:
	var glow := HubGlow.new(_on_floor)
	for sq: Array in SQUARE_POOLS:
		glow.pool(sq[0], sq[1], sq[2], sq[3])
	if not _lantern_xf.is_empty():
		_lantern_meshes()
		for xf in _lantern_xf:
			glow.pool(Vector2(xf.origin.x, -xf.origin.z), LANTERN_POOL.x, LANTERN_POOL.y, FIRE_POOL.lerp(GOLD_POOL, 0.5))
	glow.build(look.frame)


## The lanterns' meshes, each over the same transforms: the amber boxes (one MultiMesh, "Lanterns"), a cap of dark iron
## over each and a soft halo round each (a card turned to the camera).
func _lantern_meshes() -> void:
	var bm := BoxMesh.new()
	bm.size = Vector3.ONE
	var cap := PrismMesh.new()
	cap.size = Vector3.ONE
	var halo := QuadMesh.new()
	halo.size = Vector2.ONE
	var body := MultiMesh.new()
	body.transform_format = MultiMesh.TRANSFORM_3D
	body.mesh = bm
	body.instance_count = _lantern_xf.size()
	var caps := MultiMesh.new()
	caps.transform_format = MultiMesh.TRANSFORM_3D
	caps.mesh = cap
	caps.instance_count = _lantern_xf.size()
	var halos := MultiMesh.new()
	halos.transform_format = MultiMesh.TRANSFORM_3D
	halos.mesh = halo
	halos.instance_count = _lantern_xf.size()
	for i in _lantern_xf.size():
		var xf := _lantern_xf[i]
		var size := xf.basis.get_scale().x
		body.set_instance_transform(i, xf)
		var top := xf.origin + Vector3(0.0, size * 0.5, 0.0)
		caps.set_instance_transform(i, Transform3D(Basis.from_scale(LANTERN_CAP * size), top + Vector3(0.0, LANTERN_CAP.y * size * 0.5, 0.0)))
		halos.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * size * LANTERN_HALO), xf.origin))
	var lit := StandardMaterial3D.new()
	lit.albedo_color = LANTERN_COLOR * 0.2
	lit.emission_enabled = true
	lit.emission = LANTERN_COLOR
	lit.emission_energy_multiplier = LANTERN_ENERGY
	var iron := StandardMaterial3D.new()
	iron.albedo_color = LANTERN_CAP_COLOR
	iron.roughness = 0.6
	iron.metallic = 0.3
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64
	var halo_mat := StandardMaterial3D.new()
	halo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	halo_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	halo_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	halo_mat.albedo_color = LANTERN_HALO_COLOR
	halo_mat.albedo_texture = tex
	halo_mat.disable_receive_shadows = true
	for part: Array in [["Lanterns", body, lit], ["LanternCaps", caps, iron], ["LanternHalos", halos, halo_mat]]:
		var mi := MultiMeshInstance3D.new()
		mi.name = part[0]
		mi.multimesh = part[1]
		mi.material_override = part[2]
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		look.frame.add_child(mi)


# ---------- the Videira's fountain ----------

## A round stone basin in the middle of the pergola (on the bed's top): the rim in blocks, water, a pedestal with a bowl
## over it, a column of water falling into the bowl and a curtain over its lip.
func _fountain() -> void:
	var c := Vector2(HubPlan.VINE_BED.x, HubPlan.VINE_BED.y)
	var y := HubPlan.BED_HEIGHT
	var f := FOUNTAIN_BASIN
	var stone := look.stone()
	var fm := look.fm
	fm.shaft(_at(c.x, y, c.y), f.x, f.y, stone)
	for i in FOUNTAIN_RIM_BLOCKS:
		var a := TAU * i / FOUNTAIN_RIM_BLOCKS
		var p := c + Vector2(cos(a), sin(a)) * (f.x - 0.1)
		fm.block(_at(p.x, y + f.y, p.y), Vector3(TAU * f.x / FOUNTAIN_RIM_BLOCKS + 0.04, 0.2, 0.32), a + PI * 0.5, stone, false)
	var clear := _water_mat.duplicate() as ShaderMaterial
	clear.set_shader_parameter(&"deep", FOUNTAIN_DEEP)
	clear.set_shader_parameter(&"shallow", FOUNTAIN_SHALLOW)
	clear.set_shader_parameter(&"reflect_amount", FOUNTAIN_SPARKLE)
	var water := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = f.z
	disc.bottom_radius = f.z
	disc.height = 0.02
	disc.radial_segments = 20
	disc.rings = 1
	water.mesh = disc
	water.material_override = clear
	water.position = _at(c.x, y + f.y + 0.02, c.y)
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(water)
	var top := y + f.y
	fm.shaft(_at(c.x, top, c.y), f.w, 1.0, stone)
	fm.shaft(_at(c.x, top + 0.95, c.y), 0.66, 0.14, stone)
	fm.shaft(_at(c.x, top + 1.07, c.y), 0.56, 0.1, stone)
	var bowl := MeshInstance3D.new()
	var bd := CylinderMesh.new()
	bd.top_radius = 0.5
	bd.bottom_radius = 0.5
	bd.height = 0.02
	bd.radial_segments = 14
	bowl.mesh = bd
	bowl.material_override = clear
	bowl.position = _at(c.x, top + 1.18, c.y)
	bowl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(bowl)
	fm.shaft(_at(c.x, top + 1.18, c.y), 0.1, 0.5, stone)
	facades.light(Vector3(c.x, 2.4, c.y), Color(1.0, 0.86, 0.6), 2.0, 7.0)
	# the falling water: three crossed strips from the finial into the bowl, a curtain from the bowl's lip to the basin
	for k in 3:
		_fall_strip(_at(c.x, top + 1.19, c.y), Vector2(0.34, 0.5), PI * k / 3.0, 0.7)
	var lip := 0.62
	for k in FOUNTAIN_FALLS:
		var a := TAU * k / FOUNTAIN_FALLS
		var p := c + Vector2(cos(a), sin(a)) * lip
		_fall_strip(_at(p.x, top + 0.3, p.y), Vector2(TAU * lip / FOUNTAIN_FALLS + 0.05, 0.85), a + PI * 0.5, 0.55)


## A strip of falling water: its foot at `foot`, size (width, drop), facing yaw.
func _fall_strip(foot: Vector3, size: Vector2, yaw: float, alpha: float) -> void:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = FALL_SHADER
	mat.set_shader_parameter(&"color", Color(WATER_BLUE.r, WATER_BLUE.g, WATER_BLUE.b).lightened(0.4))
	mat.set_shader_parameter(&"alpha", alpha)
	mat.set_shader_parameter(&"streaks", 3.0)
	mi.material_override = mat
	mi.position = foot + Vector3(0, size.y * 0.5, 0)
	mi.basis = Basis(Vector3.UP, yaw)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(mi)


# ---------- bridge ----------

## The south way as a bridge: balustrades on its sides, pointed arches under its south face (the dark behind, a fall in two
## of them) and a lion in the keystone of the middle one.
func _bridge() -> void:
	var mat := look.stone()
	for r in RAILS:
		look.fm.balustrade(_at(r.x, 0.0, r.y), _at(r.z, 0.0, r.w), true, mat)
	var face := BRIDGE_V.x - 0.12
	var inner := look.m.stone(0.0, look.stone_tint() * HubLook.INNER_TINT)
	var back := look.m.stone(0.0, look.stone_tint() * HubLook.INNER_TINT * ARCH_BACK)
	for u in BRIDGE_ARCHES:
		var recess := MeshInstance3D.new()
		recess.mesh = HubFacades.ogive_mesh(ARCH_SPAN, ARCH_SPRING - ARCH_FOOT, 0.8, [], 10)
		recess.material_override = back
		recess.position = _at(u, ARCH_FOOT, BRIDGE_V.x - 0.1)
		look.frame.add_child(recess)
		look.fm.voussoir_arch(_at(u, ARCH_FOOT, face), Vector2(0.0, 1.0), ARCH_SPAN, ARCH_SPRING - ARCH_FOOT, ARCH_RING, 0.4, inner, 0.8)
	# the piers between the arches and the cornice under the deck
	for u: float in [BRIDGE_ARCHES[0] + (BRIDGE_ARCHES[1] - BRIDGE_ARCHES[0]) * 0.5, BRIDGE_ARCHES[1] + (BRIDGE_ARCHES[2] - BRIDGE_ARCHES[1]) * 0.5]:
		look.fm.block(_at(u, ARCH_FOOT, face), Vector3(0.9, -ARCH_FOOT - 0.4, 0.5), 0.0, look.ashlar(), false)
	look.fm.block(_at((BRIDGE_U.x + BRIDGE_U.y) * 0.5, -0.5, face), Vector3(BRIDGE_U.y - BRIDGE_U.x, 0.3, 0.4), 0.0, look.stone(), false)
	for f in FALLS:
		if _open_void(Vector2(f.x, f.y), Vector2(0.0, -1.0)):
			_fall(f)
			_falls_all.append(f)
	for f in _extra_falls():
		_fall(f)
		_falls_all.append(f)


## Round 3: a few more white falls down the south cliffs (where the edge faces the camera, off the bridge, the buildings
## and the falls there already), picked off the edge: u, v, width, drop.
func _extra_falls() -> Array[Vector4]:
	var out: Array[Vector4] = []
	var taken: Array[Vector2] = []
	for f in FALLS:
		taken.append(Vector2(f.x, f.y))
	for e in _edge_points(1.5, 0.05, 0.0, false, true):
		if out.size() >= EXTRA_FALLS:
			break
		var p: Vector2 = e[0]
		var normal: Vector2 = e[1]
		if normal.y > -0.95 or _under_bridge(p) or _near_mass(p) or p.y < -16.0 or not _open_void(p, normal):
			continue
		var clear := true
		for t in taken:
			clear = clear and t.distance_to(p) > EXTRA_FALL_APART
		if clear:
			taken.append(p)
			out.append(Vector4(p.x, p.y - 0.15, _rng.randf_range(EXTRA_FALL_WIDTH.x, EXTRA_FALL_WIDTH.y), _rng.randf_range(EXTRA_FALL_DROP.x, EXTRA_FALL_DROP.y)))
	return out


## True when the drop in front of p (toward `normal`) is open void for FALL_OPEN.x metres, also FALL_OPEN.y to each side: no
## floor, basin or yard in the way (a fall in a trench between two courts, or in a pit of the floor, reads as a hole).
func _open_void(p: Vector2, normal: Vector2) -> bool:
	var along := Vector2(-normal.y, normal.x)
	for d: float in [3.0, 6.0, 9.0, FALL_OPEN.x]:
		for side: float in [-1.0, 0.0, 1.0]:
			if _in_plan(p + normal * d + along * side * FALL_OPEN.y):
				return false
	return true


## True when the point is on the plan: the floor, a basin, a sunken yard of the future rooms.
func _in_plan(p: Vector2) -> bool:
	for poly in HubPlan.floor_polys():
		if Geometry2D.is_point_in_polygon(p, poly):
			return true
	for w in HubPlan.water():
		if Geometry2D.is_point_in_polygon(p, w):
			return true
	for r in HubPlan.FUTURE_CUT:
		if Rect2(r.x, r.y, r.z - r.x, r.w - r.y).has_point(p):
			return true
	return false


## A fall hanging from just under the lip down `drop`, foam at its foot, a haze where it lands.
func _fall(f: Vector4) -> void:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(f.z * FALL_NARROW, f.w)
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = FALL_SHADER
	mat.set_shader_parameter(&"color", FALL_COLOR)
	mat.set_shader_parameter(&"foam_color", FALL_FOAM)
	mat.set_shader_parameter(&"alpha", FALL_ALPHA)
	mat.set_shader_parameter(&"vanish", FALL_VANISH)
	mat.set_shader_parameter(&"gap", FALL_GAP)
	mat.set_shader_parameter(&"lip", FALL_LIP)
	mat.set_shader_parameter(&"streaks", 5.0)
	mi.material_override = mat
	mi.position = _at(f.x, -0.4 - f.w * 0.5, f.y)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(mi)
	look.fk.mist_bank(_at(f.x, -0.4 - f.w * 0.85, f.y - 0.6), Vector2(f.z * 3.0, 2.2), FALL_MIST, 0.35, 0.3, 0.2)


# ---------- the Videira's pergola ----------

## The round gazebo over the fountain (see GAZEBO_*): columns, a cornice of stone between them, a wreath of leaves and grapes on it,
## tassels of wisteria and bunches of grapes hanging between the columns; no wall, so the water shows from every side.
func _pergola() -> void:
	var c := Vector2(HubPlan.VINE_BED.x, HubPlan.VINE_BED.y)
	var stone := look.stone()
	var fm := look.fm
	for k in GAZEBO_COLUMNS:
		var a := TAU * (k + 0.5) / GAZEBO_COLUMNS
		var p := c + Vector2(cos(a), sin(a)) * GAZEBO_RADIUS
		var y := HubPlan.BED_HEIGHT
		fm.shaft(_at(p.x, y, p.y), 0.34, 0.18, stone)
		fm.shaft(_at(p.x, y + 0.18, p.y), 0.22, PERGOLA_HEIGHT - 0.18 - y, stone)
		fm.shaft(_at(p.x, PERGOLA_HEIGHT, p.y), 0.32, 0.16, stone)
		# the cornice: a beam to the next column
		var q := c + Vector2(cos(a + TAU / GAZEBO_COLUMNS), sin(a + TAU / GAZEBO_COLUMNS)) * GAZEBO_RADIUS
		var mid := (p + q) * 0.5
		var yaw := atan2((q - p).y, (q - p).x)
		fm.block(_at(mid.x, PERGOLA_HEIGHT + 0.16, mid.y), Vector3(p.distance_to(q), 0.22, 0.34), yaw, stone, false)
		fm.block(_at(mid.x, PERGOLA_HEIGHT + 0.38, mid.y), Vector3(p.distance_to(q) + 0.1, 0.08, 0.42), yaw, stone, false)
		# between this column and the next: a cluster of wisteria and grapes hanging from the beam
		var m := (a + TAU / GAZEBO_COLUMNS * 0.5)
		for j in 3:
			var aa := a + TAU / GAZEBO_COLUMNS * (0.2 + 0.3 * j)
			var h := c + Vector2(cos(aa), sin(aa)) * (GAZEBO_RADIUS - 0.05)
			var hang := _rng.randf_range(1.0, 1.7)
			_wisteria_spots.append(Vector3(h.x, PERGOLA_HEIGHT - hang, h.y))
			_wisteria_tall.append(hang)
			var g := _rng.randf_range(GRAPE_HANG.x, GRAPE_HANG.y)
			_grape_spots.append(Vector3(h.x + cos(m) * 0.15, PERGOLA_HEIGHT - g, h.y + sin(m) * 0.15))
			_grape_tall.append(g)
	# the wreath of vine leaves on the cornice, open over the fountain and thinner on the camera's side (south, -v)
	var r := WREATH_HOLE
	while r <= GAZEBO_RADIUS + 0.6:
		var n := maxi(6, roundi(TAU * r / PERGOLA_LEAF_EVERY))
		for i in n:
			var a := TAU * (i + _rng.randf_range(-0.2, 0.2)) / n
			var south := clampf(-sin(a) * 0.5 + 0.5, 0.0, 1.0)
			if _rng.randf() > PERGOLA_GAP * south:
				var p := c + Vector2(cos(a), sin(a)) * r
				_roof_spots.append(Vector3(p.x, PERGOLA_HEIGHT + 0.2, p.y))
				_roof_tall.append(PERGOLA_LEAF.y * _rng.randf_range(0.8, 1.1))
		r += PERGOLA_LEAF_EVERY * 0.9


# ---------- the Ponto de Vigília ----------

## The arrival's post: a stone bowl on a round dais south-east of its wall (out from under the roof, in sight on
## arriving), a lit flame (the plan's one lit fire here) and a lion standard on a pole beside it.
func _vigil_post() -> void:
	var f := VIGIL_FLAME
	var stone := look.stone()
	var wall: Material = look.facade_stone()
	# the dais: two round steps of cream stone, then the pedestal of the bowl
	look.fm.shaft(_at(f.x, 0.0, f.z), 1.75, 0.16, wall)
	look.fm.shaft(_at(f.x, 0.16, f.z), 1.35, VIGIL_STEP, wall)
	look.fm.shaft(_at(f.x, 0.16 + VIGIL_STEP, f.z), 0.62, 0.2, wall)
	look.fk.brazier(Vector2(f.x, -f.z), 0.75, false, 1.6, true)
	var iron := look._plain(IRON, 0.6)
	var pole := _at(f.x + 1.5, 0.0, f.z)
	look._bar(pole + Vector3(0, 1.6, 0), Vector3(0.09, 3.2, 0.09), iron)
	look._bar(pole + Vector3(0, 3.15, 0), Vector3(1.0, 0.07, 0.07), iron)
	facades.banner(f.x + 1.5, 3.1, f.z, 0.85, 1.9)
	_vigil_bed(stone)
	_vigil_niche()


## The mass of the Vigilia as a raised bed: soil inside a cream balustrade on top, flowers, two cypresses, wisteria hanging
## down its south and east faces.
func _vigil_bed(stone: Material) -> void:
	var r := VIGIL_RECT
	var top := 2.4 + 0.12
	var inner := Vector4(r.x + VIGIL_BED_INSET, r.y + VIGIL_BED_INSET, r.z - VIGIL_BED_INSET, r.w - VIGIL_BED_INSET)
	look.fm.block(_at((inner.x + inner.z) * 0.5, top, (inner.y + inner.w) * 0.5), Vector3(inner.z - inner.x, 0.1, inner.w - inner.y), 0.0, look._plain(GARDEN_SOIL, 1.0), false)
	var q := Vector4(r.x + VIGIL_RAIL_INSET, r.y + VIGIL_RAIL_INSET, r.z - VIGIL_RAIL_INSET, r.w - VIGIL_RAIL_INSET)
	# round 6: one continuous low wall with its coping all round and just two posts (the south corners), not a thicket of balusters
	var wall_w := VIGIL_WALL.x
	var wall_h := VIGIL_WALL.y
	var cu := (q.x + q.z) * 0.5
	var cv := (q.y + q.w) * 0.5
	for sv: float in [q.y, q.w]:
		look.fm.block(_at(cu, top, sv), Vector3(q.z - q.x, wall_h, wall_w), 0.0, stone, false)
		look.fm.block(_at(cu, top + wall_h, sv), Vector3(q.z - q.x + 0.06, VIGIL_WALL.z, wall_w + 0.1), 0.0, stone, false)
	for su: float in [q.x, q.z]:
		look.fm.block(_at(su, top, cv), Vector3(wall_w, wall_h, q.w - q.y), 0.0, stone, false)
		look.fm.block(_at(su, top + wall_h, cv), Vector3(wall_w + 0.1, VIGIL_WALL.z, q.w - q.y + 0.06), 0.0, stone, false)
	for su: float in [q.x, q.z]:
		look.fm.post(_at(su, top, q.y), 0.0, Masonry.POST.y * RAIL_LOW, stone)
	var v := inner.y + 0.3
	var row := 0
	while v < inner.w - 0.2:
		for u: float in [lerpf(inner.x, inner.z, 0.3), lerpf(inner.x, inner.z, 0.72)]:
			plant((row + int(u * 10.0)) % 3, Vector3(u + _rng.randf_range(-0.12, 0.12), top + 0.05, v), _rng.randf_range(0.5, 0.95))
		v += VIGIL_PLANT_EVERY
		row += 1
	for c: Vector2 in [Vector2(inner.x + 0.5, inner.w - 0.25), Vector2(inner.z - 0.5, inner.w - 0.6)]:
		_cypress_spots.append(Vector3(c.x, top + 0.05, c.y))
		_cypress_tall.append(_rng.randf_range(2.4, 3.2))
	# wisteria down the south face
	var u := r.x + 0.5
	while u < r.z - 0.3:
		var hang := _rng.randf_range(1.3, 2.0)
		_wisteria_spots.append(Vector3(u, 2.45 - hang, r.y - 0.42))
		_wisteria_tall.append(hang)
		u += _rng.randf_range(0.8, 1.2)
	var w := r.y + 0.6
	while w < r.w - 0.4:
		var hang := _rng.randf_range(1.2, 1.9)
		_wisteria_spots.append(Vector3(r.z + 0.4, 2.45 - hang, w))
		_wisteria_tall.append(hang)
		w += _rng.randf_range(1.1, 1.7)


## A low niche of voussoirs in the mass's south face (facing the camera) with a dark back, a wine standard and a lantern each side.
func _vigil_niche() -> void:
	# round 3: a tall pointed arch of cream stone in a screen wall just west of the brazier, open to the square (VIGIL_ARCH)
	var w := HubPlan.VIGIL_ARCH
	var face := w.x + w.z  # the wall's east face (u)
	var wall: Material = look.facade_stone()
	var n := VIGIL_ARCH_OPENING
	var r := n.x * n.z
	var cx := r - n.x * 0.5
	var spring := n.y - sqrt((r + n.w) * (r + n.w) - cx * cx)
	var tall := VIGIL_ARCH_WALL_TALL
	look.fm.block(_at(w.x, 0.0, w.y), Vector3(w.z * 2.0, tall, w.w * 2.0), 0.0, wall, false)
	look.fm.block(_at(w.x, tall, w.y), Vector3(w.z * 2.0 + 0.14, 0.12, w.w * 2.0 + 0.14), 0.0, look.stone(), false)
	var foot := _at(face - 0.2, 0.0, w.y)
	look.fm.voussoir_arch(foot, Vector2(1.0, 0.0), n.x, spring, n.w, 0.45, wall, n.z)
	for sd: float in [-1.0, 1.0]:
		look.fm.block(_at(face - 0.2, 0.0, w.y + sd * (n.x * 0.5 + n.w * 0.5)), Vector3(0.45, spring + 0.05, n.w), 0.0, wall, false)
	var back := MeshInstance3D.new()
	back.mesh = HubFacades.ogive_mesh(n.x, spring, n.z, [], 8)
	back.material_override = look._plain(Color(0.14, 0.09, 0.08), 1.0)
	back.position = _at(face + 0.01, 0.0, w.y)
	back.basis = Basis(Vector3.UP, PI * 0.5)
	look.frame.add_child(back)
	for sd: float in [-1.0, 1.0]:
		facades.banner(face + 0.02, tall - 0.5, w.y + sd * (n.x * 0.5 + n.w + 0.33), 0.5, 1.6, PI * 0.5)
		var lp := _at(face + 0.2, 1.3, w.y + sd * (n.x * 0.5 + n.w + 0.12))
		_lantern_xf.append(Transform3D(Basis.from_scale(Vector3.ONE * LAMP_LANTERN), lp))


# ---------- the future rooms ----------

## Behind each future door the sunken yard (YARD_DROP under the floor, in the simulation a cliff): a stair down from the
## door, the dark floor, a low wall round it and a lantern; the real door (HubBlockout) is what closes it.
func _future_yards() -> void:
	var floor_mat := look.m.stone(-YARD_DROP, look.stone_tint() * YARD_FLOOR)
	var wall := look.ashlar()
	var nosing := look._plain(STEP_NOSING, 0.8)
	var treads := look._plain(STEP_TREAD, 0.9)
	var shade := look._plain(STEP_SHADOW, 1.0)
	for yi in FUTURE_YARDS.size():
		var y := FUTURE_YARDS[yi]
		var c := Vector2(y.x + y.z, y.y + y.w) * 0.5
		var w := y.z - y.x
		var d := y.w - y.y
		look.fm.block(_at(c.x, -YARD_DROP - 0.4, c.y - 1.0), Vector3(w - 0.6, 0.4, d - 2.0), 0.0, floor_mat, false)
		# the low wall on three sides (the north side is the cliff of the way)
		look.fm.block(_at(c.x, -YARD_DROP, y.y + YARD_WALL.x * 0.5), Vector3(w, YARD_WALL.y + YARD_DROP - 0.1, YARD_WALL.x), 0.0, wall, false)
		for s: float in [-1.0, 1.0]:
			look.fm.block(_at(c.x + s * (w * 0.5 - YARD_WALL.x * 0.5), -YARD_DROP, c.y - 1.0), Vector3(YARD_WALL.x, YARD_WALL.y + YARD_DROP - 0.1, d - 2.0), 0.0, wall, false)
		# the stair down from the door
		var mouth := HubPlan.DOORS[HubPlan.FUTURE_A if yi == 0 else HubPlan.FUTURE_B] as Vector4
		for k in YARD_STEPS:
			var top := -YARD_DROP / (YARD_STEPS + 1) * (k + 1)
			var tread := Vector3(mouth.z * 2.0 + 1.0, top + YARD_DROP, 0.45)
			look.fm.block(_at(mouth.x, -YARD_DROP, -17.35 - k * 0.45), tread, 0.0, treads, false)
			var riser := YARD_DROP / (YARD_STEPS + 1)
			look.fm.block(_at(mouth.x, top - riser * STEP_SHADOW_SHARE, -17.35 - k * 0.45 - 0.24), Vector3(tread.x, riser * STEP_SHADOW_SHARE, 0.03), 0.0, shade, false)
			look.fm.block(_at(mouth.x, top - 0.01, -17.35 - k * 0.45 - 0.2), Vector3(tread.x + 0.06, STEP_NOSING_H, 0.1), 0.0, nosing, false)
		_lamp(Vector2(mouth.x - mouth.z + 0.4, -15.9), true)
		_lamp(Vector2(mouth.x + mouth.z - 0.4, -15.9), true)


# ---------- the lower plaza (round 3) ----------
const PLAZA_STONE_TOP := Vector2(0.14, 0.08)  # the bed's coping: how much wider, how tall
const PLAZA_SOIL := Color(0.26, 0.18, 0.12)
const PLAZA_BED_EVERY := 0.55
const PLAZA_BLOOM := Vector2(0.7, 1.1)  # the clumps' height factor
const PLAZA_LAMPS: Array[Vector2] = [Vector2(-11.2, -16.4), Vector2(2.2, -16.4), Vector2(-11.2, -13.0), Vector2(1.3, -13.4)]


## The chasm south of the Videira is a lower plaza (HubPlan.PLAZA): a planter between its two flights, a big bed of
## flowers in its middle (kerbed stone, dark soil, clumps of lilac, magenta and cream) and four lamps.
func _plaza() -> void:
	if HubPlan.PLAZA_DROP <= 0.0:
		return
	var stone: Material = look.stone()
	var soil: Material = look._plain(PLAZA_SOIL, 1.0)
	for spec: Array in [[HubPlan.PLANTER_BOX, HubPlan.PLANTER_HEIGHT], [HubPlan.PLAZA_BED, HubPlan.PLAZA_BED_HEIGHT]]:
		var b: Vector4 = spec[0]
		var h: float = spec[1]
		look.fm.block(_at(b.x, 0.0, b.y), Vector3(b.z * 2.0, h - PLAZA_STONE_TOP.y, b.w * 2.0), 0.0, stone, false)
		look.fm.block(_at(b.x, h - PLAZA_STONE_TOP.y, b.y), Vector3(b.z * 2.0 + PLAZA_STONE_TOP.x, PLAZA_STONE_TOP.y, b.w * 2.0 + PLAZA_STONE_TOP.x), 0.0, stone, false)
		look._bar(_at(b.x, h - 0.03, b.y), Vector3(b.z * 2.0 - 0.3, 0.07, b.w * 2.0 - 0.3), soil)
		var u := b.x - b.z + 0.35
		while u < b.x + b.z - 0.3:
			var v := b.y - b.w + 0.3
			while v < b.y + b.w - 0.25:
				var spot := Vector3(u + _rng.randf_range(-0.2, 0.2), h, v + _rng.randf_range(-0.2, 0.2))
				var roll := _rng.randf()
				if roll < 0.55:
					plant(0, spot, _rng.randf_range(PLAZA_BLOOM.x, PLAZA_BLOOM.y))
				elif roll < 0.8:
					plant(1, spot, _rng.randf_range(PLAZA_BLOOM.x, PLAZA_BLOOM.y))
				else:
					plant(2, spot, _rng.randf_range(0.4, 0.7))
				v += PLAZA_BED_EVERY * _rng.randf_range(0.8, 1.3)
			u += PLAZA_BED_EVERY * _rng.randf_range(0.8, 1.3)
	for p in PLAZA_LAMPS:
		_lamp(p, true)


# ---------- the way's clear, the mountain behind ----------

## Round 3: no cypress within PATH_CLEAR of a way (they stood in the middle of the squares); they stay on the edges and behind.
func _clear_cypresses() -> void:
	var keep_spots: Array[Vector3] = []
	var keep_tall: Array[float] = []
	for i in _cypress_spots.size():
		var p := Vector2(_cypress_spots[i].x, _cypress_spots[i].z)
		var near := false
		for line: Array[Vector2] in [PATH_MAIN, PATH_GATE]:
			for k in line.size() - 1:
				near = near or p.distance_to(Geometry2D.get_closest_point_to_segment(p, line[k], line[k + 1])) < PATH_CLEAR
		if not near:
			keep_spots.append(_cypress_spots[i])
			keep_tall.append(_cypress_tall[i])
	_cypress_spots = keep_spots
	_cypress_tall = keep_tall


## Round 3: the grey-lilac rock of the mountain standing up behind the west and north edges (BACKDROP_TALL over the floor at the
## least), moss and cypresses on its top: the hub sits in a cliff, not in front of an empty sky.
func _backdrop() -> void:
	var rock := _rock_material()
	var placed := 0
	for e in _edge_points(BACKDROP_EVERY, 0.0, 0.0, false, true):
		var p: Vector2 = e[0]
		var out: Vector2 = e[1]
		if out.y < 0.5 or p.y < BACKDROP_MIN_V:
			continue  # only the far north rim: west and inner edges put the rock between the camera and the floor
		if p.distance_to(RED_TREE_AT) < RED_TREE_CLEAR or p.distance_to(Vector2(RED_TREE_2.x, RED_TREE_2.y)) < RED_TREE_CLEAR:
			continue
		var along := Vector2(-out.y, out.x)
		var wide := _rng.randf_range(BACKDROP_WIDE.x, BACKDROP_WIDE.y)
		var tall := _rng.randf_range(BACKDROP_TALL.x, BACKDROP_TALL.y)
		var deep := _rng.randf_range(BACKDROP_DEEP.x, BACKDROP_DEEP.y)
		var c := p + out * (deep * 0.5 + _rng.randf_range(0.6, 1.6))
		var size := Vector3(wide, tall + BACKDROP_SINK, deep)
		var mi := look.fm.block(_at(c.x, -BACKDROP_SINK, c.y), size, atan2(along.y, along.x), rock, false)
		mi.mesh = look.fm.bevel_mesh(size, ROCK_CHAMFER, _rng.randi_range(0, 7), _rng.randf_range(0.2, 0.5))
		mi.basis = Basis.from_euler(Vector3(_rng.randf_range(-ROCK_TILT, ROCK_TILT), atan2(along.y, along.x) + _rng.randf_range(-0.2, 0.2), _rng.randf_range(-ROCK_TILT, ROCK_TILT)))
		_leaf_spots.append(Vector3(c.x, tall - 0.2, c.y))
		_leaf_tall.append(_rng.randf_range(0.8, 1.4))
		placed += 1
		if placed % 3 == 0:
			_cypress_spots.append(Vector3(c.x + along.x * 0.4, tall - 0.3, c.y + along.y * 0.4))
			_cypress_tall.append(_rng.randf_range(CYPRESS_TALL.x, CYPRESS_TALL.y))


# ---------- plants and lamps ----------

func _edges() -> void:
	for e in _edge_points(SHRUB_EVERY, EDGE_INSET):
		var p: Vector2 = e[0]
		_leaf_spots.append(Vector3(p.x, 0.0, p.y))
		_leaf_tall.append(_rng.randf_range(SHRUB.x, SHRUB.y))
	for e in _edge_points(CYPRESS_EVERY, EDGE_INSET + 0.2, PLANT_CLEAR + 1.0):
		var p: Vector2 = e[0]
		if (e[1] as Vector2).y < -0.25:
			continue  # on a south edge it would hide the floor behind it
		_cypress_spots.append(Vector3(p.x, 0.0, p.y))
		_cypress_tall.append(_rng.randf_range(CYPRESS_TALL.x, CYPRESS_TALL.y))
	_trees()
	for e in _edge_points(LAMP_EVERY, 0.45, PLANT_CLEAR - 0.6):
		_lamp(e[0])


## Round trees on rock shelves just beyond the north and side edges (never the south ones: they would hide the floor), a
## trunk down to the shelf and a crown over the edge.
func _trees() -> void:
	var rock := look.stone()
	var bark := look._plain(Color(0.28, 0.2, 0.14), 0.9)
	var shelves := 0
	for e in _edge_points(TREE_EVERY, 0.15, 0.0, false):
		var out: Vector2 = e[1]
		if out.y < -0.25:
			continue
		var edge: Vector2 = e[0]
		var c := edge + out * TREE_SHELF.x * 0.5
		var free := true
		for k in [0.6, 1.3, 2.0]:
			free = free and not _on_floor(edge + out * (k + 0.6))
		for b in HubPlan.BUILDINGS:
			var br: Vector4 = b[&"rect"]
			free = free and not Rect2(br.x - 1.0, br.y - 1.0, br.z - br.x + 2.0, br.w - br.y + 2.0).has_point(c)
		if not free:
			continue
		if c.distance_to(RED_TREE_AT) < RED_TREE_CLEAR or c.distance_to(Vector2(RED_TREE_2.x, RED_TREE_2.y)) < RED_TREE_CLEAR:
			continue
		look.fm.block(_at(c.x, -TREE_SHELF.y - 0.3, c.y), Vector3(TREE_SHELF.x, TREE_SHELF.y + 0.3, TREE_SHELF.x * 0.8), _rng.randf() * PI, rock, false)
		shelves += 1
		if shelves % TREE_ROUND_EVERY == 0:
			look._bar(_at(c.x, TREE_TRUNK.y * 0.5 - 0.3, c.y), Vector3(TREE_TRUNK.x, TREE_TRUNK.y, TREE_TRUNK.x), bark)
			_tree_spots.append(Vector3(c.x, TREE_TRUNK.y - 0.7, c.y))
			_tree_tall.append(_rng.randf_range(TREE_TALL.x, TREE_TALL.y))
		else:
			# the art's dark cypresses: two on the shelf, one taller
			var along := Vector2(-out.y, out.x)
			for k in 2:
				var q := c + along * (-0.55 + 1.1 * k)
				_cypress_spots.append(Vector3(q.x, 0.0, q.y))
				_cypress_tall.append(_rng.randf_range(CYPRESS_TALL.x, CYPRESS_TALL.y) + (0.8 if k == 0 else 0.0))


## A lamp post in cream stone (plinth, shaft, a cap) carrying a lit lantern (the lanterns' one MultiMesh; no light of its
## own: the hub is lit by its air, its pools and the few lights of its faces).
func _lamp(p: Vector2, force := false) -> void:
	if not force and not _lantern_free(p):
		return
	var stone: Material = look.facade_stone()
	var fm := look.fm
	fm.block(_at(p.x, 0.0, p.y), Vector3(0.5, 0.5, 0.5), 0.0, stone, false)
	fm.block(_at(p.x, 0.5, p.y), Vector3(0.3, 1.1, 0.3), 0.0, stone, false)
	fm.block(_at(p.x, 1.6, p.y), Vector3(0.46, 0.12, 0.46), 0.0, stone, false)
	_lantern_xf.append(Transform3D(Basis.from_scale(Vector3.ONE * LAMP_LANTERN), _at(p.x, 1.72 + LAMP_LANTERN * 0.5, p.y)))


func _window_material() -> StandardMaterial3D:
	if _window_mat == null:
		_window_mat = HubLook.lit_opening(WINDOW_GLOW, GLASS_GLOW, WINDOW_TOP, WINDOW_MID)
	return _window_mat


# ---------- balustrades, planters ----------

## A low cream balustrade along every outer edge that is not behind a building, the future rooms' mouths or an existing
## rail, inset from the lip; every second post carries a lit lantern.
func _balustrades() -> void:
	var mat: Material = look.facade_stone()
	var post_top := RAIL_POST.y + RAIL_CAP_TALL
	for poly in HubPlan.floor_polys():
		var n := poly.size()
		for i in n:
			var a := poly[i]
			var b := poly[(i + 1) % n]
			var length := a.distance_to(b)
			if length < RAIL_MIN:
				continue
			var dir := (b - a) / length
			var normal := Vector2(-dir.y, dir.x)
			var mid := (a + b) * 0.5
			var into := normal if _on_floor(mid + normal * 0.25) else -normal
			if -into.y > 0.35 or mid.y < -16.4 or _rail_taken(mid) or _near_mass(mid) or HubPlan.near_plaza(mid, true):
				continue
			var p0 := a + dir * 0.5 + into * RAIL_INSET
			var p1 := b - dir * 0.5 + into * RAIL_INSET
			if not (_on_floor(p0) and _on_floor(p1)):
				continue
			if _facing_court(mid, into):
				continue
			var spans := maxi(1, roundi(p0.distance_to(p1) / RAIL_GAP))
			_thin_rail(p0, p1, spans, mat)
			for k in range(0, spans + 1, RAIL_LANTERN_EVERY):
				var q := p0.lerp(p1, float(k) / spans)
				if not _lantern_free(q):
					continue
				_lantern_xf.append(Transform3D(Basis.from_scale(Vector3.ONE * LANTERN_SIZE), _at(q.x, post_top + LANTERN_SIZE * 0.5 + 0.02, q.y)))


## A thin cream balustrade from a to b in `spans` bays (see RAIL_*): square posts with a cap, a bar on top, a curb and balusters.
func _thin_rail(a: Vector2, b: Vector2, spans: int, mat: Material) -> void:
	var fm := look.fm
	var yaw := atan2((b - a).y, (b - a).x)
	for i in spans + 1:
		var p := a.lerp(b, float(i) / spans)
		fm.block(_at(p.x, 0.0, p.y), Vector3(RAIL_POST.x, RAIL_POST.y, RAIL_POST.x), yaw, mat, false)
		fm.block(_at(p.x, RAIL_POST.y, p.y), Vector3(RAIL_POST.z, RAIL_CAP_TALL, RAIL_POST.z), yaw, mat, false)
	for i in spans:
		var p0 := a.lerp(b, float(i) / spans)
		var p1 := a.lerp(b, float(i + 1) / spans)
		var mid := (p0 + p1) * 0.5
		var span := p0.distance_to(p1) - RAIL_POST.x
		fm.block(_at(mid.x, RAIL_TOP - RAIL_BAR.x, mid.y), Vector3(span, RAIL_BAR.x, RAIL_BAR.y), yaw, mat, false)
		fm.block(_at(mid.x, 0.0, mid.y), Vector3(span, 0.1, RAIL_BAR.y), yaw, mat, false)
		var shaft := RAIL_TOP - RAIL_BAR.x - 0.1
		var count := maxi(2, roundi(span / 0.34))
		for k in count:
			var q := p0.lerp(p1, (k + 1.0) / (count + 1.0))
			fm.block(_at(q.x, 0.1, q.y), Vector3(RAIL_BALUSTER, shaft, RAIL_BALUSTER), yaw, mat, false)
			fm.block(_at(q.x, 0.1 + shaft * 0.3, q.y), Vector3(RAIL_BALUSTER * 1.5, shaft * 0.3, RAIL_BALUSTER * 1.5), yaw, mat, false)


## Round 5: a ledge rock is not a crate: a third of them stand tall and narrow, the rest vary in all three sizes; each is
## chamfered deeply (ROCK_CHAMFER), turned (any yaw within 0.5 rad of the edge's) and tilted up to ROCK_TILT rad.
func _rock_size() -> Vector3:
	if _rng.randf() < ROCK_TALL_SHARE:
		return Vector3(_rng.randf_range(0.9, 1.5), _rng.randf_range(1.9, 3.0), _rng.randf_range(0.9, 1.4))
	return Vector3(_rng.randf_range(1.3, 2.9), _rng.randf_range(0.7, 1.5), _rng.randf_range(1.0, 1.8))


## True when a lantern may stand at p (none within LANTERN_APART); records it when it may.
func _lantern_free(p: Vector2) -> bool:
	for q in _lantern_at:
		if q.distance_to(p) < LANTERN_APART:
			return false
	_lantern_at.append(p)
	return true


## True when the edge at `mid` (the floor on its `into` side) has floor again within RAIL_TRENCH beyond it (a trench between
## two courts, not the drop to the void) and is the northern of the two: its rail would only be a second wall in the middle.
func _facing_court(mid: Vector2, into: Vector2) -> bool:
	for d: float in [RAIL_TRENCH.x, RAIL_TRENCH.y]:
		var beyond := mid - into * d
		if _on_floor(beyond):
			return mid.y >= beyond.y
	return false


## True when the point is on one of RAILS (the bridge's) or near the bridge's arches.
func _rail_taken(p: Vector2) -> bool:
	for r in RAILS:
		var c := Geometry2D.get_closest_point_to_segment(p, Vector2(r.x, r.y), Vector2(r.z, r.w))
		if c.distance_to(p) < RAIL_CLEAR:
			return true
	return false


## True when the point is in or by a building or the gate (an edge behind a mass is never seen).
func _near_mass(p: Vector2) -> bool:
	for b in HubPlan.BUILDINGS:
		var r: Vector4 = b[&"rect"]
		if Rect2(r.x - RAIL_CLEAR, r.y - RAIL_CLEAR, r.z - r.x + RAIL_CLEAR * 2.0, r.w - r.y + RAIL_CLEAR * 2.0).has_point(p):
			return true
	var g := HubPlan.GATE
	return Rect2(g.x - RAIL_CLEAR, g.y - RAIL_CLEAR, g.z - g.x + RAIL_CLEAR * 2.0, g.w - g.y + RAIL_CLEAR * 2.0).has_point(p)


## A stone planter with four flowering plants inside the rail every PLANTER_EVERY m of edge, long side along the edge.
func _planters() -> void:
	var stone := look.stone()
	var soil := look._plain(GARDEN_SOIL, 1.0)
	for e in _edge_points(PLANTER_EVERY, PLANTER_INSET, PLANT_CLEAR + 0.6):
		var c: Vector2 = e[0]
		var out: Vector2 = e[1]
		if _near_mass(c):
			continue
		var along := Vector2(-out.y, out.x)
		var yaw := atan2(along.y, along.x)
		look.fm.block(_at(c.x, 0.0, c.y), Vector3(PLANTER.x, PLANTER.y, PLANTER.z), yaw, stone, false)
		look._bar(_at(c.x, PLANTER.y - 0.02, c.y), Vector3(PLANTER.x - 0.2, 0.05, PLANTER.z - 0.2), soil, Basis(Vector3.UP, yaw))
		for k in 3:
			var q := c + along * (-PLANTER.x * 0.3 + PLANTER.x * 0.3 * k)
			plant(0 if (k + int(absf(c.x))) % 3 != 0 else 1, Vector3(q.x, PLANTER.y, q.y), _rng.randf_range(0.5, 0.85))


# ---------- the mountain: cliffs, ledges, the red tree, the way's glow ----------

func _rock_material() -> ShaderMaterial:
	if _rock == null:
		_rock = look.cliff_material() as ShaderMaterial
	return _rock


## Tufts of shrub, flowers and hanging wisteria on the face just under every lip, and ledges of the cliff's rock
## jutting out of it (broken silhouette, moss on top): the platform is the top of a mountain, not a block.
func _cliffs() -> void:
	var rock := _rock_material()
	for e in _edge_points(CLIFF_TUFT_EVERY, 0.05, 0.0, false, true):
		var p: Vector2 = e[0]
		var out: Vector2 = e[1]
		if _under_bridge(p):
			continue
		var depth := lerpf(CLIFF_TUFT_DEPTH.x, CLIFF_TUFT_DEPTH.y, pow(_rng.randf(), 2.2))
		var at := Vector3(p.x + out.x * 0.35, -depth, p.y + out.y * 0.35)
		var roll := _rng.randf()
		if roll < 0.4:
			_leaf_spots.append(at)
			_leaf_tall.append(_rng.randf_range(1.0, 1.8))
		elif roll < 0.58:
			plant(_rng.randi() % 2, at, _rng.randf_range(0.8, 1.3))
		elif _near_avoid(p):
			continue
		else:
			# round 3: a tassel hung from the lip (its top at the paving's level, against the rock), never a bubble in the air
			var hang := _rng.randf_range(HANG_TALL.x, HANG_TALL.y)
			_wisteria_spots.append(Vector3(p.x + out.x * 0.2, 0.1 - hang, p.y + out.y * 0.2))
			_wisteria_tall.append(hang)
	# round 3: ivy hanging in long curtains from the lip, and stacks of rock stepping out and down the face
	for e in _edge_points(IVY_EVERY, 0.05, 0.0, false, true):
		var p: Vector2 = e[0]
		var out: Vector2 = e[1]
		if _under_bridge(p) or _near_avoid(p):
			continue
		var tall := _rng.randf_range(IVY_TALL.x, IVY_TALL.y)
		_ivy_spots.append(Vector3(p.x + out.x * 0.18, 0.05 - tall, p.y + out.y * 0.18))
		_ivy_tall.append(tall)
	for e in _edge_points(ROCK_STEP_EVERY, 0.0, 0.0, false, true):
		var p: Vector2 = e[0]
		var out: Vector2 = e[1]
		if _under_bridge(p):
			continue
		var along := Vector2(-out.y, out.x)
		var yaw := atan2(along.y, along.x)
		var y := -_rng.randf_range(ROCK_STEP_DROP.x, ROCK_STEP_DROP.y)
		var steps := _rng.randi_range(ROCK_STEPS.x, ROCK_STEPS.y)
		for k in steps:
			var size := _rock_size()
			var c := p + out * (size.z * 0.5 - 0.2 + ROCK_STEP_OUT * k) + along * _rng.randf_range(-0.6, 0.6)
			var rock_mi := look.fm.block(_at(c.x, y - size.y, c.y), size, 0.0, rock, false)
			rock_mi.mesh = look.fm.bevel_mesh(size, ROCK_CHAMFER, _rng.randi_range(0, 7), _rng.randf_range(0.2, 0.5))
			rock_mi.basis = Basis.from_euler(Vector3(_rng.randf_range(-ROCK_TILT, ROCK_TILT), yaw + _rng.randf_range(-0.5, 0.5), _rng.randf_range(-ROCK_TILT, ROCK_TILT)))
			if k < 2:
				_leaf_spots.append(Vector3(c.x, y, c.y))
				_leaf_tall.append(_rng.randf_range(0.5, 1.0))
			y -= size.y * 0.55 + _rng.randf_range(ROCK_STEP_DROP.x, ROCK_STEP_DROP.y) * 0.6
	# round 2: dark crowns of cypress and trees far down the mountain, past the edge, going into the indigo mist
	for e in _edge_points(DEEP_EVERY, 0.0, 0.0, false, true):
		var p: Vector2 = e[0]
		var out: Vector2 = e[1]
		if _under_bridge(p):
			continue
		var q := p + out * _rng.randf_range(DEEP_OUT.x, DEEP_OUT.y)
		var depth := _rng.randf_range(DEEP_DEPTH.x, DEEP_DEPTH.y)
		var at := Vector3(q.x, -depth, q.y)
		if _rng.randf() < 0.55:
			_deep_spots.append(at)
			_deep_tall.append(_rng.randf_range(DEEP_TALL.x, DEEP_TALL.y))
		else:
			_deep_round_spots.append(at)
			_deep_round_tall.append(_rng.randf_range(DEEP_TALL.x, DEEP_TALL.y) * 0.8)
	for e in _edge_points(LEDGE_EVERY, 0.0, 0.0, false, true):
		var p: Vector2 = e[0]
		var out: Vector2 = e[1]
		if _under_bridge(p):
			continue
		var along := Vector2(-out.y, out.x)
		var depth := lerpf(LEDGE_DEPTH.x, LEDGE_DEPTH.y, _rng.randf())
		var c := p + out * (LEDGE.z * 0.5 - 0.15)
		var size := Vector3(LEDGE.x * _rng.randf_range(0.7, 1.25), LEDGE.y * _rng.randf_range(0.8, 1.4), LEDGE.z * _rng.randf_range(0.8, 1.2))
		look.fm.block(_at(c.x, -depth - size.y, c.y), size, atan2(along.y, along.x), rock, false)
		_leaf_spots.append(Vector3(c.x, -depth, c.y))
		_leaf_tall.append(_rng.randf_range(0.7, 1.3))


## True under the south bridge's face or its falls (the arches and the water stay seen).
func _under_bridge(p: Vector2) -> bool:
	if p.y < BRIDGE_V.x + 0.6 and p.x > BRIDGE_U.x - 1.5 and p.x < BRIDGE_U.y + 1.5:
		return true
	for f in _falls_all:
		if absf(p.x - f.x) < f.z * 0.5 + 0.8 and absf(p.y - f.y) < 1.2:
			return true
	return false


## The art's red tree in the north-west corner: a shelf of rock beyond the lip, a trunk and a broad crown of crimson leaves.
func _red_tree() -> void:
	_red_tree_at(RED_TREE_AT, 1.0, "RedTree")
	_red_tree_at(Vector2(RED_TREE_2.x, RED_TREE_2.y), RED_TREE_2.z, "RedTree2")


func _red_tree_at(c: Vector2, size: float, label: String) -> void:
	var trunk := RED_TREE.z * size
	look.fm.block(_at(c.x, -TREE_SHELF.y - 0.3, c.y), Vector3(TREE_SHELF.x * 1.5, TREE_SHELF.y + 0.3, TREE_SHELF.x * 1.2), 0.4, look.stone(), false)
	look._bar(_at(c.x, trunk * 0.5 - 0.3, c.y), Vector3(0.38 * size, trunk, 0.38 * size), look._plain(Color(0.24, 0.16, 0.12), 0.9))
	look.add_crowns([Vector3(c.x, trunk - 0.8, c.y)] as Array[Vector3], [RED_TREE.y * size] as Array[float], RED_LEAF_A, RED_LEAF_B, RED_TREE.x * size, label, true)


# ---------- the far ridges ----------

## The sky and the sea of cloud, then layers of mountain north of the plan, each paler than the one in front: the void
## round the floor reads as air with mountains in it, never a flat grey.
func _ridges() -> void:
	var sky := _gradient_mat(SKY_TOP, SKY_HORIZON, 1.0, 0.0)
	var card := MeshInstance3D.new()
	card.name = "Sky"
	var cq := QuadMesh.new()
	cq.size = Vector2(SKY_CARD.y, SKY_CARD.z)
	card.mesh = cq
	card.material_override = sky
	card.position = _at(RIDGE_U, SKY_CARD.w + SKY_CARD.z * 0.5, SKY_CARD.x)
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(card)
	var sea := MeshInstance3D.new()
	sea.name = "CloudSea"
	var pm := PlaneMesh.new()
	pm.size = Vector2(SEA_SIZE, SEA_SIZE)
	sea.mesh = pm
	sea.material_override = _gradient_mat(SEA_FAR, SEA_NEAR, 0.0, SEA_CLOUD)
	sea.position = _at(RIDGE_U, SEA_Y, SEA_SIZE * 0.4)
	sea.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(sea)
	for r in RIDGES:
		_ridge_card(r, RIDGE_U, float(r[&"v"]), 0.0)
	for r in RIDGES_WEST:
		_ridge_card(r, float(r[&"u"]), float(r[&"v"]), PI * 0.5)


## One ridge card of the far mountains at (u, v), turned `yaw` about the vertical (0 faces south, the camera).
func _ridge_card(r: Dictionary, u: float, v: float, yaw: float) -> void:
	var mi := MeshInstance3D.new()
	mi.name = "Ridge"
	var q := QuadMesh.new()
	q.size = Vector2(r[&"w"], r[&"h"])
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = RIDGE_SHADER
	mat.set_shader_parameter(&"low_color", r[&"low"])
	mat.set_shader_parameter(&"top_color", r[&"top"])
	mat.set_shader_parameter(&"ridge", Vector2(r[&"base"], r[&"amp"]))
	mat.set_shader_parameter(&"seed", r[&"seed"])
	mi.material_override = mat
	mi.position = _at(u, float(r[&"y"]) + float(r[&"h"]) * 0.5, v)
	mi.rotation.y = yaw
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(mi)


func _gradient_mat(top: Color, bottom: Color, vertical: float, cloud: float) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = SKY_SHADER
	mat.set_shader_parameter(&"top_color", top)
	mat.set_shader_parameter(&"bottom_color", bottom)
	mat.set_shader_parameter(&"vertical", vertical)
	mat.set_shader_parameter(&"cloud", cloud)
	mat.set_shader_parameter(&"cloud_scale", SEA_CLOUD_SCALE)
	return mat
