extends SceneTree
## The breakables' board (AT-Q2, docs/art/at_q0_breakables.md section 6): the nine pieces whole in a row on a plain
## floor of the room's stone, and the same nine broken behind them (their shards lying). Lab only.
## On the CPU: xvfb-run -a ~/tools/godot/godot --path . --resolution 1600x900 -s tools/break_lab.gd -- out.png [--room=hall]
## On the GPU: tools/gpu.sh run --resolution 1920x1080 -s tools/break_lab.gd -- C:/out.png --room=crypt

const FORMS := [BreakablePiece.Form.VASE, BreakablePiece.Form.URN, BreakablePiece.Form.OFFERING,
	BreakablePiece.Form.WATER, BreakablePiece.Form.CRATE, BreakablePiece.Form.PLANK, BreakablePiece.Form.BENCH,
	BreakablePiece.Form.BRANCH, BreakablePiece.Form.SAPLING]
const HEIGHTS := [0.7, 0.9, 0.45, 0.75, 0.8, 0.35, 0.6, 0.9, 0.45]
const STEP := 1.5


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if not args.is_empty() else "user://break_lab.png"
	var room := &"hall"
	for a in args:
		if a.begins_with("--room="):
			room = StringName(a.substr(7))
	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.05, 0.05, 0.06)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.5, 0.52, 0.56)
	env.environment.ambient_light_energy = 0.8
	world.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 30, 0)
	sun.shadow_enabled = true
	world.add_child(sun)
	var floor_ := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(20, 8)
	floor_.mesh = pm
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(0.36, 0.37, 0.4)
	floor_.material_override = fm
	floor_.position = Vector3(STEP * 4.0, 0, 1.0)
	world.add_child(floor_)
	var bf := load("res://scripts/game/break_floor.gd")
	for k in FORMS.size():
		for row in 2:
			var p := BreakablePiece.make(FORMS[k], Vector2(k * STEP, row * 2.2), HEIGHTS[k], 0)
			var color: Color = _color(bf, p.form, room)
			if row == 0:
				world.add_child(BreakableKit.build(p, color, room))
			else:
				BreakableKit.shatter(world, p, color, Vector3(0, 0, 1))
	var cam := Camera3D.new()
	world.add_child(cam)
	cam.fov = 30
	cam.look_at_from_position(Vector3(STEP * 4.0, 7.5, 11.0), Vector3(STEP * 4.0, 0.2, 1.1), Vector3.UP)
	cam.make_current()
	for f in 30:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(out)
	print("saved %s" % out)
	quit()


func _color(bf: Script, form: int, room: StringName) -> Color:
	var hsv: Vector3
	match Breakables.material_of(form):
		Breakables.Stuff.WOOD:
			hsv = bf.WOOD
		Breakables.Stuff.BRANCH:
			hsv = bf.SAPLING if form == BreakablePiece.Form.SAPLING else bf.BRANCH
		_:
			hsv = bf.CLAY.get(room, bf.CLAY[&""])
	return Color.from_hsv(hsv.x / 360.0, hsv.y, hsv.z)
