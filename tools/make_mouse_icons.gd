extends SceneTree
## Saves the mouse icons (MouseGlyphArt) as PNGs: ~/tools/godot/godot --headless --path . -s tools/make_mouse_icons.gd
## then --import once. Only needed when the drawing changes.


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/ui/keys")
	for b in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		MouseGlyphArt.rasterize(b).save_png("res://assets/ui/keys/mouse_%d.png" % b)
	print("MOUSE ICONS saved")
	quit()
