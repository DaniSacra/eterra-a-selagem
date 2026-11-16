class_name ArenaRoom
extends Node3D
## The look of an arena of cycle C12 (the crypt, the rift hall, the garden), drawn from its RoomLayout: the floor
## (the catacomb floor's shader) with its holes open on the abyss, the cliffs under every edge, the abyss's mist and
## violet glow, each obstacle drawn on its own footprint (ArenaObstacle.piece: the collision and the look come from
## the same data), the doors and a few lights. This is the grey, playable version: the stone, the pieces and the
## light of each arena are the environment artist's, in its own script (CryptLook, RiftLook, GardenLook: dress()),
## following docs/art/cycle12_arenas_spec.md. Collision never comes from here (Arena._build_arena reads the layout).

## The looks an arena may have (RoomLayout.look) and the script of each.
const LOOKS: Array[StringName] = [&"crypt", &"rift", &"garden"]
## How deep the cliffs under the floor's edges drop, and the abyss under them.
const DEPTH := 22.0
## A lip of stone along every edge: its height under the floor and how far it stands out.
const LIP := Vector2(0.35, 0.18)
## Points along the floor's edges for its triangles (meters apart), and inside it.
const EDGE_STEP := 0.5
const FILL_STEP := 2.0
## The violet light under each hole (the abyss's), and the key light over the floor (the hall's numbers).
const ABYSS_LIGHT_ENERGY := 4.0
const ABYSS_LIGHT_Y := -9.0
## A door: its arch (opening width, height) a little behind its spot, and its light when dim.
const DOOR_ARCH := Vector2(3.2, 4.2)
const DOOR_BACK := 1.6
const DOOR_DIM := 0.6
## A sarcophagus's lid stands out this much and is this high; a column's base and capital.
const LID := Vector2(0.08, 0.22)
const COLUMN_CAP := 1.25

var arena: Arena
var layout: RoomLayout
var kit: ArenaKit
var m: Masonry
var _see: ShaderMaterial


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
	kit = ArenaKit.new(self, seed_)
	m = kit.masonry
	_see = m.stone(0.0).duplicate() as ShaderMaterial
	_see.set_shader_parameter(&"see_through", 1.0)
	_floor()
	_cliffs()
	_abyss()
	for o in layout.obstacles:
		piece(o)
	_doors(exit_count)
	_light()
	dress()
	m.merge()


## Each arena's own pieces and light (the environment artist's: CryptLook, RiftLook, GardenLook). Nothing here may
## block: what blocks is an ArenaObstacle in the layout.
func dress() -> void:
	pass


# ---------- the floor ----------

## The floor's top, in triangles: points along every edge and on a grid inside, joined (Delaunay), the triangles
## whose middle is on the floor kept.
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
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	for i in range(0, tris.size(), 3):
		var p0 := pts[tris[i]]
		var p1 := pts[tris[i + 1]]
		var p2 := pts[tris[i + 2]]
		if not f.covers((p0 + p1 + p2) / 3.0):
			continue
		# wound so the face looks up (Godot's front faces turn clockwise as seen; seen from above, x right and z down,
		# that is a positive cross on the floor plane)
		if (p1 - p0).cross(p2 - p0) < 0.0:
			var t := p1
			p1 = p2
			p2 = t
		for p in [p0, p1, p2]:
			st.set_uv(p)
			st.add_vertex(Vector3(p.x, 0.0, p.y))
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = kit.floor_material(0.0, Vector2.ZERO, minf(b.size.x, b.size.y) * 0.3)
	add_child(mi)


## A wall of stone under every edge of the floor, down into the abyss, and a lip along it.
func _cliffs() -> void:
	var f := arena.shape()
	var e := f.edges()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0, e.size(), 2):
		var a := e[i]
		var b := e[i + 1]
		var out := -f.edge_inward(i / 2)
		var n := Vector3(out.x, 0.0, out.y)
		var q: Array[Vector3] = [Vector3(a.x, -LIP.x, a.y), Vector3(b.x, -LIP.x, b.y), Vector3(b.x, -DEPTH, b.y), Vector3(a.x, -DEPTH, a.y)]
		# facing out of the floor (clockwise as seen from outside)
		if (b - a).cross(out) < 0.0:
			q = [q[1], q[0], q[3], q[2]]
		st.set_normal(n)
		for k: int in [0, 1, 2, 0, 2, 3]:
			st.add_vertex(q[k])
		# the lip: a thin slab just under the floor's edge, standing out a little
		var o := out * LIP.y
		m.box(Vector3((a.x + b.x) * 0.5 + o.x * 0.5, -LIP.x * 0.5, (a.y + b.y) * 0.5 + o.y * 0.5),
			Vector3(a.distance_to(b) + LIP.y, LIP.x, LIP.y * 2.0), atan2(-(b - a).y, (b - a).x))
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = m.depth_stone(ArenaKit.MIST)
	mi.layers = 1 | ArenaKit.DEPTH_LAYER
	add_child(mi)


## The abyss's mist far below, and a violet light under each hole and along the outer edge.
func _abyss() -> void:
	var b := arena.shape().bounds()
	kit.abyss(b.size * 0.5 + Vector2(6, 6), DEPTH, false)
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
		&"column", &"trunk":
			m.block(at, Vector3(o.radius * 2.4, 0.3, o.radius * 2.4), 0.0, mat)
			m.shaft(at + Vector3(0, 0.3, 0), o.radius, o.height - 0.3, mat)
			if o.piece == &"column":
				m.block(at + Vector3(0, o.height - 0.25, 0), Vector3(o.radius * COLUMN_CAP * 2.0, 0.25, o.radius * COLUMN_CAP * 2.0), 0.0, mat)
		&"sarcophagus":
			var size := Vector3(o.half.x * 2.0, o.height - LID.y, o.half.y * 2.0)
			m.block(at, size, -o.yaw, mat)
			m.block(at + Vector3(0, size.y, 0), Vector3(size.x + LID.x * 2.0, LID.y, size.z + LID.x * 2.0), -o.yaw, mat)
		&"statue":
			kit.statue(o.center, o.yaw, o.height, 0.0, ArenaKit.STATUE_VALUE, false)
		&"brazier":
			kit.brazier(o.center, 0.0, false)
		_:
			if o.shape == ArenaObstacle.Shape.CIRCLE:
				m.shaft(at, o.radius, o.height, mat)
			else:
				m.block(at, Vector3(o.half.x * 2.0, o.height, o.half.y * 2.0), -o.yaw, mat)


## The doors: a pointed arch behind each spot, facing into the room, and a light that lights when it opens.
func _doors(count: int) -> void:
	for i in mini(count, layout.exits.size()):
		var e := layout.exits[i]
		var back := e.at - e.inward * DOOR_BACK
		m.pointed_arch(Vector3(back.x, 0.0, back.y), e.inward, DOOR_ARCH.x, DOOR_ARCH.y, 0.5, 0.7)
		var l := OmniLight3D.new()
		l.position = Vector3(back.x, 2.6, back.y) + Vector3(e.inward.x, 0.0, e.inward.y) * 0.6
		l.light_color = Color(0.5, 0.45, 0.6)
		l.light_energy = DOOR_DIM
		l.omni_range = 7.0
		l.light_cull_mask = ~Arena.CROWD_LAYER
		add_child(l)
		arena._exit_lights.append(l)


## The key light over the middle (the hall's).
func _light() -> void:
	var c := arena.shape().bounds().get_center()
	var key := OmniLight3D.new()
	key.position = Vector3(c.x, CatacombHall.KEY_HEIGHT, c.y)
	key.light_color = CatacombHall.KEY_LIGHT
	key.light_energy = CatacombHall.KEY_ENERGY
	key.omni_range = maxf(CatacombHall.KEY_RANGE, arena.shape().bounds().size.length() * 0.5)
	key.omni_attenuation = 1.0
	key.light_cull_mask = ArenaKit.WARM_MASK
	add_child(key)
