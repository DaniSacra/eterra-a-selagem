extends SceneTree
## One arena of cycle C12 on its own (the stage's RoomLayout, Arena, its look), without characters, with what play
## sees drawn over the floor: the walking grid (NavGrid: free cells green, cut-off islands red), the floor's edges and
## holes, every obstacle's collision (orange: stops shots too; white: bodies only; grey: drawn only), the spawn zones
## (blue; the late ones paler), the doors' zones (gold), the box the camera's point keeps to (cyan) and the way in.
## On the real GPU (Forward+):
##   tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/arena_lab.gd -- C:/out.png --arena=crypt
## On the CPU: xvfb-run -a ~/tools/godot/godot --path . --resolution 1920x1080 -s tools/arena_lab.gd -- out.png --arena=rift
## Options after the output:
##   --arena=hall|crypt|rift|garden   which arena (default crypt); --variant=n (default 0); --doors=1..3 (default 3)
##   --arena=sanctuary|bridge|runes|trial|altar   E5's rooms: the stage's plan when it has one, else the lab's
##                    (tools/e5_layouts.gd, the spec's numbers)
##   --state=...      E5 states: runes armed (--state=arm, --state=fire, --state=quiet), altar lit (--state=after),
##                    trial chosen (--state=after); --breath=look lights door 0's breath with that arena's air
##   --measure=s      after the capture, s seconds of frames: prints FRAME cpu and gpu ms (median and worst)
##   --top            seen from straight above, the whole arena in the frame (orthographic); else the game's camera
##   --cam-at=x,z     the game's camera looks at this floor point (default: the arena's camera point or box middle)
##   --bare           the arena alone, without the overlays
##   --hazard=x,y,z   every SW-G7 hazard piece in that state (windup, strike, ember); --dist=m the camera's distance
##   --wait=seconds   before the capture (default 1.0)
##   --look=classic|stylized   the visual profile (VisualProfile; room redesign lot D): the room and the world's air in it

const STAGE := "res://data/stages/catacombs.tres"
const E5 := preload("res://tools/e5_layouts.gd")
## Height of the overlays over the floor.
const LIFT := 0.06

var opts := {}
# untyped on purpose: a -s script compiles before the autoloads exist, so it cannot name the classes that use them
var G: Variant


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var out := "arena.png"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--"):
			var kv := a.trim_prefix("--").split("=")
			opts[kv[0]] = kv[1] if kv.size() > 1 else "1"
		else:
			out = a
	G = load("res://scripts/game/game.gd")
	var stage: StageDef = load(STAGE)
	var layout: RoomLayout = stage.layouts[0]
	var want := StringName(str(opts.get("arena", "crypt")))
	var found := false
	for l in stage.layouts:
		if l.id == want:
			layout = l
			found = true
	if not found and E5.IDS.has(want):
		layout = E5.layout(want)
	layout = layout.variant(int(opts.get("variant", "0")))
	var vp: Variant = load("res://scripts/core/visual_profile.gd")
	if opts.has("look"):
		vp.set_look(vp.parse(str(opts["look"])))
	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = _environment()
	world.add_child(env)
	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-50, 150, 0)
	moon.light_color = Color(0.5, 0.75, 0.85)
	moon.light_energy = 0.35
	moon.shadow_enabled = true
	world.add_child(moon)
	load("res://scripts/game/room_mood.gd").own(env, moon)
	var arena: Variant = load("res://scripts/game/arena.gd").new()
	world.add_child(arena)
	arena.build(layout, int(opts.get("doors", "3")), 1406)
	if arena.look != null:
		# spec 0.5: at most 8 lights with shadows an arena (the moon is the world's)
		print("SHADOWED LIGHTS %d" % arena.look.shadowed)
	if arena.look != null:
		_state(arena.look)
	if not opts.has("bare"):
		world.add_child(_overlay(arena))
	var cam := Camera3D.new()
	world.add_child(cam)
	cam.make_current()
	cam.far = 200.0
	var b: Rect2 = arena.bounds()
	if opts.has("top"):
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		var view := root.get_visible_rect().size
		cam.size = maxf(b.size.y, b.size.x * view.y / maxf(view.x, 1.0)) + 4.0
		var c := b.get_center()
		cam.look_at_from_position(Vector3(c.x, 60.0, c.y + 0.001), Vector3(c.x, 0, c.y), Vector3.FORWARD)
	else:
		var feel := Feel.live()
		cam.fov = feel.cam_fov
		var target: Vector2 = arena.cam_target if arena.cam_reach > 0.0 else arena.middle
		if opts.has("cam-at"):
			var xz: PackedStringArray = str(opts["cam-at"]).split(",")
			target = Vector2(float(xz[0]), float(xz[1]))
		var look := Vector3(target.x, 0, target.y)
		cam.look_at_from_position(look + Feel.cam_offset_of(float(opts.get("dist", feel.cam_distance)), feel.cam_pitch, feel.cam_yaw), look, Vector3.UP)
	var start := Time.get_ticks_msec()
	while (Time.get_ticks_msec() - start) / 1000.0 < float(opts.get("wait", "1.0")):
		await process_frame
	root.get_viewport().get_texture().get_image().save_png(out)
	print("saved %s" % out)
	if opts.has("measure"):
		await _measure(float(opts["measure"]))
	quit()


## E5's states on the look (lab only): the runes' tiles armed or firing, the altar lit, the trial chosen, a door's breath.
func _state(look: Node) -> void:
	var state := str(opts.get("state", ""))
	if look.has_method("demo"):
		look.call("demo", state)
	if opts.has("breath"):
		look.call("breath", 0, StringName(str(opts["breath"])))
	if opts.has("hazard"):
		var v: PackedStringArray = str(opts["hazard"]).split(",")
		var s := Vector3(float(v[0]), float(v[1]), float(v[2]))
		for n in look.find_children("*", "HazardPiece", true, false):
			n.call("set_state", s, false, 1.0 if s == Vector3.ZERO else 0.0)


## Frames for `seconds`: the CPU's and the GPU's time of each (RenderingServer's measure), median and worst.
func _measure(seconds: float) -> void:
	var vp := root.get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	var cpu: Array[float] = []
	var gpu: Array[float] = []
	var start := Time.get_ticks_msec()
	while (Time.get_ticks_msec() - start) / 1000.0 < seconds:
		await process_frame
		cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(vp) + RenderingServer.get_frame_setup_time_cpu())
		gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(vp))
	cpu.sort()
	gpu.sort()
	if gpu.is_empty():
		return
	print("FRAME cpu %.2f ms (worst %.2f), gpu %.2f ms (worst %.2f), %d frames, draw calls %d" % [cpu[cpu.size() / 2], cpu[-1],
		gpu[gpu.size() / 2], gpu[-1], gpu.size(), RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)])


## Lines and cells over the floor: the grid, edges, obstacles, zones, camera box and the way in.
func _overlay(arena: Variant) -> Node3D:
	var node := Node3D.new()
	var cells := ImmediateMesh.new()
	var nav: NavGrid = arena.nav
	var sizes := nav.island_sizes()
	var home := nav.island[nav.nearest_free(arena.start)] if nav.nearest_free(arena.start) >= 0 else -1
	cells.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _unlit())
	var r := nav.cell * 0.4
	for i in nav.free.size():
		if nav.free[i] == 0:
			continue
		var c := nav.center(i)
		cells.surface_set_color(Color(0.2, 0.9, 0.35, 0.22) if nav.island[i] == home else Color(1.0, 0.2, 0.2, 0.6))
		for q: Vector2 in [Vector2(-r, -r), Vector2(r, -r), Vector2(r, r), Vector2(-r, -r), Vector2(r, r), Vector2(-r, r)]:
			cells.surface_add_vertex(Vector3(c.x + q.x, LIFT, c.y + q.y))
	cells.surface_end()
	node.add_child(_mesh(cells))
	var lines := ImmediateMesh.new()
	lines.surface_begin(Mesh.PRIMITIVE_LINES, _unlit())
	var shape: FloorShape = arena.shape()
	if shape.kind == FloorShape.Kind.POLY:
		var ends := shape.edges()
		for i in range(0, ends.size(), 2):
			_seg(lines, ends[i], ends[i + 1], Color(0.9, 0.9, 1.0))
	for o: ArenaObstacle in arena.layout.obstacles:
		var col := Color(1.0, 0.55, 0.15) if o.blocks_shots else (Color(1, 1, 1) if o.blocks_move else Color(0.5, 0.5, 0.5))
		_loop(lines, o.outline(), col)
	for z: Rect2 in arena.spawns:
		_loop(lines, FloorShape.box(z), Color(0.3, 0.55, 1.0))
	for z: Rect2 in arena.late_spawns:
		_loop(lines, FloorShape.box(z), Color(0.6, 0.75, 1.0))
	for z: Rect2 in arena.exit_zones:
		_loop(lines, FloorShape.box(z), Color(1.0, 0.8, 0.3))
	if arena.cam_bounds.has_area():
		_loop(lines, FloorShape.box(arena.cam_bounds), Color(0.3, 1.0, 1.0))
	var s: Vector2 = arena.start
	var f: Vector2 = arena.start_facing
	_seg(lines, s, s + f * 2.0, Color(1, 1, 1))
	_loop(lines, FloorShape.box(Rect2(s - Vector2(0.5, 0.5), Vector2(1, 1))), Color(1, 1, 1))
	lines.surface_end()
	node.add_child(_mesh(lines))
	print("ISLANDS %s (home %d)" % [sizes, home])
	return node


func _seg(m: ImmediateMesh, a: Vector2, b: Vector2, c: Color) -> void:
	m.surface_set_color(c)
	m.surface_add_vertex(Vector3(a.x, LIFT + 0.02, a.y))
	m.surface_set_color(c)
	m.surface_add_vertex(Vector3(b.x, LIFT + 0.02, b.y))


func _loop(m: ImmediateMesh, pts: PackedVector2Array, c: Color) -> void:
	for i in pts.size():
		_seg(m, pts[i], pts[(i + 1) % pts.size()], c)


func _mesh(m: ImmediateMesh) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


func _unlit() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	return mat


## The game's air, as the chamber lab sets it (Game._build_world).
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
	e.glow_hdr_threshold = G.GLOW_THRESHOLD
	return e
