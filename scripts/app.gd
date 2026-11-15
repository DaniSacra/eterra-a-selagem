class_name App
extends RefCounted
## Applies the saved options to the window and the audio buses.

const WINDOW_SIZES: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]


static func window_size() -> Vector2i:
	return WINDOW_SIZES[clampi(int(Save.option("scale")), 1, WINDOW_SIZES.size()) - 1]


static func apply_options() -> void:
	if DisplayServer.get_name() != "headless" and not OS.has_feature("mobile") and not OS.has_feature("web"):
		var full: bool = Save.option("fullscreen")
		var win := Engine.get_main_loop().root as Window
		var want := Window.MODE_FULLSCREEN if full else Window.MODE_WINDOWED
		if win.mode != want:
			win.mode = want
		if not full:
			var size := window_size()
			if win.size != size and not Dev.has("shot") and not Dev.has("frames"):
				win.size = size
				win.move_to_center()
	Audio.apply_volumes()
