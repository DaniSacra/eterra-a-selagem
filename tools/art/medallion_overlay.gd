extends SceneTree
## Debug: draws the inner ring circle from a json {id: [cx, cy, r_in]} over each medallion. Args: <dir> <json> <out.png> <tile> <cols>
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(a[1]))
	var tile := int(a[3])
	var cols := int(a[4])
	var ids: Array = d.keys()
	ids.sort()
	var rows := ceili(ids.size() / float(cols))
	var sheet := Image.create(tile * cols, tile * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.5, 0.5, 0.52))
	var k := tile / 512.0 * (float(a[5]) if a.size() > 5 else 1.0)
	for i in ids.size():
		var img := Image.load_from_file(a[0] + "/" + ids[i] + ".png")
		img.convert(Image.FORMAT_RGBA8)
		img.resize(tile, tile, Image.INTERPOLATE_LANCZOS)
		var v: Array = d[ids[i]]
		for j in 360:
			var an := TAU * j / 360.0
			var p: Vector2 = Vector2(v[0], v[1]) * k + Vector2(cos(an), sin(an)) * float(v[2]) * k
			if p.x >= 0 and p.y >= 0 and p.x < tile - 1 and p.y < tile - 1:
				img.set_pixelv(Vector2i(p), Color(1, 0, 1))
				img.set_pixelv(Vector2i(p) + Vector2i(1, 0), Color(1, 0, 1))
		sheet.blend_rect(img, Rect2i(0, 0, tile, tile), Vector2i((i % cols) * tile, (i / cols) * tile))
	sheet.save_png(a[2])
	print(ids)
	quit()
