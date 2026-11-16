extends SceneTree
## QA (E1a AFTER; the baseline's script with the E1a timing: the walk at Horde.walk_rate, i.e. the enemy's speed over the
## baked ground speed (BakedModel.ground_speed) times its size; the hit with HitRecoil's drawn push, sideways on screen)
## QA (E1a baseline): renders one enemy alone, close, from the game's camera angle, at the clip times the game would show
## on consecutive 30 fps frames (the same CrowdRenderer.add as Horde.render), one PNG per frame.
## godot --path <project> -s C:/Users/danie/tools/e1a_lab/strip.gd -- <out_dir>
## Each job: id, anim, clip seconds per real second (Horde.clip_rate for walk, 1 for hit, 1.3 for death), frames.
const JOBS := [
	["skeleton", "walk", -1.0, 24],
	["skeleton", "hit", 1.0, 10],
	["skeleton", "death", 1.3, 40],
	["mage", "walk", -1.0, 24],
	["mage", "hit", 1.0, 10],
	["mage", "death", 1.3, 40],
	["guard", "walk", -1.0, 24],
	["guard", "hit", 1.0, 10],
	["guard", "death", 1.3, 40],
	["morvath", "walk", -1.0, 24],
	["morvath", "hit", 1.0, 10],
	["morvath", "death", 1.3, 40],
]


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
	var index := FileAccess.open(out + "/strip_index.txt", FileAccess.WRITE)
	for job in JOBS:
		var d = load("res://data/enemies/%s.tres" % job[0])
		renderer.register(d)
		var m = renderer.model_of(d)
		var h: float = m.height * d.size
		# the game's 30 degree pitch, a close narrow lens framed on the figure
		cam.fov = 24.0
		var dist := h * 4.2 + 3.0
		cam.look_at_from_position(Vector3(0, h * 0.5 + dist * 0.5, dist * 0.866), Vector3(0, h * 0.5, 0), Vector3.UP)
		var idx := PackedStringArray()
		var rate: float = job[2]
		if rate < 0.0:
			# Horde.walk_rate (the game's walk pace since E1a-2)
			var g: float = float(m.ground_speed.get(&"walk", 0.0))
			rate = d.speed / (g * maxf(d.size, 0.01)) if g > 0.0 else clampf(d.speed / 2.3, 0.6, 1.6)
		var HR: GDScript = load("res://scripts/core/hit_recoil.gd")
		for k in int(job[3]):
			var t: float = k / 30.0 * rate
			var at := Vector3.ZERO
			if job[1] == "hit":
				# Horde.render: HitRecoil.offset(recoil_t, heavy) along the blow (here to screen right)
				at = Vector3(1, 0, 0) * HR.offset(k / 30.0, d.heavy)
			renderer.begin()
			renderer.add(d, StringName(job[1]), t, at, 0.7, CR.state(0.0, false, false))
			renderer.commit()
			var bl: Vector3 = m.blend_at(StringName(job[1]), t)
			idx.append("%d>%d@%.2f%s" % [int(bl.x), int(bl.y), bl.z, (" x=%.3f" % at.x) if job[1] == "hit" else ""])
			for f in 3:
				await process_frame
			root.get_viewport().get_texture().get_image().save_png("%s/%s_%s_%02d.png" % [out, job[0], job[1], k])
		index.store_line("%s %s rate=%.4f ground=%.4f poses=%d blend=%s" % [job[0], job[1], rate, float(m.ground_speed.get(StringName(job[1]), 0.0)), m.frame_count(StringName(job[1])), ",".join(idx)])
	index.close()
	quit()
