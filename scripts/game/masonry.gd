class_name Masonry
extends RefCounted
## Built stone for the catacomb hall, made of boxes in the dressed-stone material (masonry.gdshader), where the
## KayKit pieces are too small, too clean or missing: balustrades with chunky posts, stairs, obelisks, pointed
## arches, plinths, clay pots. Everything goes under `root`; nothing here blocks the way (CatacombHall records that).

const SHADER := preload("res://assets/shaders/masonry.gdshader")
const DEPTH_SHADER := preload("res://assets/shaders/depth_stone.gdshader")
## Balustrade (the picture's: capped posts bigger than a man's head): post size, the cap's and the step's under it
## (width, height), posts every POST_GAP meters, the rail (height, depth, top), the curb at its foot, and balusters
## between two posts (their width).
const POST := Vector3(0.9, 1.3, 0.9)
const POST_CAP := Vector2(1.1, 0.22)
const POST_STEP := Vector2(0.95, 0.1)
const POST_GAP := 3.0
const RAIL := Vector2(0.3, 0.45)
const RAIL_TOP := 1.05
const CURB := 0.26
const BALUSTERS := 3
const BALUSTER := 0.22
## Hooded statue (shares of its height H): the robe's radius at the hem and at the chest, its pleats (how many, how
## deep), the hood's middle height and how far forward it is pulled, the joined hands' height, the face's darkness.
const ROBE_HEM := 0.2
const ROBE_CHEST := 0.13
const ROBE_TOP := 0.78
const PLEATS := 10
const PLEAT_DEPTH := 0.012
const HOOD_AT := 0.86
const HOOD_FORWARD := 0.03
const HANDS_AT := 0.6
const FACE_DARK := 0.04
## Pots: the belly's radius (share of the pot's height). Candles: the wax, the flame's size and colour.
const POT_BELLY := 0.38
const WAX := Color(0.92, 0.86, 0.72)
const CANDLE_FLAME := 0.22
const CANDLE_FIRE := Color(4.0, 2.2, 0.8)
const CLAY := Color(0.55, 0.2, 0.1)
const CLAY_DARK := Color(0.3, 0.1, 0.06)

var root: Node3D
## Visual layers given to what is built next (the depths take ArenaKit.DEPTH_LAYER too, for their own lights).
var layers := 1
var _mats := {}
var _clay: StandardMaterial3D
var _depth: ShaderMaterial
var _mouth: StandardMaterial3D
var _wax: StandardMaterial3D
var _wax_mesh: CylinderMesh
var _flame: QuadMesh
var _statue_mesh: ArrayMesh
var _statue_mats := {}


func _init(parent: Node3D) -> void:
	root = parent


## The stone material whose grime is thickest at height base_y (where the piece stands). tint: multiplies the colour.
func stone(base_y: float = 0.0, tint := Color.WHITE) -> ShaderMaterial:
	var key := "%.1f|%s" % [base_y, tint.to_html()]
	if not _mats.has(key):
		var m := ShaderMaterial.new()
		m.shader = SHADER
		m.set_shader_parameter(&"base_y", base_y)
		m.set_shader_parameter(&"stone_a", Color(0.3, 0.29, 0.33) * tint)
		m.set_shader_parameter(&"stone_b", Color(0.42, 0.4, 0.44) * tint)
		_mats[key] = m
	return _mats[key]


## The unlit stone of the far depths (depth_stone.gdshader): dark shapes fading into a mist of colour `mist`.
func depth_stone(mist: Color) -> ShaderMaterial:
	if _depth == null:
		_depth = ShaderMaterial.new()
		_depth.shader = DEPTH_SHADER
		_depth.set_shader_parameter(&"mist_color", mist)
	return _depth


## A box of stone: its centre, size and turn around Y.
func box(center: Vector3, size: Vector3, yaw: float = 0.0, mat: Material = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	mi.mesh = b
	mi.transform = Transform3D(Basis(Vector3.UP, yaw), center)
	mi.material_override = mat if mat else stone(center.y - size.y * 0.5)
	_add(mi)
	return mi


## A box standing on the ground at `foot` (the middle of its base).
func block(foot: Vector3, size: Vector3, yaw: float = 0.0, mat: Material = null) -> MeshInstance3D:
	return box(foot + Vector3(0, size.y * 0.5, 0), size, yaw, mat if mat else stone(foot.y))


## A four-sided point (pyramid) on top of something: its base centre, base width, height; `top` > 0 cuts it flat
## (a frustum whose top is that share of the base).
func point(base: Vector3, width: float, height: float, yaw: float = 0.0, top := 0.0, mat: Material = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = width * 0.7071 * top
	c.bottom_radius = width * 0.7071
	c.height = height
	c.radial_segments = 4
	c.rings = 1
	mi.mesh = c
	mi.transform = Transform3D(Basis(Vector3.UP, yaw + PI * 0.25), base + Vector3(0, height * 0.5, 0))
	mi.material_override = mat if mat else stone(base.y)
	_add(mi)
	return mi


## A balustrade from a to b on the floor: chunky capped posts at both ends and every POST_GAP meters, a thick rail
## on top, a curb at the foot and bellied square balusters between each pair of posts.
func balustrade(a: Vector3, b: Vector3, end_posts := true) -> void:
	var length := Vector2(b.x - a.x, b.z - a.z).length()
	if length < 0.3:
		return
	var yaw := atan2(b.x - a.x, b.z - a.z) + PI * 0.5
	var spans := maxi(1, roundi(length / POST_GAP))
	var mat := stone(a.y)
	for i in spans + 1:
		if not end_posts and (i == 0 or i == spans):
			continue
		var p := a.lerp(b, float(i) / spans)
		post(p, yaw)
	var shaft := RAIL_TOP - RAIL.x - CURB
	for i in spans:
		var p0 := a.lerp(b, float(i) / spans)
		var p1 := a.lerp(b, float(i + 1) / spans)
		var mid := (p0 + p1) * 0.5
		var span := p0.distance_to(p1) - POST.x
		box(mid + Vector3(0, RAIL_TOP - RAIL.x * 0.5, 0), Vector3(span, RAIL.x, RAIL.y), yaw, mat)
		box(mid + Vector3(0, CURB * 0.5, 0), Vector3(span, CURB, RAIL.y + 0.1), yaw, mat)
		for k in BALUSTERS:
			var t := (k + 1.0) / (BALUSTERS + 1.0)
			var at := p0.lerp(p1, t) + Vector3(0, CURB, 0)
			box(at + Vector3(0, shaft * 0.5, 0), Vector3(BALUSTER, shaft, BALUSTER), yaw, mat)
			box(at + Vector3(0, shaft * 0.35, 0), Vector3(BALUSTER * 1.45, shaft * 0.3, BALUSTER * 1.45), yaw, mat)


## One balustrade post: plinth, shaft, a step under a wide cap.
func post(at: Vector3, yaw: float = 0.0, height: float = POST.y) -> void:
	var mat := stone(at.y)
	box(at + Vector3(0, CURB * 0.5, 0), Vector3(POST.x + 0.12, CURB, POST.z + 0.12), yaw, mat)
	box(at + Vector3(0, height * 0.5, 0), Vector3(POST.x, height, POST.z), yaw, mat)
	box(at + Vector3(0, height + POST_STEP.y * 0.5, 0), Vector3(POST_STEP.x, POST_STEP.y, POST_STEP.x), yaw, mat)
	box(at + Vector3(0, height + POST_STEP.y + POST_CAP.y * 0.5, 0), Vector3(POST_CAP.x, POST_CAP.y, POST_CAP.x), yaw, mat)


## A flight of stairs. foot: the middle of the lowest step's front edge; up: the way up the flight (on the floor);
## width, number of steps, rise and run of each.
func stairs(foot: Vector3, up: Vector2, width: float, steps: int, rise: float, run: float) -> void:
	var dir := Vector3(up.x, 0, up.y).normalized()
	var yaw := atan2(dir.x, dir.z)
	for i in steps:
		# each step a block from a little under the flight's foot up to its top, so the flight is solid
		var h := rise * (i + 1) + 0.6
		var c := foot + dir * (run * (i + 0.5))
		box(Vector3(c.x, foot.y - 0.6 + h * 0.5, c.z), Vector3(width, h, run), yaw, stone(foot.y))


## A thick, blunt standing stone (the picture's): a base, three stacked blocks each a little narrower and turned, a low
## flat-topped cap set a little askew, and a dark pointed niche on the face that looks along `face`.
func obelisk(at: Vector3, height: float, width: float, face: Vector2) -> void:
	var yaw := atan2(face.x, face.y)
	block(at, Vector3(width * 1.3, 0.5, width * 1.3), yaw)
	var y := 0.5
	var cap := width * 0.45
	var shaft := height - 0.5 - cap
	var layers := 3
	var w := width
	for i in layers:
		var h := shaft / layers
		block(at + Vector3(0, y, 0), Vector3(w, h - 0.06, w), yaw + [-0.04, 0.05, -0.02][i])
		y += h
		w *= 0.91
	var c := point(at + Vector3(0, y, 0), w * 1.02, cap, yaw + 0.06, 0.55)
	c.rotate_object_local(Vector3.RIGHT, 0.07)
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.02, 0.02, 0.03)
	dark.roughness = 1.0
	var f := Vector3(face.x, 0, face.y).normalized()
	pointed_arch(at + Vector3(0, height * 0.55, 0) + f * (width * 0.44), face, width * 0.45, height * 0.2, 0.08, 0.1, dark)
	box(at + Vector3(0, height * 0.55 + height * 0.08, 0) + f * (width * 0.43), Vector3(width * 0.4, height * 0.16, 0.06), yaw, dark)


## A pointed (gothic) arch frame standing on the ground: two jambs and two slanted stones meeting at the apex.
## foot: the middle of the opening at the ground; facing: the way the arch looks; width and height of the opening;
## thick: width of the stones; deep: their depth.
func pointed_arch(foot: Vector3, facing: Vector2, width: float, height: float, thick: float, deep: float, mat: Material = null) -> void:
	var yaw := atan2(facing.x, facing.y)
	var basis := Basis(Vector3.UP, yaw)
	var m := mat if mat else stone(foot.y)
	var spring := height - width * 0.55
	for s in [-1.0, 1.0]:
		var jamb := foot + basis * Vector3(s * (width * 0.5 + thick * 0.5), spring * 0.5, 0)
		box(jamb, Vector3(thick, spring, deep), yaw, m)
		# the slanted stone from the top of the jamb to the apex
		var from := Vector3(s * (width * 0.5 + thick * 0.5), spring, 0)
		var to := Vector3(0, height + thick * 0.4, 0)
		var mid := (from + to) * 0.5
		var length := from.distance_to(to) + thick * 0.6
		var tilt := atan2(to.y - from.y, (to.x - from.x))
		var mi := box(foot + basis * mid, Vector3(length, thick, deep), 0.0, m)
		mi.basis = basis * Basis(Vector3.FORWARD, -tilt)


## A hooded monk carved in dark stone (the picture's statues, no model yet): a pleated robe to the ground, broad
## shoulders, hands joined on the chest, a deep hood over a face in shadow. foot: the middle of its base; it looks
## along +Z turned by yaw; height in meters; tint: the stone's colour.
func hooded_statue(foot: Vector3, yaw: float, height: float, tint: Color) -> MeshInstance3D:
	if _statue_mesh == null:
		_statue_mesh = _build_statue()
	var key := tint.to_html()
	if not _statue_mats.has(key):
		var mat := StandardMaterial3D.new()
		mat.vertex_color_use_as_albedo = true
		mat.albedo_color = tint
		var tex := NoiseTexture2D.new()
		var noise := FastNoiseLite.new()
		noise.frequency = 0.15
		noise.fractal_octaves = 3
		tex.noise = noise
		tex.seamless = true
		mat.albedo_texture = tex
		mat.uv1_triplanar = true
		mat.uv1_world_triplanar = true
		mat.uv1_scale = Vector3.ONE * 0.6
		mat.roughness = 0.95
		mat.rim_enabled = true
		mat.rim = 0.3
		mat.rim_tint = 0.8
		_statue_mats[key] = mat
	var mi := MeshInstance3D.new()
	mi.mesh = _statue_mesh
	mi.material_override = _statue_mats[key]
	mi.transform = Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * height), foot)
	_add(mi)
	return mi


## The statue of height 1, looking along +Z: lathed robe, shoulders, hood with its point behind, arms and hands, and
## the dark face (vertex colour: the face is near black, the rest white and taking the tint).
func _build_statue() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var robe: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(ROBE_HEM * 1.04, 0.0), Vector2(ROBE_HEM, 0.04),
		Vector2(ROBE_HEM * 0.93, 0.18), Vector2(ROBE_HEM * 0.82, 0.4), Vector2(ROBE_CHEST * 1.08, 0.56),
		Vector2(ROBE_CHEST, 0.7), Vector2(ROBE_CHEST * 0.85, ROBE_TOP), Vector2(0.06, ROBE_TOP + 0.02), Vector2(0.0, ROBE_TOP + 0.02)]
	_lathe(st, robe, Transform3D.IDENTITY, Color.WHITE, PLEAT_DEPTH)
	# shoulders and the cape over them, a flattened ball
	_lathe(st, _ellipse(), Transform3D(Basis.from_scale(Vector3(0.15, 0.05, 0.1)), Vector3(0, 0.755, -0.01)), Color.WHITE)
	# the hood, pulled forward, and its point falling behind
	_lathe(st, _ellipse(), Transform3D(Basis.from_scale(Vector3(0.068, 0.088, 0.08)), Vector3(0, HOOD_AT, HOOD_FORWARD)), Color.WHITE)
	var tip: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.045, 0.0), Vector2(0.0, 0.11)]
	_lathe(st, tip, Transform3D(Basis(Vector3.RIGHT, -2.2), Vector3(0, HOOD_AT + 0.02, -0.02)), Color.WHITE)
	# the face: a dark hollow in the hood's front
	_lathe(st, _ellipse(), Transform3D(Basis.from_scale(Vector3(0.042, 0.055, 0.02)), Vector3(0, HOOD_AT - 0.012, HOOD_FORWARD + 0.068)),
		Color.WHITE * FACE_DARK)
	# the arms from the shoulders down to the hands joined on the chest
	for s in [-1.0, 1.0]:
		var from := Vector3(s * 0.12, 0.74, 0.02)
		var to := Vector3(s * 0.035, HANDS_AT, ROBE_CHEST + 0.02)
		var up := (to - from).normalized()
		var side := up.cross(Vector3.FORWARD).normalized()
		var basis := Basis(side * 0.042, up * from.distance_to(to), side.cross(up) * 0.042)
		var arm: Array[Vector2] = [Vector2(0.0, -0.05), Vector2(0.9, 0.0), Vector2(1.0, 0.5), Vector2(0.9, 1.0), Vector2(0.0, 1.05)]
		_lathe(st, arm, Transform3D(basis, from), Color.WHITE)
	_lathe(st, _ellipse(), Transform3D(Basis.from_scale(Vector3(0.05, 0.04, 0.035)), Vector3(0, HANDS_AT, ROBE_CHEST + 0.04)), Color.WHITE)
	st.generate_normals()
	return st.commit()


## The half outline of a ball of radius 1 (bottom to top), to lathe.
func _ellipse() -> Array[Vector2]:
	var e: Array[Vector2] = []
	for i in 9:
		var a := PI * i / 8.0
		e.append(Vector2(sin(a), -cos(a)))
	return e


## Turns an outline (radius, height) around Y into a closed surface, placed by xf; pleat: depth of vertical folds.
func _lathe(st: SurfaceTool, outline: Array[Vector2], xf: Transform3D, color: Color, pleat := 0.0) -> void:
	var segs := 20
	var rings: Array[PackedVector3Array] = []
	for p in outline:
		var ring := PackedVector3Array()
		for j in segs:
			var a := TAU * j / segs
			var r := p.x + pleat * sin(a * PLEATS) * (1.0 - smoothstep(0.5, ROBE_TOP, p.y)) * float(p.x > 0.0)
			ring.append(xf * Vector3(sin(a) * r, p.y, cos(a) * r))
		rings.append(ring)
	st.set_color(color)
	st.set_smooth_group(0)
	for i in rings.size() - 1:
		for j in segs:
			var k := (j + 1) % segs
			var a: Vector3 = rings[i][j]
			var b: Vector3 = rings[i][k]
			var c: Vector3 = rings[i + 1][j]
			var d: Vector3 = rings[i + 1][k]
			st.add_vertex(a)
			st.add_vertex(c)
			st.add_vertex(b)
			st.add_vertex(b)
			st.add_vertex(c)
			st.add_vertex(d)


## A clay pot: belly, shoulder, neck, a lip turned out and its dark mouth. size: its height in meters.
func pot(at: Vector3, size: float = 0.9) -> void:
	if _clay == null:
		_clay = StandardMaterial3D.new()
		_clay.albedo_color = CLAY
		_clay.roughness = 0.75
		_clay.rim_enabled = true
		_clay.rim = 0.2
		_mouth = StandardMaterial3D.new()
		_mouth.albedo_color = CLAY_DARK * 0.2
	var body := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = size * POT_BELLY
	s.height = size * 0.72
	s.radial_segments = 14
	s.rings = 8
	body.mesh = s
	body.material_override = _clay
	body.position = at + Vector3(0, size * 0.36, 0)
	_add(body)
	var neck := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = size * 0.13
	c.bottom_radius = size * 0.22
	c.height = size * 0.26
	c.radial_segments = 12
	neck.mesh = c
	neck.material_override = _clay
	neck.position = at + Vector3(0, size * 0.8, 0)
	_add(neck)
	var lip := MeshInstance3D.new()
	var t := TorusMesh.new()
	t.inner_radius = size * 0.11
	t.outer_radius = size * 0.19
	t.rings = 14
	t.ring_segments = 6
	lip.mesh = t
	lip.material_override = _clay
	lip.position = at + Vector3(0, size * 0.93, 0)
	_add(lip)
	var mouth := MeshInstance3D.new()
	var d := CylinderMesh.new()
	d.top_radius = size * 0.12
	d.bottom_radius = size * 0.12
	d.height = 0.01
	d.radial_segments = 10
	mouth.mesh = d
	mouth.material_override = _mouth
	mouth.position = at + Vector3(0, size * 0.94, 0)
	_add(mouth)


## A thick candle of cream wax with drips at its foot, and its flame (unlit, glowing). height, radius in meters.
func candle(at: Vector3, height: float, radius: float) -> void:
	if _wax == null:
		_wax = StandardMaterial3D.new()
		_wax.albedo_color = WAX
		_wax.roughness = 0.6
		_wax.rim_enabled = true
		_wax.rim = 0.3
		_wax_mesh = CylinderMesh.new()
		_wax_mesh.top_radius = 1.0
		_wax_mesh.bottom_radius = 1.0
		_wax_mesh.height = 1.0
		_wax_mesh.radial_segments = 8
		_wax_mesh.rings = 1
		_flame = Fx.quad(CANDLE_FLAME, CANDLE_FIRE)
	var body := MeshInstance3D.new()
	body.mesh = _wax_mesh
	body.material_override = _wax
	body.transform = Transform3D(Basis.from_scale(Vector3(radius, height, radius)), at + Vector3(0, height * 0.5, 0))
	_add(body)
	# the wax run down and pooled round its foot
	var drip := MeshInstance3D.new()
	drip.mesh = _wax_mesh
	drip.material_override = _wax
	drip.transform = Transform3D(Basis.from_scale(Vector3(radius * 1.5, height * 0.18, radius * 1.5)), at + Vector3(0, height * 0.09, 0))
	_add(drip)
	var f := MeshInstance3D.new()
	f.mesh = _flame
	f.position = at + Vector3(0, height + CANDLE_FLAME * 0.4, 0)
	f.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_add(f)


func _add(mi: GeometryInstance3D) -> void:
	mi.layers = layers
	root.add_child(mi)
