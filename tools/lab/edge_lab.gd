extends Node
## The body of tools/edge_lab.gd (run that one).

const PIECES := [&"broken_pillar", &"broken_arch", &"rubble", &"root_curtain", &"ivy", &"chain_weight"]


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := PackedStringArray()
	var opts := {}
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--"):
			var kv := a.trim_prefix("--").split("=")
			opts[kv[0]] = kv[1] if kv.size() > 1 else "1"
		else:
			args.append(a)
	var out: String = args[0] if args.size() > 0 else "edge"
	var look := str(opts.get("look", "classic"))
	VisualProfile.set_look(VisualProfile.parse(look))
	var world := Node3D.new()
	get_tree().root.add_child(world)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.05, 0.06, 0.08)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.55, 0.58, 0.65)
	e.ambient_light_energy = 0.7
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.25
	env.environment = e
	world.add_child(env)
	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-50, 150, 0)
	moon.light_energy = 0.9
	moon.shadow_enabled = true
	world.add_child(moon)
	var fire := OmniLight3D.new()
	fire.position = Vector3(0, 2.5, 2)
	fire.light_color = Color(1.0, 0.6, 0.3)
	fire.light_energy = 2.0
	fire.omni_range = 9.0
	world.add_child(fire)
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(60, 60)
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(0.3, 0.29, 0.3)
	plane.material = fm
	floor.mesh = plane
	world.add_child(floor)
	var hero := Vector2(99, 99)
	if opts.has("hero"):
		hero = Vector2(float(str(opts.hero).get_slice(",", 0)), float(str(opts.hero).get_slice(",", 1)))
	RenderingServer.global_shader_parameter_set(&"hero_pos", Vector3(hero.x, 0, hero.y))
	RenderingServer.global_shader_parameter_set(&"boss_pos", Vector3(0, 0, 400))
	var cam := Camera3D.new()
	world.add_child(cam)
	cam.fov = 24.0
	var yaw := deg_to_rad(35.0)
	var pitch := deg_to_rad(30.0)
	var look_at := Vector3(0, 0, 0)
	var back := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * 54.0
	cam.look_at_from_position(look_at + back, look_at, Vector3.UP)
	var holder := Node3D.new()
	world.add_child(holder)
	var kit := ArenaKit.new(holder, 7)
	var edge := EdgeKit.new(kit)
	await _settle()
	var calls := _calls()
	print("EDGE floor only: %d draw calls" % calls)
	var tris_before := _tris(holder)
	for p: StringName in PIECES:
		match p:
			&"broken_pillar": edge.broken_pillar(Vector3(-7, 0, 3), 0.55, 3.4, Vector2(1, 0.3))
			&"broken_arch": edge.broken_arch(Vector3(-2, 0, -6), Vector2(0, 1), 4.0, 3.2)
			&"rubble": edge.rubble(Vector3(5, 0, 5), 1.8)
			&"root_curtain": edge.root_curtain(Vector3(-1, 5.5, -9), 4.0, 3.5, Vector2(1, 0))
			&"ivy": edge.ivy(Vector3(5, 5.0, -8), 2.4, 3.0, Vector2(1, 0), Vector2(0, 1))
			&"chain_weight":
				edge.chain_weight(Vector3(8, 7.0, -2), 4.5, 1.0)
				edge.chain_weight(Vector3(10, 6.5, 5), 0.0, 1.0, Vector3(14, 6.5, 5), 0.9)
		await _settle()
		var now := _calls()
		var tris := _tris(holder)
		print("EDGE %s: %d triangles, +%d draw calls" % [p, tris - tris_before, now - calls])
		calls = now
		tris_before = tris
	if look == "stylized":
		kit.paint_look()
	kit.masonry.merge()
	await _settle()
	print("EDGE all, merged: %d draw calls (%d over the floor)" % [_calls(), _calls() - 0])
	get_viewport().get_texture().get_image().save_png("%s_%s.png" % [out, look])
	get_tree().quit()


func _settle() -> void:
	for i in 4:
		await RenderingServer.frame_post_draw


func _calls() -> int:
	return RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)


func _tris(n: Node) -> int:
	var t := 0
	for c in n.find_children("*", "GeometryInstance3D", true, false):
		if c is MeshInstance3D and (c as MeshInstance3D).mesh:
			var mesh := (c as MeshInstance3D).mesh
			for s in mesh.get_surface_count():
				var arr := mesh.surface_get_arrays(s)
				var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX] if arr[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
				t += idx.size() / 3 if idx.size() > 0 else (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
		elif c is MultiMeshInstance3D:
			var mm := (c as MultiMeshInstance3D).multimesh
			var arr := mm.mesh.surface_get_arrays(0)
			var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX] if arr[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			t += (idx.size() / 3 if idx.size() > 0 else (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3) * mm.instance_count
	return t
