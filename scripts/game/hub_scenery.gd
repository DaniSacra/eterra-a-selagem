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
const VINE_GREEN := Color("94A76A")
const WATER_BLUE := Color("527F8C")
const OLD_GOLD := Color("B68A48")
const SUN_WARM := Color("F4DBAB")
const TERRACOTTA := Color(1.7, 0.7, 0.42)
const IRON := Color(0.1, 0.1, 0.11)
const WISTERIA_A := Color(0.36, 0.22, 0.48)
const WISTERIA_B := Color(0.66, 0.5, 0.76)
const LEAF_DARK := Color(0.2, 0.3, 0.14)
const LEAF_LIGHT := Color(0.42, 0.54, 0.26)
const TREE_DARK := Color(0.22, 0.34, 0.16)
const TREE_LIGHT := Color(0.5, 0.62, 0.3)
const RED_LEAF_A := Color(0.46, 0.08, 0.1)
const RED_LEAF_B := Color(0.84, 0.26, 0.16)
const MAGENTA_A := Color(0.46, 0.12, 0.34)
const MAGENTA_B := Color(0.86, 0.46, 0.7)
const WINDOW_GLOW := Color(1.0, 0.72, 0.38)

# ---------- roofs, windows, corners ----------
## Eaves out of the wall, the rise as a share of the short side (and its limits), the fascia's thickness.
const EAVE := 0.5
const ROOF_RISE := Vector3(0.3, 0.9, 1.5)
const FASCIA := 0.12
const CORNER_STONE := Vector2(0.45, 0.2)  # width and how far it stands out
## A window: width, sill height (low houses: the second), height cap, frame and glass depth, how far from the wall.
const WINDOW := Vector4(0.85, 1.25, 1.7, 0.16)
const WINDOW_LOW_SILL := 0.9
const WINDOW_EVERY := 3.4
const WINDOW_CLEAR := Vector2(1.3, 0.9)  # how far from a door or a piece along the wall, and out from it
const GLASS_GLOW := 1.35
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
const ARCH_SPRING := 2.2
const ARCH_RING := 0.4
const ARCH_FOOT := -6.2
const FALL_SHADER := preload("res://assets/shaders/waterfall.gdshader")
## The falls: u, v of the cliff face they hang on, width, drop (from just under the lip).
const FALLS: Array[Vector4] = [Vector4(16.4, -15.7, 2.6, 9.0), Vector4(22.0, -15.7, 2.6, 9.0), Vector4(28.1, -13.6, 2.4, 8.0),
	Vector4(35.5, -12.2, 2.6, 10.0)]
const FALL_TURN := 0.0
## Balustrades along the edges that look over the drop (a, b in u, v), inset from the floor's edge.
const RAILS: Array[Vector4] = [
	Vector4(-28.7, -12.75, -19.3, -12.75), Vector4(7.0, -15.25, 25.7, -15.25), Vector4(7.6, -10.75, 23.6, -10.75),
	Vector4(30.4, -11.75, 36.4, -11.75),
]

# ---------- pergola (the Videira) ----------
const PERGOLA_POSTS := Vector4(-11.0, -2.0, -0.6, 3.4)  # u0, u1, v0, v1
const PERGOLA_HEIGHT := 2.9
const PERGOLA_COLUMNS := 3
const RAFTER := Vector2(0.9, 0.12)  # every, thickness
const RAFTER_WOOD := Color(0.3, 0.19, 0.11)

# ---------- the gate's frame and light ----------
const GATE_FRAME := Vector3(2.4, 2.6, 6.2)  # how far west of the face, half the way's width, pillar height
const GATE_LIGHT := Vector2(5.0, 16.0)
const GATE_LIGHT_COLOR := Color(1.0, 0.78, 0.38)

# ---------- the Ponto de Vigília and the future rooms ----------
const VIGIL_FLAME := Vector3(-22.6, 0.0, -10.2)
const FUTURE_YARDS: Array[Vector4] = [Vector4(-21.0, -26.0, -8.0, -17.0), Vector4(-1.0, -26.0, 12.0, -17.0)]
const YARD_DROP := 1.2
const YARD_STEPS := 3
const YARD_WALL := Vector2(0.5, 1.1)
const YARD_FLOOR := Color(0.5, 0.47, 0.41)

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
const GARDEN_CYPRESS_EDGE := 1.3
## The fountain on the Videira's bed (the middle of the pergola): basin radius, rim height, water radius, pedestal radius.
const FOUNTAIN_BASIN := Vector4(1.55, 0.26, 1.36, 0.3)
const FOUNTAIN_RIM_BLOCKS := 14
const FOUNTAIN_FALLS := 8
## Low balustrades along the outer edges that look at the camera or the sides (the art's low creamy wall with its
## lanterns): inset from the edge, share of the usual height, shortest run, every Nth post carries a lantern.
const RAIL_INSET := 0.6
const RAIL_LOW := 0.8
const RAIL_MIN := 2.5
const RAIL_LANTERN_EVERY := 2
const RAIL_CLEAR := 1.5
const LANTERN_SIZE := 0.3
## Planters of stone with flowers along the rails (the art's canteiros), every so many metres of edge.
const PLANTER_EVERY := 9.0
const PLANTER_INSET := 1.55
const PLANTER := Vector3(2.6, 0.45, 0.75)
## The cliffs: tufts of shrub, flowers and hanging wisteria on the face, and ledges of rock (the hub_cliff stone).
const CLIFF_TUFT_EVERY := 2.2
const CLIFF_TUFT_DEPTH := Vector2(0.5, 8.5)
const LEDGE_EVERY := 6.0
const LEDGE := Vector3(3.2, 1.0, 1.8)  # along the edge, tall, out of the face
const LEDGE_DEPTH := Vector2(1.8, 13.0)
## The main way's glow (Vigilia, Videira, Dons, Aposento, Portao): width, how far apart the samples.
const PATH_WIDTH := 1.5
const PATH_STEP := 0.6
const PATH_GLOW := Color(0.5, 0.34, 0.12)
const PATH_MAIN: Array[Vector2] = [Vector2(-23.0, -7.0), Vector2(-14.0, -7.0), Vector2(-7.0, -6.0), Vector2(2.0, -6.0),
	Vector2(4.0, 0.0), Vector2(4.0, 12.0), Vector2(1.0, 17.5)]
const PATH_GATE: Array[Vector2] = [Vector2(2.0, -6.0), Vector2(5.0, -13.0), Vector2(25.0, -13.0), Vector2(32.0, -6.0), Vector2(36.0, -6.0)]
## The red tree on a shelf at the north-west corner (the art's), its shelf, crown and trunk.
const RED_TREE_AT := Vector2(-30.4, 21.5)
const RED_TREE := Vector3(5.2, 5.0, 3.2)  # crown width, crown tall, trunk tall
const RED_TREE_CLEAR := 7.0

# ---------- the far ridges ----------
const RIDGE_SHADER := preload("res://assets/shaders/hub_ridge.gdshader")
## Each ridge card: distance north of the plan's middle v, width, height, bottom y, colour near the crest, colour at its
## top, ridge base share and amplitude, the seed.
const RIDGES: Array[Dictionary] = [
	{&"v": 160.0, &"w": 700.0, &"h": 170.0, &"y": -60.0, &"low": Color(0.5, 0.36, 0.52), &"top": Color(0.86, 0.6, 0.55), &"base": 0.6, &"amp": 0.3, &"seed": 3.0},
	{&"v": 110.0, &"w": 520.0, &"h": 140.0, &"y": -60.0, &"low": Color(0.3, 0.24, 0.42), &"top": Color(0.58, 0.4, 0.5), &"base": 0.62, &"amp": 0.3, &"seed": 11.0},
	{&"v": 70.0, &"w": 360.0, &"h": 120.0, &"y": -60.0, &"low": Color(0.14, 0.2, 0.2), &"top": Color(0.3, 0.34, 0.3), &"base": 0.6, &"amp": 0.3, &"seed": 21.0},
]
const RIDGE_U := 14.0
## The sky (a standing card behind the ridges) and the sea of cloud under the floor (a flat plane), as gradients.
const SKY_SHADER := preload("res://assets/shaders/hub_sky.gdshader")
const SKY_TOP := Color(0.26, 0.2, 0.48)
const SKY_HORIZON := Color(0.95, 0.62, 0.42)
const SEA_Y := -30.0
const SEA_SIZE := 900.0
const SEA_FAR := Color(0.8, 0.5, 0.4)
const SEA_NEAR := Color(0.3, 0.24, 0.42)
const SEA_CLOUD := 0.7
const SEA_CLOUD_SCALE := 0.07  # waves of cloud the near camera can tell apart (a view is only tens of metres wide)
const SKY_CARD := Vector4(260.0, 900.0, 320.0, -60.0)  # v, width, height, bottom y

var look: HubLook
var _rng := RandomNumberGenerator.new()
var _pieces: Array[Rect2] = []  # footprints of the stations' pieces and the doors (local u, v), padded
var _avoid: Array[Vector2] = []  # use points, door centres, the arrival
var _roof_mat: ShaderMaterial
var _window_mat: StandardMaterial3D
var _flower_spots: Array[Vector3] = []
var _flower_tall: Array[float] = []
var _wisteria_spots: Array[Vector3] = []
var _wisteria_tall: Array[float] = []
var _leaf_spots: Array[Vector3] = []
var _leaf_tall: Array[float] = []
var _cypress_spots: Array[Vector3] = []
var _cypress_tall: Array[float] = []
var _tree_spots: Array[Vector3] = []
var _tree_tall: Array[float] = []
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
		_roof(r, b[&"h"])
		_corners(r, b[&"h"])
		_windows(r, b[&"h"])
	facades.build()
	_water()
	_bridge()
	_pergola()
	_fountain()
	_vigil_post()
	_future_yards()
	_gate_dressing()
	facades.gate()
	_balustrades()
	_edges()
	_planters()
	_cliffs()
	_red_tree()
	_wall_flowers()
	_path_glow()
	_build_lanterns()
	look.add_crowns(_leaf_spots, _leaf_tall, LEAF_DARK, LEAF_LIGHT, 1.5, "Shrubs", false)
	look.add_crowns(_flower_spots, _flower_tall, WISTERIA_A, WISTERIA_B, 1.3, "Flowers", false)
	look.add_crowns(_magenta_spots, _magenta_tall, MAGENTA_A, MAGENTA_B, 1.3, "Magentas", false)
	look.add_crowns(_wisteria_spots, _wisteria_tall, WISTERIA_A, WISTERIA_B, 1.1, "Wisteria", false)
	look.add_crowns(_cypress_spots, _cypress_tall, CYPRESS_GREEN * 0.7, CYPRESS_GREEN * 1.25, 1.25, "Cypresses", false)
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
				if _on_floor(p) and (free_of_blocks or not _blocked(p, clear)) and p.y > -16.4:
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
	var board := look._plain(Color(0.2, 0.12, 0.08), 0.9)
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
				var tall := _rng.randf_range(1.0, 1.6)
				_wisteria_spots.append(Vector3(p.x, h - tall, p.y))
				_wisteria_tall.append(tall)
			u += _rng.randf_range(2.4, 3.6)


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
			elif roll < 0.4:
				plant(0, spot, _rng.randf_range(0.7, 1.2))
			elif roll < 0.7:
				plant(1, spot, _rng.randf_range(0.7, 1.2))
			else:
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
	if _lantern_xf.is_empty():
		return
	var bm := BoxMesh.new()
	bm.size = Vector3.ONE
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = bm
	mm.instance_count = _lantern_xf.size()
	for i in _lantern_xf.size():
		mm.set_instance_transform(i, _lantern_xf[i])
	var mi := MultiMeshInstance3D.new()
	mi.name = "Lanterns"
	mi.multimesh = mm
	mi.material_override = _window_material()
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
	var water := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = f.z
	disc.bottom_radius = f.z
	disc.height = 0.02
	disc.radial_segments = 20
	disc.rings = 1
	water.mesh = disc
	water.material_override = _water_mat
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
	bowl.material_override = _water_mat
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
	var dark := look._plain(HubBlockout.GATE_DARK, 1.0)
	var inner := look.m.stone(0.0, look.stone_tint() * HubLook.INNER_TINT)
	for u in BRIDGE_ARCHES:
		look.fm.block(_at(u, ARCH_FOOT, BRIDGE_V.x - 0.1), Vector3(ARCH_SPAN + ARCH_RING * 2.0, ARCH_SPRING - ARCH_FOOT + 1.4, 0.08), 0.0, dark, false)
		look.fm.voussoir_arch(_at(u, ARCH_FOOT, face), Vector2(0.0, 1.0), ARCH_SPAN, ARCH_SPRING - ARCH_FOOT, ARCH_RING, 0.4, inner, 0.8)
	# the piers between the arches and the cornice under the deck
	for u: float in [BRIDGE_ARCHES[0] + (BRIDGE_ARCHES[1] - BRIDGE_ARCHES[0]) * 0.5, BRIDGE_ARCHES[1] + (BRIDGE_ARCHES[2] - BRIDGE_ARCHES[1]) * 0.5]:
		look.fm.block(_at(u, ARCH_FOOT, face), Vector3(0.9, -ARCH_FOOT - 0.4, 0.5), 0.0, look.ashlar(), false)
	look.fm.block(_at((BRIDGE_U.x + BRIDGE_U.y) * 0.5, -0.5, face), Vector3(BRIDGE_U.y - BRIDGE_U.x, 0.3, 0.4), 0.0, look.stone(), false)
	for f in FALLS:
		_fall(f)


## A fall hanging from just under the lip down `drop`, foam at its foot, a haze where it lands.
func _fall(f: Vector4) -> void:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(f.z, f.w)
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = FALL_SHADER
	mat.set_shader_parameter(&"color", Color(WATER_BLUE.r, WATER_BLUE.g, WATER_BLUE.b).lightened(0.35))
	mat.set_shader_parameter(&"alpha", 0.8)
	mat.set_shader_parameter(&"streaks", 6.0)
	mi.material_override = mat
	mi.position = _at(f.x, -0.4 - f.w * 0.5, f.y)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(mi)
	look.fk.mist_bank(_at(f.x, -0.4 - f.w, f.y - 0.6), Vector2(f.z * 3.0, 2.2), Color(0.85, 0.92, 0.95), 0.35, 0.3, 0.2)


# ---------- the Videira's pergola ----------

## Stone columns and timber over the Videira's bed (the arch stands south of it), wisteria hanging from the beams.
func _pergola() -> void:
	var p := PERGOLA_POSTS
	var stone := look.stone()
	var wood := look._plain(RAFTER_WOOD, 0.85)
	var us: Array[float] = []
	for i in PERGOLA_COLUMNS:
		us.append(lerpf(p.x, p.y, float(i) / (PERGOLA_COLUMNS - 1)))
	for u in us:
		for v: float in [p.z, p.w]:
			look.fm.block(_at(u, 0.0, v), Vector3(0.45, 0.25, 0.45), 0.0, stone, false)
			look.fm.block(_at(u, 0.25, v), Vector3(0.32, PERGOLA_HEIGHT - 0.25, 0.32), 0.0, stone, false)
			look.fm.block(_at(u, PERGOLA_HEIGHT, v), Vector3(0.5, 0.14, 0.5), 0.0, stone, false)
	for v: float in [p.z, p.w]:
		look._bar(_at((p.x + p.y) * 0.5, PERGOLA_HEIGHT + 0.14 + RAFTER.y * 0.5, v), Vector3(p.y - p.x + 0.6, RAFTER.y * 1.4, 0.2), wood)
	var u := p.x
	while u <= p.y + 0.01:
		look._bar(_at(u, PERGOLA_HEIGHT + 0.14 + RAFTER.y * 1.7, (p.z + p.w) * 0.5), Vector3(0.1, RAFTER.y, p.w - p.z + 0.6), wood)
		var hang := _rng.randf_range(1.0, 1.5)
		_wisteria_spots.append(Vector3(u, PERGOLA_HEIGHT - hang, p.z + _rng.randf_range(0.0, p.w - p.z)))
		_wisteria_tall.append(hang)
		u += RAFTER.x * 1.6
	# the green roof of vine over the beams
	for k in 5:
		_leaf_spots.append(Vector3(lerpf(p.x, p.y, (k + 0.5) / 5.0), PERGOLA_HEIGHT + 0.1, (p.z + p.w) * 0.5 + _rng.randf_range(-0.8, 0.8)))
		_leaf_tall.append(0.8)


# ---------- the Ponto de Vigília ----------

## The arrival's post: a stone bowl on a round dais south-east of its wall (out from under the roof, in sight on
## arriving), a lit flame (the plan's one lit fire here) and a lion standard on a pole beside it.
func _vigil_post() -> void:
	var f := VIGIL_FLAME
	var stone := look.stone()
	var wall: Material = look.facade_stone()
	look.fm.shaft(_at(f.x, 0.0, f.z), 1.75, 0.16, stone)
	look.fm.shaft(_at(f.x, 0.16, f.z), 1.35, 0.2, stone)
	look.fm.shaft(_at(f.x, 0.36, f.z), 0.62, 0.39, wall)
	look.fk.brazier(Vector2(f.x, -f.z), 0.75, false, 1.6, true)
	var iron := look._plain(IRON, 0.6)
	var pole := _at(f.x + 1.5, 0.0, f.z)
	look._bar(pole + Vector3(0, 1.6, 0), Vector3(0.09, 3.2, 0.09), iron)
	look._bar(pole + Vector3(0, 3.15, 0), Vector3(1.0, 0.07, 0.07), iron)
	facades.banner(f.x + 1.5, 3.1, f.z, 0.85, 1.9)


# ---------- the future rooms ----------

## Behind each future door the sunken yard (YARD_DROP under the floor, in the simulation a cliff): a stair down from the
## door, the dark floor, a low wall round it and a lantern; the real door (HubBlockout) is what closes it.
func _future_yards() -> void:
	var floor_mat := look.m.stone(-YARD_DROP, look.stone_tint() * YARD_FLOOR)
	var wall := look.ashlar()
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
			look.fm.block(_at(mouth.x, -YARD_DROP, -17.35 - k * 0.45), Vector3(mouth.z * 2.0 + 1.0, top + YARD_DROP, 0.45), 0.0, look.stone(), false)
		_lamp(Vector2(mouth.x - mouth.z + 0.4, -15.9))
		_lamp(Vector2(mouth.x + mouth.z - 0.4, -15.9))


# ---------- the gate ----------

## The gate, readable from the camera (it opens to the west, edge-on to it): a freestanding frame of two tall pillars and a
## lintel across the way in front of the opening, lion statues' plinths at their feet, the lion over the arch, two
## standards, lanterns, a stone cap, and a column of the portal's light rising over it (a card facing the camera).
func _gate_dressing() -> void:
	var g := HubPlan.GATE
	var face := HubPlan.GATE_FACE_U
	var mid := HubPlan.GATE_MID_V
	var stone: Material = look.facade_stone()
	var fu := face - GATE_FRAME.x
	for s: float in [-1.0, 1.0]:
		var v := mid + s * GATE_FRAME.y
		look.fm.block(_at(fu, 0.0, v), Vector3(1.3, 0.5, 1.3), 0.0, stone, false)
		look.fm.block(_at(fu, 0.5, v), Vector3(0.95, GATE_FRAME.z - 0.5, 0.95), 0.0, stone, false)
		look.fm.block(_at(fu, GATE_FRAME.z, v), Vector3(1.2, 0.3, 1.2), 0.0, stone, false)
		facades.banner(fu - 0.48, GATE_FRAME.z - 0.6, v, 0.9, 2.4, -PI * 0.5)
		look._lion(_at(fu - 0.49, 1.3, v), Basis(Vector3.UP, -PI * 0.5), 0.6, HubLook.MEDALLION_GOLD)
		_lamp(Vector2(fu - 1.2, v))
	look.fm.block(_at(fu, GATE_FRAME.z + 0.3, mid), Vector3(1.1, 0.7, GATE_FRAME.y * 2.0 + 1.4), 0.0, stone, false)
	look.fm.block(_at(fu, GATE_FRAME.z + 1.0, mid), Vector3(0.8, 0.4, GATE_FRAME.y * 2.0 + 0.4), 0.0, stone, false)
	look._lion(_at(fu - 0.41, GATE_FRAME.z + 0.65, mid), Basis(Vector3.UP, -PI * 0.5), 0.8, HubLook.MEDALLION_GOLD)
	look.fm.block(_at((g.x + g.z) * 0.5, HubBlockout.GATE_WALL_H, (g.y + g.w) * 0.5), Vector3(g.z - g.x + 0.5, 0.35, g.w - g.y + 0.5), 0.0, stone, false)
	var head := HubBlockout.GATE_W * 0.5 + HubBlockout.GATE_HEAD_SIDE
	look.fm.block(_at((g.x + g.z) * 0.5, HubPlan.GATE_HEIGHT, mid), Vector3(g.z - g.x + 0.5, 0.35, head * 2.0 + 0.5), 0.0, stone, false)
	_light_column(Vector3(face + 0.5, 0.0, mid))


## A soft column of Elun's warm gold light standing over the gate: a vertical card facing south, fading upward.
func _light_column(p: Vector3) -> void:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.4), Color(1, 1, 1, 0.0)])
	grad.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0.0, 1.0)
	tex.fill_to = Vector2(0.0, 0.0)
	tex.width = 4
	tex.height = 128
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = GATE_LIGHT_COLOR
	mat.albedo_texture = tex
	mat.no_depth_test = false
	var mi := MeshInstance3D.new()
	mi.name = "GateLight"
	var q := QuadMesh.new()
	q.size = Vector2(GATE_LIGHT.x, GATE_LIGHT.y)
	mi.mesh = q
	mi.material_override = mat
	mi.position = p + Vector3(0, GATE_LIGHT.y * 0.5, 0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(mi)


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
		if c.distance_to(RED_TREE_AT) < RED_TREE_CLEAR:
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
func _lamp(p: Vector2) -> void:
	var stone: Material = look.facade_stone()
	var fm := look.fm
	fm.block(_at(p.x, 0.0, p.y), Vector3(0.5, 0.5, 0.5), 0.0, stone, false)
	fm.block(_at(p.x, 0.5, p.y), Vector3(0.3, 1.1, 0.3), 0.0, stone, false)
	fm.block(_at(p.x, 1.6, p.y), Vector3(0.46, 0.12, 0.46), 0.0, stone, false)
	_lantern_xf.append(Transform3D(Basis.from_scale(Vector3.ONE * LANTERN_SIZE), _at(p.x, 1.72 + LANTERN_SIZE * 0.5, p.y)))
	fm.block(_at(p.x, 1.72 + LANTERN_SIZE, p.y), Vector3(LANTERN_SIZE + 0.12, 0.09, LANTERN_SIZE + 0.12), 0.0, stone, false)


func _window_material() -> StandardMaterial3D:
	if _window_mat == null:
		_window_mat = StandardMaterial3D.new()
		_window_mat.albedo_color = WINDOW_GLOW * 0.5
		_window_mat.emission_enabled = true
		_window_mat.emission = WINDOW_GLOW
		_window_mat.emission_energy_multiplier = GLASS_GLOW
		_window_mat.roughness = 0.4
	return _window_mat


# ---------- balustrades, planters ----------

## A low cream balustrade along every outer edge that is not behind a building, the future rooms' mouths or an existing
## rail, inset from the lip; every second post carries a lit lantern.
func _balustrades() -> void:
	var mat := look.stone()
	var post_top := Masonry.POST.y * RAIL_LOW + Masonry.POST_STEP.y + Masonry.POST_CAP.y
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
			if -into.y > 0.35 or mid.y < -16.4 or _rail_taken(mid) or _near_mass(mid):
				continue
			var p0 := a + dir * 0.5 + into * RAIL_INSET
			var p1 := b - dir * 0.5 + into * RAIL_INSET
			if not (_on_floor(p0) and _on_floor(p1)):
				continue
			look.fm.balustrade(_at(p0.x, 0.0, p0.y), _at(p1.x, 0.0, p1.y), true, mat, RAIL_LOW)
			var spans := maxi(1, roundi(p0.distance_to(p1) / Masonry.POST_GAP))
			for k in range(0, spans + 1, RAIL_LANTERN_EVERY):
				var q := p0.lerp(p1, float(k) / spans)
				_lantern_xf.append(Transform3D(Basis.from_scale(Vector3.ONE * LANTERN_SIZE), _at(q.x, post_top + LANTERN_SIZE * 0.5 + 0.02, q.y)))


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
		for k in 4:
			var q := c + along * (-PLANTER.x * 0.36 + PLANTER.x * 0.24 * k)
			plant(0 if (k + int(absf(c.x))) % 2 == 0 else 1, Vector3(q.x, PLANTER.y, q.y), _rng.randf_range(0.5, 0.85))


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
		if roll < 0.5:
			_leaf_spots.append(at)
			_leaf_tall.append(_rng.randf_range(1.0, 1.8))
		elif roll < 0.72:
			plant(_rng.randi() % 2, at, _rng.randf_range(0.8, 1.3))
		else:
			var hang := _rng.randf_range(1.4, 2.4)
			_wisteria_spots.append(Vector3(at.x, -hang - 0.2, at.z))
			_wisteria_tall.append(hang)
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
	for f in FALLS:
		if absf(p.x - f.x) < f.z * 0.5 + 0.8 and absf(p.y - f.y) < 1.2:
			return true
	return false


## The art's red tree in the north-west corner: a shelf of rock beyond the lip, a trunk and a broad crown of crimson leaves.
func _red_tree() -> void:
	var c := RED_TREE_AT
	look.fm.block(_at(c.x, -TREE_SHELF.y - 0.3, c.y), Vector3(TREE_SHELF.x * 1.5, TREE_SHELF.y + 0.3, TREE_SHELF.x * 1.2), 0.4, look.stone(), false)
	look._bar(_at(c.x, RED_TREE.z * 0.5 - 0.3, c.y), Vector3(0.38, RED_TREE.z, 0.38), look._plain(Color(0.24, 0.16, 0.12), 0.9))
	look.add_crowns([Vector3(c.x, RED_TREE.z - 0.8, c.y)] as Array[Vector3], [RED_TREE.y] as Array[float], RED_LEAF_A, RED_LEAF_B, RED_TREE.x, "RedTree", true)


## A faint gold glow laid along the main way (Vigilia to Videira to Dons to the Aposento, and on to the Portao), only
## where both of its sides are floor: the art's path of light.
func _path_glow() -> void:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color.BLACK, Color(1, 1, 1), Color.BLACK])
	grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0.0, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 4
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_texture = tex
	mat.albedo_color = PATH_GLOW
	for line: Array[Vector2] in [PATH_MAIN, PATH_GATE]:
		var pts := _resample(line, PATH_STEP)
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in pts.size() - 1:
			var a := pts[i]
			var b := pts[i + 1]
			var dir := (b - a).normalized()
			var side := Vector2(-dir.y, dir.x) * PATH_WIDTH * 0.5
			if not (_on_floor(a + side) and _on_floor(a - side) and _on_floor(b + side) and _on_floor(b - side)):
				continue
			var q: Array[Vector3] = [_at(a.x + side.x, 0.03, a.y + side.y), _at(a.x - side.x, 0.03, a.y - side.y),
				_at(b.x - side.x, 0.03, b.y - side.y), _at(b.x + side.x, 0.03, b.y + side.y)]
			var uvs: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
			for k: int in [0, 1, 2, 0, 2, 3]:
				st.set_uv(uvs[k])
				st.add_vertex(q[k])
		var mi := MeshInstance3D.new()
		mi.name = "PathGlow"
		mi.mesh = st.commit()
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		look.frame.add_child(mi)


## The polyline's points every `step` m.
func _resample(line: Array[Vector2], step: float) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for i in line.size() - 1:
		var a := line[i]
		var b := line[i + 1]
		var n := maxi(1, ceili(a.distance_to(b) / step))
		for k in n:
			out.append(a.lerp(b, float(k) / n))
	out.append(line[line.size() - 1])
	return out


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
		mi.position = _at(RIDGE_U, float(r[&"y"]) + float(r[&"h"]) * 0.5, float(r[&"v"]))
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
