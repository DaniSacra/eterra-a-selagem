class_name App
extends RefCounted
## Applies the saved options to the window and the audio buses.


static func apply_options() -> void:
	if DisplayServer.get_name() != "headless" and not OS.has_feature("mobile"):
		var full: bool = Save.option("fullscreen")
		var win := Engine.get_main_loop().root as Window
		var want := Window.MODE_FULLSCREEN if full else Window.MODE_WINDOWED
		if win.mode != want:
			win.mode = want
		if not full:
			var size := Vector2i(320, 180) * int(Save.option("scale"))
			if win.size != size and not Dev.has("shot"):
				win.size = size
	Audio.apply_volumes()
