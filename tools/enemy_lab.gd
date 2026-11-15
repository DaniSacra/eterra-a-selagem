extends SceneTree
## A board of the first region's enemies as the game draws them (CrowdRenderer, their EnemyDef: model, palette,
## size), the hero beside them for scale, to set next to Daniel's sheet (docs/art/ref/inimigos_fase1.png):
## xvfb-run -a ~/tools/godot/godot --path . --rendering-driver vulkan --resolution 1672x941 -s tools/enemy_lab.gd -- out_prefix [anim] [seconds]
## Writes <out_prefix>_game.png (the game's camera angle), _front.png and _back.png.

const ROW: Array[StringName] = [&"skeleton", &"runner", &"mage", &"archer", &"guard", &"priest", &"knight", &"priest_elder", &"morvath"]
const ELITES: Array[StringName] = [&"skeleton_elite", &"runner_elite", &"mage_elite", &"archer_elite", &"guard_elite", &"priest_elite"]
## Meters between two figures in a row.
const GAP := 3.2


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "enemies"
	var anim := StringName(args[1]) if args.size() > 1 else &"idle"
	var at_t := float(args[2]) if args.size() > 2 else 0.0
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
	var hero: Node3D = HeroBody.make()[0]
	world.add_child(hero)
	var renderer := CrowdRenderer.new()
	world.add_child(renderer)
	var width := (ROW.size() - 1) * GAP
	hero.position = Vector3(-width * 0.5 - GAP, 0, 0)
	RenderingServer.global_shader_parameter_set(&"hero_pos", Vector3(0, 0, 40))
	var defs: Array[EnemyDef] = []
	for id in ROW + ELITES:
		var d: EnemyDef = load("res://data/enemies/%s.tres" % id)
		renderer.register(d)
		defs.append(d)
	var cam := Camera3D.new()
	world.add_child(cam)
	for view: String in ["game", "front", "back"]:
		renderer.begin()
		var yaw := PI if view == "back" else 0.0
		for i in defs.size():
			var row := 0 if i < ROW.size() else 1
			var k := i if row == 0 else i - ROW.size()
			var pos := Vector3(-width * 0.5 + k * GAP, 0, -row * 5.0)
			renderer.add(defs[i], anim, at_t, pos, yaw, Color(0, 0, 0, 0))
		renderer.commit()
		hero.rotation.y = yaw
		if view == "game":
			# the game's camera: 30 degrees over the floor, a narrow lens
			cam.fov = 24.0
			cam.look_at_from_position(Vector3(0, 30.0, 52.0), Vector3(0, 1.0, -2.5), Vector3.UP)
		else:
			cam.fov = 22.0
			cam.look_at_from_position(Vector3(0, 4.0, 72.0), Vector3(0, 2.4, 0), Vector3.UP)
		for f in 4:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png("%s_%s.png" % [out, view])
	quit()
