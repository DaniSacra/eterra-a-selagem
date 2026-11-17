extends SceneTree
## QA tool (E1c, bug 2 "E apertado sem parar"): plays the real game and presses the attack over and over, every
## --mash-every frames (default 3), walking to the nearest enemy first, so a video (tools/movie.sh with
## PRE="-s res://tools/mash_driver.gd") shows and sounds what Daniel heard. Run with the game's options after `--`,
## always with --bot (the game hands its step to the driver, tools/mash_bot.gd):
##   godot --path . -s res://tools/mash_driver.gd -- --bot --nosave [--mash-every=3]

var _done := false


func _initialize() -> void:
	change_scene_to_file("res://scenes/boot.tscn")


func _process(_d: float) -> bool:
	if _done:
		return false
	for n in root.find_children("*", "Node", true, false):
		if n.has_method(&"result_line") and n.get(&"bot") != null:
			var d: Object = load("res://tools/mash_bot.gd").new()
			for a in OS.get_cmdline_user_args():
				if a.begins_with("--mash-every="):
					d.set(&"every", int(a.trim_prefix("--mash-every=")))
			n.set(&"bot", d)
			root.get_node("Controls").set(&"virtual", d.get(&"pad"))
			_done = true
			print("MASH driver on")
			break
	return false
