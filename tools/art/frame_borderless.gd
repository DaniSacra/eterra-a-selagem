extends SceneTree
## Rev. 03 (2026-11-23): the art director's icons come as squares (1024 px, no frame, no cut, the picture inside the
## middle 70%). This crops each to the disc and lays the ONE shared frame over it (the frame of fix_medallions.gd, kept
## in tools/art/medallion_frame.png), so every door and Blessing icon has the same complete ring.
##   godot --headless --path . -s tools/art/frame_borderless.gd -- <squares dir> <output dir> [crop]
## crop: the share of the square's half width that fills the disc inside the ring (default CROP; lower = bigger picture).
## With --make-frame <boon.png of Rev. 02> <out png>, rebuilds medallion_frame.png from the painted ring.
const Fix := preload("res://tools/art/fix_medallions.gd")
const SIZE := 512
const FRAME := "res://tools/art/medallion_frame.png"
const CROP := 0.84
const EDGE := 1.5


static func frame_icon(src: Image, frame: Image, crop: float) -> Image:
	src.convert(Image.FORMAT_RGBA8)
	var out := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var centre := Vector2(SIZE, SIZE) * 0.5
	var disc := Fix.FRAME_INNER + Fix.FRAME_BLEED + 2.0
	var w := float(src.get_width())
	var s := (w * 0.5 * crop) / disc   # source pixels per output pixel
	var sc := Vector2(src.get_width(), src.get_height()) * 0.5
	for y in SIZE:
		for x in SIZE:
			var d := Vector2(x + 0.5, y + 0.5) - centre
			var r := d.length()
			var col := Color(0, 0, 0, 0)
			if r <= disc + EDGE:
				var sp := sc + d * s
				var p := src.get_pixel(clampi(int(sp.x), 0, src.get_width() - 1), clampi(int(sp.y), 0, src.get_height() - 1))
				col = Color(p.r, p.g, p.b, clampf((disc + EDGE - r) / EDGE, 0.0, 1.0))
			var fr := frame.get_pixel(x, y)
			if fr.a > 0.0:
				col = Color(col.r, col.g, col.b, 1.0).lerp(Color(fr.r, fr.g, fr.b, 1.0), fr.a)
				col.a = maxf(col.a, fr.a)
			out.set_pixel(x, y, col)
	return out


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	if a.size() > 0 and a[0] == "--make-frame":
		var boon := Image.load_from_file(a[1])
		boon.convert(Image.FORMAT_RGBA8)
		Fix.build_frame(boon).save_png(a[2])
		quit()
		return
	var frame := Image.load_from_file(ProjectSettings.globalize_path(FRAME))
	frame.convert(Image.FORMAT_RGBA8)
	var crop := float(a[2]) if a.size() > 2 else CROP
	for f in DirAccess.get_files_at(a[0]):
		if not (f.ends_with(".png") or f.ends_with(".jpg")):
			continue
		var src := Image.load_from_file(a[0] + "/" + f)
		# big squares are shrunk first (smoother than point sampling across 2 to 1)
		if src.get_width() > SIZE * 1.2:
			var side := int(round(SIZE / crop * 1.0))
			src.resize(side, side, Image.INTERPOLATE_LANCZOS)
		frame_icon(src, frame, crop).save_png(a[1] + "/" + f.get_basename() + ".png")
		print("framed ", f)
	quit()
