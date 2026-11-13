extends SceneTree
## Crops and enlarges a PNG to look at details: godot --headless -s tools/crop.gd -- in.png out.png x y w h scale


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var img := Image.load_from_file(a[0])
	var part := img.get_region(Rect2i(int(a[2]), int(a[3]), int(a[4]), int(a[5])))
	part.resize(part.get_width() * int(a[6]), part.get_height() * int(a[6]), Image.INTERPOLATE_NEAREST)
	part.save_png(a[1])
	quit()
