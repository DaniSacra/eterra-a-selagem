extends SceneTree
## The hero (HeroBody) playing his clips, seen from the front and from the side, saved as frames to check poses
## and the sword grip:
## xvfb-run -a ~/tools/godot/godot --path . --rendering-driver opengl3 --resolution 960x540 -s tools/pose_lab.gd -- out_prefix [clip ...] [views=0,1,2]
## (or on the GPU: tools/gpu.sh run --resolution 960x540 -s tools/pose_lab.gd -- C:/.../prefix [clip ...])
## Views: 0 from the front, 1 from his right side, 2 from his right side 30 degrees from above (as the game's camera
## sees him running across the screen). Default 0,1. Frames: <prefix>_<clip>_<view>_<i>.png.

const SAMPLES := 8

var _out := "pose"
var _clips: Array[StringName] = []
var _views: Array[int] = [0, 1]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	for i in range(1, args.size()):
		if args[i].begins_with("views="):
			_views.clear()
			for v in args[i].trim_prefix("views=").split(","):
				_views.append(int(v))
		else:
			_clips.append(StringName(args[i]))
	_run.call_deferred()


func _run() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.55, 0.6, 0.65)
	env.environment.ambient_light_color = Color(1, 1, 1)
	env.environment.ambient_light_energy = 0.6
	world.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	world.add_child(sun)
	var body := HeroBody.make()
	var hero: Node3D = body[0]
	var anim: AnimationPlayer = body[1]
	world.add_child(hero)
	var cam := Camera3D.new()
	world.add_child(cam)
	cam.fov = 40
	if _clips.is_empty():
		for a in anim.get_animation_list():
			_clips.append(a)
	for a in _clips:
		if not anim.has_animation(a):
			print("missing ", a)
			continue
		var length := anim.get_animation(a).length
		for view in _views:
			# front, from the hero's right side, from his right side and above
			cam.position = [Vector3(0, 1.8, 7.0), Vector3(-7.0, 1.8, 0.01), Vector3(-7.0, 1.2 + 7.0 * tan(deg_to_rad(30.0)), 0.01)][view]
			cam.look_at(Vector3(0, 1.2, 0))
			for i in SAMPLES:
				anim.play(a)
				anim.seek(length * i / float(SAMPLES - 1), true)
				anim.pause()
				await process_frame
				await process_frame
				root.get_viewport().get_texture().get_image().save_png("%s_%s_%d_%d.png" % [_out, a, view, i])
	quit()
