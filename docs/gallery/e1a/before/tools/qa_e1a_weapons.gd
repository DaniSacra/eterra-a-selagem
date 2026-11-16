extends SceneTree
## QA (E1a baseline): renders one enemy alone, close, from the game's camera angle, at the clip times the game would show
## on consecutive 30 fps frames (the same CrowdRenderer.add as Horde.render), one PNG per frame.
## godot --path <project> -s C:/Users/danie/tools/e1a_lab/strip.gd -- <out_dir>
## Each job: id, anim, clip seconds per real second (Horde.clip_rate for walk, 1 for hit, 1.3 for death), frames.
const IDS := ["skeleton", "runner", "mage", "archer", "guard", "priest", "knight", "priest_elder", "morvath"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "C:/Users/danie/tools/e1a_lab/out"
	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.06, 0.07, 0.09)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.3, 0.45, 0.5)
	e.ambient_light_energy = 0.65
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.25
	e.glow_enabled = true
	e.glow_hdr_threshold = 1.1
	e.glow_intensity = 0.45
	env.environment = e
	world.add_child(env)
	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-50, 150, 0)
	moon.light_color = Color(0.5, 0.75, 0.85)
	moon.light_energy = 0.35
	world.add_child(moon)
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(80, 30)
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(0.16, 0.15, 0.18)
	plane.material = fm
	floor.mesh = plane
	world.add_child(floor)
	RenderingServer.global_shader_parameter_set(&"hero_pos", Vector3(0, 0, 40))
	var CR: GDScript = load("res://scripts/render/crowd_renderer.gd")
	var renderer = CR.new()
	world.add_child(renderer)
	var cam := Camera3D.new()
	world.add_child(cam)
	for id in IDS:
		var d = load("res://data/enemies/%s.tres" % id)
		renderer.register(d)
		var m = renderer.model_of(d)
		var h: float = m.height * d.size
		cam.fov = 24.0
		for view in ["front", "side", "game"]:
			var yaw := 0.0 if view == "front" else (PI * 0.5 if view == "side" else 0.7)
			var dist := h * 2.6
			if view == "game":
				cam.look_at_from_position(Vector3(0, h * 0.55 + dist * 0.5, dist * 0.866), Vector3(0, h * 0.55, 0), Vector3.UP)
			else:
				cam.look_at_from_position(Vector3(0, h * 0.6, dist), Vector3(0, h * 0.55, 0), Vector3.UP)
			renderer.begin()
			renderer.add(d, &"idle", 0.0, Vector3.ZERO, yaw, CR.state(0.0, false, false))
			renderer.commit()
			for f in 3:
				await process_frame
			root.get_viewport().get_texture().get_image().save_png("%s/weapon_%s_%s.png" % [out, id, view])
	quit()
