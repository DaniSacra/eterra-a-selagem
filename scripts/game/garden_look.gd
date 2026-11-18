class_name GardenLook
extends ArenaRoom
## The look of the Jardim das Raízes Mortas (the garden of the dead roots): a wide hall round a petrified tree of stone (its
## trunk stops bodies and shots, its crown must open round the paladin), low roots, spectral crystals for show only
## (decision D-30; docs/art/cycle12_arenas_spec.md, section 4; the AI picture 04 for the mood).
## ArenaRoom draws the floor (FLOOR), the broken edges and cliffs (CLIFF), the abyss (MIST), the obstacles (the
## sarcophagi, the broken columns and the low wall by TombKit), the doors' stairs, arches, grilles and lanterns, and
## dresses the air (AIR). This script adds the tree (StoneTree) on the trunk's and the roots' collision, candles on the
## sarcophagi, the ruined gothic walls to the north and west with their broken windows (violet behind), the door X1 in
## a recess of the north wall, the balustrade over the abyss to the east and south with arches in the cliff under it, the
## way in with its gold filet, statues in niches, dry grass, broken arcs of an inscription round the tree, the cold beam
## on the tree with its branches' shadows and the soft key light. What blocks never comes from here: it is an
## ArenaObstacle in the layout (_garden in tools/make_data.gd), drawn on its own footprint.

# ---------- the floor, the cliffs, the air (spec 4.6) ----------
## The floor: the warmest of the three, lilac and brown, more slabs cracked and split (the roots lifted them), grey-green
## lichen; no red petals.
const FLOOR := {
	&"unit": 1.1, &"stone_a": Color(0.30, 0.27, 0.28), &"stone_b": Color(0.42, 0.38, 0.38),
	&"moss_color": Color(0.18, 0.22, 0.20), &"petal_color": Color(0.30, 0.27, 0.28), &"cracked": 0.4, &"split2": 0.4,
}
## The abyss's mist in front of the platform and the cliffs under it: a colder violet-grey than the hall's teal.
const MIST := Color(0.09, 0.08, 0.15)
const CLIFF := {&"stone_color": Color(0.06, 0.055, 0.085), &"edge_color": Color(0.15, 0.12, 0.22), &"mist_color": Color(0.09, 0.08, 0.15)}
## The air: cold grey, the moon cold and weak (ambient energy 0.7 where the game's is 0.9).
const AIR := {
	&"sky": Color(0.05, 0.06, 0.09), &"fog": Color(0.07, 0.08, 0.12), &"ambient": Color(0.30, 0.33, 0.38),
	&"ambient_gain": 1.05, &"moon": Color(0.6, 0.68, 0.85), &"moon_energy": 0.35, &"moon_shadow": true,
}
## The soft key over the middle (no shadow), cold grey.
const KEY := Color(0.78, 0.8, 0.9)
const KEY_ENERGY := 5.5
## The browser's renderer (Compatibility) turns the cold key and beam into a saturated blue on the floor (ART_REVIEW G-1):
## there they are a share weaker and the key a neutral grey.
const COMPAT_LIGHT := 0.7
const COMPAT_KEY := Color(0.8, 0.8, 0.8)
## There the weak moon (0.25) casts no shadow (ENV-03, QA B-4: the garden was the one arena past 6 ms in the p90 there;
## its shadow pass draws the whole hall again for shadows hardly seen under the beam's).
const COMPAT_MOON_SHADOW := false
## The inscription round the trunk: its band (inner and outer radius, m) and its arcs (bearings, degrees): never closed,
## gaps of 2 m and more; the floor's edges, the roots and every other piece cut it further.
const INSCRIPTION := Vector2(9.05, 9.75)
const INSCRIPTION_ARCS: Array[Vector2] = [Vector2(28.0, 84.0), Vector2(100.0, 152.0), Vector2(168.0, 236.0), Vector2(252.0, 330.0)]
const INSCRIPTION_STEP := 2.0
const INSCRIPTION_CLEAR := 0.25

# ---------- the tree ----------
## The crown stays inside the walls (their inner faces, a little in).
const CROWN_BOUNDS := Rect2(-16.4, -13.4, 33.0, 27.0)
## The crystals' largest channel of emission in each variant (dark corrupted emerald, ART_REVIEW J-1: was 0.8 and 0.9,
## near white on screen), their light (StoneTree.CRYSTAL_GLOW's hue, no shadow: energy, reach, height).
const CRYSTAL_GLOW := Vector2(0.12, 0.15)
const CRYSTAL_LIGHT := Vector3(0.2, 2.6, 0.7)
## C18 (ART P1-7, Q-21 (a)): the crown of leaves, procedural cards (canopy.gdshader) on the crown's spines above
## CANOPY_FROM m: one card every CANOPY_EVERY points, sizes, how far each is pushed off its branch, the leaves' two
## tones (muted violet, saturation under 0.45). One MultiMesh, one material.
const CANOPY_FROM := 6.2
const CANOPY_EVERY := 3
const CANOPY_SIZE := Vector2(1.6, 2.8)
const CANOPY_JITTER := 0.6
const CANOPY_LEAF_A := Color(0.22, 0.17, 0.27)
const CANOPY_LEAF_B := Color(0.42, 0.34, 0.48)
const CANOPY_SHADER := preload("res://assets/shaders/canopy.gdshader")
## A soft fill on the tree alone (StoneTree.LAYER, no shadow) from the camera's side (bearing), so the trunk's face
## reads 10 to 20% lighter than the floor beside it (ART_REVIEW J-2): colour, energy, reach, how far out and how high.
const TREE_FILL := Color(0.78, 0.8, 0.88)
const TREE_FILL_LIGHT := Vector4(0.32, 13.0, 7.5, 3.5)
const TREE_FILL_BEARING := 150.0
## The hanging lanterns: their height (the ring at the chain's foot), how many in each variant, cage size, light.
const LANTERN_AT := 5.5
const LANTERNS := Vector2i(1, 2)
const LANTERN_SIZE := Vector3(0.34, 0.5, 0.34)
const LANTERN_LIGHT := Vector2(1.4, 7.0)

# ---------- the walls (spec 4.1) ----------
## North (the back): its inner face on the floor's edge, how thick, its height between, the windows' middles (x).
const NORTH_Z := -14.0
const WALL_THICK := 0.9
const NORTH_HEIGHT := Vector2(7.0, 9.0)
const NORTH_WINDOWS: Array[float] = [-3.0, 3.5]
## West: its inner face, height, the window (z) and the banners (z).
const WEST_X := -17.0
const WEST_HEIGHT := Vector2(6.0, 7.2)
const WEST_WINDOWS: Array[float] = [-4.0]
const WEST_BANNERS: Array[float] = [-8.0, 2.0]
## Banners (the lion, Daniel's choice of 2026-11-16): their top over the floor, width and length.
const BANNER := Vector3(5.6, 1.25, 3.4)
## A window: opening width and height, its sill, the ring of its arch, the arch's radius (share of the span).
const WINDOW := Vector2(2.4, 6.0)
const WINDOW_SILL := 0.9
## How far the sill stands out of the wall's face over the floor (m; within the fit probe's slack).
const SILL_OUT := 0.12
const WINDOW_RING := 0.32
const WINDOW_RADIUS := 0.8
## The wall is built in upright slices this wide (narrower round the windows), its top broken by up to RUIN m.
const SLICE := 1.1
const SLICE_FINE := 0.3
const RUIN := 1.6
## Pilasters on the walls' faces (every, width, how far they stand out) and the string courses (heights).
const PILASTER := Vector3(4.6, 0.7, 0.35)
const COURSES: Array[float] = [0.9, 5.4]
## The door X1's recess in the north wall: its sides (x), its back wall's face (z), the raised stoop each side of the
## door where the fire bowls stand; the door's arch (ArenaRoom.door_arch) set back this far into the recess.
const RECESS := Vector2(9.4, 16.6)
const RECESS_BACK := -15.6
const DOOR_OPEN := Vector2(10.5, 15.5)
const DOOR_TOP := 5.2
const DOOR_BACK := 2.05
const STOOP := 0.2
## The north-west corner: a broken pier and its buttress.
const NW_PIER := Vector3(-15.6, -12.6, 5.4)
## The low broken wall along the north-west cut: its middle this far out of the floor's edge (its blocks turned
## across the cut reach 0.7 m: off the walkable floor).
const CUT_WALL_OUT := 0.8
## The north-east corner: a tower pier.
const NE_PIER := Vector3(17.7, -14.7, 8.2)

# ---------- the front: arches under the platform ----------
## The arches in the cliff under the east and south edges: every this many m, their span, ring, how far down their
## springing is; the piers between; how much they fade into the mist.
const ARCH_EVERY := 5.0
const ARCH := Vector3(3.4, 0.7, 7.5)
const ARCH_PIER := Vector2(1.0, 0.7)
const ARCH_FADE := 0.6

# ---------- the way in ----------
## Stairs down from the south-west cut (steps, rise, run), their middle and width.
const STAIRS := Vector3(7, 0.24, 0.42)
const ENTRY := Vector2(-14.5, 11.5)
const ENTRY_WIDTH := 4.4

# ---------- statues, grass, candles ----------
## Hooded statues (empty hands) in niches: where (x, z), their facing (degrees, 0 = looking south), height.
const STATUES: Array[Vector4] = [Vector4(7.6, -14.9, 0.0, 3.0), Vector4(-17.9, 6.0, 90.0, 3.0)]
## A niche's width and depth behind a statue.
const NICHE := Vector2(2.0, 1.1)
## Tufts of dry grass: how many at most, their size; along each root, how far out of its middle line and how likely at
## each of its points (ART_REVIEW J-4).
const GRASS := 130
const ROOT_GRASS := Vector2(0.72, 0.8)
const GRASS_SIZE := Vector2(0.25, 0.55)
## Slabs of the floor the roots lifted and split (ART_REVIEW J-3): per root, size (m), how far out of its middle line,
## the tilt (degrees, fewest and most). Drawn only: they lie low beside the root's collision, never on open ground.
const LIFTED := 2
const LIFTED_SLAB := Vector3(0.75, 0.08, 0.55)
const LIFTED_OUT := 0.78
const LIFTED_TILT := Vector2(9.0, 18.0)
## Candles on each sarcophagus's lid.
const LID_CANDLES := 2
## Moss on the floor (root_moss.gdshader; art pack 2026-11-17, section 4: the bark, the moss and the masonry meet):
## how far it reaches out of each root's middle line, round the trunk (from its radius, m) and out of the walls' feet;
## a point every MOSS_STEP meters along a band; its height over the floor (under the inscription's).
const MOSS_ROOT := 1.35
const MOSS_TRUNK := 1.8
const MOSS_WALL := 1.1
const MOSS_STEP := 0.4
const MOSS_Y := 0.004
const MOSS_SHADER := preload("res://assets/shaders/root_moss.gdshader")
## In the Compatibility renderer the floor's light is lifted (COMPAT_*) and the moss read as a lawn: less of it there.
const MOSS_COMPAT_COVER := 0.55

# ---------- light (spec 4.6) ----------
## The cold beam on the tree: from where (x, y, z), its colour, energy (A, B), cone (degrees) and reach; the shadows of
## the branches keep the floor over 60% of its light (shadow_opacity).
const BEAM_FROM := Vector3(-2.0, 22.0, -16.0)
const BEAM_AT := Vector3(-8.0, 3.0, -5.0)
const BEAM_COLOR := Color(0.75, 0.8, 0.95)
const BEAM_ENERGY := Vector2(3.0, 1.8)
const BEAM_CONE := 30.0
const BEAM_REACH := 40.0
const BEAM_SHADOW := 0.4
## The violet that comes in by each window and lights only the walls' stone (FACADE_LAYER), and the mist behind.
const WINDOW_LIGHT := Color(0.55, 0.3, 0.95)
const WINDOW_ENERGY := 2.2
const WINDOW_REACH := 6.0
const WINDOW_MIST := Color(0.42, 0.22, 0.7)
const WINDOW_MIST_ALPHA := 0.75

## The tree that was grown (StoneTree), for the lab and the tests.
var tree: StoneTree
## Variant B (three roots): the cold beam weaker, the crystals a step brighter, two lanterns.
var variant_b := false
var _trunk_o: ArenaObstacle
var _wall_mat: ShaderMaterial
## The cliff's stone of the arches under the front (the depth stone in the garden's colours).
var _deep: ShaderMaterial
var _tufts: Array[Transform3D] = []


func floor_look() -> Dictionary:
	return FLOOR


func mist() -> Color:
	return MIST


func cliff_look() -> Dictionary:
	return CLIFF


func air() -> Dictionary:
	if not _compat():
		return AIR
	var a := AIR.duplicate()
	a[&"moon_shadow"] = COMPAT_MOON_SHADOW
	return a


## The north door (X1) opens in the north wall.
func in_wall(i: int) -> bool:
	return layout.exits[i].inward.y > 0.5


## The north door's arch stands in the back of its recess (the fire bowls in front of it).
func door_arch(edge_mid: Vector2, inward: Vector2, width: float, back := 0.5, height := WALL_DOOR.y) -> void:
	super.door_arch(edge_mid, inward, width, maxf(back, DOOR_BACK), height)


func dress() -> void:
	for o in layout.obstacles:
		if o.piece == &"trunk":
			_trunk_o = o
	variant_b = _trunk_o != null and root_paths(layout, _trunk_o).size() < 4
	_wall_mat = ashlar()
	if _trunk_o != null:
		_inscription()
	_tree()
	_walls()
	_moss()
	_entry()
	_statues()
	_grass()
	_beam()
	if _compat():
		key_light(COMPAT_KEY, KEY_ENERGY * COMPAT_LIGHT)
	else:
		key_light(KEY, KEY_ENERGY)


## True in the browser's renderer (Compatibility).
static func _compat() -> bool:
	return RenderingServer.get_current_rendering_method() == "gl_compatibility"


## The trunk and the roots are the tree's (drawn on their collision by StoneTree); a sarcophagus gets candles on its
## lid; the rest as ArenaRoom draws it.
func piece(o: ArenaObstacle) -> void:
	match o.piece:
		&"trunk", &"root":
			return
		&"sarcophagus":
			var top := sarcophagus(o)
			candles(top, LID_CANDLES)
		_:
			super.piece(o)


## Every edge over the abyss is broken (ArenaRoom); along the front (east, south and their cut) a balustrade with
## arches in the cliff under it; the way in keeps only its gold filet; the north and west edges carry the walls.
func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	super.edge(a, b, out, kind, faces)
	if kind != Edge.OUTER:
		return
	var mid := (a + b) * 0.5
	if mid.distance_to(ENTRY) < ENTRY_WIDTH * 0.6:
		filet(a, b, out)
		return
	if out.x > 0.5 or out.y > 0.5:
		balustrade_edge(a, b, out, false)
		_cliff_arches(a, b, out)

# ---------- the floor ----------

## Broken arcs of a carved inscription round the trunk: a flat band a hair over the floor, cut wherever the floor ends
## or something stands.
func _inscription() -> void:
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://assets/shaders/garden_inscription.gdshader")
	var c := _trunk_o.center
	var mid := (INSCRIPTION.x + INSCRIPTION.y) * 0.5
	for arc in INSCRIPTION_ARCS:
		var run: Array[float] = []
		var b := arc.x
		while b <= arc.y:
			var p := c + StoneTree.toward(b) * mid
			var inner := c + StoneTree.toward(b) * INSCRIPTION.x
			var outer := c + StoneTree.toward(b) * INSCRIPTION.y
			if _clear(p) and _clear(inner) and _clear(outer):
				run.append(b)
			elif run.size() > 1:
				_arc_strip(c, run, mat)
				run = []
			else:
				run = []
			b += INSCRIPTION_STEP
		if run.size() > 1:
			_arc_strip(c, run, mat)


## True where the floor is open (on it, nothing standing within INSCRIPTION_CLEAR).
func _clear(p: Vector2) -> bool:
	if not arena.shape().contains(p, INSCRIPTION_CLEAR):
		return false
	for o in layout.obstacles:
		if o.blocks_move and o.depth(p, INSCRIPTION_CLEAR) > 0.0:
			return false
	return true


func _arc_strip(c: Vector2, bearings: Array[float], mat: ShaderMaterial) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	var length := deg_to_rad(bearings[-1] - bearings[0]) * (INSCRIPTION.x + INSCRIPTION.y) * 0.5
	var pts: Array[Vector3] = []
	var uvs: Array[Vector2] = []
	for b in bearings:
		var w := StoneTree.toward(b)
		var u := deg_to_rad(b - bearings[0]) * (INSCRIPTION.x + INSCRIPTION.y) * 0.5
		for r: float in [INSCRIPTION.x, INSCRIPTION.y]:
			pts.append(Vector3(c.x + w.x * r, 0.006, c.y + w.y * r))
			uvs.append(Vector2(u, 0.0 if r == INSCRIPTION.x else 1.0))
	for k in bearings.size() - 1:
		var q := [k * 2, k * 2 + 1, k * 2 + 2, k * 2 + 3]
		for tri: Array in [[q[0], q[1], q[2]], [q[2], q[1], q[3]]]:
			var a: Vector3 = pts[tri[0]]
			var b: Vector3 = pts[tri[1]]
			var d: Vector3 = pts[tri[2]]
			# facing up (clockwise as seen from above)
			var order: Array = tri if (b - a).cross(d - a).y < 0.0 else [tri[0], tri[2], tri[1]]
			for i: int in order:
				st.set_uv(uvs[i])
				st.add_vertex(pts[i])
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var own := mat.duplicate() as ShaderMaterial
	own.set_shader_parameter(&"arc_length", length)
	mi.material_override = own
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)


# ---------- the moss ----------

## Moss bands on the floor: along each root from the trunk out past its tip, round the trunk's foot and along the
## feet of the north and west walls. Drawn only, flat, in one mesh with one material.
func _moss() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	if _trunk_o != null:
		var c := _trunk_o.center
		var ring := PackedVector2Array()
		for k in 49:
			ring.append(c + StoneTree.toward(k * 7.5) * (_trunk_o.radius - 0.3))
		_moss_band(st, ring, MOSS_TRUNK + 0.3, false)
		for path in root_paths(layout, _trunk_o):
			var from := c + (path[0] - c).normalized() * _trunk_o.radius
			var line := PackedVector2Array([from])
			line.append_array(path)
			var tip := (path[path.size() - 1] - line[line.size() - 2]).normalized()
			line.append(path[path.size() - 1] + tip * StoneTree.ROOT_PAST)
			_moss_band(st, line, MOSS_ROOT, false)
			_moss_band(st, line, MOSS_ROOT, true)
	var b := arena.shape().bounds()
	_moss_band(st, PackedVector2Array([Vector2(b.position.x + 4.0, NORTH_Z), Vector2(RECESS.x, NORTH_Z)]), MOSS_WALL, true)
	_moss_band(st, PackedVector2Array([Vector2(RECESS.y, NORTH_Z), Vector2(b.end.x, NORTH_Z)]), MOSS_WALL, true)
	_moss_band(st, PackedVector2Array([Vector2(WEST_X, b.position.y + 4.0), Vector2(WEST_X, 9.0)]), MOSS_WALL, false)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var mat := ShaderMaterial.new()
	mat.shader = MOSS_SHADER
	mat.render_priority = -2
	if _compat():
		mat.set_shader_parameter(&"cover", MOSS_COMPAT_COVER)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)


## One side of a moss band along a line (to its left when `left`, as seen from above going along it), `reach` wide:
## the vertex colour's alpha 1 on the line, 0 at its border; cut to the floor.
func _moss_band(st: SurfaceTool, line: PackedVector2Array, reach: float, left: bool) -> void:
	var pts := PackedVector2Array()
	for i in range(1, line.size()):
		var n := maxi(1, ceili(line[i - 1].distance_to(line[i]) / MOSS_STEP))
		for k in n:
			pts.append(line[i - 1].lerp(line[i], float(k) / n))
	pts.append(line[line.size() - 1])
	# each point's way out of the line (the mean of its two legs'), so the band runs on without gaps round a bend
	var sides := PackedVector2Array()
	for i in pts.size():
		var a := pts[maxi(i - 1, 0)]
		var c := pts[mini(i + 1, pts.size() - 1)]
		var along := (c - a).normalized()
		sides.append(Vector2(-along.y, along.x) * (1.0 if left else -1.0))
	var shape := arena.shape()
	for i in range(1, pts.size()):
		var a := pts[i - 1]
		var c := pts[i]
		var quad: Array[Vector2] = [a, c, c + sides[i] * reach, a + sides[i - 1] * reach]
		var mid := (a + c) * 0.5 + (sides[i] + sides[i - 1]) * reach * 0.25
		if not shape.contains(mid, 0.0) and not shape.contains(a, 0.0):
			continue
		# the vertex colour's alpha: 1 on the line (the root, the wall), 0 at the band's border
		var near: Array[float] = [1.0, 1.0, 0.0, 0.0]
		for k: int in [0, 1, 2, 0, 2, 3]:
			st.set_color(Color(1.0, 1.0, 1.0, near[k]))
			st.add_vertex(Vector3(quad[k].x, MOSS_Y, quad[k].y))


# ---------- the tree ----------

## The crown's leaves: cards on the crown's high points, each facing the camera (turned round its own axis a little),
## kept to the crown's bounds.
func _canopy() -> void:
	var spots: Array[Vector3] = []
	for k in tree.crown.size():
		var p := tree.crown[k]
		if p.y >= CANOPY_FROM and k % CANOPY_EVERY == 0 and (not CROWN_BOUNDS.has_area() or CROWN_BOUNDS.has_point(Vector2(p.x, p.z))):
			spots.append(p)
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
	r.seed = 4177
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	for i in spots.size():
		var size := r.randf_range(CANOPY_SIZE.x, CANOPY_SIZE.y)
		var basis := Basis(Vector3.UP, yaw + r.randf_range(-0.5, 0.5)) * Basis(Vector3.BACK, r.randf() * TAU) * Basis.from_scale(Vector3(size, size, 1.0))
		var off := Vector3(r.randf_range(-1.0, 1.0), r.randf_range(-0.3, 1.0), r.randf_range(-1.0, 1.0)) * CANOPY_JITTER
		mm.set_instance_transform(i, Transform3D(basis, spots[i] + off))
		mm.set_instance_custom_data(i, Color(r.randf(), 0, 0, 0))
	var mat := ShaderMaterial.new()
	mat.shader = CANOPY_SHADER
	mat.set_shader_parameter(&"leaf_a", CANOPY_LEAF_A)
	mat.set_shader_parameter(&"leaf_b", CANOPY_LEAF_B)
	var mi := MultiMeshInstance3D.new()
	mi.name = "Canopy"
	mi.multimesh = mm
	mi.material_override = mat
	mi.layers = StoneTree.LAYER
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)


func _tree() -> void:
	if _trunk_o == null:
		return
	tree = StoneTree.new()
	tree.bounds = CROWN_BOUNDS
	tree.build(self, _trunk_o.center, root_paths(layout, _trunk_o), CRYSTAL_GLOW.y if variant_b else CRYSTAL_GLOW.x)
	_canopy()
	for i in mini(LANTERNS.y if variant_b else LANTERNS.x, tree.hangs.size()):
		_hanging_lantern(tree.hangs[i])
	var fill := OmniLight3D.new()
	var fw := StoneTree.toward(TREE_FILL_BEARING) * TREE_FILL_LIGHT.z
	fill.position = tree.at + Vector3(fw.x, TREE_FILL_LIGHT.w, fw.y)
	fill.light_color = TREE_FILL
	fill.light_energy = TREE_FILL_LIGHT.x
	fill.omni_range = TREE_FILL_LIGHT.y
	fill.omni_attenuation = 0.6
	fill.light_cull_mask = StoneTree.LAYER
	add_child(fill)
	for spot in tree.crystal_spots:
		var out := (spot - tree.at).normalized()
		var l := OmniLight3D.new()
		l.position = spot + out * 0.6 + Vector3(0, CRYSTAL_LIGHT.z, 0)
		l.light_color = StoneTree.CRYSTAL_GLOW
		l.light_energy = CRYSTAL_LIGHT.x
		l.omni_range = CRYSTAL_LIGHT.y
		l.light_cull_mask = ~Arena.CROWD_LAYER
		add_child(l)
	# dry grass round the trunk's foot and along the roots
	var r := RandomNumberGenerator.new()
	r.seed = 911
	for k in 14:
		var w := StoneTree.toward(r.randf() * 360.0)
		_tuft_near(_trunk_o.center + w * (_trunk_o.radius + 0.15), r, 1)
	_root_floor(r)


## Along each root: dry grass at its sides and a few slabs of the floor lifted and split by it.
func _root_floor(r: RandomNumberGenerator) -> void:
	var slab := stone()
	for path in root_paths(layout, _trunk_o):
		var from := _trunk_o.center + (path[0] - _trunk_o.center).normalized() * _trunk_o.radius
		var pts := PackedVector2Array([from])
		pts.append_array(path)
		for i in range(1, pts.size()):
			var a := pts[i - 1]
			var b := pts[i]
			var along := (b - a).normalized()
			var side := Vector2(-along.y, along.x)
			var steps := maxi(1, ceili(a.distance_to(b) / 0.8))
			for k in steps:
				var q := a.lerp(b, (k + 0.5) / steps)
				for sd: float in [-1.0, 1.0]:
					if r.randf() < ROOT_GRASS.y:
						_tuft_near(q + side * sd * ROOT_GRASS.x, r, 1)
		for k in LIFTED:
			var i := r.randi_range(1, pts.size() - 1)
			var q := pts[i - 1].lerp(pts[i], r.randf_range(0.25, 0.75))
			var along := (pts[i] - pts[i - 1]).normalized()
			var sd := 1.0 if r.randf() < 0.5 else -1.0
			var side := Vector2(-along.y, along.x) * sd
			var c := q + side * LIFTED_OUT
			if not _clear_of_others(c, LIFTED_SLAB.x * 0.5):
				continue
			var tilt := deg_to_rad(r.randf_range(LIFTED_TILT.x, LIFTED_TILT.y))
			# lifted along its edge on the root's side: that edge up, the far one sunk in the floor
			var blk := m.box(Vector3(c.x, LIFTED_SLAB.y * 0.5 + sin(tilt) * LIFTED_SLAB.z * 0.3, c.y), LIFTED_SLAB,
				atan2(-along.y, along.x) + r.randf_range(-0.3, 0.3), slab, false)
			blk.rotate_object_local(Vector3.RIGHT, tilt * sd)


## True where nothing but the tree stands within `r` of p and the floor is there.
func _clear_of_others(p: Vector2, r: float) -> bool:
	if not arena.shape().contains(p, r):
		return false
	for o in layout.obstacles:
		if o.piece != &"root" and o.piece != &"trunk" and o.blocks_move and o.depth(p, r) > 0.0:
			return false
	return true


## Each root's points from where it leaves the trunk out to its tip, read back from the layout's capsules (each leg a
## box from point to point, the first from inside the trunk: _root in tools/make_data.gd).
static func root_paths(l: RoomLayout, trunk: ArenaObstacle) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	for o in l.obstacles:
		if o.piece != &"root" or o.shape != ArenaObstacle.Shape.BOX:
			continue
		var ax := Vector2.from_angle(o.yaw) * (o.half.x - o.half.y)
		var a := o.center - ax
		var b := o.center + ax
		if a.distance_to(trunk.center) > b.distance_to(trunk.center):
			var t := a
			a = b
			b = t
		if out.is_empty() or a.distance_to(trunk.center) < trunk.radius - 0.2:
			out.append(PackedVector2Array([b]))
		else:
			out[out.size() - 1].append(b)
	return out


## An iron lantern hanging by a chain from a point under a limb, its ring at LANTERN_AT.
func _hanging_lantern(from: Vector3) -> void:
	var at := Vector3(from.x, LANTERN_AT, from.z)
	kit.chain(from, at, 0.0, 0.7)
	_lantern(at - Vector3(0, LANTERN_SIZE.y * 0.5 + 0.06, 0))


## A small iron lantern (cap, four posts, the warm glass of TombKit.WARM, a foot) with its light (no shadow), its
## middle at `at`.
func _lantern(at: Vector3) -> void:
	var s := LANTERN_SIZE
	var ir := tomb.iron()
	var glass := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(s.x * 0.78, s.y * 0.72, s.z * 0.78)
	glass.mesh = bm
	glass.material_override = tomb.unlit(TombKit.WARM.glass)
	glass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	glass.position = at
	add_child(glass)
	for cx: float in [-1.0, 1.0]:
		for cz: float in [-1.0, 1.0]:
			m.box(at + Vector3(cx * s.x * 0.45, 0, cz * s.z * 0.45), Vector3(0.04, s.y * 0.8, 0.04), 0.0, ir, false)
	m.box(at + Vector3(0, -s.y * 0.42, 0), Vector3(s.x, 0.06, s.z), 0.0, ir, false)
	m.point(at + Vector3(0, s.y * 0.38, 0), s.x * 1.05, s.y * 0.35, 0.0, 0.0, ir)
	var l := OmniLight3D.new()
	l.position = at
	l.light_color = TombKit.WARM.light
	l.light_energy = LANTERN_LIGHT.x
	l.omni_range = LANTERN_LIGHT.y
	l.light_cull_mask = ~Arena.CROWD_LAYER
	add_child(l)


# ---------- the walls ----------

func _walls() -> void:
	m.layers = 1 | ArenaKit.FACADE_LAYER
	var b := arena.shape().bounds()
	# north: from the north-west cut to the north-east corner, the door's recess left open
	var north_from := b.position.x + 4.0
	_wall(Vector2(north_from, NORTH_Z), Vector2(RECESS.x, NORTH_Z), Vector2(0, 1), NORTH_HEIGHT, NORTH_WINDOWS, 11)
	_wall(Vector2(RECESS.y, NORTH_Z), Vector2(b.end.x + 0.9, NORTH_Z), Vector2(0, 1), NORTH_HEIGHT, [], 12)
	_door_recess()
	# west: from the north-west cut to the way in
	_wall(Vector2(WEST_X, b.position.y + 4.0), Vector2(WEST_X, 9.0), Vector2(1, 0), WEST_HEIGHT, WEST_WINDOWS, 13)
	for z in WEST_BANNERS:
		kit.banner(Vector3(WEST_X + 0.06, BANNER.x, z), PI * 0.5, Vector2(BANNER.y, BANNER.z), ArenaKit.FACADE_LAYER, ArenaKit.Emblem.LION)
	_corners()
	m.layers = 1


## A ruined wall whose inner face runs from a to b along the floor's edge (facing `inward`), its top between
## height.x and height.y and broken lower toward its ends, with windows at the given places along it (x for a wall
## along x, z for one along z).
func _wall(a: Vector2, b: Vector2, inward: Vector2, height: Vector2, windows: Array, seed_: int) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = seed_
	var along := (b - a).normalized()
	var length := a.distance_to(b)
	var back := -inward * WALL_THICK * 0.5
	var yaw := atan2(along.x, along.y) + PI * 0.5
	var key := 0.0 if absf(along.x) > 0.5 else 1.0
	# the statues' niches on this wall (their place along it)
	var niches: Array[float] = []
	for st in STATUES:
		var sp := Vector2(st.x, st.y)
		var t := (sp - a).dot(along)
		if t > 0.0 and t < length and absf((sp - a).dot(inward)) < 2.0:
			niches.append(t)
	var s := 0.0
	while s < length - 0.01:
		var p := a + along * s
		var coord := p.x if key == 0.0 else p.y
		var near_window := false
		for w: float in windows:
			if absf(coord - w) < WINDOW.x * 0.5 + 0.6:
				near_window = true
		var near_niche := false
		for t in niches:
			if absf(s - t) < NICHE.x * 0.5 + 0.6:
				near_niche = true
		var step := SLICE_FINE if near_window or near_niche else r.randf_range(SLICE * 0.8, SLICE * 1.2)
		step = minf(step, length - s)
		var off := INF
		for w: float in windows:
			if absf(coord + step * 0.5 - w) < absf(off):
				off = coord + step * 0.5 - w
		var in_window := absf(off) < WINDOW.x * 0.5
		var in_niche := false
		for t in niches:
			if absf(s + step * 0.5 - t) < NICHE.x * 0.5:
				in_niche = true
		var mid := a + along * (s + step * 0.5) + back
		if in_niche:
			mid -= inward * NICHE.y
		# a slow line of courses along it, broken lower toward its ends and in a few bites
		var wave := 0.5 + 0.3 * sin(s * 0.33 + seed_) + 0.2 * sin(s * 0.91 + seed_ * 2.0)
		var top := lerpf(height.x, height.y, wave) + r.randf_range(-0.12, 0.12)
		var end_share := minf(s, length - s) / maxf(length, 1.0)
		top -= RUIN * (1.0 - smoothstep(0.0, 0.15, end_share))
		top -= RUIN * maxf(0.0, sin(s * 0.47 + seed_ * 3.0) - 0.75) * 4.0
		var stone := Vector3(step + 0.02, 0.0, WALL_THICK)
		if in_window:
			var arch := _arch_top(off)
			m.block(Vector3(mid.x, 0.0, mid.y), stone + Vector3(0, WINDOW_SILL, 0), yaw, _wall_mat)
			var over := WINDOW_SILL + arch
			m.block(Vector3(mid.x, over, mid.y), stone + Vector3(0, maxf(top, WINDOW_SILL + WINDOW.y + 0.9) - over, 0), yaw, _wall_mat)
		else:
			m.block(Vector3(mid.x, 0.0, mid.y), stone + Vector3(0, top, 0), yaw, _wall_mat)
		# a plinth course along its foot (outside the floor)
		m.box(Vector3(mid.x, 0.2, mid.y) - Vector3(back.x, 0, back.y) * 0.5 + Vector3(inward.x, 0, inward.y) * 0.0,
			Vector3(step + 0.02, 0.4, WALL_THICK * 0.5), yaw, _wall_mat, false)
		# a pilaster every PILASTER m standing out of its face, clear of the windows and niches
		var cut := floori((s + step) / PILASTER.x) > floori(s / PILASTER.x)
		if cut and not near_window and not near_niche and s > 1.0 and s < length - 1.0:
			var pp := a + along * (s + step) + inward * PILASTER.z * 0.5
			m.block(Vector3(pp.x, 0.0, pp.y), Vector3(PILASTER.y, top + 0.2, PILASTER.z), yaw, _wall_mat)
		s += step
	# string courses along its face: at the sill and at the windows' springing
	for y: float in COURSES:
		var c0 := a + inward * 0.08
		var c1 := b + inward * 0.08
		var mid2 := (c0 + c1) * 0.5
		m.box(Vector3(mid2.x, y, mid2.y), Vector3(length, 0.16, 0.2), yaw, _wall_mat, false)
	for w: float in windows:
		var c := Vector2(w, a.y) if key == 0.0 else Vector2(a.x, w)
		_window(c, inward)
	# dry grass along its foot
	var n := int(length / 2.2)
	for k in n:
		var p := a.lerp(b, (k + r.randf()) / n) + inward * 0.15
		if arena.shape().contains(p, 0.05):
			_tufts.append(_tuft(p, r))


## The height of a pointed window's arch over its sill at `off` m from its middle (WINDOW.y at the apex), or the
## springing where it stands straight.
func _arch_top(off: float) -> float:
	var half := WINDOW.x * 0.5
	var rad := WINDOW.x * WINDOW_RADIUS
	var cx := rad - half
	var rise := sqrt(rad * rad - cx * cx)
	var spring := WINDOW.y - rise
	var x := absf(off)
	if x >= half:
		return 0.0
	return spring + sqrt(maxf(rad * rad - (x + cx) * (x + cx), 0.0))


## A broken gothic window on a wall: its jambs and arch ring, a mullion broken off, half of its tracery fallen (a
## stone on the sill), and behind it the abyss's violet: a bank of mist, a glow and a light on the walls' stone.
func _window(c: Vector2, inward: Vector2) -> void:
	var face := Vector3(c.x, 0.0, c.y) + Vector3(inward.x, 0, inward.y) * 0.02
	var half := WINDOW.x * 0.5
	var rad := WINDOW.x * WINDOW_RADIUS
	var spring := WINDOW_SILL + WINDOW.y - sqrt(rad * rad - (rad - half) * (rad - half))
	var side := Vector3(-inward.y, 0, inward.x)
	var yaw := atan2(inward.x, inward.y)
	for sd: float in [-1.0, 1.0]:
		m.box(face + side * sd * (half + WINDOW_RING * 0.5) + Vector3(0, (WINDOW_SILL + spring) * 0.5, 0),
			Vector3(WINDOW_RING, spring - WINDOW_SILL, 0.35), yaw, _wall_mat, false)
	m.arch_ring(face + Vector3(0, spring, 0), inward, WINDOW.x, WINDOW_RING, 0.35, _wall_mat, WINDOW_RADIUS)
	# the sill stands SILL_OUT out of the wall's face, never over the walkable floor (art pack 2026-11-17: it reached
	# 0.7 m over it at knee height and the paladin walked through it)
	m.box(face + Vector3(0, WINDOW_SILL - 0.06, 0) + Vector3(inward.x, 0, inward.y) * (SILL_OUT - (WALL_THICK + 0.3) * 0.5),
		Vector3(WINDOW.x + 0.5, 0.14, WALL_THICK + 0.3), yaw, _wall_mat, false)
	# the tracery: a mullion broken at two thirds, one small lancet arch left of the two
	var back := face - Vector3(inward.x, 0, inward.y) * WALL_THICK * 0.5
	m.box(back + Vector3(0, WINDOW_SILL + (spring - WINDOW_SILL) * 0.33, 0), Vector3(0.16, (spring - WINDOW_SILL) * 0.66, 0.2), yaw, _wall_mat, false)
	m.arch_ring(back + side * (-half * 0.5) + Vector3(0, spring, 0), inward, half - 0.08, 0.14, 0.2, _wall_mat, 0.75, 0.0, 0.8)
	m.box(face + Vector3(0, WINDOW_SILL + 0.08, 0) + side * 0.6, Vector3(0.3, 0.16, 0.24), yaw + 0.4, _wall_mat)
	# the violet behind it
	var far := Vector3(c.x, 0.0, c.y) - Vector3(inward.x, 0, inward.y) * 4.0
	kit.mist_bank(far + Vector3(0, WINDOW_SILL + WINDOW.y * 0.4, 0), Vector2(WINDOW.x * 2.6, WINDOW.y * 0.9), WINDOW_MIST, WINDOW_MIST_ALPHA, 0.3, 0.2)
	kit.abyss_glow(far - Vector3(inward.x, 0, inward.y) * 2.0 + Vector3(0, -1.0, 0), Vector2(WINDOW.x * 3.0, WINDOW.y + 3.0),
		deg_to_rad(Feel.live().cam_yaw))
	var l := OmniLight3D.new()
	l.position = Vector3(c.x, WINDOW_SILL + WINDOW.y * 0.55, c.y) + Vector3(inward.x, 0, inward.y) * 1.2
	l.light_color = WINDOW_LIGHT
	l.light_energy = WINDOW_ENERGY
	l.omni_range = WINDOW_REACH
	l.light_cull_mask = ArenaKit.FACADE_LAYER
	add_child(l)


## The recess of the door X1: its sides, the back wall with the door's opening (ArenaRoom draws the arch in it), the
## raised stoops each side where the fire bowls stand.
func _door_recess() -> void:
	var back_z := RECESS_BACK - WALL_THICK * 0.5
	for x: float in [RECESS.x, RECESS.y]:
		var sx := x + (-0.45 if x == RECESS.x else 0.45)
		m.block(Vector3(sx, 0, (NORTH_Z + RECESS_BACK - WALL_THICK) * 0.5), Vector3(0.9, NORTH_HEIGHT.x + 0.4, absf(RECESS_BACK - NORTH_Z) + WALL_THICK), 0.0, _wall_mat)
	for span: Vector2 in [Vector2(RECESS.x, DOOR_OPEN.x), Vector2(DOOR_OPEN.y, RECESS.y)]:
		m.block(Vector3((span.x + span.y) * 0.5, 0, back_z), Vector3(span.y - span.x, NORTH_HEIGHT.y - 0.4, WALL_THICK), 0.0, _wall_mat)
		m.block(Vector3((span.x + span.y) * 0.5, 0, (NORTH_Z + RECESS_BACK) * 0.5), Vector3(span.y - span.x, STOOP, absf(RECESS_BACK - NORTH_Z)), 0.0)
	m.block(Vector3((DOOR_OPEN.x + DOOR_OPEN.y) * 0.5, DOOR_TOP, back_z), Vector3(DOOR_OPEN.y - DOOR_OPEN.x, NORTH_HEIGHT.y - 0.4 - DOOR_TOP, WALL_THICK), 0.0, _wall_mat)
	# a gable of stone over the door
	m.point(Vector3((DOOR_OPEN.x + DOOR_OPEN.y) * 0.5, NORTH_HEIGHT.y - 0.4, back_z), DOOR_OPEN.y - DOOR_OPEN.x + 1.2, 1.6, 0.0, 0.0, _wall_mat)


## The corners: the north-west cut's broken pier with a buttress leaning on the wall, and the north-east tower pier.
func _corners() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 77
	var nw := Vector3(NW_PIER.x, 0, NW_PIER.y)
	m.block(nw, Vector3(2.2, 0.6, 2.2), PI * 0.25, _wall_mat)
	var y := 0.6
	var w := 1.8
	while y < NW_PIER.z:
		var h := r.randf_range(0.8, 1.3)
		m.block(nw + Vector3(0, y, 0), Vector3(w, h, w), PI * 0.25 + r.randf_range(-0.04, 0.04), _wall_mat)
		y += h
		w *= 0.97
	# its broken top: two blocks left askew, one fallen against it
	m.box(nw + Vector3(0.3, y + 0.3, -0.2), Vector3(0.9, 0.6, 0.8), 0.5, _wall_mat).rotate_object_local(Vector3.FORWARD, 0.25)
	m.box(nw + Vector3(-1.4, 0.35, -0.9), Vector3(1.0, 0.7, 0.8), 0.9, _wall_mat).rotate_object_local(Vector3.RIGHT, 0.2)
	# the buttress: steps leaning on the pier along the cut, outside it (art pack 2026-11-17: they ran south over the
	# walkable floor, stone the paladin walked through; tools/fit_probe.gd)
	var down_cut := Vector3(-1.0, 0.0, 1.0).normalized()
	for k in 4:
		var p := nw + down_cut * (1.6 + k * 0.7)
		m.block(p, Vector3(0.75, 4.4 - k * 1.0, 1.0), PI * 0.25, _wall_mat)
	# the low wall along the cut, broken
	var a := Vector2(-17.0, -10.0)
	var b := Vector2(-13.0, -14.0)
	var out := Vector2(-1, -1).normalized()
	for k in 4:
		var p := a.lerp(b, (k + 0.5) / 4.0) + out * CUT_WALL_OUT
		m.block(Vector3(p.x, 0, p.y), Vector3(1.4, r.randf_range(1.2, 2.8), 0.9), PI * 0.25, _wall_mat)
	var ne := Vector3(NE_PIER.x, 0, NE_PIER.y)
	m.block(ne, Vector3(1.9, NE_PIER.z, 1.9), 0.0, _wall_mat)
	m.block(ne + Vector3(0, NE_PIER.z, 0), Vector3(2.2, 0.3, 2.2), 0.0, _wall_mat)
	m.pinnacle(ne + Vector3(0, NE_PIER.z + 0.3, 0), 1.0, 2.0, _wall_mat)


# ---------- the front ----------

## Pointed arches in the cliff under an edge (facing out over the abyss), with piers between.
func _cliff_arches(a: Vector2, b: Vector2, out: Vector2) -> void:
	var length := a.distance_to(b)
	var n := maxi(1, floori(length / ARCH_EVERY))
	if _deep == null:
		_deep = m.depth_stone(MIST, ARCH_FADE).duplicate() as ShaderMaterial
		for k in CLIFF:
			_deep.set_shader_parameter(k, CLIFF[k])
	var deep := _deep
	var yaw := atan2(out.x, out.y)
	for k in n:
		var c := a.lerp(b, (k + 0.5) / n) + out * 0.35
		m.arch_ring(Vector3(c.x, -ARCH.z, c.y), out, ARCH.x, ARCH.y, 0.9, deep, 0.8)
		var pier := a.lerp(b, float(k) / n) + out * 0.4
		m.box(Vector3(pier.x, -ARCH.z * 0.5 - 1.2, pier.y), Vector3(ARCH_PIER.x, ARCH.z + 6.0, ARCH_PIER.y), yaw, deep, false)


# ---------- the exits and the way in ----------

## The way in: stairs down from the south-west cut (the floor's edge there keeps only its gold filet, edge()).
func _entry() -> void:
	var out := Vector2(-1, 1).normalized()
	var steps := int(STAIRS.x)
	var foot := ENTRY + out * (STAIRS.z * (steps + 0.5))
	m.stairs(Vector3(foot.x, -STAIRS.y * steps, foot.y), -out, ENTRY_WIDTH, steps, STAIRS.y, STAIRS.z)


# ---------- statues and grass ----------

func _statues() -> void:
	for s in STATUES:
		var face := Vector2(sin(deg_to_rad(s.z)), cos(deg_to_rad(s.z)))
		kit.statue(Vector2(s.x, s.y), deg_to_rad(s.z), s.w, 0.0, ArenaKit.STATUE_VALUE, false)
		# its niche is cut in the wall (_wall); a pointed arch frames it on the wall's face
		var edge := Vector2(s.x, s.y) + face * 0.85
		m.layers = 1 | ArenaKit.FACADE_LAYER
		m.pointed_arch(Vector3(edge.x, 0, edge.y), face, NICHE.x, s.w * 1.45, 0.35, 0.6, _wall_mat)
		m.layers = 1


## A tuft of dry grass at p (its turn and size by r).
func _tuft(p: Vector2, r: RandomNumberGenerator) -> Transform3D:
	var size := r.randf_range(GRASS_SIZE.x, GRASS_SIZE.y)
	return Transform3D(Basis(Vector3.UP, r.randf() * TAU).scaled(Vector3(size, size, size)), Vector3(p.x, 0.0, p.y))


## Up to `count` tufts round p, wherever the floor is open.
func _tuft_near(p: Vector2, r: RandomNumberGenerator, count: int) -> void:
	for k in count:
		var q := p + Vector2(r.randf_range(-0.35, 0.35), r.randf_range(-0.35, 0.35))
		if arena.shape().contains(q, 0.05):
			_tufts.append(_tuft(q, r))


## All the tufts in one MultiMesh (two crossed cards each), GRASS at most.
func _grass() -> void:
	if _tufts.is_empty():
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for k in 2:
		var a := PI * 0.5 * k
		var d := Vector3(cos(a), 0, sin(a)) * 0.5
		var quad: Array[Vector3] = [-d, d, d + Vector3.UP, -d + Vector3.UP]
		var uv: Array[Vector2] = [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
		for i: int in [0, 1, 2, 0, 2, 3]:
			st.set_normal(Vector3.UP)
			st.set_uv(uv[i])
			st.add_vertex(quad[i])
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = st.commit()
	var n := mini(_tufts.size(), GRASS)
	mm.instance_count = n
	# spread the ones kept over all the places that asked
	for i in n:
		mm.set_instance_transform(i, _tufts[int(float(i) * _tufts.size() / n)])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://assets/shaders/dry_grass.gdshader")
	mmi.material_override = mat
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mmi)


# ---------- light and air ----------

## The cold beam from high behind on the tree: its branches cast long shadows on the floor, kept light.
func _beam() -> void:
	var s := SpotLight3D.new()
	add_child(s)
	s.look_at_from_position(BEAM_FROM, BEAM_AT)
	s.light_color = BEAM_COLOR
	s.light_energy = (BEAM_ENERGY.y if variant_b else BEAM_ENERGY.x) * (COMPAT_LIGHT if _compat() else 1.0)
	s.spot_angle = BEAM_CONE
	s.spot_range = BEAM_REACH
	s.spot_attenuation = 0.4
	s.shadow_enabled = true
	s.shadow_opacity = BEAM_SHADOW
	s.light_cull_mask = ~Arena.CROWD_LAYER

