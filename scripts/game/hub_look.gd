class_name HubLook
extends ArenaRoom
## The hub's look (HUB-01, HUB-B2; plan in HubPlan, space, pieces, light and palette in docs/design/hub_spec_art.md):
## an open courtyard at dusk over the mist. In the hub's own frame (u right on the screen, v up it; HubPlan) and so
## built under one node turned by the camera's yaw (`frame`): the portal high on the axis in a gothic facade (three
## orders of voussoirs, the seal's lion on the keystone, never a star) over a wide flight of stairs and a terrace
## where two seated lions guard it, an arcade of three arches each side open to the far ruins and a cascade; the side
## walls with the stations' niches; the low balustrade in front with the arrival stairs and two lamp posts. On the
## square the lion's medallion in old gold and the fountain of the lion (decoration: it neither heals nor is used).
## The five stations as pieces (their NPCs are HUB-D's: only their place): the Vendedor's awning with lanterns over
## his counter, the Forjador's furnace in the west wall with the anvil and a rack of blades, the Árvore de Dons (a bronze medallion
## with the lion, on a pedestal and its dais) before a blind arch, the Livro de Ahk open on a lectern before a shelf of
## scrolls in the east wall. Every blocking piece is drawn on its footprint in the layout (HubPlan.layout; the same
## data draws and collides); nothing else stands on the walkable floor. The stylized look is the one the hub was made
## for (STYLE: warm limestone, petrol shadow, a lighter and warmer air than any room); the classic one is the same
## build unpainted. No texture of its own (one shader: the book's page, hub_page.gdshader).
## The masonry and the slabs are mapped in the frame, not the world: dress() sets the global shader uniform frame_yaw
## (FRAME_YAW, frame_yaw.gdshaderinc) to the frame's yaw and leaving puts it back to 0 (HUB-D, technical-artist).
## Pending (environment): the floor's two rings of slabs round the medallion.

## The global shader uniform the stone and floor shaders lay their courses and slabs by (project.godot shader_globals).
const FRAME_YAW := &"frame_yaw"

# ---------- the frame and the walls ----------
## A band of the wall's arched holes is cut in steps this tall above the springing (hidden by the arch rings).
const BAND := 0.3

# ---------- the portal ----------
## The opening of the portal (its sheet): width, height over the landing, the springing of its pointed head; the sheet's
## plane (v) and the dark behind it.
const PORTAL_W := 3.6
const PORTAL_H := 5.0
const PORTAL_SPRING := 2.2
const ORDER_TINT := Color(1.12, 1.12, 1.12)
const INNER_TINT := Color(0.62, 0.62, 0.62)
## The keystone with the seal's lion in old gold (never a star; spec 3.1): its side and depth.
const KEYSTONE := Vector2(0.9, 0.35)

# ---------- the square ----------
const MEDALLION_GOLD := Color(0.36, 0.27, 0.13)
const DECAL_Y := 0.02
const FLOWER_OCHRE := Color(0.66, 0.58, 0.42)
const FLOWER_EARTH := Color(0.45, 0.32, 0.28)
const CYPRESS_WIDE := Vector2(1.25, 0.3)
const CYPRESS_CARD := Vector2(0.9, 1.4)
const CYPRESS_CARDS := 9.0
## Leaves on a crown's card (canopy.gdshader).
const CROWN_LEAVES := 7.0
const CYPRESS_A := Color(0.26, 0.34, 0.18)
const CYPRESS_B := Color(0.36, 0.44, 0.24)
## The raised beds' shrubs (HUB-D, H-P0-3: beds of pale flowers read as coffins): green leaves, a crown this
## tall and wide every SHRUB_EVERY metres along the bed.
const SHRUB_A := Color(0.26, 0.34, 0.16)
const SHRUB_B := Color(0.5, 0.6, 0.3)
## Art review 2026-11-21 item 5 (stylized look): the shrubs' leaves muted (the vivid orange is the hazard's colour,
## saturation under 0.45), bigger and less ragged so the cards stop reading as blocky noise.
const STY_CROWN_LEAVES := 5.0
const STY_CROWN_RAGGED := 0.05  # PM-2: a thinner edge (was 0.08)
const SHRUB_TALL := Vector2(1.0, 1.7)
const SHRUB_WIDE := 1.5
const SHRUB_EVERY := 1.4
const BED_FOOT := 0.25  # the planter's footing: how far it stands out, how high
const BED_FOOT_H := 0.14
const BED_COPING := 0.1
const BED_WALL := 0.35  # the wall's thickness (the earth is inside it)
const VINE_PLINTH := Vector2(0.9, 0.2)  # the vase's round plinth: radius, height

# ---------- the stations ----------
## Vendedor (spec 3.2; HUB-D): the awning's back and front heights, how far it reaches south and north of the
## counter's middle, its half width along u; the valance under its front edge (height, scallops a metre); its cloth;
## the lion on it (side); the posts at its corners; two lanterns hanging from its front (u off the middle) and their
## light (energy, reach); the racks' boards behind the counter (heights).
const AWNING_BACK := 4.0
const AWNING_FRONT := 3.5
## HV-C (6.2): the awning has two slopes, the back one the longer: its ridge at AWNING_RIDGE (share of the depth from the
## back, height), so from the square it reads as a gable over the counter, not a sign board.
const AWNING_RIDGE := Vector2(0.62, 5.0)
const AWNING_DEPTH := Vector2(1.5, 2.4)
const AWNING_HALF := 2.9
const VALANCE := Vector2(0.28, 1.6)
const AWNING_CLOTH := Color(0.44, 0.1, 0.15)
## Every other run of the cloth along v a muted wine (HV-C 6.2: hue 355, saturation 0.35, never the danger's red; an
## awning, not a sign); runs a metre.
const AWNING_STRIPE := Color(0.9, 0.82, 0.68)
const AWNING_RUNS := 2.0
const AWNING_LION := 1.5
const POST_R := 0.07
const VENDOR_LANTERNS: Array[float] = [-1.6, 1.6]
const LANTERN_LIGHT := Vector2(1.8, 4.5)
const LANTERN_SIZE := Vector3(0.28, 0.42, 0.28)
const VENDOR_SHELVES: Array[float] = [0.7, 1.4, 2.1]
const COUNTER_CLOTH := Color(0.06, 0.13, 0.14)
## The wares' glazes: amber, ivory, slate blue (never green, cyan nor violet).
const GLAZES: Array[Color] = [Color(0.62, 0.42, 0.2), Color(0.86, 0.82, 0.72), Color(0.42, 0.48, 0.56)]
## Forjador (spec 3.3; HUB-D): the forge stands on the floor north-west of the anvil (HubPlan.FORGE, its footprint),
## its mouth on its south face toward the camera (it was in the west wall facing east, edge-on to the camera, and hardly
## showed). Its top; the mouth (span, sill, springing); the hearth's back this deep in; the chimney (side, top) and its
## smoke (a card: size, colour, alpha); its fire, its light out at the mouth (energy, reach, fall-off; the only fire
## with a shadow), the glow at the hearth's back (its size, colour, alpha at rank 0 and a rank more). FORGE_RANKS ranks
## (set_forge_rank, the Forja's improvements, sistemas.md 3.4): each a twin light without a shadow
## (FORGE_RANK_LIGHT of the forge's energy a rank) and a lick more of fire in the hearth, from rank 2.
const FORGE_TOP := 3.4
const FORGE_MOUTH := Vector3(1.9, 0.8, 1.8)
const FORGE_HEARTH := 2.2
const CHIMNEY := Vector2(1.4, 5.8)
const SMOKE := Vector2(2.4, 4.0)
const SMOKE_COLOR := Color(0.32, 0.3, 0.29)
const SMOKE_ALPHA := 0.35
const FORGE_LIGHT := Vector3(3.0, 7.0, 1.0)
## How far east of the forge's mouth its light stands (art re-review E-4: the pool reaches the anvil and the Forjador).
const FORGE_LIGHT_EAST := 1.5
const FORGE_COLOR := Color(1.0, 0.55, 0.22)
const FORGE_GLOW := Vector2(1.7, 1.1)
const FORGE_GLOW_COLOR := Color(1.0, 0.42, 0.14)
const FORGE_GLOW_ALPHA := Vector2(0.45, 0.15)
const FORGE_RANKS := 3
const FORGE_RANK_LIGHT := 0.3
## The station in focus (Hub.focus_changed, HUB-D): its light FOCUS_GAIN brighter (a twin of it with no shadow, so the
## look's F7 values stay the light's own) and a faint thread of old gold round its use slab (the lozenge's outer
## half-diagonal, width, alpha), both eased in and out over FOCUS_EASE s; the gold under the screen's ceiling
## (ScreenTone.fit).
const FOCUS_GAIN := 0.25
const FOCUS_EASE := 0.3
const FOCUS_RIM := Vector3(1.85, 0.07, 0.5)
const FOCUS_GOLD := Color(0.9, 0.7, 0.38)
const ANVIL_STUMP := Vector2(0.45, 0.6)
## Árvore de Dons (spec 3.4; phase 3a: the station is the Dons' bronze medallion, as the screen): the dais's two steps
## (outer radius, top of each), the stone pedestal (foot, shaft and cap: width, height), the bronze disc on it (radius,
## thickness, height of its centre over the dais, tilt toward the camera in degrees), the rim ring (width), the lion in
## relief (side as a share of the radius), the warm glow behind it (size as a share of the disc, alpha), its light
## (energy, reach, height over the dais).
const DAIS: Array[Vector2] = [Vector2(3.2, 0.25), Vector2(2.6, 0.5)]
const PEDESTAL: Array[Vector2] = [Vector2(1.5, 0.35), Vector2(1.0, 1.0), Vector2(1.3, 0.22)]
const DISC_RADIUS := 1.25
const DISC_THICK := 0.16
const DISC_HEIGHT := 2.35
const DISC_TILT := 22.0
const DISC_RIM := 0.12
const DISC_LION := 1.5
const DISC_BRONZE := Color(0.46, 0.31, 0.15)
const DISC_FIELD := Color(0.3, 0.2, 0.1)
const DISC_RIM_BRONZE := Color(0.58, 0.4, 0.19)
const DISC_GLOW := Vector2(2.1, 0.5)
const DISC_GLOW_COLOR := Color(1.0, 0.72, 0.36)
const TREE_LIGHT := Vector3(1.0, 6.0, 3.2)
const TREE_COLOR := Color(1.0, 0.82, 0.5)
## Livro de Ahk (spec 3.5; HUB-D): the lectern's foot and its sloped top (tilt in degrees), the open book (a page's
## size), the ribbon; the candle stands' height; the case's boards (heights); the light (energy, height); the rug.
const LECTERN_FOOT := Vector2(0.6, 1.3)
const LECTERN_TILT := 22.0
const PAGE := Vector2(0.55, 0.75)
const RIBBON := Color(0.05, 0.16, 0.17)
const CANDLE_STAND := 1.25
const SHELF_BOARDS: Array[float] = [0.55, 1.35, 2.15, 2.95, 3.75]
const BOOK_LIGHT := Vector2(1.8, 2.6)
const RUG := Vector2(3.0, 3.6)
const BOOK_COVERS: Array[Color] = [Color(0.08, 0.17, 0.18), Color(0.3, 0.16, 0.1), Color(0.22, 0.15, 0.1), Color(0.36, 0.28, 0.14)]
const SCROLL := Color(0.64, 0.57, 0.44)

# ---------- the front ----------

# ---------- air and light ----------
## SV-R: the air under the far ridges (HubScenery draws them) and the cliffs of the drop: pale blue haze, warm grey stone
## (palette 04-paleta-e-iluminacao.md: water and distant mist #527F8C, shaded stone #8F8775), never a dark panel.
const MIST := Color(0.36, 0.31, 0.47)  # PM-2: lilac dusk void, not flat navy (was 0.07, 0.075, 0.14)
## Round 3: the void is night-blue indigo, nearly black right under the platform and going lighter and violet with the
## distance (the horizon's haze): the abyss planes' rim colour and the distances (m from the room's middle) it takes over.
## Round 4: night blue, little saturated (#141a33 to #2a2848), the haze toward the horizon a grey-blue and lighter.
const MIST_RIM := Color(0.38, 0.31, 0.48)  # PM-2: was 0.17, 0.17, 0.3
const MIST_RIM_RANGE := Vector2(24.0, 110.0)
const CLIFF := {&"stone_color": Color(0.3, 0.28, 0.25), &"edge_color": Color(0.5, 0.46, 0.4), &"mist_color": MIST,
	&"glow_color": Color(0.5, 0.6, 0.7)}
## Hub refine round 1: the platform is the top of a mountain at dusk. The cliffs are warm layered rock (hub_cliff.gdshader)
## going into the lilac mist of the abyss planes (their opaque floor is about this share of MIST).
const CLIFF_SHADER := preload("res://assets/shaders/hub_cliff.gdshader")
## Round 4: warm grey stone and moss, no pink, darker than the paving.
const CLIFF_ROCK_A := Color(0.46, 0.42, 0.45)
const CLIFF_ROCK_B := Color(0.3, 0.28, 0.34)
const CLIFF_MOSS := Color(0.17, 0.3, 0.12)
const CLIFF_MIST_SHARE := 0.4
const CLIFF_FADE := Vector2(8.0, 36.0)
## Round 2: the face's cool shadow (violet, the rock away from the light) and how much it darkens going down.
const CLIFF_SHADE := Color(0.17, 0.17, 0.3)
const CLIFF_DEEP_DARK := 0.65
## The hub's air (spec 4.1: lighter and warmer than any room, the cold in the sky and the vista) and its stylized look.
const DUSK_GOLD := Color(1.0, 0.7, 0.44)  # late-afternoon sun: warm and low (the shade stays cool: DUSK_AMBIENT)
## Round 2: the air is dusk, not noon: a cold violet ambient and a dark indigo fog; the warm lights are what shine.
## Round 4: the fog (the colour of everything below the floor) is night blue, not violet. The height fog under the floor
## (WorldAir FOG_HEIGHT_DENSITY 0.6: opaque a few metres down, so the void was this one flat colour and the planes' gradient
## and the crowns below never showed) is thinned here to HUB_FOG_HEIGHT.
const DUSK_FOG := Color(0.1, 0.105, 0.16)
const HUB_FOG_HEIGHT := 0.05
const DUSK_AMBIENT := Color(0.6, 0.58, 0.82)
const AIR := {
	&"sky": Color(0.3, 0.24, 0.42), &"fog": DUSK_FOG, &"fog_depth": Vector2(110.0, 240.0), &"fog_height_density": HUB_FOG_HEIGHT,
	&"ambient": DUSK_AMBIENT, &"ambient_gain": 1.0, &"moon": DUSK_GOLD, &"moon_energy": 1.1,
	&"moon_shadow": true,
}
## The classic look's floor (F7): the warm limestone of the stylized one, so the square is not the hall's rose slab.
## Round 3: small paving (HUB_SLAB, half the hall's slab) with finer joints (HUB_JOINT), in cream honey (STY_FLOOR_STONE).
const HUB_SLAB := 0.6
const HUB_JOINT := 0.03
const CLASSIC_FLOOR := {
	&"unit": HUB_SLAB, &"joint_width": HUB_JOINT, &"stone_a": Color(0.30, 0.29, 0.27), &"stone_b": Color(0.40, 0.38, 0.35),
	&"joint_color": Color(0.10, 0.09, 0.09), &"moss_color": Color(0.30, 0.29, 0.27), &"petal_color": Color(0.30, 0.29, 0.27),
	&"missing": 0.0, &"cracked": 0.2, &"split2": 0.45, &"tinted": 0.1,
}
## C1V N3 (docs/art/identidade_c1v.md 2.1, the hall's recipe, only in the stylized look): the shadow band's tint, the room's own hue
## (docs/art/plano_pintado_a_mao.md 5); the vignette is the hall's, the hub's softer.
const STY_SHADOW_GLOW := Color(0.2, 0.19, 0.4)
const STY_VIGNETTE := Vector3(0.5, 0.45, 1.3)
## Round 3: the paving is warm cream-rose (the art's), not grey-brown; the dark is kept for the rim and the void.
const STY_STONE := Color(0.66, 0.58, 0.5)
const STY_FLOOR_STONE := Color(0.86, 0.75, 0.58)
const STYLE := {
	&"stone": STY_STONE, &"floor_stone": STY_FLOOR_STONE, &"shadow": Color(0.7, 0.66, 0.88),
	&"joint_cold": Color(0.92, 0.89, 0.9), &"slab_paint": Vector2(0.82, 1.18), &"slab_hue": 3.0, &"olive_share": 0.03,
	&"edge_value": 1.0, &"pool_saturation": 0.8, &"metal": true,
	&"fire": {&"candle_range": 3.5, &"candle_gain": 1.2, &"bowl_range": 4.2, &"bowl_gain": 0.95},
	&"air": {&"sky": Color(0.3, 0.24, 0.42), &"fog": DUSK_FOG, &"fog_height_density": HUB_FOG_HEIGHT, &"ambient": DUSK_AMBIENT,
		&"ambient_gain": STY_AMBIENT_GAIN, &"moon": DUSK_GOLD, &"moon_energy": STY_MOON, &"moon_shadow": true},
	&"shadow_glow": STY_SHADOW_GLOW, &"vignette": STY_VIGNETTE,
}
## ENV-HB6 and BH-07 (docs/design/ciclo_visual_2026-11-20.md item 2; benchmark_hades2_style.md 4.1; rooms_progression.md
## BH-07), only in the stylized look: the square a step darker (the air's ambient and the moon, the soft fill over it at
## a share), and each station a clearing of its own light: a warm pool from high over its place (diffuse: no drawn
## circle, light_specular 0, paint.gdshaderinc), never on the crowd. The Forja reads by its fire, its anvil and the
## Forjador (the pool between the forge's mouth and the anvil, the fire stronger); the Livro by its lectern, the open
## book and a reading light over it (a narrow pool on the lectern, a wider one on the rug); the Vendedor and the Árvore
## the same, a little softer. The fountain, the gold threads and the ways stay readable between them; the portal's own
## glow reads the more for it on arriving, and a pale green pool at the foot of its flight (the top of the screen on
## arriving, where the camera holds the portal itself out of the frame) points the way. Each pool: station, aim (u, height, v), from (u, height, v), energy, cone
## (degrees), reach, colour.
const STY_AMBIENT_GAIN := 0.72
const STY_MOON := 0.95
const STY_KEY_SHARE := 0.8
const STY_FORGE_GAIN := 1.5
const STY_POOLS: Array[Array] = [
	# SV-R: each pool moved with its station's pieces (the anvil, the lectern, the counter, the dais, the arch, the stand)
	[HubPlan.SMITH, Vector3(-21.2, 0.6, 17.7), Vector3(-18.4, 7.5, 14.5), 9.0, 30.0, 12.0, Color(1.0, 0.7, 0.42)],
	[HubPlan.BOOK, Vector3(21.1, 1.2, 19.4), Vector3(20.1, 6.2, 17.4), 10.0, 18.0, 9.0, Color(1.0, 0.86, 0.62)],
	[HubPlan.BOOK, Vector3(20.5, 0.0, 20.0), Vector3(19.3, 8.0, 16.2), 11.0, 28.0, 12.0, Color(1.0, 0.82, 0.58)],
	[HubPlan.VENDOR, Vector3(11.5, 0.8, 7.8), Vector3(12.9, 8.0, 3.6), 9.0, 28.0, 12.0, Color(1.0, 0.8, 0.55)],
	[HubPlan.TREE, Vector3(14.6, 1.0, -4.2), Vector3(12.8, 9.0, -8.6), 5.0, 28.0, 13.0, Color(1.0, 0.84, 0.55)],
	# V2 and PT-9: the Videira's vase and the heroes' standards
	[HubPlan.VINE, Vector3(-2.5, 1.0, 4.8), Vector3(-4.3, 9.0, 0.3), 2.5, 28.0, 13.0, Color(1.0, 0.82, 0.5)],
	[HubPlan.PORTAL, Vector3(-1.0, 0.9, 21.4), Vector3(-1.0, 8.0, 14.6), 14.0, 38.0, 13.0, Color(1.0, 0.78, 0.4)],
]
## P1-A2 of the cycle's art review: the portal's pool (the last row) green and wide enough to read at the top of the
## screen on arriving with the near camera. P2-A7: the floor's outer ring (past the stations, from the fountain at the
## SV-R: the plan is 71 m wide, so the ring of darkening starts past the whole floor (calm_radius 60 of the world middle) until the environment-artist paints the rim.
## world's middle: edge_span times the floor's calm radius) a step darker, so the frame is no lighter than the square.
## The darkening starts past STY_RIM_FLOOR's calm radius times edge_span (from the fountain; the hub's floor box is
## turned, its own calm radius came out past the cliffs) and leaves each station's pool alone (STY_KEEP: full to, none
## from, m round each pool's aim).
## P2-B3 (ART_REVIEW.md 4.5): the rim between the stations to 0.70 of the square or under (it measured 0.75 to 0.82).
const STY_RIM_FLOOR := {&"calm_radius": 40.0, &"edge_value": 0.32, &"edge_span": Vector2(1.1, 1.9)}
const STY_KEEP := Vector2(2.5, 4.0)
const KEEP_MAX := 6
## The browser's renderer: the stylized air's share there (its painted stone lights lighter).
const STY_COMPAT_AMBIENT := 0.3
const STY_COMPAT_MOON := 0.3
const STY_COMPAT_KEY := 0.5
## A soft fill over the square (no shadow), so the floor reads as the lightest of the game (spec 4.2).
const KEY := Color(1.0, 0.84, 0.64)
const KEY_ENERGY := 0.7
## The key lamp hangs high so its hotspot on the middle of the square flattens into an even warm wash (no white pool).
const KEY_HIGH := 30.0
const LION_SHADER := preload("res://assets/shaders/altar_lion.gdshader")
const PAGE_SHADER := preload("res://assets/shaders/hub_page.gdshader")
const CANOPY_SHADER := preload("res://assets/shaders/canopy.gdshader")
## Round 2: the flower clumps and hanging wisteria are clean shapes on a few cards (hub_flower.gdshader), not the canopy's
## speckled leaf cut-outs. A clump: BLOOM_CARDS cards a spot, spread BLOOM_SPREAD of the width, each BLOOM_TALL over the
## spot's height and BLOOM_WIDE of the width; a tassel: one card (TASSEL_WIDE of the width given), top at the spot's top.
const FLOWER_SHADER := preload("res://assets/shaders/hub_flower.gdshader")
const BLOOM_CARDS := 3
const BLOOM_SPREAD := 0.34
## Round 3: small clumps (the tufts were the hero's size): half the height, more and smaller blossoms.
const BLOOM_TALL := 0.6
const BLOOM_WIDE := 0.62
const BLOOM_CLUMP := 1.0  # the width a flower bed's clump is given (HubScenery)
const BLOOM_LEAN := 0.22
const BLOOM_BLOSSOMS := 14.0
const TASSEL_WIDE := 1.25
const TASSEL_BLOSSOMS := 11.0
const BLOOM_LEAF_A := Color(0.13, 0.2, 0.1)
const BLOOM_LEAF_B := Color(0.28, 0.4, 0.19)
const DECAL_SHADER := preload("res://assets/shaders/floor_decal.gdshader")
## Facing directions in the frame (x, z): toward the camera (south), east, west.
const SOUTH := Vector2(0, 1)

## The node turned by the camera's yaw that holds the hub's own pieces (frame coordinates: x = u, z = -v), its kit and
## stone.
var frame: Node3D
var fk: ArenaKit
var fm: Masonry
## Each station's own light (HUB-B3 lifts the one in focus).
## V2 and PT-9: the Videira's planting and the heroes' standards (null before dress; Hub.evolve gives them the save).
var blockout: HubBlockout
var vine_station: VineStation
var station_lights := {}
var _lion_mats := {}
var _plain_mats := {}
var _cypress_spots: Array[Vector3] = []
var _cypress_tall: Array[float] = []
var _shrub_spots: Array[Vector3] = []
var _shrub_tall: Array[float] = []
## The station in focus and how far each one's focus has eased in (0 to 1), its twin light and its gold thread.
var focus_id: StringName = &""
var _focus_glow := {}
var _focus_twin := {}
var _focus_rim := {}
## The forge's rank (set_forge_rank), its twin light, the glow at its hearth's back and the fire a rank more lights.
var forge_rank := 0
var _forge_light: OmniLight3D
var _forge_twin: OmniLight3D
var _forge_glow: StandardMaterial3D
var _forge_fires: Array[Array] = []
## What goes out or away while a station is closed (set_closed): the forge's coals, flame and smoke, the Dons' glow, the
## book's open pages; and where the closed book lies.
var _closed_hides: Dictionary[StringName, Array] = {}
var _book_at := Transform3D.IDENTITY
var _book_shut: MeshInstance3D


## A point of the hub's frame (u, height, v) in the frame node's coordinates.
static func at(u: float, y: float, v: float) -> Vector3:
	return Vector3(u, y, -v)


## A point of the hub's frame (u, height, v) in the room's (the world's) coordinates.
func world(u: float, y: float, v: float) -> Vector3:
	return frame.transform * at(u, y, v)


func floor_look() -> Dictionary:
	return CLASSIC_FLOOR


func air() -> Dictionary:
	return AIR


func mist() -> Color:
	return MIST


func cliff_look() -> Dictionary:
	return CLIFF


## The buildings' wall: warm cream limestone ashlar that keeps its own colour in the stylized look (the art's calcário e
## marfim, 04-paleta-e-iluminacao.md): the room's grey-blue ashlar read as a brick box.
const WALL_A := Color(0.5, 0.42, 0.35)
const WALL_B := Color(0.68, 0.58, 0.47)
var _wall_mat: ShaderMaterial


func facade_stone() -> ShaderMaterial:
	if _wall_mat == null:
		_wall_mat = fm.ashlar(0.0, stone_tint()).duplicate() as ShaderMaterial
		_wall_mat.set_shader_parameter(&"stone_a", WALL_A)
		_wall_mat.set_shader_parameter(&"stone_b", WALL_B)
		_wall_mat.set_meta(ArenaKit.PAINT_OWN, ArenaKit.OWN_KEEP)
	return _wall_mat


## The mountain's rock under every edge (hub_cliff.gdshader), the same for all of them.
func cliff_material() -> Material:
	var mat := ShaderMaterial.new()
	mat.shader = CLIFF_SHADER
	mat.set_shader_parameter(&"rock_a", CLIFF_ROCK_A)
	mat.set_shader_parameter(&"rock_b", CLIFF_ROCK_B)
	mat.set_shader_parameter(&"moss_color", CLIFF_MOSS)
	mat.set_shader_parameter(&"mist_color", MIST * CLIFF_MIST_SHARE)
	mat.set_shader_parameter(&"fade", CLIFF_FADE)
	mat.set_shader_parameter(&"shade_color", CLIFF_SHADE)
	mat.set_shader_parameter(&"deep_dark", CLIFF_DEEP_DARK)
	return mat


## Every edge of the floor, the basins' too, a plain cliff under it (SV-R: the buildings and doors are dressed in the
## frame by HubBlockout, the water and the garden are the environment-artist's).
func edge(a: Vector2, b: Vector2, out: Vector2, _kind: Edge, faces: SurfaceTool) -> void:
	cliff(a, b, out, faces)


## The hub's pieces (hub_*) are drawn in dress() on their footprints, in the frame.
## Round 2: the levels (HubLevels) are the last of the build: the finished room lifted by the plan's height field, then the
## treads of its flights drawn on it.
func build_steps(a: Arena, l: RoomLayout, exit_count: int, seed_: int) -> Array[Callable]:
	var steps := super(a, l, exit_count, seed_)
	steps.append(_timed.bind(&"levels", func() -> Array[Callable]: return HubLevels.raise_steps(self)))
	steps.append(_timed.bind(&"treads", func() -> void: HubLevels.stairs(self)))
	return steps


func piece(o: ArenaObstacle) -> void:
	if String(o.piece).begins_with("hub_"):
		return
	super.piece(o)


## Round 3: the abyss planes (ArenaRoom._abyss) take the indigo-to-violet gradient with the distance (abyss_fog rim_*).
func _abyss() -> void:
	var from := get_child_count()
	super()
	for n in added_since(from):
		var sm: ShaderMaterial = null
		if n is GeometryInstance3D:
			sm = (n as GeometryInstance3D).material_override as ShaderMaterial
		if sm != null and sm.shader.resource_path.ends_with("abyss_fog.gdshader"):
			sm.set_shader_parameter(&"rim_color", MIST_RIM)
			sm.set_shader_parameter(&"rim_range", MIST_RIM_RANGE)


func _light() -> void:
	var key := key_light(KEY, KEY_ENERGY * (STY_COMPAT_KEY if compat() else 1.0), KEY_HIGH)
	VisualProfile.vary(key, {&"light_energy": key.light_energy * STY_KEY_SHARE})


func dress() -> void:
	frame = Node3D.new()
	frame.name = "HubFrame"
	frame.transform = Transform3D(Basis(Vector3.UP, deg_to_rad(Feel.live().cam_yaw)), Vector3.ZERO)
	add_child(frame)
	# the masonry's courses and the floor's slabs laid along the frame (frame_yaw.gdshaderinc; back to 0 on leaving)
	RenderingServer.global_shader_parameter_set(FRAME_YAW, Feel.live().cam_yaw)
	fk = ArenaKit.new(frame, 2207)
	fm = fk.masonry
	blockout = HubBlockout.new(self)
	blockout.build(layout)
	for o in layout.obstacles:
		var c := HubPlan.to_local(o.center)
		match o.piece:
			&"hub_counter":
				_vendor(c, o)
			&"hub_anvil":
				_anvil(c, o)
			&"hub_dais":
				_tree(c, o)
			&"hub_lectern":
				_book(c, o)
			&"hub_bed":
				_bed(c, o)
			&"hub_shelf":
				_shelf(c, o)
			&"hub_alchemist":
				_alchemist(c, o)
			&"hub_vine":
				_vine_arch(c, o)
			&"hub_gate_steps":
				_gate_steps(c, o)
	add_crowns(_cypress_spots, _cypress_tall, CYPRESS_A, CYPRESS_B, CYPRESS_WIDE.x, "Cypresses")
	add_crowns(_shrub_spots, _shrub_tall, SHRUB_A, SHRUB_B, SHRUB_WIDE, "Shrubs")
	_forge()
	_people()
	_focus_rims()
	HubScenery.new(self).build(layout)
	# the frame's wood keeps its own colour in the stylized look (paint_look knows only the room's)
	for w: Material in fm._wood.values():
		w.set_meta(ArenaKit.PAINT_OWN, {&"paint_keep": 1.0})
	fm.merge()


func _exit_tree() -> void:
	super()
	RenderingServer.global_shader_parameter_set(FRAME_YAW, 0.0)


func style() -> Dictionary:
	_station_pools()
	var st := STYLE.duplicate(true)
	var ground := STY_RIM_FLOOR.duplicate()
	var keep := PackedVector4Array()
	for p: Array in STY_POOLS:
		var aim: Vector3 = world(p[1].x, 0.0, p[1].z)
		if keep.size() < KEEP_MAX:
			keep.append(Vector4(aim.x, aim.z, STY_KEEP.x, STY_KEEP.y))
	ground[&"keep_spots"] = keep
	ground[&"keep_spot_count"] = keep.size()
	st[&"floor"] = ground
	if compat():
		st[&"air"][&"ambient_gain"] = float(st[&"air"][&"ambient_gain"]) * STY_COMPAT_AMBIENT
		st[&"air"][&"moon_energy"] = float(st[&"air"][&"moon_energy"]) * STY_COMPAT_MOON
	fk.stylize_metal()
	return st


## The stations' pools of the stylized look (STY_POOLS), under a node shown only in it; the forge's fire stronger.
func _station_pools() -> void:
	var node := Node3D.new()
	node.name = "StationPools"
	frame.add_child(node)
	ArenaKit.style_only(node)
	for p: Array in STY_POOLS:
		var l := SpotLight3D.new()
		l.name = "Pool_%s" % p[0]
		node.add_child(l)
		var aim: Vector3 = world(p[1].x, p[1].y, p[1].z)
		var from: Vector3 = world(p[2].x, p[2].y, p[2].z)
		l.look_at_from_position(from, aim, Vector3.UP)
		l.light_energy = float(p[3]) * (STY_COMPAT_KEY if compat() else 1.0)
		l.spot_angle = p[4]
		l.spot_range = p[5]
		l.spot_attenuation = 0.6
		l.spot_angle_attenuation = 1.6
		l.light_color = p[6]
		l.light_specular = 0.0
		l.shadow_enabled = false
		l.light_cull_mask = ~Arena.CROWD_LAYER
		l.set_meta(ArenaKit.NOT_FIRE, true)
	if _forge_light != null:
		_forge_light.set_meta(ArenaKit.FIRE_SHARE, STY_FORGE_GAIN)


## The light of a station (HubPlan.STATIONS id; null if it has none).
func station_light(id: StringName) -> Light3D:
	return station_lights.get(id)


## A station not open yet (HubGate; Hub calls it with the save): its light and fire are out (the Vendedor keeps his cloth,
## HubEvolution). Closed, the forge is cold (no coals, flame nor smoke), the Dons' glow out and the book shut (2026-11-21).
func set_closed(id: StringName, closed: bool) -> void:
	if closed:
		# (opened, they are as built: some only show in one look, F7, so nothing is ever shown by hand here)
		for nd: Node3D in _closed_hides.get(id, []):
			nd.visible = false
	if id == HubPlan.BOOK and closed and _book_shut == null:
		_book_shut = _bar(_book_at.origin, Vector3(PAGE.y, 0.09, PAGE.x), _plain(RIBBON * 0.55, 0.85), _book_at.basis)
	if _book_shut != null and id == HubPlan.BOOK:
		_book_shut.visible = closed
	var l: Light3D = station_lights.get(id)
	if l != null:
		l.visible = not closed
	if id == HubPlan.SMITH:
		set_forge_rank(forge_rank)
		if _forge_glow != null and closed:
			_forge_glow.albedo_color.a = 0.0
		if _forge_twin != null:
			_forge_twin.visible = not closed and forge_rank > 0

## The station in focus (&"": none; Hub calls it on focus_changed): its light eases FOCUS_GAIN brighter and the thread
## of gold round its use slab fades in, the one before eases out.
func focus(id: StringName) -> void:
	focus_id = id


## The forge's rank (0 to FORGE_RANKS: the Forja's improvements, sistemas.md 3.4; the gameplay calls it when the hub is
## built and after an improvement): its glow brighter, a twin light FORGE_RANK_LIGHT of its own a rank, from rank 2 a
## lick of fire more each side.
func set_forge_rank(n: int) -> void:
	forge_rank = clampi(n, 0, FORGE_RANKS)
	if _forge_glow != null:
		var c := _forge_glow.albedo_color
		c.a = FORGE_GLOW_ALPHA.x + FORGE_GLOW_ALPHA.y * forge_rank
		_forge_glow.albedo_color = c
	for k in _forge_fires.size():
		for nd: Node3D in _forge_fires[k]:
			nd.visible = forge_rank >= 2 + k * (FORGE_RANKS - 2)
	if _forge_light != null and forge_rank > 0 and _forge_twin == null:
		_forge_twin = _twin_of(_forge_light)
	if _forge_twin != null:
		_forge_twin.visible = forge_rank > 0


func _process(delta: float) -> void:
	for id: StringName in station_lights:
		var was: float = _focus_glow.get(id, 0.0)
		var g := move_toward(was, 1.0 if id == focus_id else 0.0, delta / FOCUS_EASE)
		if g == was and g == 0.0:
			continue
		_focus_glow[id] = g
		var base: Light3D = station_lights[id]
		if not _focus_twin.has(id):
			_focus_twin[id] = _twin_of(base)
		var twin: Light3D = _focus_twin[id]
		twin.visible = g > 0.0 and base.visible
		twin.light_energy = base.light_energy * FOCUS_GAIN * g
		_match(twin, base)
		var rim: MeshInstance3D = _focus_rim.get(id)
		if rim != null:
			rim.visible = g > 0.0
			var mat := rim.material_override as StandardMaterial3D
			var c := mat.albedo_color
			c.a = FOCUS_RIM.z * g
			mat.albedo_color = c
	if _forge_twin != null and forge_rank > 0:
		_forge_twin.light_energy = _forge_light.light_energy * FORGE_RANK_LIGHT * forge_rank
		_match(_forge_twin, _forge_light)


## A light with no shadow standing where `base` stands, nothing on (made when first needed, after the look was styled,
## so F7 never sees it: its energy follows the base's every frame).
func _twin_of(base: Light3D) -> Light3D:
	var twin: Light3D = OmniLight3D.new() if base is OmniLight3D else SpotLight3D.new()
	twin.name = String(base.name) + "Twin"
	twin.shadow_enabled = false
	twin.light_energy = 0.0
	twin.visible = false
	base.get_parent().add_child(twin)
	twin.transform = base.transform
	_match(twin, base)
	return twin


static func _match(twin: Light3D, base: Light3D) -> void:
	twin.light_color = base.light_color
	twin.light_cull_mask = base.light_cull_mask
	twin.light_specular = base.light_specular
	if twin is OmniLight3D:
		(twin as OmniLight3D).omni_range = (base as OmniLight3D).omni_range
		(twin as OmniLight3D).omni_attenuation = (base as OmniLight3D).omni_attenuation
	elif twin is SpotLight3D:
		(twin as SpotLight3D).spot_range = (base as SpotLight3D).spot_range
		(twin as SpotLight3D).spot_angle = (base as SpotLight3D).spot_angle
		(twin as SpotLight3D).spot_attenuation = (base as SpotLight3D).spot_attenuation


## The thread of old gold round each station's use slab (hidden until it comes into focus): a lozenge just outside the
## slab's outer groove, unshaded, under the screen's ceiling, one material a station (its alpha eases with the focus).
func _focus_rims() -> void:
	var gold := ScreenTone.fit(FOCUS_GOLD)
	var r := FOCUS_RIM.x
	var w := FOCUS_RIM.y * 0.5
	for id in HubPlan.STATIONS:
		var p: Vector2 = HubPlan.USE[id]
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_normal(Vector3.UP)
		var corners: Array[Vector2] = [Vector2(r, 0), Vector2(0, r), Vector2(-r, 0), Vector2(0, -r)]
		for k in 4:
			var a := corners[k]
			var b := corners[(k + 1) % 4]
			var quad := [a * (1.0 + w / r), b * (1.0 + w / r), b * (1.0 - w / r), a * (1.0 - w / r)]
			for i: int in [0, 1, 2, 0, 2, 3]:
				var q: Vector2 = quad[i]
				st.add_vertex(at(q.x, 0.0, q.y))
		var mi := MeshInstance3D.new()
		mi.name = "FocusRim_" + String(id)
		mi.mesh = st.commit()
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.albedo_color = Color(gold.r, gold.g, gold.b, 0.0)
		mi.material_override = mat
		mi.position = at(p.x, DECAL_Y + 0.012, p.y)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.visible = false
		frame.add_child(mi)
		_focus_rim[id] = mi


# ---------- walls ----------

## A wall in the frame: along u (facing v: its face at `face`, its back at `back`) or along v (facing u), from s0 to s1,
## `top` tall from under the floor, with openings cut in it: each Vector4(middle, span, sill, springing) with its arc
## (a share of the span: 0.5 round, more pointed; 0 square, its top at the springing). Above the springing it is cut
## in bands of BAND, each as wide as the arch is at its foot (the arch's ring in front covers the steps).
func _wall(along_u: bool, face: float, back: float, s0: float, s1: float, top: float, holes: Array[Vector4],
		arcs: Array[float], mat: Material) -> void:
	# whole-height blocks between the openings; over each opening's width, its jambs' blocks band by band
	var spans: Array[Vector2] = []
	for h in holes:
		spans.append(Vector2(h.x - h.y * 0.5, h.x + h.y * 0.5))
	spans.sort_custom(func(p: Vector2, q: Vector2) -> bool: return p.x < q.x)
	var s := s0
	for sp in spans:
		if sp.x > s:
			_slab(along_u, face, back, s, sp.x, -0.6, top, mat)
		s = maxf(s, sp.y)
	if s < s1:
		_slab(along_u, face, back, s, s1, -0.6, top, mat)
	for i in holes.size():
		var h := holes[i]
		var x0 := h.x - h.y * 0.5
		var x1 := h.x + h.y * 0.5
		_slab(along_u, face, back, x0, x1, -0.6, h.z, mat)
		var y := h.w
		if arcs[i] <= 0.0:
			_slab(along_u, face, back, x0, x1, h.w, top, mat)
			continue
		var r := arcs[i] * h.y
		var cx := r - h.y * 0.5
		var high := minf(top, h.w + sqrt(maxf(0.0, r * r - cx * cx)))
		while y < high - 0.001:
			var y1 := minf(y + BAND, high)
			var hw := _half_open(h, arcs[i], y)
			_slab(along_u, face, back, x0, h.x - hw, y, y1, mat)
			_slab(along_u, face, back, h.x + hw, x1, y, y1, mat)
			y = y1
		_slab(along_u, face, back, x0, x1, high, top, mat)


## How far an opening is open each side of its middle at height y (0: closed there).
static func _half_open(h: Vector4, arc: float, y: float) -> float:
	if y < h.z - 0.001:
		return 0.0
	if y < h.w - 0.001:
		return h.y * 0.5
	if arc <= 0.0:
		return 0.0
	var r := arc * h.y
	var cx := r - h.y * 0.5
	var t := y - h.w
	if t >= r:
		return 0.0
	return maxf(0.0, sqrt(r * r - t * t) - cx)


## One block of a wall from s0 to s1 along it, face to back across it, y0 to y1.
func _slab(along_u: bool, face: float, back: float, s0: float, s1: float, y0: float, y1: float, mat: Material) -> void:
	if s1 - s0 < 0.02:
		return
	var d := absf(back - face)
	if along_u:
		fm.block(at((s0 + s1) * 0.5, y0, (face + back) * 0.5), Vector3(s1 - s0, y1 - y0, d), 0.0, mat, false)
	else:
		fm.block(at((face + back) * 0.5, y0, (s0 + s1) * 0.5), Vector3(d, y1 - y0, s1 - s0), 0.0, mat, false)


## Every crown of one kind in one MultiMesh (the canopy's cards, canopy.gdshader; they open round the hero): the
## cypresses in dark olive, the beds' shrubs in copper (wide: the crown's width at its widest).
## Round 3: `hanging` turns the crown over (widest at the top, a tassel to a point at the foot: the foot is the lowest point,
## wisteria and grapes), `card_scale` shrinks the cards (a grape cluster is made of small ones).
func add_crowns(spots: Array[Vector3], talls: Array[float], leaf_a: Color, leaf_b: Color, width: float, label: String, round_crown := false,
		hanging := false, card_scale := 1.0) -> void:
	if spots.is_empty():
		return
	var r := RandomNumberGenerator.new()
	r.seed = 6151 + label.length()
	var xf: Array[Transform3D] = []
	for i in spots.size():
		var foot := spots[i]
		var tall := talls[i]
		var n := maxi(3, roundi(tall * CYPRESS_CARDS * maxf(1.0, width / CYPRESS_WIDE.x)))
		for k in n:
			var t := (k + r.randf()) / n
			if hanging:
				t = 1.0 - t  # t runs from the tip: the same shape upside down
			# widest a share of the way up, to a point at the top
			var wide := width * 0.5 * (sqrt(t / CYPRESS_WIDE.y) if t < CYPRESS_WIDE.y else (1.0 - t) / (1.0 - CYPRESS_WIDE.y) * 0.9 + 0.1)
			if round_crown:
				wide = width * 0.5 * pow(sin(PI * clampf(t, 0.04, 0.96)), 0.7)
			var a := r.randf() * TAU
			var p := at(foot.x, foot.y + (1.0 - t if hanging else t) * tall, foot.z) + Vector3(cos(a), 0.0, sin(a)) * wide * r.randf_range(0.3, 0.8)
			var size := lerpf(CYPRESS_CARD.y, CYPRESS_CARD.x, t) * r.randf_range(0.8, 1.1) * card_scale
			# the frame is already turned by the camera's yaw: face its south
			var basis := Basis(Vector3.BACK, r.randf_range(-0.3, 0.3)) * Basis.from_scale(Vector3(size * 0.75, size, 1.0))
			xf.append(Transform3D(basis, p))
	var q := QuadMesh.new()
	q.size = Vector2.ONE
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = q
	mm.instance_count = xf.size()
	for i in xf.size():
		mm.set_instance_transform(i, xf[i])
		mm.set_instance_custom_data(i, Color(r.randf(), 0, 0, 0))
	var mat := ShaderMaterial.new()
	mat.shader = CANOPY_SHADER
	mat.set_shader_parameter(&"leaf_a", leaf_a)
	mat.set_shader_parameter(&"leaf_b", leaf_b)
	mat.set_shader_parameter(&"leaves", CROWN_LEAVES)
	mat.set_shader_parameter(&"fill", 0.8)
	var sty := {&"shader_parameter/leaves": STY_CROWN_LEAVES, &"shader_parameter/ragged": STY_CROWN_RAGGED}
	VisualProfile.vary(mat, sty)
	var mi := MultiMeshInstance3D.new()
	mi.name = label
	mi.multimesh = mm
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	frame.add_child(mi)


## Round 2: flowers and wisteria as whole clumps (or tassels, `hanging`) on single cards drawn by hub_flower.gdshader: the
## spots as add_crowns has them (foot = the lowest point), one MultiMesh and one material a layer.
func add_blooms(spots: Array[Vector3], talls: Array[float], petal_a: Color, petal_b: Color, width: float, label: String,
		hanging := false) -> void:
	if spots.is_empty():
		return
	var r := RandomNumberGenerator.new()
	r.seed = 7331 + label.length()
	var xf: Array[Transform3D] = []
	var seeds: Array[float] = []
	for i in spots.size():
		var foot := spots[i]
		var tall := talls[i]
		if hanging:
			var basis := Basis(Vector3.UP, r.randf_range(-0.2, 0.2)) * Basis.from_scale(Vector3(width * TASSEL_WIDE, tall, 1.0))
			xf.append(Transform3D(basis, at(foot.x, foot.y + tall * 0.5, foot.z)))
			seeds.append(r.randf())
			continue
		for k in BLOOM_CARDS:
			var side := float(k) - (BLOOM_CARDS - 1) * 0.5
			var off := Vector3(side * width * BLOOM_SPREAD + r.randf_range(-0.06, 0.06), 0.0, r.randf_range(-0.08, 0.08) + 0.04 * k)
			var h := tall * BLOOM_TALL * r.randf_range(0.85, 1.1)
			var basis := Basis(Vector3.UP, r.randf_range(-BLOOM_LEAN, BLOOM_LEAN)) * Basis.from_scale(Vector3(width * BLOOM_WIDE * r.randf_range(0.9, 1.1), h, 1.0))
			xf.append(Transform3D(basis, at(foot.x, foot.y + h * 0.5, foot.z) + off))
			seeds.append(r.randf())
	var q := QuadMesh.new()
	q.size = Vector2.ONE
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = q
	mm.instance_count = xf.size()
	for i in xf.size():
		mm.set_instance_transform(i, xf[i])
		mm.set_instance_custom_data(i, Color(seeds[i], 0, 0, 0))
	var mat := ShaderMaterial.new()
	mat.shader = FLOWER_SHADER
	mat.set_shader_parameter(&"petal_a", petal_a)
	mat.set_shader_parameter(&"petal_b", petal_b)
	mat.set_shader_parameter(&"leaf_a", BLOOM_LEAF_A)
	mat.set_shader_parameter(&"leaf_b", BLOOM_LEAF_B)
	mat.set_shader_parameter(&"hang", 1.0 if hanging else 0.0)
	mat.set_shader_parameter(&"blossoms", TASSEL_BLOSSOMS if hanging else BLOOM_BLOSSOMS)
	var mi := MultiMeshInstance3D.new()
	mi.name = label
	mi.multimesh = mm
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(mi)


## V2: the Videira's vase with its young vine (VineStation; `grow_vine` shows what the save has bought) on a low round plinth
## before the gazebo. Round 3: no stone portico over it (it hid the fountain): the footprint is still its collider.
func _vine_arch(c: Vector2, _o: ArenaObstacle) -> void:
	var mat := stone()
	fm.shaft(at(c.x, 0.0, c.y), VINE_PLINTH.x, VINE_PLINTH.y, mat)
	fm.shaft(at(c.x, VINE_PLINTH.y, c.y), VINE_PLINTH.x - 0.15, 0.06, mat)
	vine_station = VineStation.make(frame, at(c.x, VINE_PLINTH.y + 0.06, c.y))


## The planting as the save has grown it (Vine.growth: nodes bought by branch; VineStation.grown).
func grow_vine(growth: Dictionary) -> void:
	if vine_station != null:
		vine_station.grown(growth)


## The Portão's stair (the art's: a flight with a red carpet up from the gallery): GATE_STEP_COUNT cream treads rising
## north to the terrace's height, the carpet over them with gold edges, a stone cheek on each side. Solid on its footprint.
func _gate_steps(c: Vector2, o: ArenaObstacle) -> void:
	var n := HubPlan.GATE_STEP_COUNT
	var rise := HubPlan.GATE_TERRACE / n
	var run := o.half.y * 2.0 / n
	var v0 := c.y - o.half.y
	var wide := o.half.x * 2.0
	var cloth := _plain(HubFacades.CARPET, 1.0)
	var gold := _plain(HubFacades.BANNER_GOLD, 0.6)
	var carpet := HubFacades.CARPET_WIDTH
	for k in n:
		var top := rise * (k + 1)
		var vc := v0 + run * (k + 0.5)
		fm.block(at(c.x, 0.0, vc), Vector3(wide, top, run), 0.0, facade_stone(), false)
		_bar(at(c.x, top + 0.012, vc), Vector3(carpet, 0.024, run), cloth)
		_bar(at(c.x, top - rise * 0.5, v0 + run * k - 0.012), Vector3(carpet, rise, 0.024), cloth)
		for s: float in [-1.0, 1.0]:
			_bar(at(c.x + s * (carpet * 0.5 - 0.05), top + 0.02, vc), Vector3(0.07, 0.018, run), gold)
	# the cheeks: a low wall each side, coped, rising with the flight
	for s: float in [-1.0, 1.0]:
		var x := c.x + s * (o.half.x - 0.14)
		for k in n:
			var top := rise * (k + 1) + 0.3
			fm.block(at(x, 0.0, v0 + run * (k + 0.5)), Vector3(0.28, top, run), 0.0, facade_stone(), false)


## The Videira's planter (hub art 2026-11-27): a low round wall of stone (HubPlan.VINE_BED radius) with its coping, dark earth
## inside; HubScenery plants the tree, the little fountain and the flowers on it.
func _bed(c: Vector2, _o: ArenaObstacle) -> void:
	var h := HubPlan.BED_HEIGHT
	var r := HubPlan.VINE_BED.z
	fm.shaft(at(c.x, 0.0, c.y), r + BED_FOOT, BED_FOOT_H, stone())
	fm.shaft(at(c.x, 0.0, c.y), r, h - BED_COPING, stone())
	fm.shaft(at(c.x, h - BED_COPING, c.y), r + BED_COPING, BED_COPING, stone())
	fm.shaft(at(c.x, h - BED_COPING - 0.02, c.y), r - BED_WALL, BED_COPING * 0.5, _plain(HubScenery.GARDEN_SOIL, 1.0))


## HV-C, the Alquimista's space (hv_santuario_vigilia_art.md 4; reserved, Q-OF7, no figure, no use): on the footprint
## against the west wall (HubPlan.ALCHEMIST_BENCH) a shelf of dark wood with tall empty jars, the bench before it with a
## cloth over half of it, a mortar and a pair of scales (dark iron, no bright gold), and over all a lean-to roof of dark
## boards on two posts (ALCH_ROOF: its back and front heights; it reaches ALCH_ROOF_OUT m east of the footprint, always
## above 2.6 m over the floor) with dry herbs hanging under it; a low amber lamp on the bench (ALCH_LAMP: energy, reach,
## no shadow): a place waiting, not a shop closed. The glass muted green only in its colour, never lit.
const ALCH_WOOD := 0.55
const ALCH_GLASS := Color(0.36, 0.4, 0.31)
const ALCH_GLASS_DARK := Color(0.2, 0.22, 0.17)
const ALCH_CLOTH := Color(0.3, 0.22, 0.16)
const ALCH_HERBS: Array[Color] = [Color(0.4, 0.33, 0.18), Color(0.3, 0.31, 0.2)]
const ALCH_ROOF := Vector2(2.2, 2.85)
const ALCH_ROOF_OUT := 1.25
const ALCH_JARS := 8
const ALCH_LAMP := Vector2(0.9, 2.5)
const ALCH_LAMP_COLOR := Color(0.74, 0.63, 0.48)
func _alchemist(c: Vector2, o: ArenaObstacle) -> void:
	var wood := m._wood_mat(0.0, ALCH_WOOD)
	var u0 := c.x - o.half.x
	var u1 := c.x + o.half.x
	var v0 := c.y - o.half.y
	var v1 := c.y + o.half.y
	var r := RandomNumberGenerator.new()
	r.seed = 6091
	# the shelf against the wall: sides, back, three boards
	var back := u0 + 0.14
	fm.block(at(back, 0.0, c.y), Vector3(0.08, ALCH_ROOF.x - 0.1, o.half.y * 2.0), 0.0, wood, false)
	for sd: float in [-1.0, 1.0]:
		fm.block(at(back + 0.12, 0.0, c.y + sd * (o.half.y - 0.04)), Vector3(0.3, 1.9, 0.06), 0.0, wood, false)
	for h: float in [0.55, 1.15, 1.7]:
		fm.block(at(back + 0.14, h, c.y), Vector3(0.3, 0.04, o.half.y * 2.0 - 0.1), 0.0, wood, false)
	# the bench: top, legs, a cloth over its south half
	var bu := u1 - 0.36
	fm.block(at(bu, 0.84, c.y), Vector3(0.7, 0.06, o.half.y * 2.0 - 0.05), 0.0, wood)
	for su: float in [-0.28, 0.28]:
		for sv: float in [-1.0, 1.0]:
			fm.block(at(bu + su, 0.0, c.y + sv * (o.half.y - 0.1)), Vector3(0.07, 0.84, 0.07), 0.0, wood, false)
	_bar(at(bu + 0.02, 0.9, c.y - o.half.y * 0.5), Vector3(0.76, 0.03, o.half.y * 0.95), _plain(ALCH_CLOTH, 1.0))
	_bar(at(bu + 0.38, 0.62, c.y - o.half.y * 0.5), Vector3(0.02, 0.54, o.half.y * 0.95), _plain(ALCH_CLOTH, 1.0))
	# jars: tall and narrow on the shelves, empty or with a dark sediment
	var glass := _plain(ALCH_GLASS, 0.25)
	var dark := _plain(ALCH_GLASS_DARK, 0.3)
	for k in ALCH_JARS:
		var board: float = [0.59, 1.19, 1.74][k % 3]
		var h := r.randf_range(0.25, 0.48) if board < 1.5 else r.randf_range(0.2, 0.3)
		var v := lerpf(v0 + 0.2, v1 - 0.2, (float(k) + r.randf_range(0.1, 0.9)) / ALCH_JARS)
		var rad := r.randf_range(0.05, 0.08)
		fm.shaft(at(back + 0.16, board, v), rad, h * 0.75, glass)
		fm.shaft(at(back + 0.16, board + h * 0.75, v), rad * 0.45, h * 0.25, glass)
		if k % 3 == 1:
			fm.shaft(at(back + 0.16, board, v), rad * 0.95, h * 0.18, dark)
	# the mortar and the scales on the bench's north half
	var iron := tomb.iron()
	fm.shaft(at(bu, 0.87, c.y + 0.55), 0.11, 0.12, stone())
	_bar(at(bu + 0.05, 1.0, c.y + 0.55), Vector3(0.025, 0.2, 0.025), wood, Basis(Vector3.FORWARD, 0.6))
	fm.shaft(at(bu, 0.87, c.y + 0.15), 0.02, 0.42, iron)
	_bar(at(bu, 1.28, c.y + 0.15), Vector3(0.02, 0.02, 0.5), iron)
	for sv: float in [-0.23, 0.23]:
		fm.shaft(at(bu, 1.02, c.y + 0.15 + sv), 0.08, 0.02, iron)
	# the lean-to roof (back low, front high, over the floor only above 2.6 m) and its two posts in the footprint
	var front := u1 + ALCH_ROOF_OUT
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var q: Array[Vector3] = [at(u0 - 0.1, ALCH_ROOF.x, v0 - 0.3), at(front, ALCH_ROOF.y, v0 - 0.3), at(front, ALCH_ROOF.y, v1 + 0.3),
		at(u0 - 0.1, ALCH_ROOF.x, v1 + 0.3)]
	for idx: int in [0, 2, 1, 0, 3, 2]:
		st.add_vertex(q[idx])
	st.generate_normals()
	var roof := MeshInstance3D.new()
	roof.name = "AlchemistRoof"
	roof.mesh = st.commit()
	var rm := wood.duplicate() as ShaderMaterial
	roof.material_override = rm
	roof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	frame.add_child(roof)
	for sv: float in [-1.0, 1.0]:
		var pv := c.y + sv * (o.half.y - 0.06)
		var top := lerpf(ALCH_ROOF.x, ALCH_ROOF.y, (u1 - 0.06 - u0 + 0.1) / (front - u0 + 0.1))
		fm.shaft(at(u1 - 0.06, 0.0, pv), 0.06, top, wood)
	# herbs hanging in bunches over the bench, inside the footprint
	for k in 5:
		var v := lerpf(v0 + 0.25, v1 - 0.25, float(k) / 4.0)
		var hu := lerpf(u0 + 0.5, u1 - 0.1, 0.5 + 0.3 * sin(k * 1.7))
		var top := lerpf(ALCH_ROOF.x, ALCH_ROOF.y, (hu - u0 + 0.1) / (front - u0 + 0.1)) - 0.02
		var hang := r.randf_range(0.35, 0.55)
		_bar(at(hu, top - hang * 0.5, v), Vector3(0.12, hang, 0.1), _plain(ALCH_HERBS[k % 2], 1.0),
			Basis(Vector3.UP, r.randf() * PI))
	# the low lamp on the bench: a small amber flame in a dark iron cage, its own light, no shadow
	var lamp := at(bu - 0.1, 0.87, c.y - 0.05)
	_bar(lamp + Vector3(0, 0.1, 0), Vector3(0.12, 0.2, 0.12), iron)
	var flame := _bar(lamp + Vector3(0, 0.12, 0), Vector3(0.05, 0.09, 0.05), _glow_mat(ALCH_LAMP_COLOR))
	flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var l := OmniLight3D.new()
	l.position = world(bu + 0.4, 1.4, c.y - 0.05)
	l.light_color = ALCH_LAMP_COLOR
	l.light_energy = ALCH_LAMP.x
	l.omni_range = ALCH_LAMP.y
	l.shadow_enabled = false
	l.light_cull_mask = ~Arena.CROWD_LAYER
	l.set_meta(ArenaKit.NOT_FIRE, true)
	add_child(l)


## An unshaded flame-like material of colour c (a lamp's small flame; under the glow).
## Round 2: warm light from below, not a flat yellow pane: the emission runs from `top` (a dim ember at the head of the
## opening) to the full colour at the foot (a vertical gradient on a box's side faces, UV y 0 at the top).
static func lit_opening(color: Color, energy: float, top := 0.12, mid := 0.0) -> StandardMaterial3D:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(top, top * 0.6, top * 0.4), Color(1, 1, 1)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	if mid > 0.0:
		# round 5: a dark interior over the upper half, the light pooling toward the foot (the door is not a flat plate)
		grad.add_point(0.5, Color(mid, mid * 0.7, mid * 0.5))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)
	tex.width = 4
	tex.height = 64
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color * 0.15
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_texture = tex
	mat.emission_energy_multiplier = energy
	mat.roughness = 0.5
	return mat


func _glow_mat(c: Color) -> StandardMaterial3D:
	var key := [c, -1.0]
	if not _plain_mats.has(key):
		var s := StandardMaterial3D.new()
		s.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		s.albedo_color = c.lightened(0.25)
		_plain_mats[key] = s
	return _plain_mats[key]


## The radius of the sheet's pointed head as a share of its width (its apex at PORTAL_H, springing at PORTAL_SPRING).
static func _portal_arc() -> float:
	var rise := PORTAL_H - PORTAL_SPRING
	return (rise * rise + PORTAL_W * PORTAL_W * 0.25) / PORTAL_W / PORTAL_W


## A keystone with the seal's lion in old gold on its face (its middle at p, facing south, side `side`).
func _keystone(p: Vector3, side: float) -> void:
	fm.box(p, Vector3(side, side, KEYSTONE.y), 0.0, m.ashlar(p.y, stone_tint() * ORDER_TINT), false)
	_lion(p + Vector3(0, 0, KEYSTONE.y * 0.5 + 0.006), Basis(), side * 0.88, MEDALLION_GOLD)


## The seal's lion drawn in relief (altar_lion.gdshader on a quad): middle, basis (the quad faces its +z), side, colour.
func _lion(p: Vector3, basis: Basis, side: float, color: Color, parent: Node3D = null) -> MeshInstance3D:
	if not _lion_mats.has(color):
		var lm := ShaderMaterial.new()
		lm.shader = LION_SHADER
		lm.set_shader_parameter(&"lion", ArenaKit.LION_FIELD)
		lm.set_shader_parameter(&"stone", color)
		_lion_mats[color] = lm
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(side, side)
	mi.mesh = q
	mi.material_override = _lion_mats[color]
	mi.transform = Transform3D(basis, p)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	(parent if parent != null else frame).add_child(mi)
	return mi


# ---------- the square and the front ----------

## A box of a plain material (gold threads, iron bars) not merged with the stone.
func _bar(p: Vector3, size: Vector3, mat: Material, basis := Basis()) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	mi.transform = Transform3D(basis, p)
	frame.add_child(mi)
	return mi


## A painted decal flat on a surface (floor_decal.gdshader; `values` its uniforms, kind among them), size in m.
func _decal(p: Vector3, size: Vector2, values: Dictionary, basis := Basis()) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var q := PlaneMesh.new()
	q.size = size
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = DECAL_SHADER
	mat.set_shader_parameter(&"rug_size", size)
	for k: StringName in values:
		mat.set_shader_parameter(k, values[k])
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.transform = Transform3D(basis, p)
	frame.add_child(mi)
	return mi


## A plain lit material of colour c and roughness (one per pair).
func _plain(c: Color, rough: float) -> StandardMaterial3D:
	var key := [c, rough]
	if not _plain_mats.has(key):
		var s := StandardMaterial3D.new()
		s.albedo_color = c
		s.roughness = rough
		_plain_mats[key] = s
	return _plain_mats[key]


# ---------- the stations ----------

## The Vendedor (spec 3.2; HUB-D, H-P0-4): his stall in the west lobe facing the camera, the counter (its footprint,
## along u) under a cloth of petrol with wares on it, two racks of wares behind it, the great awning of rust earth and
## ochre with the lion in old gold over four posts (its back AWNING_BACK m high, its front AWNING_FRONT), two lanterns
## hanging from its front. The vendor himself stands between counter and racks (HUB-D, technical-artist).
func _vendor(c: Vector2, o: ArenaObstacle) -> void:
	var size := Vector3(o.half.x * 2.0, o.height, o.half.y * 2.0)
	fm.crate(at(c.x, 0.0, c.y), size, 0.0)
	var front := c.y - size.z * 0.5 - 0.01
	var cloth := _decal(at(c.x, size.y * 0.5, front), Vector2(size.x * 0.94, size.y * 0.8), {&"kind": 0,
		&"cloth": COUNTER_CLOTH, &"border": Color(0.18, 0.14, 0.09)}, Basis(Vector3.RIGHT, PI * 0.5))
	cloth.name = "CounterCloth"
	var r := RandomNumberGenerator.new()
	r.seed = 311
	_wares(Vector2(c.x - size.x * 0.44, c.y), Vector2(c.x + size.x * 0.44, c.y), size.y, 9, r)
	# the racks behind (boards on posts), wares on every board
	var wood := m._wood_mat(0.0, 0.8)
	var rv := c.y + AWNING_DEPTH.y - 0.5
	for sd: float in [-1.0, 1.0]:
		fm.block(at(c.x + sd * (AWNING_HALF - 0.3), 0.0, rv), Vector3(0.12, VENDOR_SHELVES[VENDOR_SHELVES.size() - 1] + 0.3, 0.12), 0.0, wood, false)
	for h in VENDOR_SHELVES:
		fm.block(at(c.x, h - 0.06, rv), Vector3(AWNING_HALF * 2.0 - 0.5, 0.06, 0.55), 0.0, m._wood_mat(0.0, 1.0), false)
		_wares(Vector2(c.x - AWNING_HALF + 0.5, rv), Vector2(c.x + AWNING_HALF - 0.5, rv), h, 10, r)
	# the posts at the awning's corners
	var fv := c.y - AWNING_DEPTH.x
	var bv := c.y + AWNING_DEPTH.y
	for sd: float in [-1.0, 1.0]:
		fm.shaft(at(c.x + sd * (AWNING_HALF - 0.1), 0.0, fv + 0.08), POST_R, AWNING_FRONT, wood)
		fm.shaft(at(c.x + sd * (AWNING_HALF - 0.1), 0.0, bv - 0.08), POST_R, AWNING_BACK, wood)
	_awning(c)
	var lights: Array[OmniLight3D] = []
	for du in VENDOR_LANTERNS:
		lights.append(hanging_lantern(world(c.x + du, AWNING_FRONT + 0.25, fv + 0.3), AWNING_FRONT - 0.45, LANTERN_SIZE, LANTERN_LIGHT))
	station_lights[HubPlan.VENDOR] = lights[0]


## Wares along a to b (frame u, v) on a top at height y: urns and jars in amber, ivory and slate blue, small boxes, rolls.
func _wares(a: Vector2, b: Vector2, y: float, count: int, r: RandomNumberGenerator) -> void:
	for k in count:
		var p := a.lerp(b, (k + r.randf_range(0.3, 0.7)) / count)
		match r.randi() % 4:
			0, 1:
				var glaze: Color = GLAZES[r.randi() % GLAZES.size()]
				fm.urn(at(p.x, y, p.y), r.randf_range(0.2, 0.34), m.carved(0.0, glaze * 2.2), r.randf() < 0.6)
			2:
				fm.box(at(p.x, y + 0.08, p.y), Vector3(0.2, 0.16, 0.24), r.randf_range(-0.3, 0.3), m._wood_mat(0.0, 0.9))
			3:
				var roll := fm.shaft(at(p.x, y + 0.06, p.y), 0.06, 0.32, _plain(SCROLL, 0.9))
				roll.basis = Basis(Vector3.RIGHT, PI * 0.5) * Basis(Vector3.FORWARD, r.randf_range(-0.4, 0.4))
				roll.position = at(p.x, y + 0.06, p.y)


## The awning (spec 3.2): a cloth over the stall from its back (high) to its front (low), across u, a scalloped valance
## under its front, the lion on its slope; runs of rust earth and ochre across it.
func _awning(c: Vector2) -> void:
	var v_back := c.y + AWNING_DEPTH.y
	var v_front := c.y - AWNING_DEPTH.x
	var u0 := c.x - AWNING_HALF
	var u1 := c.x + AWNING_HALF
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rows := 6
	var cols := int((u1 - u0) * AWNING_RUNS) * 2
	for i in rows:
		for j in cols:
			var quad: Array[Vector3] = []
			for d: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)]:
				var t := float(i + d.x) / rows
				var s := float(j + d.y) / cols
				# a soft sag between the posts
				var y := _awning_y(t) - sin(PI * s) * 0.1 * t
				quad.append(at(lerpf(u0, u1, s), y, lerpf(v_back, v_front, t)))
			st.set_color(AWNING_CLOTH if (j / 2) % 2 == 0 else AWNING_STRIPE)
			for idx: int in [0, 1, 2, 0, 2, 3]:
				st.add_vertex(quad[idx])
	# the valance: scallops hanging under the front edge
	var n := int((u1 - u0) * VALANCE.y)
	for k in n:
		var s0 := lerpf(u0, u1, float(k) / n)
		var s1 := lerpf(u0, u1, float(k + 1) / n)
		var seg := 6
		for q in seg:
			var a0 := lerpf(s0, s1, float(q) / seg)
			var a1 := lerpf(s0, s1, float(q + 1) / seg)
			var d0 := VALANCE.x + sin(PI * q / seg) * 0.12
			var d1 := VALANCE.x + sin(PI * (q + 1) / seg) * 0.12
			var y := AWNING_FRONT - 0.04
			st.set_color(AWNING_CLOTH)
			var quad2: Array[Vector3] = [at(a0, y, v_front), at(a1, y, v_front), at(a1, y - d1, v_front), at(a0, y - d0, v_front)]
			for idx: int in [0, 1, 2, 0, 2, 3]:
				st.add_vertex(quad2[idx])
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.name = "Awning"
	mi.mesh = st.commit()
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = true
	mat.roughness = 1.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = mat
	frame.add_child(mi)
	# the lion on the cloth's slope, a little over it, upright on the screen
	var t := (AWNING_RIDGE.x + 1.0) * 0.5
	var mid := at(c.x, _awning_y(t) + 0.03, lerpf(v_back, v_front, t))
	var slope := (at(c.x, AWNING_FRONT, v_front) - at(c.x, AWNING_RIDGE.y, lerpf(v_back, v_front, AWNING_RIDGE.x))).normalized()
	var normal := Vector3.RIGHT.cross(slope)
	if normal.y < 0.0:
		normal = -normal
	var up := -slope
	var basis := Basis(up.cross(normal), up, normal)
	_lion(mid + normal * 0.02, basis, AWNING_LION, MEDALLION_GOLD)


## The awning's height at t (0 its back edge, 1 its front): up the long back slope to the ridge, down the short front
## one, a soft sag in each.
func _awning_y(t: float) -> float:
	if t < AWNING_RIDGE.x:
		var k := t / AWNING_RIDGE.x
		return lerpf(AWNING_BACK, AWNING_RIDGE.y, k) - sin(PI * k) * 0.08
	var f := (t - AWNING_RIDGE.x) / (1.0 - AWNING_RIDGE.x)
	return lerpf(AWNING_RIDGE.y, AWNING_FRONT, f) - sin(PI * f) * 0.1


## The Forjador's forge (spec 3.3; HUB-D, H-P0-4): on the floor north-west of the anvil (HubPlan.FORGE, its footprint),
## a block of ashlar with its round-arched mouth on the south face toward the camera, the hearth inside with the coals,
## the fire and a glow at its soot-black back, the chimney over it; its light out at the mouth (the only fire with a
## shadow). set_forge_rank lights it more. West of it the yard (_yard): the rack of blades, the trough, the coal.
func _forge() -> void:
	var f := HubPlan.FORGE
	var body := Vector3(HubPlan.FORGE_HALF.x * 2.0, FORGE_TOP, HubPlan.FORGE_HALF.y * 2.0)
	var mat := ashlar()
	var soot := m.stone(0.0, Color(0.25, 0.22, 0.2))
	var front := f.y - body.z * 0.5
	var sill := FORGE_MOUTH.y
	var mouth: Array[Vector4] = [Vector4(f.x, FORGE_MOUTH.x, sill, sill + FORGE_MOUTH.z)]
	var arcs: Array[float] = [0.5]
	_wall(true, front, front + body.z, f.x - body.x * 0.5, f.x + body.x * 0.5, body.y, mouth, arcs, mat)
	fm.block(at(f.x, body.y, f.y), Vector3(body.x + 0.24, 0.18, body.z + 0.24), 0.0, mat, false)
	fm.voussoir_arch(at(f.x, sill, front - 0.1), SOUTH, FORGE_MOUTH.x, FORGE_MOUTH.z, 0.34, 0.45, mat, 0.5)
	# the hood over the mouth (a sloped lintel of stone)
	fm.block(at(f.x, sill + FORGE_MOUTH.z + FORGE_MOUTH.x * 0.5 + 0.35, front - 0.35), Vector3(FORGE_MOUTH.x + 1.2, 0.3, 0.7), 0.0, mat, false)
	# the hearth: its soot-black back, the stone sill out in front, the coals
	fm.block(at(f.x, sill - 0.05, front + FORGE_HEARTH + 0.3), Vector3(FORGE_MOUTH.x + 0.1, FORGE_MOUTH.z + 1.0, 0.6), 0.0, soot, false)
	fm.block(at(f.x, 0.0, front - 0.3), Vector3(FORGE_MOUTH.x + 0.9, sill, 0.6), 0.0, stone(), false)
	var coals := MeshInstance3D.new()
	var bed := PlaneMesh.new()
	bed.size = Vector2(FORGE_MOUTH.x - 0.2, FORGE_HEARTH - 0.1)
	coals.mesh = bed
	coals.material_override = fk._coals()
	coals.position = at(f.x, sill + 0.03, front + FORGE_HEARTH * 0.5)
	coals.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(coals)
	var hearth: Array = [coals]
	var lit_from := frame.get_child_count()
	fk.fire(at(f.x, sill + 0.02, front + 0.9), 0.5, 16, 0.5, 0.6)
	for k in range(lit_from, frame.get_child_count()):
		hearth.append(frame.get_child(k))
	_closed_hides[HubPlan.SMITH] = hearth
	# the licks a rank more lights (hidden until then)
	for sd: float in [-1.0, 1.0]:
		var from := frame.get_child_count()
		fk.fire(at(f.x + sd * 0.5, sill + 0.02, front + 0.6), 0.3, 8, 0.36, 0.5)
		var added: Array = []
		for k in range(from, frame.get_child_count()):
			var nd := frame.get_child(k) as Node3D
			nd.visible = false
			added.append(nd)
		_forge_fires.append(added)
	# the glow at the hearth's back, under the screen's ceiling, a step brighter a rank
	var glow := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = FORGE_GLOW
	glow.mesh = q
	_forge_glow = StandardMaterial3D.new()
	_forge_glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_forge_glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_forge_glow.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	var gc := ScreenTone.fit(FORGE_GLOW_COLOR)
	_forge_glow.albedo_color = Color(gc.r, gc.g, gc.b, FORGE_GLOW_ALPHA.x)
	glow.material_override = _forge_glow
	glow.position = at(f.x, sill + FORGE_GLOW.y * 0.5 + 0.05, front + FORGE_HEARTH - 0.02)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(glow)
	# the chimney over the back of it, its cap, its smoke
	var cv := f.y + body.z * 0.2
	fm.block(at(f.x, body.y + 0.18, cv), Vector3(CHIMNEY.x, CHIMNEY.y - body.y - 0.18, CHIMNEY.x), 0.0, mat, false)
	fm.block(at(f.x, CHIMNEY.y, cv), Vector3(CHIMNEY.x + 0.3, 0.2, CHIMNEY.x + 0.3), 0.0, mat, false)
	lit_from = frame.get_child_count()
	fk.mist_bank(at(f.x, CHIMNEY.y + SMOKE.y * 0.45, cv), SMOKE, SMOKE_COLOR, SMOKE_ALPHA, 0.0, 0.0, 0.25)
	for k in range(lit_from, frame.get_child_count()):
		hearth.append(frame.get_child(k))
	var l := OmniLight3D.new()
	l.position = at(f.x + FORGE_LIGHT_EAST, sill + 0.8, front - 0.9)
	l.light_color = FORGE_COLOR
	l.light_energy = FORGE_LIGHT.x
	l.omni_range = FORGE_LIGHT.y
	l.omni_attenuation = FORGE_LIGHT.z
	l.shadow_enabled = true
	l.light_cull_mask = ~Arena.CROWD_LAYER
	l.set_meta(ArenaKit.KEEP_SHADOW, true)
	l.set_meta(ArenaKit.FIRE_SHARE, 1.0)
	frame.add_child(l)
	station_lights[HubPlan.SMITH] = l
	_forge_light = l


## The anvil (spec 3.3) on its footprint (HUB-D: 1.5 times the old one): a stump of wood, the iron body and face, the
## horn toward the square, tongs and a hammer by it.
func _anvil(c: Vector2, o: ArenaObstacle) -> void:
	var wood := m._wood_mat(0.0, 0.8)
	fm.shaft(at(c.x, 0.0, c.y), ANVIL_STUMP.x, ANVIL_STUMP.y, wood)
	var ir := tomb.iron()
	var y := ANVIL_STUMP.y
	_bar(at(c.x, y + 0.17, c.y), Vector3(0.75, 0.34, 0.54), ir)
	_bar(at(c.x, y + 0.42, c.y), Vector3(0.5, 0.2, 0.36), ir)
	_bar(at(c.x - 0.04, o.height - 0.09, c.y), Vector3(0.98, 0.18, 0.5), ir)
	var horn := _bar(at(c.x + 0.62, o.height - 0.12, c.y), Vector3(0.36, 0.14, 0.3), ir)
	horn.scale = Vector3(1.0, 0.8, 0.7)
	_bar(at(c.x + 0.2, o.height + 0.02, c.y + 0.1), Vector3(0.5, 0.05, 0.06), ir, Basis(Vector3.UP, 0.4))


## The Árvore de Dons (spec 3.4; phase 3a): the dais of two octagonal steps on its footprint, a stone pedestal on it and,
## tilted toward the camera, the bronze medallion of the Dons screen (a rim ring, the lion in relief, a soft warm glow
## behind), its warm light. It replaced the stone tree so that the Videira is the one tree of the hub.
func _tree(c: Vector2, _o: ArenaObstacle) -> void:
	var mat := stone()
	for k in DAIS.size():
		var pts := PackedVector2Array()
		for i in 8:
			var a := TAU * (i + 0.5) / 8.0
			var p := c + Vector2(cos(a), sin(a)) * DAIS[k].x
			pts.append(Vector2(p.x, -p.y))
		fm.prism(pts, DAIS[k - 1].y if k > 0 else -0.6, DAIS[k].y, mat)
	var top := DAIS[DAIS.size() - 1].y
	var y := top
	for part in PEDESTAL:
		fm.block(at(c.x, y, c.y), Vector3(part.x, part.y, part.x), 0.0, mat, false)
		y += part.y
	var centre := at(c.x, top + DISC_HEIGHT, c.y)
	# a cylinder stands on its Y axis: a quarter turn about X lays that axis along the screen's depth, then it tilts back
	var tilt := Basis(Vector3.RIGHT, -deg_to_rad(DISC_TILT))
	var face := tilt * Basis(Vector3.RIGHT, PI * 0.5)
	var normal := tilt * Vector3.BACK
	var cm := CylinderMesh.new()
	cm.top_radius = DISC_RADIUS
	cm.bottom_radius = DISC_RADIUS
	cm.height = DISC_THICK
	cm.radial_segments = 40
	cm.rings = 1
	var disc := MeshInstance3D.new()
	disc.mesh = cm
	disc.material_override = _bronze(DISC_BRONZE, 0.45)
	disc.transform = Transform3D(face, centre)
	frame.add_child(disc)
	var rm := TorusMesh.new()
	rm.inner_radius = DISC_RADIUS - DISC_RIM * 0.5
	rm.outer_radius = DISC_RADIUS + DISC_RIM * 0.5
	rm.rings = 40
	rm.ring_segments = 8
	var ring := MeshInstance3D.new()
	ring.mesh = rm
	ring.material_override = _bronze(DISC_RIM_BRONZE, 0.35)
	ring.transform = Transform3D(face, centre + normal * (DISC_THICK * 0.5))
	frame.add_child(ring)
	# the lion, in relief on the face
	_lion(centre + normal * (DISC_THICK * 0.5 + 0.008), tilt, DISC_RADIUS * DISC_LION, DISC_FIELD)
	# the soft glow behind and round the disc
	var grad := Gradient.new()
	grad.set_color(0, Color(DISC_GLOW_COLOR, DISC_GLOW.y))
	grad.set_color(1, Color(DISC_GLOW_COLOR, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	var gm := StandardMaterial3D.new()
	gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	gm.albedo_texture = gt
	var gq := QuadMesh.new()
	gq.size = Vector2.ONE * DISC_RADIUS * 2.0 * DISC_GLOW.x
	var glow := MeshInstance3D.new()
	glow.mesh = gq
	glow.material_override = gm
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	glow.transform = Transform3D(tilt, centre - normal * 0.05)
	frame.add_child(glow)
	_closed_hides[HubPlan.TREE] = [glow]
	_gift_plaques(c)
	var l := OmniLight3D.new()
	l.position = world(c.x, top + TREE_LIGHT.z, c.y)
	l.light_color = TREE_COLOR
	l.light_energy = TREE_LIGHT.x
	l.omni_range = TREE_LIGHT.y
	l.light_cull_mask = ~Arena.CROWD_LAYER
	l.set_meta(ArenaKit.NOT_FIRE, true)
	add_child(l)
	station_lights[HubPlan.TREE] = l


## A bronze: a metallic plain material of colour c and roughness (one per pair).
func _bronze(c: Color, rough: float) -> StandardMaterial3D:
	var key := [&"bronze", c, rough]
	if not _plain_mats.has(key):
		var s := StandardMaterial3D.new()
		s.albedo_color = c
		s.roughness = rough
		s.metallic = 0.7
		_plain_mats[key] = s
	return _plain_mats[key]


## HV-C (6.3), the Dons' plaques round the dais (HV-E E3 lights them; dull at first): low stones on the lower step
## (PLAQUE: width, height, thickness), one every PLAQUE_STEP degrees all round, a lozenge cut on the face
## turned out, in dimmed old gold.
const PLAQUE := Vector3(0.42, 0.24, 0.12)
const PLAQUE_STEP := 30.0
const PLAQUE_GOLD := 0.6
func _gift_plaques(c: Vector2) -> void:
	var mat := stone()
	var g := MEDALLION_GOLD * PLAQUE_GOLD
	var gold := _plain(Color(g.r, g.g, g.b), 0.8)
	var r := (DAIS[0].x + DAIS[1].x) * 0.5
	var a := PLAQUE_STEP * 0.5
	while a < 360.0:
		var w := Vector2.from_angle(deg_to_rad(a))
		var p := c + w * r
		var yaw := atan2(-w.y, w.x) + PI * 0.5
		var b := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, -0.12)
		fm.box(at(p.x, DAIS[0].y + PLAQUE.y * 0.5, p.y), PLAQUE, yaw, mat, false)
		var face := at(p.x, DAIS[0].y + PLAQUE.y * 0.55, p.y) + Vector3(w.x, 0, -w.y) * (PLAQUE.z * 0.5 + 0.004)
		_bar(face, Vector3(0.08, 0.08, 0.006), gold, b * Basis(Vector3.BACK, PI * 0.25))
		a += PLAQUE_STEP


## The Livro de Ahk (spec 3.5; HUB-D, H-P0-4: a pulpit, not a side table): the lectern on its footprint (a stone foot on
## a step, a sloped top of wood toward the reader), the book open on it (two pages, the petrol ribbon), a candle stand
## each side; behind it, on its own footprint (hub_shelf), the tall case of scrolls and closed books facing the camera
## with its cornice and a ladder; the rug before it. Ahk has no figure.
func _book(c: Vector2, o: ArenaObstacle) -> void:
	var mat := stone()
	fm.block(at(c.x, 0.0, c.y), Vector3(o.half.x * 2.6, 0.16, o.half.y * 2.6), 0.0, mat)
	fm.block(at(c.x, 0.16, c.y), Vector3(LECTERN_FOOT.x, LECTERN_FOOT.y - 0.16, LECTERN_FOOT.x), 0.0, mat)
	fm.block(at(c.x, LECTERN_FOOT.y - 0.12, c.y), Vector3(LECTERN_FOOT.x + 0.16, 0.12, LECTERN_FOOT.x + 0.16), 0.0, mat, false)
	# the top rises toward +u (away from the reader at the use point)
	var tilt := Basis(Vector3.BACK, deg_to_rad(LECTERN_TILT))
	var top_y := o.height - 0.1
	var wood := m._wood_mat(0.0, 0.9)
	var desk := fm.box(at(c.x, top_y, c.y), Vector3(o.half.x * 2.0, 0.07, o.half.y * 2.0), 0.0, wood, false)
	desk.basis = tilt
	for sd: float in [-1.0, 1.0]:
		var page := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = Vector2(PAGE.x, PAGE.y)
		page.mesh = q
		var pm := ShaderMaterial.new()
		pm.shader = PAGE_SHADER
		pm.set_shader_parameter(&"spine_left", sd > 0.0)
		page.material_override = pm
		# lying on the desk, u across the page along the frame's v (the spine runs across the slope)
		var lay := tilt * Basis(Vector3.UP, PI * 0.5) * Basis(Vector3.RIGHT, -PI * 0.5) * Basis(Vector3.FORWARD, sd * 0.1)
		page.transform = Transform3D(lay, at(c.x, top_y, c.y) + tilt * Vector3(0, 0.06, 0) + Vector3(0, 0, -sd * PAGE.x * 0.5))
		page.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		frame.add_child(page)
		_closed_hides.get_or_add(HubPlan.BOOK, []).append(page)
	_book_at = Transform3D(tilt, at(c.x, top_y, c.y) + tilt * Vector3(0, 0.08, 0))
	_bar(at(c.x, top_y - 0.3, c.y) + tilt * Vector3(-o.half.x + 0.02, 0, 0), Vector3(0.01, 0.6, 0.05), _plain(RIBBON, 0.9))
	# a candle stand each side of it (iron, three candles)
	var ir := tomb.iron()
	for sd: float in [-1.0, 1.0]:
		var p := Vector2(c.x + 0.2, c.y + sd * (o.half.y + 0.55))
		fm.shaft(at(p.x, 0.0, p.y), 0.04, CANDLE_STAND, ir)
		_bar(at(p.x, CANDLE_STAND, p.y), Vector3(0.36, 0.04, 0.12), ir)
		for k in 3:
			fm.candle(at(p.x - 0.13 + k * 0.13, CANDLE_STAND + 0.02, p.y), 0.16 + 0.08 * (k % 2), 0.045)
	_decal(at(c.x - 0.3, DECAL_Y, c.y), RUG, {&"kind": 0, &"cloth": Color(0.07, 0.14, 0.15), &"border": Color(0.26, 0.17, 0.11)})
	var l := warm_light(world(c.x - 0.6, BOOK_LIGHT.y, c.y), BOOK_LIGHT.x, false, 6.0)
	station_lights[HubPlan.BOOK] = l


## The case of the Livro's scrolls and books (HUB-D) on its footprint, facing the camera: sides and a back of dark
## wood, boards with books and rolls on every one, a cornice, a ladder leaning on it, candles on the second board.
func _shelf(c: Vector2, o: ArenaObstacle) -> void:
	var wood := m._wood_mat(0.0, 0.7)
	var w := o.half.x * 2.0
	var d := o.half.y * 2.0
	fm.block(at(c.x, 0.0, c.y + o.half.y - 0.06), Vector3(w, o.height, 0.12), 0.0, wood, false)
	for sd: float in [-1.0, 1.0]:
		fm.block(at(c.x + sd * (o.half.x - 0.08), 0.0, c.y), Vector3(0.16, o.height, d), 0.0, wood, false)
	fm.block(at(c.x, o.height, c.y - 0.04), Vector3(w + 0.3, 0.22, d + 0.2), 0.0, wood, false)
	var r := RandomNumberGenerator.new()
	r.seed = 4421
	for h in SHELF_BOARDS:
		fm.block(at(c.x, h - 0.05, c.y), Vector3(w - 0.2, 0.05, d - 0.1), 0.0, wood, false)
		var uu := c.x - o.half.x + 0.25
		while uu < c.x + o.half.x - 0.25:
			if r.randf() < 0.4:
				var roll := fm.shaft(at(uu, h + 0.07, c.y), 0.07, d - 0.2, _plain(SCROLL, 0.9))
				roll.basis = Basis(Vector3.RIGHT, PI * 0.5)
				roll.position = at(uu, h + 0.07, c.y + (d - 0.2) * 0.5)
				uu += 0.16
			else:
				var hb := r.randf_range(0.3, 0.46)
				var tb := r.randf_range(0.06, 0.12)
				fm.box(at(uu, h + hb * 0.5, c.y), Vector3(tb, hb, d - 0.25), r.randf_range(-0.05, 0.05), _plain(BOOK_COVERS[r.randi() % BOOK_COVERS.size()], 0.8), false)
				uu += tb + 0.02
	fm.candle(at(c.x - o.half.x * 0.5, SHELF_BOARDS[1], c.y - o.half.y + 0.15), 0.18, 0.045)
	fm.candle(at(c.x + o.half.x * 0.55, SHELF_BOARDS[2], c.y - o.half.y + 0.15), 0.16, 0.045)
	for sd: float in [-1.0, 1.0]:
		var rail := fm.box(at(c.x + o.half.x * 0.45 + sd * 0.22, o.height * 0.42, c.y - o.half.y - 0.45), Vector3(0.06, o.height * 0.86, 0.06), 0.0, wood, false)
		rail.basis = Basis(Vector3.RIGHT, -0.2)


# ---------- the people (HUB-D, technical-artist) ----------

## The Vendedor behind his counter (frame u, v), turned from facing the square this many degrees toward the camera.
const VENDOR_STAND := HubPlan.VENDOR_SPOT
const VENDOR_TURN := 20.0


## The two people (HubNpc, baked KayKit figures): the Vendedor behind his counter, the Forjador west of the anvil
## facing it across (in profile to the camera), standing where his hammer's head lands on its face.
func _people() -> void:
	var vendor := HubNpc.make(HubNpc.Who.VENDOR)
	frame.add_child(vendor)
	vendor.position = at(VENDOR_STAND.x, 0.0, VENDOR_STAND.y)
	# facing the camera across his counter, turned a little toward the hero's way in (HUB-D: the stall faces south)
	vendor.rotation.y = deg_to_rad(VENDOR_TURN)
	var smith := HubNpc.make(HubNpc.Who.SMITH)
	frame.add_child(smith)
	smith.rotation.y = PI * 0.5
	var hit := HubNpc.strike_point()
	smith.position = at(HubPlan.ANVIL.x, 0.0, HubPlan.ANVIL.y + 0.05) - smith.basis * Vector3(hit.x, 0.0, hit.z)
