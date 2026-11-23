class_name Masonry
extends RefCounted
## Built stone for the catacomb hall, made of boxes in the dressed-stone material (masonry.gdshader), where the
## KayKit pieces are too small, too clean or missing: balustrades with chunky posts, stairs, obelisks, pointed
## arches, plinths, clay pots. Everything goes under `root`; nothing here blocks the way (CatacombHall records that).

const SHADER := preload("res://assets/shaders/masonry.gdshader")
## Its twin in the stylized look (STY-04; ArenaKit.paint_look puts it through VisualProfile).
const PAINT_SHADER := preload("res://assets/shaders/masonry_paint.gdshader")
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
## Hooded statue (shares of its height H; cycle 7: a brimmed hood over a sunken face, deeper pleats, shading by
## vertex value). The robe's radius at the hem and at the chest, its pleats (how many round it: half show from any
## side; how deep at the hem and at the waist, as shares of the height; the value left in the bottom of a fold).
const ROBE_HEM := 0.215
const ROBE_CHEST := 0.13
const ROBE_TOP := 0.78
const PLEATS := 12
const PLEAT_SEGMENTS := 4
const PLEAT_DEPTH := Vector2(0.036, 0.008)
const PLEAT_SHADE := 0.36
## Where the pleats fade out (share of the height: up to the chest), the belt (height, thickness), the sleeves' mouth
## (radius) over the hands, the two steps of the carved base (each as a share of the statue's height).
const PLEAT_TOP := 0.72
const BELT := Vector2(0.55, 0.03)
const SLEEVE := 0.085
const BASE_STEPS := Vector2(0.06, 0.04)
## The shoulders' half width and the arms' reach from the middle (shares of the height; cycle 6: 1.4 times broader).
const SHOULDERS := 0.2
const ARM_OUT := 0.165
## The hood: its middle (height, how far forward), its half size (across, front to back, up), how far it bows down
## (radians), and its outline turned round the way it looks (radius, then distance along that way, as shares of the
## half size; then the vertex value): the ball of the hood, the brim standing out round the opening, the opening's
## wall and the sunken face, darkest in its middle.
const HOOD_AT := 0.86
const HOOD_FORWARD := 0.03
const HOOD_SIZE := Vector3(0.082, 0.09, 0.1)
const HOOD_BOW := 0.3
const HOOD_OUTLINE: Array[Vector3] = [Vector3(0.0, -1.0, 0.85), Vector3(0.38, -0.92, 0.9), Vector3(0.71, -0.71, 0.95),
	Vector3(0.92, -0.38, 1.0), Vector3(1.0, 0.0, 1.0), Vector3(0.96, 0.3, 0.95), Vector3(0.9, 0.5, 0.8),
	Vector3(0.98, 0.58, 1.25), Vector3(1.0, 0.72, 1.35), Vector3(0.9, 0.82, 1.35), Vector3(0.76, 0.8, 1.1),
	Vector3(0.68, 0.66, 0.42), Vector3(0.6, 0.5, 0.26), Vector3(0.34, 0.4, 0.14), Vector3(0.0, 0.36, 0.08)]
const HANDS_AT := 0.6
## The statue's vertex value of plain stone (the mesh stores value times this, so the brim can be lighter than 1),
## and the robe's value by height (height, value): dark where it meets the plinth, under the arms and under the hood.
const ROBE_VALUE := 0.5
## The statue of the Salão, a Meshy model (2026-11-21): 6 thousand triangles, shared by every statue of a room.
const STATUE_MODEL := "res://assets/models/meshy/statue_hooded/statue_hooded.glb"
const ROBE_SHADE: Array[Vector2] = [Vector2(0.0, 0.55), Vector2(0.05, 0.72), Vector2(0.2, 1.0), Vector2(0.42, 1.0),
	Vector2(0.54, 0.72), Vector2(0.62, 0.8), Vector2(0.7, 1.0), Vector2(0.76, 0.75), Vector2(0.8, 0.6)]
## The statues' stone: Masonry's own, carved from one piece (no courses), a cold grey; each statue only changes its
## value. Its grime climbs this share of the statue's height from its feet.
const STATUE_STONE := Color(0.8, 0.88, 0.94)
const STATUE_GRIME := 0.16
## How much of the built stone's fine cracks and of its rock's hollows a statue keeps (smoother, carved stone).
const STATUE_CRACKS := 0.2
const STATUE_ROCK := 0.22
## How much lighter the faces turned up are (hood, shoulders, sleeves: the form reads from above, as the camera sees it).
const STATUE_TOP_LIGHT := 1.45
## Pots: the belly's radius (share of the pot's height). Candles: the wax, the flame's size and colour.
const POT_BELLY := 0.38
## Standing stones: the share of their columns cracked upright, the frame round their niche.
const OBELISK_CRACKS := 0.3
const OBELISK_FRAME := 0.08
## The niche's darkness (cycle 9: the niche is dressed stone too, so it opens round the paladin with the rest).
const OBELISK_NICHE := Color(0.025, 0.025, 0.035)
const WAX := Color(1.0, 0.8, 0.55)
## The wax lit from inside by its flame, so its shaded side stays amber under the cold teal air (not olive): strongest
## at the top, this share of it at the foot. The pool of wax run down round the foot (times the candle's radius).
const WAX_GLOW := Color(0.36, 0.14, 0.04)
const WAX_GLOW_FOOT := 0.55
const WAX_POOL := 1.8
## A burnt-out candle's wax (a share of WAX) and its wick.
const WAX_OUT := 0.4
const WICK := Color(0.05, 0.045, 0.04)
## A candle's flame: its size (m), the orange tongue, the near-white core inside it and the core's share of the size.
const CANDLE_FLAME := 0.34
## Urns (urn): the belly's radius as a share of the height, at most URN_RADIUS m (they stand on 0.3 m ledges); the
## carved stone's grime height for small pieces.
const URN_BELLY := 0.26
const URN_RADIUS := 0.14
const CARVED_GRIME := 0.3
const CANDLE_FIRE := Color(2.3, 1.1, 0.35)
const CANDLE_CORE := Color(2.6, 2.0, 1.1)
const CANDLE_CORE_SIZE := 0.55
## The stylized look (STY-04, stylized_spec 1.3 T6): the wax darker (it burnt white under the warm air)
## and the flame amber, never white (its core under the glow threshold: luma up to 200 on the screen).
## STY-10 (art review: smooth cream cylinders read as toys): an old wax, darker and greyer (saturation 0.3, was 0.45),
## with no rim of light down its sides.
const STY_WAX := Color(0.52, 0.45, 0.36)
const STY_WAX_RIM := 0.0
const STY_CANDLE_FIRE := Color(1.3, 0.6, 0.16)
const STY_CANDLE_CORE := Color(1.1, 0.72, 0.28)
## STY-09 (art-director): the clay of the pots in the stylized look, an umber terracotta (CLAY read on the screen at
## saturation 0.69 and luma 120 under the stylized key, the brightest colour of the hall after the fires).
const STY_CLAY := Color(0.3, 0.21, 0.16)
## Terracotta, dark in the shade (cycle 6: the pots were too orange).
const CLAY := Color(0.45, 0.18, 0.1)
const CLAY_RIM := 0.08
## Crates (dark wood with darker corner posts and bands, in place of the kit's pale-framed box): the planks' two
## values, the posts' and bands' colour, the width of a plank (m), the posts' width and the bands' height (shares of
## the crate's size), how far they stand out (m).
const WOOD_A := Color(0.19, 0.125, 0.09)
const WOOD_B := Color(0.26, 0.175, 0.125)
const WOOD_JOINT := Color(0.045, 0.03, 0.025)
const WOOD_FRAME := 0.5
const PLANK := 0.24
const CRATE_POST := 0.14
const CRATE_BAND := 0.12
const CRATE_PROUD := 0.035
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
## How much of the mist the stone of the depths takes far away (depth_stone).
const DEPTH_FADE := 0.8

var root: Node3D
## Visual layers given to what is built next (the depths take ArenaKit.DEPTH_LAYER too, for their own lights).
var layers := 1
var _mats := {}
var _clay: StandardMaterial3D
var _depths := {}
var _mouth: StandardMaterial3D
var _wax: StandardMaterial3D
var _wax_out: StandardMaterial3D
var _wick: StandardMaterial3D
var _wax_mesh: CylinderMesh
var _flame: QuadMesh
var _flame_core: QuadMesh
var _wood := {}
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


## The unlit stone of the far depths (depth_stone.gdshader): dark shapes fading into a mist of colour `mist`. fade:
## how much of the mist the far ones take (the near masses less: they stand dark against it); tint: of the stone.
func depth_stone(mist: Color, fade := DEPTH_FADE, tint := 1.0) -> ShaderMaterial:
	var key := "%.2f|%.2f" % [fade, tint]
	if not _depths.has(key):
		var d := ShaderMaterial.new()
		d.shader = DEPTH_SHADER
		d.set_shader_parameter(&"mist_color", mist)
		d.set_shader_parameter(&"fade_max", fade)
		d.set_shader_parameter(&"tint", tint)
		_depths[key] = d
	return _depths[key]


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
	return Masonry.kept(st)


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
## on top, a curb at the foot and bellied square balusters between each pair of posts. mat: its stone (none: stone()).
func balustrade(a: Vector3, b: Vector3, end_posts := true, mat: Material = null) -> void:
	var length := Vector2(b.x - a.x, b.z - a.z).length()
	if length < 0.3:
		return
	var yaw := atan2(b.x - a.x, b.z - a.z) + PI * 0.5
	var spans := maxi(1, roundi(length / POST_GAP))
	if mat == null:
		mat = stone(a.y)
	for i in spans + 1:
		if not end_posts and (i == 0 or i == spans):
			continue
		var p := a.lerp(b, float(i) / spans)
		post(p, yaw, POST.y, mat)
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


## One balustrade post: plinth, shaft, a step under a wide cap. mat: its stone (none: stone()).
func post(at: Vector3, yaw: float = 0.0, height: float = POST.y, mat: Material = null) -> void:
	if mat == null:
		mat = stone(at.y)
	box(at + Vector3(0, CURB * 0.5, 0), Vector3(POST.x + 0.12, CURB, POST.z + 0.12), yaw, mat)
	box(at + Vector3(0, height * 0.5, 0), Vector3(POST.x, height, POST.z), yaw, mat)
	box(at + Vector3(0, height + POST_STEP.y * 0.5, 0), Vector3(POST_STEP.x, POST_STEP.y, POST_STEP.x), yaw, mat)
	box(at + Vector3(0, height + POST_STEP.y + POST_CAP.y * 0.5, 0), Vector3(POST_CAP.x, POST_CAP.y, POST_CAP.x), yaw, mat)


## An upright prism of stone: its footprint (a simple polygon on the floor, x and z, either winding) from height y0 up
## to y1, with flat normals (the curved bottom step of a stair, a plinth along an arc). Concave footprints are cut into
## triangles for the caps; the sides follow the outline.
func prism(points: PackedVector2Array, y0: float, y1: float, mat: Material = null) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tris := Geometry2D.triangulate_polygon(points)
	for i in range(0, tris.size(), 3):
		for cap: float in [y0, y1]:
			var tri: Array[Vector3] = []
			for k in 3:
				var p := points[tris[i + k]]
				tri.append(Vector3(p.x, cap, p.y))
			_face(st, tri[0], tri[1], tri[2], tri[2], Vector3.UP if cap == y1 else Vector3.DOWN)
	for i in points.size():
		var a := points[i]
		var b := points[(i + 1) % points.size()]
		var along := (b - a).normalized()
		var out := Vector2(along.y, -along.x)
		if Geometry2D.is_point_in_polygon((a + b) * 0.5 + out * 0.01, points):
			out = -out
		_face(st, Vector3(a.x, y0, a.y), Vector3(b.x, y0, b.y), Vector3(b.x, y1, b.y), Vector3(a.x, y1, a.y), Vector3(out.x, 0.0, out.y))
	var mi := MeshInstance3D.new()
	mi.mesh = Masonry.kept(st)
	mi.material_override = mat if mat else stone(y0)
	_add(mi)
	return mi


## A flight of stairs. foot: the middle of the lowest step's front edge; up: the way up the flight (on the floor);
## width, number of steps, rise and run of each; mat: their stone (default the plain stone at their foot).
func stairs(foot: Vector3, up: Vector2, width: float, steps: int, rise: float, run: float, mat: Material = null) -> void:
	var dir := Vector3(up.x, 0, up.y).normalized()
	var yaw := atan2(dir.x, dir.z)
	for i in steps:
		# each step a block from a little under the flight's foot up to its top, so the flight is solid
		var h := rise * (i + 1) + 0.6
		var c := foot + dir * (run * (i + 0.5))
		box(Vector3(c.x, foot.y - 0.6 + h * 0.5, c.z), Vector3(width, h, run), yaw, mat if mat else stone(foot.y), false)


## A thick, blunt standing stone (the picture's): a base, three stacked blocks each a little narrower and turned, a low
## flat-topped cap set a little askew, and a dark pointed niche on the face that looks along `face`.
func obelisk(at: Vector3, height: float, width: float, face: Vector2) -> void:
	var yaw := atan2(face.x, face.y)
	var mat := stone(at.y).duplicate() as ShaderMaterial
	mat.set_shader_parameter(&"upright_cracks", OBELISK_CRACKS)
	# the paladin behind it reads through a stippled hole round him (masonry.gdshader, see_through)
	mat.set_shader_parameter(&"see_through", 1.0)
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
	var dark := mat.duplicate() as ShaderMaterial
	dark.set_shader_parameter(&"stone_a", OBELISK_NICHE)
	dark.set_shader_parameter(&"stone_b", OBELISK_NICHE)
	dark.set_shader_parameter(&"top_light", 1.0)
	dark.set_shader_parameter(&"upright_cracks", 0.0)
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
	mi.mesh = Masonry.kept(st)
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


## A broken arch (room redesign lot B: the sanctuary's torn vault, the rift's fallen bridge and the arches at its
## mouth): voussoir_arch with the stones whose middle lies in `gap` (from, to: meters across the opening from its
## middle, along the facing's right) gone, and the keystone with them when the gap holds the middle. Returns the
## stones left (the broken ends' last stones are the first and last of each side's run).
func broken_arch(foot: Vector3, facing: Vector2, span: float, spring: float, ring: float, deep: float, mat: Material,
		gap: Vector2, radius := 0.8) -> Array[MeshInstance3D]:
	var from_built := _built.size()
	voussoir_arch(foot, facing, span, spring, ring, deep, mat, radius)
	var to_local := Basis(Vector3.UP, atan2(facing.x, facing.y)).inverse()
	var kept: Array[MeshInstance3D] = []
	for i in range(from_built, _built.size()):
		var mi := _built[i]
		var x := (to_local * (mi.position - foot)).x
		if x > gap.x and x < gap.y:
			root.remove_child(mi)
			mi.free()
		else:
			kept.append(mi)
	_built.resize(from_built)
	_built.append_array(kept)
	return kept


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


## A fluted drum of a column standing at foot (Sworn F-1): `radius` to the flutes' arrises, `height`, `flutes` shallow
## concave grooves `depth` m deep round it (FLUTE_SIDES sides each), flat ends. Shared by snapped size.
func fluted(foot: Vector3, radius: float, height: float, flutes: int, depth: float, mat: Material = null) -> MeshInstance3D:
	var key := "fluted|%.2f|%.2f|%d|%.3f" % [radius, height, flutes, depth]
	if not _fluted.has(key):
		_fluted[key] = fluted_mesh(snappedf(radius, 0.01), snappedf(height, 0.01), flutes, depth)
	var mi := MeshInstance3D.new()
	mi.mesh = _fluted[key]
	mi.position = foot + Vector3(0, height * 0.5, 0)
	mi.material_override = mat if mat else stone(foot.y)
	_add(mi)
	return mi


const FLUTE_SIDES := 4
var _fluted := {}


## The fluted drum's mesh, centred, along Y (fluted), flat facets so the flutes catch the light.
func fluted_mesh(radius: float, height: float, flutes: int, depth: float) -> ArrayMesh:
	var n := flutes * FLUTE_SIDES
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var ring: Array[Vector2] = []
	for i in n:
		var a := TAU * i / n
		# each flute a shallow scoop between two sharp arrises
		var s := sin(PI * float(i % FLUTE_SIDES) / FLUTE_SIDES)
		ring.append(Vector2(cos(a), sin(a)) * (radius - depth * s))
	var h := height * 0.5
	for i in n:
		var p: Vector2 = ring[i]
		var q: Vector2 = ring[(i + 1) % n]
		var a0 := Vector3(p.x, -h, p.y)
		var a1 := Vector3(q.x, -h, q.y)
		var b0 := Vector3(p.x, h, p.y)
		var b1 := Vector3(q.x, h, q.y)
		_quad(st, a0, a1, b1, b0)
		_tri(st, Vector3(0, h, 0), b0, b1)
		_tri(st, Vector3(0, -h, 0), a1, a0)
	return Masonry.kept(st)


## SW-K1: an empty iron cage (a gibbet) hanging from its hook at the origin, one mesh: a dome of four straps from the
## hook to the top ring, `bars` upright bars down to the bottom ring, a band round its middle and two straps across its
## floor. size: radius, height of the bars, height of the dome, the bars' width (m). door: degrees its door (the two
## bars after bar 0, with their own rails) stands open on its hinge at bar 0 (0 shut); bent: the bar bowed out (-1 none).
static func cage_mesh(size: Vector4, bars: int, door := 0.0, bent := -1) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var r := size.x
	var top := -size.z
	var low := top - size.y
	var band := top - size.y * CAGE_BAND
	var w := size.w
	var ring := func(i: int, y: float) -> Vector3: return Vector3(r * sin(TAU * i / bars), y, r * cos(TAU * i / bars))
	# the dome, the floor
	for k in 4:
		var a := TAU * k / 4.0
		var out := Vector3(sin(a), 0, cos(a))
		for s in CAGE_DOME_STEPS:
			var t0 := PI * 0.5 * s / CAGE_DOME_STEPS
			var t1 := PI * 0.5 * (s + 1) / CAGE_DOME_STEPS
			_bar(st, out * r * sin(t0) + Vector3.UP * -size.z * (1.0 - cos(t0)), out * r * sin(t1) + Vector3.UP * -size.z * (1.0 - cos(t1)), w)
		if k < 2:
			_bar(st, Vector3(0, low, 0) + out * r, Vector3(0, low, 0) - out * r, w)
	var shut := door <= 0.0
	for i in bars:
		var j := (i + 1) % bars
		_bar(st, ring.call(i, top), ring.call(j, top), w * CAGE_RING)
		_bar(st, ring.call(i, low), ring.call(j, low), w * CAGE_RING)
		if shut or i >= CAGE_DOOR_BARS:
			_bar(st, ring.call(i, band), ring.call(j, band), w)
		if not shut and i >= 1 and i <= CAGE_DOOR_BARS:
			continue
		if i == bent:
			var mid: Vector3 = ring.call(i, lerpf(top, low, 0.55))
			var bow := Vector3(mid.x, 0, mid.z).normalized() * CAGE_BOW
			_bar(st, ring.call(i, top), mid + bow, w)
			_bar(st, mid + bow, ring.call(i, low), w)
		else:
			_bar(st, ring.call(i, top), ring.call(i, low), w)
	if not shut:
		# the door: its bars and rails, turned out round the hinge (bar 0)
		var hinge: Vector3 = ring.call(0, 0.0)
		var turn := Basis(Vector3.UP, deg_to_rad(door))
		var swing := func(p: Vector3) -> Vector3: return hinge + turn * (p - hinge)
		for i in range(1, CAGE_DOOR_BARS + 1):
			_bar(st, swing.call(ring.call(i, top - w)), swing.call(ring.call(i, low + w)), w)
		for y: float in [top - w, band, low + w]:
			_bar(st, swing.call(ring.call(0, y)), swing.call(ring.call(CAGE_DOOR_BARS, y)), w)
	return Masonry.kept(st)


## The cage's band (share of the bars' height down), its dome's steps, how much thinner its rings are than its bars,
## how many bars its door takes and how far its bent bar bows out (m).
const CAGE_BAND := 0.45
const CAGE_DOME_STEPS := 4
const CAGE_RING := 1.3
const CAGE_DOOR_BARS := 2
const CAGE_BOW := 0.2


## A square iron bar from a to b, w wide: its four sides with flat normals (its ends open: too small to see).
static func _bar(st: SurfaceTool, a: Vector3, b: Vector3, w: float) -> void:
	var along := (b - a).normalized()
	var u := along.cross(Vector3.UP if absf(along.y) < 0.9 else Vector3.RIGHT).normalized() * w * 0.5
	var v := along.cross(u).normalized() * w * 0.5
	var c: Array[Vector3] = [u + v, -u + v, -u - v, u - v]
	for k in 4:
		var p := c[k]
		var q := c[(k + 1) % 4]
		var n := (p + q).normalized()
		st.set_normal(n)
		st.add_vertex(a + p)
		st.add_vertex(b + p)
		st.add_vertex(b + q)
		st.add_vertex(a + p)
		st.add_vertex(b + q)
		st.add_vertex(a + q)


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
## shoulders, hands joined on the chest in wide sleeves, a brimmed hood over a face in shadow. foot: the middle of its
## base; it looks along +Z turned by yaw; height in meters; value: how light its stone is (STATUE_STONE times it).
func hooded_statue(foot: Vector3, yaw: float, height: float, value: float) -> MeshInstance3D:
	if _statue_mesh == null:
		_statue_mesh = _build_statue()
	var mi := MeshInstance3D.new()
	mi.mesh = _statue_mesh
	mi.material_override = _carved(foot.y, STATUE_STONE * value, height * STATUE_GRIME)
	mi.transform = Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * height), foot)
	_add(mi)
	return mi


## Carved stone (the statues', the urns', the effigies'): one piece, no courses, no blocks, no chipped corners, shaded
## by the mesh's vertex value (_lathe's colours); its grime up to grime_height over base_y.
func _carved(base_y: float, tint: Color, grime_height: float) -> ShaderMaterial:
	var key := "%.2f|%s|%.2f" % [base_y, tint.to_html(), grime_height]
	if not _statue_mats.has(key):
		var mat := stone(base_y, tint).duplicate() as ShaderMaterial
		mat.set_shader_parameter(&"course", 10000.0)
		mat.set_shader_parameter(&"block_len", 10000.0)
		mat.set_shader_parameter(&"block_var", 0.0)
		mat.set_shader_parameter(&"joint_width", 0.001)
		mat.set_shader_parameter(&"chipped", 0.0)
		mat.set_shader_parameter(&"side_light", 1.0)
		mat.set_shader_parameter(&"cracks", STATUE_CRACKS)
		mat.set_shader_parameter(&"top_light", STATUE_TOP_LIGHT)
		mat.set_shader_parameter(&"rock_value", STATUE_ROCK)
		mat.set_shader_parameter(&"grime_height", grime_height)
		mat.set_shader_parameter(&"vertex_shade", 1.0 / ROBE_VALUE)
		_statue_mats[key] = mat
	return _statue_mats[key]


## Carved stone for small pieces (urns, effigies; room redesign lot A 1.6), of the room's stone times tint.
func carved(base_y: float, tint := Color.WHITE) -> ShaderMaterial:
	return _carved(base_y, STATUE_STONE * tint, CARVED_GRIME)


## An urn (room redesign lot A 1.6): a turned body, a narrow mouth, a lid; `height` 0.2 to 0.55 m, the belly's radius
## URN_BELLY of it (at most URN_RADIUS), standing at `at` (the middle of its foot). mat: carved stone (carved) or metal.
func urn(at: Vector3, height: float, mat: Material, lid := true) -> void:
	var r := minf(height * URN_BELLY, URN_RADIUS) / height
	var outline: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(r * 0.62, 0.0), Vector2(r * 0.55, 0.06), Vector2(r * 0.86, 0.22),
		Vector2(r, 0.45), Vector2(r * 0.9, 0.66), Vector2(r * 0.5, 0.8), Vector2(r * 0.42, 0.86), Vector2(r * 0.55, 0.9)]
	var shade := PackedFloat32Array([0.6, 0.6, 0.7, 0.9, 1.05, 1.1, 0.9, 0.8, 1.0])
	if lid:
		outline.append_array([Vector2(r * 0.55, 0.93), Vector2(r * 0.3, 0.97), Vector2(r * 0.12, 1.0), Vector2(0.0, 1.02)])
		shade.append_array([1.05, 1.1, 1.1, 1.1])
	else:
		outline.append_array([Vector2(r * 0.38, 0.9), Vector2(0.0, 0.84)])
		shade.append_array([0.4, 0.2])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_lathe(st, outline, Transform3D(Basis.from_scale(Vector3.ONE * height), Vector3.ZERO), shade)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = Masonry.kept(st)
	mi.material_override = mat
	mi.position = at
	_add(mi)


## A cluster of pale fungus (room redesign lot C 1: on lids, column feet, sills; never on the open floor): `count`
## flat six-sided caps on short stems round `at` (its middle, on the surface they grow on), within `reach` m, each cap
## FUNGUS_CAP (smallest, largest) m across, leaning out; one mesh (fungus.gdshader: the rim's own faint glow).
const FUNGUS_CAP := Vector2(0.06, 0.14)
const FUNGUS_SHADER := preload("res://assets/shaders/fungus.gdshader")
var _fungus: ShaderMaterial


func fungus(at: Vector3, count: int, reach: float, seed_: int) -> MeshInstance3D:
	var r := RandomNumberGenerator.new()
	r.seed = seed_
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for k in count:
		var a := r.randf() * TAU
		var d := reach * sqrt(r.randf())
		var rad := r.randf_range(FUNGUS_CAP.x, FUNGUS_CAP.y) * 0.5
		var stem := rad * r.randf_range(0.6, 1.3)
		var foot := Vector3(cos(a) * d, 0.0, sin(a) * d)
		var lean := Basis(Vector3(-sin(a), 0, cos(a)), r.randf_range(0.0, 0.35))
		var top := foot + lean * Vector3(0, stem, 0)
		# the stem: a thin square post
		var s := rad * 0.25
		var base: Array[Vector3] = [Vector3(-s, 0, -s), Vector3(s, 0, -s), Vector3(s, 0, s), Vector3(-s, 0, s)]
		for i in 4:
			var p0 := foot + base[i]
			var p1 := foot + base[(i + 1) % 4]
			var q0 := top + base[i]
			var q1 := top + base[(i + 1) % 4]
			_fungus_quad(st, p0, p1, q1, q0, Color(0, 1, 0))
		# the cap: a flat hexagonal prism, its rim (the sides and the top's outer ring) lit by its own glow
		var thick := rad * 0.35
		var ring: Array[Vector3] = []
		for i in 6:
			var b := TAU * i / 6.0 + r.randf() * 0.3
			ring.append(lean * Vector3(cos(b) * rad, 0, sin(b) * rad))
		var under_y := top
		var over := top + lean * Vector3(0, thick, 0)
		var crown := over + lean * Vector3(0, thick * 0.6, 0)
		for i in 6:
			var a0 := ring[i]
			var a1 := ring[(i + 1) % 6]
			_fungus_quad(st, under_y + a0, under_y + a1, over + a1, over + a0, Color(1, 0, 0))
			_fungus_tri(st, over + a0, over + a1, crown, [Color(1, 0, 0), Color(1, 0, 0), Color(0, 0, 0)])
			_fungus_tri(st, under_y + a1, under_y + a0, top, [Color(0, 1, 0), Color(0, 1, 0), Color(0, 1, 0)])
	var mi := MeshInstance3D.new()
	mi.mesh = Masonry.kept(st)
	if _fungus == null:
		_fungus = ShaderMaterial.new()
		_fungus.shader = FUNGUS_SHADER
	mi.material_override = _fungus
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = at
	_add(mi)
	return mi


## Art pack 2026-11-23 (the garden): a patch of small wild flowers (never on the open floor's middle; the caller places
## it at a wall's foot or a bank): `count` thin stems each with a flat six-petal head BLOSSOM_HEAD (smallest, largest) m
## across, within `reach` m of `at`, the heads cream and soft yellow (never red or violet: those colours are warnings
## and Morvath's). One mesh with vertex colours, no collision, no shadow.
const BLOSSOM_HEAD := Vector2(0.09, 0.15)
const BLOSSOM_STEM := Vector2(0.08, 0.18)
const BLOSSOM_COLORS: Array[Color] = [Color(0.94, 0.92, 0.80), Color(0.94, 0.92, 0.80), Color(0.92, 0.80, 0.38)]
const BLOSSOM_STEM_COLOR := Color(0.18, 0.26, 0.14)
const BLOSSOM_PETALS := 6
var _blossom: StandardMaterial3D


func blossoms(at: Vector3, count: int, reach: float, seed_: int) -> MeshInstance3D:
	var r := RandomNumberGenerator.new()
	r.seed = seed_
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for k in count:
		var a := r.randf() * TAU
		var d := reach * sqrt(r.randf())
		var foot := Vector3(cos(a) * d, 0.0, sin(a) * d)
		var top := foot + Vector3(r.randf_range(-0.03, 0.03), r.randf_range(BLOSSOM_STEM.x, BLOSSOM_STEM.y), r.randf_range(-0.03, 0.03))
		var w := 0.008
		_fungus_quad(st, foot + Vector3(-w, 0, 0), foot + Vector3(w, 0, 0), top + Vector3(w, 0, 0), top + Vector3(-w, 0, 0), BLOSSOM_STEM_COLOR)
		var rad := r.randf_range(BLOSSOM_HEAD.x, BLOSSOM_HEAD.y) * 0.5
		var col := BLOSSOM_COLORS[r.randi() % BLOSSOM_COLORS.size()]
		var spin := r.randf() * TAU
		for i in BLOSSOM_PETALS:
			var b0 := spin + TAU * i / BLOSSOM_PETALS
			var b1 := spin + TAU * (i + 1) / BLOSSOM_PETALS
			var bm := (b0 + b1) * 0.5
			_fungus_quad(st, top, top + Vector3(cos(b0), 0.1, sin(b0)) * rad * 0.5, top + Vector3(cos(bm), 0.2, sin(bm)) * rad,
				top + Vector3(cos(b1), 0.1, sin(b1)) * rad * 0.5, col)
	var mi := MeshInstance3D.new()
	mi.mesh = Masonry.kept(st)
	if _blossom == null:
		_blossom = StandardMaterial3D.new()
		_blossom.vertex_color_use_as_albedo = true
		_blossom.roughness = 0.9
		_blossom.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = _blossom
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = at
	_add(mi)
	return mi


func _fungus_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, col: Color) -> void:
	_fungus_tri(st, a, b, c, [col, col, col])
	_fungus_tri(st, a, c, d, [col, col, col])


func _fungus_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, cols: Array) -> void:
	# both faces (a cap seen from under and over)
	for tri: Array in [[a, b, c, 0, 1, 2], [a, c, b, 0, 2, 1]]:
		var p0: Vector3 = tri[0]
		var n: Vector3 = ((tri[1] as Vector3) - p0).cross(tri[2] - p0).normalized()
		for k in 3:
			st.set_normal(n)
			st.set_color(cols[tri[3 + k]])
			st.add_vertex(tri[k])


## The statue of height 1, looking along +Z: lathed robe with deep pleats, belt, shoulders, the hood with its brim
## and sunken face and its point behind, arms in wide sleeves, hands. Vertex colour: the stone's value there
## (ROBE_VALUE = plain stone), which the material multiplies in: the folds, the foot, under the arms and the face.
func _build_statue() -> ArrayMesh:
	# 2026-11-21: the Meshy statue (statue_hooded, Daniel's pick); the lathed monk below stays as the fallback
	var model := meshy_stone(STATUE_MODEL, true)
	return model if model != null else _build_lathed_statue()


## A Meshy model as carved stone of height 1 standing on its foot (the middle of its base at the origin, looking along
## the model's +Z): its geometry only (the material, _carved, is the stone), the vertex value ROBE_VALUE, from ROBE_SHADE
## over its height when `robe` (the lathed monk's folds). null without the model.
func meshy_stone(path: String, robe := false) -> ArrayMesh:
	var scene := load(path) as PackedScene
	if scene == null:
		return null
	var root := scene.instantiate()
	var found := root.find_children("*", "MeshInstance3D", true, false)
	if found.is_empty():
		root.free()
		return null
	var src := (found[0] as MeshInstance3D).mesh
	var box := src.get_aabb()
	var arrays := src.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var index: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	root.free()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var scale := 1.0 / box.size.y
	var mid := box.get_center()
	for i in index:
		var v := verts[i]
		var p := Vector3((v.x - mid.x) * scale, (v.y - box.position.y) * scale, (v.z - mid.z) * scale)
		st.set_normal(normals[i])
		st.set_color(Color.WHITE * minf((_shade_at(p.y) if robe else 1.0) * ROBE_VALUE, 1.0))
		st.add_vertex(p)
	st.index()
	return Masonry.kept(st)


func _build_lathed_statue() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var robe: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(ROBE_HEM * 1.04, 0.0), Vector2(ROBE_HEM, 0.04),
		Vector2(ROBE_HEM * 0.93, 0.18), Vector2(ROBE_HEM * 0.86, 0.3), Vector2(ROBE_HEM * 0.78, 0.42), Vector2(ROBE_CHEST * 1.08, 0.56),
		Vector2(ROBE_CHEST, 0.7), Vector2(ROBE_CHEST * 0.85, ROBE_TOP), Vector2(0.06, ROBE_TOP + 0.02), Vector2(0.0, ROBE_TOP + 0.02)]
	var robe_shade := PackedFloat32Array()
	for p in robe:
		robe_shade.append(_shade_at(p.y))
	_lathe(st, robe, Transform3D.IDENTITY, robe_shade, true)
	# the belt round the waist
	var belt_r := ROBE_CHEST * 1.12
	var belt: Array[Vector2] = [Vector2(0.0, BELT.x - BELT.y * 0.5), Vector2(belt_r, BELT.x - BELT.y * 0.5),
		Vector2(belt_r * 1.03, BELT.x), Vector2(belt_r, BELT.x + BELT.y * 0.5), Vector2(0.0, BELT.x + BELT.y * 0.5)]
	_lathe(st, belt, Transform3D.IDENTITY, _flat(belt.size(), 0.8))
	# shoulders and the cape over them, a flattened ball (darker underneath)
	var ball := _ellipse()
	var under := PackedFloat32Array()
	for p in ball:
		under.append(lerpf(0.65, 1.05, smoothstep(-0.6, 0.5, p.y)))
	_lathe(st, ball, Transform3D(Basis.from_scale(Vector3(SHOULDERS, 0.055, 0.11)), Vector3(0, 0.755, -0.01)), under)
	# the hood, turned round the way it looks and bowed: its ball, the brim round the opening, the sunken face
	var hood: Array[Vector2] = []
	var hood_shade := PackedFloat32Array()
	for p in HOOD_OUTLINE:
		hood.append(Vector2(p.x, p.y))
		hood_shade.append(p.z)
	var look := Basis(Vector3.RIGHT, PI * 0.5 + HOOD_BOW) * Basis.from_scale(Vector3(HOOD_SIZE.x, HOOD_SIZE.y, HOOD_SIZE.z))
	_lathe(st, hood, Transform3D(look, Vector3(0, HOOD_AT, HOOD_FORWARD)), hood_shade)
	# its point falling behind
	var tip: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.05, 0.0), Vector2(0.03, 0.07), Vector2(0.0, 0.14)]
	_lathe(st, tip, Transform3D(Basis(Vector3.RIGHT, -2.1), Vector3(0, HOOD_AT + 0.035, -0.035)), PackedFloat32Array([0.9, 0.9, 1.0, 1.05]))
	# the arms from the shoulders down to the hands joined on the chest, in wide sleeves that hide the hands
	for s in [-1.0, 1.0]:
		var from := Vector3(s * ARM_OUT, 0.74, 0.02)
		var to := Vector3(s * 0.035, HANDS_AT, ROBE_CHEST + 0.02)
		var up := (to - from).normalized()
		var side := up.cross(Vector3.FORWARD).normalized()
		var basis := Basis(side * 0.046, up * from.distance_to(to), side.cross(up) * 0.046)
		var arm: Array[Vector2] = [Vector2(0.0, -0.05), Vector2(0.9, 0.0), Vector2(1.0, 0.5), Vector2(0.9, 1.0), Vector2(0.0, 1.05)]
		_lathe(st, arm, Transform3D(basis, from), _flat(arm.size(), 0.95))
		var mouth := SLEEVE / 0.046
		var sleeve: Array[Vector2] = [Vector2(0.0, 0.4), Vector2(1.05, 0.4), Vector2(mouth * 0.75, 0.75), Vector2(mouth, 1.06),
			Vector2(mouth * 0.92, 1.1), Vector2(mouth * 0.6, 1.02), Vector2(0.0, 0.98)]
		_lathe(st, sleeve, Transform3D(basis, from), PackedFloat32Array([0.9, 0.9, 1.0, 1.15, 1.1, 0.4, 0.25]))
	_lathe(st, _ellipse(), Transform3D(Basis.from_scale(Vector3(0.05, 0.04, 0.035)), Vector3(0, HANDS_AT, ROBE_CHEST + 0.04)), _flat(9, 0.7))
	st.generate_normals()
	return Masonry.kept(st)


## The robe's value at a height (ROBE_SHADE).
func _shade_at(y: float) -> float:
	for i in range(1, ROBE_SHADE.size()):
		if y <= ROBE_SHADE[i].x:
			return remap(y, ROBE_SHADE[i - 1].x, ROBE_SHADE[i].x, ROBE_SHADE[i - 1].y, ROBE_SHADE[i].y)
	return ROBE_SHADE[ROBE_SHADE.size() - 1].y


func _flat(count: int, value: float) -> PackedFloat32Array:
	var f := PackedFloat32Array()
	f.resize(count)
	f.fill(value)
	return f


## The half outline of a ball of radius 1 (bottom to top), to lathe.
func _ellipse() -> Array[Vector2]:
	var e: Array[Vector2] = []
	for i in 9:
		var a := PI * i / 8.0
		e.append(Vector2(sin(a), -cos(a)))
	return e


## Turns an outline (radius, height) around Y into a closed surface, placed by xf. shade: the value of each point of
## the outline (1 = plain stone). pleated: upright folds round it (PLEATS: round ridges, sharp dark valleys), deepest
## at the hem and gone by PLEAT_TOP.
func _lathe(st: SurfaceTool, outline: Array[Vector2], xf: Transform3D, shade: PackedFloat32Array, pleated := false) -> void:
	var segs := PLEATS * PLEAT_SEGMENTS if pleated else 20
	var rings: Array[PackedVector3Array] = []
	var values: Array[PackedFloat32Array] = []
	for i in outline.size():
		var p := outline[i]
		var ring := PackedVector3Array()
		var vals := PackedFloat32Array()
		var fold := (1.0 - smoothstep(PLEAT_TOP - 0.2, PLEAT_TOP, p.y)) * float(p.x > 0.0) if pleated else 0.0
		var depth := lerpf(PLEAT_DEPTH.x, PLEAT_DEPTH.y, clampf(p.y / PLEAT_TOP, 0.0, 1.0)) * fold
		for j in segs:
			var a := TAU * j / segs
			# 0 in the bottom of a fold, 1 on its ridge
			var ridge := absf(sin(a * PLEATS * 0.5))
			var r := p.x + depth * (ridge - 0.6)
			ring.append(xf * Vector3(sin(a) * r, p.y, cos(a) * r))
			vals.append(shade[i] * lerpf(1.0, lerpf(PLEAT_SHADE, 1.0, ridge), fold))
		rings.append(ring)
		values.append(vals)
	st.set_smooth_group(0)
	for i in rings.size() - 1:
		for j in segs:
			var k := (j + 1) % segs
			for q: Vector2i in [Vector2i(i, j), Vector2i(i + 1, j), Vector2i(i, k), Vector2i(i, k), Vector2i(i + 1, j), Vector2i(i + 1, k)]:
				st.set_color(Color.WHITE * minf(values[q.x][q.y] * ROBE_VALUE, 1.0))
				st.add_vertex(rings[q.x][q.y])


## A clay pot: belly, shoulder, neck, a lip turned out and its dark mouth. size: its height in meters.
func pot(at: Vector3, size: float = 0.9) -> void:
	if _clay == null:
		_clay = StandardMaterial3D.new()
		_clay.albedo_color = CLAY
		_clay.roughness = 0.75
		_clay.rim_enabled = true
		_clay.rim = CLAY_RIM
		_mouth = StandardMaterial3D.new()
		_mouth.albedo_color = CLAY_DARK * 0.2
		VisualProfile.vary(_clay, {&"albedo_color": STY_CLAY})
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


## A thick candle of cream wax, the wax run down in a wide pool round its foot, and its flame (unlit, glowing: an
## orange tongue with a near-white core). height, radius in meters. open: it opens round the paladin behind it, like
## the stone with see_through (the Chamber of the Seal's front candles; see_open() gives the materials).
func candle(at: Vector3, height: float, radius: float, open := false) -> void:
	_wax_ready()
	var wax: Material = see_open(_wax) if open else _wax
	var body := MeshInstance3D.new()
	body.mesh = _wax_mesh
	body.material_override = wax
	body.transform = Transform3D(Basis.from_scale(Vector3(radius, height, radius)), at + Vector3(0, height * 0.5, 0))
	_add(body)
	# the wax run down and pooled round its foot
	var drip := MeshInstance3D.new()
	drip.mesh = _wax_mesh
	drip.material_override = wax
	drip.transform = Transform3D(Basis.from_scale(Vector3(radius * WAX_POOL, 0.04, radius * WAX_POOL)), at + Vector3(0, 0.0, 0))
	_add(drip)
	var run := MeshInstance3D.new()
	run.mesh = _wax_mesh
	run.material_override = wax
	run.transform = Transform3D(Basis.from_scale(Vector3(radius * 1.25, height * 0.3, radius * 1.25)), at + Vector3(radius * 0.12, height * 0.15, 0))
	_add(run)
	for mesh: QuadMesh in [_flame, _flame_core]:
		var f := MeshInstance3D.new()
		f.mesh = mesh
		f.position = at + Vector3(0, height + CANDLE_FLAME * 0.4 * (1.0 if mesh == _flame else CANDLE_CORE_SIZE), 0)
		f.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if open:
			# a billboard: kept out of merge() (joined meshes lose their own upright)
			f.material_override = see_open(mesh.material)
			f.layers = layers
			root.add_child(f)
			continue
		_add(f)


## A burnt-out candle (VX-13: most of the hall's edge stays unlit, the warm a few accents): the wax darker and unlit
## from inside, its pool, a dark wick; no flame, no halo, no light.
func candle_out(at: Vector3, height: float, radius: float) -> void:
	_wax_ready()
	if _wax_out == null:
		_wax_out = StandardMaterial3D.new()
		_wax_out.albedo_color = WAX * WAX_OUT
		_wax_out.roughness = 0.7
		_wick = StandardMaterial3D.new()
		_wick.albedo_color = WICK
	for t: Transform3D in [Transform3D(Basis.from_scale(Vector3(radius, height, radius)), at + Vector3(0, height * 0.5, 0)),
			Transform3D(Basis.from_scale(Vector3(radius * WAX_POOL, 0.04, radius * WAX_POOL)), at)]:
		var body := MeshInstance3D.new()
		body.mesh = _wax_mesh
		body.material_override = _wax_out
		body.transform = t
		_add(body)
	box(at + Vector3(0, height + 0.02, 0), Vector3(0.012, 0.04, 0.012), 0.0, _wick, false)


func _wax_ready() -> void:
	if _wax != null:
		return
	_wax = StandardMaterial3D.new()
	_wax.albedo_color = WAX
	_wax.roughness = 0.6
	_wax.rim_enabled = true
	_wax.rim = 0.3
	_wax.emission_enabled = true
	_wax.emission = WAX_GLOW
	_wax.emission_operator = BaseMaterial3D.EMISSION_OP_MULTIPLY
	_wax.emission_texture = _wax_glow()
	_wax_mesh = CylinderMesh.new()
	_wax_mesh.top_radius = 1.0
	_wax_mesh.bottom_radius = 1.0
	_wax_mesh.height = 1.0
	_wax_mesh.radial_segments = 10
	_wax_mesh.rings = 1
	var size := Vector2(CANDLE_FLAME * 0.6, CANDLE_FLAME * 1.3)
	_flame = ArenaKit.tongue(size, CANDLE_FIRE)
	_flame_core = ArenaKit.tongue(size * CANDLE_CORE_SIZE, CANDLE_CORE)
	VisualProfile.vary(_wax, {&"albedo_color": STY_WAX, &"rim": STY_WAX_RIM})
	VisualProfile.vary(_flame.material, {&"albedo_color": STY_CANDLE_FIRE})
	VisualProfile.vary(_flame_core.material, {&"albedo_color": STY_CANDLE_CORE})


const CANDLE_WAX_SEE := preload("res://assets/shaders/candle_wax_see.gdshader")
const FLAME_SEE := preload("res://assets/shaders/flame_see.gdshader")
static var _see_twins: Dictionary = {}


## The twin of a candle's wax, of a flame (ArenaKit.tongue) or of a warm halo (Fx.quad) that opens round the paladin
## behind it (see_through.gdshaderinc): the same colours, one twin per material.
static func see_open(mat: Material) -> ShaderMaterial:
	if _see_twins.has(mat):
		return _see_twins[mat]
	var base := mat as StandardMaterial3D
	var twin := ShaderMaterial.new()
	# the base's classic colours whatever the look it is built in, and its stylized ones through the visual profile
	# (lot E: a chamber built in the stylized look kept the stylized flames in the classic one)
	var albedo: Color = VisualProfile.classic_of(base, &"albedo_color", base.albedo_color)
	var styled := {}
	if base.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
		twin.shader = FLAME_SEE
		twin.set_shader_parameter(&"color", albedo)
		twin.set_shader_parameter(&"shape", base.albedo_texture)
		twin.set_shader_parameter(&"facing", 1 if base.billboard_mode == BaseMaterial3D.BILLBOARD_PARTICLES else 0)
		twin.render_priority = base.render_priority
		if VisualProfile.styled(base, &"albedo_color") != null:
			styled[&"shader_parameter/color"] = VisualProfile.styled(base, &"albedo_color")
	else:
		twin.shader = CANDLE_WAX_SEE
		twin.set_shader_parameter(&"wax", albedo)
		twin.set_shader_parameter(&"roughness", base.roughness)
		twin.set_shader_parameter(&"rim", VisualProfile.classic_of(base, &"rim", base.rim))
		twin.set_shader_parameter(&"glow", base.emission)
		twin.set_shader_parameter(&"glow_share", base.emission_texture)
		if VisualProfile.styled(base, &"albedo_color") != null:
			styled[&"shader_parameter/wax"] = VisualProfile.styled(base, &"albedo_color")
		if VisualProfile.styled(base, &"rim") != null:
			styled[&"shader_parameter/rim"] = VisualProfile.styled(base, &"rim")
	VisualProfile.vary(twin, styled)
	_see_twins[mat] = twin
	return twin


## How much of the wax's glow each part of a candle takes (the cylinder's UVs: its side in the upper half of the
## texture, top to foot; its top cap in the lower left, its bottom cap in the lower right).
func _wax_glow() -> ImageTexture:
	var h := 16
	var img := Image.create(2, h, false, Image.FORMAT_L8)
	for y in h:
		var v := (y + 0.5) / h
		for x in 2:
			var foot := v * 2.0 if v < 0.5 else float(x)
			img.set_pixel(x, y, Color.WHITE * lerpf(1.0, WAX_GLOW_FOOT, clampf(foot, 0.0, 1.0)))
	return ImageTexture.create_from_image(img)


## A wooden crate standing at `foot` (the middle of its base): planks, darker corner posts and bands at top and bottom.
func crate(foot: Vector3, size: Vector3, yaw: float = 0.0) -> void:
	var wood := _wood_mat(foot.y, 1.0)
	var frame := _wood_mat(foot.y, WOOD_FRAME)
	var inner := size - Vector3(CRATE_PROUD, 0.0, CRATE_PROUD) * 2.0
	block(foot, inner, yaw, wood, false)
	var basis := Basis(Vector3.UP, yaw)
	var post := maxf(size.x, size.z) * CRATE_POST
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			block(foot + basis * Vector3(sx * (size.x - post) * 0.5, 0, sz * (size.z - post) * 0.5), Vector3(post, size.y, post), yaw, frame, false)
	var band := size.y * CRATE_BAND
	for y: float in [0.0, size.y - band]:
		block(foot + Vector3(0, y, 0), Vector3(size.x - post * 0.5, band, size.z - post * 0.5), yaw, frame, false)


## Wood for the crates: the stone's shader with planks for courses (their joints the gaps between the boards).
func _wood_mat(base_y: float, value: float) -> ShaderMaterial:
	var key := "%.1f|%.2f" % [base_y, value]
	if not _wood.has(key):
		var w := ShaderMaterial.new()
		w.shader = SHADER
		w.set_shader_parameter(&"base_y", base_y)
		w.set_shader_parameter(&"stone_a", WOOD_A * value)
		w.set_shader_parameter(&"stone_b", WOOD_B * value)
		w.set_shader_parameter(&"joint_color", WOOD_JOINT)
		w.set_shader_parameter(&"course", PLANK)
		w.set_shader_parameter(&"block_len", 3.0)
		w.set_shader_parameter(&"block_var", 0.2)
		w.set_shader_parameter(&"joint_width", 0.02)
		w.set_shader_parameter(&"chipped", 0.0)
		w.set_shader_parameter(&"grime_height", 0.4)
		w.set_shader_parameter(&"rock_normal", ROCK_NORMAL)
		w.set_shader_parameter(&"rock_height", ROCK_HEIGHT)
		_wood[key] = w
	return _wood[key]


## True for the crates' wood (it keeps its own colour in the stylized look).
func is_wood(mat: Material) -> bool:
	return _wood.values().has(mat)


func _add(mi: GeometryInstance3D) -> void:
	mi.layers = layers
	root.add_child(mi)
	if mi is MeshInstance3D:
		_built.append(mi)


## RS-C1: the billboards added under root since child `from` (open candles' flames, which merge() leaves alone: a
## joined mesh loses each one's own upright) joined into one MultiMesh per mesh and material, so a crown of candles is
## two draw calls, not two a candle. flame_see.gdshader turns each instance round its own upright.
func gather_billboards(from: int) -> void:
	var groups := {}
	for i in range(from, root.get_child_count()):
		var mi := root.get_child(i) as MeshInstance3D
		if mi == null or not mi.mesh is QuadMesh or mi.material_override == null:
			continue
		var key := [mi.mesh, mi.material_override, mi.layers]
		if not groups.has(key):
			groups[key] = []
		groups[key].append(mi)
	for key: Array in groups:
		var list: Array = groups[key]
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = key[0]
		mm.instance_count = list.size()
		for k in list.size():
			mm.set_instance_transform(k, (list[k] as MeshInstance3D).transform)
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		mmi.material_override = key[1]
		mmi.layers = key[2]
		mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(mmi)
		for mi: MeshInstance3D in list:
			root.remove_child(mi)
			mi.free()


## Joins the stone built so far into one mesh per material, visual layer and MERGE_CELL square of floor (so each
## piece still only takes the lights near it, which the browser's renderer needs): a few hundred draw calls instead
## of over a thousand. Call once the room is built; nothing built before it may be moved afterwards.
## RS-C1: from (an index in what was built, built_count()): only what was built since, cells false: all of it in one
## mesh per material whatever the square (a small piece hanging high, the crypt's crown). Returns the meshes it leaves
## (joined or alone).
## The meshes built since `from`, taken out of what merge() joins (they stay where they are, on their own: RP-09, a
## column that may topple moves alone).
func take_since(from: int) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	for i in range(from, _built.size()):
		out.append(_built[i])
	_built.resize(mini(from, _built.size()))
	return out


## QA P1-1: a mesh committed with its arrays kept on the CPU (meta ARRAYS), so merge() never reads them back from
## the graphics card (surface_get_arrays on a real renderer copies the buffer back and waits for the card: a room's
## merge took 0.5 s on the iGPU, 30 ms without a screen). The same mesh as st.commit().
const ARRAYS := &"cpu_arrays"
## How many pieces the last merge read back from the card (no kept arrays): for the measures.
static var read_back := 0


static func kept(st: SurfaceTool) -> ArrayMesh:
	var arrays := st.commit_to_arrays()
	var vertices: Variant = arrays[Mesh.ARRAY_VERTEX]
	if vertices == null or (vertices as PackedVector3Array).is_empty():
		return st.commit()
	for slot in Mesh.ARRAY_MAX:
		if arrays[slot] != null and arrays[slot].is_empty():
			arrays[slot] = null  # (as the card gives them back: an empty array is no array)
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	if arrays[Mesh.ARRAY_NORMAL] != null and arrays[Mesh.ARRAY_TANGENT] == null:
		# what the card gives back for a mesh with normals and no tangents (and so what merge() always joined)
		# (the renderer's dummy tangent: (n.z, -n.x, n.y) x n)
		var t := PackedFloat32Array()
		for exact: Vector3 in arrays[Mesh.ARRAY_NORMAL]:
			# (from the normal as stored: 16-bit octahedral)
			var n := Vector3.octahedron_decode((exact.normalized().octahedron_encode() * 65535.0).round() / 65535.0)
			var d := Vector3(n.z, -n.x, n.y).cross(n.normalized()).normalized()
			t.append_array([d.x, d.y, d.z, 1.0])
		arrays[Mesh.ARRAY_TANGENT] = t
	mesh.set_meta(ARRAYS, arrays)
	return mesh


## A one-surface mesh's arrays without asking the card when it can: kept ones, a primitive's own (made on the CPU),
## else read back once and kept on the mesh for its next uses.
static func arrays_of(mesh: Mesh) -> Array:
	if mesh.has_meta(ARRAYS):
		return mesh.get_meta(ARRAYS)
	var arrays: Array
	if mesh is PrimitiveMesh:
		arrays = (mesh as PrimitiveMesh).get_mesh_arrays()
	else:
		arrays = mesh.surface_get_arrays(0)
		read_back += 1
	mesh.set_meta(ARRAYS, arrays)
	return arrays


## The pieces' arrays joined into one, each moved by its transform as SurfaceTool.append_from does (vertex by the
## transform, normal and tangent by its basis); empty when they cannot be joined this way (different arrays, bones
## or custom data), and merge() falls back on the SurfaceTool.
static func joined_arrays(list: Array) -> Array:
	var parts: Array = []
	for mi: MeshInstance3D in list:
		parts.append(arrays_of(mi.mesh))
	var first: Array = parts[0]
	for slot in Mesh.ARRAY_MAX:
		var has := first[slot] != null
		for a: Array in parts:
			if (a[slot] != null) != has:
				return []
		if has and slot in [Mesh.ARRAY_BONES, Mesh.ARRAY_WEIGHTS, Mesh.ARRAY_CUSTOM0, Mesh.ARRAY_CUSTOM1,
				Mesh.ARRAY_CUSTOM2, Mesh.ARRAY_CUSTOM3]:
			return []
	var out: Array = []
	out.resize(Mesh.ARRAY_MAX)
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var tangents := PackedFloat32Array()
	var colors := PackedColorArray()
	var uvs := PackedVector2Array()
	var uv2s := PackedVector2Array()
	var indices := PackedInt32Array()
	for k in list.size():
		var a: Array = parts[k]
		var xf: Transform3D = (list[k] as MeshInstance3D).transform
		var base := verts.size()
		for v: Vector3 in a[Mesh.ARRAY_VERTEX]:
			verts.append(xf * v)
		if a[Mesh.ARRAY_NORMAL] != null:
			for n: Vector3 in a[Mesh.ARRAY_NORMAL]:
				normals.append((xf.basis * n).normalized())
		if a[Mesh.ARRAY_TANGENT] != null:
			var t: PackedFloat32Array = a[Mesh.ARRAY_TANGENT]
			for i in range(0, t.size(), 4):
				var d := (xf.basis * Vector3(t[i], t[i + 1], t[i + 2])).normalized()
				tangents.append_array([d.x, d.y, d.z, t[i + 3]])
		if a[Mesh.ARRAY_COLOR] != null:
			colors.append_array(a[Mesh.ARRAY_COLOR])
		if a[Mesh.ARRAY_TEX_UV] != null:
			uvs.append_array(a[Mesh.ARRAY_TEX_UV])
		if a[Mesh.ARRAY_TEX_UV2] != null:
			uv2s.append_array(a[Mesh.ARRAY_TEX_UV2])
		if a[Mesh.ARRAY_INDEX] != null:
			for i: int in a[Mesh.ARRAY_INDEX]:
				indices.append(base + i)
	out[Mesh.ARRAY_VERTEX] = verts
	if first[Mesh.ARRAY_NORMAL] != null:
		out[Mesh.ARRAY_NORMAL] = normals
	if first[Mesh.ARRAY_TANGENT] != null:
		out[Mesh.ARRAY_TANGENT] = tangents
	if first[Mesh.ARRAY_COLOR] != null:
		out[Mesh.ARRAY_COLOR] = colors
	if first[Mesh.ARRAY_TEX_UV] != null:
		out[Mesh.ARRAY_TEX_UV] = uvs
	if first[Mesh.ARRAY_TEX_UV2] != null:
		out[Mesh.ARRAY_TEX_UV2] = uv2s
	if first[Mesh.ARRAY_INDEX] != null:
		out[Mesh.ARRAY_INDEX] = indices
	return out


func merge(from := 0, cells := true) -> Array[MeshInstance3D]:
	var left: Array[MeshInstance3D] = []
	BuildSteps.run(merge_steps(from, cells, left))
	return left


## The vertices one slice of a merge joins (merge_steps: a frame each on a new room's black screen).
const MERGE_SLICE := 6000


## merge() in steps (BuildSteps): the first sorts the pieces into groups and gives back one step per slice of about
## MERGE_SLICE vertices; `left` gathers the meshes it leaves, as merge() returns them.
func merge_steps(from := 0, cells := true, left: Array[MeshInstance3D] = []) -> Array[Callable]:
	return [func() -> Array[Callable]:
		var groups := {}
		var t0 := Time.get_ticks_usec()
		var prims := 0
		for i in range(from, _built.size()):
			var mi := _built[i]
			if not is_instance_valid(mi) or mi.material_override == null or mi.mesh == null or mi.mesh.get_surface_count() != 1:
				continue
			if mi.mesh is PrimitiveMesh:
				prims += 1
			var cell := Vector2i(floori(mi.position.x / MERGE_CELL), floori(mi.position.z / MERGE_CELL)) if cells else Vector2i.ZERO
			# meshes of one kind of vertex data per group (bevelled boxes, statues, primitives)
			var fmt := (mi.mesh as ArrayMesh).surface_get_format(0) if mi.mesh is ArrayMesh else -1
			var key := [mi.material_override, mi.layers, mi.cast_shadow, cell, fmt]
			if not groups.has(key):
				groups[key] = []
			groups[key].append(mi)
		var t1 := Time.get_ticks_usec()
		_built.resize(from)
		var slices: Array[Callable] = []
		# the primitives' arrays made first, a few a step (a big group is joined in one step, from arrays at hand)
		var making: Array[Mesh] = []
		var seen := {}
		for key: Array in groups:
			if (groups[key] as Array).size() < 2:
				continue
			for mi: MeshInstance3D in groups[key]:
				if not mi.mesh.has_meta(ARRAYS) and not seen.has(mi.mesh):
					seen[mi.mesh] = true
					making.append(mi.mesh)
		for k in range(0, making.size(), PRIMITIVES_A_STEP):
			slices.append(func() -> void:
				for mesh in making.slice(k, k + PRIMITIVES_A_STEP):
					arrays_of(mesh))
		var batch: Array = []
		var verts := 0
		for key: Array in groups:
			batch.append(key)
			for mi: MeshInstance3D in groups[key]:
				verts += _vertex_count(mi.mesh)
			if verts >= MERGE_SLICE:
				slices.append(_join.bind(groups, batch, left))
				batch = []
				verts = 0
		if not batch.is_empty():
			slices.append(_join.bind(groups, batch, left))
		if Dev.has("trace-build"):
			print("MERGE groups %.1f ms (%d primitives) counts %.1f ms" % [(t1 - t0) / 1000.0, prims, (Time.get_ticks_usec() - t1) / 1000.0])
		return slices]


## A piece's weight in a slice: its vertices when its arrays are at hand, else (a primitive whose arrays are still to
## be made, about half a millisecond each on the iGPU's machine) PRIMITIVE_WEIGHT.
const PRIMITIVE_WEIGHT := 400
## The primitives whose arrays one step of a merge makes (merge_steps).
const PRIMITIVES_A_STEP := 8


static func _vertex_count(mesh: Mesh) -> int:
	if mesh.has_meta(ARRAYS):
		return ((mesh.get_meta(ARRAYS) as Array)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
	return PRIMITIVE_WEIGHT


func _join(groups: Dictionary, keys: Array, left: Array[MeshInstance3D]) -> void:
	for key: Array in keys:
		var list: Array = groups[key]
		if list.size() < 2:
			left.append(list[0])
			continue
		var joined := MeshInstance3D.new()
		var arrays := joined_arrays(list)
		if arrays.is_empty():
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			for mi: MeshInstance3D in list:
				st.append_from(mi.mesh, 0, mi.transform)
			joined.mesh = st.commit()
		else:
			var mesh := ArrayMesh.new()
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			joined.mesh = mesh
		joined.material_override = key[0]
		joined.layers = key[1]
		joined.cast_shadow = key[2]
		root.add_child(joined)
		left.append(joined)
		for mi: MeshInstance3D in list:
			root.remove_child(mi)
			mi.free()


## How many pieces were built and not merged yet (merge's `from`).
func built_count() -> int:
	return _built.size()
