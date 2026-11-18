extends SceneTree
## A board of the first region's enemies as the game draws them (CrowdRenderer, their EnemyDef: model, palette,
## size), the hero beside them for scale, to set next to Daniel's sheet (docs/art/ref/inimigos_fase1.png):
## tools/gpu.sh run --rendering-driver vulkan --resolution 1672x941 -s tools/enemy_lab.gd -- C:/out_prefix [anim] [seconds] [ids...]
## (or xvfb-run -a ~/tools/godot/godot --path . ... on the CPU). Writes <out_prefix>_game.png (the game's camera
## angle), _front.png, _back.png and _side.png (the right side). With ids (EnemyDef ids), only those, in one row and closer; seconds as "a:b"
## spreads that row over the clip (the same id many times shows the clip as a strip); "clip" spreads it over the whole clip.
## Options anywhere after the prefix: --zoom=2 (the camera that much closer), --tell=0.8 (every figure as if that far
## into its wind-up: the swollen orb and the lights of EnemyFx), --loosed=0.03 (as if its attack was loosed that many
## seconds ago), --absorbed (a blow just landed on its armor), --broken (its armor is gone).
## Cycle 8: --bars (each one's life bar as the game draws it: 60% life with a pale trail to 85%, an elite with 70% of
## its armor, or none with --broken) and --warn=0.6 (the warning of its attack on the floor, that far filled, aimed
## down and to the right of the screen).

const ROW: Array[StringName] = [&"skeleton", &"runner", &"mage", &"archer", &"guard", &"priest", &"knight", &"priest_elder", &"morvath"]
const ELITES: Array[StringName] = [&"skeleton_elite", &"runner_elite", &"mage_elite", &"archer_elite", &"guard_elite", &"priest_elite"]
## Meters between two figures in a row.
const GAP := 3.2
const CLOSE_GAP := 2.4


func _initialize() -> void:
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
	var out: String = args[0] if args.size() > 0 else "enemies"
	var anim := StringName(args[1]) if args.size() > 1 else &"idle"
	# seconds into the clip; "a:b" spreads the row from a to b (the same id many times: the clip as a strip)
	var whole := args.size() > 2 and args[2] == "clip"
	var times := ("0" if whole else (args[2] if args.size() > 2 else "0")).split(":")
	var at_t := float(times[0])
	var to_t := float(times[1]) if times.size() > 1 else at_t
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
	var tells := EnemyFx.new()
	world.add_child(tells)
	var warnings := Node3D.new()
	world.add_child(warnings)
	var row: Array[StringName] = ROW
	var elites: Array[StringName] = ELITES
	if args.size() > 3:
		row = []
		elites = []
		for i in range(3, args.size()):
			row.append(StringName(args[i]))
	# a chosen row stands closer together
	var gap := GAP if elites.size() > 0 else CLOSE_GAP
	var width := (row.size() - 1) * gap
	# how much closer the camera comes when the row is short
	var zoom := maxf(width + 2.0 * gap, 6.0) / ((ROW.size() + 1) * GAP) / float(opts.get("zoom", "1"))
	hero.position = Vector3(-width * 0.5 - gap, 0, 0)
	RenderingServer.global_shader_parameter_set(&"hero_pos", Vector3(0, 0, 40))
	var defs: Array[EnemyDef] = []
	for id in row + elites:
		var d: EnemyDef = load("res://data/enemies/%s.tres" % id)
		renderer.register(d)
		defs.append(d)
	if whole and defs.size() > 0:
		# the last frame a little before the end, so a looping clip does not wrap back to its first pose
		to_t = renderer.model_of(defs[0]).duration(anim) * 0.97
	var cam := Camera3D.new()
	world.add_child(cam)
	for view: String in ["game", "front", "back", "side"]:
		renderer.begin()
		tells.begin()
		# side: turned to show the right hand
		var yaw := PI if view == "back" else (PI * 0.5 if view == "side" else 0.0)
		for i in defs.size():
			var back_row := 0 if i < row.size() else 1
			var k := i if back_row == 0 else i - row.size()
			var pos := Vector3(-width * 0.5 + k * gap, 0, -back_row * 5.0)
			var tell := float(opts.get("tell", "0"))
			if opts.has("bars"):
				var top := pos + Vector3(0, renderer.model_of(defs[i]).height * defs[i].size, 0)
				renderer.add_bar(defs[i], top, 0.6, 0.7 if defs[i].armor > 0.0 and not opts.has("broken") else 0.0, false, 0.85)
			if opts.has("warn") and view == "game":
				_warn(warnings, defs[i], Vector2(pos.x, pos.z), float(opts.warn))
			var state := CrowdRenderer.state(0.6 if opts.has("absorbed") else 0.0, false, false, 0.0, opts.has("absorbed"), tell, opts.has("broken"))
			renderer.add(defs[i], anim, lerpf(at_t, to_t, k / maxf(row.size() - 1, 1.0)) if back_row == 0 else at_t, pos, yaw, state)
			if opts.has("tell") or opts.has("loosed"):
				var foe := Enemy.new()
				foe.def = defs[i]
				foe.pos = Vector2(pos.x, pos.z)
				foe.dir = Vector2(sin(yaw), cos(yaw))
				foe.aim = foe.dir
				foe.look = fposmod(i * 0.618034, 1.0)
				if opts.has("loosed"):
					tells.loosed(foe, float(opts.loosed))
				else:
					tells.tell(foe, tell)
		renderer.commit()
		tells.commit()
		if view != "game":
			for w in warnings.get_children():
				w.queue_free()
		hero.rotation.y = yaw
		if view == "game":
			# the game's camera: 30 degrees over the floor, a narrow lens
			cam.fov = 24.0
			cam.look_at_from_position(Vector3(-gap * 0.5, 1.0 + 29.0 * zoom, (-2.5 if elites.size() > 0 else 0.0) + 54.5 * zoom), Vector3(-gap * 0.5, 1.0, -2.5 if elites.size() > 0 else 0.0), Vector3.UP)
		else:
			cam.fov = 22.0
			cam.look_at_from_position(Vector3(-gap * 0.5, 2.4 + 1.6 * zoom, 72.0 * zoom), Vector3(-gap * 0.5, 2.4 if elites.size() > 0 else 1.6, 0), Vector3.UP)
		for f in 4:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png("%s_%s.png" % [out, view])
	quit()


## The warning the figure's attack puts on the floor (Horde's numbers and Ground's look), filled to progress.
func _warn(parent: Node3D, d: EnemyDef, at: Vector2, progress: float) -> void:
	var aim := Vector2(0.45, 0.9).normalized()
	var B := EnemyDef.Behavior
	var S := GroundLook.Shape
	var node := GroundLook.new_node()
	parent.add_child(node)
	var y := 0.06 + parent.get_child_count() * 0.0005
	match d.behavior:
		B.RUNNER:
			# the pounce, drawn as an aim (QW-107)
			GroundLook.aim_warning(node, at, aim, d.lunge_speed * d.lunge_time + d.radius + 1.0, 1.3, y)
		B.ARCHER when d.shot_line:
			# the crossbow's aim (QW-107)
			GroundLook.aim_warning(node, at, aim, d.attack_range, 0.5, y)
		B.KNIGHT:
			GroundLook.warning(node, S.LINE, at, aim, d.lunge_speed * d.lunge_time + d.radius, 2.4, y)
		B.CONE:
			GroundLook.warning(node, S.ARC, at, aim, d.attack_range + 0.5, d.attack_width, y)
		B.PULSE:
			GroundLook.warning(node, S.CIRCLE, at, aim, d.attack_width, 0.0, y)
		_:
			GroundLook.warning(node, S.CIRCLE, at + aim * 3.0, aim, 2.3, 0.0, y)
	GroundLook.put(node.material_override as ShaderMaterial, &"progress", progress)
