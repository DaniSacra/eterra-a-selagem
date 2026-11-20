extends SceneTree
## Fatia 1 (RJ-1) evidence for the technical-artist's part: the four angels' seals (AngelSeal) and the Emeth at each
## rank of Temperar (emeth.gdshader temper, EmethSword.set_temper).
##   tools/gpu.sh run --rendering-driver vulkan --resolution 1600x900 -s tools/rj1_lab.gd -- --lab-out=C:/x/rj1 [--look=stylized]
## Writes <lab-out>_seals.png (the seals at 24, 46, 96 and 140 px on ink and on the book's paper, lit and unlit) and
## <lab-out>_emeth_<look>.png (the blade at temper 0, 1, 2, 1.5 in the world's air, the run's light). Nothing ships.

const FAMILIES: Array[Boon.Family] = [Boon.Family.CHAMA, Boon.Family.GEADA, Boon.Family.LUZ, Boon.Family.VIGILIA]
const SIZES: Array[float] = [24.0, 46.0, 96.0, 140.0]
const PAPER := Color(0.83, 0.76, 0.62)
const RANKS: Array[float] = [0.0, 1.0, 2.0, 1.5]

var _out := ""


func _initialize() -> void:
	create_timer(60.0).timeout.connect(quit)
	_run.call_deferred()


func _run() -> void:
	_out = Dev.arg("lab-out", "rj1")
	var styled := Dev.arg("look", "classic") == "stylized"
	RenderingServer.global_shader_parameter_set(&"art_style", 1.0 if styled else 0.0)
	await _seals()
	await _emeth("stylized" if styled else "classic")
	quit()


func _seals() -> void:
	var page := Control.new()
	page.size = root.size
	root.add_child(page)
	var w := float(root.size.x)
	var h := float(root.size.y)
	var ink := ColorRect.new()
	ink.color = Color(0.06, 0.05, 0.06)
	ink.size = Vector2(w, h * 0.62)
	page.add_child(ink)
	var paper := ColorRect.new()
	paper.color = PAPER
	paper.position = Vector2(0, h * 0.62)
	paper.size = Vector2(w, h * 0.38)
	page.add_child(paper)
	# on ink: each family a row of sizes
	var y := 16.0
	for f in FAMILIES:
		var x := 24.0
		for s in SIZES:
			var seal := AngelSeal.new().setup(f, s * 0.75)
			seal.position = Vector2(x, y)
			page.add_child(seal)
			x += s * 0.75 + 18.0
		var dim := AngelSeal.new().setup(f, 72.0, false)
		dim.position = Vector2(x + 30.0, y)
		page.add_child(dim)
		y += SIZES[3] * 0.75 + 6.0
		if y > h * 0.6 - 60.0:
			break
	# a second column: the four at 168 on ink, side by side (the encounter's pair is two of these)
	var x2 := w * 0.5
	for i in FAMILIES.size():
		var big := AngelSeal.new().setup(FAMILIES[i], 168.0)
		big.position = Vector2(x2 + (i % 2) * 190.0, 30.0 + (i / 2) * 200.0)
		page.add_child(big)
	# on the book's paper: the four at 112 and 72
	var x3 := 24.0
	for f in FAMILIES:
		for s: float in [112.0, 72.0]:
			var seal := AngelSeal.new().setup(f, s)
			seal.position = Vector2(x3, h * 0.62 + 30.0 + (112.0 - s) * 0.5)
			page.add_child(seal)
			x3 += s + 16.0
		x3 += 30.0
	await _shot("seals")
	page.queue_free()
	await process_frame


func _emeth(look: String) -> void:
	var world := Node3D.new()
	root.add_child(world)
	# the run's tone map and glow (WorldAir's numbers; WorldAir itself needs the Save autoload, absent under -s)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.05, 0.07, 0.08)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.45, 0.52, 0.56)
	e.ambient_light_energy = 0.6
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.25
	e.glow_enabled = true
	e.glow_hdr_threshold = 1.3
	e.glow_intensity = 0.8
	env.environment = e
	world.add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-40, 30, 0)
	key.light_color = Color(1.0, 0.9, 0.78)
	key.light_energy = 1.2
	world.add_child(key)
	var cam := Camera3D.new()
	cam.fov = 30.0
	cam.position = Vector3(0, 0.8, 3.6)
	world.add_child(cam)
	cam.look_at(Vector3(0, 0.75, 0))
	cam.current = true
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(8, 8)
	floor.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.14, 0.13, 0.13)
	floor.material_override = mat
	floor.position.y = -0.3
	world.add_child(floor)
	for i in RANKS.size():
		var sword := EmethSword.make()
		sword.position = Vector3((i - 1.5) * 0.7, 0.0, 0.0)
		sword.rotation = Vector3(0, 0, 0)
		world.add_child(sword)
		var blade := (sword.get_node("Blade") as MeshInstance3D).material_override as ShaderMaterial
		EmethSword.set_temper(blade, RANKS[i])
	await create_timer(0.6).timeout
	await _shot("emeth_" + look)
	world.queue_free()
	await process_frame


func _shot(tag: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "%s_%s.png" % [_out, tag]
	root.get_texture().get_image().save_png(path)
	print("LAB saved ", path)
