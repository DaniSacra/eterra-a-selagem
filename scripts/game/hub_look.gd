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
## The side walls (u = +-WALL_FACE to +-WALL_BACK), from v WALL_FROM to the facade, WALL_HEIGHT tall; their south end
## steps down (RUIN_END: v from, height) so no clean section faces the camera.
const WALL_FACE := 26.0
const WALL_BACK := 27.5
const WALL_FROM := -10.8
const WALL_HEIGHT := 6.5
const WALL_RUIN: Array[Vector2] = [Vector2(-10.8, 1.6), Vector2(-10.4, 3.4)]
const WALL_RUIN_TO := -10.0
## Pilasters on the side walls between the stations (v), how far they stand out, their width.
const PILASTERS: Array[float] = [-12.5, -3.4, 5.0, 14.6]
const PILASTER := Vector2(0.2, 0.7)
## A band of the wall's arched holes is cut in steps this tall above the springing (hidden by the arch rings).
const BAND := 0.3
## The facade: its front face, the front layer's back (the inner layer behind it to FACADE_BACK), from u -FACADE_HALF
## to FACADE_HALF, FACADE_TOP tall, its cornice.
const FACADE_V := 17.5
const FACADE_MID := 18.35
const FACADE_BACK := 19.2
const FACADE_HALF := 27.5
const FACADE_TOP := 11.0
const CORNICE := Vector2(0.3, 0.2)

# ---------- the portal ----------
## The stairs to the portal (spec 3.1): from v STAIRS_FROM, 8 m wide, six steps of 0.2 by 0.5; the terrace they climb to
## at y TERRACE_Y (u within TERRACE_HALF from v TERRACE_FROM to the facade; beside the stairs it comes forward to the
## floor's north edge), a thread of old gold along the landing's front.
const STAIRS_FROM := HubPlan.NORTH
const STAIRS_WIDTH := 10.0
const STAIRS_STEPS := 6
const STAIRS_RISE := 0.2
const STAIRS_RUN := 0.5
const TERRACE_Y := 1.2
const TERRACE_HALF := HubPlan.LOBE.x
const TERRACE_FROM := 15.0
const LANDING_FILET := 0.06
## The opening of the portal (its sheet): width, height over the landing, the springing of its pointed head; the sheet's
## plane (v) and the dark behind it.
const PORTAL_W := 3.6
const PORTAL_H := 5.0
const PORTAL_SPRING := 2.2
const SHEET_V := 18.75
const PORTAL_DARK := Color(0.02, 0.05, 0.035)
## The orders round it (spec 3.1: three, recessed): the innermost span, the step of span from one to the next, their
## middles' v (innermost first), the ring (width, depth), their pointed arcs (a share of the span), their stone a little
## lighter; the inner ring round the sheet itself (width, depth, v) and its stone darker.
const ORDERS := 3
const ORDER_SPAN := 4.8
const ORDER_STEP := 0.7
const ORDER_V: Array[float] = [18.2, 17.9, 17.6]
const ORDER_RING := Vector2(0.45, 0.6)
const ORDER_ARC := 0.65
const ORDER_TINT := Color(1.12, 1.12, 1.12)
const INNER_RING := Vector3(0.32, 0.3, 18.45)
const INNER_TINT := Color(0.62, 0.62, 0.62)
## The keystone with the seal's lion in old gold (never a star; spec 3.1): its side and depth.
const KEYSTONE := Vector2(0.9, 0.35)
## The seated lions on the terrace's wings beside the stairs (the Meshy lion_seated, 2026-11-21; it was a stele with the
## lion in relief): u, v; plinth (width, height, depth); the lion's height (it sits on a base of its own and looks
## along +Z, the square; the east one is the west one mirrored) and how far it turns to the stairs (radians), its
## stone tint over the carved stone of the rooms. HUB-D (H-P1-3): large, at the front of the wings, where the camera sees them.
const LIONS: Array[Vector2] = [Vector2(-7.0, 13.4), Vector2(7.0, 13.4)]
const LION_PLINTH := Vector3(1.9, 0.6, 2.8)
const LION_MODEL := "res://assets/models/meshy/lion_seated/lion_seated.glb"
const LION_HEIGHT := 2.5
const LION_TURN := 0.3
const LION_TINT := Color(1.0, 0.9, 0.78)
## The braziers at the stairs' foot on the terrace (u, v) and their light.
const BRAZIERS: Array[Vector2] = [Vector2(-7.0, 15.9), Vector2(7.0, 15.9)]
const BRAZIER_LIGHT := 2.6
## The planters along the terrace's front beside the stairs (from, to u; depth, height) with pale flowers on them.
const PLANTERS: Array[Vector2] = []
const PLANTER := Vector2(0.75, 0.42)
## The arcades each side of the portal (spec 3.6): their middles (u, mirrored), span, sill, springing over it, ring.
const ARCADES: Array[float] = [7.4, 9.6, 11.8, 14.0]
const ARCADE := Vector4(1.6, 1.2, 2.4, 0.3)
const ARCADE_ARC := 0.7
## The blind niches in the facade's corners (u mirrored; span, springing, ring): the Árvore's to the east.
const NICHES: Array[float] = [18.4, 22.6]
const NICHE := Vector3(2.2, 3.0, 0.3)
const NICHE_DARK := Color(0.42, 0.42, 0.44)
## The hooded figures before the niches (and in the side walls' niches): their height, how far out of the wall.
const STATUE_HEIGHT := 2.9
const STATUE_OUT := 0.75
## The side walls' statue niches (v; span, sill, springing over it) and the ledge between the floor's edge and the
## walls' faces (its top), with urns and candles along it at these v (both sides).
const SIDE_NICHE := Vector4(1.0, 2.4, 0.15, 3.3)
const LEDGE_TOP := 0.35
const LEDGE_WARES: Array[float] = [-8.4, 8.6, 14.6]
## The ground in the corners north of the floor, a step over it (top), out of the walkable.
const CORNER_TOP := 0.15
## The banners on the piers between the arcades (u mirrored, top, size).
const BANNERS: Array[float] = [5.3, 16.1]
const BANNER := Vector3(9.8, 1.1, 2.8)

# ---------- the square ----------
## The lion's medallion on the floor (spec 3.7): middle (u, v), the lion's side, its gold; two rings of old gold (outer
## and inner radius of each), how high over the slabs; the thread of gold on the axis (width; it stops at the fountain).
const MEDALLION := Vector2(0.0, -4.6)
const MEDALLION_LION := 4.4
const MEDALLION_GOLD := Color(0.36, 0.27, 0.13)
## The lion inlaid in the floor a step darker (it lies in the full light of the square).
const INLAY_GOLD := Color(0.27, 0.2, 0.1)
const MEDALLION_RINGS: Array[Vector2] = [Vector2(2.95, 3.1), Vector2(2.5, 2.58)]
const DECAL_Y := 0.02
const AXIS_FILET := 0.07
## The fountain of the lion (spec 3.7; decoration): the basin's blocks (how many, middle radius, height, thickness), the
## water's top and radius, the stele on its north rim (width, height, depth) with the lion's head in relief (side, how
## high) and the thread of water from its mouth (width), the moss round it.
const BASIN_BLOCKS := 20
## HUB-D (H-P1-5): a basin of 5.6 m and a stele of 2.8, the centre of the square, not a well.
const BASIN := Vector3(2.8, 0.7, 0.4)
const WATER_Y := 0.56
const WATER_R := 2.6
## The fountain's ripples (dark_water.gdshader): bands per metre, their sharpness, their light.
const WATER_RINGS := Vector3(0.6, 2.5, 0.05)
## P2-A9, only in the stylized look (with WATER_MATTE): the ripples brighter, the surface nearly matte (roughness,
## specular); it mirrored the sky's low cubemap, blotchy clouds that read as veins of marble.
## The classic surface (roughness, specular), the shader's own.
const WATER_GLOSS := Vector2(0.1, 0.4)
## The ripples themselves had become the marble (broad swells of light, WATER_RINGS' sharpness): in the stylized look
## they are faint thin lines (sharpness, light) over a body with a little light of its own (dark_water's body_light).
const STY_WATER_RINGS := Vector2(8.0, 0.035)
const STY_WATER_BODY := 1.4
const STY_WATER_GLOSS := Vector2(0.85, 0.03)
const FOUNTAIN_STELE := Vector3(1.5, 2.8, 0.5)
const FOUNTAIN_LION := Vector2(1.1, 1.9)
const SPOUT := 0.2
const FOUNTAIN_MOSS := Vector2(3.1, 4.4)
const FLOWER_OCHRE := Color(0.66, 0.58, 0.42)
const FLOWER_EARTH := Color(0.45, 0.32, 0.28)
## The great urns' plinth height.
const URN_PLINTH := 0.45
## The square's paving (HUB-D; the hub is 50 m across and the bare floor read as one vast empty slab: the paving tells
## its ways): cut slabs a hair over the floor (their top PAVE_TOP, a little lighter, PAVE_TINT), laid along the frame,
## nothing collides. A ring round the fountain (inner, outer radius, rings), one round the medallion (its slabs never
## inside the fountain's ring), and a way of larger slabs (across, along) from the fountain's ring toward each side
## station, WAY_WIDTH wide, stopping WAY_SHORT before its use point, with a kerb of darker stone (WAY_KERB wide, KERB_TINT)
## each side and worn paler slabs down its middle; the axis to the portal paved the same.
const FOUNTAIN_PAVING := Vector3(3.3, 5.6, 2.0)
const MEDALLION_PAVING := Vector3(3.25, 4.25, 1.0)
const PAVE_SLAB := 1.1
const PAVE_TOP := 0.025
const PAVE_TINT := Color(1.06, 1.04, 1.0)
const KERB_TINT := Color(0.7, 0.68, 0.66)
const WAY_KERB := 0.24
const WAY_WIDTH := 2.6
const WAY_SLAB := Vector2(1.3, 0.95)
const WAY_SHORT := 1.15
## PT-4: a way has no painted line. The slabs in its middle third are worn paler (WORN_TINT) and sit a hair higher
## (WORN_RISE), the way a walked path reads; the kerb and the dark joints frame it.
const WORN_TINT := Color(1.2, 1.17, 1.1)
const WORN_RISE := 0.006
const WORN_SHARE := 0.2
## The cypresses (HubPlan.CYPRESSES): the planter's height and coping, the tree's foot over it and its width at its
## widest (a share of the way up), the leaves' cards (size, how many a metre of height), their dark olive.
const PLANTER_HEIGHT := 0.7
const CYPRESS_FOOT := 0.4
const CYPRESS_WIDE := Vector2(1.25, 0.3)
const CYPRESS_CARD := Vector2(0.9, 1.4)
const CYPRESS_CARDS := 9.0
## Leaves on a crown's card (canopy.gdshader).
const CROWN_LEAVES := 7.0
const CYPRESS_A := Color(0.11, 0.13, 0.09)
const CYPRESS_B := Color(0.24, 0.27, 0.17)
## The raised beds' shrubs (HUB-D, H-P0-3: beds of pale flowers read as coffins): copper and rust leaves, a crown this
## tall and wide every SHRUB_EVERY metres along the bed.
const SHRUB_A := Color(0.26, 0.13, 0.06)
const SHRUB_B := Color(0.5, 0.3, 0.14)
## Art review 2026-11-21 item 5 (stylized look): the shrubs' leaves muted (the vivid orange is the hazard's colour,
## saturation under 0.45), bigger and less ragged so the cards stop reading as blocky noise.
const STY_SHRUB_A := Color(0.22, 0.17, 0.1)
const STY_SHRUB_B := Color(0.46, 0.32, 0.16)
const STY_CROWN_LEAVES := 5.0
const STY_CROWN_RAGGED := 0.12
const SHRUB_TALL := Vector2(1.0, 1.7)
const SHRUB_WIDE := 1.5
const SHRUB_EVERY := 1.4
## The yards' low walls (coping), the braziers on stands at the arrival (their light), the goods' crates.
const YARD_COPING := 0.1
const STAND_FIRE := Vector2(2.4, 5.5)
## HV-C (5): the Retorno's braziers at 0.9 m, a share of the kit's (about 1.4 m).
const RETURN_FIRE := 0.65
## P2-B2: the arrival braziers' flames in the stylized look, a share of their height and size (their light unchanged).
const STY_STAND_FLAME := 0.67

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
const AWNING_CLOTH := Color(0.26, 0.14, 0.1)
## Every other run of the cloth along v a muted wine (HV-C 6.2: hue 355, saturation 0.35, never the danger's red; an
## awning, not a sign); runs a metre.
const AWNING_STRIPE := Color(0.22, 0.13, 0.14)
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
## The low balustrade along the south and the cut corners (spec 3.6: nothing over 0.9 m within 2 m of the south edge):
## how far out, its curb (height, depth), balusters (radius, spacing), the rail (bottom, top); the arrival stairs' gap
## (half width) and the flight down (steps of rise and run), the grille at their foot; the lamp posts (height, arm).
const RAIL_OUT := 0.3
const RAIL_CURB := Vector2(0.24, 0.42)
const RAIL_BALUSTER := Vector2(0.07, 0.36)
const RAIL_TOP := Vector2(0.58, 0.7)
## HV-A: the Retorno's stairs, 7 x 2.5 m, down from the south edge at HubPlan.ARRIVAL_STAIRS, between low walls
## (ARRIVAL_CHEEK: thickness, height over the floor); the seal on the floor at HubPlan.ARRIVAL, the worn lion at
## SEAL_LION m in the inlay's gold dimmed to SEAL_GOLD (placeholder until HV-C).
const ARRIVAL_STEPS := 7
const ARRIVAL_RISE := 0.2
const ARRIVAL_RUN := 0.36
const ARRIVAL_CHEEK := Vector2(0.35, 0.65)
const SEAL_LION := 2.2
const SEAL_GOLD := 0.8
const LAMP_POST := Vector2(2.9, 0.55)
const LAMP_LIGHT := Vector2(1.3, 3.0)

# ---------- air and light ----------
## The far vista through the arcades (spec 3.6): the ruins' mist, stone and edge, the cascade left of the portal (u, v,
## width, height), the mist under the courtyard.
const VISTA := [Color(0.12, 0.13, 0.16), Color(0.05, 0.055, 0.065), Color(0.16, 0.17, 0.2)]
const CASCADE := Vector4(-14.0, 45.0, 4.4, 34.0)
const MIST := Color(0.1, 0.12, 0.17)
const CLIFF := {&"stone_color": Color(0.045, 0.045, 0.05), &"edge_color": Color(0.11, 0.11, 0.12), &"mist_color": Color(0.1, 0.12, 0.17),
	&"glow_color": Color(0.2, 0.22, 0.28)}
## The hub's air (spec 4.1: lighter and warmer than any room, the cold in the sky and the vista) and its stylized look.
const AIR := {
	&"sky": Color(0.06, 0.08, 0.13), &"fog": Color(0.14, 0.13, 0.13), &"fog_depth": Vector2(60.0, 140.0),
	&"ambient": Color(0.76, 0.76, 0.75), &"ambient_gain": 1.2, &"moon": Color(1.0, 0.96, 0.9), &"moon_energy": 0.8,
	&"moon_shadow": true,
}
## The classic look's floor (F7): the warm limestone of the stylized one, so the square is not the hall's rose slab.
const CLASSIC_FLOOR := {
	&"unit": 1.2, &"stone_a": Color(0.30, 0.29, 0.27), &"stone_b": Color(0.40, 0.38, 0.35),
	&"joint_color": Color(0.10, 0.09, 0.09), &"moss_color": Color(0.30, 0.29, 0.27), &"petal_color": Color(0.30, 0.29, 0.27),
	&"missing": 0.0, &"cracked": 0.2, &"split2": 0.45, &"tinted": 0.1,
}
## C1V N3 (docs/art/identidade_c1v.md 2.1, the hall's recipe, only in the stylized look): the shadow band's tint, the room's own hue
## (docs/art/plano_pintado_a_mao.md 5); the vignette is the hall's, the hub's softer.
const STY_SHADOW_GLOW := Color(0.15, 0.40, 0.55)
const STY_VIGNETTE := Vector3(0.5, 0.45, 1.3)
const STYLE := {
	&"stone": Color(0.4, 0.375, 0.345), &"floor_stone": Color(0.375, 0.355, 0.325), &"shadow": Color(0.8, 0.9, 0.96),
	&"joint_cold": Color(0.86, 0.93, 0.98), &"slab_paint": Vector2(0.82, 1.18), &"slab_hue": 6.0, &"olive_share": 0.03,
	&"edge_value": 1.0, &"pool_saturation": 0.8, &"metal": true,
	&"fire": {&"candle_range": 3.5, &"candle_gain": 1.2, &"bowl_range": 4.2, &"bowl_gain": 0.95},
	&"air": {&"sky": Color(0.06, 0.08, 0.13), &"fog": Color(0.14, 0.13, 0.13), &"ambient": Color(0.76, 0.76, 0.75),
		&"ambient_gain": STY_AMBIENT_GAIN, &"moon": Color(1.0, 0.96, 0.9), &"moon_energy": STY_MOON, &"moon_shadow": true},
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
const STY_AMBIENT_GAIN := 0.8
const STY_MOON := 0.45
const STY_KEY_SHARE := 0.45
const STY_FORGE_GAIN := 1.5
const STY_POOLS: Array[Array] = [
	# HV-A: each pool moved with its station's pieces (the anvil, the lectern, the counter, the dais)
	[HubPlan.SMITH, Vector3(-13.6, 0.6, -5.6), Vector3(-10.8, 7.5, -8.8), 9.0, 30.0, 12.0, Color(1.0, 0.7, 0.42)],
	[HubPlan.BOOK, Vector3(12.0, 1.2, -5.9), Vector3(11.0, 6.2, -7.9), 10.0, 18.0, 9.0, Color(1.0, 0.86, 0.62)],
	[HubPlan.BOOK, Vector3(11.4, 0.0, -5.3), Vector3(10.2, 8.0, -9.1), 11.0, 28.0, 12.0, Color(1.0, 0.82, 0.58)],
	[HubPlan.VENDOR, Vector3(-10.6, 0.8, 6.8), Vector3(-9.2, 8.0, 2.6), 9.0, 28.0, 12.0, Color(1.0, 0.8, 0.55)],
	[HubPlan.TREE, Vector3(11.9, 1.0, 8.5), Vector3(10.1, 9.0, 4.1), 5.0, 28.0, 13.0, Color(1.0, 0.84, 0.55)],
	# V2 and PT-9: the Videira's vase and the heroes' standards
	[HubPlan.VINE, Vector3(19.0, 1.0, 9.9), Vector3(17.2, 9.0, 5.4), 5.0, 28.0, 13.0, Color(0.9, 1.0, 0.62)],
	[HubPlan.HEROES, Vector3(-17.5, 1.4, 9.5), Vector3(-19.3, 9.0, 5.1), 5.0, 28.0, 13.0, Color(1.0, 0.84, 0.55)],
	[HubPlan.PORTAL, Vector3(0.0, 0.0, 10.4), Vector3(0.0, 8.0, 5.5), 14.0, 38.0, 13.0, Color(0.36, 1.0, 0.58)],
]
## P1-A2 of the cycle's art review: the portal's pool (the last row) green and wide enough to read at the top of the
## screen on arriving with the near camera. P2-A7: the floor's outer ring (past the stations, from the fountain at the
## world's middle: edge_span times the floor's calm radius) a step darker, so the frame is no lighter than the square.
## The darkening starts past STY_RIM_FLOOR's calm radius times edge_span (from the fountain; the hub's floor box is
## turned, its own calm radius came out past the cliffs) and leaves each station's pool alone (STY_KEEP: full to, none
## from, m round each pool's aim).
## P2-B3 (ART_REVIEW.md 4.5): the rim between the stations to 0.70 of the square or under (it measured 0.75 to 0.82).
const STY_RIM_FLOOR := {&"calm_radius": 8.0, &"edge_value": 0.32, &"edge_span": Vector2(1.1, 1.9)}
const STY_KEEP := Vector2(2.5, 4.0)
const KEEP_MAX := 6
## The browser's renderer: the stylized air's share there (its painted stone lights lighter).
const STY_COMPAT_AMBIENT := 0.3
const STY_COMPAT_MOON := 0.3
const STY_COMPAT_KEY := 0.5
## A soft fill over the square (no shadow), so the floor reads as the lightest of the game (spec 4.2).
const KEY := Color(1.0, 0.97, 0.92)
const KEY_ENERGY := 0.75
const LION_SHADER := preload("res://assets/shaders/altar_lion.gdshader")
const PAGE_SHADER := preload("res://assets/shaders/hub_page.gdshader")
const WATER_SHADER := preload("res://assets/shaders/dark_water.gdshader")
## The fountain in the stylized look: the same water without the sky mirrored in it (P2-A9, the cycle of 2026-11-20).
const WATER_MATTE := preload("res://assets/shaders/dark_water_matte.gdshader")
const CANOPY_SHADER := preload("res://assets/shaders/canopy.gdshader")
const DECAL_SHADER := preload("res://assets/shaders/floor_decal.gdshader")
## Facing directions in the frame (x, z): toward the camera (south), east, west.
const SOUTH := Vector2(0, 1)
const EAST := Vector2(1, 0)
const WEST := Vector2(-1, 0)

## The node turned by the camera's yaw that holds the hub's own pieces (frame coordinates: x = u, z = -v), its kit and
## stone.
var frame: Node3D
var fk: ArenaKit
var fm: Masonry
## Each station's own light (HUB-B3 lifts the one in focus).
## V2 and PT-9: the Videira's planting and the heroes' standards (null before dress; Hub.evolve gives them the save).
var vine_station: VineStation
var hero_station: HeroStation
var station_lights := {}
var _lion_mats := {}
var _plain_mats := {}
var _far: Array[Node] = []
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


## Every edge a plain cliff under the floor (walls, terrace and balustrade are dressed in the frame), but the north
## ones: the stairs' foot and the lobes along the terrace and the facade stand on ground.
func edge(a: Vector2, b: Vector2, out: Vector2, _kind: Edge, faces: SurfaceTool) -> void:
	if minf(HubPlan.to_local(a).y, HubPlan.to_local(b).y) > HubPlan.NORTH - 0.05:
		return
	cliff(a, b, out, faces)


## The hub's pieces (hub_*) are drawn in dress() on their footprints, in the frame.
func piece(o: ArenaObstacle) -> void:
	if String(o.piece).begins_with("hub_"):
		return
	super.piece(o)


func _light() -> void:
	var key := key_light(KEY, KEY_ENERGY * (STY_COMPAT_KEY if compat() else 1.0))
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
	_walls()
	_facade()
	_portal()
	_terrace()
	_front()
	_square()
	for o in layout.obstacles:
		var c := HubPlan.to_local(o.center)
		match o.piece:
			&"hub_fountain":
				_fountain(c)
			&"hub_counter":
				_vendor(c, o)
			&"hub_anvil":
				_anvil(c, o)
			&"hub_dais":
				_tree(c, o)
			&"hub_lectern":
				_book(c, o)
			&"hub_lamp":
				_lamp_post(c, o)
			&"hub_bench":
				_bench(c, o)
			&"hub_bed":
				_bed(c, o)
			&"hub_urn":
				_great_urn(c, o)
			&"hub_cypress":
				_cypress(c, o)
			&"hub_shelf":
				_shelf(c, o)
			&"hub_yard":
				_yard()
			&"hub_desk":
				_desk(c, o)
			&"hub_yard_wall":
				_yard_wall(c, o)
			&"hub_goods":
				_goods(c, o)
			&"hub_fire":
				_stand_fire(c)
			&"hub_alchemist":
				_alchemist(c, o)
			&"hub_vine":
				_vine_arch(c, o)
			&"hub_heroes":
				_hero_stand(c, o)
	_crowns(_cypress_spots, _cypress_tall, CYPRESS_A, CYPRESS_B, CYPRESS_WIDE.x, "Cypresses")
	_crowns(_shrub_spots, _shrub_tall, SHRUB_A, SHRUB_B, SHRUB_WIDE, "Shrubs")
	_forge()
	_people()
	_focus_rims()
	var from := get_child_count()
	backdrop(VISTA[0], VISTA[1], VISTA[2])
	_far = added_since(from)
	_cascade()
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


## The side walls with the stations' recesses (the furnace west, the shelf east), pilasters, cornice and the sill
## between the floor's edge and their face; their south ends broken down in steps.
func _walls() -> void:
	var mat := ashlar()
	for side: float in [-1.0, 1.0]:
		var face := side * WALL_FACE
		var back := side * WALL_BACK
		var holes: Array[Vector4] = []
		var arcs: Array[float] = []
		holes.append(SIDE_NICHE)
		arcs.append(ARCADE_ARC)
		var nv := SIDE_NICHE.x
		_slab(false, side * (WALL_BACK - 0.3), back, nv - SIDE_NICHE.y * 0.5, nv + SIDE_NICHE.y * 0.5, -0.6, SIDE_NICHE.w + 2.0, m.stone(0.0, NICHE_DARK))
		fm.voussoir_arch(at(face - side * 0.1, SIDE_NICHE.z, nv), EAST * -side, SIDE_NICHE.y - 0.2, SIDE_NICHE.w, NICHE.z, 0.5, mat, ARCADE_ARC)
		fk.statue(Vector2(side * (WALL_FACE + 0.75), -nv), -side * PI * 0.5, STATUE_HEIGHT, SIDE_NICHE.z, ArenaKit.STATUE_VALUE, false)
		_wall(false, face, back, WALL_RUIN_TO, FACADE_V + 0.1, WALL_HEIGHT, holes, arcs, mat)
		_slab(false, face - side * CORNICE.y, back, WALL_RUIN_TO, FACADE_V, WALL_HEIGHT - CORNICE.x, WALL_HEIGHT, mat)
		var from := WALL_RUIN[0].x
		for k in WALL_RUIN.size():
			var to := WALL_RUIN[k + 1].x if k + 1 < WALL_RUIN.size() else WALL_RUIN_TO
			_slab(false, face, back, from, to, -0.6, WALL_RUIN[k].y, mat)
			from = to
		_ledge(side)
		for v in PILASTERS:
			_slab(false, face - side * PILASTER.x, face, v - PILASTER.y * 0.5, v + PILASTER.y * 0.5, 0.0, WALL_HEIGHT - CORNICE.x, mat)


## The ledge between the floor's edge and a side wall (side -1 west, 1 east), a step up, with urns, a crate and candles
## along it (out of the walkable: the edges populated, never a bare corridor).
func _ledge(side: float) -> void:
	var u0 := side * HubPlan.HALF_U
	_slab(false, u0, side * WALL_FACE, WALL_FROM, HubPlan.LOBE.y, -0.6, LEDGE_TOP, stone())
	var r := RandomNumberGenerator.new()
	r.seed = 77 + int(side)
	var mid := side * (HubPlan.HALF_U + WALL_FACE) * 0.5
	for v in LEDGE_WARES:
		for k in 3:
			var p := Vector2(mid + side * r.randf_range(-0.2, 0.25), v + r.randf_range(-0.5, 0.5))
			if k == 0:
				fm.urn(at(p.x, LEDGE_TOP, p.y), r.randf_range(0.5, 0.75), m.carved(0.0, GLAZES[r.randi() % GLAZES.size()] * 1.6), r.randf() < 0.5)
			elif k == 1 and r.randf() < 0.5:
				fm.crate(at(p.x, LEDGE_TOP, p.y), Vector3(0.5, 0.42, 0.55), r.randf_range(-0.3, 0.3))
			else:
				fm.candle(at(p.x, LEDGE_TOP, p.y), r.randf_range(0.14, 0.26), 0.05)


## A great urn on a square plinth in the square (its footprint), a copper shrub growing out of it (HUB-D: tall and
## lidded they read as black spikes), candles at its foot.
func _great_urn(c: Vector2, o: ArenaObstacle) -> void:
	var side := o.radius * 1.9
	fm.block(at(c.x, 0.0, c.y), Vector3(side, URN_PLINTH, side), 0.0, stone())
	var tall := o.height - URN_PLINTH
	fm.urn(at(c.x, URN_PLINTH, c.y), tall, m.carved(0.0, GLAZES[int(absf(c.x) + absf(c.y)) % 2] * 1.5), false)
	_shrub_spots.append(Vector3(c.x, o.height - 0.15, c.y))
	_shrub_tall.append(SHRUB_TALL.x)
	for k in 2:
		fm.candle(at(c.x + side * (0.32 if k == 0 else -0.3), URN_PLINTH, c.y - side * 0.34), 0.16 + 0.08 * k, 0.045)


## A cypress in a stone planter on its footprint (HubPlan.CYPRESSES): the planter with its coping and dark earth, a
## short trunk and the crown (cards of dark olive leaves facing the camera on a spindle, widest low; drawn all at once
## in _cypress_crowns).
func _cypress(c: Vector2, o: ArenaObstacle) -> void:
	var side := o.half.x * 2.0
	fm.block(at(c.x, 0.0, c.y), Vector3(side, PLANTER_HEIGHT - 0.08, side), 0.0, stone())
	fm.block(at(c.x, PLANTER_HEIGHT - 0.08, c.y), Vector3(side + 0.14, 0.08, side + 0.14), 0.0, stone(), false)
	fm.block(at(c.x, PLANTER_HEIGHT - 0.06, c.y), Vector3(side - 0.24, 0.07, side - 0.24), 0.0, _plain(Color(0.09, 0.07, 0.05), 1.0), false)
	fm.shaft(at(c.x, PLANTER_HEIGHT, c.y), 0.1, CYPRESS_FOOT + 0.4, m._wood_mat(0.0, 0.6))
	_cypress_spots.append(Vector3(c.x, PLANTER_HEIGHT + CYPRESS_FOOT, c.y))
	_cypress_tall.append(o.height - PLANTER_HEIGHT - CYPRESS_FOOT)


## Every crown of one kind in one MultiMesh (the canopy's cards, canopy.gdshader; they open round the hero): the
## cypresses in dark olive, the beds' shrubs in copper (wide: the crown's width at its widest).
func _crowns(spots: Array[Vector3], talls: Array[float], leaf_a: Color, leaf_b: Color, width: float, label: String) -> void:
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
			# widest a share of the way up, to a point at the top
			var wide := width * 0.5 * (sqrt(t / CYPRESS_WIDE.y) if t < CYPRESS_WIDE.y else (1.0 - t) / (1.0 - CYPRESS_WIDE.y) * 0.9 + 0.1)
			var a := r.randf() * TAU
			var p := at(foot.x, foot.y + t * tall, foot.z) + Vector3(cos(a), 0.0, sin(a)) * wide * r.randf_range(0.3, 0.8)
			var size := lerpf(CYPRESS_CARD.y, CYPRESS_CARD.x, t) * r.randf_range(0.8, 1.1)
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
	if leaf_a == SHRUB_A:
		sty[&"shader_parameter/leaf_a"] = STY_SHRUB_A
		sty[&"shader_parameter/leaf_b"] = STY_SHRUB_B
	VisualProfile.vary(mat, sty)
	var mi := MultiMeshInstance3D.new()
	mi.name = label
	mi.multimesh = mm
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	frame.add_child(mi)


## The stone benches round the fountain and the flower beds by the arrival, on their footprints (HubPlan).
func _bench(c: Vector2, o: ArenaObstacle) -> void:
	var yaw := deg_to_rad(Feel.live().cam_yaw) + (PI * 0.5 if c.x < 0.0 else -PI * 0.5)
	tomb.bench(o.center, Vector2(o.half.y, o.half.x), yaw, stone())


## V2: the Videira's arch of stone on its footprint (two pillars, a lintel with its corner blocks, a low plinth between
## them) and the vase with its young vine in the middle (VineStation; `grow_vine` shows what the save has bought).
func _vine_arch(c: Vector2, o: ArenaObstacle) -> void:
	var mat := stone()
	var hx := o.half.x
	var h := o.height
	for side in [-1.0, 1.0]:
		fm.block(at(c.x + side * (hx - 0.25), 0.0, c.y), Vector3(0.5, h - 0.4, o.half.y * 2.0), 0.0, mat)
		fm.block(at(c.x + side * (hx - 0.85), h - 0.9, c.y), Vector3(0.7, 0.5, o.half.y * 2.0 - 0.1), 0.0, mat)
	fm.block(at(c.x, h - 0.4, c.y), Vector3(hx * 2.0 + 0.2, 0.4, o.half.y * 2.0 + 0.08), 0.0, mat)
	fm.block(at(c.x, 0.0, c.y), Vector3(hx * 2.0 - 0.5, 0.2, o.half.y * 2.0 - 0.1), 0.0, mat)
	vine_station = VineStation.make(frame, at(c.x, 0.0, c.y))


## The planting as the save has grown it (Vine.growth: nodes bought by branch; VineStation.grown).
func grow_vine(growth: Dictionary) -> void:
	if vine_station != null:
		vine_station.grown(growth)


## PT-9: the heroes' stand on its footprint (a low plinth of stone) with the two standards (HeroStation).
func _hero_stand(c: Vector2, o: ArenaObstacle) -> void:
	fm.block(at(c.x, 0.0, c.y), Vector3(o.half.x * 2.0, 0.3, o.half.y * 2.0), 0.0, stone())
	hero_station = HeroStation.make(frame, at(c.x, 0.0, c.y))


## The standards as the save has it (the picked hero's whole, the locked Maga grey).
func show_heroes(data: Dictionary) -> void:
	if hero_station != null:
		hero_station.refresh(data)


## A raised bed (HUB-D): a box of stone with its coping, dark earth, copper shrubs along it (drawn in _crowns), a few
## pale flowers at their feet.
func _bed(c: Vector2, o: ArenaObstacle) -> void:
	var h := o.height
	fm.block(at(c.x, 0.0, c.y), Vector3(o.half.x * 2.0, h - 0.08, o.half.y * 2.0), 0.0, stone())
	fm.block(at(c.x, h - 0.08, c.y), Vector3(o.half.x * 2.0 + 0.14, 0.08, o.half.y * 2.0 + 0.14), 0.0, stone(), false)
	fm.block(at(c.x, h - 0.06, c.y), Vector3(o.half.x * 2.0 - 0.24, 0.07, o.half.y * 2.0 - 0.24), 0.0, _plain(Color(0.09, 0.07, 0.05), 1.0), false)
	_decal(at(c.x, h + 0.02, c.y), Vector2(o.half.x * 2.0 - 0.3, o.half.y * 2.0 - 0.3), {
		&"kind": 3, &"leaf_dark": FLOWER_EARTH, &"leaf_light": FLOWER_OCHRE, &"litter_cell": 0.11,
		&"litter_size": Vector2(0.06, 0.1), &"litter_cover": 0.35})
	var long := o.half.x >= o.half.y
	var length := (o.half.x if long else o.half.y) * 2.0
	var n := maxi(1, roundi(length / SHRUB_EVERY))
	var r := RandomNumberGenerator.new()
	r.seed = int(absf(c.x) * 13.0 + absf(c.y) * 7.0)
	for k in n:
		var t := (k + 0.5) / n - 0.5
		var p := c + (Vector2(t * length, 0.0) if long else Vector2(0.0, t * length))
		_shrub_spots.append(Vector3(p.x, h, p.y))
		_shrub_tall.append(r.randf_range(SHRUB_TALL.x, SHRUB_TALL.y))


## A yard's low wall on its footprint (HUB-D: the Forjador's and the Livro's places closed to the south): blocks of
## ashlar, a coping, a candle or two on it.
func _yard_wall(c: Vector2, o: ArenaObstacle) -> void:
	var w := o.half.x * 2.0
	fm.block(at(c.x, 0.0, c.y), Vector3(w, o.height - YARD_COPING, o.half.y * 2.0), 0.0, ashlar())
	fm.block(at(c.x, o.height - YARD_COPING, c.y), Vector3(w + 0.1, YARD_COPING, o.half.y * 2.0 + 0.12), 0.0, stone(), false)
	for k in 2:
		fm.candle(at(c.x + (k - 0.5) * w * 0.6, o.height, c.y), 0.16 + 0.06 * k, 0.05)


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
func _glow_mat(c: Color) -> StandardMaterial3D:
	var key := [c, -1.0]
	if not _plain_mats.has(key):
		var s := StandardMaterial3D.new()
		s.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		s.albedo_color = c.lightened(0.25)
		_plain_mats[key] = s
	return _plain_mats[key]


## The Vendedor's goods on their footprint (HUB-D): crates stacked, sacks, jars in the wares' glazes.
func _goods(c: Vector2, o: ArenaObstacle) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = int(absf(c.x) * 31.0 + absf(c.y) * 3.0)
	var nu := maxi(1, roundi(o.half.x * 2.0 / 0.95))
	var nv := maxi(1, roundi(o.half.y * 2.0 / 0.95))
	for k in nu * nv:
		var cell := Vector2((k % nu + 0.5) / nu - 0.5, (k / nu + 0.5) / nv - 0.5)
		var p := c + Vector2(cell.x * o.half.x * 2.0, cell.y * o.half.y * 2.0) + Vector2(r.randf_range(-0.1, 0.1), r.randf_range(-0.1, 0.1))
		match (k + r.randi() % 2) % 3:
			0:
				var sz := Vector3(r.randf_range(0.6, 0.9), r.randf_range(0.5, 0.75), r.randf_range(0.6, 0.85))
				fm.crate(at(p.x, 0.0, p.y), sz, r.randf_range(-0.3, 0.3))
				if r.randf() < 0.6:
					fm.crate(at(p.x + 0.05, sz.y, p.y), sz * 0.8, r.randf_range(-0.4, 0.4))
			1:
				fm.urn(at(p.x, 0.0, p.y), r.randf_range(0.6, 0.95), m.carved(0.0, GLAZES[r.randi() % GLAZES.size()] * 1.6), r.randf() < 0.5)
			2:
				fm.box(at(p.x, 0.0, p.y), Vector3(0.55, 0.5, 0.4), r.randf() * TAU, _plain(Color(0.42, 0.36, 0.26), 1.0))


## A brazier on a stand by the arrival (HUB-D, H-P1-7: warm light in the square), without a shadow.
func _stand_fire(c: Vector2) -> void:
	var from := fk.root.get_child_count()
	var l := fk.brazier(Vector2(c.x, -c.y), 0.0, false, STAND_FIRE.x)
	# HV-C (5): the Retorno's two braziers are the smaller ones, RETURN_FIRE of the kit's height round their foot
	var foot := Vector3(c.x, 0.0, -c.y)
	for i in range(from, fk.root.get_child_count()):
		var n := fk.root.get_child(i) as Node3D
		if n != null and n != l:
			n.transform = Transform3D(Basis.from_scale(Vector3.ONE * RETURN_FIRE), foot) * Transform3D(Basis(), -foot) * n.transform
	l.position = foot + (l.position - foot) * RETURN_FIRE
	l.omni_range = STAND_FIRE.y
	l.shadow_enabled = false
	# P2-B2 (ART_REVIEW.md 4.5): in the stylized look the flames a third lower (their tongues' life and size), the
	# light as it was; they were the strongest fire of the frame on arriving, in the band nearest the camera
	for i in range(from, fk.root.get_child_count()):
		var p := fk.root.get_child(i) as CPUParticles3D
		if p != null:
			VisualProfile.vary(p, {&"lifetime": p.lifetime * STY_STAND_FLAME,
				&"scale_amount_min": p.scale_amount_min * STY_STAND_FLAME, &"scale_amount_max": p.scale_amount_max * STY_STAND_FLAME})


## The Livro's writing desk on its footprint (HUB-D): a table of dark wood, rolls and a closed book on it, an inkwell,
## a candle, a stool.
func _desk(c: Vector2, o: ArenaObstacle) -> void:
	var wood := m._wood_mat(0.0, 0.75)
	var top := o.height
	fm.block(at(c.x, top - 0.08, c.y), Vector3(o.half.x * 2.0, 0.08, o.half.y * 2.0), 0.0, wood, false)
	for su: float in [-1.0, 1.0]:
		for sv: float in [-1.0, 1.0]:
			fm.block(at(c.x + su * (o.half.x - 0.1), 0.0, c.y + sv * (o.half.y - 0.1)), Vector3(0.1, top - 0.08, 0.1), 0.0, wood, false)
	for k in 3:
		var roll := fm.shaft(at(c.x - o.half.x * 0.5 + k * 0.22, top + 0.06, c.y), 0.06, 0.55, _plain(SCROLL, 0.9))
		roll.basis = Basis(Vector3.RIGHT, PI * 0.5)
		roll.position = at(c.x - o.half.x * 0.5 + k * 0.22, top + 0.06, c.y + 0.27)
	fm.box(at(c.x + o.half.x * 0.35, top + 0.05, c.y), Vector3(0.36, 0.1, 0.48), 0.2, _plain(BOOK_COVERS[1], 0.8), false)
	fm.box(at(c.x + o.half.x * 0.7, top + 0.05, c.y - 0.15), Vector3(0.1, 0.1, 0.1), 0.0, tomb.iron(), false)
	fm.candle(at(c.x + o.half.x * 0.75, top, c.y + 0.2), 0.2, 0.045)
	fm.shaft(at(c.x, 0.0, c.y - o.half.y - 0.45), 0.2, 0.5, wood)


## The facade (spec 3.6): two layers (the front one with the portal's wide embrasure, the inner one with the sheet's
## opening), the arcades open to the vista, the blind niches in the corners with their dark backs, the cornice, the
## arches' rings, the banners on the piers.
func _facade() -> void:
	var mat := ashlar()
	var outer := ORDER_SPAN + ORDER_STEP * (ORDERS - 1) + ORDER_RING.x
	var front: Array[Vector4] = [Vector4(0.0, outer, TERRACE_Y, TERRACE_Y + PORTAL_SPRING)]
	var front_arcs: Array[float] = [ORDER_ARC]
	var inner: Array[Vector4] = [Vector4(0.0, PORTAL_W, TERRACE_Y, TERRACE_Y + PORTAL_SPRING)]
	var inner_arcs: Array[float] = [_portal_arc()]
	for sd: float in [-1.0, 1.0]:
		for c in ARCADES:
			var h := Vector4(sd * c, ARCADE.x + 0.2, ARCADE.y, ARCADE.y + ARCADE.z)
			front.append(h)
			front_arcs.append(ARCADE_ARC)
			inner.append(h)
			inner_arcs.append(ARCADE_ARC)
		for u in NICHES:
			front.append(Vector4(sd * u, NICHE.x + 0.2, CORNER_TOP, CORNER_TOP + NICHE.y))
			front_arcs.append(ARCADE_ARC)
	_wall(true, FACADE_V, FACADE_MID, -FACADE_HALF, FACADE_HALF, FACADE_TOP, front, front_arcs, mat)
	_wall(true, FACADE_MID, FACADE_BACK, -FACADE_HALF, FACADE_HALF, FACADE_TOP, inner, inner_arcs, mat)
	_slab(true, FACADE_V - CORNICE.y, FACADE_MID, -FACADE_HALF, FACADE_HALF, FACADE_TOP - CORNICE.x, FACADE_TOP, mat)
	var dark := m.stone(0.0, NICHE_DARK)
	for sd: float in [-1.0, 1.0]:
		for c in ARCADES:
			fm.voussoir_arch(at(sd * c, ARCADE.y, FACADE_V - 0.1), SOUTH, ARCADE.x, ARCADE.z, ARCADE.w, 0.5, mat, ARCADE_ARC)
			fm.block(at(sd * c, ARCADE.y - 0.12, FACADE_V - 0.15), Vector3(ARCADE.x + 0.5, 0.12, 0.5), 0.0, mat, false)
		# the blind niches: dark backs, arches, the lion on each keystone, a hooded figure before each
		for u in NICHES:
			var n := at(sd * u, CORNER_TOP, FACADE_MID - 0.04)
			fm.block(n, Vector3(NICHE.x + 0.2, NICHE.y + 1.8, 0.08), 0.0, dark, false)
			var apex := fm.voussoir_arch(at(sd * u, CORNER_TOP, FACADE_V - 0.1), SOUTH, NICHE.x, NICHE.y, NICHE.z, 0.5, mat, ARCADE_ARC)
			_keystone(at(sd * u, CORNER_TOP + apex - NICHE.z * 0.6, FACADE_V - 0.38), 0.6)
			if u == NICHES[0]:
				fk.statue(Vector2(sd * u, -(FACADE_V - STATUE_OUT)), 0.0, STATUE_HEIGHT, CORNER_TOP, ArenaKit.STATUE_VALUE, false)
			else:
				# HUB-D (H-P1-4: eight hooded figures alike): the outer niches hold a tall urn on a plinth, candles
				fm.block(at(sd * u, CORNER_TOP, FACADE_V - 0.4), Vector3(1.1, 0.5, 0.7), 0.0, stone())
				fm.urn(at(sd * u, CORNER_TOP + 0.5, FACADE_V - 0.4), 1.5, m.carved(0.0, GLAZES[0] * 1.5), true)
				for k in 2:
					fm.candle(at(sd * u + (k - 0.5) * 0.8, CORNER_TOP + 0.5, FACADE_V - 0.65), 0.18 + 0.06 * k, 0.05)
		for u in BANNERS:
			fk.banner(at(sd * u, BANNER.x, FACADE_V - 0.08), 0.0, Vector2(BANNER.y, BANNER.z), 1, ArenaKit.Emblem.LION)


## The radius of the sheet's pointed head as a share of its width (its apex at PORTAL_H, springing at PORTAL_SPRING).
static func _portal_arc() -> float:
	var rise := PORTAL_H - PORTAL_SPRING
	return (rise * rise + PORTAL_W * PORTAL_W * 0.25) / PORTAL_W / PORTAL_W


## The portal (spec 3.1): the orders of voussoirs on their jambs, the inner ring round the sheet, the dark behind, the
## sheet of light and its lights, the keystone with the lion.
func _portal() -> void:
	var y := TERRACE_Y
	var order := m.ashlar(y, stone_tint() * ORDER_TINT)
	var top := 0.0
	for k in ORDERS:
		var span := ORDER_SPAN + ORDER_STEP * k
		var v: float = ORDER_V[k]
		for sd: float in [-1.0, 1.0]:
			fm.block(at(sd * (span + ORDER_RING.x) * 0.5, y, v), Vector3(ORDER_RING.x, PORTAL_SPRING, ORDER_RING.y), 0.0, order, false)
		top = fm.voussoir_arch(at(0.0, y, v), SOUTH, span, PORTAL_SPRING, ORDER_RING.x, ORDER_RING.y, order, ORDER_ARC)
	var inner_mat := m.stone(y, stone_tint() * INNER_TINT)
	for sd: float in [-1.0, 1.0]:
		fm.block(at(sd * (PORTAL_W + INNER_RING.x) * 0.5, y, INNER_RING.z), Vector3(INNER_RING.x, PORTAL_SPRING, INNER_RING.y), 0.0, inner_mat, false)
	fm.voussoir_arch(at(0.0, y, INNER_RING.z), SOUTH, PORTAL_W, PORTAL_SPRING, INNER_RING.x, INNER_RING.y, inner_mat, _portal_arc())
	var dark := _plain(PORTAL_DARK, 1.0)
	fm.block(at(0.0, y - 0.1, SHEET_V + 0.3), Vector3(PORTAL_W + 0.6, PORTAL_H + 0.3, 0.3), 0.0, dark, false)
	fm.block(at(0.0, y - 0.02, (SHEET_V + FACADE_MID) * 0.5), Vector3(PORTAL_W + 0.2, 0.04, SHEET_V - FACADE_MID + 0.4), 0.0, inner_mat, false)
	var r := _portal_arc() * PORTAL_W
	fk.portal_glow(at(0.0, y + PORTAL_H * 0.5, SHEET_V), 0.0, Vector2(PORTAL_W, PORTAL_H), Vector3(PORTAL_SPRING, PORTAL_W, r))
	var lights: Array = fk.portals[fk.portals.size() - 1]
	station_lights[HubPlan.PORTAL] = lights[1]
	_keystone(at(0.0, y + top - ORDER_RING.x * 0.7, ORDER_V[ORDERS - 1] - ORDER_RING.y * 0.5 - 0.02), KEYSTONE.x)


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


## The terrace and the stairs (spec 3.1): the landing over the stairs, coming forward beside them to the floor's edge,
## the thread of gold on the landing's front, the lion stelae, the braziers and the planters; the corners north of the
## floor a step over it.
func _terrace() -> void:
	var mat := stone()
	fm.stairs(at(0.0, 0.0, STAIRS_FROM), Vector2(0, -1), STAIRS_WIDTH, STAIRS_STEPS, STAIRS_RISE, STAIRS_RUN, mat)
	var half := STAIRS_WIDTH * 0.5
	fm.block(at(0.0, -0.6, (TERRACE_FROM + FACADE_V) * 0.5 + 0.05), Vector3(TERRACE_HALF * 2.0, TERRACE_Y + 0.6, FACADE_V - TERRACE_FROM + 0.1), 0.0, mat, false)
	for sd: float in [-1.0, 1.0]:
		var mid := sd * (half + TERRACE_HALF) * 0.5
		fm.block(at(mid, -0.6, (STAIRS_FROM + TERRACE_FROM) * 0.5), Vector3(TERRACE_HALF - half, TERRACE_Y + 0.6, TERRACE_FROM - STAIRS_FROM), 0.0, ashlar(), false)
		# north of the lobes, a step up, to the facade
		var cu := sd * (TERRACE_HALF + WALL_FACE) * 0.5
		fm.block(at(cu, -0.6, (HubPlan.LOBE.y + FACADE_V) * 0.5), Vector3(WALL_FACE - TERRACE_HALF, CORNER_TOP + 0.6, FACADE_V - HubPlan.LOBE.y), 0.0, mat, false)
		# the terrace's coping along its front and the planter on it
		fm.block(at(mid, TERRACE_Y, STAIRS_FROM + 0.12), Vector3(TERRACE_HALF - half, 0.08, 0.3), 0.0, mat, false)
	_bar(at(0.0, TERRACE_Y + 0.004, TERRACE_FROM + LANDING_FILET), Vector3(STAIRS_WIDTH, 0.008, LANDING_FILET), tomb.gold())
	for p: Vector2 in PLANTERS:
		_planter(p)
	for l: Vector2 in LIONS:
		_lion_stele(l)
	var lights: Array[OmniLight3D] = []
	for b: Vector2 in BRAZIERS:
		lights.append(fk.brazier(Vector2(b.x, -b.y), TERRACE_Y, false, BRAZIER_LIGHT))
	# the braziers burn no shadow (spec 4.3); stylized, they light diffuse (paint_diffuse): their hard-edged pool fell on
	# the facade as round spotlights (art re-review E-2)
	for l in lights:
		l.shadow_enabled = false
		VisualProfile.vary(l, {&"light_specular": 0.0})


## A planter along the terrace's front from p.x to p.y in u: a low box of stone, dark earth and pale flowers.
func _planter(p: Vector2) -> void:
	var v := STAIRS_FROM + 0.3 + PLANTER.x * 0.5
	fm.block(at((p.x + p.y) * 0.5, TERRACE_Y, v), Vector3(p.y - p.x, PLANTER.y, PLANTER.x), 0.0, stone(), false)
	fm.block(at((p.x + p.y) * 0.5, TERRACE_Y + PLANTER.y, v), Vector3(p.y - p.x - 0.16, 0.02, PLANTER.x - 0.16), 0.0, _plain(Color(0.09, 0.07, 0.05), 1.0), false)
	_decal(at((p.x + p.y) * 0.5, TERRACE_Y + PLANTER.y + 0.03, v), Vector2(p.y - p.x - 0.2, PLANTER.x - 0.2), {
		&"kind": 3, &"leaf_dark": FLOWER_EARTH, &"leaf_light": FLOWER_OCHRE, &"litter_cell": 0.11,
		&"litter_size": Vector2(0.06, 0.1), &"litter_cover": 0.55})


## A seated lion on the terrace (the Meshy model of 2026-11-21): the plinth, the lion on it looking at the square and
## turned a little to the stairs, the east one mirrored; candles on the plinth. Nothing collides (the terrace is a view).
func _lion_stele(p: Vector2) -> void:
	var mat := stone()
	var y := TERRACE_Y
	fm.block(at(p.x, y, p.y), Vector3(LION_PLINTH.x, LION_PLINTH.y, LION_PLINTH.z), 0.0, mat)
	y += LION_PLINTH.y
	var mesh := fm.meshy_stone(LION_MODEL)
	if mesh != null:
		var mi := MeshInstance3D.new()
		mi.mesh = mesh
		mi.material_override = fm.carved(y, LION_TINT)
		var side := -signf(p.x)
		mi.transform = Transform3D(Basis(Vector3.UP, side * LION_TURN) * Basis.from_scale(Vector3(-side, 1.0, 1.0) * LION_HEIGHT), at(p.x, y, p.y))
		fm._add(mi)
	for k in 3:
		fm.candle(at(p.x - 0.45 + k * 0.42, TERRACE_Y + LION_PLINTH.y, p.y - LION_PLINTH.z * 0.5 + 0.12), 0.14 + 0.06 * (k % 2), 0.05)


# ---------- the square and the front ----------

## The low balustrade along the south and the cut corners (the arrival's gap open), the arrival stairs down to a closed
## grille.
func _front() -> void:
	var pts := HubPlan.FLOOR
	var mat := see(stone())
	for i in pts.size():
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[(i + 1) % pts.size()]
		if minf(a.y, b.y) > HubPlan.SOUTH + HubPlan.CUT.y - 0.5:
			continue
		# the Retorno's stairs' head (HV-A): open
		if is_equal_approx(a.y, HubPlan.SOUTH) and is_equal_approx(b.y, HubPlan.SOUTH) \
				and minf(a.x, b.x) >= HubPlan.ARRIVAL_STAIRS.x - 0.01 and maxf(a.x, b.x) <= HubPlan.ARRIVAL_STAIRS.y + 0.01:
			continue
		var along := (b - a).normalized()
		var out := Vector2(along.y, -along.x)
		if Geometry2D.is_point_in_polygon((a + b) * 0.5 + out * 0.1, PackedVector2Array(pts)):
			out = -out
		_rail(a + out * RAIL_OUT, b + out * RAIL_OUT, mat)
	# the Retorno's stairs (HV-A, Q-HV2 a): from the open head on the south edge down into the mist, between low walls
	# (H-P2-3: no grille); the seal he comes up onto
	var top := HubPlan.SOUTH
	var su := (HubPlan.ARRIVAL_STAIRS.x + HubPlan.ARRIVAL_STAIRS.y) * 0.5
	var width := HubPlan.ARRIVAL_STAIRS.y - HubPlan.ARRIVAL_STAIRS.x
	var depth := ARRIVAL_STEPS * ARRIVAL_RUN
	var drop := ARRIVAL_STEPS * ARRIVAL_RISE
	fm.stairs(at(su, -drop, top - depth), Vector2(0, -1), width, ARRIVAL_STEPS, ARRIVAL_RISE, ARRIVAL_RUN, stone())
	for sd: float in [-1.0, 1.0]:
		var cu := su + sd * (width + ARRIVAL_CHEEK.x) * 0.5
		fm.block(at(cu, -drop - 0.6, top - depth * 0.5), Vector3(ARRIVAL_CHEEK.x, drop + 0.6 + ARRIVAL_CHEEK.y, depth), 0.0, mat, false)
	var gold := Color(INLAY_GOLD.r * SEAL_GOLD, INLAY_GOLD.g * SEAL_GOLD, INLAY_GOLD.b * SEAL_GOLD)
	_lion(at(HubPlan.ARRIVAL.x, DECAL_Y + 0.002, HubPlan.ARRIVAL.y), Basis(Vector3.RIGHT, -PI * 0.5), SEAL_LION, gold)
	_retorno(su + (width + ARRIVAL_CHEEK.x) * 0.5, top - depth * 0.15)


## HV-C, the Pátio do Retorno (hv_santuario_vigilia_art.md 5): a ring of worn slabs round the seal (SEAL_PAVING),
## faults running across the lion (SEAL_FAULTS: dark joints, no glow, no runes), the paved way from it to the medallion's
## ring; on the east low wall of the stairs a low lamp (RETURN_LAMP: post height, energy, reach; amber, no shadow), so
## the Retorno's pool stays under the stations'. The two braziers at the stairs' head are the arrival's (smaller).
const SEAL_PAVING := Vector3(1.15, 1.75, 1.0)
const SEAL_FAULTS: Array[Vector4] = [Vector4(-0.9, -0.3, 0.7, 0.5), Vector4(-0.2, 0.9, 0.3, -0.8), Vector4(0.4, -0.2, 1.0, -0.6)]
const RETURN_LAMP := Vector3(0.75, 0.8, 3.5)
const RETURN_LAMP_COLOR := Color(0.74, 0.63, 0.48)
func _retorno(cheek_u: float, cheek_v: float) -> void:
	var pave := m.stone(0.0, stone_tint() * PAVE_TINT)
	var kerb := m.stone(0.0, stone_tint() * KERB_TINT)
	var joint := _plain(Color(0.07, 0.065, 0.06), 1.0)
	_pave_ring(HubPlan.ARRIVAL, SEAL_PAVING, pave, joint)
	for f in SEAL_FAULTS:
		var a := HubPlan.ARRIVAL + Vector2(f.x, f.y)
		var b := HubPlan.ARRIVAL + Vector2(f.z, f.w)
		var mid := (a + b) * 0.5
		var d := b - a
		_bar(at(mid.x, DECAL_Y + 0.004, mid.y), Vector3(d.length(), 0.004, 0.035), joint, Basis(Vector3.UP, d.angle()))
	var dir := (MEDALLION - HubPlan.ARRIVAL).normalized()
	_pave_way(HubPlan.ARRIVAL + dir * SEAL_PAVING.y, MEDALLION - dir * MEDALLION_PAVING.y, pave, kerb, joint, _worn_stone())
	# the lamp on the low wall's head, a short iron post with the lantern hanging from its arm
	var ir := tomb.iron()
	var foot := at(cheek_u, ARRIVAL_CHEEK.y, cheek_v)
	_bar(foot + Vector3(0, RETURN_LAMP.x * 0.5, 0), Vector3(0.05, RETURN_LAMP.x, 0.05), ir)
	_bar(foot + Vector3(-0.15, RETURN_LAMP.x, 0), Vector3(0.3, 0.04, 0.04), ir)
	var l := hanging_lantern(frame.transform * (foot + Vector3(-0.28, RETURN_LAMP.x, 0)), ARRIVAL_CHEEK.y + RETURN_LAMP.x - 0.25,
		LANTERN_SIZE * 0.8, Vector2(RETURN_LAMP.y, RETURN_LAMP.z))
	l.light_color = RETURN_LAMP_COLOR
	l.shadow_enabled = false


## A low balustrade from a to b (frame u, v): curb, balusters, rail (spec 3.6: under 0.9 m).
func _rail(a: Vector2, b: Vector2, mat: Material) -> void:
	var length := a.distance_to(b)
	if length < 0.3:
		return
	var d := b - a
	var yaw := atan2(-(-d.y), d.x)
	var mid := (a + b) * 0.5
	fm.box(at(mid.x, RAIL_CURB.x * 0.5, mid.y), Vector3(length, RAIL_CURB.x, RAIL_CURB.y), yaw, mat, false)
	fm.box(at(mid.x, (RAIL_TOP.x + RAIL_TOP.y) * 0.5, mid.y), Vector3(length, RAIL_TOP.y - RAIL_TOP.x, RAIL_CURB.y - 0.06), yaw, mat, false)
	var n := maxi(1, int(length / RAIL_BALUSTER.y))
	for k in n:
		var p := a.lerp(b, (k + 0.5) / n)
		fm.shaft(at(p.x, RAIL_CURB.x, p.y), RAIL_BALUSTER.x, RAIL_TOP.x - RAIL_CURB.x, mat)


## A lamp post on the front (its footprint in the layout): a shaft and an arm out to the south with a lantern hanging
## from it, off the floor.
func _lamp_post(c: Vector2, o: ArenaObstacle) -> void:
	var mat := stone()
	fm.block(at(c.x, 0.0, c.y), Vector3(o.radius * 2.0, 0.35, o.radius * 2.0), 0.0, mat)
	fm.shaft(at(c.x, 0.35, c.y), o.radius * 0.45, LAMP_POST.x - 0.35, mat)
	var ir := tomb.iron()
	_bar(at(c.x, LAMP_POST.x, c.y - LAMP_POST.y * 0.5), Vector3(0.06, 0.06, LAMP_POST.y), ir)
	var from := world(c.x, LAMP_POST.x, c.y - LAMP_POST.y)
	var l := hanging_lantern(from, LAMP_POST.x - 0.3, LANTERN_SIZE, LAMP_LIGHT)
	l.shadow_enabled = false


## The square (spec 3.7): the lion's medallion in old gold with its two rings, the thread of gold on the axis, the use
## points' slabs.
func _square() -> void:
	var g := tomb.gold()
	var mc := at(MEDALLION.x, DECAL_Y, MEDALLION.y)
	_lion(mc + Vector3(0, 0.002, 0), Basis(Vector3.RIGHT, -PI * 0.5), MEDALLION_LION, INLAY_GOLD)
	for ring in MEDALLION_RINGS:
		_ring(mc, ring.x, ring.y, g)
	# the paving (HUB-D): the fountain's ring, the medallion's (clear of the fountain's), the ways to the stations
	var pave := m.stone(0.0, stone_tint() * PAVE_TINT)
	var kerb := m.stone(0.0, stone_tint() * KERB_TINT)
	var joint := _plain(Color(0.07, 0.065, 0.06), 1.0)
	var worn := _worn_stone()
	var fountain := Vector2(HubPlan.FOUNTAIN.x, HubPlan.FOUNTAIN.y)
	_pave_ring(fountain, FOUNTAIN_PAVING, pave, joint)
	_pave_ring(MEDALLION, MEDALLION_PAVING, pave, joint, func(p: Vector2) -> bool:
		return p.distance_to(fountain) < FOUNTAIN_PAVING.y + PAVE_SLAB * 0.6)
	# the ways (HUB-D): the upper stations' from the fountain's ring, the lower ones' from the medallion's, each to the
	# edge of its use slab; the axis from the medallion's ring to the fountain's and on to the portal's slab
	for id in [HubPlan.VENDOR, HubPlan.TREE, HubPlan.SMITH, HubPlan.BOOK]:
		var to: Vector2 = HubPlan.USE[id]
		var from := fountain if to.y > fountain.y else MEDALLION
		var ring := FOUNTAIN_PAVING.y if to.y > fountain.y else MEDALLION_PAVING.y
		var dir := (to - from).normalized()
		_pave_way(from + dir * ring, to - dir * WAY_SHORT, pave, kerb, joint, worn)
	var portal: Vector2 = HubPlan.USE[HubPlan.PORTAL]
	_pave_way(fountain + Vector2(0, FOUNTAIN_PAVING.y), portal - Vector2(0, WAY_SHORT), pave, kerb, joint, worn)
	_pave_way(MEDALLION + Vector2(0, MEDALLION_PAVING.y), fountain - Vector2(0, FOUNTAIN_PAVING.y), pave, kerb, joint, worn)
	# PT-4 (Daniel, 2026-11-23): no lozenges cut at the stations' use spots either; the worn way ends at the station


## A ring of cut slabs round c (frame u, v): ring.z rings from ring.x to ring.y, each slab about PAVE_SLAB along it,
## every other ring turned half a slab, on a dark bed that shows in the joints; a slab whose middle `skip` refuses is
## left out (the bed too, under it).
func _pave_ring(c: Vector2, ring: Vector3, mat: Material, joint: Material, skip := Callable()) -> void:
	var rings := maxi(1, int(ring.z))
	var step := (ring.y - ring.x) / rings
	for k in rings:
		var r := ring.x + step * (k + 0.5)
		var n := maxi(8, roundi(TAU * r / PAVE_SLAB))
		for i in n:
			var a := TAU * (i + 0.5 * (k % 2)) / n
			var p := c + Vector2(cos(a), sin(a)) * r
			if skip.is_valid() and skip.call(p):
				continue
			var yaw := a + PI * 0.5
			fm.box(at(p.x, PAVE_TOP - 0.06, p.y), Vector3(TAU * r / n - 0.07, 0.12, step - 0.07), yaw, mat, false)
			fm.box(at(p.x, PAVE_TOP - 0.035, p.y), Vector3(TAU * r / n + 0.02, 0.06, step + 0.02), yaw, joint, false)


## A paved way from a to b (frame u, v): WAY_WIDTH wide, rows of WAY_SLAB slabs across it in a running bond, a kerb of
## darker stone each side, a dark bed in the joints, the thread of old gold down its middle.
func _pave_way(a: Vector2, b: Vector2, mat: Material, kerb: Material, joint: Material, worn: Material) -> void:
	var d := b - a
	var length := d.length()
	if length < WAY_SLAB.y:
		return
	var dir := d / length
	var side := Vector2(-dir.y, dir.x)
	var yaw := atan2(dir.y, dir.x)
	var inner := WAY_WIDTH - WAY_KERB * 2.0
	var across := maxi(1, roundi(inner / WAY_SLAB.x))
	var w := inner / across
	var rows := maxi(1, roundi(length / WAY_SLAB.y))
	var l := length / rows
	var mid := (a + b) * 0.5
	fm.box(at(mid.x, PAVE_TOP - 0.035, mid.y), Vector3(length, 0.06, WAY_WIDTH), yaw, joint, false)
	for r in rows:
		# running bond: every other row starts with a half slab
		var cuts: Array[float] = [-inner * 0.5]
		var x := -inner * 0.5 + (w * 0.5 if r % 2 == 1 else 0.0)
		while x + w < inner * 0.5 - 0.01:
			x += w
			cuts.append(x)
		if r % 2 == 1:
			cuts.insert(1, -inner * 0.5 + w * 0.5)
		cuts.append(inner * 0.5)
		var along := a + dir * (l * (r + 0.5))
		for k in cuts.size() - 1:
			var cw := cuts[k + 1] - cuts[k]
			if cw < 0.1:
				continue
			var p := along + side * ((cuts[k] + cuts[k + 1]) * 0.5)
			var centre := absf(cuts[k] + cuts[k + 1]) * 0.5 < inner * WORN_SHARE
			var rise := WORN_RISE if centre else 0.0
			fm.box(at(p.x, PAVE_TOP - 0.06 + rise, p.y), Vector3(l - 0.07, 0.12, cw - 0.07), yaw, worn if centre else mat, false)
	var segs := maxi(1, roundi(length / 1.6))
	for sd: float in [-1.0, 1.0]:
		for k in segs:
			var p := a + dir * (length * (k + 0.5) / segs) + side * sd * (WAY_WIDTH - WAY_KERB) * 0.5
			fm.box(at(p.x, PAVE_TOP - 0.05, p.y), Vector3(length / segs - 0.05, 0.13, WAY_KERB - 0.04), yaw, kerb, false)


## The paler stone of a way's walked middle.
func _worn_stone() -> Material:
	return m.stone(0.0, stone_tint() * PAVE_TINT * WORN_TINT)


## A flat ring of old gold on the floor round c (radii r0 to r1).
func _ring(c: Vector3, r0: float, r1: float, mat: Material) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	var n := 64
	for k in n:
		var a0 := TAU * k / n
		var a1 := TAU * (k + 1) / n
		var p := [Vector3(cos(a0) * r0, 0, sin(a0) * r0), Vector3(cos(a0) * r1, 0, sin(a0) * r1),
			Vector3(cos(a1) * r1, 0, sin(a1) * r1), Vector3(cos(a1) * r0, 0, sin(a1) * r0)]
		for i: int in [0, 2, 1, 0, 3, 2]:
			st.add_vertex(p[i])
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	mi.position = c
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(mi)


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


## The fountain of the lion (spec 3.7; decoration, no spring: that is the sign of the rooms' healing fountain): the
## basin's blocks, dark water, the stele on its north rim with the lion's head in relief and the thread of water from
## its mouth, moss with pale flowers round it, candles on the rim.
func _fountain(c: Vector2) -> void:
	var mat := stone()
	var seg := TAU * BASIN.x / BASIN_BLOCKS
	for k in BASIN_BLOCKS:
		var a := TAU * (k + 0.5) / BASIN_BLOCKS
		var p := c + Vector2(cos(a), sin(a)) * BASIN.x
		fm.box(at(p.x, BASIN.y * 0.5, p.y), Vector3(seg * 1.03, BASIN.y, BASIN.z), a + PI * 0.5, mat)
	fm.block(at(c.x, -0.2, c.y), Vector3(BASIN.x * 1.6, 0.2 + WATER_Y - 0.12, BASIN.x * 1.6), 0.0, m.stone(0.0, Color(0.5, 0.5, 0.5)), false)
	# the water: a disc, UV over its square
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	var n := 32
	for k in n:
		for q: Vector2 in [Vector2.ZERO, Vector2(cos(TAU * (k + 1) / n), sin(TAU * (k + 1) / n)), Vector2(cos(TAU * k / n), sin(TAU * k / n))]:
			st.set_uv(q * 0.5 + Vector2(0.5, 0.5))
			st.add_vertex(Vector3(q.x, 0.0, q.y) * WATER_R)
	var water := MeshInstance3D.new()
	water.mesh = st.commit()
	var wm := ShaderMaterial.new()
	wm.shader = WATER_SHADER
	wm.set_shader_parameter(&"form", 0)
	wm.set_shader_parameter(&"size", Vector2.ONE * WATER_R * 2.0)
	wm.set_shader_parameter(&"fade", 0.05)
	wm.set_shader_parameter(&"foam_at", Vector2(0.5, 0.2))
	wm.set_shader_parameter(&"foam_reach", 0.5)
	# P2-A9 of the cycle's art review: broad soft swells, not white veins (it read as marble)
	wm.set_shader_parameter(&"rings", WATER_RINGS.x)
	wm.set_shader_parameter(&"ring_sharp", WATER_RINGS.y)
	wm.set_shader_parameter(&"ring_light", WATER_RINGS.z)
	water.material_override = wm
	wm.set_shader_parameter(&"gloss_roughness", WATER_GLOSS.x)
	wm.set_shader_parameter(&"gloss_specular", WATER_GLOSS.y)
	wm.set_shader_parameter(&"body_light", 0.0)
	VisualProfile.vary(wm, {&"shader": WATER_MATTE, &"shader_parameter/ring_sharp": STY_WATER_RINGS.x,
		&"shader_parameter/ring_light": STY_WATER_RINGS.y, &"shader_parameter/body_light": STY_WATER_BODY,
		&"shader_parameter/gloss_roughness": STY_WATER_GLOSS.x, &"shader_parameter/gloss_specular": STY_WATER_GLOSS.y})
	water.position = at(c.x, WATER_Y, c.y)
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(water)
	# the stele on the north rim and the lion's head on its face
	var sv := c.y + BASIN.x
	fm.block(at(c.x, 0.0, sv), FOUNTAIN_STELE, 0.0, mat)
	fm.point(at(c.x, FOUNTAIN_STELE.y, sv), FOUNTAIN_STELE.x, 0.32, 0.0, 0.0, mat)
	_lion(at(c.x, FOUNTAIN_LION.y, sv - FOUNTAIN_STELE.z * 0.5 - 0.006), Basis(), FOUNTAIN_LION.x, MEDALLION_GOLD)
	var spout := MeshInstance3D.new()
	var q := QuadMesh.new()
	var from := at(c.x, FOUNTAIN_LION.y - FOUNTAIN_LION.x * 0.3, sv - FOUNTAIN_STELE.z * 0.5)
	var to := at(c.x, WATER_Y, sv - 0.75)
	q.size = Vector2(SPOUT, from.distance_to(to))
	spout.mesh = q
	var fall := ShaderMaterial.new()
	fall.shader = WATER_SHADER
	fall.set_shader_parameter(&"form", 1)
	fall.set_shader_parameter(&"size", q.size)
	fall.set_shader_parameter(&"foot", 0.1)
	fall.set_shader_parameter(&"streaks", 1.0)
	spout.material_override = fall
	var down := (to - from).normalized()
	spout.transform = Transform3D(Basis(Vector3.RIGHT, -down, Vector3.RIGHT.cross(-down)), (from + to) * 0.5)
	spout.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(spout)
	_decal(at(c.x, DECAL_Y, c.y), Vector2.ONE * (FOUNTAIN_MOSS.y + 0.9) * 2.0, {&"kind": 1, &"ring": FOUNTAIN_MOSS,
		&"ragged": 0.4, &"north_reach": 0.3, &"flower_pale": FLOWER_OCHRE, &"flower_lilac": FLOWER_EARTH})
	var r := BASIN.x
	for k in 6:
		var a := [0.9, 1.2, 1.95, 2.25, 0.55, 2.6][k] as float
		var p := c + Vector2(cos(a), sin(a)) * r
		if k % 3 == 2:
			fm.candle_out(at(p.x, BASIN.y, p.y), 0.1, 0.05)
		else:
			fm.candle(at(p.x, BASIN.y, p.y), 0.14 + 0.05 * (k % 2), 0.05)


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


## The Forjador's yard west of the forge (HubPlan.YARD; drawn at its rack, hub_yard, the other parts only collide): the
## rack of blades point up and the lion's shield facing the camera, a stone trough of dark water, a heap of coal, a
## grindstone.
func _yard() -> void:
	var c := Vector2(HubPlan.YARD.x, HubPlan.YARD.y)
	var o := ArenaObstacle.new()
	o.half = Vector2(HubPlan.YARD.z, HubPlan.YARD.w)
	var wood := m._wood_mat(0.0, 0.8)
	var ir := tomb.iron()
	# the rack along u at the back of the footprint
	var rv := c.y + o.half.y - 0.3
	var r0 := c.x - o.half.x + 0.3
	var r1 := c.x + o.half.x * 0.2
	for uu: float in [r0, r1]:
		fm.block(at(uu, 0.0, rv), Vector3(0.12, 1.9, 0.12), 0.0, wood, false)
	for h: float in [0.4, 1.5]:
		fm.block(at((r0 + r1) * 0.5, h, rv + 0.02), Vector3(r1 - r0, 0.08, 0.1), 0.0, wood, false)
	for k in 4:
		_blade(at(lerpf(r0, r1, (k + 1.0) / 6.0), 0.48, rv - 0.12), ir, wood)
	var shield := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.48
	disc.bottom_radius = 0.5
	disc.height = 0.07
	disc.radial_segments = 22
	shield.mesh = disc
	shield.material_override = _plain(Color(0.2, 0.16, 0.12), 0.8)
	var su := lerpf(r0, r1, 0.86)
	shield.transform = Transform3D(Basis(Vector3.RIGHT, PI * 0.5), at(su, 1.2, rv - 0.14))
	frame.add_child(shield)
	_lion(at(su, 1.2, rv - 0.19), Basis(), 0.74, MEDALLION_GOLD)
	# the trough before the rack, the coal heap by the forge, the grindstone
	var tu := c.x - o.half.x * 0.35
	var tv := c.y - o.half.y + 0.55
	fm.block(at(tu, 0.0, tv), Vector3(1.8, 0.6, 0.7), 0.0, stone())
	_bar(at(tu, 0.56, tv), Vector3(1.55, 0.02, 0.48), _plain(Color(0.03, 0.05, 0.06), 0.15))
	var coal := _plain(Color(0.05, 0.045, 0.04), 1.0)
	var rr := RandomNumberGenerator.new()
	rr.seed = 913
	for k in 7:
		var p := Vector2(c.x + o.half.x - 0.7 + rr.randf_range(-0.5, 0.5), c.y + rr.randf_range(-0.6, 0.5))
		fm.box(at(p.x, 0.0, p.y), Vector3(rr.randf_range(0.3, 0.55), rr.randf_range(0.15, 0.4), rr.randf_range(0.3, 0.5)), rr.randf() * TAU, coal, false)
	var grind := MeshInstance3D.new()
	var wheel := CylinderMesh.new()
	wheel.top_radius = 0.42
	wheel.bottom_radius = 0.42
	wheel.height = 0.14
	grind.mesh = wheel
	grind.material_override = m.stone(0.0, Color(0.6, 0.58, 0.55))
	grind.transform = Transform3D(Basis(Vector3.FORWARD, PI * 0.5), at(c.x + o.half.x * 0.2, 0.62, tv))
	frame.add_child(grind)
	fm.block(at(c.x + o.half.x * 0.2, 0.0, tv), Vector3(0.5, 0.25, 0.3), 0.0, wood, false)


## A blade standing point up (the Câmara's raised sword, never a cross): the grip and pommel at `foot`, the guard short
## and thin, the blade long and tapering.
func _blade(foot: Vector3, iron: Material, wood: Material) -> void:
	fm.box(foot + Vector3(0, 0.0, 0), Vector3(0.06, 0.06, 0.06), 0.0, iron, false)
	fm.box(foot + Vector3(0, 0.1, 0), Vector3(0.035, 0.16, 0.035), 0.0, wood, false)
	fm.box(foot + Vector3(0, 0.19, 0), Vector3(0.04, 0.035, 0.22), 0.0, iron, false)
	fm.point(foot + Vector3(0, 0.2, 0), 0.07, 0.95, 0.0, 0.0, iron).scale = Vector3(0.35, 1.0, 1.0)


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


## The cascade far left of the portal behind the arcades (spec 3.6): a fall of dark water, ivory-blue streaks.
func _cascade() -> void:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(CASCADE.z, CASCADE.w)
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = WATER_SHADER
	mat.set_shader_parameter(&"form", 1)
	mat.set_shader_parameter(&"size", q.size)
	mat.set_shader_parameter(&"peak", 0.6)
	mi.material_override = mat
	mi.position = at(CASCADE.x, CASCADE.w * 0.5 - 18.0, CASCADE.y)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(mi)


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
