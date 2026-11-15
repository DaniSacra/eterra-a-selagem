extends SceneTree
## Only the title backdrop (TitleBackdrop: the clean painting, the bands, the air), full screen, and a capture of it:
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/title_lab.gd -- C:/x/out.png [seconds] [bare|still|dim]
## `bare` leaves the air out (to measure its cost against a run with it); `still` saves a second capture one second
## later (<out>_b.png: the painted bodies must not differ); `dim` shows the darkened state behind a submenu.
## Prints LAB with the art rectangle, the screen size, the GPU time of the viewport and the mean time of a whole frame.
## To cost the air, run with --disable-vsync once as it is and once `bare`, and subtract the two frame_ms.

const BACKDROP := "res://scripts/ui/title_backdrop.gd"
const DEFAULT_SECONDS := 3.0
const WARM_UP := 1.0


func _initialize() -> void:
	# never hold the GPU if something breaks halfway
	create_timer(60.0).timeout.connect(quit)
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if args.size() > 0 else "title_backdrop.png"
	var seconds := float(args[1]) if args.size() > 1 else DEFAULT_SECONDS
	var mode := args[2] if args.size() > 2 else ""
	# untyped on purpose: a -s script compiles before the project's classes can be named
	var backdrop: Control = (load(BACKDROP) as Script).new()
	backdrop.set(&"deterministic", true)
	backdrop.set(&"atmosphere", mode != "bare")
	root.add_child(backdrop)
	if mode == "dim":
		backdrop.call(&"dim", true)
	var view := root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(view, true)
	var gpu := 0.0
	var frames := 0
	var measured := 0.0
	var left := seconds
	while left > 0.0:
		await process_frame
		var delta := root.get_process_delta_time()
		left -= delta
		# the first frames compile shaders and load the painting
		if seconds - left > WARM_UP:
			gpu += RenderingServer.viewport_get_measured_render_time_gpu(view)
			measured += delta
			frames += 1
	await _shot(out)
	if mode == "still":
		await create_timer(1.0).timeout
		await _shot(out.get_basename() + "_b.png")
	print("LAB screen=%s art=%s scale=%.4f frames=%d gpu_ms=%.3f frame_ms=%.3f" % [
		backdrop.size, backdrop.call(&"art_rect"), backdrop.call(&"art_scale"), frames,
		gpu / maxf(frames, 1.0), measured * 1000.0 / maxf(frames, 1.0)])
	quit()


func _shot(path: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
	print("LAB saved ", path)
