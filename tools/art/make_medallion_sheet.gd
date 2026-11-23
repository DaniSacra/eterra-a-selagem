extends SceneTree
## Before/after sheet of the Blessing medallions, one block per family: each member at 64 px (before row, after row),
## and the first member at 128 and 32 px on the right.
## ~/tools/godot/godot --headless --path . -s tools/art/make_medallion_sheet.gd -- BEFORE_DIR AFTER_DIR out.png
const FAM := ["Chama", "Geada", "Luz", "Vigilia", "Duo", "Veu", "Mare", "Marca"]


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var fams := {}
	for f in DirAccess.get_files_at("res://data/boons"):
		var t := FileAccess.get_file_as_string("res://data/boons/" + f)
		var id := ""
		var fam := -1
		for line in t.split("\n"):
			if line.begins_with("id = &"):
				id = line.split('"')[1]
			elif line.begins_with("family = "):
				fam = int(line.split("= ")[1])
		if id != "" and FileAccess.file_exists(a[1].path_join(id + ".png")):
			if not fams.has(fam):
				fams[fam] = []
			fams[fam].append(id)
	var keys := fams.keys()
	keys.sort()
	var W := 1700
	var H := 0
	for k in keys:
		H += 2 * 66 + 10
	var sheet := Image.create(W, H, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.09, 0.1, 0.12))
	var y := 0
	for k in keys:
		var ids: Array = fams[k]
		for row in 2:
			var dir: String = a[row]
			var x := 2
			for id in ids:
				var im := Image.load_from_file(dir.path_join(id + ".png"))
				im.convert(Image.FORMAT_RGBA8)
				im.generate_mipmaps()
				var s := im.duplicate()
				s.resize(64, 64, Image.INTERPOLATE_LANCZOS)
				sheet.blend_rect(s, Rect2i(0, 0, 64, 64), Vector2i(x, y + row * 66))
				x += 66
			var im0 := Image.load_from_file(dir.path_join(ids[0] + ".png"))
			im0.convert(Image.FORMAT_RGBA8)
			var b := im0.duplicate()
			b.resize(128, 128, Image.INTERPOLATE_LANCZOS)
			var c := im0.duplicate()
			c.resize(32, 32, Image.INTERPOLATE_LANCZOS)
			var gx := 1300 + row * 200
			sheet.blend_rect(b, Rect2i(0, 0, 128, 128), Vector2i(gx, y))
			sheet.blend_rect(c, Rect2i(0, 0, 32, 32), Vector2i(gx + 140 - 8, y + 48))
		y += 2 * 66 + 10
	sheet.save_png(a[2])
	quit()
