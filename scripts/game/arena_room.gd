class_name ArenaRoom
extends Node3D
## The look of an arena of cycle C12 (the crypt, the rift hall, the garden), drawn from its RoomLayout: the floor
## (the catacomb floor's shader, its slabs and colours the arena's: floor_look) with its holes, every edge of it
## (edge: by default the broken edge over the abyss, spec 1.3), the abyss's mist and violet glow, each obstacle drawn
## on its own footprint (ArenaObstacle.piece: the collision and the look come from the same data; the funerary pieces
## are TombKit's), the doors (stairs going down, the arch of a door in a wall, the grille of a door not used, the
## lantern of a door used), the arena's air (air: dressed when it is built, given back when it leaves) and its light.
## Each arena's script (CryptLook, RiftLook, GardenLook) overrides what is its own, following
## docs/art/cycle12_arenas_spec.md. Collision never comes from here (Arena._build_arena reads the layout).

## The looks an arena may have (RoomLayout.look) and the script of each.
const LOOKS: Array[StringName] = [&"crypt", &"rift", &"garden", &"sanctuary", &"bridge", &"runes", &"trial", &"altar"]
## How deep the cliffs under the floor's edges drop, and the abyss under them.
const DEPTH := 22.0
## A render layer only an arena's floor is on (with 1), for a fill light of the floor alone (floor_layers; M-1, the
## crypt). Not used by anything else (2 the crowd, 4 the depths, 8 the facade, 16 the statues, 32 the stone tree).
const FLOOR_LAYER := 64
## A lip of stone along every edge: its height under the floor and how far it stands out.
const LIP := Vector2(0.35, 0.18)
## Points along the floor's edges for its triangles (meters apart), and inside it; the floor is cut in squares this
## big (each only takes the lights near it, which the browser's renderer needs).
const EDGE_STEP := 0.5
const FILL_STEP := 2.0
const FLOOR_CELL := 8.0
## The violet light under each hole (the abyss's).
const ABYSS_LIGHT_ENERGY := 4.0
const ABYSS_LIGHT_Y := -9.0
## A door's light when dim (Arena.light_exit lights it when it opens).
const DOOR_DIM := 0.6
## The broken edge (spec 1.3): a tooth of stone every TOOTH_STEP meters (range), its length along the edge, how far
## it stands out, how tall; its top under the floor by TOOTH_DROP; one in TOOTH_GAP is a gap instead (missing
## stones); the slabs of the brink sunk SAG under the floor in a band SAG_BAND wide; loose shards falling in the first
## meters (SHARDS per meter, their size).
const TOOTH_STEP := Vector2(0.8, 2.0)
const TOOTH_LENGTH := Vector2(0.4, 1.2)
const TOOTH_OUT := Vector2(0.15, 0.55)
const TOOTH_TALL := Vector2(0.6, 2.2)
const TOOTH_DROP := Vector2(0.06, 0.4)
const TOOTH_GAP := 0.25
const SAG := Vector2(0.05, 0.25)
const SAG_BAND := 0.3
const SHARDS := 0.35
const SHARD := Vector2(0.15, 0.4)
## A balustrade over the abyss stands this far out of the edge (its posts never on the floor); broken: runs of
## BALUSTRADE_RUN meters (range) with gaps of BALUSTRADE_GAP between them.
const BALUSTRADE_OUT := 0.55
const BALUSTRADE_RUN := Vector2(2.0, 4.0)
const BALUSTRADE_GAP := Vector2(1.0, 2.0)
## The thread of old gold inlaid along a bare edge (spec 3.1): its width and how far in from the drop.
const FILET := Vector2(0.05, 0.22)
## The stairs of a door going down out of the room: steps, rise and run of each; the low cheeks beside them.
const EXIT_STEPS := 7
const EXIT_RISE := 0.24
const EXIT_RUN := 0.42
const EXIT_CHEEK := Vector2(0.55, 0.9)
## A door in a wall: the pointed arch over its mouth (opening a little wider than the mouth, height).
const WALL_DOOR := Vector2(4.0, 5.2)
const JAMB := 0.3
## A sarcophagus of the arenas (spec 1.2): plinth, lid (height, overhang), the sword on its lid, its stone (times the
## arena's) and the lid's; a box at least TOMB_FROM long is the great tomb (spec 1.3).
const SARC_PLINTH := 0.15
const SARC_LID := Vector2(0.15, 0.05)
const SARC_SWORD := 1.5
const SARC_TINT := 1.25
const SARC_LID_LIGHT := 1.5
const TOMB_FROM := 3.5
## A column at least this tall is whole (with its capital and the spring of an arch); lower ones are broken.
const WHOLE_COLUMN := 4.5
## A wall-like block (a ruined wall, a dividing wall): its top broken in steps this big (range, meters down).
const RUIN_STEP := Vector2(0.2, 0.6)
## Candles (on top of pieces, never loose on the floor, spec 0.3): heights and radii (range), how many at most, the
## light of a lit group (energy, range) and the warm halo over it.
const CANDLE_HEIGHT := Vector2(0.12, 0.35)
const CANDLE_RADIUS := Vector2(0.05, 0.09)
const CANDLE_MAX := 5
const CANDLE_LIGHT := 1.2
const CANDLE_RANGE := 2.8
const CANDLE_COLOR := Color(1.0, 0.7, 0.4)
const CANDLE_HALO := 0.45
const CANDLE_HALO_ALPHA := 0.3
## A bridge: its deck's thickness under the floor (the cornice) and how far it stands out of the walkable 5 m on each
## side (the parapet stands on it), the arch under it (its crown this far under the deck, the ring's width), the piers
## going down into the mist. The arch, its haunches and the piers are the depths' dark stone (no light of their own).
const DECK := 0.6
const DECK_OUT := 0.65
const ARCH_CROWN := 2.5
const ARCH_RING := 0.7
const ARCH_RADIUS := 0.8
## The deck's own paving over the floor (F-2, so a bridge never reads as a strip of the floor): slabs running along the
## span (length range, rows across between the kerbs, the joint, their top over the floor, their stone times the
## arena's), a kerb of lighter stone along both sides of the walkable 5 m (width, top, stone), a dark seam where the
## deck meets the platform (width), the joints' and seams' stone (the depths' dark).
const DECK_SLAB := Vector2(1.1, 2.1)
const DECK_ROWS := 4
const DECK_JOINT := 0.06
const DECK_TOP := 0.016
const DECK_TINT := Color(0.8, 0.8, 0.8)
const KERB := Vector3(0.3, 0.022, 1.1)
const SEAM := 0.08
const SEAM_TOP := 0.008
## The open parapet outside the walkable 5 m (spec 1.3: low, 0.5 m wide; never see-through): its height, its depth, its
## middle's distance out of the walkable edge; the curb and the rail (height, depth); balusters (side, spacing, the
## belly's side and height); a post every PARAPET_POST meters (side).
const PARAPET := Vector3(0.9, 0.4, 0.32)
const PARAPET_CURB := Vector2(0.18, 0.4)
const PARAPET_RAIL := Vector2(0.16, 0.38)
const BALUSTER := Vector4(0.13, 0.42, 0.2, 0.16)
const PARAPET_POST := 3.0
const PARAPET_POST_SIDE := 0.36
## A pillar at each of the four heads (F-2: 1.4 m; side, cap) and under each the abutment (F-3, "pegão") the bridge
## springs from: a block of cut stone against the rift's wall beside the deck (along the wall out of the walkable edge,
## into the rift, its cut stone this deep, then the depths' stone down to ABUTMENT_FOOT).
const HEAD := Vector3(0.55, 1.4, 0.2)
const HEAD_LANTERN := Vector3(0.5, 1.0, 0.5)
const ABUTMENT := Vector3(1.35, 1.1, 1.3)
const ABUTMENT_FOOT := -5.0
## Its lanterns (one at each end, diagonally): warm, a little stronger.
const BRIDGE_LAMP_ENERGY := 1.5
const BRIDGE_LAMP_RANGE := 4.5
## The rift's broken lips (spec 1.3, F-3): chunks of the brink's slabs standing out past the drop (length along the
## lip, how far out at each end, their top sunk under the floor), a stretch with none between them (a missing stone),
## each chunk's cut stone under its paving and the depths' stone hanging lower (heights); the ledge under the west
## lip's balustrade (out of the drop); stones hanging in a gap (share, size, depth).
const LIP_TOOTH := Vector2(0.4, 1.2)
const LIP_OUT := Vector2(0.3, 1.0)
const LIP_SINK := Vector2(0.03, 0.16)
const LIP_GAP := Vector2(0.3, 0.9)
const LIP_STONE := 0.45
const LIP_HANG := Vector2(1.2, 2.6)
const LIP_LEDGE := 1.05
const LIP_FALLEN_SHARE := 0.45
const LIP_FALLEN := Vector2(0.35, 0.7)
const LIP_FALLEN_DEPTH := Vector2(0.3, 1.1)

## A whole column's head (the crypt's; E5: every arena's whole column that wants it) (ART_REVIEW C-2, spec 1.3: no askew cubes over it): the round capital (necking ring height,
## bell height, how far the bell flares and the abacus reaches as shares of the shaft's radius, abacus height) and two
## arches springing from it as curved voussoirs, across the camera's view so their curve shows (their bearings; span
## of their arch, ring width, the share of the arch each keeps).
const CAPITAL := Vector4(0.09, 0.3, 1.38, 1.55)
const ABACUS := 0.12
const SPRING_BEARINGS: Array[float] = [55.0, 235.0]
const SPRING_ARCH := Vector3(2.2, 0.34, 0.36)
## The springers' depth (a share of the shaft's radius) and the round pieces' sides (smoother than a plain shaft).
const SPRING_DEEP := 1.2
const CAPITAL_SIDES := 18
## The blind window's tracery: mullion width, how deep the panel is set back, the dark of the panel, the broken share.
const WINDOW_MULLION := 0.14
const WINDOW_PANEL_SET := 0.25
const WINDOW_PANEL := Color(0.16, 0.16, 0.18)
## E5: a closed room's wall runs this far past each end of its edge (the corners meet).
const CLOSE_REACH := 0.9
## E5: a wall of a closed room (ArenaRoom.wall): how far its face stands behind the floor's edge, its thickness, the
## cornice on top (height, how far out); a wall cut low at the front (cut_wall): its top, thickness, how far its outer
## face drops into the dark, the dark fill seen on its cut, fallen blocks outside it (per meter).
const FACE_SET := 0.3
const FACE_THICK := 1.4
const WALL_CORNICE := Vector2(0.3, 0.18)
const CUT_WALL := Vector3(0.9, 0.8, 3.0)
const CUT_FILL := 0.55
const CUT_FALLEN := 0.25
## E5: a shaft of light from a hole in the vault (moon_shaft; the sanctuary's moon, the altar's crack, the trial's
## square opening): how far off the plumb it leans (toward the back of the room); no fall-off with distance.
const SHAFT_LEAN := Vector2(-2.0, -2.5)
## E5 spec 7.2: the breath of the next room in the mouth of a door used (breath): a card of light this big (width,
## height), this far beyond the mouth, its foot this far under the floor, its alpha and the brightest channel of its
## colour; the colour of each arena's air (its ambient, pushed to read at a glance) and, for some, a thread of another
## colour through it (the runes' amber).
const BREATH_SIZE := Vector2(4.0, 3.0)
const BREATH_BEYOND := 2.0
const BREATH_FOOT := -1.4
const BREATH_ALPHA := 0.35
const BREATH_PEAK := 0.6
const BREATH: Dictionary = {
	&"hall": Color(0.16, 0.5, 0.5), &"crypt": Color(0.6, 0.42, 0.28), &"rift": Color(0.4, 0.22, 0.6),
	&"garden": Color(0.46, 0.5, 0.56), &"bridge": Color(0.34, 0.44, 0.6), &"sanctuary": Color(0.56, 0.57, 0.6),
	&"runes": Color(0.1, 0.1, 0.14), &"trial": Color(0.52, 0.36, 0.78), &"altar": Color(0.6, 0.5, 0.38),
	&"chamber": Color(0.22, 0.2, 0.55),
}
const BREATH_THREAD: Dictionary = {&"runes": Color(1.0, 0.62, 0.25)}
const BREATH_SHADER := preload("res://assets/shaders/door_breath.gdshader")

## The kinds of edge (edge()): over the abyss, round a hole, the side of a door's mouth.
enum Edge { OUTER, HOLE, MOUTH }

var arena: Arena
var layout: RoomLayout
var kit: ArenaKit
var m: Masonry
var tomb: TombKit
## How many of the doors are used (the others are closed by a grille).
var exits_used := 0
## Lights with shadows placed (spec 0.5: at most 8 an arena).
var shadowed := 0
var _see: ShaderMaterial
var _rng := RandomNumberGenerator.new()
## The walkable floor's material (one for all its cells), once built.
var floor_mat: ShaderMaterial


static func make(look: StringName) -> ArenaRoom:
	match look:
		&"crypt":
			return CryptLook.new()
		&"rift":
			return RiftLook.new()
		&"garden":
			return GardenLook.new()
		&"sanctuary":
			return SanctuaryLook.new()
		&"bridge":
			return BridgeLook.new()
		&"runes":
			return RunesLook.new()
		&"trial":
			return TrialLook.new()
		&"altar":
			return AltarLook.new()
	return ArenaRoom.new()


func build(a: Arena, l: RoomLayout, exit_count: int, seed_: int) -> void:
	arena = a
	layout = l
	exits_used = mini(exit_count, l.exits.size())
	_rng.seed = seed_
	kit = ArenaKit.new(self, seed_)
	m = kit.masonry
	tomb = TombKit.new(m)
	_see = stone().duplicate() as ShaderMaterial
	_see.set_shader_parameter(&"see_through", 1.0)
	_floor()
	_edges()
	_abyss()
	for o in layout.obstacles:
		piece(o)
	_doors()
	_light()
	dress()
	m.merge()
	_dress_air()
	shadowed = _count_shadows()


## Each arena's own pieces and light (the environment artist's: CryptLook, RiftLook, GardenLook). Nothing here may
## block: what blocks is an ArenaObstacle in the layout.
func dress() -> void:
	pass


## The render layers of the floor's cells: an arena that lights its floor alone (a fill light whose light_cull_mask is
## only FLOOR_LAYER, never the walls) adds FLOOR_LAYER.
func floor_layers() -> int:
	return 1


## The floor's shader (null: the catacomb floor's; the runes' chamber its own, rune_floor.gdshader).
func floor_shader() -> Shader:
	return null


## The floor's shader parameters of the arena (catacomb_floor.gdshaderinc uniforms; spec 2.5, 3.5, 4.6).
func floor_look() -> Dictionary:
	return {}


## The arena's stone (times the kit's).
func stone_tint() -> Color:
	return Color.WHITE


## The arena's air (dressed when it is built, given back when it leaves; empty: the world's as it is). Keys: sky,
## fog (colours), fog_depth (begin, end), ambient (colour), ambient_gain (times the world's energy), moon (colour),
## moon_energy, moon_shadow.
func air() -> Dictionary:
	return {}


## The cliffs' stone (depth_stone.gdshader uniforms: stone_color, edge_color...), if not the hall's teal.
func cliff_look() -> Dictionary:
	return {}


## The colour of the abyss's mist under the arena (the cliffs fade into it).
func mist() -> Color:
	return ArenaKit.MIST


func stone(base_y := 0.0) -> ShaderMaterial:
	return m.stone(base_y, stone_tint())


func ashlar(base_y := 0.0) -> ShaderMaterial:
	return m.ashlar(base_y, stone_tint())


## The same stone opening round the paladin behind it (see_through), one twin per material.
func see(mat: ShaderMaterial) -> ShaderMaterial:
	if not _see_twins.has(mat):
		var t := mat.duplicate() as ShaderMaterial
		t.set_shader_parameter(&"see_through", 1.0)
		_see_twins[mat] = t
	return _see_twins[mat]


var _see_twins := {}


# ---------- the floor ----------

## The floor's top, in triangles: points along every edge and on a grid inside, joined (Delaunay), the triangles
## whose middle is on the floor kept, one mesh per FLOOR_CELL square.
func _floor() -> void:
	var f := arena.shape()
	var pts := PackedVector2Array()
	var e := f.edges()
	for i in range(0, e.size(), 2):
		var n := maxi(1, ceili(e[i].distance_to(e[i + 1]) / EDGE_STEP))
		for k in n:
			pts.append(e[i].lerp(e[i + 1], float(k) / n))
	var b := f.bounds()
	var y := b.position.y + FILL_STEP * 0.5
	while y < b.end.y:
		var x := b.position.x + FILL_STEP * 0.5
		while x < b.end.x:
			if f.contains(Vector2(x, y), EDGE_STEP):
				pts.append(Vector2(x, y))
			x += FILL_STEP
		y += FILL_STEP
	var tris := Geometry2D.triangulate_delaunay(pts)
	var cells := {}
	for i in range(0, tris.size(), 3):
		var p0 := pts[tris[i]]
		var p1 := pts[tris[i + 1]]
		var p2 := pts[tris[i + 2]]
		var mid := (p0 + p1 + p2) / 3.0
		if not f.covers(mid):
			continue
		# wound so the face looks up (Godot's front faces turn clockwise as seen; seen from above, x right and z down,
		# that is a positive cross on the floor plane)
		if (p1 - p0).cross(p2 - p0) < 0.0:
			var t := p1
			p1 = p2
			p2 = t
		var key := Vector2i(floori(mid.x / FLOOR_CELL), floori(mid.y / FLOOR_CELL))
		if not cells.has(key):
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			st.set_normal(Vector3.UP)
			cells[key] = st
		var s: SurfaceTool = cells[key]
		for p in [p0, p1, p2]:
			s.set_uv(p)
			s.add_vertex(Vector3(p.x, 0.0, p.y))
	var mat := kit.floor_material(0.0, Vector2.ZERO, minf(b.size.x, b.size.y) * 0.3, floor_shader())
	var look := floor_look()
	for k in look:
		mat.set_shader_parameter(k, look[k])
	floor_mat = mat
	for key in cells:
		var mi := MeshInstance3D.new()
		mi.mesh = (cells[key] as SurfaceTool).commit()
		mi.material_override = mat
		mi.layers = floor_layers()
		add_child(mi)


# ---------- the edges ----------

## Every edge of the floor, by its kind (edge).
func _edges() -> void:
	var f := arena.shape()
	var e := f.edges()
	var faces := SurfaceTool.new()
	faces.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0, e.size(), 2):
		var a := e[i]
		var b := e[i + 1]
		var out := -f.edge_inward(i / 2)
		var probe := (a + b) * 0.5 + out * 0.3
		var kind := Edge.OUTER
		for h in layout.floor.holes:
			if Geometry2D.is_point_in_polygon(probe, h):
				kind = Edge.HOLE
		for k in exits_used:
			if layout.exits[k].mouth.grow(0.05).has_point((a + b) * 0.5):
				kind = Edge.MOUTH
		edge(a, b, out, kind, faces)
	faces.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = faces.commit()
	var deep := m.depth_stone(mist())
	var look := cliff_look()
	if not look.is_empty():
		deep = deep.duplicate() as ShaderMaterial
		for k in look:
			deep.set_shader_parameter(k, look[k])
	mi.material_override = deep
	mi.layers = 1 | ArenaKit.DEPTH_LAYER
	add_child(mi)


## One edge of the floor from a to b, the abyss (or the outside) toward `out`. By default the broken edge over the
## abyss; the side of a door's mouth a plain cut (its cheek is the door's). faces: the cliffs' one mesh.
func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		cliff(a, b, out, faces, EXIT_STEPS * EXIT_RISE + 0.6)
		return
	broken_edge(a, b, out, faces)


## A plain wall of stone under the edge a to b, from just under the floor down `drop` meters, facing `out`.
func cliff(a: Vector2, b: Vector2, out: Vector2, faces: SurfaceTool, drop := DEPTH) -> void:
	var q: Array[Vector3] = [Vector3(a.x, -LIP.x, a.y), Vector3(b.x, -LIP.x, b.y), Vector3(b.x, -drop, b.y), Vector3(a.x, -drop, a.y)]
	# facing out of the floor (clockwise as seen from outside)
	if (b - a).cross(out) < 0.0:
		q = [q[1], q[0], q[3], q[2]]
	for k: int in [0, 1, 2, 0, 2, 3]:
		faces.add_vertex(q[k])
	var o := out * LIP.y
	m.box(Vector3((a.x + b.x) * 0.5 + o.x * 0.5, -LIP.x * 0.5, (a.y + b.y) * 0.5 + o.y * 0.5),
		Vector3(a.distance_to(b) + LIP.y, LIP.x, LIP.y * 2.0), atan2(-(b - a).y, (b - a).x), stone())


## The broken edge of a floor over the abyss (spec 1.3, the hall's cliff for any polygon): the wall of stone down into
## the abyss, along it teeth of stone standing out or missing every TOOTH_STEP, the brink's slabs sunk a little in a
## narrow band outside the edge, loose shards falling below. Everything outside the walkable floor.
func broken_edge(a: Vector2, b: Vector2, out: Vector2, faces: SurfaceTool) -> void:
	cliff(a, b, out, faces)
	var length := a.distance_to(b)
	var along := (b - a) / maxf(length, 0.001)
	var yaw := atan2(-along.y, along.x)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i((a + b) * 10.0))
	var s := r.randf_range(0.0, TOOTH_STEP.x)
	var mat := stone()
	while s < length - 0.2:
		var l := minf(r.randf_range(TOOTH_LENGTH.x, TOOTH_LENGTH.y), length - s)
		var c := a + along * (s + l * 0.5)
		if r.randf() > TOOTH_GAP:
			var o := r.randf_range(TOOTH_OUT.x, TOOTH_OUT.y)
			var tall := r.randf_range(TOOTH_TALL.x, TOOTH_TALL.y)
			var top := -r.randf_range(TOOTH_DROP.x, TOOTH_DROP.y)
			var p := c + out * (o * 0.5 + LIP.y * 0.5)
			m.box(Vector3(p.x, top - tall * 0.5, p.y), Vector3(l * 0.92, tall, o + LIP.y), yaw, mat)
		# a sunk slab of the brink
		if r.randf() < 0.5:
			var sag := r.randf_range(SAG.x, SAG.y)
			var p2 := c + out * SAG_BAND * 0.5
			var slab := m.box(Vector3(p2.x, -sag - 0.06, p2.y), Vector3(l * 0.8, 0.12, SAG_BAND), yaw, mat)
			slab.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.12, 0.05))
		s += l + r.randf_range(0.0, TOOTH_STEP.y - TOOTH_LENGTH.y)
	# shards falling just below
	for k in floori(length * SHARDS):
		var t := r.randf()
		var p3 := a.lerp(b, t) + out * r.randf_range(0.5, 2.0)
		var size := r.randf_range(SHARD.x, SHARD.y)
		var sh := m.box(Vector3(p3.x, -r.randf_range(0.8, 3.0), p3.y), Vector3(size, size * 0.8, size * 0.9), r.randf() * TAU, mat)
		sh.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.8, 0.8))


## A balustrade standing BALUSTRADE_OUT outside the edge a to b; broken: in runs with gaps and a fallen stump. On an
## edge the camera looks across (its outside toward the camera) it opens round the paladin behind it (see_through).
func balustrade_edge(a: Vector2, b: Vector2, out: Vector2, broken := false, mat: Material = null) -> void:
	if mat == null:
		var yaw := deg_to_rad(Feel.live().cam_yaw)
		mat = see(stone()) if out.dot(Vector2(sin(yaw), cos(yaw))) > 0.2 else stone()
	var length := a.distance_to(b)
	var along := (b - a) / maxf(length, 0.001)
	var off := out * BALUSTRADE_OUT
	if not broken:
		m.balustrade(Vector3(a.x + off.x, 0.0, a.y + off.y), Vector3(b.x + off.x, 0.0, b.y + off.y), true, mat)
		return
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i((a - b) * 10.0))
	var s := 0.0
	while s < length - 0.5:
		var run := minf(r.randf_range(BALUSTRADE_RUN.x, BALUSTRADE_RUN.y), length - s)
		var p0 := a + along * s + off
		var p1 := a + along * (s + run) + off
		m.balustrade(Vector3(p0.x, 0.0, p0.y), Vector3(p1.x, 0.0, p1.y), true, mat)
		s += run
		var gap := minf(r.randf_range(BALUSTRADE_GAP.x, BALUSTRADE_GAP.y), length - s)
		if gap > 0.6:
			# the stump of a broken post in the gap, and the curb running on under it
			var g := a + along * (s + gap * 0.5) + off
			m.box(Vector3(g.x, Masonry.CURB * 0.5, g.y), Vector3(gap, Masonry.CURB, Masonry.RAIL.y + 0.1), atan2(-along.y, along.x), mat)
			var stub := m.box(Vector3(g.x, 0.3, g.y), Vector3(Masonry.POST.x * 0.8, 0.6, Masonry.POST.z * 0.8), r.randf() * 0.4, mat)
			stub.rotate_object_local(Vector3.BACK, r.randf_range(-0.15, 0.15))
		s += gap


## The thread of old gold inlaid in the floor FILET.y in from the bare edge a to b (the limit drawn on the floor).
func filet(a: Vector2, b: Vector2, out: Vector2) -> void:
	var c := (a + b) * 0.5 - out * FILET.y
	var d := b - a
	tomb.bar(Vector3(c.x, 0.004, c.y), Vector3(d.length(), 0.008, FILET.x), atan2(-d.y, d.x), tomb.gold())


## The abyss's mist far below, and a violet light under each hole and along the outer edge.
func _abyss() -> void:
	var b := arena.shape().bounds()
	kit.abyss(b.size * 0.5 + Vector2(6, 6), DEPTH, false, mist())
	var spots: Array[Vector2] = []
	for h in arena.shape().holes:
		var c := Vector2.ZERO
		for v in h:
			c += v
		spots.append(c / maxf(1.0, h.size()))
	for s: Vector2 in [Vector2(b.position.x - 6.0, b.get_center().y), Vector2(b.end.x + 6.0, b.get_center().y)]:
		spots.append(s)
	for s in spots:
		var l := OmniLight3D.new()
		l.position = Vector3(s.x, ABYSS_LIGHT_Y, s.y)
		l.light_color = CatacombHall.ABYSS_LIGHT
		l.light_energy = ABYSS_LIGHT_ENERGY
		l.omni_range = 18.0
		l.light_cull_mask = ArenaKit.DEPTH_LAYER
		add_child(l)


# ---------- what stands on it ----------

## Draws one obstacle on its own footprint, by its piece.
func piece(o: ArenaObstacle) -> void:
	var at := Vector3(o.center.x, 0.0, o.center.y)
	var mat: Material = _see if o.see_through else null
	match o.piece:
		&"column":
			tomb.column(o.center, o.radius, o.height, see(stone()) if o.see_through else stone(), o.height < WHOLE_COLUMN)
		&"trunk":
			m.block(at, Vector3(o.radius * 2.4, 0.3, o.radius * 2.4), 0.0, mat)
			m.shaft(at + Vector3(0, 0.3, 0), o.radius, o.height - 0.3, mat)
		&"sarcophagus":
			sarcophagus(o)
		&"statue":
			kit.statue(o.center, o.yaw, o.height, 0.0, ArenaKit.STATUE_VALUE, false)
		&"brazier":
			kit.brazier(o.center, 0.0, false)
		&"bench", &"bench_broken":
			var long_x := o.half.x >= o.half.y
			tomb.bench(o.center, o.half if long_x else Vector2(o.half.y, o.half.x), -o.yaw + (0.0 if long_x else PI * 0.5),
				stone(), o.piece == &"bench_broken")
		&"column_base":
			# the stump of a fallen column: its plinth, base and a short broken shaft
			tomb.column(o.center, o.radius, maxf(o.height, TombKit.COLUMN_BASE + 0.4), stone(), true)
		&"drums":
			drums(o)
		&"quiet":
			pass
		&"block":
			if o.height <= 1.0 and o.shape == ArenaObstacle.Shape.BOX:
				var ax := Vector2(cos(o.yaw), sin(o.yaw)) * (o.half.x - o.half.y)
				tomb.low_wall(o.center - ax, o.center + ax, o.half.y * 2.0, o.height, stone())
			elif o.shape == ArenaObstacle.Shape.BOX:
				ruin_wall(o)
			else:
				m.shaft(at, o.radius, o.height, mat)
		_:
			if o.shape == ArenaObstacle.Shape.CIRCLE:
				m.shaft(at, o.radius, o.height, mat)
			else:
				m.block(at, Vector3(o.half.x * 2.0, o.height, o.half.y * 2.0), -o.yaw, mat)


## A sarcophagus on its footprint (spec 1.2): a plinth the footprint's size, the chest on it with its lid, the sword
## in stone on the lid (no gold, no lion); a long one is the great tomb on its two steps (TombKit.tomb).
func sarcophagus(o: ArenaObstacle) -> Vector3:
	var long_x := o.half.x >= o.half.y
	var yaw := -o.yaw + (0.0 if long_x else PI * 0.5)
	var half := o.half if long_x else Vector2(o.half.y, o.half.x)
	var st := stone()
	var light := m.stone(0.0, stone_tint() * SARC_LID_LIGHT)
	var hollow := m.stone(0.0, stone_tint() * 0.6)
	if o.see_through:
		st = see(st)
		light = see(light)
		hollow = see(hollow)
	if half.x * 2.0 >= TOMB_FROM:
		return tomb.tomb(o.center, half, yaw, o.height, st, light, hollow)
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	m.block(foot, Vector3(half.x * 2.0, SARC_PLINTH, half.y * 2.0), yaw, st, false)
	var body := Vector3(half.x * 2.0 - 0.2, half.y * 2.0 - 0.2, o.height - SARC_PLINTH - SARC_LID.x)
	return tomb.sarcophagus(foot + Vector3(0, SARC_PLINTH, 0), yaw, body, m.stone(0.0, stone_tint() * SARC_TINT), light, hollow,
		SARC_SWORD, light, SARC_LID)


## A ruined wall on a box footprint: cut stone up to its top, the top broken in steps, opening round the paladin
## behind it if it is tall (see_through).
func ruin_wall(o: ArenaObstacle) -> void:
	var mat := see(ashlar()) if o.see_through else ashlar()
	var long_x := o.half.x >= o.half.y
	var yaw := -o.yaw + (0.0 if long_x else PI * 0.5)
	var half := o.half if long_x else Vector2(o.half.y, o.half.x)
	var basis := Basis(Vector3.UP, yaw)
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	var low := o.height * 0.7
	m.block(foot, Vector3(half.x * 2.0, low, half.y * 2.0), yaw, mat, false)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i(o.center * 10.0))
	var x := -half.x
	while x < half.x - 0.1:
		var w := minf(r.randf_range(0.5, 1.1), half.x - x)
		var h := o.height - low - r.randf_range(RUIN_STEP.x, RUIN_STEP.y) * (0.0 if r.randf() < 0.3 else 1.0)
		if h > 0.1:
			m.block(foot + basis * Vector3(x + w * 0.5, low, 0), Vector3(w - 0.04, h, half.y * 2.0 - 0.06), yaw, mat)
		x += w


## A group of candles standing on top of something at `at` (never loose on the floor): count candles, tallest in the
## middle; lit (a flame, a halo) or burnt out; light: a warm light over them (shadow: it casts shadows).
func candles(at: Vector3, count: int, lit := true, light := false, shadow := false, energy := CANDLE_LIGHT) -> OmniLight3D:
	var n := clampi(count, 1, CANDLE_MAX)
	var turn := _rng.randf() * TAU
	for i in n:
		var t := 1.0 if i == 0 else _rng.randf_range(0.0, 0.7)
		var r := lerpf(CANDLE_RADIUS.x, CANDLE_RADIUS.y, t)
		var p := at
		if i > 0:
			var a := turn + TAU * float(i) / float(maxi(1, n - 1)) + _rng.randf_range(-0.3, 0.3)
			p += Vector3(cos(a), 0, sin(a)) * (CANDLE_RADIUS.y + r + _rng.randf_range(0.03, 0.12))
		var h := lerpf(CANDLE_HEIGHT.x, CANDLE_HEIGHT.y, t)
		if lit:
			m.candle(p, h, r)
		else:
			# a burnt-out stub: the wax and its pool, a dark wick, no flame
			m.shaft(p, r, h * 0.7, _wax_out())
			m.box(p + Vector3(0, h * 0.7 + 0.02, 0), Vector3(0.012, 0.04, 0.012), 0.0, tomb.iron(), false)
	if not lit:
		return null
	var glow := MeshInstance3D.new()
	glow.mesh = Fx.quad(CANDLE_HALO, Color(0.8, 0.45, 0.18) * CANDLE_HALO_ALPHA)
	glow.position = at + Vector3(0, CANDLE_HEIGHT.y * 0.9, 0)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(glow)
	if not light:
		return null
	var l := OmniLight3D.new()
	l.position = at + Vector3(0, 0.7, 0)
	l.light_color = CANDLE_COLOR
	l.light_energy = energy
	l.omni_range = CANDLE_RANGE
	l.shadow_enabled = shadow
	l.light_cull_mask = ~Arena.CROWD_LAYER
	add_child(l)
	return l


## Candles in a row from a to b (on a ledge, a step, the rim of a base): n of them, uneven heights; lit or burnt out.
func candle_line(a: Vector3, b: Vector3, n: int, lit := true) -> void:
	for i in n:
		var t := (i + 0.5) / n
		var k := _rng.randf()
		var p := a.lerp(b, t) + Vector3(_rng.randf_range(-0.03, 0.03), 0.0, _rng.randf_range(-0.03, 0.03))
		var h := lerpf(CANDLE_HEIGHT.x, CANDLE_HEIGHT.y, k)
		var r := lerpf(CANDLE_RADIUS.x, CANDLE_RADIUS.y, k * 0.7)
		if lit:
			m.candle(p, h, r)
		else:
			m.shaft(p, r, h * 0.7, _wax_out())


## A warm light over candles at `at` (shadow: it casts shadows, counted against the arena's 8).
func warm_light(at: Vector3, energy := CANDLE_LIGHT, shadow := false, reach := CANDLE_RANGE) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.position = at
	l.light_color = CANDLE_COLOR
	l.light_energy = energy
	l.omni_range = reach
	l.shadow_enabled = shadow
	l.light_cull_mask = ~Arena.CROWD_LAYER
	add_child(l)
	return l


var _wax_dark: StandardMaterial3D


func _wax_out() -> StandardMaterial3D:
	if _wax_dark == null:
		_wax_dark = StandardMaterial3D.new()
		_wax_dark.albedo_color = Masonry.WAX * 0.55
		_wax_dark.roughness = 0.7
	return _wax_dark


# ---------- bridges and lips (out of the Salão das Fendas, RiftLook; E5: every arena's) ----------

## A lip of the rift or of a hole (spec 1.3, F-3): the wall going down into the dark (the cliffs' one mesh), and along
## it chunks of the brink's slabs standing out past the drop at uneven lengths (paved with the floor's slabs, sunk a
## little, cut stone under the paving, the depths' stone hanging lower), stretches with none between them (a stone
## missing; sometimes one fallen in the gap), loose shards below. ledge: a shelf this far out under a balustrade, the
## chunks past it. Nothing on the walkable floor.
func broken_lip(a: Vector2, b: Vector2, out: Vector2, faces: SurfaceTool, ledge := 0.0) -> void:
	lip_wall(a, b, out, faces)
	var length := a.distance_to(b)
	var along := (b - a) / maxf(length, 0.001)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i((a + b) * 10.0))
	var cut := stone()
	if ledge > 0.0:
		chunk(PackedVector2Array([a, b, b + out * ledge, a + out * ledge]), -LIP_SINK.x, LIP_HANG.x)
	var s := r.randf_range(0.0, LIP_GAP.x)
	while s < length - LIP_TOOTH.x * 0.5:
		var l := minf(r.randf_range(LIP_TOOTH.x, LIP_TOOTH.y), length - s)
		var p0 := a + along * s + out * ledge
		var p1 := a + along * (s + l) + out * ledge
		var o0 := r.randf_range(LIP_OUT.x, LIP_OUT.y)
		var o1 := r.randf_range(LIP_OUT.x, LIP_OUT.y)
		var tip := (p0 + p1) * 0.5 + out * maxf(o0, o1) * r.randf_range(0.7, 1.15) + along * l * r.randf_range(-0.15, 0.15)
		chunk(PackedVector2Array([p0, p1, p1 + out * o1, tip, p0 + out * o0]), -r.randf_range(LIP_SINK.x, LIP_SINK.y),
			r.randf_range(LIP_HANG.x, LIP_HANG.y))
		s += l
		var gap := r.randf_range(LIP_GAP.x, LIP_GAP.y)
		if r.randf() < LIP_FALLEN_SHARE and s + gap < length:
			var g := a + along * (s + gap * 0.5) + out * (ledge + r.randf_range(0.2, 0.6))
			var size := r.randf_range(LIP_FALLEN.x, LIP_FALLEN.y)
			var fallen := m.box(Vector3(g.x, -r.randf_range(LIP_FALLEN_DEPTH.x, LIP_FALLEN_DEPTH.y), g.y), Vector3(size, size * 0.6, size * 0.8), r.randf() * TAU, cut)
			fallen.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.6, 0.6))
		s += gap
	# shards falling just below
	for k in floori(length * SHARDS):
		var p3 := a.lerp(b, r.randf()) + out * (ledge + r.randf_range(0.6, 2.0))
		var size := r.randf_range(SHARD.x, SHARD.y)
		var sh := m.box(Vector3(p3.x, -r.randf_range(0.8, 2.5), p3.y), Vector3(size, size * 0.8, size * 0.9), r.randf() * TAU, cut)
		sh.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.8, 0.8))


## The plain wall under a lip from the floor down into the abyss (the cliffs' mesh, the depths' dark stone; no
## straight kerb along it: the chunks are the brink).
func lip_wall(a: Vector2, b: Vector2, out: Vector2, faces: SurfaceTool) -> void:
	var q: Array[Vector3] = [Vector3(a.x, 0.0, a.y), Vector3(b.x, 0.0, b.y), Vector3(b.x, -DEPTH, b.y), Vector3(a.x, -DEPTH, a.y)]
	# facing out of the floor (clockwise as seen from outside)
	if (b - a).cross(out) < 0.0:
		q = [q[1], q[0], q[3], q[2]]
	for k: int in [0, 1, 2, 0, 2, 3]:
		faces.add_vertex(q[k])


## One chunk of the brink on the footprint poly: the floor's paving on top at `top`, cut stone under it, the depths'
## dark stone hanging `hang` meters lower, a little inset. On the depths' layer too (the violet from below).
func chunk(poly: PackedVector2Array, top: float, hang: float) -> void:
	m.layers = 1 | ArenaKit.DEPTH_LAYER
	m.prism(poly, top - 0.04, top, paving())
	m.prism(poly, top - LIP_STONE, top - 0.04, stone())
	var c := Vector2.ZERO
	for p in poly:
		c += p
	c /= poly.size()
	var inset := PackedVector2Array()
	for p in poly:
		inset.append(p + (c - p).limit_length(0.06))
	m.prism(inset, top - LIP_STONE - hang, top - LIP_STONE, deep())
	m.layers = 1



var _deep_mat: ShaderMaterial
var _paving_mat: ShaderMaterial


## The depths' dark stone of this hall (the cliffs' look): arches, piers, the lips' hanging stone, joints.
func deep() -> ShaderMaterial:
	if _deep_mat == null:
		_deep_mat = m.depth_stone(mist()).duplicate() as ShaderMaterial
		var look := cliff_look()
		for k in look:
			_deep_mat.set_shader_parameter(k, look[k])
	return _deep_mat


## The floor's slabs (the same look as the floor) for the chunks of the brink.
func paving() -> ShaderMaterial:
	if _paving_mat == null:
		var b := arena.shape().bounds()
		_paving_mat = kit.floor_material(0.0, Vector2.ZERO, minf(b.size.x, b.size.y) * 0.3)
		var look := floor_look()
		for k in look:
			_paving_mat.set_shader_parameter(k, look[k])
	return _paving_mat



## A bridge of stone over a gap (the Salão das Fendas' of C12, F-2; E5: every arena's), its deck the floor's rect `r`
## spanning along x (the walkable width along z): its own paving over the floor (slabs along the span, kerbs, dark
## seams at the heads), the deck's cornice of cut stone under it, an open parapet outside the walkable width on each
## side, a pillar at each of the four heads on the abutment it springs from (two with a lantern, diagonally: north-west
## and south-east; two with candles), `arches` arches of voussoirs under it (their crown ARCH_CROWN under the deck), their
## haunches and the piers down into the mist in the depths' dark stone. shadow_nw, shadow_se: those lanterns cast
## shadows. open (from, to along x; zero: none): a landing across the deck there, the parapets leave it open.
func bridge(r: Rect2, shadow_nw: bool, shadow_se: bool, arches := 1, open: Vector2 = Vector2.ZERO) -> void:
	var mat := ashlar()
	var deep := deep()
	var cx := r.get_center().x
	var cz := r.get_center().y
	var span := r.size.x
	m.box(Vector3(cx, -DECK * 0.5 - 0.02, cz), Vector3(span + 1.0, DECK, r.size.y + DECK_OUT * 2.0), 0.0, mat, false)
	m.layers = 1 | ArenaKit.DEPTH_LAYER
	# each arch: its crown ARCH_CROWN under the deck, springing from the walls (or the piers), and the fill over its
	# haunches
	var n := maxi(1, arches)
	var bay := span / n
	var rr := bay * ARCH_RADIUS
	var hx := rr - bay * 0.5
	var rise := sqrt((rr + ARCH_RING) * (rr + ARCH_RING) - hx * hx)
	var spring := -ARCH_CROWN - rise
	for j in n:
		var ax := r.position.x + bay * (j + 0.5)
		m.voussoir_arch(Vector3(ax, spring, cz), Vector2(0, 1), bay, 0.0, ARCH_RING, r.size.y, deep, ARCH_RADIUS)
		var slices := 8
		for k in slices:
			var x0 := -bay * 0.5 + bay * k / slices
			var x1 := x0 + bay / slices
			var xm := absf((x0 + x1) * 0.5)
			# the arch's outer curve over this slice (the arc whose centre is on the other side)
			var y := spring + sqrt(maxf(0.0, (rr + ARCH_RING) * (rr + ARCH_RING) - (xm + hx) * (xm + hx)))
			if y < -DECK - 0.05:
				m.box(Vector3(ax + (x0 + x1) * 0.5, (y - DECK) * 0.5, cz), Vector3(x1 - x0 + 0.02, -DECK - y, r.size.y * 0.92), 0.0, deep, false)
	for j in n + 1:
		var px := r.position.x + bay * j + (-0.6 if j == 0 else (0.6 if j == n else 0.0))
		m.box(Vector3(px, (spring - DEPTH) * 0.5, cz), Vector3(1.6, DEPTH + spring, r.size.y * 0.9), 0.0, deep, false)
	m.layers = 1
	deck(r)
	for z: float in [r.position.y - PARAPET.z, r.end.y + PARAPET.z]:
		if open == Vector2.ZERO:
			parapet(Vector2(r.position.x + ABUTMENT.x * 0.5, z), Vector2(r.end.x - ABUTMENT.x * 0.5, z))
			continue
		# a landing breaks the parapet (open: from, to along x): it has its own
		parapet(Vector2(r.position.x + ABUTMENT.x * 0.5, z), Vector2(open.x - PARAPET.z, z))
		parapet(Vector2(open.y + PARAPET.z, z), Vector2(r.end.x - ABUTMENT.x * 0.5, z))
	# the four heads: north-west and south-east with lanterns (the first of the pair casting shadows), the others candles
	for k in 4:
		var west := k == 0 or k == 3
		var north := k == 0 or k == 2
		var lip := r.position.x if west else r.end.x
		var into := 1.0 if west else -1.0
		var side := r.position.y if north else r.end.y
		var away := -1.0 if north else 1.0
		abutment(Vector2(lip, side), into, away)
		var head := Vector2(lip + into * ABUTMENT.x * 0.5, side + away * PARAPET.z)
		if k < 2:
			var l := tomb.lantern(Vector3(head.x, 0.0, head.y), 0.0, stone(), TombKit.WARM, ~Arena.CROWD_LAYER, HEAD_LANTERN)
			l.light_energy = BRIDGE_LAMP_ENERGY
			l.omni_range = BRIDGE_LAMP_RANGE
			l.shadow_enabled = shadow_nw if k == 0 else shadow_se
		else:
			bridge_head(head)
			candles(Vector3(head.x, HEAD.y, head.y), 3)


## The abutment a bridge springs from at one corner (F-3): against the rift's wall at `corner` (where the lip meets the
## deck's side), reaching `into` the rift (x sign) and `away` from the deck (z sign): cut stone under the floor, then
## the depths' stone down into the haze.
func abutment(corner: Vector2, into: float, away: float) -> void:
	var c := corner + Vector2(into * ABUTMENT.x * 0.5, away * ABUTMENT.z * 0.5)
	m.box(Vector3(c.x, -0.03 - ABUTMENT.y * 0.5, c.y), Vector3(ABUTMENT.x, ABUTMENT.y, ABUTMENT.z), 0.0, ashlar(), false)
	m.layers = 1 | ArenaKit.DEPTH_LAYER
	var top := -0.03 - ABUTMENT.y
	m.box(Vector3(c.x, (top + ABUTMENT_FOOT) * 0.5, c.y), Vector3(ABUTMENT.x - 0.1, top - ABUTMENT_FOOT, ABUTMENT.z - 0.1), 0.0, deep(), false)
	m.layers = 1


## A head pillar of a bridge (F-2): plinth, shaft and cap, HEAD.y tall.
func bridge_head(at: Vector2) -> void:
	var mat := stone()
	m.block(Vector3(at.x, 0.0, at.y), Vector3(HEAD.x + 0.12, Masonry.CURB * 0.7, HEAD.x + 0.12), 0.0, mat)
	m.block(Vector3(at.x, 0.0, at.y), Vector3(HEAD.x, HEAD.y - HEAD.z, HEAD.x), 0.0, mat)
	m.block(Vector3(at.x, HEAD.y - HEAD.z, at.y), Vector3(HEAD.x + 0.14, HEAD.z, HEAD.x + 0.14), 0.0, mat)


## The deck's own paving over the floor (F-2): the depths' dark stone under it all (the joints, and the seams where it
## meets the platforms), a kerb of lighter stone in lengths along each side, slabs running along the span in
## DECK_ROWS staggered rows between the kerbs.
func deck(r: Rect2) -> void:
	var x0 := r.position.x + SEAM
	var x1 := r.end.x - SEAM
	m.prism(rect_poly(r.position.x, r.end.x, r.position.y, r.end.y), 0.0, SEAM_TOP, deep())
	var kerb := m.stone(0.0, stone_tint() * KERB.z)
	var slab := m.stone(0.0, stone_tint() * DECK_TINT)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector2i(r.position * 10.0))
	var rows: Array[Vector2] = [Vector2(r.position.y, r.position.y + KERB.x)]
	var inner := (r.size.y - KERB.x * 2.0) / DECK_ROWS
	for k in DECK_ROWS:
		var z := r.position.y + KERB.x + inner * k
		rows.append(Vector2(z, z + inner))
	rows.append(Vector2(r.end.y - KERB.x, r.end.y))
	for k in rows.size():
		var is_kerb := k == 0 or k == rows.size() - 1
		var x := x0
		var first := true
		while x < x1 - 0.05:
			var l := rng.randf_range(DECK_SLAB.x, DECK_SLAB.y) * (0.5 if first and k % 2 == 1 else 1.0)
			first = false
			if x1 - (x + l) < DECK_SLAB.x * 0.5:
				l = x1 - x
			var j := DECK_JOINT * 0.5
			m.prism(rect_poly(x + j, x + l - j, rows[k].x + j, rows[k].y - j), 0.0, KERB.y if is_kerb else DECK_TOP, kerb if is_kerb else slab)
			x += l


func rect_poly(x0: float, x1: float, z0: float, z1: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x0, z0), Vector2(x1, z0), Vector2(x1, z1), Vector2(x0, z1)])


## The open parapet of a bridge from a to b (spec 1.3: 0.9 m, never see-through): a curb, a rail, posts every
## PARAPET_POST meters and bellied balusters between them, the abyss seen through it.
func parapet(a: Vector2, b: Vector2) -> void:
	var mat := stone()
	var length := a.distance_to(b)
	var along := (b - a) / maxf(length, 0.001)
	var yaw := atan2(-along.y, along.x)
	var mid := (a + b) * 0.5
	m.box(Vector3(mid.x, PARAPET_CURB.x * 0.5, mid.y), Vector3(length, PARAPET_CURB.x, PARAPET_CURB.y), yaw, mat, false)
	m.box(Vector3(mid.x, PARAPET.x - PARAPET_RAIL.x * 0.5, mid.y), Vector3(length, PARAPET_RAIL.x, PARAPET_RAIL.y), yaw, mat, false)
	var posts := maxi(1, roundi(length / PARAPET_POST))
	var bay := length / posts
	for i in posts + 1:
		var p := a + along * bay * i
		m.box(Vector3(p.x, PARAPET.x * 0.5 + 0.03, p.y), Vector3(PARAPET_POST_SIDE, PARAPET.x + 0.06, PARAPET.y), yaw, mat)
	var shaft := PARAPET.x - PARAPET_RAIL.x - PARAPET_CURB.x
	var n := floori(length / BALUSTER.y)
	for i in n:
		var s := (i + 0.5) * length / n
		var t := s / bay
		if absf(t - roundf(t)) * bay < PARAPET_POST_SIDE:
			continue
		var p := a + along * s
		m.box(Vector3(p.x, PARAPET_CURB.x + shaft * 0.5, p.y), Vector3(BALUSTER.x, shaft, BALUSTER.x), yaw, mat)
		m.box(Vector3(p.x, PARAPET_CURB.x + shaft * 0.35, p.y), Vector3(BALUSTER.z, BALUSTER.w, BALUSTER.z), yaw, mat)


## A whole column (TombKit.column's foot and shaft, which the Seal Chamber keeps): plinth, base, shaft, then a necking
## ring, a round bell flaring to a round abacus, and the arch springing from it as one curved voussoir toward the back.
func round_column(o: ArenaObstacle) -> void:
	var mat := see(stone()) if o.see_through else stone()
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	var r := o.radius
	var shaft_r := r * TombKit.COLUMN_SHAFT
	m.block(foot, Vector3(r * 1.41, TombKit.COLUMN_PLINTH, r * 1.41), PI * 0.25, mat, false)
	m.shaft(foot + Vector3(0, TombKit.COLUMN_PLINTH, 0), r * 0.98, TombKit.COLUMN_BASE - TombKit.COLUMN_PLINTH, mat)
	m.shaft(foot + Vector3(0, TombKit.COLUMN_BASE, 0), shaft_r * 1.12, 0.12, mat)
	var head := CAPITAL.x + CAPITAL.y + ABACUS
	var cap_y := o.height - TombKit.COLUMN_SPRING.x - head
	m.shaft(foot + Vector3(0, TombKit.COLUMN_BASE, 0), shaft_r, cap_y - TombKit.COLUMN_BASE, mat)
	var ring := m.shaft(foot + Vector3(0, cap_y, 0), shaft_r * 1.1, CAPITAL.x, mat)
	var bell := m.shaft(foot + Vector3(0, cap_y + CAPITAL.x, 0), shaft_r * CAPITAL.z, CAPITAL.y, mat)
	(bell.mesh as CylinderMesh).bottom_radius = shaft_r
	var top := cap_y + CAPITAL.x + CAPITAL.y
	var abacus := m.shaft(foot + Vector3(0, top, 0), shaft_r * CAPITAL.w, ABACUS, mat)
	for piece_mi: MeshInstance3D in [ring, bell, abacus]:
		(piece_mi.mesh as CylinderMesh).radial_segments = CAPITAL_SIDES
	# the springers: the first part of a round arch whose left foot sits on the abacus (centred on it), rising away
	for b in SPRING_BEARINGS:
		var way := Vector2(sin(deg_to_rad(b)), -cos(deg_to_rad(b)))
		var yaw := atan2(-way.y, way.x)
		var mid := foot + Vector3(way.x, 0.0, way.y) * (SPRING_ARCH.x + SPRING_ARCH.y) * 0.5 + Vector3(0, top + ABACUS, 0)
		m.arch_ring(mid, Vector2(sin(yaw), cos(yaw)), SPRING_ARCH.x, SPRING_ARCH.y, shaft_r * SPRING_DEEP, mat, 0.5, 0.0, SPRING_ARCH.z)


# ---------- walls, benches, light from above (E5) ----------

## A wall along a to b (the floor's edge), its face FACE_SET behind it (out: away from the room), `height` tall and
## `thick` thick, with openings (x, y: from and to along it from a; z, w: from and to in height) through it, and a
## cornice. mat: its stone (the arena's ashlar by default). Nothing on the floor.
func wall(a: Vector2, b: Vector2, out: Vector2, height: float, openings: Array[Vector4] = [], mat: Material = null,
		thick := FACE_THICK) -> void:
	if mat == null:
		mat = ashlar()
	var length := a.distance_to(b)
	var t0 := FACE_SET
	var t1 := FACE_SET + thick
	var cuts := openings.duplicate()
	cuts.sort_custom(func(p: Vector4, q: Vector4) -> bool: return p.x < q.x)
	var s := 0.0
	for c: Vector4 in cuts:
		if c.x > s:
			wall_part(a, b, out, s, c.x, t0, t1, 0.0, height, mat)
		s = maxf(s, c.y)
		if c.z > 0.0:
			wall_part(a, b, out, c.x, c.y, t0, t1, 0.0, c.z, mat)
		if c.w < height:
			wall_part(a, b, out, c.x, c.y, t0, t1, c.w, height, mat)
	if s < length:
		wall_part(a, b, out, s, length, t0, t1, 0.0, height, mat)
	wall_part(a, b, out, 0.0, length, t0 - WALL_CORNICE.y, t1, height - WALL_CORNICE.x, height, mat)
	# under the face, from the floor's edge back: a low sill so no gap shows between the floor and the wall
	wall_part(a, b, out, 0.0, length, -0.02, t0, -0.6, 0.06, mat)


## One block of a wall: from s0 to s1 along a to b, from d0 to d1 out of the edge, from y0 to y1.
func wall_part(a: Vector2, b: Vector2, out: Vector2, s0: float, s1: float, d0: float, d1: float, y0: float, y1: float, mat: Material) -> void:
	if s1 - s0 < 0.02 or y1 - y0 < 0.02:
		return
	var along := (b - a).normalized()
	var c := a + along * (s0 + s1) * 0.5 + out * (d0 + d1) * 0.5
	m.box(Vector3(c.x, (y0 + y1) * 0.5, c.y), Vector3(s1 - s0, y1 - y0, d1 - d0), atan2(-along.y, along.x), mat, false)


## A wall of the front cut at CUT_WALL.x along a to b (the crypt's, spec 2.1 of C12, for any arena): cut stone on both
## faces, the dark fill between them on the cut, the outer face dropping CUT_WALL.z into the dark, gaps (from, to along
## it) left open, fallen blocks outside. Nothing on the floor.
func cut_wall(a: Vector2, b: Vector2, out: Vector2, gaps: Array[Vector2] = [], skin: Material = null, fill: Material = null) -> void:
	if skin == null:
		skin = ashlar()
	if fill == null:
		fill = m.stone(0.0, stone_tint() * 0.3)
	var along := (b - a).normalized()
	var length := a.distance_to(b)
	var runs := gaps.duplicate()
	runs.sort_custom(func(p: Vector2, q: Vector2) -> bool: return p.x < q.x)
	runs.append(Vector2(length, length))
	var s0 := 0.0
	var skin_w := CUT_WALL.y * (1.0 - CUT_FILL) * 0.5
	for g: Vector2 in runs:
		if g.x > s0 + 0.05:
			wall_part(a, b, out, s0, g.x, 0.0, skin_w, -CUT_WALL.z, CUT_WALL.x, skin)
			wall_part(a, b, out, s0, g.x, CUT_WALL.y - skin_w, CUT_WALL.y, -CUT_WALL.z, CUT_WALL.x - 0.06, skin)
			wall_part(a, b, out, s0, g.x, skin_w, CUT_WALL.y - skin_w, -CUT_WALL.z, CUT_WALL.x - 0.1, fill)
			var r := RandomNumberGenerator.new()
			r.seed = hash(Vector2i((a + along * s0) * 10.0))
			for k in floori((g.x - s0) * CUT_FALLEN):
				var p := a + along * r.randf_range(s0 + 0.3, g.x - 0.3) + out * (CUT_WALL.y + r.randf_range(0.3, 1.2))
				var size := r.randf_range(0.3, 0.7)
				var blk := m.box(Vector3(p.x, -r.randf_range(0.6, 2.2), p.y), Vector3(size, size * 0.7, size * 0.9), r.randf() * TAU, skin)
				blk.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.6, 0.6))
		s0 = maxf(s0, g.y)


## The stretches the doors' mouths take out of the edge a to b (from, to along it, `cheek` wider on each side), for
## wall and cut_wall.
func door_gaps(a: Vector2, b: Vector2, out: Vector2, cheek := EXIT_CHEEK.x) -> Array[Vector2]:
	var along := (b - a).normalized()
	var length := a.distance_to(b)
	var gaps: Array[Vector2] = []
	for e in layout.exits:
		if e.inward.dot(-out) < 0.9:
			continue
		var mid := e.mouth.get_center() + e.inward * absf(e.mouth.size.dot(e.inward)) * 0.5
		var s := (mid - a).dot(along)
		if s < -1.0 or s > length + 1.0 or absf((mid - a).dot(out)) > 0.5:
			continue
		var w := absf(e.mouth.size.dot(along))
		gaps.append(Vector2(s - w * 0.5 - cheek, s + w * 0.5 + cheek))
	return gaps


## The drums of a fallen column lying along its footprint (a capsule box of the layout): a few drums with gaps, each a
## short shaft laid on its side, a little askew.
func drums(o: ArenaObstacle) -> void:
	var long_x := o.half.x >= o.half.y
	var half := o.half if long_x else Vector2(o.half.y, o.half.x)
	var dir := Vector2(cos(o.yaw), sin(o.yaw)) if long_x else Vector2(-sin(o.yaw), cos(o.yaw))
	var r := minf(half.y, o.height * 0.5)
	var length := half.x * 2.0 - r * 0.4
	var n := maxi(2, roundi(length / (r * 2.4)))
	var drum := length / n
	var mat := stone()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector2i(o.center * 10.0))
	var axis := Vector3(dir.x, 0.0, dir.y)
	var side := axis.cross(Vector3.UP).normalized()
	for k in n:
		var c := o.center + dir * (-length * 0.5 + drum * (k + 0.5)) + Vector2(side.x, side.z) * rng.randf_range(-0.08, 0.08)
		var mi := m.shaft(Vector3(c.x, 0.0, c.y), r * rng.randf_range(0.88, 1.0), drum - 0.1, mat)
		# laid on its side: its own up along dir, turned a little about the floor's up
		mi.basis = Basis(Vector3.UP, rng.randf_range(-0.15, 0.15)) * Basis(side, axis, side.cross(axis)).orthonormalized()
		mi.position = Vector3(c.x, r * 0.95, c.y)


## A blind pointed window on a wall's face (foot: the middle of its sill on the face; facing: into the room): a dark
## panel set back, its pointed frame, a mullion and broken tracery (no glass, no figure).
func blind_window(foot: Vector3, facing: Vector2, width: float, height: float, mat: Material) -> void:
	var yaw := atan2(facing.x, facing.y)
	var basis := Basis(Vector3.UP, yaw)
	var f := Vector3(facing.x, 0.0, facing.y)
	var dark := m.stone(0.0, WINDOW_PANEL)
	var straight := height - width * 0.55
	m.box(foot - f * WINDOW_PANEL_SET + Vector3(0, straight * 0.5, 0), Vector3(width, straight, 0.06), yaw, dark, false)
	var head := m.box(foot - f * WINDOW_PANEL_SET + Vector3(0, straight, 0), Vector3(width * 0.7071, width * 0.7071, 0.06), yaw, dark, false)
	head.basis = basis * Basis.from_scale(Vector3(1.0, 1.25, 1.0)) * Basis(Vector3.BACK, PI * 0.25)
	m.pointed_arch(foot + f * 0.05, facing, width, height, 0.24, 0.3, mat)
	m.box(foot + f * 0.1 + Vector3(0, -0.08, 0), Vector3(width + 0.5, 0.16, 0.3), yaw, mat)
	# the mullion, broken off two thirds up, and the stump of the tracery over it
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector3i(foot * 10.0))
	var up := straight * r.randf_range(0.55, 0.9)
	m.box(foot - f * 0.08 + Vector3(0, up * 0.5, 0), Vector3(WINDOW_MULLION, up, 0.2), yaw, mat)
	for sd: float in [-1.0, 1.0]:
		if r.randf() < 0.6:
			var sub := foot - f * 0.1 + basis * Vector3(sd * width * 0.25, straight - 0.2, 0)
			m.pointed_arch(sub, facing, width * 0.38, width * 0.5, WINDOW_MULLION, 0.16, mat)


## An outer edge of a closed room (E5: the Provação, the Altar Esquecido): the sides away from the camera (north, west
## and the cut between them) a wall `height` tall with the doors in it opened (in_wall), the others the low cut wall
## of the front (cut_wall) with the doors' gaps. Each run reaches CLOSE_REACH past its ends so the corners meet.
func closed_edge(a: Vector2, b: Vector2, out: Vector2, height: float, mat: Material = null) -> void:
	var along := (b - a).normalized()
	var a2 := a - along * CLOSE_REACH
	var b2 := b + along * CLOSE_REACH
	if out.y < -0.5 or out.x < -0.5:
		var openings: Array[Vector4] = []
		for g in door_gaps(a2, b2, out, JAMB):
			openings.append(Vector4(g.x, g.y, 0.0, WALL_DOOR.y + 0.4))
		wall(a2, b2, out, height, openings, mat)
	else:
		cut_wall(a2, b2, out, door_gaps(a2, b2, out), mat)


## True on the browser's and the phone's renderer (Compatibility).
static func compat() -> bool:
	return RenderingServer.get_current_rendering_method() == "gl_compatibility"


## A shaft of light falling on `target` from a hole in the vault `height` m up (leaning SHAFT_LEAN toward the back): a
## spot of `cone` degrees, no fall-off with distance (its energy is what reaches the floor), with or without shadow
## (never in Compatibility), never on the crowd, and the dust drifting down through it (Arena._dust).
func moon_shaft(target: Vector2, color: Color, energy: float, cone: float, height: float, shadow := true, dust := true) -> SpotLight3D:
	var spot := SpotLight3D.new()
	add_child(spot)
	var to := Vector3(target.x, 0.0, target.y)
	spot.look_at_from_position(to + Vector3(SHAFT_LEAN.x, height, SHAFT_LEAN.y), to)
	spot.light_color = color
	spot.light_energy = energy
	spot.spot_angle = cone
	spot.spot_range = height * 2.0
	spot.spot_attenuation = 0.0
	# the browser's renderer draws the spot's shadow in stripes: none there
	spot.shadow_enabled = shadow and not compat()
	spot.light_cull_mask = ~Arena.CROWD_LAYER
	if dust:
		arena._dust(to)
	return spot


## E5 spec 7.2: the breath of the next room in the mouth of door i (used doors only): a card of light in the colour of
## the air of the arena `look` (BREATH; the hall's when unknown) rising out of its stairs, no light cast. Call it when
## the doors open (Rooms knows where each leads); again on the same door changes its colour. Returns the card (null when
## the door is not used).
func breath(i: int, look: StringName) -> MeshInstance3D:
	if i < 0 or i >= exits_used:
		return null
	var e := layout.exits[i]
	var u := e.inward
	var depth := absf(e.mouth.size.dot(u))
	var end := e.mouth.get_center() - u * depth * 0.5
	var c := end - u * BREATH_BEYOND
	var colour: Color = BREATH.get(look, BREATH[&"hall"])
	var peak := maxf(colour.r, maxf(colour.g, colour.b))
	if peak > BREATH_PEAK:
		colour = colour * (BREATH_PEAK / peak)
	var mat := ShaderMaterial.new()
	mat.shader = BREATH_SHADER
	mat.set_shader_parameter(&"color", colour)
	mat.set_shader_parameter(&"alpha", BREATH_ALPHA)
	mat.set_shader_parameter(&"thread", BREATH_THREAD.get(look, Color(0, 0, 0, 0)))
	var name_ := "Breath%d" % i
	var card := get_node_or_null(name_) as MeshInstance3D
	if card == null:
		card = MeshInstance3D.new()
		card.name = name_
		var q := QuadMesh.new()
		q.size = BREATH_SIZE
		card.mesh = q
		card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(card)
	card.material_override = mat
	# upright across the door's way, facing into the room
	card.transform = Transform3D(Basis(Vector3.UP, atan2(u.x, u.y)), Vector3(c.x, BREATH_FOOT + BREATH_SIZE.y * 0.5, c.y))
	return card


# ---------- doors ----------

## What the lanterns of the doors burn (the arenas' warm iron lanterns; the trial's cold ivory).
func door_lamp() -> TombKit.Lamp:
	return TombKit.WARM


## True when door i opens in a wall of the room (an arch over its mouth, steps going down inside it), not over the
## abyss (stairs going down between low cheeks). The arena's script knows its walls.
func in_wall(_i: int) -> bool:
	return false


## Every door of the layout: its stairs going down out of the room from the end of its mouth; a door used gets its
## light (dim until it opens: Arena.light_exit) and, unless a fire bowl of the layout stands within 3 m, a warm
## lantern on the pillar beside it; a door not used keeps its stairs but its mouth is closed at the edge by a low iron
## grille (spec 0.4).
func _doors() -> void:
	for i in layout.exits.size():
		var e := layout.exits[i]
		var u := e.inward
		var side := Vector2(-u.y, u.x)
		var r := e.mouth
		# the edge's middle and the mouth's far end (r: the landing, 4 x 2.4 m beyond the edge)
		var depth := absf(r.size.dot(u))
		var width := absf(r.size.dot(side))
		var edge_mid := r.get_center() + u * depth * 0.5
		var end := r.get_center() - u * depth * 0.5
		var used := i < exits_used
		var mat := stone()
		if not used:
			# the landing is not floor: a slab of stone a little under the floor's level, the grille on the edge
			m.block(Vector3(r.get_center().x, -0.6, r.get_center().y), Vector3(r.size.x, 0.58, r.size.y), 0.0, mat, false)
			var g0 := edge_mid + side * width * 0.5
			var g1 := edge_mid - side * width * 0.5
			tomb.grille(Vector3(g0.x, 0.0, g0.y), Vector3(g1.x, 0.0, g1.y))
		var steps := EXIT_STEPS
		var foot := end - u * EXIT_RUN * steps
		m.stairs(Vector3(foot.x, -EXIT_RISE * steps, foot.y), u, width, steps, EXIT_RISE, EXIT_RUN)
		if in_wall(i):
			door_arch(edge_mid, u, width)
		else:
			for sd: float in [-1.0, 1.0]:
				var c := (edge_mid + end) * 0.5 - u * EXIT_RUN * steps * 0.5 + side * sd * (width * 0.5 + EXIT_CHEEK.x * 0.5)
				var along := depth + EXIT_RUN * steps
				var yaw := atan2(u.x, u.y)
				m.block(Vector3(c.x, -EXIT_RISE * steps, c.y), Vector3(EXIT_CHEEK.x, EXIT_CHEEK.y + EXIT_RISE * steps, along), yaw, mat)
			m.post(Vector3(edge_mid.x + side.x * (width * 0.5 + EXIT_CHEEK.x * 0.5), 0.0, edge_mid.y + side.y * (width * 0.5 + EXIT_CHEEK.x * 0.5)), 0.0, 0.9, mat)
			var lamp_side := edge_mid - side * (width * 0.5 + EXIT_CHEEK.x * 0.5)
			if used and not _bowl_near(edge_mid, 3.0):
				tomb.lantern(Vector3(lamp_side.x, 0.0, lamp_side.y), atan2(u.x, u.y), mat, door_lamp(), ~Arena.CROWD_LAYER)
			else:
				m.post(Vector3(lamp_side.x, 0.0, lamp_side.y), 0.0, 0.9, mat)
		if not used:
			continue
		var l := OmniLight3D.new()
		l.position = Vector3(end.x, 2.6, end.y) + Vector3(u.x, 0.0, u.y) * 0.6
		l.light_color = Color(0.5, 0.45, 0.6)
		l.light_energy = DOOR_DIM
		l.omni_range = 7.0
		l.light_cull_mask = ~Arena.CROWD_LAYER
		add_child(l)
		arena._exit_lights.append(l)


## The pointed arch of a door in a wall over its opening (spec 0.4): voussoirs over two jambs, its foot `edge_mid` (the
## middle of the opening on the floor's edge), facing `inward`, the opening `width` wide (at least WALL_DOOR.x) and
## WALL_DOOR.y high; the jambs JAMB thick, set back `back` meters out of the room (in the wall's thickness).
func door_arch(edge_mid: Vector2, inward: Vector2, width: float, back := 0.5, height := WALL_DOOR.y) -> void:
	var mat := ashlar()
	var o := edge_mid - inward * back
	var foot := Vector3(o.x, 0.0, o.y)
	var w := maxf(WALL_DOOR.x, width + 0.4)
	var spring := height - w * 0.55
	for sd: float in [-1.0, 1.0]:
		var side := Vector2(-inward.y, inward.x) * sd * (w * 0.5 + JAMB * 0.5)
		m.block(foot + Vector3(side.x, 0.0, side.y), Vector3(JAMB, spring, 0.9), atan2(inward.x, inward.y), mat)
	m.voussoir_arch(foot, inward, w, spring, 0.5, 0.9, mat)


## True when a fire bowl of the layout stands within `reach` of p.
func _bowl_near(p: Vector2, reach: float) -> bool:
	for o in layout.obstacles:
		if o.piece == &"brazier" and o.center.distance_to(p) <= reach:
			return true
	return false


## The arena's own light (by default nothing more: its fires and lanterns light it).
func _light() -> void:
	pass


## A soft light high over the middle of the floor, no shadow (the hall's key, dimmer and of the arena's colour): it
## keeps the floor between the pools of fire at the value the fight reads on (spec 0.5).
func key_light(color: Color, energy: float, height := CatacombHall.KEY_HEIGHT) -> OmniLight3D:
	var b := arena.shape().bounds()
	var c := b.get_center()
	var key := OmniLight3D.new()
	key.position = Vector3(c.x, height, c.y)
	key.light_color = color
	key.light_energy = energy
	key.omni_range = maxf(CatacombHall.KEY_RANGE, b.size.length() * 0.6)
	key.omni_attenuation = 1.0
	key.light_cull_mask = ArenaKit.WARM_MASK
	add_child(key)
	return key


## How many lights cast shadows (spec 0.5: at most 8 an arena; arena_lab prints it).
func _count_shadows() -> int:
	var n := 0
	for l in find_children("*", "Light3D", true, false):
		if (l as Light3D).shadow_enabled:
			n += 1
	return n


# ---------- the air ----------

## The world's air as it was before an arena dressed it, the environment and the moon, and the room that dressed it
## last (only that one gives it back).
static var _saved: Dictionary = {}
static var _air_env: Environment
static var _air_moon: DirectionalLight3D
static var _dresser: ArenaRoom


## Puts the world's air back as it was if an arena dressed it (Arena.build calls it before any room is built: the
## old room leaves only after the new one stands).
static func leave_air() -> void:
	if _air_env != null and not _saved.is_empty():
		BossChamber.restore_air(_air_env, _air_moon if is_instance_valid(_air_moon) else null, _saved)
	_saved = {}
	_dresser = null


func _dress_air() -> void:
	var want := air()
	if want.is_empty() or not is_inside_tree():
		return
	var e := get_world_3d().environment
	if e == null:
		for n in get_tree().root.find_children("*", "WorldEnvironment", true, false):
			e = (n as WorldEnvironment).environment
	if e == null:
		return
	var moon: DirectionalLight3D = null
	for n in get_tree().root.find_children("*", "DirectionalLight3D", true, false):
		moon = n as DirectionalLight3D
	if _saved.is_empty():
		_air_env = e
		_air_moon = moon
		_saved = BossChamber.air_of(e, moon)
	_dresser = self
	var base_energy: float = _saved[&"ambient_light_energy"]
	e.background_mode = Environment.BG_COLOR
	e.background_color = want.get(&"sky", e.background_color)
	e.fog_light_color = want.get(&"fog", e.fog_light_color)
	if want.has(&"fog_depth"):
		var fd: Vector2 = want[&"fog_depth"]
		e.fog_depth_begin = fd.x
		e.fog_depth_end = fd.y
	e.ambient_light_color = want.get(&"ambient", e.ambient_light_color)
	# a share of the world's energy (the browser's renderer compensates its own: Game.COMPAT_*)
	e.ambient_light_energy = base_energy * float(want.get(&"ambient_gain", 1.0))
	if moon != null:
		moon.light_color = want.get(&"moon", moon.light_color)
		moon.light_energy = want.get(&"moon_energy", moon.light_energy)
		moon.shadow_enabled = want.get(&"moon_shadow", moon.shadow_enabled)


func _exit_tree() -> void:
	if _dresser == self:
		leave_air()
