class_name PoseBaker
extends RefCounted
## Skins a rigged model on the CPU at chosen times of its animations and keeps the result as plain meshes.
## The model must be inside the scene tree (the AnimationPlayer resolves its tracks there).


## Every mesh of the model (skinned parts, attached weapons) posed as it is right now, merged into one surface,
## in the space of the model's root.
static func snapshot(root: Node3D, skeleton: Skeleton3D, extra: Array[Dictionary] = []) -> ArrayMesh:
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var to_root := local_to(root, skeleton)
	var bone_globals: Array[Transform3D] = []
	for b in skeleton.get_bone_count():
		bone_globals.append(skeleton.get_bone_global_pose(b))
	for mi: MeshInstance3D in _meshes(skeleton):
		if not mi.visible or not _visible_in_tree(mi, skeleton):
			continue
		var arrays := mi.mesh.surface_get_arrays(0)
		if mi.skin != null and arrays[Mesh.ARRAY_BONES] != null:
			_add_skinned(arrays, mi.skin, skeleton, bone_globals, to_root, verts, normals, uvs, indices)
		else:
			var parent := mi.get_parent()
			var xf := to_root
			if parent is BoneAttachment3D:
				xf = to_root * bone_globals[skeleton.find_bone((parent as BoneAttachment3D).bone_name)] * mi.transform
			_add_rigid(arrays, xf, verts, normals, uvs, indices)
	# weapons that the model does not carry by itself: { mesh, bone, transform }
	for item in extra:
		var xf: Transform3D = to_root * bone_globals[skeleton.find_bone(item.bone)] * (item.get("transform", Transform3D()) as Transform3D)
		_add_rigid((item.mesh as Mesh).surface_get_arrays(0), xf, verts, normals, uvs, indices)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	# 16-bit positions, normals and UVs: the baked crowd is hundreds of frames, this halves it on disk and in memory
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, Mesh.ARRAY_FLAG_COMPRESS_ATTRIBUTES)
	return mesh


## Transform of a node relative to one of its ancestors, without needing the scene tree.
static func local_to(ancestor: Node, n: Node3D) -> Transform3D:
	var xf := Transform3D()
	var p: Node = n
	while p != null and p != ancestor:
		if p is Node3D:
			xf = (p as Node3D).transform * xf
		p = p.get_parent()
	return xf


static func _meshes(n: Node) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	for c in n.get_children():
		if c is MeshInstance3D:
			out.append(c)
		out.append_array(_meshes(c))
	return out


static func _visible_in_tree(n: Node, stop: Node) -> bool:
	var p := n
	while p != null and p != stop:
		if p is Node3D and not (p as Node3D).visible:
			return false
		p = p.get_parent()
	return true


static func _add_skinned(arrays: Array, skin: Skin, skeleton: Skeleton3D, bone_globals: Array[Transform3D], to_root: Transform3D,
		verts: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, indices: PackedInt32Array) -> void:
	var binds: Array[Transform3D] = []
	for i in skin.get_bind_count():
		var bone := skin.get_bind_bone(i)
		if bone < 0:
			bone = skeleton.find_bone(skin.get_bind_name(i))
		binds.append(to_root * bone_globals[bone] * skin.get_bind_pose(i))
	var src_v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var src_n: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	var per := bones.size() / src_v.size()
	var base := verts.size()
	for v in src_v.size():
		var p := Vector3.ZERO
		var nrm := Vector3.ZERO
		for k in per:
			var w := weights[v * per + k]
			if w <= 0.0:
				continue
			var xf := binds[bones[v * per + k]]
			p += xf * src_v[v] * w
			nrm += xf.basis * src_n[v] * w
		verts.append(p)
		normals.append(nrm.normalized())
	uvs.append_array(arrays[Mesh.ARRAY_TEX_UV])
	for i: int in arrays[Mesh.ARRAY_INDEX]:
		indices.append(base + i)


static func _add_rigid(arrays: Array, xf: Transform3D, verts: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, indices: PackedInt32Array) -> void:
	var base := verts.size()
	for p: Vector3 in arrays[Mesh.ARRAY_VERTEX]:
		verts.append(xf * p)
	for nrm: Vector3 in arrays[Mesh.ARRAY_NORMAL]:
		normals.append((xf.basis * nrm).normalized())
	uvs.append_array(arrays[Mesh.ARRAY_TEX_UV])
	for i: int in arrays[Mesh.ARRAY_INDEX]:
		indices.append(base + i)


static func find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n
	for c in n.get_children():
		var s := find_skeleton(c)
		if s:
			return s
	return null


static func find_player(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n
	for c in n.get_children():
		var p := find_player(c)
		if p:
			return p
	return null


## The albedo texture of the first textured surface of the model.
static func find_albedo(n: Node) -> Texture2D:
	if n is MeshInstance3D:
		var m := (n as MeshInstance3D).mesh.surface_get_material(0)
		if m is BaseMaterial3D and (m as BaseMaterial3D).albedo_texture:
			return (m as BaseMaterial3D).albedo_texture
	for c in n.get_children():
		var t := find_albedo(c)
		if t:
			return t
	return null
