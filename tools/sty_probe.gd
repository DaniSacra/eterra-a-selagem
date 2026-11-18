extends SceneTree
## Frame cost of the game itself (the boot scene with the usual game options), for the stylized proof (STY-06, STY-07):
## waits --probe-wait seconds, then measures --probe-for seconds of frames and prints the median and worst CPU and GPU
## time of each frame (RenderingServer's measure), the draw calls and the video memory in use, then quits.
##   tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/sty_probe.gd -- --nosave --bot \
##     --autopick --seed=5 --look=stylized [--paint-pass=1] [--quality=baixa] --probe-wait=6 --probe-for=6
## Run with --disable-vsync before -s for the GPU's own time without the screen's pace.

var _wait := 6.0
var _for := 6.0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--probe-wait="):
			_wait = float(a.get_slice("=", 1))
		elif a.begins_with("--probe-for="):
			_for = float(a.get_slice("=", 1))
	change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	_run.call_deferred()


func _run() -> void:
	var start := Time.get_ticks_msec()
	while (Time.get_ticks_msec() - start) / 1000.0 < _wait:
		await process_frame
	var vp := root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	var cpu: Array[float] = []
	var gpu: Array[float] = []
	var frames: Array[float] = []
	start = Time.get_ticks_msec()
	var last := Time.get_ticks_usec()
	while (Time.get_ticks_msec() - start) / 1000.0 < _for:
		await process_frame
		var now := Time.get_ticks_usec()
		frames.append((now - last) / 1000.0)
		last = now
		cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(vp) + RenderingServer.get_frame_setup_time_cpu())
		gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(vp))
	cpu.sort()
	gpu.sort()
	frames.sort()
	print("PROBE frame %.2f ms, cpu %.2f ms (worst %.2f), gpu %.2f ms (worst %.2f), %d frames, draw calls %d, video memory %.1f MB" % [
		frames[frames.size() / 2], cpu[cpu.size() / 2], cpu[-1], gpu[gpu.size() / 2], gpu[-1], gpu.size(),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1048576.0])
	quit()
