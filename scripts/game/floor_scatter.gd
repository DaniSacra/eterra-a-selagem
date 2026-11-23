class_name FloorScatter
extends RefCounted
## What lies on the floor and round it in the stylized look (SR-G1 rich floor, SR-G3 dark frame; docs/reference/art_rooms.md):
## patches of moss and damp, tufts of grass, skulls and bones, a few small pots in groups, a dark band along the floor's
## edges and big fallen stones just past them over the abyss. Decoration only: nothing here collides, and nothing is put
## where the paladin starts, in front of a door, on a floor that strikes (the red warning stays readable), inside an
## obstacle, or in the middle of the fight (CENTRE_FREE). Its own random numbers (never the room's, so the run is the
## same). One MultiMesh per kind, so a room costs about six draw calls. The classic look never shows it
## (ArenaKit.style_only).

const PATCH_SHADER := preload("res://assets/shaders/floor_patch.gdshader")
const GRASS_SHADER := preload("res://assets/shaders/dry_grass.gdshader")
## Heights over the floor (m): above the slabs' joints, under the warnings (render priority).
const PATCH_Y := 0.014
const PATCH_PRIORITY := -3
## The middle of the fight stays clear of everything but a faint patch: the share of the floor's half size.
const CENTRE_FREE := 0.32
const START_CLEAR := 3.5
const DOOR_CLEAR := 2.5
const HAZARD_CLEAR := 0.9
const TRIES := 24
const SEED := 4417
## Colours (the palette of the room's stone: cold green moss, blue-grey damp, bone, never a bright lawn). sRGB, as seen:
## a MultiMesh's colours reach the shader as they are, so _patch makes them linear (2026-11-21: they were not, and the
## moss came out a bright lawn).
const MOSS := Color(0.13, 0.155, 0.11)
const MOSS_DRY := Color(0.17, 0.16, 0.11)
## Moss patch strength (was 0.8: the patch read brighter than the floor it lay on, GR-4).
const MOSS_ALPHA := 0.55
const DAMP := Color(0.11, 0.135, 0.16)
const BONE := Color(0.30, 0.28, 0.24)
const FRAME_COLOR := Color(0.012, 0.012, 0.016)
## Sizes (m): a patch's width, a skull's radius, a bone's length, a pot's height, a fallen stone's side.  A pot stays under 0.3 m (the rule of every stylized piece over the floor).
const MOSS_SIZE := Vector2(0.8, 2.3)
const DAMP_SIZE := Vector2(1.6, 4.0)
const SKULL_RADIUS := 0.085
## A skull lies half buried: its centre this share of the radius up (was 0.8, a marble on the floor, GR-3).
const SKULL_SINK := 0.35
const BONE_LONG := 0.32
const POT_SIZE := Vector2(0.2, 0.28)
const STONE_SIDE := Vector2(0.9, 1.8)
## The dark frame: how far in it reaches (m), how dark it is at the edge, and (second) how far a fallen stone lies past the edge.
const FRAME_REACH := 4.0
const FRAME_ALPHA := 0.55
const STONE_OUT := Vector2(1.0, 2.4)
const STONE_DROP := Vector2(0.3, 0.9)
const STONE_STEP := 6.0

## Per look: moss, damp (patches), tufts, skulls, bones, pots (groups of two or three), stones (fallen past the edge,
## per 6 m of edge, 0 where a wall stands behind it), frame (the dark band's share), tuft colour.
const BIOMES := {
	&"crypt": {&"moss": 4, &"damp": 8, &"tufts": 0, &"skulls": 9, &"bones": 14, &"pots": 2, &"stones": 0.0, &"frame": 0.9},
	&"garden": {&"moss": 22, &"damp": 6, &"tufts": 70, &"skulls": 3, &"bones": 4, &"pots": 1, &"stones": 0.5, &"frame": 1.0,
		&"tuft": Color(0.22, 0.25, 0.15)},
	&"sanctuary": {&"moss": 5, &"damp": 10, &"tufts": 0, &"skulls": 4, &"bones": 6, &"pots": 2, &"stones": 0.0, &"frame": 0.8},
	&"runes": {&"moss": 4, &"damp": 6, &"tufts": 0, &"skulls": 6, &"bones": 8, &"pots": 1, &"stones": 0.4, &"frame": 1.0},
	&"bridge": {&"moss": 4, &"damp": 4, &"tufts": 0, &"skulls": 0, &"bones": 0, &"pots": 0, &"stones": 0.5, &"frame": 1.0},
	&"rift": {&"moss": 3, &"damp": 10, &"tufts": 0, &"skulls": 7, &"bones": 10, &"pots": 0, &"stones": 0.0, &"frame": 1.0},
	&"trial": {&"moss": 4, &"damp": 4, &"tufts": 0, &"skulls": 2, &"bones": 3, &"pots": 0, &"stones": 0.0, &"frame": 0.8},
	&"armory": {&"moss": 0, &"damp": 4, &"tufts": 0, &"skulls": 0, &"bones": 0, &"pots": 0, &"stones": 0.0, &"frame": 0.8},
	&"chapel": {&"moss": 0, &"damp": 3, &"tufts": 0, &"skulls": 0, &"bones": 0, &"pots": 0, &"stones": 0.0, &"frame": 0.7},
	&"altar": {&"moss": 5, &"damp": 4, &"tufts": 0, &"skulls": 2, &"bones": 3, &"pots": 1, &"stones": 0.0, &"frame": 0.8},
}

var _room: ArenaRoom
var _rng := RandomNumberGenerator.new()
var _centre := Vector2.ZERO
var _free := 0.0
var _root: Node3D


## Dresses `room` (built: its layout, arena and kit are there) for its look; the look's id is layout.look.
static func dress(room: ArenaRoom) -> void:
	if room.layout == null or not BIOMES.has(room.layout.look):
		return
	var s := FloorScatter.new()
	s._build(room, BIOMES[room.layout.look])


func _build(room: ArenaRoom, cfg: Dictionary) -> void:
	_room = room
	_rng.seed = SEED + hash(String(room.layout.look))
	var b := room.arena.shape().bounds()
	_centre = b.get_center()
	_free = minf(b.size.x, b.size.y) * 0.5 * CENTRE_FREE
	_root = Node3D.new()
	_root.name = "FloorScatter"
	room.add_child(_root)
	ArenaKit.style_only(_root)
	var patches: Array[Transform3D] = []
	var colours: Array[Color] = []
	for k in int(cfg[&"moss"]):
		_patch(patches, colours, MOSS_SIZE, MOSS if _rng.randf() < 0.7 else MOSS_DRY, MOSS_ALPHA)
	for k in int(cfg[&"damp"]):
		_patch(patches, colours, DAMP_SIZE, DAMP, 0.6)
	_multi(PlaneMesh.new(), _patch_material(1.0, PATCH_PRIORITY), patches, colours)
	_tufts(int(cfg[&"tufts"]), cfg.get(&"tuft", Color(0.52, 0.48, 0.37)))
	_skulls(int(cfg[&"skulls"]), int(cfg[&"bones"]))
	_pots(int(cfg[&"pots"]))
	_frame(float(cfg[&"frame"]))
	_stones(float(cfg[&"stones"]))


## A spot on the floor that is free (nothing standing, no door, no start, no floor that strikes, `margin` m from the
## edge); `centre` false keeps out of the middle of the fight. Vector2(NAN, NAN) when none was found.
func _spot(margin: float, clear: float, centre: bool) -> Vector2:
	var f := _room.arena.shape()
	var b := f.bounds()
	for t in TRIES:
		var p := Vector2(_rng.randf_range(b.position.x, b.end.x), _rng.randf_range(b.position.y, b.end.y))
		if not f.contains(p, margin):
			continue
		if not centre and p.distance_to(_centre) < _free:
			continue
		if p.distance_to(_room.arena.start) < START_CLEAR or _room.on_hazard(p, HAZARD_CLEAR):
			continue
		var ok := true
		for o in _room.layout.obstacles:
			if o.depth(p, clear) > 0.0:
				ok = false
				break
		for e in _room.layout.exits:
			if e.mouth.grow(DOOR_CLEAR).has_point(p):
				ok = false
				break
		if ok:
			return p
	return Vector2(NAN, NAN)


func _patch(out: Array[Transform3D], colours: Array[Color], size: Vector2, c: Color, alpha: float) -> void:
	var p := _spot(0.3, 0.2, true)
	if is_nan(p.x):
		return
	var w := _rng.randf_range(size.x, size.y)
	var h := w * _rng.randf_range(0.6, 1.0)
	# fainter in the middle of the fight, strongest at the room's edges
	var near := clampf(1.0 - p.distance_to(_centre) / (_free * 3.0), 0.0, 1.0)
	var basis := Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3(w, 1.0, h))
	out.append(Transform3D(basis, Vector3(p.x, PATCH_Y, p.y)))
	colours.append(Color(c.srgb_to_linear(), alpha * (1.0 - 0.6 * near)))


func _patch_material(radial: float, priority: int) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = PATCH_SHADER
	m.render_priority = priority
	m.set_shader_parameter(&"radial", radial)
	return m


func _multi(mesh: Mesh, mat: Material, xf: Array[Transform3D], colours: Array[Color] = []) -> void:
	if xf.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = not colours.is_empty()
	mm.mesh = mesh
	mm.instance_count = xf.size()
	for i in xf.size():
		mm.set_instance_transform(i, xf[i])
		if mm.use_colors:
			mm.set_instance_color(i, colours[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = mat
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_root.add_child(mmi)


## Tufts (two crossed cards, dry_grass.gdshader), a few in a clump, along the room's edges and never in the middle.
func _tufts(count: int, colour: Color) -> void:
	if count <= 0:
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
	var xf: Array[Transform3D] = []
	while xf.size() < count:
		var p := _spot(0.2, 0.25, false)
		if is_nan(p.x):
			break
		for j in _rng.randi_range(2, 4):
			var q := p + Vector2(_rng.randf_range(-0.4, 0.4), _rng.randf_range(-0.4, 0.4))
			if _room.arena.shape().contains(q, 0.1):
				var s := _rng.randf_range(0.35, 0.7)
				xf.append(Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3(s, s, s)), Vector3(q.x, 0.0, q.y)))
	var mat := ShaderMaterial.new()
	mat.shader = GRASS_SHADER
	mat.set_shader_parameter(&"color", colour)
	_multi(st.commit(), mat, xf)


## Skulls (a rounded cranium and a jaw, in one mesh) lying in twos and threes, and long bones scattered between.
func _skulls(skulls: int, bones: int) -> void:
	var bone := StandardMaterial3D.new()
	bone.albedo_color = BONE
	bone.roughness = 0.9
	var sk: Array[Transform3D] = []
	var made := 0
	while made < skulls:
		var p := _spot(0.5, 0.3, false)
		if is_nan(p.x):
			break
		for j in _rng.randi_range(1, 3):
			if made >= skulls:
				break
			var q := p + Vector2(_rng.randf_range(-0.5, 0.5), _rng.randf_range(-0.5, 0.5))
			var tilt := Basis(Vector3.RIGHT, _rng.randf_range(-0.5, 0.5)) * Basis(Vector3.FORWARD, _rng.randf_range(-0.4, 0.4))
			sk.append(Transform3D(Basis(Vector3.UP, _rng.randf() * TAU) * tilt, Vector3(q.x, SKULL_RADIUS * SKULL_SINK, q.y)))
			made += 1
	var cranium := SphereMesh.new()
	cranium.radius = SKULL_RADIUS
	cranium.height = SKULL_RADIUS * 1.8
	cranium.radial_segments = 10
	cranium.rings = 6
	var jaw := BoxMesh.new()
	jaw.size = Vector3(SKULL_RADIUS * 1.2, SKULL_RADIUS * 0.6, SKULL_RADIUS * 1.0)
	var st := SurfaceTool.new()
	st.append_from(cranium, 0, Transform3D.IDENTITY)
	st.append_from(jaw, 0, Transform3D(Basis.IDENTITY, Vector3(0, -SKULL_RADIUS * 0.8, SKULL_RADIUS * 0.45)))
	_multi(st.commit(), bone, sk)
	var bn: Array[Transform3D] = []
	for k in bones:
		var p := _spot(0.4, 0.2, false)
		if is_nan(p.x):
			continue
		var along := Basis(Vector3.UP, _rng.randf() * TAU) * Basis(Vector3.FORWARD, PI * 0.5)
		bn.append(Transform3D(along, Vector3(p.x, 0.03, p.y)))
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.026
	capsule.height = BONE_LONG
	capsule.radial_segments = 6
	capsule.rings = 2
	_multi(capsule, bone, bn)


## Small clay pots in groups of two or three at the edge, smaller and darker than a breakable one (a decoration never
## looks like what gives gold), merged with the room's other stylized stone.
func _pots(groups: int) -> void:
	for g in groups:
		var p := _spot(0.7, 0.5, false)
		if is_nan(p.x):
			continue
		var n := _rng.randi_range(2, 3)
		var spots: Array[Vector3] = []
		var sizes: Array[float] = []
		for j in n:
			spots.append(Vector3(p.x + _rng.randf_range(-0.45, 0.45), 0.0, p.y + _rng.randf_range(-0.45, 0.45)))
			sizes.append(_rng.randf_range(POT_SIZE.x, POT_SIZE.y))
		_room.kit.styled_build(func() -> void:
			for j in n:
				_room.kit.masonry.pot(spots[j], sizes[j]))


## The dark frame (SR-G3): a band along every edge of the floor, black at the edge and clear FRAME_REACH m in, `share`
## of FRAME_ALPHA at the strongest; the centre of the fight stays the lightest.
func _frame(share: float) -> void:
	if share <= 0.0:
		return
	var f := _room.arena.shape()
	var e := f.edges()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	var edge_c := Color(FRAME_COLOR, FRAME_ALPHA * share)
	var in_c := Color(FRAME_COLOR, 0.0)
	for i in range(0, e.size(), 2):
		var a := e[i]
		var b := e[i + 1]
		var inward := f.edge_inward(i / 2)
		var run := a.distance_to(b)
		var cut := mini(ceili(run / 3.0), 24)
		for k in cut:
			var a0 := a.lerp(b, float(k) / cut)
			var a1 := a.lerp(b, float(k + 1) / cut)
			var w := FRAME_REACH * (0.75 + 0.5 * hash(Vector2i(a0 * 7.0)) / 4294967295.0)
			var q: Array[Vector2] = [a0, a1, a1 + inward * w, a0 + inward * w]
			var cols: Array[Color] = [edge_c, edge_c, in_c, in_c]
			var uv: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
			for j: int in [0, 1, 2, 0, 2, 3]:
				st.set_color(cols[j])
				st.set_uv(uv[j])
				st.add_vertex(Vector3(q[j].x, PATCH_Y * 0.5, q[j].y))
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = _patch_material(0.0, PATCH_PRIORITY - 1)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_root.add_child(mi)


## Big fallen stones just past the floor's edge (SR-G3), over the abyss: a ruin the room is framed by. `per_step` per
## STONE_STEP m of edge; a stone never reaches the floor (it starts STONE_OUT m beyond) and stays under 0.9 m high.
func _stones(per_step: float) -> void:
	if per_step <= 0.0:
		return
	var f := _room.arena.shape()
	var e := f.edges()
	var made: Array = []
	for i in range(0, e.size(), 2):
		var a := e[i]
		var b := e[i + 1]
		var inward := f.edge_inward(i / 2)
		var n := int(a.distance_to(b) / STONE_STEP * per_step)
		for k in n:
			var p := a.lerp(b, _rng.randf_range(0.1, 0.9)) - inward * _rng.randf_range(STONE_OUT.x, STONE_OUT.y)
			if f.covers(p):
				continue
			var side := _rng.randf_range(STONE_SIDE.x, STONE_SIDE.y)
			var drop := _rng.randf_range(STONE_DROP.x, STONE_DROP.y)
			made.append([p, side, drop, _rng.randf() * TAU, _rng.randf_range(-0.5, 0.5), _rng.randf_range(-0.4, 0.4)])
	if made.is_empty():
		return
	_room.kit.styled_build(func() -> void:
		var sm := _room.kit.masonry
		for s: Array in made:
			var side: float = s[1]
			var blk := sm.box(Vector3(s[0].x, minf(0.9, side * 0.6) - float(s[2]) - side * 0.3, s[0].y),
				Vector3(side, side * 0.6, side * 0.85), s[3], _room.stone(), false)
			blk.rotate_object_local(Vector3.RIGHT, s[4])
			blk.rotate_object_local(Vector3.BACK, s[5]))
