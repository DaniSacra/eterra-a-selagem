class_name Masonry
extends RefCounted
## Built stone for the catacomb hall, made of boxes in the dressed-stone material (masonry.gdshader), where the
## KayKit pieces are too small, too clean or missing: balustrades with chunky posts, stairs, obelisks, pointed
## arches, plinths, clay pots. Everything goes under `root`; nothing here blocks the way (CatacombHall records that).

const SHADER := preload("res://assets/shaders/masonry.gdshader")
## Balustrade: post size, rail height, posts every POST_GAP meters, balusters between two posts.
const POST := Vector3(0.62, 1.15, 0.62)
const POST_GAP := 2.8
const RAIL_TOP := 1.0
const BALUSTERS := 2
const CLAY := Color(0.52, 0.17, 0.09)
const CLAY_DARK := Color(0.3, 0.1, 0.06)

var root: Node3D
var _mats := {}
var _clay: StandardMaterial3D


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


## A box of stone: its centre, size and turn around Y.
func box(center: Vector3, size: Vector3, yaw: float = 0.0, mat: Material = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	mi.mesh = b
	mi.transform = Transform3D(Basis(Vector3.UP, yaw), center)
	mi.material_override = mat if mat else stone(center.y - size.y * 0.5)
	root.add_child(mi)
	return mi


## A box standing on the ground at `foot` (the middle of its base).
func block(foot: Vector3, size: Vector3, yaw: float = 0.0, mat: Material = null) -> MeshInstance3D:
	return box(foot + Vector3(0, size.y * 0.5, 0), size, yaw, mat if mat else stone(foot.y))


## A four-sided point (pyramid) on top of something: its base centre, base width, height.
func point(base: Vector3, width: float, height: float, yaw: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = 0.0
	c.bottom_radius = width * 0.7071
	c.height = height
	c.radial_segments = 4
	c.rings = 1
	mi.mesh = c
	mi.transform = Transform3D(Basis(Vector3.UP, yaw + PI * 0.25), base + Vector3(0, height * 0.5, 0))
	mi.material_override = stone(base.y)
	root.add_child(mi)
	return mi


## A balustrade from a to b on the floor: chunky capped posts at both ends and every POST_GAP meters, a thick rail
## on top, a curb at the foot and a couple of square balusters between each pair of posts.
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
	for i in spans:
		var p0 := a.lerp(b, float(i) / spans)
		var p1 := a.lerp(b, float(i + 1) / spans)
		var mid := (p0 + p1) * 0.5
		var span := p0.distance_to(p1) - POST.x
		box(mid + Vector3(0, RAIL_TOP - 0.12, 0), Vector3(span, 0.24, 0.42), yaw, mat)
		box(mid + Vector3(0, 0.12, 0), Vector3(span, 0.24, 0.5), yaw, mat)
		for k in BALUSTERS:
			var t := (k + 1.0) / (BALUSTERS + 1.0)
			box(p0.lerp(p1, t) + Vector3(0, 0.5, 0), Vector3(0.2, 0.55, 0.2), yaw, mat)


## One balustrade post: plinth, shaft, a wide cap.
func post(at: Vector3, yaw: float = 0.0, height: float = POST.y) -> void:
	var mat := stone(at.y)
	box(at + Vector3(0, 0.12, 0), Vector3(POST.x + 0.14, 0.24, POST.z + 0.14), yaw, mat)
	box(at + Vector3(0, height * 0.5, 0), Vector3(POST.x, height, POST.z), yaw, mat)
	box(at + Vector3(0, height + 0.08, 0), Vector3(POST.x + 0.18, 0.16, POST.z + 0.18), yaw, mat)


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


## A tall tapering standing stone: a base, a shaft of stacked blocks narrowing up, a point, and a dark niche on the
## face that looks along `face`.
func obelisk(at: Vector3, height: float, width: float, face: Vector2) -> void:
	var yaw := atan2(face.x, face.y)
	block(at, Vector3(width * 1.35, 0.5, width * 1.35), yaw)
	var y := 0.5
	var shaft := height - 0.5 - width * 0.9
	var layers := 4
	for i in layers:
		var w := width * lerpf(1.0, 0.72, float(i) / layers)
		var h := shaft / layers
		block(at + Vector3(0, y, 0), Vector3(w, h, w), yaw + (0.03 if i % 2 else -0.02))
		y += h
	point(at + Vector3(0, y, 0), width * 0.74, width * 0.9, yaw)
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.02, 0.02, 0.03)
	dark.roughness = 1.0
	var f := Vector3(face.x, 0, face.y).normalized()
	box(at + Vector3(0, height * 0.62, 0) + f * (width * 0.36), Vector3(width * 0.32, height * 0.16, 0.12), yaw, dark)


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


## A clay pot: belly, shoulder, neck and lip. size: its height in meters.
func pot(at: Vector3, size: float = 0.6) -> void:
	if _clay == null:
		_clay = StandardMaterial3D.new()
		_clay.albedo_color = CLAY
		_clay.roughness = 0.75
		_clay.rim_enabled = true
		_clay.rim = 0.2
	var body := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = size * 0.38
	s.height = size * 0.78
	s.radial_segments = 12
	s.rings = 6
	body.mesh = s
	body.material_override = _clay
	body.position = at + Vector3(0, size * 0.4, 0)
	root.add_child(body)
	var neck := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = size * 0.2
	c.bottom_radius = size * 0.15
	c.height = size * 0.22
	c.radial_segments = 10
	neck.mesh = c
	neck.material_override = _clay
	neck.position = at + Vector3(0, size * 0.85, 0)
	root.add_child(neck)
