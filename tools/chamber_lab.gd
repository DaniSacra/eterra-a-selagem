extends SceneTree
## The Chamber of the Seal on its own (BossChamber, cycle C11), seen through the game's camera, with the game's air
## and glow, to look at and capture it without the fight. On the real GPU (Forward+, as on Daniel's PC):
##   tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/chamber_lab.gd -- C:/out.png [options]
## (the browser's renderer: DRIVER=opengl3 tools/shot.sh is the game's; here pass --rendering-driver opengl3; on the CPU:
## xvfb-run -a ~/tools/godot/godot --path . --resolution 1920x1080 -s tools/chamber_lab.gd -- out.png ...).
## Options after the output:
##   --state=normal|prep|ritual|final|victory  the seal's state (SealLook), --t=seconds into it (default 1.0)
##   --phase=1..4      Morvath's phase (the crack's length; final and victory set 4)
##   --hero            the Explorer standing at the mouth of the stairs (BossChamber.HERO_SPAWN), --hero-at=x,z elsewhere
##   --boss            Morvath standing on the seal (BOSS_SPAWN), still
##   --veil            the veil across the mouth of the stairs
##   --showcase        the reference painting's frame (BossChamber.SHOWCASE_DIST, SHOWCASE_PITCH)
##   --cam-at=x,z      the camera looks at this floor point; --cam-dist=, --cam-pitch= as in the game
##   --hall            the catacomb hall (the old boss room, CatacombHall) instead, for comparison
##   --wait=seconds    before the capture (default 1.5); --measure=seconds: frame times over that long after it,
##                     printed as "FRAMES n=.. mean_ms=.. p50=.. p90=.. fps=.." (vsync off)
##   --compat          the browser's exposure and ambient (Game.COMPAT_*), with --rendering-driver opengl3

var opts := {}
# untyped on purpose: a -s script compiles before the autoloads exist, so it cannot name the classes that use them
var G: Variant
var CH: Variant


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var out := "chamber.png"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--"):
			var kv := a.trim_prefix("--").split("=")
			opts[kv[0]] = kv[1] if kv.size() > 1 else "1"
		else:
			out = a
	G = load("res://scripts/game/game.gd")
	CH = load("res://scripts/game/boss_chamber.gd")
	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	var e := _environment()
	env.environment = e
	world.add_child(env)
	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-50, 150, 0)
	moon.light_color = Color(0.5, 0.75, 0.85)
	moon.light_energy = 0.35
	moon.shadow_enabled = true
	moon.directional_shadow_max_distance = 90.0
	world.add_child(moon)
	var chamber: Variant = null
	var target: Vector2 = CH.CAM_TARGET
	if opts.has("hall"):
		var arena: Variant = load("res://scripts/game/arena.gd").new()
		world.add_child(arena)
		var layout := RoomLayout.new()
		layout.half = Vector2(16, 15)
		layout.platform = true
		arena.build(layout, 1)
		target = Vector2(arena.showcase.x, arena.showcase.z)
	else:
		chamber = CH.new()
		world.add_child(chamber)
		chamber.build()
		CH.dress(e, moon)
		if opts.has("compat"):
			e.ambient_light_energy = CH.AMBIENT_ENERGY * G.COMPAT_AMBIENT / G.AMBIENT_ENERGY
		if opts.has("phase"):
			chamber.set_phase(int(opts.phase))
			chamber.seal.crack_grow = float(opts.phase)
		if opts.has("state"):
			chamber.set_seal_state(StringName(opts.state), float(opts.get("t", "1.0")))
		chamber.set_veil(opts.has("veil"), true)
	RenderingServer.global_shader_parameter_set(&"hero_pos", Vector3(0, -1000, 0))
	RenderingServer.global_shader_parameter_set(&"boss_pos", CH.BOSS_FAR)
	if opts.has("hero") or opts.has("hero-at"):
		var hero_at: Vector2 = CH.HERO_SPAWN
		if opts.has("hero-at"):
			var xz: PackedStringArray = str(opts["hero-at"]).split(",")
			hero_at = Vector2(float(xz[0]), float(xz[1]))
		var made := HeroBody.make()
		var hero: Node3D = made[0]
		world.add_child(hero)
		hero.position = Vector3(hero_at.x, 0, hero_at.y)
		hero.rotation.y = atan2(CH.HERO_FACING.x, CH.HERO_FACING.y)
		(made[1] as AnimationPlayer).play(&"Idle")
		RenderingServer.global_shader_parameter_set(&"hero_pos", hero.position)
	var renderer: CrowdRenderer = null
	var boss_def: EnemyDef = null
	if opts.has("boss"):
		renderer = CrowdRenderer.new()
		world.add_child(renderer)
		boss_def = load("res://data/enemies/morvath.tres")
		renderer.register(boss_def)
		RenderingServer.global_shader_parameter_set(&"boss_pos", Vector3(CH.BOSS_SPAWN.x, 0, CH.BOSS_SPAWN.y))
	var cam := Camera3D.new()
	world.add_child(cam)
	cam.make_current()
	var feel := Feel.live()
	cam.fov = float(opts.get("cam-fov", str(feel.cam_fov)))
	var dist := float(opts.get("cam-dist", str(CH.SHOWCASE_DIST if opts.has("showcase") else (G.SHOWCASE_DISTANCE if opts.has("hall") else feel.cam_distance))))
	var pitch := float(opts.get("cam-pitch", str(CH.SHOWCASE_PITCH if opts.has("showcase") else feel.cam_pitch)))
	if opts.has("cam-at"):
		var c: PackedStringArray = str(opts["cam-at"]).split(",")
		target = Vector2(float(c[0]), float(c[1]))
	var look := Vector3(target.x, 0, target.y)
	cam.far = 160.0
	cam.look_at_from_position(look + Feel.cam_offset_of(dist, pitch, feel.cam_yaw), look, Vector3.UP)
	var clock := 0.0
	var wait := float(opts.get("wait", "1.5"))
	var start := Time.get_ticks_msec()
	while (Time.get_ticks_msec() - start) / 1000.0 < wait:
		await process_frame
		clock += 1.0 / 60.0
		_boss(renderer, boss_def, clock)
	root.get_viewport().get_texture().get_image().save_png(out)
	print("saved %s" % out)
	if opts.has("measure"):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 0
		var times: Array[float] = []
		var last := Time.get_ticks_usec()
		var until := Time.get_ticks_msec() + int(float(opts.measure) * 1000.0)
		while Time.get_ticks_msec() < until:
			await process_frame
			_boss(renderer, boss_def, clock)
			var now := Time.get_ticks_usec()
			times.append((now - last) / 1000.0)
			last = now
		times.sort()
		var sum := 0.0
		for t in times:
			sum += t
		var mean := sum / maxf(times.size(), 1.0)
		print("FRAMES n=%d mean_ms=%.2f p50=%.2f p90=%.2f fps=%.1f" % [times.size(), mean, times[times.size() / 2], times[int(times.size() * 0.9)], 1000.0 / mean])
	quit()


## Morvath standing on the seal, his idle clip running.
func _boss(renderer: CrowdRenderer, d: EnemyDef, t: float) -> void:
	if renderer == null:
		return
	renderer.begin()
	var at: Vector2 = CH.BOSS_SPAWN
	renderer.add(d, &"idle", fmod(t, 2.0), Vector3(at.x, 0, at.y), atan2(CH.BOSS_FACING.x, CH.BOSS_FACING.y), CrowdRenderer.state(0.0, false, false))
	renderer.commit()


## The game's air (Game._build_world, Forward+), so the chamber is seen as in the fight.
func _environment() -> Environment:
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = G.SKY
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = G.AMBIENT
	e.ambient_light_energy = G.AMBIENT_ENERGY
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = G.EXPOSURE
	e.glow_enabled = true
	e.glow_intensity = G.GLOW_INTENSITY
	e.glow_strength = 1.0
	e.glow_bloom = 0.03
	e.glow_hdr_threshold = G.GLOW_THRESHOLD
	e.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	for i in 7:
		e.set_glow_level(i, G.GLOW_LEVELS[i])
	e.fog_enabled = true
	e.fog_mode = Environment.FOG_MODE_DEPTH
	e.fog_light_color = G.FOG
	e.fog_depth_begin = G.FOG_BEGIN
	e.fog_depth_end = G.FOG_END
	e.fog_depth_curve = 1.0
	e.fog_height = G.FOG_HEIGHT
	e.fog_height_density = G.FOG_HEIGHT_DENSITY
	e.fog_aerial_perspective = 0.2
	e.volumetric_fog_enabled = true
	e.volumetric_fog_density = G.VOLUMETRIC_DENSITY
	e.volumetric_fog_albedo = Color(0.7, 0.72, 0.78)
	e.volumetric_fog_emission = Color.BLACK
	e.volumetric_fog_gi_inject = 0.0
	e.volumetric_fog_length = 90.0
	e.volumetric_fog_ambient_inject = 0.0
	e.ssao_enabled = true
	e.ssao_radius = G.SSAO_RADIUS
	e.ssao_intensity = G.SSAO_INTENSITY
	e.ssao_light_affect = G.SSAO_LIGHT_AFFECT
	e.ssr_enabled = true
	e.ssr_max_steps = 48
	e.adjustment_enabled = true
	e.adjustment_contrast = G.ADJUST_CONTRAST
	e.adjustment_saturation = G.ADJUST_SATURATION
	if RenderingServer.get_current_rendering_method() == "gl_compatibility" or opts.has("compat"):
		e.tonemap_exposure = G.COMPAT_EXPOSURE
		e.ambient_light_energy = G.COMPAT_AMBIENT
	return e
