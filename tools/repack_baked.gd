extends SceneTree
## F2: converts baked files in the old pose format (RGBAH positions, no bounds) to the current one (10 bits inside each
## vertex's box) without baking again: ~/tools/godot/godot --headless --path . -s tools/repack_baked.gd -- [ids]
## Files already converted are left alone. Normals are kept byte for byte; positions are what the old image decodes to.


func _init() -> void:
	var ids: Array[String] = []
	for a in OS.get_cmdline_user_args():
		ids.append(a)
	var dir := DirAccess.open("res://assets/baked")
	for f in dir.get_files():
		if f.get_extension() != "res" or (not ids.is_empty() and f.get_basename() not in ids):
			continue
		var path := "res://assets/baked/" + f
		var m: BakedModel = load(path)
		if m.bounds != null and m.uniques > 0:
			print("%s already converted" % f)
			continue
		var old_pos := m.positions
		var old_normals := m.normals
		var clips := {}
		for anim: StringName in m.first:
			var poses := []
			for k in m.frame_count(anim):
				var pv := PackedVector3Array()
				pv.resize(m.vertices)
				var base := (int(m.first[anim]) + k) * m.vertices
				for v in m.vertices:
					var c := old_pos.get_pixel((base + v) % BakedModel.WIDTH, (base + v) / BakedModel.WIDTH)
					pv[v] = Vector3(c.r, c.g, c.b)
				poses.append([pv, pv])
			clips[String(anim)] = poses
		m.pack(m.mesh, clips)
		m.normals = old_normals
		ResourceSaver.save(m, path, ResourceSaver.FLAG_COMPRESS)
		print("%s converted" % f)
	quit()
