extends SceneTree
## Exports every grid as a PNG strip (the template for hand-drawn replacements):
##   godot --headless --path . -s tools/export_png.gd -- [out_dir] [scale]
## Default out_dir is art/png_templates (never art/png, where a file would replace the grid).


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out_dir: String = args[0] if args.size() > 0 else "res://art/png_templates"
	var scale: int = int(args[1]) if args.size() > 1 else 1
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	for file in DirAccess.get_files_at(GridSprite.GRID_DIR):
		if not file.ends_with(".json"):
			continue
		var img := GridSprite.to_strip(GridSprite.load_def(file.get_basename()))
		if scale > 1:
			img.resize(img.get_width() * scale, img.get_height() * scale, Image.INTERPOLATE_NEAREST)
		img.save_png(out_dir.path_join(file.get_basename() + ".png"))
	quit()
