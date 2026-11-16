extends SceneTree
## Strips of the enemies walking as the game draws them (CrowdRenderer, their EnemyDef), each one alone crossing a
## checkered floor (0.5 m squares) at its own speed, its walk at Horde.walk_rate, seen from the game's 30 degree
## pitch from its side, the camera following: a planted foot that slides moves over the squares. 24 frames at 30 FPS
## per figure, in one sheet of 8 x 3 (frame 0 top left), plus one PNG per frame.
## tools/gpu.sh run --rendering-driver vulkan --resolution 640x640 -s tools/walk_strip.gd -- C:/out_dir [ids...]
## (or xvfb-run -a ~/tools/godot/godot --path . ... on the CPU). Writes <out_dir>/<id>_walk.png and <id>_walk_NN.png.

const IDS: Array[String] = ["guard", "knight", "morvath", "mage", "archer"]
const FRAMES := 24
const COLS := 8
const FPS := 30.0
const SQUARE := 0.5


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := Array(OS.get_cmdline_user_args())
	var out: String = args.pop_front() if not args.is_empty() else "walk_strips"
	var ids: Array = args if not args.is_empty() else IDS
	DirAccess.make_dir_recursive_absolute(out)
	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.06, 0.07, 0.09)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.45, 0.5, 0.55)
	e.ambient_light_energy = 0.8
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.25
	env.environment = e
	world.add_child(env)
	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-50, 150, 0)
	moon.light_energy = 0.6
	world.add_child(moon)
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(200, 40)
	var fm := StandardMaterial3D.new()
	var checks := Image.create(2, 2, false, Image.FORMAT_RGB8)
	for p in [Vector2i(0, 0), Vector2i(1, 1)]:
		checks.set_pixelv(p, Color(0.3, 0.29, 0.31))
	for p in [Vector2i(1, 0), Vector2i(0, 1)]:
		checks.set_pixelv(p, Color(0.17, 0.16, 0.19))
	fm.albedo_texture = ImageTexture.create_from_image(checks)
	fm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	fm.uv1_scale = Vector3(plane.size.x / (2.0 * SQUARE), plane.size.y / (2.0 * SQUARE), 1)
	plane.material = fm
	floor.mesh = plane
	world.add_child(floor)
	RenderingServer.global_shader_parameter_set(&"hero_pos", Vector3(0, 0, 400))
	var renderer: Node3D = (load("res://scripts/render/crowd_renderer.gd") as GDScript).new()
	world.add_child(renderer)
	var cam := Camera3D.new()
	world.add_child(cam)
	cam.fov = 24.0
	for id: String in ids:
		var d: EnemyDef = load("res://data/enemies/%s.tres" % id)
		renderer.register(d)
		var m: BakedModel = renderer.model_of(d)
		var h := m.height * d.size
		var ground := float(m.ground_speed.get(&"walk", 0.0))
		# Horde.walk_rate (Horde needs the autoloads, which a -s script lacks)
		var rate := d.speed / (ground * d.size) if ground > 0.0 else clampf(d.speed / 2.3, 0.6, 1.6)
		var sheet: Image = null
		for k in FRAMES:
			var x := -d.speed * FRAMES / FPS * 0.5 + d.speed * k / FPS
			var dist := h * 3.2 + 2.0
			var look := Vector3(x, h * 0.4, 0)
			cam.look_at_from_position(look + Vector3(0, dist * 0.5, dist * 0.866), look, Vector3.UP)
			renderer.begin()
			renderer.add(d, &"walk", k / FPS * rate, Vector3(x, 0, 0), PI * 0.5, CrowdRenderer.state(0.0, false, false))
			renderer.commit()
			for f in 3:
				await process_frame
			var shot := root.get_viewport().get_texture().get_image()
			shot.convert(Image.FORMAT_RGB8)
			shot.save_png("%s/%s_walk_%02d.png" % [out, id, k])
			if sheet == null:
				sheet = Image.create(shot.get_width() * COLS, shot.get_height() * ceili(float(FRAMES) / COLS), false, Image.FORMAT_RGB8)
			sheet.blit_rect(shot, Rect2i(Vector2i.ZERO, shot.get_size()), Vector2i(k % COLS * shot.get_width(), k / COLS * shot.get_height()))
		sheet.save_png("%s/%s_walk.png" % [out, id])
		print("STRIP %s: %.2f m/s, walk at %.2fx, %d poses" % [id, d.speed, rate, m.frame_count(&"walk")])
	quit()
