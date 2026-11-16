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
const LOOKS: Array[StringName] = [&"crypt", &"rift", &"garden"]
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


static func make(look: StringName) -> ArenaRoom:
	match look:
		&"crypt":
			return CryptLook.new()
		&"rift":
			return RiftLook.new()
		&"garden":
			return GardenLook.new()
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
	var mat := kit.floor_material(0.0, Vector2.ZERO, minf(b.size.x, b.size.y) * 0.3)
	var look := floor_look()
	for k in look:
		mat.set_shader_parameter(k, look[k])
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


# ---------- doors ----------

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
				tomb.lantern(Vector3(lamp_side.x, 0.0, lamp_side.y), atan2(u.x, u.y), mat, TombKit.WARM, ~Arena.CROWD_LAYER)
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
