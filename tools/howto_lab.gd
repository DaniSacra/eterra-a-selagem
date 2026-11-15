extends SceneTree
## Capture of the "Como Jogar" screen over a dark backdrop, for UI review.
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/howto_lab.gd -- C:/x/howto.png [--moves]
## --moves: opens the combo list from it ("Golpes").

var _out := ""


func _initialize() -> void:
	# never hold the GPU if something breaks halfway
	create_timer(20.0).timeout.connect(quit)
	_run.call_deferred()


func _run() -> void:
	_out = "howto.png"
	for a in OS.get_cmdline_user_args():
		if not a.begins_with("--"):
			_out = a
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.04, 0.07)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	# untyped on purpose: a -s script compiles before the autoloads exist, so it cannot name the game's classes
	var screen: Control = (load("res://scripts/ui/how_to_screen.gd") as GDScript).new()
	root.add_child(screen)
	screen.call(&"open")
	if OS.get_cmdline_user_args().has("--moves"):
		await create_timer(0.3).timeout
		screen.call(&"_open_moves")
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(_out)
	print("LAB saved ", _out)
	quit()
