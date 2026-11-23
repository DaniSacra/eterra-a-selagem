class_name VineStation
extends Node3D
## The Videira's station in the Santuário (V2 planted it, V3 grows it): a stone vase on a low plinth under the arch that
## HubLook draws (hub_vine's footprint), a twisted trunk out of the vase and three branches (Vida, Provisão,
## Perseverança) climbing the arch, three stages on each, one for each node bought: sprout, leafy branch, branch with
## amber clusters and flowers. With nothing bought it is a stump with one sprout; with everything it covers the arch.
## Procedural meshes (tubes and flattened spheres merged per stage), in the palette of the Árvore de Dons (darker moss).
##   var v := VineStation.make(frame, HubLook.at(u, 0.0, v))   # in the hub's frame (x = u, z = -v)
##   v.grown({&"vida": 2, &"provisao": 0, &"perseveranca": 3})  # nodes bought in each branch, 0 to STEPS (Vine.growth)
## `grown` is idempotent and only shows or hides; every stage exists from the start. The first branch climbs the west
## pillar, the last the east one, the middle one the centre of the arch.

const STEPS := 3
const SIDES := 6
const SEG_STEPS := 4
const VASE := Vector3(0.62, 0.42, 0.62)
const TRUNK_TOP := 1.0
const TRUNK_R := Vector2(0.17, 0.07)
const VINE_R := Vector2(0.1, 0.04)
const STONE := Color(0.5, 0.47, 0.42)
const SOIL := Color(0.1, 0.07, 0.05)
const WOOD := Color(0.26, 0.18, 0.11)
const LEAF_A := Color(0.12, 0.25, 0.09)
const LEAF_B := Color(0.2, 0.34, 0.12)
const FRUIT := Color(0.95, 0.6, 0.12)
const FLOWER := Color(0.98, 0.82, 0.4)
const FRUIT_GLOW := 0.7
## Per stage (1 to 3): leaves, amber clusters and flowers on each branch.
const LEAVES := [9, 18, 24]
const FRUITS := [0, 0, 7]
const FLOWERS := [0, 2, 4]
## Each branch's path (x, y in the arch's plane) in 10 points: stage k runs the segments 3k to 3k+2.
const PATHS := [
	[Vector2(0, 0.95), Vector2(-0.2, 1.2), Vector2(-0.45, 1.4), Vector2(-0.65, 1.65), Vector2(-0.85, 1.85),
		Vector2(-0.88, 2.1), Vector2(-0.9, 2.35), Vector2(-0.75, 2.6), Vector2(-0.45, 2.72), Vector2(-0.15, 2.7)],
	[Vector2(0, 0.95), Vector2(0.08, 1.2), Vector2(-0.05, 1.45), Vector2(-0.12, 1.7), Vector2(0.05, 1.95),
		Vector2(0.12, 2.15), Vector2(0.0, 2.4), Vector2(-0.08, 2.58), Vector2(0.1, 2.7), Vector2(0.25, 2.66)],
	[Vector2(0, 0.95), Vector2(0.2, 1.2), Vector2(0.45, 1.4), Vector2(0.65, 1.65), Vector2(0.85, 1.85),
		Vector2(0.88, 2.1), Vector2(0.9, 2.35), Vector2(0.75, 2.6), Vector2(0.45, 2.72), Vector2(0.15, 2.7)],
]
const PART_KEYS: Array[String] = ["wood", "a", "b", "fruit", "flower"]

## The branches' stages (Node3D each, shown up to the bought count) and the last count given.
var stages: Dictionary = {}
var bought: Dictionary = {}

static var _round: SphereMesh


static func make(parent: Node3D, at: Vector3) -> VineStation:
	var s := VineStation.new()
	s.name = "VineStation"
	s.position = at
	parent.add_child(s)
	s._build()
	return s


func _build() -> void:
	var foot := CylinderMesh.new()
	foot.top_radius = VASE.x * 0.9
	foot.bottom_radius = VASE.x * 0.95
	foot.height = 0.2
	_mesh(foot, Vector3(0, 0.1, 0), _flat(STONE * 0.8, 0.95))
	var vase := CylinderMesh.new()
	vase.top_radius = VASE.x
	vase.bottom_radius = VASE.x * 0.7
	vase.height = VASE.y
	_mesh(vase, Vector3(0, VASE.y * 0.5 + 0.2, 0), _flat(STONE, 0.95))
	var soil := CylinderMesh.new()
	soil.top_radius = VASE.x * 0.9
	soil.bottom_radius = VASE.x * 0.9
	soil.height = 0.04
	_mesh(soil, Vector3(0, VASE.y + 0.19, 0), _flat(SOIL, 1.0))
	var mats := _materials()
	_trunk(mats)
	var branches := Vine.BRANCHES
	for i in branches.size():
		var path := _path(PATHS[i], (i - 1) * 0.16)
		var list: Array[Node3D] = []
		for k in STEPS:
			var st := Node3D.new()
			st.name = "%s_%d" % [branches[i], k + 1]
			add_child(st)
			var rng := RandomNumberGenerator.new()
			rng.seed = 7919 * (i + 1) + k
			var mi := MeshInstance3D.new()
			mi.name = "growth"
			mi.mesh = _commit(_stage_parts(path, k, rng), mats)
			st.add_child(mi)
			list.append(st)
		stages[branches[i]] = list
	grown({})


## The twisted trunk out of the vase (always there) with the sprout on its top.
func _trunk(mats: Dictionary) -> void:
	var base := VASE.y + 0.2
	var pts: Array[Vector3] = []
	var n := 9
	for j in n + 1:
		var t := float(j) / n
		var a := t * TAU * 0.9
		pts.append(Vector3(sin(a) * 0.07 * (1.0 - t * 0.4), base + t * (TRUNK_TOP - base), 0.04 + cos(a) * 0.05 * (1.0 - t * 0.4)))
	var parts := _new_parts()
	_tube(parts["wood"], pts, TRUNK_R.x, TRUNK_R.y)
	for side in [-1.0, 1.0]:
		var basis := Basis.from_euler(Vector3(0.2, 0.0, side * 0.7)) * Basis.from_scale(Vector3(0.13, 0.025, 0.07))
		(parts["b"] as SurfaceTool).append_from(_leaf_mesh(), 0, Transform3D(basis, pts[n] + Vector3(side * 0.1, 0.04, 0.03)))
	var mi := MeshInstance3D.new()
	mi.name = "trunk"
	mi.mesh = _commit(parts, mats)
	add_child(mi)


## One stage of a branch: the tube along its segments, the leaves, and from the third the amber fruit and flowers.
func _stage_parts(path: Array[Vector3], k: int, rng: RandomNumberGenerator) -> Dictionary:
	var parts := _new_parts()
	var pts: Array[Vector3] = []
	for seg in range(3 * k, 3 * k + 3):
		for j in SEG_STEPS:
			pts.append(_spline(path, seg, float(j) / SEG_STEPS))
	pts.append(_spline(path, 3 * k + 2, 1.0))
	_tube(parts["wood"], pts, lerpf(VINE_R.x, VINE_R.y, k / 3.0), lerpf(VINE_R.x, VINE_R.y, (k + 1) / 3.0))
	for l in LEAVES[k]:
		var p := pts[rng.randi_range(0, pts.size() - 1)]
		var side := 1.0 if l % 2 == 0 else -1.0
		var size := lerpf(0.9, 1.25, k / 2.0) * rng.randf_range(0.85, 1.15)
		var basis := Basis.from_euler(Vector3(rng.randf_range(-0.5, 0.5), rng.randf_range(0.0, TAU), side * rng.randf_range(0.3, 0.9)))
		basis = basis * Basis.from_scale(Vector3(0.26, 0.045, 0.16) * size)
		var target: SurfaceTool = parts["b"] if l % 3 == 0 else parts["a"]
		target.append_from(_leaf_mesh(), 0, Transform3D(basis, p + Vector3(side * 0.09 * size, rng.randf_range(0.0, 0.05), rng.randf_range(0.0, 0.08))))
	for f in FRUITS[k]:
		var p := pts[rng.randi_range(pts.size() / 3, pts.size() - 1)]
		for g in 3:
			var xf := Transform3D(Basis.from_scale(Vector3(0.075, 0.08, 0.075)), p + Vector3(rng.randf_range(-0.03, 0.03), -0.09 - g * 0.05, 0.06))
			(parts["fruit"] as SurfaceTool).append_from(_leaf_mesh(), 0, xf)
	for f in FLOWERS[k]:
		var p := pts[rng.randi_range(0, pts.size() - 1)]
		var xf := Transform3D(Basis.from_scale(Vector3(0.05, 0.03, 0.05)), p + Vector3(rng.randf_range(-0.05, 0.05), 0.06, 0.07))
		(parts["flower"] as SurfaceTool).append_from(_leaf_mesh(), 0, xf)
	return parts


## The path's control points in the arch's plane lifted into 3D (`lean` stacks the branches front to back).
static func _path(pts2: Array, lean: float) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for j in pts2.size():
		var p: Vector2 = pts2[j]
		out.append(Vector3(p.x, p.y, 0.08 + lean + sin(j * 1.7) * 0.05))
	return out


## Catmull-Rom between the control points seg and seg+1 at t (0 to 1).
static func _spline(path: Array[Vector3], seg: int, t: float) -> Vector3:
	var n := path.size()
	var p0 := path[maxi(seg - 1, 0)]
	var p1 := path[seg]
	var p2 := path[mini(seg + 1, n - 1)]
	var p3 := path[mini(seg + 2, n - 1)]
	return p1.cubic_interpolate(p2, p0, p3, t)


## A low-poly unit sphere, flattened by each part's transform (leaf, fruit, flower).
static func _leaf_mesh() -> SphereMesh:
	if _round == null:
		_round = SphereMesh.new()
		_round.radius = 1.0
		_round.height = 2.0
		_round.radial_segments = 6
		_round.rings = 3
	return _round


static func _new_parts() -> Dictionary:
	var parts := {}
	for key in PART_KEYS:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		parts[key] = st
	return parts


## A tube of SIDES faces along `pts`, its radius going from r0 to r1.
static func _tube(st: SurfaceTool, pts: Array[Vector3], r0: float, r1: float) -> void:
	var rings: Array = []
	for j in pts.size():
		var d := (pts[mini(j + 1, pts.size() - 1)] - pts[maxi(j - 1, 0)]).normalized()
		var side := d.cross(Vector3.BACK)
		if side.length() < 0.1:
			side = d.cross(Vector3.RIGHT)
		side = side.normalized()
		var up := side.cross(d).normalized()
		var r := lerpf(r0, r1, float(j) / maxi(pts.size() - 1, 1))
		var ring: Array[Vector3] = []
		for s in SIDES:
			var a := TAU * s / SIDES
			ring.append(pts[j] + (side * cos(a) + up * sin(a)) * r)
		rings.append(ring)
	for j in rings.size() - 1:
		for s in SIDES:
			var s2 := (s + 1) % SIDES
			var a: Vector3 = rings[j][s]
			var b: Vector3 = rings[j][s2]
			var c: Vector3 = rings[j + 1][s]
			var e: Vector3 = rings[j + 1][s2]
			for v in [a, c, b, b, c, e]:
				st.add_vertex(v)


## The surfaces of a stage into one mesh, a material each (only the parts that have geometry).
static func _commit(parts: Dictionary, mats: Dictionary) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	for key: String in PART_KEYS:
		var st: SurfaceTool = parts[key]
		st.generate_normals()
		var arrays := st.commit_to_arrays()
		var verts: Variant = arrays[Mesh.ARRAY_VERTEX]
		if verts == null or (verts as PackedVector3Array).is_empty():
			continue
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(mesh.get_surface_count() - 1, mats[key])
	return mesh


static func _materials() -> Dictionary:
	var fruit := _flat(FRUIT, 0.5)
	fruit.emission_enabled = true
	fruit.emission = FRUIT
	fruit.emission_energy_multiplier = FRUIT_GLOW
	var flower := _flat(FLOWER, 0.6)
	flower.emission_enabled = true
	flower.emission = FLOWER
	flower.emission_energy_multiplier = FRUIT_GLOW * 0.5
	var wood := _flat(WOOD, 0.9)
	var a := _flat(LEAF_A, 0.8)
	var b := _flat(LEAF_B, 0.8)
	for m in [wood, a, b, fruit, flower]:
		(m as StandardMaterial3D).cull_mode = BaseMaterial3D.CULL_DISABLED
	return {"wood": wood, "a": a, "b": b, "fruit": fruit, "flower": flower}


## Shows the stages bought: `branches_bought` maps each branch (Vine.BRANCHES) to its nodes bought, 0 to STEPS (Vine.growth).
func grown(branches_bought: Dictionary) -> void:
	bought = branches_bought.duplicate()
	for branch: StringName in stages:
		var n := clampi(int(bought.get(branch, bought.get(String(branch), 0))), 0, STEPS)
		var list: Array = stages[branch]
		for k in list.size():
			(list[k] as Node3D).visible = k < n


## How many stages show now in all (0 to 9).
func stages_shown() -> int:
	var n := 0
	for branch: StringName in stages:
		for st: Node3D in stages[branch]:
			if st.visible:
				n += 1
	return n


func _mesh(mesh: Mesh, at: Vector3, mat: Material, parent: Node3D = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = at
	(parent if parent != null else self).add_child(mi)
	return mi


static func _flat(c: Color, rough: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	return m
