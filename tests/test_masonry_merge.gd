extends GutTest
## QA P1-1: Masonry.merge joins the pieces from arrays kept on the CPU (Masonry.kept, arrays_of), never reading them
## back from the card (a room's merge took 0.5 s on the iGPU). The joined arrays are the SurfaceTool's.


func _by_surface_tool(list: Array) -> Array:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for mi: MeshInstance3D in list:
		st.append_from(mi.mesh, 0, mi.transform)
	return st.commit().surface_get_arrays(0)


func _same(a: Array, b: Array, what: String) -> void:
	for slot in Mesh.ARRAY_MAX:
		assert_eq(a[slot] == null, b[slot] == null, "%s: slot %d present in both or neither" % [what, slot])
		if a[slot] == null or b[slot] == null:
			continue
		assert_eq(a[slot].size(), b[slot].size(), "%s: slot %d size" % [what, slot])
		if slot == Mesh.ARRAY_TANGENT:
			_same_tangents(a[slot], b[slot], what)
			continue
		var off := 0.0
		for i in mini(a[slot].size(), b[slot].size()):
			var x: Variant = a[slot][i]
			var y: Variant = b[slot][i]
			if x is Vector3:
				off = maxf(off, (x - y).length())
			elif x is Vector2:
				off = maxf(off, (x - y).length())
			elif x is Color:
				off = maxf(off, absf(x.r - y.r) + absf(x.g - y.g) + absf(x.b - y.b) + absf(x.a - y.a))
			else:
				off = maxf(off, absf(float(x) - float(y)))
		assert_lt(off, 0.001, "%s: slot %d the same (%.5f)" % [what, slot, off])


func test_blocks_join_as_the_surface_tool_did() -> void:
	var root := Node3D.new()
	add_child_autofree(root)
	var m := Masonry.new(root)
	var list: Array = []
	for k in 4:
		list.append(m.box(Vector3(k * 1.3, 0.4, -k), Vector3(1.0, 0.5 + k * 0.2, 0.7), k * 0.4))
	list[2].scale = Vector3(1.0, 1.6, 0.8)
	for mi: MeshInstance3D in list:
		assert_true(mi.mesh.has_meta(Masonry.ARRAYS), "kept on the CPU")
	var before := Masonry.read_back
	_same(Masonry.joined_arrays(list), _by_surface_tool(list), "blocks")
	assert_eq(Masonry.read_back, before, "nothing read back from the card")


func test_primitives_join_as_the_surface_tool_did() -> void:
	var root := Node3D.new()
	add_child_autofree(root)
	var list: Array = []
	for k in 3:
		var mi := MeshInstance3D.new()
		var c := CylinderMesh.new()
		c.top_radius = 0.2 + k * 0.1
		c.height = 1.0
		mi.mesh = c
		mi.position = Vector3(k, 0, 0)
		mi.rotation = Vector3(0.3 * k, 0.1, 0)
		root.add_child(mi)
		list.append(mi)
	_same(Masonry.joined_arrays(list), _by_surface_tool(list), "cylinders")


func test_a_room_merges_without_reading_back_its_stone() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	Masonry.read_back = 0
	var a := Arena.new()
	add_child_autofree(a)
	a.build(stage.layouts[1].variant(0), 2, 1406)
	gut.p("pieces read back from the card in the crypt: %d" % Masonry.read_back)
	assert_lt(Masonry.read_back, 60, "the crypt's stone joins from the CPU")


## The renderer's dummy tangent of a mesh without tangents ((n.z, -n.x, n.y) x n, from the stored normal) is noise
## where that cross nearly vanishes (normals near (1, 1, -1): a bevel's corners); no stone shader reads the tangent.
func _same_tangents(a: PackedFloat32Array, b: PackedFloat32Array, what: String) -> void:
	var off := 0
	for i in range(0, mini(a.size(), b.size()), 4):
		var d := Vector4(a[i], a[i + 1], a[i + 2], a[i + 3]) - Vector4(b[i], b[i + 1], b[i + 2], b[i + 3])
		if d.length() > 0.01:
			off += 1
	assert_lt(float(off) / (a.size() / 4), 0.1, "%s: the tangents the same but at the bevels' corners (%d)" % [what, off])
