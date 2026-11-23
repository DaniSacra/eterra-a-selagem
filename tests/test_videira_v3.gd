extends GutTest
## V3: the Videira grows (each stage has its own visible mesh, with nothing bought and with everything it differs) and the
## heroes' standards dress (the Maga's rolls up and goes grey while she is locked, unrolls when she opens).

func _vine() -> VineStation:
	var holder := Node3D.new()
	add_child_autofree(holder)
	return VineStation.make(holder, Vector3.ZERO)


func _verts(v: VineStation) -> int:
	var n := 0
	for branch: StringName in v.stages:
		for st: Node3D in v.stages[branch]:
			if st.visible:
				var mesh := (st.get_child(0) as MeshInstance3D).mesh as ArrayMesh
				for s in mesh.get_surface_count():
					n += (mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
	return n


func test_each_stage_has_a_mesh_of_its_own() -> void:
	var v := _vine()
	for branch: StringName in v.stages:
		var surfaces: Array[int] = []
		for st: Node3D in v.stages[branch]:
			var mesh := (st.get_child(0) as MeshInstance3D).mesh as ArrayMesh
			assert_gt(mesh.get_surface_count(), 0, "%s has geometry" % st.name)
			surfaces.append(mesh.get_surface_count())
		assert_gt(surfaces[2], surfaces[0], "the third stage adds fruit and flowers to the leaves and wood")


func test_the_vine_grows_with_every_purchase() -> void:
	var v := _vine()
	var last := _verts(v)
	assert_eq(last, 0, "nothing bought, only the stump with its sprout")
	var trunk := v.find_child("trunk", false, false) as MeshInstance3D
	assert_not_null(trunk)
	assert_true(trunk.visible)
	for n in 3:
		v.grown({&"vida": n + 1, &"provisao": n + 1, &"perseveranca": n + 1})
		var now := _verts(v)
		assert_gt(now, last, "stage %d adds geometry" % (n + 1))
		last = now
	v.grown({})
	assert_eq(_verts(v), 0)


func test_the_third_stage_carries_the_amber() -> void:
	var v := _vine()
	var third := (v.stages[&"vida"][2] as Node3D).get_child(0) as MeshInstance3D
	var amber := false
	for s in (third.mesh as ArrayMesh).get_surface_count():
		var m := (third.mesh as ArrayMesh).surface_get_material(s) as StandardMaterial3D
		if m.emission_enabled and m.emission == VineStation.FRUIT:
			amber = true
	assert_true(amber)


func test_the_magas_standard_rolls_up_while_locked() -> void:
	var holder := Node3D.new()
	add_child_autofree(holder)
	var st := HeroStation.make(holder, Vector3.ZERO)
	assert_true(st.rolls["maga"].visible)
	assert_false(st.emblems["maga"].visible)
	assert_true(st.emblems["warrior"].visible, "the lion always shows")
	var closed: float = st.cloths["maga"].scale.y
	var d := SaveData.defaults()
	d.wins = 1
	st.refresh(d)
	assert_false(st.rolls["maga"].visible)
	assert_true(st.emblems["maga"].visible)
	assert_gt(st.cloths["maga"].scale.y, closed * 3.0, "unrolled")
