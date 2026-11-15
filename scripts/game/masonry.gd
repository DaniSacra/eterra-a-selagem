class_name Masonry
extends RefCounted
## Built stone for the catacomb hall, made of boxes in the dressed-stone material (masonry.gdshader), where the
## KayKit pieces are too small, too clean or missing: balustrades with chunky posts, stairs, obelisks, pointed
## arches, plinths, clay pots. Everything goes under `root`; nothing here blocks the way (CatacombHall records that).

const SHADER := preload("res://assets/shaders/masonry.gdshader")
const DEPTH_SHADER := preload("res://assets/shaders/depth_stone.gdshader")
## Relief of real stone (Poly Haven "Rock Surface", CC0, docs/art/asset_credits.md) under the painted colour.
const ROCK_NORMAL := preload("res://assets/textures/rock_surface/rock_surface_nor_gl_1k.jpg")
const ROCK_HEIGHT := preload("res://assets/textures/rock_surface/rock_surface_disp_1k.jpg")
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
const PLEATS := 7
const PLEAT_DEPTH := 0.025
## Where the pleats fade out (share of the height: up to the chest), the belt (height, thickness), the sleeves' mouth
## (radius) over the hands, the two steps of the carved base (each as a share of the statue's height).
const PLEAT_TOP := 0.72
const BELT := Vector2(0.55, 0.03)
const SLEEVE := 0.07
const BASE_STEPS := Vector2(0.06, 0.04)
const HOOD_AT := 0.86
const HOOD_FORWARD := 0.03
const HANDS_AT := 0.6
const FACE_DARK := 0.04
## The statue's vertex values: the robe takes ROBE_VALUE, the pale mask in the hood's shadow twice that.
const ROBE_VALUE := 0.5
const MASK := Vector3(0.03, 0.04, 0.012)
## Pots: the belly's radius (share of the pot's height). Candles: the wax, the flame's size and colour.
const POT_BELLY := 0.38
## Standing stones: the share of their columns cracked upright, the frame round their niche.
const OBELISK_CRACKS := 0.3
const OBELISK_FRAME := 0.08
const WAX := Color(0.95, 0.7, 0.5)
## The wax lit a little from inside by its flame, so its shaded side stays cream under the cold teal air (not olive).
const WAX_GLOW := Color(0.12, 0.05, 0.015)
const CANDLE_FLAME := 0.3
const CANDLE_FIRE := Color(2.3, 1.4, 0.55)
const CLAY := Color(0.55, 0.2, 0.1)
## Bevelled stone (no bare box anywhere): the chamfer on every edge (CHAMFER on blocks up to CHAMFER_BIG_AT meters,
## CHAMFER_BIG on bigger ones); blocks up to VARY_MAX meters are each set a little askew (yaw, tilt in degrees), a
## little smaller on each axis (down to VARY_SCALE), and a share of them (CHIPPED) has one corner knocked off (the
## chip's size range in meters). Sizes are snapped to BEVEL_SNAP meters so the meshes are shared.
const CHAMFER := 0.06
const CHAMFER_BIG := 0.1
const CHAMFER_BIG_AT := 1.5
const VARY_MAX := 3.5
const VARY_YAW := 1.5
const VARY_TILT := 0.8
const VARY_SCALE := 0.96
const CHIPPED := 0.3
const CHIP := Vector2(0.1, 0.25)
const BEVEL_SNAP := 0.02
## The side of the floor squares (m) the stone is joined by (merge).
const MERGE_CELL := 8.0
## The facade's ashlar (big, uneven): course height and how much each course varies (shares, see masonry.gdshader),
## block length and its spread, the joint, and its stone darker than the rest.
const ASHLAR := Vector4(1.15, 0.11, 1.9, 0.37)
const ASHLAR_JOINT := 0.06
const ASHLAR_DARK := 0.9
const ASHLAR_A := Color(0.24, 0.27, 0.31)
const ASHLAR_B := Color(0.34, 0.37, 0.41)
## Voussoirs of a pointed arch: their length along the arch, the joint between two, how far each may sink back.
const VOUSSOIR := 0.55
const VOUSSOIR_JOINT := 0.04
const VOUSSOIR_SINK := 0.05
## Segments along a whole one-mesh arch ring (arch_ring).
const ARCH_SEGMENTS := 16
## A pinnacle's crockets (blocks along each edge of its spire): how many, their size; its finial's size.
const CROCKETS := 4
const CROCKET := 0.18
const FINIAL := 0.3
## Pendants longer than this (m) grow two smaller teeth off their sides.
const PENDANT_SIDE_TEETH := 0.9
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
var _bevels := {}
## What has been built (merge joins it).
var _built: Array[MeshInstance3D] = []


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
		m.set_shader_parameter(&"rock_normal", ROCK_NORMAL)
		m.set_shader_parameter(&"rock_height", ROCK_HEIGHT)
		_mats[key] = m
	return _mats[key]


## The facade's stone: big uneven ashlar (ASHLAR), a little darker, the same grime and wash.
func ashlar(base_y: float = 0.0, tint := Color.WHITE) -> ShaderMaterial:
	var key := "ashlar|%.1f|%s" % [base_y, tint.to_html()]
	if not _mats.has(key):
		var m := stone(base_y, tint * ASHLAR_DARK).duplicate() as ShaderMaterial
		m.set_shader_parameter(&"course", ASHLAR.x)
		m.set_shader_parameter(&"course_var", ASHLAR.y)
		m.set_shader_parameter(&"block_len", ASHLAR.z)
		m.set_shader_parameter(&"block_var", ASHLAR.w)
		m.set_shader_parameter(&"joint_width", ASHLAR_JOINT)
		m.set_shader_parameter(&"stone_a", ASHLAR_A * tint * ASHLAR_DARK)
		m.set_shader_parameter(&"stone_b", ASHLAR_B * tint * ASHLAR_DARK)
		_mats[key] = m
	return _mats[key]


## The unlit stone of the far depths (depth_stone.gdshader): dark shapes fading into a mist of colour `mist`.
func depth_stone(mist: Color) -> ShaderMaterial:
	if _depth == null:
		_depth = ShaderMaterial.new()
		_depth.shader = DEPTH_SHADER
		_depth.set_shader_parameter(&"mist_color", mist)
	return _depth


## A box of stone: its centre, size and turn around Y. Bevelled (bevel_mesh); a small one (vary) is also set a little
## askew and may have a chipped corner, each the same at the same place (seeded by it).
func box(center: Vector3, size: Vector3, yaw: float = 0.0, mat: Material = null, vary := true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var basis := Basis(Vector3.UP, yaw)
	var chip_corner := -1
	var chip := 0.0
	var dims := size
	if vary and maxf(size.x, maxf(size.y, size.z)) <= VARY_MAX:
		var r := RandomNumberGenerator.new()
		r.seed = hash(Vector3i(center * 100.0))
		basis = basis * Basis.from_euler(Vector3(deg_to_rad(r.randf_range(-VARY_TILT, VARY_TILT)),
			deg_to_rad(r.randf_range(-VARY_YAW, VARY_YAW)), deg_to_rad(r.randf_range(-VARY_TILT, VARY_TILT))))
		dims = size * Vector3(r.randf_range(VARY_SCALE, 1.0), r.randf_range(VARY_SCALE, 1.0), r.randf_range(VARY_SCALE, 1.0))
		if r.randf() < CHIPPED:
			chip_corner = r.randi_range(0, 7)
			chip = r.randf_range(CHIP.x, CHIP.y)
	mi.mesh = bevel_mesh(dims, CHAMFER if maxf(size.x, maxf(size.y, size.z)) <= CHAMFER_BIG_AT else CHAMFER_BIG, chip_corner, chip)
	mi.transform = Transform3D(basis, center)
	mi.material_override = mat if mat else stone(center.y - size.y * 0.5)
	_add(mi)
	return mi


## A box of `size` with every edge cut at 45 degrees (`chamfer` meters) and, if chip_corner is 0 to 7, that corner
## knocked off deeper (`chip` meters), with flat normals, so the light catches the bevels. Shared by snapped size.
func bevel_mesh(size: Vector3, chamfer: float, chip_corner := -1, chip := 0.0) -> ArrayMesh:
	var sz := Vector3(maxf(snappedf(size.x, BEVEL_SNAP), BEVEL_SNAP), maxf(snappedf(size.y, BEVEL_SNAP), BEVEL_SNAP),
		maxf(snappedf(size.z, BEVEL_SNAP), BEVEL_SNAP))
	var key := "%s|%.2f|%d|%.2f" % [sz, chamfer, chip_corner, snappedf(chip, 0.05)]
	if not _bevels.has(key):
		_bevels[key] = _build_bevel(sz * 0.5, chamfer, chip_corner, snappedf(chip, 0.05))
	return _bevels[key]


func _build_bevel(h: Vector3, chamfer: float, chip_corner: int, chip: float) -> ArrayMesh:
	var least := minf(h.x, minf(h.y, h.z))
	var c := minf(chamfer, least * 0.45)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# each corner (bits: x, y, z sign) has three points, one on each face that meets there
	var pts: Array[Vector3] = []
	for k in 8:
		var s := Vector3(1.0 if k & 1 else -1.0, 1.0 if k & 2 else -1.0, 1.0 if k & 4 else -1.0)
		var cc := minf(chip, least * 0.9) if k == chip_corner else c
		for axis in 3:
			var p := Vector3(s.x * (h.x - cc), s.y * (h.y - cc), s.z * (h.z - cc))
			p[axis] = s[axis] * h[axis]
			pts.append(p)
	for axis in 3:
		var b := (axis + 1) % 3
		var d := (axis + 2) % 3
		for sa in 2:
			# the face on this side of this axis
			var ring: Array[Vector3] = []
			for q: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)]:
				ring.append(pts[_corner(axis, sa, b, q.x, d, q.y) * 3 + axis])
			_quad(st, ring[0], ring[1], ring[2], ring[3])
		# the bevels along the edges that run along this axis
		for sb in 2:
			for sd in 2:
				var k0 := _corner(axis, 0, b, sb, d, sd)
				var k1 := _corner(axis, 1, b, sb, d, sd)
				_quad(st, pts[k0 * 3 + b], pts[k1 * 3 + b], pts[k1 * 3 + d], pts[k0 * 3 + d])
	for k in 8:
		_tri(st, pts[k * 3], pts[k * 3 + 1], pts[k * 3 + 2])
	return st.commit()


## The corner index with sign bit sa on axis a, sb on axis b and sd on axis d.
func _corner(a: int, sa: int, b: int, sb: int, d: int, sd: int) -> int:
	return (sa << a) | (sb << b) | (sd << d)


func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	_tri(st, a, b, c)
	_tri(st, a, c, d)


## One flat triangle of a convex shape round the origin, turned to face outward.
func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var n := (c - a).cross(b - a)
	if n.length_squared() < 1e-10:
		return
	if n.dot(a + b + c) < 0.0:
		var t := b
		b = c
		c = t
		n = -n
	st.set_normal(n.normalized())
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)


## A box standing on the ground at `foot` (the middle of its base).
func block(foot: Vector3, size: Vector3, yaw: float = 0.0, mat: Material = null, vary := true) -> MeshInstance3D:
	return box(foot + Vector3(0, size.y * 0.5, 0), size, yaw, mat if mat else stone(foot.y), vary)


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
		box(Vector3(c.x, foot.y - 0.6 + h * 0.5, c.z), Vector3(width, h, run), yaw, stone(foot.y), false)


## A thick, blunt standing stone (the picture's): a base, three stacked blocks each a little narrower and turned, a low
## flat-topped cap set a little askew, and a dark pointed niche on the face that looks along `face`.
func obelisk(at: Vector3, height: float, width: float, face: Vector2) -> void:
	var yaw := atan2(face.x, face.y)
	var mat := stone(at.y).duplicate() as ShaderMaterial
	mat.set_shader_parameter(&"upright_cracks", OBELISK_CRACKS)
	block(at, Vector3(width * 1.3, 0.5, width * 1.3), yaw, mat)
	var y := 0.5
	var cap := width * 0.45
	var shaft := height - 0.5 - cap
	var layers := 3
	var w := width
	for i in layers:
		var h := shaft / layers
		block(at + Vector3(0, y, 0), Vector3(w, h - 0.06, w), yaw + [-0.04, 0.05, -0.02][i], mat)
		y += h
		w *= 0.91
	var c := point(at + Vector3(0, y, 0), w * 1.02, cap, yaw + 0.06, 0.55, mat)
	c.rotate_object_local(Vector3.RIGHT, 0.07)
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.02, 0.02, 0.03)
	dark.roughness = 1.0
	var f := Vector3(face.x, 0, face.y).normalized()
	pointed_arch(at + Vector3(0, height * 0.55, 0) + f * (width * 0.44), face, width * 0.45, height * 0.2, 0.08, 0.1, dark)
	box(at + Vector3(0, height * 0.55 + height * 0.08, 0) + f * (width * 0.43), Vector3(width * 0.4, height * 0.16, 0.06), yaw, dark)
	# the niche's stone frame standing a little out of the face, and its sill
	pointed_arch(at + Vector3(0, height * 0.55, 0) + f * (width * 0.47), face, width * 0.45 + OBELISK_FRAME * 2.0, height * 0.2 + OBELISK_FRAME,
		OBELISK_FRAME, 0.08, mat)
	box(at + Vector3(0, height * 0.55 - 0.04, 0) + f * (width * 0.48), Vector3(width * 0.6, 0.1, 0.14), yaw, mat)


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


## A curved arch ring in one mesh (cheap: the far arcades of the depths): from its left springing (t 0) over the apex
## (t 0.5) to its right springing (t 1), only the part from `from` to `to` (a broken arch keeps a stump). foot: the
## middle of the opening on the springing line; facing: the way it looks; span: the opening's width; ring: how wide
## the ring is; deep: its depth; radius: of its arcs as a share of the span (0.5 a round arch, more a pointed one).
func arch_ring(foot: Vector3, facing: Vector2, span: float, ring: float, deep: float, mat: Material, radius := 0.5,
		from := 0.0, to := 1.0) -> void:
	var r := span * maxf(radius, 0.5)
	var cx := r - span * 0.5
	var top := acos(clampf(cx / r, -1.0, 1.0))
	var n := maxi(2, ceili(ARCH_SEGMENTS * (to - from)))
	var inner: Array[Vector3] = []
	var outer: Array[Vector3] = []
	for i in n + 1:
		var t := lerpf(from, to, float(i) / n)
		# the left arc (centred right of the middle) up to the apex, then the right one down
		var a := top * (t * 2.0) if t <= 0.5 else top * ((1.0 - t) * 2.0)
		var side := -1.0 if t <= 0.5 else 1.0
		var dir := Vector3(side * cos(a), sin(a), 0.0)
		var centre := Vector3(-side * cx, 0.0, 0.0)
		inner.append(centre + dir * r)
		outer.append(centre + dir * (r + ring))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var f := Vector3(0, 0, deep * 0.5)
	for i in n:
		var mid := (inner[i] + inner[i + 1] + outer[i] + outer[i + 1]) * 0.25
		_face(st, inner[i] + f, inner[i + 1] + f, outer[i + 1] + f, outer[i] + f, Vector3.BACK)
		_face(st, inner[i] - f, inner[i + 1] - f, outer[i + 1] - f, outer[i] - f, Vector3.FORWARD)
		_face(st, outer[i] - f, outer[i + 1] - f, outer[i + 1] + f, outer[i] + f, (outer[i] + outer[i + 1]) * 0.5 - mid)
		_face(st, inner[i] - f, inner[i + 1] - f, inner[i + 1] + f, inner[i] + f, mid - (inner[i] + inner[i + 1]) * 0.5)
	for k: int in [0, n]:
		var along := (inner[k] - inner[1 if k == 0 else n - 1]).normalized()
		_face(st, inner[k] - f, outer[k] - f, outer[k] + f, inner[k] + f, along)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.transform = Transform3D(Basis(Vector3.UP, atan2(facing.x, facing.y)), foot)
	mi.material_override = mat
	_add(mi)


## A flat quad with a given outward direction (its winding turned to face it).
func _face(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, out: Vector3) -> void:
	for tri: Array in [[a, b, c], [a, c, d]]:
		var p: Vector3 = tri[0]
		var q: Vector3 = tri[1]
		var s: Vector3 = tri[2]
		var n := (s - p).cross(q - p)
		if n.length_squared() < 1e-10:
			continue
		if n.dot(out) < 0.0:
			var t := q
			q = s
			s = t
			n = -n
		st.set_normal(n.normalized())
		st.add_vertex(p)
		st.add_vertex(q)
		st.add_vertex(s)


## A pointed arch of separate voussoirs (the portal's orders): two arcs of radius `radius` times the span, their
## centres on the springing line, each stone a little sunk back at random, a keystone where they meet. foot: the middle
## of the opening on the ground; facing: the way it looks; span: the opening's width; spring: the springing line's
## height; ring: how wide the ring of stones is; deep: their depth. Returns the height of the ring's outer apex.
func voussoir_arch(foot: Vector3, facing: Vector2, span: float, spring: float, ring: float, deep: float, mat: Material = null,
		radius := 0.8) -> float:
	var basis := Basis(Vector3.UP, atan2(facing.x, facing.y))
	var m := mat if mat else stone(foot.y)
	var r := span * radius
	var cx := r - span * 0.5
	var sweep := PI - atan2(sqrt(r * r - cx * cx), -cx)
	var rm := r + ring * 0.5
	var n := maxi(3, roundi(rm * sweep / VOUSSOIR))
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector3i(foot * 10.0))
	for side: float in [-1.0, 1.0]:
		for i in n:
			var a := PI - sweep * (i + 0.5) / n
			var p := Vector3(side * -(cx + cos(a) * rm), spring + sin(a) * rm, -rng.randf() * VOUSSOIR_SINK)
			var mi := box(foot + basis * p, Vector3(ring, rm * sweep / n - VOUSSOIR_JOINT, deep), 0.0, m)
			mi.basis = basis * Basis(Vector3.BACK, a if side < 0.0 else PI - a)
	var apex := spring + sqrt((r + ring) * (r + ring) - cx * cx)
	box(foot + basis * Vector3(0, apex - ring * 0.55, 0.02), Vector3(ring * 0.7, ring * 1.1, deep), 0.0, m)
	return apex


## A gothic pinnacle on top of something: a square shaft `width` wide and as tall, a spire `height` tall with CROCKETS
## blocks up each of its edges, a finial on its tip.
func pinnacle(base: Vector3, width: float, height: float, mat: Material = null) -> void:
	var m := mat if mat else stone(base.y)
	block(base, Vector3(width, width, width), 0.0, m)
	block(base + Vector3(0, width, 0), Vector3(width * 1.12, 0.14, width * 1.12), 0.0, m)
	var foot := base + Vector3(0, width + 0.14, 0)
	point(foot, width * 0.95, height, 0.0, 0.0, m)
	for cx: float in [-1.0, 1.0]:
		for cz: float in [-1.0, 1.0]:
			for i in CROCKETS:
				var t := (i + 0.6) / (CROCKETS + 0.4)
				var half := width * 0.475 * (1.0 - t)
				box(foot + Vector3(cx * half, height * t, cz * half), Vector3.ONE * CROCKET * (1.0 - t * 0.4), PI * 0.25, m)
	box(foot + Vector3(0, height + FINIAL * 0.4, 0), Vector3(FINIAL, FINIAL, FINIAL), PI * 0.25, m)


## A round shaft of stone (a colonnette) standing at foot: radius, height.
func shaft(foot: Vector3, radius: float, height: float, mat: Material = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = radius
	c.bottom_radius = radius * 1.05
	c.height = height
	c.radial_segments = 10
	c.rings = 1
	mi.mesh = c
	mi.position = foot + Vector3(0, height * 0.5, 0)
	mi.material_override = mat if mat else stone(foot.y)
	_add(mi)
	return mi


## A jagged tooth of stone hanging from `top`: a tapering prism `length` long, `root` wide at the top, with two
## smaller teeth growing off its sides (the portal's pendants, dark against the light).
func pendant(top: Vector3, length: float, root: float, mat: Material) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector3i(top * 100.0))
	var lean := Basis(Vector3.BACK, r.randf_range(-0.12, 0.12))
	for i in (3 if length > PENDANT_SIDE_TEETH else 1):
		var l := length if i == 0 else length * r.randf_range(0.3, 0.45)
		var w := root if i == 0 else root * 0.45
		var side := 0.0 if i == 0 else (-1.0 if i == 1 else 1.0)
		var at := top + Vector3(side * root * 0.3, -(length * r.randf_range(0.15, 0.35) if i > 0 else 0.0), 0)
		var tilt := lean * Basis(Vector3.BACK, side * 0.35) * Basis(Vector3.UP, r.randf() * TAU)
		# each tooth in two pieces, the lower one set a little askew (a jagged break, not a clean cone)
		var kink := r.randf_range(0.45, 0.6)
		for part in 2:
			var mi := MeshInstance3D.new()
			var c := CylinderMesh.new()
			c.top_radius = w * 0.5 * (1.0 if part == 0 else 0.62)
			c.bottom_radius = w * 0.31 if part == 0 else 0.015
			c.height = l * (kink if part == 0 else 1.0 - kink)
			c.radial_segments = 5
			c.rings = 1
			mi.mesh = c
			var b := tilt if part == 0 else tilt * Basis(Vector3.BACK, r.randf_range(-0.25, 0.25))
			var start := at if part == 0 else at + tilt * Vector3(0, -l * kink, 0)
			mi.transform = Transform3D(b, start + b * Vector3(0, -c.height * 0.5, 0))
			mi.material_override = mat
			_add(mi)


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
		mat.albedo_color = tint / ROBE_VALUE
		var tex := NoiseTexture2D.new()
		var noise := FastNoiseLite.new()
		noise.frequency = 0.15
		noise.fractal_octaves = 3
		tex.noise = noise
		tex.seamless = true
		# weathered stone: the noise only from 0.65 to 1 (no black blotches)
		var ramp := Gradient.new()
		ramp.colors = PackedColorArray([Color.WHITE * 0.65, Color.WHITE])
		tex.color_ramp = ramp
		mat.albedo_texture = tex
		mat.uv1_triplanar = true
		mat.uv1_world_triplanar = true
		mat.uv1_scale = Vector3.ONE * 0.6
		mat.roughness = 0.95
		mat.rim_enabled = true
		mat.rim = 0.15
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
	var stone_v := Color.WHITE * ROBE_VALUE
	var robe: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(ROBE_HEM * 1.04, 0.0), Vector2(ROBE_HEM, 0.04),
		Vector2(ROBE_HEM * 0.93, 0.18), Vector2(ROBE_HEM * 0.82, 0.4), Vector2(ROBE_CHEST * 1.08, 0.56),
		Vector2(ROBE_CHEST, 0.7), Vector2(ROBE_CHEST * 0.85, ROBE_TOP), Vector2(0.06, ROBE_TOP + 0.02), Vector2(0.0, ROBE_TOP + 0.02)]
	_lathe(st, robe, Transform3D.IDENTITY, stone_v, PLEAT_DEPTH, 42)
	# the belt round the waist
	var belt_r := ROBE_CHEST * 1.12
	var belt: Array[Vector2] = [Vector2(0.0, BELT.x - BELT.y * 0.5), Vector2(belt_r, BELT.x - BELT.y * 0.5),
		Vector2(belt_r * 1.03, BELT.x), Vector2(belt_r, BELT.x + BELT.y * 0.5), Vector2(0.0, BELT.x + BELT.y * 0.5)]
	_lathe(st, belt, Transform3D.IDENTITY, stone_v * 0.8)
	# shoulders and the cape over them, a flattened ball
	_lathe(st, _ellipse(), Transform3D(Basis.from_scale(Vector3(0.15, 0.05, 0.1)), Vector3(0, 0.755, -0.01)), stone_v)
	# the hood, pulled forward, and its point falling behind
	_lathe(st, _ellipse(), Transform3D(Basis.from_scale(Vector3(0.068, 0.088, 0.08)), Vector3(0, HOOD_AT, HOOD_FORWARD)), stone_v)
	var tip: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.045, 0.0), Vector2(0.0, 0.11)]
	_lathe(st, tip, Transform3D(Basis(Vector3.RIGHT, -2.2), Vector3(0, HOOD_AT + 0.02, -0.02)), stone_v)
	# the face: a dark hollow in the hood's front, a pale mask deep in it
	_lathe(st, _ellipse(), Transform3D(Basis.from_scale(Vector3(0.042, 0.055, 0.02)), Vector3(0, HOOD_AT - 0.012, HOOD_FORWARD + 0.068)),
		stone_v * FACE_DARK)
	_lathe(st, _ellipse(), Transform3D(Basis.from_scale(MASK), Vector3(0, HOOD_AT - 0.016, HOOD_FORWARD + 0.082)), Color.WHITE)
	# the arms from the shoulders down to the hands joined on the chest, in wide sleeves that hide the hands
	for s in [-1.0, 1.0]:
		var from := Vector3(s * 0.12, 0.74, 0.02)
		var to := Vector3(s * 0.035, HANDS_AT, ROBE_CHEST + 0.02)
		var up := (to - from).normalized()
		var side := up.cross(Vector3.FORWARD).normalized()
		var basis := Basis(side * 0.042, up * from.distance_to(to), side.cross(up) * 0.042)
		var arm: Array[Vector2] = [Vector2(0.0, -0.05), Vector2(0.9, 0.0), Vector2(1.0, 0.5), Vector2(0.9, 1.0), Vector2(0.0, 1.05)]
		_lathe(st, arm, Transform3D(basis, from), stone_v)
		var mouth := SLEEVE / 0.042
		var sleeve: Array[Vector2] = [Vector2(0.0, 0.5), Vector2(1.0, 0.5), Vector2(mouth * 0.8, 0.9), Vector2(mouth, 1.08), Vector2(mouth * 0.7, 1.1), Vector2(0.0, 1.1)]
		_lathe(st, sleeve, Transform3D(basis, from), stone_v)
	_lathe(st, _ellipse(), Transform3D(Basis.from_scale(Vector3(0.05, 0.04, 0.035)), Vector3(0, HANDS_AT, ROBE_CHEST + 0.04)), stone_v * 0.7)
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
func _lathe(st: SurfaceTool, outline: Array[Vector2], xf: Transform3D, color: Color, pleat := 0.0, segs := 20) -> void:
	var rings: Array[PackedVector3Array] = []
	for p in outline:
		var ring := PackedVector3Array()
		for j in segs:
			var a := TAU * j / segs
			var r := p.x + pleat * sin(a * PLEATS) * (1.0 - smoothstep(PLEAT_TOP - 0.2, PLEAT_TOP, p.y)) * float(p.x > 0.0)
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
		_wax.emission_enabled = true
		_wax.emission = WAX_GLOW
		_wax_mesh = CylinderMesh.new()
		_wax_mesh.top_radius = 1.0
		_wax_mesh.bottom_radius = 1.0
		_wax_mesh.height = 1.0
		_wax_mesh.radial_segments = 8
		_wax_mesh.rings = 1
		_flame = ArenaKit.tongue(Vector2(CANDLE_FLAME * 0.6, CANDLE_FLAME * 1.3), CANDLE_FIRE)
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
	if mi is MeshInstance3D:
		_built.append(mi)


## Joins the stone built so far into one mesh per material, visual layer and MERGE_CELL square of floor (so each
## piece still only takes the lights near it, which the browser's renderer needs): a few hundred draw calls instead
## of over a thousand. Call once the room is built; nothing built before it may be moved afterwards.
func merge() -> void:
	var groups := {}
	for mi in _built:
		if not is_instance_valid(mi) or mi.material_override == null or mi.mesh == null or mi.mesh.get_surface_count() != 1:
			continue
		var cell := Vector2i(floori(mi.position.x / MERGE_CELL), floori(mi.position.z / MERGE_CELL))
		# meshes of one kind of vertex data per group (bevelled boxes, statues, primitives)
		var fmt := (mi.mesh as ArrayMesh).surface_get_format(0) if mi.mesh is ArrayMesh else -1
		var key := [mi.material_override, mi.layers, mi.cast_shadow, cell, fmt]
		if not groups.has(key):
			groups[key] = []
		groups[key].append(mi)
	for key: Array in groups:
		var list: Array = groups[key]
		if list.size() < 2:
			continue
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for mi: MeshInstance3D in list:
			st.append_from(mi.mesh, 0, mi.transform)
		var joined := MeshInstance3D.new()
		joined.mesh = st.commit()
		joined.material_override = key[0]
		joined.layers = key[1]
		joined.cast_shadow = key[2]
		root.add_child(joined)
		for mi: MeshInstance3D in list:
			root.remove_child(mi)
			mi.free()
	_built.clear()
