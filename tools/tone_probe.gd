extends SceneTree
## What an unshaded colour turns into on the screen: patches of known linear colours under the game's tone (exposure,
## filmic curve, glow, contrast and saturation, Game._build_world), seen from straight above, each printed with what
## ScreenTone predicts; the capture is then read back at the printed pixel. Checks the model the caps rest on.
## On the real GPU (Forward+):
##   tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/tone_probe.gd -- C:/out.png

const COLS := 8
const STEP := 3.0
const PATCH := 1.6

var G: Variant


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var out := "tone.png"
	for a in OS.get_cmdline_user_args():
		if not a.begins_with("--"):
			out = a
	G = load("res://scripts/game/game.gd")
	var colors: Array[Color] = []
	for g in [0.2, 0.4, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2]:
		colors.append(Color(g, g, g))
	for c in [Color(1, 0.45, 0.4), Color(0.55, 0.8, 1.0), Color(1.0, 0.85, 0.3), Color(0.8, 0.35, 0.3),
			Color(0.4, 0.6, 0.8), Color(0.7, 0.6, 0.2), Color(0.6, 0.25, 0.2), Color(0.3, 0.9, 0.5)]:
		colors.append(c)
	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color.BLACK
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
	e.adjustment_enabled = true
	e.adjustment_contrast = G.ADJUST_CONTRAST
	e.adjustment_saturation = G.ADJUST_SATURATION
	env.environment = e
	world.add_child(env)
	var cam := Camera3D.new()
	world.add_child(cam)
	cam.make_current()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	var rows := ceili(colors.size() / float(COLS))
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	cam.size = COLS * STEP
	var mid := Vector3((COLS - 1) * STEP * 0.5, 0, (rows - 1) * STEP * 0.5)
	cam.look_at_from_position(mid + Vector3(0, 30, 0.001), mid, Vector3.FORWARD)
	var quad := PlaneMesh.new()
	quad.size = Vector2(PATCH, PATCH)
	for i in colors.size():
		var mi := MeshInstance3D.new()
		mi.mesh = quad
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = colors[i]
		mi.material_override = m
		mi.position = Vector3((i % COLS) * STEP, 0, (i / COLS) * STEP)
		world.add_child(mi)
	for i in 3:
		await process_frame
	await create_timer(0.5).timeout
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(out)
	for i in colors.size():
		var p := cam.unproject_position(Vector3((i % COLS) * STEP, 0, (i / COLS) * STEP))
		p *= Vector2(img.get_size()) / root.get_visible_rect().size
		var got := img.get_pixelv(Vector2i(p))
		var want: Color = ScreenTone.of(colors[i])
		print("PATCH %d (%.2f %.2f %.2f) at %d,%d got %d %d %d model %d %d %d" % [i, colors[i].r, colors[i].g, colors[i].b,
			int(p.x), int(p.y), got.r8, got.g8, got.b8, want.r8, want.g8, want.b8])
	quit()
