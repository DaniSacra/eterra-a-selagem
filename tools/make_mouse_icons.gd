extends SceneTree
## Saves the mouse icons (MouseGlyphArt) as PNGs: ~/tools/godot/godot --headless --path . -s tools/make_mouse_icons.gd
## then --import once. Only needed when the drawing changes. mouse_N.png is the gold icon of the cards and tips; mouse_N_tap.png (lit
## white) and mouse_N_hold.png (lit gold) are the HUD slots' (white = a click, gold = a hold), as MouseGlyph.path() names them.


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/ui/keys")
	for b in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		MouseGlyphArt.rasterize(b).save_png("res://assets/ui/keys/mouse_%d.png" % b)
	for b in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		MouseGlyphArt.rasterize(b, MouseGlyphArt.Style.TAP).save_png("res://assets/ui/keys/mouse_%d_tap.png" % b)
		MouseGlyphArt.rasterize(b, MouseGlyphArt.Style.HOLD).save_png("res://assets/ui/keys/mouse_%d_hold.png" % b)
	print("MOUSE ICONS saved")
	quit()
