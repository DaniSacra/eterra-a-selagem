extends SceneTree
## Contact sheet. Args: <dir> <out.png> <tile> <cols> <grid 0/1> [id,id,...]
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var tile := int(a[2])
	var cols := int(a[3])
	var grid := a[4] == "1"
	var ids: PackedStringArray
	if a.size() > 5:
		ids = a[5].split(",")
	else:
		for f in DirAccess.get_files_at(a[0]):
			if f.ends_with(".png"):
				ids.append(f.get_basename())
		ids.sort()
	var rows := ceili(ids.size() / float(cols))
	var sheet := Image.create(tile * cols, tile * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.5, 0.5, 0.52))
	for i in ids.size():
		var img := Image.load_from_file(a[0] + "/" + ids[i] + ".png")
		img.convert(Image.FORMAT_RGBA8)
		img.resize(tile, tile, Image.INTERPOLATE_LANCZOS)
		var ox := (i % cols) * tile
		var oy := (i / cols) * tile
		sheet.blend_rect(img, Rect2i(0, 0, tile, tile), Vector2i(ox, oy))
		if grid:
			for k in range(1, 8):
				var p := int(tile * k / 8.0)
				var col := Color(1, 1, 1, 0.9) if k == 4 else Color(1, 0, 1, 0.5)
				for t in tile:
					sheet.set_pixel(ox + p, oy + t, col)
					sheet.set_pixel(ox + t, oy + p, col)
	sheet.save_png(a[1])
	print(ids)
	quit()
