class_name VineStation
extends Node3D
## The Videira's station in the Santuário (V2; its planting grows in V3): a stone vase on a low plinth under the arch that
## HubLook draws (hub_vine's footprint), and in the vase a young vine of three stems, one for each branch (Vida,
## Provisão, Perseverança) and three stages on each, one for each node bought. PROVISIONAL pieces: plain meshes of
## primitives, so the V3 can replace the stems for a real growing plant without touching who calls it.
##   var v := VineStation.make(frame, HubLook.at(u, 0.0, v))   # in the hub's frame (x = u, z = -v)
##   v.grown({&"vida": 2, &"provisao": 0, &"perseveranca": 3})  # nodes bought in each branch, 0 to STEPS (Vine.growth)
## `grown` is idempotent and only shows or hides; every stage exists from the start. Stems stand across the arch (along u),
## the first branch to the west of it.

const STEPS := 3
const SPREAD := 0.62
const VASE := Vector3(0.62, 0.42, 0.62)
const STONE := Color(0.5, 0.47, 0.42)
const SOIL := Color(0.1, 0.07, 0.05)
const WOOD := Color(0.3, 0.2, 0.12)
const LEAF_A := Color(0.2, 0.36, 0.14)
const LEAF_B := Color(0.38, 0.5, 0.2)

## The stems' stages by branch (Node3D each, shown up to the bought count) and the last count given.
var stages: Dictionary = {}
var bought: Dictionary = {}


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
	var wood := _flat(WOOD, 0.9)
	var branches := Vine.BRANCHES
	for i in branches.size():
		var root := Node3D.new()
		root.name = "Stem_%s" % branches[i]
		root.position = Vector3((i - 1) * SPREAD * 0.5, VASE.y + 0.2, 0)
		add_child(root)
		var list: Array[Node3D] = []
		for k in STEPS:
			var st := Node3D.new()
			st.name = "Stage%d" % (k + 1)
			st.position = Vector3(0, k * 0.62, 0)
			st.rotation.z = (i - 1) * 0.1
			root.add_child(st)
			var stem := CylinderMesh.new()
			stem.top_radius = 0.04
			stem.bottom_radius = 0.06
			stem.height = 0.62
			_mesh(stem, Vector3(0, 0.31, 0), wood, st).name = "stem"
			for side in [-1.0, 1.0]:
				var ball := SphereMesh.new()
				ball.radius = 0.17
				ball.height = 0.22
				var leaf := _mesh(ball, Vector3(side * 0.2, 0.42, 0.02), _flat(LEAF_A if (k + i) % 2 == 0 else LEAF_B, 0.8), st)
				leaf.rotation.z = side * 0.5
			list.append(st)
		stages[branches[i]] = list
		# a sprout on the vase before anything is bought
		var bud := SphereMesh.new()
		bud.radius = 0.09
		bud.height = 0.14
		_mesh(bud, Vector3(0, 0.1, 0), _flat(LEAF_B, 0.8), root).name = "sprout"
	grown({})


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
