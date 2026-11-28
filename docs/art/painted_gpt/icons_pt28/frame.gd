extends SceneTree
## PT28-4 icons. Modes (after --):
##   frame              -> frame.png (the canonical medallion rim every assets/ui/rewards PNG shares: the pixels equal in
##                         heart, gold and boon from r >= 160, transparent inside) and template.png (3x2 frames, 1536x1024).
##   cut <sheet> <out_dir> <name1,...,name6>  -> each 512 cell: the painted disc (r <= DISC) under the canonical frame.
const R := "/home/dani/games/eterra-a-selagem/assets/ui/rewards/"
const HERE := "/home/dani/games/eterra-a-selagem/docs/art/painted_gpt/icons_pt28/"
const DISC := 202.0
const INSIDE := Color8(30, 32, 36)
const GROUND := Color8(16, 16, 16)

func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	if a[0] == "frame":
		_frame()
	elif a[0] == "cut":
		_cut(a[1], a[2], a[3].split(","))
	quit()

func _frame() -> void:
	var ims: Array[Image] = []
	for f in ["heart", "gold", "boon", "heal"]:
		var im := Image.load_from_file(R + f + ".png")
		im.convert(Image.FORMAT_RGBA8)
		ims.append(im)
	var out := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	for y in 512:
		for x in 512:
			var r := Vector2(x + 0.5 - 256, y + 0.5 - 256).length()
			var c := ims[0].get_pixel(x, y)
			var same := r >= 160.0
			for k in range(1, ims.size()):
				var d := ims[k].get_pixel(x, y)
				if absf(d.r - c.r) + absf(d.g - c.g) + absf(d.b - c.b) + absf(d.a - c.a) > 0.04:
					same = false
			out.set_pixel(x, y, c if same else Color(0, 0, 0, 0))
	out.save_png(HERE + "frame.png")
	var t := Image.create(1536, 1024, false, Image.FORMAT_RGBA8)
	t.fill(GROUND)
	var disc := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	for y in 512:
		for x in 512:
			var r := Vector2(x + 0.5 - 256, y + 0.5 - 256).length()
			disc.set_pixel(x, y, INSIDE if r <= DISC else Color(0, 0, 0, 0))
	for i in 6:
		var at := Vector2i((i % 3) * 512, (i / 3) * 512)
		t.blend_rect(disc, Rect2i(0, 0, 512, 512), at)
		t.blend_rect(out, Rect2i(0, 0, 512, 512), at)
	t.convert(Image.FORMAT_RGB8)
	t.save_png(HERE + "template.png")
	print("frame + template ok")

func _cut(sheet: String, out_dir: String, names: PackedStringArray) -> void:
	var frame := Image.load_from_file(HERE + "frame.png")
	var im := Image.load_from_file(sheet)
	im.convert(Image.FORMAT_RGBA8)
	if im.get_size() != Vector2i(1536, 1024):
		im.resize(1536, 1024, Image.INTERPOLATE_LANCZOS)
	DirAccess.make_dir_recursive_absolute(out_dir)
	for i in mini(6, names.size()):
		if names[i] == "":
			continue
		var cell := im.get_region(Rect2i((i % 3) * 512, (i / 3) * 512, 512, 512))
		var o := Image.create(512, 512, false, Image.FORMAT_RGBA8)
		for y in 512:
			for x in 512:
				var r := Vector2(x + 0.5 - 256, y + 0.5 - 256).length()
				var c := cell.get_pixel(x, y)
				c.a = clampf(DISC + 0.5 - r, 0.0, 1.0)
				o.set_pixel(x, y, c)
		o.blend_rect(frame, Rect2i(0, 0, 512, 512), Vector2i.ZERO)
		o.save_png(out_dir.path_join(names[i] + ".png"))
	print("cut ", sheet, " ", names)
