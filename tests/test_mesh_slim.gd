extends GutTest
## MeshSlim (scripts/render/mesh_slim.gd): the heavy painted models made light for the crowd. Welding closes the
## seams, the simplifier keeps the skin, the new atlas carries the old painting.


## A ball whose top half is painted red and bottom half blue, every triangle with vertices of its own (all seams,
## like the Meshy models), each vertex skinned to bone 0 (top) or 1 (bottom).
func _ball() -> Array:
	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	sphere.radial_segments = 24
	sphere.rings = 12
	var src := sphere.get_mesh_arrays()
	var src_v: PackedVector3Array = src[Mesh.ARRAY_VERTEX]
	var src_n: PackedVector3Array = src[Mesh.ARRAY_NORMAL]
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var bones := PackedInt32Array()
	var weights := PackedFloat32Array()
	var index := PackedInt32Array()
	for i: int in src[Mesh.ARRAY_INDEX]:
		index.append(verts.size())
		verts.append(src_v[i])
		normals.append(src_n[i])
		# the painting: u by the side, v by the height (top of the image = top of the ball)
		uvs.append(Vector2(0.5, 0.5 - src_v[i].y * 0.45))
		bones.append_array([0 if src_v[i].y > 0.0 else 1, 0, 0, 0])
		weights.append_array([1.0, 0.0, 0.0, 0.0])
	var out := []
	out.resize(Mesh.ARRAY_MAX)
	out[Mesh.ARRAY_VERTEX] = verts
	out[Mesh.ARRAY_NORMAL] = normals
	out[Mesh.ARRAY_TEX_UV] = uvs
	out[Mesh.ARRAY_BONES] = bones
	out[Mesh.ARRAY_WEIGHTS] = weights
	out[Mesh.ARRAY_INDEX] = index
	return out


func _painting() -> Image:
	var img := Image.create_empty(16, 16, false, Image.FORMAT_RGB8)
	img.fill_rect(Rect2i(0, 0, 16, 8), Color.RED)
	img.fill_rect(Rect2i(0, 8, 16, 8), Color.BLUE)
	return img


func test_weld_closes_the_seams_and_keeps_the_skin() -> void:
	var ball := _ball()
	var welded := MeshSlim.weld(ball)
	var verts: PackedVector3Array = welded[Mesh.ARRAY_VERTEX]
	assert_lt(verts.size(), (ball[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3, "one vertex per position")
	var seen := {}
	for v in verts:
		assert_false(seen.has(v.snappedf(MeshSlim.WELD)), "no position twice")
		seen[v.snappedf(MeshSlim.WELD)] = true
	var bones: PackedInt32Array = welded[Mesh.ARRAY_BONES]
	assert_eq(bones.size(), verts.size() * 4, "four bones a vertex, as it came")
	for i in verts.size():
		if absf(verts[i].y) > 0.01:
			assert_eq(bones[i * 4], 0 if verts[i].y > 0.0 else 1, "each vertex keeps its bone")
	for i: int in welded[Mesh.ARRAY_INDEX]:
		assert_between(i, 0, verts.size() - 1)


func test_simplify_reaches_the_target_on_the_same_vertices() -> void:
	var welded := MeshSlim.weld(_ball())
	var before := MeshSlim.triangles(welded)
	var light := MeshSlim.simplify(welded, 120)
	assert_lt(MeshSlim.triangles(light), before / 2, "far fewer triangles")
	assert_between(MeshSlim.triangles(light), 80, 180, "about the target (the nearest level of the chain)")
	var verts: PackedVector3Array = light[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = light[Mesh.ARRAY_BONES]
	var used := {}
	for i: int in light[Mesh.ARRAY_INDEX]:
		used[i] = true
	assert_eq(used.size(), verts.size(), "no vertex left unused")
	for i in verts.size():
		assert_almost_eq(verts[i].length(), 1.0, 0.001, "still a vertex of the ball")
		if absf(verts[i].y) > 0.01:
			assert_eq(bones[i * 4], 0 if verts[i].y > 0.0 else 1, "with its own bone")
	assert_eq(MeshSlim.triangles(MeshSlim.simplify(welded, before + 10)), before, "already light: untouched")


func test_smooth_normals_point_out() -> void:
	var smooth := MeshSlim.smooth(MeshSlim.weld(_ball()))
	var verts: PackedVector3Array = smooth[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = smooth[Mesh.ARRAY_NORMAL]
	for i in verts.size():
		assert_gt(normals[i].dot(verts[i]), 0.9, "outward")


func test_slim_carries_the_painting_to_the_new_atlas() -> void:
	var out := MeshSlim.slim(_ball(), _painting(), 200, 128)
	assert_eq(out.size(), 2, "arrays and image")
	var arrays: Array = out[0]
	var image: Image = out[1]
	assert_eq(image.get_size(), Vector2i(128, 128))
	assert_between(MeshSlim.triangles(arrays), 130, 300)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var index: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	assert_eq(uvs.size(), verts.size())
	assert_eq((arrays[Mesh.ARRAY_BONES] as PackedInt32Array).size(), verts.size() * 4, "the skin goes through the unwrap")
	# the middle of every triangle well inside one half shows that half's colour
	var checked := 0
	for t in range(0, index.size(), 3):
		var p := (verts[index[t]] + verts[index[t + 1]] + verts[index[t + 2]]) / 3.0
		if absf(p.y) < 0.35:
			continue
		var uv := (uvs[index[t]] + uvs[index[t + 1]] + uvs[index[t + 2]]) / 3.0
		assert_between(uv.x, 0.0, 1.0)
		assert_between(uv.y, 0.0, 1.0)
		var c := image.get_pixel(clampi(int(uv.x * 128), 0, 127), clampi(int(uv.y * 128), 0, 127))
		if p.y > 0.0:
			assert_true(c.r > 0.8 and c.b < 0.2, "red on top, got %s at %s" % [c, p])
		else:
			assert_true(c.b > 0.8 and c.r < 0.2, "blue below, got %s at %s" % [c, p])
		checked += 1
	assert_gt(checked, 40)
	# no texel is left empty (black): the charts bleed into the gaps
	for y in range(0, 128, 8):
		for x in range(0, 128, 8):
			assert_gt(image.get_pixel(x, y).get_luminance(), 0.02, "painted or bled")
