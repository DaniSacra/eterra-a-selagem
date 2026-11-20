extends SceneTree
## The rewards' medallions side by side on their reliquaries (RewardGem), lit as a room, seen by the game's camera:
## gold, Prata Antiga, Fragmento de Memória, Bênção (Fatia 1, sistemas.md 3.4: compare the two materials with the
## coin and the enamel). On the GPU: tools/gpu.sh run -s tools/gem_lab.gd -- C:/out.png [--look=stylized] [--dist=14]
## --shafts: every reward under its RewardShaft (vfx_pass_spec.md 6.6, 5): Blessings of the four angels, pomegranate,
## heart, Magia, gold, Prata, Memória, Encanto, Salmo and the fountain's light, at --at seconds (default 2) after they
## came down (--shop=0.3 shows them at a shop's strength).

# RunMap.Reward GOLD, SILVER, MEMORY, BOON (a -s script compiles before the autoloads exist: nothing typed by the game's
# classes, they are loaded once the tree runs)
const REWARDS: Array[int] = [5, 8, 9, 1]
const STEP := 3.2
# with --shafts: [reward, angel family (-1 none, -2 the fountain)]
const SHAFTS := [[1, 0], [1, 1], [1, 2], [1, 3], [2, -1], [3, -1], [4, -1], [5, -1], [8, -1], [9, -1], [10, -1], [11, -1], [0, -2]]


var shafts := false
var at_s := 2.0
var shop := 1.0


func _initialize() -> void:
	var out := "gem_lab.png"
	var dist := 16.0
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--dist="):
			dist = float(a.substr(7))
		elif a == "--shafts":
			shafts = true
			dist = maxf(dist, 46.0)
		elif a.begins_with("--at="):
			at_s = float(a.substr(5))
		elif a.begins_with("--shop="):
			shop = float(a.substr(7))
		elif not a.begins_with("--"):
			out = a
	_build.call_deferred(out, dist)


func _build(out: String, dist: float) -> void:
	var gem: Variant = load("res://scripts/game/reward_gem.gd")
	var feel: Variant = load("res://scripts/core/feel.gd").live()
	var tone: Variant = load("res://scripts/core/screen_tone.gd")
	var root := Node3D.new()
	get_root().add_child(root)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.05, 0.05, 0.07)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.5, 0.5, 0.52)
	env.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment.tonemap_exposure = tone.EXPOSURE
	env.environment.glow_enabled = true
	root.add_child(env)
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(30, 30)
	floor.mesh = plane
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(0.3, 0.29, 0.27)
	floor.material_override = fm
	root.add_child(floor)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	sun.light_energy = 0.8
	root.add_child(sun)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 3.5, 2.5)
	lamp.light_color = Color(1.0, 0.8, 0.55)
	lamp.light_energy = 2.0
	lamp.omni_range = 9.0
	root.add_child(lamp)
	var a := deg_to_rad(feel.cam_yaw)
	var right := Vector2.RIGHT.rotated(-a)
	# the paladin far away (the shafts fall near him)
	RenderingServer.global_shader_parameter_set(&"hero_pos", Vector3(0, 0, 100))
	var list: Array = SHAFTS if shafts else REWARDS
	var shaft: Variant = load("res://scripts/game/reward_shaft.gd")
	for i in list.size():
		var spot := Node3D.new()
		var p := right * (i - (list.size() - 1) * 0.5) * STEP
		spot.position = Vector3(p.x, 0, p.y)
		root.add_child(spot)
		if not shafts:
			gem.make(spot, list[i], 0, Color.WHITE, 1)
			continue
		var r: int = list[i][0]
		var fam: int = list[i][1]
		if r != 0:
			gem.make(spot, r, 0, Color.WHITE, 1)
		var tint: Color = shaft.fountain_tint() if fam == -2 else shaft.tint_of(r, fam)
		var s: Variant = shaft.make(spot, spot.position, tint, shop)
		s.appear(0.0)
	var cam := Camera3D.new()
	root.add_child(cam)
	cam.fov = feel.cam_fov
	var off: Vector3 = load("res://scripts/core/feel.gd").cam_offset_of(dist, feel.cam_pitch, feel.cam_yaw)
	cam.look_at_from_position(Vector3(0, 1.2, 0) + off, Vector3(0, 1.2, 0), Vector3.UP)
	cam.make_current()
	for k in 20:
		await process_frame
	if shafts:
		await create_timer(at_s).timeout
	await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png(out)
	print("saved ", out)
	quit()
