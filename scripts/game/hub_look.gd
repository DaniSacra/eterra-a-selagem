class_name HubLook
extends ArenaRoom
## The hub's look (HUB-01, HUB-B2; plan in HubPlan, space, pieces, light and palette in docs/design/hub_spec_art.md):
## an open courtyard at dusk over the mist. In the hub's own frame (u right on the screen, v up it; HubPlan) and so
## built under one node turned by the camera's yaw (`frame`): the portal high on the axis in a gothic facade (three
## orders of voussoirs, the seal's lion on the keystone, never a star) over a wide flight of stairs and a terrace
## where two lion stelae guard it, an arcade of three arches each side open to the far ruins and a cascade; the side
## walls with the stations' niches; the low balustrade in front with the arrival stairs and two lamp posts. On the
## square the lion's medallion in old gold and the fountain of the lion (decoration: it neither heals nor is used).
## The five stations as pieces (their NPCs are HUB-D's: only their place): the Vendedor's awning with lanterns over
## his counter, the Forjador's furnace in the west wall with the anvil and a rack of blades, the golden Árvore de Dons
## (StoneTree, grown small) on its dais before a blind arch, the Livro de Ahk open on a lectern before a shelf of
## scrolls in the east wall. Every blocking piece is drawn on its footprint in the layout (HubPlan.layout; the same
## data draws and collides); nothing else stands on the walkable floor. The stylized look is the one the hub was made
## for (STYLE: warm limestone, petrol shadow, a lighter and warmer air than any room); the classic one is the same
## build unpainted. No texture of its own (one shader: the book's page, hub_page.gdshader).
## Pending (environment): the masonry and the slabs are mapped in the world, so with the frame turned 35 degrees their
## courses run askew to the walls until the shaders take frame_yaw (technical-artist); the floor's two rings of slabs
## round the medallion need that floor shader too.

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
const FACADE_V := 22.0
const FACADE_MID := 22.85
const FACADE_BACK := 23.7
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
const TERRACE_HALF := 15.0
const TERRACE_FROM := 19.5
const LANDING_FILET := 0.06
## The opening of the portal (its sheet): width, height over the landing, the springing of its pointed head; the sheet's
## plane (v) and the dark behind it.
const PORTAL_W := 3.6
const PORTAL_H := 5.0
const PORTAL_SPRING := 2.2
const SHEET_V := 23.25
const PORTAL_DARK := Color(0.02, 0.05, 0.035)
## The orders round it (spec 3.1: three, recessed): the innermost span, the step of span from one to the next, their
## middles' v (innermost first), the ring (width, depth), their pointed arcs (a share of the span), their stone a little
## lighter; the inner ring round the sheet itself (width, depth, v) and its stone darker.
const ORDERS := 3
const ORDER_SPAN := 4.8
const ORDER_STEP := 0.7
const ORDER_V: Array[float] = [22.7, 22.4, 22.1]
const ORDER_RING := Vector2(0.45, 0.6)
const ORDER_ARC := 0.65
const ORDER_TINT := Color(1.12, 1.12, 1.12)
const INNER_RING := Vector3(0.32, 0.3, 22.95)
const INNER_TINT := Color(0.62, 0.62, 0.62)
## The keystone with the seal's lion in old gold (never a star; spec 3.1): its side and depth.
const KEYSTONE := Vector2(0.9, 0.35)
## The lion stelae on the terrace (spec 3.1, no Meshy): u, v; plinth (width, height, depth); the stele (width, height,
## depth) with the rampant lion in relief on its face (side of the relief); its cap (height, the point over it).
const LIONS: Array[Vector2] = [Vector2(-6.2, 20.6), Vector2(6.2, 20.6)]
const LION_PLINTH := Vector3(1.3, 0.5, 1.1)
const LION_STELE := Vector3(1.0, 1.6, 0.8)
const LION_RELIEF := 0.95
const LION_CAP := Vector2(0.16, 0.5)
const LION_STONE := Color(0.46, 0.43, 0.39)
## The braziers at the stairs' foot on the terrace (u, v) and their light.
const BRAZIERS: Array[Vector2] = [Vector2(-6.4, 17.2), Vector2(6.4, 17.2)]
const BRAZIER_LIGHT := 2.6
## The planters along the terrace's front beside the stairs (from, to u; depth, height) with pale flowers on them.
const PLANTERS: Array[Vector2] = [Vector2(-14.4, -7.6), Vector2(7.6, 14.4)]
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
const LEDGE_WARES: Array[float] = [-8.4, -5.6, 3.6, 6.4]
## The ground in the corners north of the floor, a step over it (top), out of the walkable.
const CORNER_TOP := 0.15
## The banners on the piers between the arcades (u mirrored, top, size).
const BANNERS: Array[float] = [5.3, 16.1]
const BANNER := Vector3(9.8, 1.1, 2.8)

# ---------- the square ----------
## The lion's medallion on the floor (spec 3.7): middle (u, v), the lion's side, its gold; two rings of old gold (outer
## and inner radius of each), how high over the slabs; the thread of gold on the axis (width; it stops at the fountain).
const MEDALLION := Vector2(0.0, -8.0)
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
const BASIN := Vector3(2.0, 0.6, 0.35)
const WATER_Y := 0.48
const WATER_R := 1.84
const FOUNTAIN_STELE := Vector3(1.2, 2.2, 0.42)
const FOUNTAIN_LION := Vector2(0.85, 1.5)
const SPOUT := 0.16
const FOUNTAIN_MOSS := Vector2(2.3, 3.6)
const FLOWER_OCHRE := Color(0.66, 0.58, 0.42)
const FLOWER_EARTH := Color(0.45, 0.32, 0.28)
## The use points' slabs (spec 2.4): grooved lozenges on a 2.4 m square, nothing round.
const USE_SLAB := 2.4
## The great urns' plinth height.
const URN_PLINTH := 0.45
## The square's inlay (the hub is 50 m across: the floor tells its ways): a ring of old gold round the fountain (inner,
## outer radius) and a thread from it toward each side station, stopping this short of its use point.
const SQUARE_RING := Vector2(5.4, 5.55)
const WAY_SHORT := 3.2

# ---------- the stations ----------
## Vendedor (spec 3.2): the awning from the wall (its back's height) to over the counter's front (its front's height),
## along v from, to; the valance under its front edge (height, scallops a metre); its cloth; the lion on it (side); the
## posts at the counter's front corners; two lanterns hanging from the awning (v) and their light (energy, reach); the
## shelves on the wall (heights; from, to v).
const AWNING_BACK := 3.5
const AWNING_FRONT := Vector2(-22.05, 2.75)
const AWNING_V := Vector2(8.1, 12.7)
const VALANCE := Vector2(0.28, 1.6)
const AWNING_CLOTH := Color(0.26, 0.14, 0.1)
## Every other run of the cloth along v a muted ochre (an awning, not a sign); runs a metre.
const AWNING_STRIPE := Color(0.36, 0.29, 0.2)
const AWNING_RUNS := 2.0
const AWNING_LION := 1.1
const POST_R := 0.07
const VENDOR_LANTERNS: Array[float] = [8.9, 11.9]
const LANTERN_LIGHT := Vector2(1.6, 3.5)
const LANTERN_SIZE := Vector3(0.28, 0.42, 0.28)
const VENDOR_SHELVES: Array[float] = [1.25, 1.95]
const VENDOR_SHELF := Vector2(8.4, 12.4)
const COUNTER_CLOTH := Color(0.06, 0.13, 0.14)
## The wares' glazes: amber, ivory, slate blue (never green, cyan nor violet).
const GLAZES: Array[Color] = [Color(0.62, 0.42, 0.2), Color(0.86, 0.82, 0.72), Color(0.42, 0.48, 0.56)]
## Forjador (spec 3.3): the furnace's mouth in the west wall (v, span, sill, springing), the hood over it (height, how far
## out, top), its coals and fire, its light (energy, reach, fall-off; the only fire with a shadow); the anvil's stump and
## iron; the rack of blades on the wall (from, to v).
const FORGE := Vector4(-9.0, 1.7, 0.55, 0.9)
const HOOD := Vector3(2.0, 0.28, 3.2)
const FORGE_LIGHT := Vector3(3.2, 4.5, 1.5)
const FORGE_COLOR := Color(1.0, 0.55, 0.22)
const ANVIL_STUMP := Vector2(0.32, 0.45)
const RACK := Vector2(-6.6, -5.0)
## Árvore de Dons (spec 3.4): the dais's two steps (outer radius, top of each), the tree grown at TREE_SCALE of the
## garden's in old gold, the crown's leaves (from height in the tree's own metres, one card every few points, sizes,
## pale gold), its light (energy, reach, height over the dais).
const DAIS: Array[Vector2] = [Vector2(3.2, 0.25), Vector2(2.6, 0.5)]
const TREE_SCALE := 0.65
const BARK := Color(0.36, 0.29, 0.18)
const BARK_CORD := Color(0.44, 0.36, 0.22)
const BARK_LICHEN := Color(0.34, 0.31, 0.24)
const BARK_FRACTURE := Color(0.52, 0.45, 0.32)
const TREE_ROOTS: Array[float] = [215.0, 290.0, 25.0]
## How far short of the dais's rim the roots end (the tree's metres; they dive past their last point).
const ROOT_SHORT := 2.3
const LEAVES_FROM := 4.6
const LEAVES_EVERY := 2
const LEAF_SIZE := Vector2(1.6, 2.6)
const LEAF_A := Color(0.36, 0.3, 0.17)
const LEAF_B := Color(0.58, 0.5, 0.33)
## Leaves across a card and how much of it the clump fills (the tree is half the garden's: fewer, larger leaves).
const LEAF_COUNT := 5.0
const LEAF_FILL := 0.7
const TREE_LIGHT := Vector3(1.0, 6.0, 4.2)
const TREE_COLOR := Color(1.0, 0.82, 0.5)
## Livro de Ahk (spec 3.5): the lectern's foot and its sloped top (tilt in degrees), the open book (a page's size), the
## ribbon; the shelf of scrolls in a recess of the east wall (v, span, height) with its boards; candles; the rug.
const LECTERN_FOOT := Vector2(0.42, 0.85)
const LECTERN_TILT := 22.0
const PAGE := Vector2(0.42, 0.58)
const RIBBON := Color(0.05, 0.16, 0.17)
const SHELF := Vector3(-8.8, 3.2, 2.7)
const SHELF_BOARDS: Array[float] = [0.75, 1.5, 2.2]
const BOOK_LIGHT := Vector2(1.4, 3.5)
const RUG := Vector2(1.6, 2.2)
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
const ARRIVAL_HALF := 3.0
const ARRIVAL_STEPS := 5
const ARRIVAL_RISE := 0.2
const ARRIVAL_RUN := 0.4
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
const STYLE := {
	&"stone": Color(0.4, 0.375, 0.345), &"floor_stone": Color(0.375, 0.355, 0.325), &"shadow": Color(0.8, 0.9, 0.96),
	&"joint_cold": Color(0.86, 0.93, 0.98), &"slab_paint": Vector2(0.82, 1.18), &"slab_hue": 6.0, &"olive_share": 0.03,
	&"edge_value": 1.0, &"pool_saturation": 0.8, &"metal": true,
	&"fire": {&"candle_range": 3.5, &"candle_gain": 1.2, &"bowl_range": 5.0, &"bowl_gain": 1.1},
	&"air": {&"sky": Color(0.06, 0.08, 0.13), &"fog": Color(0.14, 0.13, 0.13), &"ambient": Color(0.76, 0.76, 0.75),
		&"ambient_gain": 1.55, &"moon": Color(1.0, 0.96, 0.9), &"moon_energy": 0.85, &"moon_shadow": true},
}
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
## The tree that was grown, and each station's own light (HUB-B3 lifts the one in focus).
var tree: StoneTree
var station_lights := {}
var _lion_mats := {}
var _plain_mats := {}
var _far: Array[Node] = []


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


## Every edge a plain cliff under the floor (walls, terrace and balustrade are dressed in the frame).
func edge(a: Vector2, b: Vector2, out: Vector2, _kind: Edge, faces: SurfaceTool) -> void:
	cliff(a, b, out, faces)


## The hub's pieces (hub_*) are drawn in dress() on their footprints, in the frame.
func piece(o: ArenaObstacle) -> void:
	if String(o.piece).begins_with("hub_"):
		return
	super.piece(o)


func _light() -> void:
	key_light(KEY, KEY_ENERGY * (STY_COMPAT_KEY if compat() else 1.0))


func dress() -> void:
	frame = Node3D.new()
	frame.name = "HubFrame"
	frame.transform = Transform3D(Basis(Vector3.UP, deg_to_rad(Feel.live().cam_yaw)), Vector3.ZERO)
	add_child(frame)
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
	_forge()
	var from := get_child_count()
	backdrop(VISTA[0], VISTA[1], VISTA[2])
	_far = added_since(from)
	_cascade()
	# the frame's wood keeps its own colour in the stylized look (paint_look knows only the room's)
	for w: Material in fm._wood.values():
		w.set_meta(ArenaKit.PAINT_OWN, {&"paint_keep": 1.0})
	fm.merge()


func style() -> Dictionary:
	var st := STYLE.duplicate(true)
	if compat():
		st[&"air"][&"ambient_gain"] = float(st[&"air"][&"ambient_gain"]) * STY_COMPAT_AMBIENT
		st[&"air"][&"moon_energy"] = float(st[&"air"][&"moon_energy"]) * STY_COMPAT_MOON
	fk.stylize_metal()
	return st


## The light of a station (HubPlan.STATIONS id; null if it has none).
func station_light(id: StringName) -> Light3D:
	return station_lights.get(id)


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
		if side < 0.0:
			holes.append(FORGE)
			arcs.append(0.5)
		else:
			holes.append(Vector4(SHELF.x, SHELF.y, 0.0, SHELF.z))
			arcs.append(0.0)
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
	_slab(false, u0, side * WALL_FACE, WALL_FROM, HubPlan.NORTH, -0.6, LEDGE_TOP, stone())
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


## A great urn on a square plinth in the square (its footprint), candles at its foot.
func _great_urn(c: Vector2, o: ArenaObstacle) -> void:
	var side := o.radius * 1.9
	fm.block(at(c.x, 0.0, c.y), Vector3(side, URN_PLINTH, side), 0.0, stone())
	fm.urn(at(c.x, URN_PLINTH, c.y), o.height - URN_PLINTH, m.carved(0.0, GLAZES[int(absf(c.x) + absf(c.y)) % GLAZES.size()] * 1.5), true)
	for k in 2:
		fm.candle(at(c.x + side * (0.32 if k == 0 else -0.3), URN_PLINTH, c.y - side * 0.34), 0.16 + 0.08 * k, 0.045)


## The stone benches round the fountain and the flower beds by the arrival, on their footprints (HubPlan).
func _bench(c: Vector2, o: ArenaObstacle) -> void:
	var yaw := deg_to_rad(Feel.live().cam_yaw) + (PI * 0.5 if c.x < 0.0 else -PI * 0.5)
	tomb.bench(o.center, Vector2(o.half.y, o.half.x), yaw, stone())


func _bed(c: Vector2, o: ArenaObstacle) -> void:
	fm.block(at(c.x, 0.0, c.y), Vector3(o.half.x * 2.0, o.height, o.half.y * 2.0), 0.0, stone(), false)
	fm.block(at(c.x, o.height, c.y), Vector3(o.half.x * 2.0 - 0.16, 0.02, o.half.y * 2.0 - 0.16), 0.0, _plain(Color(0.09, 0.07, 0.05), 1.0), false)
	_decal(at(c.x, o.height + 0.03, c.y), Vector2(o.half.x * 2.0 - 0.2, o.half.y * 2.0 - 0.2), {
		&"kind": 3, &"leaf_dark": FLOWER_EARTH, &"leaf_light": FLOWER_OCHRE, &"litter_cell": 0.11,
		&"litter_size": Vector2(0.06, 0.1), &"litter_cover": 0.55})


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
			fk.statue(Vector2(sd * u, -(FACADE_V - STATUE_OUT)), 0.0, STATUE_HEIGHT, CORNER_TOP, ArenaKit.STATUE_VALUE, false)
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
		# the corner north of the floor, a step up, to the wall
		var cu := sd * (TERRACE_HALF + WALL_FACE) * 0.5
		fm.block(at(cu, -0.6, (STAIRS_FROM + FACADE_V) * 0.5), Vector3(WALL_FACE - TERRACE_HALF, CORNER_TOP + 0.6, FACADE_V - STAIRS_FROM), 0.0, mat, false)
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
	# the braziers burn no shadow (spec 4.3)
	for l in lights:
		l.shadow_enabled = false


## A planter along the terrace's front from p.x to p.y in u: a low box of stone, dark earth and pale flowers.
func _planter(p: Vector2) -> void:
	var v := STAIRS_FROM + 0.3 + PLANTER.x * 0.5
	fm.block(at((p.x + p.y) * 0.5, TERRACE_Y, v), Vector3(p.y - p.x, PLANTER.y, PLANTER.x), 0.0, stone(), false)
	fm.block(at((p.x + p.y) * 0.5, TERRACE_Y + PLANTER.y, v), Vector3(p.y - p.x - 0.16, 0.02, PLANTER.x - 0.16), 0.0, _plain(Color(0.09, 0.07, 0.05), 1.0), false)
	_decal(at((p.x + p.y) * 0.5, TERRACE_Y + PLANTER.y + 0.03, v), Vector2(p.y - p.x - 0.2, PLANTER.x - 0.2), {
		&"kind": 3, &"leaf_dark": FLOWER_EARTH, &"leaf_light": FLOWER_OCHRE, &"litter_cell": 0.11,
		&"litter_size": Vector2(0.06, 0.1), &"litter_cover": 0.55})


## A lion stele on the terrace (spec 3.1, no Meshy): plinth, the stele with the seal's rampant lion in relief on its
## face, a lion's head of chamfered blocks on top (mane, head, muzzle, ears), facing the square; candles on the plinth.
func _lion_stele(p: Vector2) -> void:
	var mat := stone()
	var y := TERRACE_Y
	fm.block(at(p.x, y, p.y), Vector3(LION_PLINTH.x, LION_PLINTH.y, LION_PLINTH.z), 0.0, mat)
	y += LION_PLINTH.y
	fm.block(at(p.x, y, p.y), LION_STELE, 0.0, mat)
	_lion(at(p.x, y + LION_STELE.y * 0.55, p.y - LION_STELE.z * 0.5 - 0.006), Basis(), LION_RELIEF, LION_STONE)
	y += LION_STELE.y
	# a stepped cap and a ball finial (the lion is the relief, spec 3.1; no carved head)
	fm.block(at(p.x, y, p.y), Vector3(LION_STELE.x + 0.2, LION_CAP.x, LION_STELE.z + 0.2), 0.0, mat)
	fm.point(at(p.x, y + LION_CAP.x, p.y), LION_STELE.x * 0.8, LION_CAP.y, 0.0, 0.0, mat)
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
		var along := (b - a).normalized()
		var out := Vector2(along.y, -along.x)
		if Geometry2D.is_point_in_polygon((a + b) * 0.5 + out * 0.1, PackedVector2Array(pts)):
			out = -out
		var length := a.distance_to(b)
		var runs: Array[Vector2] = [Vector2(0.0, length)]
		if absf(a.y - b.y) < 0.01:
			# the arrival's gap in the south edge
			var s_gap := (Vector2(-ARRIVAL_HALF, a.y) - a).dot(along)
			var e_gap := (Vector2(ARRIVAL_HALF, a.y) - a).dot(along)
			runs = [Vector2(0.0, minf(s_gap, e_gap)), Vector2(maxf(s_gap, e_gap), length)]
		for run in runs:
			_rail(a + along * run.x + out * RAIL_OUT, a + along * run.y + out * RAIL_OUT, mat)
	# the arrival stairs down to the grille
	var south := HubPlan.FLOOR[0].y
	var depth := ARRIVAL_STEPS * ARRIVAL_RUN
	fm.stairs(at(0.0, -ARRIVAL_STEPS * ARRIVAL_RISE, south - depth), Vector2(0, -1), ARRIVAL_HALF * 2.0, ARRIVAL_STEPS, ARRIVAL_RISE, ARRIVAL_RUN, stone())
	for sd: float in [-1.0, 1.0]:
		fm.block(at(sd * (ARRIVAL_HALF + 0.25), -1.6, south - depth * 0.5), Vector3(0.5, 1.6 + RAIL_CURB.x, depth), 0.0, mat, false)
	var ir := tomb.iron()
	var gy := -ARRIVAL_STEPS * ARRIVAL_RISE
	var gv := south - depth - 0.1
	for y: float in [gy + 0.1, gy + 0.85]:
		_bar(at(0.0, y, gv), Vector3(ARRIVAL_HALF * 2.0, 0.06, 0.06), ir)
	var n := int(ARRIVAL_HALF * 2.0 / 0.28)
	for k in n + 1:
		_bar(at(-ARRIVAL_HALF + k * ARRIVAL_HALF * 2.0 / n, gy + 0.45, gv), Vector3(0.04, 0.9, 0.04), ir)


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
	var outer := MEDALLION_RINGS[0].y
	for span: Vector2 in [Vector2(MEDALLION.y + outer, -BASIN.x - BASIN.z), Vector2(BASIN.x + BASIN.z, STAIRS_FROM)]:
		_bar(at(0.0, DECAL_Y * 0.5, (span.x + span.y) * 0.5), Vector3(AXIS_FILET, 0.008, span.y - span.x), g)
	_ring(at(0.0, DECAL_Y, 0.0), SQUARE_RING.x, SQUARE_RING.y, g)
	for id in [HubPlan.VENDOR, HubPlan.TREE, HubPlan.SMITH, HubPlan.BOOK]:
		var to: Vector2 = HubPlan.USE[id]
		var from := to.normalized() * SQUARE_RING.y
		var end := to - to.normalized() * WAY_SHORT
		var mid := (from + end) * 0.5
		var d := end - from
		_bar(at(mid.x, DECAL_Y * 0.5, mid.y), Vector3(d.length(), 0.008, AXIS_FILET), g, Basis(Vector3.UP, atan2(d.y, d.x)))
	for id in HubPlan.STATIONS:
		var p: Vector2 = HubPlan.USE[id]
		_decal(at(p.x, DECAL_Y, p.y), Vector2(USE_SLAB, USE_SLAB), {&"kind": 4, &"lozenges": Vector3(0.8, 1.55, 2.3),
			&"groove_width": 0.07, &"groove_color": Color(0.16, 0.14, 0.12), &"groove_lip": Color(0.5, 0.46, 0.4),
			&"groove_worn": 0.15})


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
	water.material_override = wm
	water.position = at(c.x, WATER_Y, c.y)
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(water)
	# the stele on the north rim and the lion's head on its face
	var sv := c.y + BASIN.x
	fm.block(at(c.x, 0.0, sv), FOUNTAIN_STELE, 0.0, mat)
	fm.point(at(c.x, FOUNTAIN_STELE.y, sv), FOUNTAIN_STELE.x, 0.32, 0.0, 0.0, mat)
	_lion(at(c.x, FOUNTAIN_LION.y, sv - FOUNTAIN_STELE.z * 0.5 - 0.006), Basis(), FOUNTAIN_LION.x, LION_STONE)
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

## The Vendedor (spec 3.2): the counter (its footprint) under a cloth of petrol, wares on it and on shelves on the wall,
## the awning of rust earth with the lion in old gold over posts at the counter's front, two lanterns hanging from it.
## The vendor himself stands behind it (HUB-D).
func _vendor(c: Vector2, o: ArenaObstacle) -> void:
	var size := Vector3(o.half.x * 2.0, o.height, o.half.y * 2.0)
	fm.crate(at(c.x, 0.0, c.y), size, 0.0)
	var front := c.x + size.x * 0.5 + 0.01
	var cloth := _decal(at(front, size.y * 0.5, c.y), Vector2(size.z * 0.94, size.y * 0.8), {&"kind": 0,
		&"cloth": COUNTER_CLOTH, &"border": Color(0.18, 0.14, 0.09)}, Basis(Vector3.FORWARD, -PI * 0.5) * Basis(Vector3.UP, PI * 0.5))
	cloth.name = "CounterCloth"
	var r := RandomNumberGenerator.new()
	r.seed = 311
	_wares(Vector2(c.x - 0.1, c.y - size.z * 0.42), Vector2(c.x - 0.1, c.y + size.z * 0.42), size.y, 7, r)
	for h in VENDOR_SHELVES:
		fm.block(at(-WALL_FACE + 0.18, h - 0.06, (VENDOR_SHELF.x + VENDOR_SHELF.y) * 0.5), Vector3(0.36, 0.06, VENDOR_SHELF.y - VENDOR_SHELF.x), 0.0, m._wood_mat(0.0, 1.0), false)
		_wares(Vector2(-WALL_FACE + 0.15, VENDOR_SHELF.x + 0.2), Vector2(-WALL_FACE + 0.15, VENDOR_SHELF.y - 0.2), h, 8, r)
	# posts at the counter's front corners, up to the awning
	var wood := m._wood_mat(0.0, 0.8)
	for v: float in [c.y - size.z * 0.5 + 0.08, c.y + size.z * 0.5 - 0.08]:
		fm.shaft(at(front - 0.09, size.y, v), POST_R, AWNING_FRONT.y - size.y, wood)
	_awning()
	var lights: Array[OmniLight3D] = []
	for v in VENDOR_LANTERNS:
		lights.append(hanging_lantern(world(c.x + 0.25, AWNING_FRONT.y + 0.25, v), AWNING_FRONT.y - 0.4, LANTERN_SIZE, LANTERN_LIGHT))
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


## The awning (spec 3.2): a cloth from the wall over the counter, a scalloped valance under its front, the lion on it.
func _awning() -> void:
	var back := Vector3(-WALL_FACE, AWNING_BACK, 0.0)
	var frontp := Vector3(AWNING_FRONT.x, AWNING_FRONT.y, 0.0)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var v0 := AWNING_V.x
	var v1 := AWNING_V.y
	var rows := 6
	var cols := int((v1 - v0) * AWNING_RUNS) * 2
	for i in rows:
		for j in cols:
			var quad: Array[Vector3] = []
			for d: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)]:
				var t := float(i + d.x) / rows
				var s := float(j + d.y) / cols
				var p := back.lerp(frontp, t)
				# a soft sag between the posts
				p.y -= sin(PI * t) * 0.12 + sin(PI * s) * 0.08 * t
				quad.append(at(p.x, p.y, lerpf(v0, v1, s)))
			st.set_color(AWNING_CLOTH if (j / 2) % 2 == 0 else AWNING_STRIPE)
			for idx: int in [0, 1, 2, 0, 2, 3]:
				st.add_vertex(quad[idx])
	# the valance: scallops hanging under the front edge
	var n := int((v1 - v0) * VALANCE.y)
	for k in n:
		var s0 := lerpf(v0, v1, float(k) / n)
		var s1 := lerpf(v0, v1, float(k + 1) / n)
		var seg := 6
		for q in seg:
			var a0 := lerpf(s0, s1, float(q) / seg)
			var a1 := lerpf(s0, s1, float(q + 1) / seg)
			var d0 := VALANCE.x + sin(PI * q / seg) * 0.1
			var d1 := VALANCE.x + sin(PI * (q + 1) / seg) * 0.1
			var y := AWNING_FRONT.y - 0.04
			st.set_color(AWNING_CLOTH)
			var quad2: Array[Vector3] = [at(frontp.x, y, a0), at(frontp.x, y, a1), at(frontp.x, y - d1, a1), at(frontp.x, y - d0, a0)]
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
	# the lion on the cloth's slope, a little over it
	var mid := back.lerp(frontp, 0.55)
	var slope := (frontp - back).normalized()
	var normal := Vector3(-slope.y, slope.x, 0.0)
	if normal.y < 0.0:
		normal = -normal
	var vmid := (v0 + v1) * 0.5
	# upright on the screen: its up along the frame's v, its face along the cloth's normal
	var up := Vector3(0, 0, -1)
	var basis := Basis(up.cross(normal), up, normal)
	_lion(at(mid.x, mid.y - sin(PI * 0.55) * 0.12 + 0.03, vmid) + normal * 0.02, basis, AWNING_LION, MEDALLION_GOLD)


## The Forjador's furnace (spec 3.3): in its mouth in the west wall a hearth with the coals and a low fire, its back dark
## and soot black, the round arch on the wall's face and the hood over it, the forge's light (the only fire with a
## shadow); the rack of blades and the lion's shield along the wall.
func _forge() -> void:
	var v := FORGE.x
	var mat := ashlar()
	var soot := m.stone(0.0, Color(0.25, 0.22, 0.2))
	fm.block(at(-WALL_BACK + 0.15, FORGE.z - 0.6, v), Vector3(0.3, FORGE.w + 1.4, FORGE.y + 0.2), 0.0, soot, false)
	var foot := at(-WALL_FACE + 0.05, FORGE.z, v)
	fm.voussoir_arch(foot, EAST, FORGE.y, FORGE.w, 0.28, 0.4, mat, 0.5)
	# the hood: a sloped block over the arch, out to the floor's edge
	fm.block(at(-WALL_FACE + HOOD.y * 0.5 - 0.05, FORGE.z + FORGE.w + FORGE.y * 0.5 + 0.35, v), Vector3(HOOD.y + 0.1, 0.25, HOOD.x), 0.0, mat, false)
	var hood := fm.point(at(-WALL_FACE + 0.05, FORGE.z + FORGE.w + FORGE.y * 0.5 + 0.6, v), HOOD.x, HOOD.z - FORGE.w - FORGE.y * 0.5 - 0.6, 0.0, 0.0, mat)
	hood.scale = Vector3(0.3, 1.0, 1.0)
	var coals := MeshInstance3D.new()
	var bed := PlaneMesh.new()
	bed.size = Vector2(1.0, FORGE.y - 0.3)
	coals.mesh = bed
	coals.material_override = fk._coals()
	coals.position = at(-(WALL_FACE + WALL_BACK) * 0.5, FORGE.z + 0.03, v)
	coals.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(coals)
	fk.fire(at(-(WALL_FACE + WALL_BACK) * 0.5 - 0.1, FORGE.z + 0.02, v), 0.35, 12, 0.32, 0.55)
	var l := OmniLight3D.new()
	l.position = at(-WALL_FACE + 0.6, FORGE.z + 0.8, v)
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
	# the rack: two posts and two rails against the wall, three blades standing point up, the lion's shield
	var wood := m._wood_mat(0.0, 0.8)
	var u := -WALL_FACE + 0.12
	for vv: float in [RACK.x, RACK.y]:
		fm.block(at(u, 0.0, vv), Vector3(0.1, 1.5, 0.1), 0.0, wood, false)
	for h: float in [0.35, 1.2]:
		fm.block(at(u + 0.02, h, (RACK.x + RACK.y) * 0.5), Vector3(0.08, 0.07, RACK.y - RACK.x), 0.0, wood, false)
	var ir := tomb.iron()
	for k in 3:
		var bv := lerpf(RACK.x, RACK.y, (k + 1.0) / 5.0)
		_blade(at(u + 0.12, 0.42, bv), ir, wood)
	var shield := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.36
	disc.bottom_radius = 0.38
	disc.height = 0.06
	disc.radial_segments = 20
	shield.mesh = disc
	shield.material_override = _plain(Color(0.2, 0.16, 0.12), 0.8)
	var sv := lerpf(RACK.x, RACK.y, 0.82)
	shield.transform = Transform3D(Basis(Vector3.FORWARD, PI * 0.5), at(u + 0.14, 0.95, sv))
	frame.add_child(shield)
	_lion(at(u + 0.18, 0.95, sv), Basis(Vector3.UP, PI * 0.5), 0.56, MEDALLION_GOLD)


## A blade standing point up (the Câmara's raised sword, never a cross): the grip and pommel at `foot`, the guard short
## and thin, the blade long and tapering.
func _blade(foot: Vector3, iron: Material, wood: Material) -> void:
	fm.box(foot + Vector3(0, 0.0, 0), Vector3(0.06, 0.06, 0.06), 0.0, iron, false)
	fm.box(foot + Vector3(0, 0.1, 0), Vector3(0.035, 0.16, 0.035), 0.0, wood, false)
	fm.box(foot + Vector3(0, 0.19, 0), Vector3(0.04, 0.035, 0.22), 0.0, iron, false)
	fm.point(foot + Vector3(0, 0.2, 0), 0.07, 0.95, 0.0, 0.0, iron).scale = Vector3(0.35, 1.0, 1.0)


## The anvil (spec 3.3) on its footprint: a stump of wood, the iron body and face, the horn.
func _anvil(c: Vector2, o: ArenaObstacle) -> void:
	var wood := m._wood_mat(0.0, 0.8)
	fm.shaft(at(c.x, 0.0, c.y), ANVIL_STUMP.x, ANVIL_STUMP.y, wood)
	var ir := tomb.iron()
	var y := ANVIL_STUMP.y
	_bar(at(c.x, y + 0.12, c.y), Vector3(0.36, 0.24, 0.5), ir)
	_bar(at(c.x, y + 0.3, c.y), Vector3(0.24, 0.14, 0.34), ir)
	_bar(at(c.x, o.height - 0.06, c.y + 0.05), Vector3(0.34, 0.12, 0.66), ir)
	var horn := _bar(at(c.x, o.height - 0.08, c.y - 0.42), Vector3(0.2, 0.1, 0.26), ir)
	horn.scale = Vector3(0.7, 0.8, 1.0)


## The Árvore de Dons (spec 3.4): the dais of two octagonal steps on its footprint, the garden's stone tree grown at
## TREE_SCALE in old gold (no crystals, gold veins), pale gold leaves in its crown, its warm light.
func _tree(c: Vector2, o: ArenaObstacle) -> void:
	var mat := stone()
	for k in DAIS.size():
		var pts := PackedVector2Array()
		for i in 8:
			var a := TAU * (i + 0.5) / 8.0
			var p := c + Vector2(cos(a), sin(a)) * DAIS[k].x
			pts.append(Vector2(p.x, -p.y))
		fm.prism(pts, DAIS[k - 1].y if k > 0 else -0.6, DAIS[k].y, mat)
	var top := DAIS[DAIS.size() - 1].y
	var holder := Node3D.new()
	holder.name = "GiftTree"
	holder.transform = Transform3D(Basis.from_scale(Vector3.ONE * TREE_SCALE), world(c.x, top, c.y))
	add_child(holder)
	var roots: Array[PackedVector2Array] = []
	for b in TREE_ROOTS:
		var w := StoneTree.toward(b)
		roots.append(PackedVector2Array([w * 2.4, w * 3.2, w * (o.radius / TREE_SCALE - ROOT_SHORT)]))
	tree = StoneTree.new()
	tree.build(holder, Vector2.ZERO, roots, 0.0, 19)
	var crystals := holder.get_node_or_null("StoneTreeCrystals")
	if crystals != null:
		holder.remove_child(crystals)
		crystals.free()
	var sm := tree.stone_material
	sm.set_shader_parameter(&"base_color", BARK)
	sm.set_shader_parameter(&"cord_color", BARK_CORD)
	sm.set_shader_parameter(&"lichen_color", BARK_LICHEN)
	sm.set_shader_parameter(&"fracture_color", BARK_FRACTURE)
	sm.set_shader_parameter(&"vein_color", MEDALLION_GOLD)
	sm.set_shader_parameter(&"vein_light", 0.0)
	_leaves(holder)
	var l := OmniLight3D.new()
	l.position = world(c.x, top + TREE_LIGHT.z, c.y)
	l.light_color = TREE_COLOR
	l.light_energy = TREE_LIGHT.x
	l.omni_range = TREE_LIGHT.y
	l.light_cull_mask = ~Arena.CROWD_LAYER
	l.set_meta(ArenaKit.NOT_FIRE, true)
	add_child(l)
	station_lights[HubPlan.TREE] = l


## The crown's leaves: cards on the crown's high points facing the camera (the garden's canopy), pale gold.
func _leaves(holder: Node3D) -> void:
	var spots: Array[Vector3] = []
	for k in tree.crown.size():
		if tree.crown[k].y >= LEAVES_FROM and k % LEAVES_EVERY == 0:
			spots.append(tree.crown[k])
	if spots.is_empty():
		return
	var q := QuadMesh.new()
	q.size = Vector2.ONE
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = q
	mm.instance_count = spots.size()
	var r := RandomNumberGenerator.new()
	r.seed = 5113
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	for i in spots.size():
		var size := r.randf_range(LEAF_SIZE.x, LEAF_SIZE.y)
		var basis := Basis(Vector3.UP, yaw + r.randf_range(-0.5, 0.5)) * Basis(Vector3.BACK, r.randf() * TAU) * Basis.from_scale(Vector3(size, size, 1.0))
		mm.set_instance_transform(i, Transform3D(basis, spots[i] + Vector3(r.randf_range(-0.5, 0.5), r.randf_range(-0.2, 0.6), r.randf_range(-0.5, 0.5))))
		mm.set_instance_custom_data(i, Color(r.randf(), 0, 0, 0))
	var mat := ShaderMaterial.new()
	mat.shader = CANOPY_SHADER
	mat.set_shader_parameter(&"leaf_a", LEAF_A)
	mat.set_shader_parameter(&"leaf_b", LEAF_B)
	mat.set_shader_parameter(&"leaves", LEAF_COUNT)
	mat.set_shader_parameter(&"fill", LEAF_FILL)
	var mi := MultiMeshInstance3D.new()
	mi.name = "Leaves"
	mi.multimesh = mm
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(mi)


## The Livro de Ahk (spec 3.5): the lectern on its footprint (a stone foot, a sloped top of wood toward the reader), the
## book open on it (two pages, the petrol ribbon), candles; the shelf of scrolls and closed books in the east wall's
## recess with a ladder; the rug before it. Ahk has no figure.
func _book(c: Vector2, o: ArenaObstacle) -> void:
	var mat := stone()
	fm.block(at(c.x, 0.0, c.y), Vector3(LECTERN_FOOT.x * 1.4, 0.12, LECTERN_FOOT.x * 1.6), 0.0, mat)
	fm.block(at(c.x, 0.12, c.y), Vector3(LECTERN_FOOT.x, LECTERN_FOOT.y - 0.12, LECTERN_FOOT.x), 0.0, mat)
	# the top rises toward +u (away from the reader at the use point)
	var tilt := Basis(Vector3.BACK, deg_to_rad(LECTERN_TILT))
	var top_y := o.height - 0.1
	var wood := m._wood_mat(0.0, 0.9)
	var desk := fm.box(at(c.x, top_y, c.y), Vector3(o.half.x * 2.0, 0.06, o.half.y * 2.0), 0.0, wood, false)
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
		page.transform = Transform3D(lay, at(c.x, top_y, c.y) + tilt * Vector3(0, 0.05, 0) + Vector3(0, 0, -sd * PAGE.x * 0.5))
		page.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		frame.add_child(page)
	_bar(at(c.x, top_y - 0.2, c.y) + tilt * Vector3(-o.half.x + 0.02, 0, 0), Vector3(0.01, 0.4, 0.04), _plain(RIBBON, 0.9))
	for k in 3:
		fm.candle(at(c.x + 0.1, 0.12, c.y + LECTERN_FOOT.x * 0.55 - k * 0.12), 0.18 + 0.08 * (k % 2), 0.045)
	_decal(at(c.x, DECAL_Y, c.y), RUG, {&"kind": 0, &"cloth": Color(0.07, 0.14, 0.15), &"border": Color(0.26, 0.17, 0.11)})
	# the shelf in the east wall's recess
	var sv := SHELF.x
	var back := fm.block(at(WALL_BACK - 0.15, -0.1, sv), Vector3(0.3, SHELF.z + 0.2, SHELF.y + 0.1), 0.0, m.stone(0.0, Color(0.45, 0.42, 0.4)), false)
	back.name = "ShelfBack"
	var r := RandomNumberGenerator.new()
	r.seed = 4421
	var inner := (WALL_FACE + WALL_BACK) * 0.5 - 0.1
	for h in SHELF_BOARDS:
		fm.block(at(inner, h - 0.05, sv), Vector3(WALL_BACK - WALL_FACE - 0.3, 0.05, SHELF.y - 0.1), 0.0, wood, false)
		var vv := sv - SHELF.y * 0.45
		while vv < sv + SHELF.y * 0.45:
			if r.randf() < 0.45:
				var roll := fm.shaft(at(inner + 0.05, h + 0.06, vv), 0.06, 0.5, _plain(SCROLL, 0.9))
				roll.basis = Basis(Vector3.BACK, PI * 0.5)
				roll.position = at(inner + 0.05, h + 0.06, vv)
				vv += 0.14
			else:
				var hb := r.randf_range(0.24, 0.36)
				var tb := r.randf_range(0.05, 0.1)
				fm.box(at(inner + 0.05, h + hb * 0.5, vv), Vector3(0.36, hb, tb), r.randf_range(-0.05, 0.05), _plain(BOOK_COVERS[r.randi() % BOOK_COVERS.size()], 0.8), false)
				vv += tb + 0.015
		if h > 1.0:
			fm.candle(at(WALL_FACE + 0.2, h, sv + SHELF.y * (0.3 if h > 2.0 else -0.35)), 0.16, 0.045)
	# the ladder leaning on the shelf
	for sd: float in [-1.0, 1.0]:
		var rail := fm.box(at(WALL_FACE - 0.05, 1.2, sv + SHELF.y * 0.3 + sd * 0.2), Vector3(0.05, 2.5, 0.05), 0.0, wood, false)
		rail.basis = Basis(Vector3.BACK, -0.2)
	var l := warm_light(world(WALL_FACE - 1.4, 1.6, sv + 0.3), BOOK_LIGHT.x, false, BOOK_LIGHT.y)
	station_lights[HubPlan.BOOK] = l


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
