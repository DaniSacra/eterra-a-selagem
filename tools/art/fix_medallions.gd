extends SceneTree
## Door medallions (assets/ui/rewards/*.png, painted by AI, 512 x 512 RGBA): every file gets the SAME complete, centred
## frame (the one painted in boon.png) and keeps only its own centre picture, re-centred and scaled into the frame.
## The painted rings come cut, partial or off-centre, so the middle of each ring is a hand-checked table
## (tools/art/medallion_rings.json: id -> [cx, cy, r_inner, optional y_cut] in units of a 400 px preview, x1.28 = source px; check it
## with tools/art/medallion_overlay.gd). Redo when new art arrives: put the new originals in a folder, run
##   godot --headless --path . -s tools/art/fix_medallions.gd -- <originals dir> <output dir>
## (boon.png of the originals is the frame donor; without a table row the full disc is used.)
const SIZE := 512
const FRAME_CENTRE := Vector2(264.0, 263.0)   # centre of the ring painted in boon.png
const FRAME_INNER := 192.0                    # inner edge of that ring
const FRAME_OUTER := 228.0                    # outer edge of the ring band we draw
const BAND_FROM := 192.0                      # degrees: clean stone in boon.png, from the left diamond ...
const BAND_TO := 260.0                        # ... to the top one
const DIAMOND_CENTRE := Vector2(287.0, 59.5)  # the top diamond in boon.png
const DIAMOND_HALF := Vector2(37.0, 39.0)
const DIAMOND_RADIUS := 205.0                 # where the diamonds sit on the new frame
const FRAME_BLEED := 4.0                      # frame starts this far inside its inner edge (hides the seam)
const PREVIEW_TO_SRC := 1.28

static func sample(img: Image, p: Vector2) -> Color:
	var x := clampf(p.x - 0.5, 0.0, SIZE - 1.001)
	var y := clampf(p.y - 0.5, 0.0, SIZE - 1.001)
	var x0 := int(x)
	var y0 := int(y)
	var fx := x - x0
	var fy := y - y0
	var c00 := img.get_pixel(x0, y0)
	var c10 := img.get_pixel(x0 + 1, y0)
	var c01 := img.get_pixel(x0, y0 + 1)
	var c11 := img.get_pixel(x0 + 1, y0 + 1)
	# alpha-weighted so transparent pixels do not drag their colour in
	var w00 := c00.a * (1 - fx) * (1 - fy)
	var w10 := c10.a * fx * (1 - fy)
	var w01 := c01.a * (1 - fx) * fy
	var w11 := c11.a * fx * fy
	var a := w00 + w10 + w01 + w11
	if a < 1e-4:
		return Color(0, 0, 0, 0)
	var rgb := (Vector3(c00.r, c00.g, c00.b) * w00 + Vector3(c10.r, c10.g, c10.b) * w10 + Vector3(c01.r, c01.g, c01.b) * w01 + Vector3(c11.r, c11.g, c11.b) * w11) / a
	return Color(rgb.x, rgb.y, rgb.z, a)

## The shared frame, built from the ring painted in boon.png: the clean stone band between its left and top diamonds is
## mirrored round the whole circle (so the ring is complete, round and the same all over, with a clean edge of our own),
## and the top diamond is cut out as a sprite and set on the four compass points.
static func build_frame(boon: Image) -> Image:
	var f := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var centre := Vector2(SIZE / 2.0, SIZE / 2.0)
	var span := BAND_TO - BAND_FROM
	for y in SIZE:
		for x in SIZE:
			var d := Vector2(x + 0.5, y + 0.5) - centre
			var r := d.length()
			if r < FRAME_INNER - FRAME_BLEED or r > FRAME_OUTER + 2.0:
				continue
			var t := fposmod(rad_to_deg(d.angle()) + 360.0, span * 2.0)
			if t > span:
				t = span * 2.0 - t
			var c: Color = sample(boon, FRAME_CENTRE + Vector2.from_angle(deg_to_rad(BAND_FROM + t)) * r)
			var a := clampf((FRAME_OUTER + 1.0 - r), 0.0, 1.0) * clampf((r - (FRAME_INNER - FRAME_BLEED)) / 2.0, 0.0, 1.0)
			# our own thin dark outline on the outer edge
			var rim := clampf((r - (FRAME_OUTER - 8.0)) / 2.0, 0.0, 1.0)
			var rgb := Vector3(c.r, c.g, c.b).lerp(Vector3(0.16, 0.11, 0.06), rim)
			f.set_pixel(x, y, Color(rgb.x, rgb.y, rgb.z, a))
	# diamonds
	var half := Vector2(DIAMOND_HALF)
	for k in 4:
		var ang := deg_to_rad(-90.0 + 90.0 * k)
		var dc := centre + Vector2.from_angle(ang) * DIAMOND_RADIUS
		for y in range(-50, 51):
			for x in range(-50, 51):
				var o := Vector2(x, y)
				# the sprite is the top diamond turned by k quarter turns
				var q := o
				for i in k:
					q = Vector2(q.y, -q.x)   # rotate back by 90 degrees (k times) to read the unturned sprite
				var m := 1.0 - (absf(q.x) / half.x + absf(q.y) / half.y)
				if m <= 0.0:
					continue
				var c: Color = sample(boon, DIAMOND_CENTRE + q)
				var px := Vector2i(dc + o)
				var cur := f.get_pixelv(px)
				var cov := clampf(m * 6.0, 0.0, 1.0)
				var out := Color(cur.r, cur.g, cur.b).lerp(Color(c.r, c.g, c.b), cov)
				out.a = maxf(cur.a, cov)
				f.set_pixelv(px, out)
	return f

static func bg_colour(img: Image, c: Vector2, rc: float) -> Color:
	var sum := Vector3.ZERO
	var n := 0
	for i in 90:
		var a := TAU * i / 90.0
		for k: float in [0.78, 0.86, 0.94]:
			var p := c + Vector2.from_angle(a) * rc * k
			if p.x < 0 or p.y < 0 or p.x >= SIZE or p.y >= SIZE:
				continue
			var px := img.get_pixelv(Vector2i(p))
			if px.a > 0.9 and px.v < 0.32:
				sum += Vector3(px.r, px.g, px.b)
				n += 1
	if n < 20:
		return Color(0.05, 0.05, 0.07)
	sum /= n
	return Color(sum.x, sum.y, sum.z)

static func compose(src: Image, frame: Image, c: Vector2, rc: float, y_cut: float) -> Image:
	var out := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var bg := bg_colour(src, c, rc)
	var centre := Vector2(SIZE / 2.0, SIZE / 2.0)
	var dest_r := FRAME_INNER + FRAME_BLEED + 2.0
	var s := rc / dest_r   # source pixels per output pixel
	for y in SIZE:
		for x in SIZE:
			var d := Vector2(x + 0.5, y + 0.5) - centre
			var r := d.length()
			var col := Color(0, 0, 0, 0)
			if r <= dest_r:
				var sp := c + d * s
				var p: Color = sample(src, sp)
				if y_cut > 0.0:   # hides what is left of the old ring at the bottom of the picture
					p.a *= clampf((y_cut - sp.y) / 8.0, 0.0, 1.0)
				col = Color(bg.r, bg.g, bg.b, 1).lerp(Color(p.r, p.g, p.b, 1), p.a)
			var fr := frame.get_pixel(x, y)
			if fr.a > 0.0:
				col = Color(col.r, col.g, col.b, maxf(col.a, 0.0)).lerp(Color(fr.r, fr.g, fr.b, 1), fr.a)
				col.a = maxf(col.a, fr.a)
			out.set_pixel(x, y, col)
	return out

func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var table: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tools/art/medallion_rings.json"))
	var boon := Image.load_from_file(a[0] + "/boon.png")
	boon.convert(Image.FORMAT_RGBA8)
	var frame := build_frame(boon)
	frame.save_png(a[1] + "/_frame.png")
	var only := a[2].split(",") if a.size() > 2 else PackedStringArray()
	for id in table.keys():
		if only.size() > 0 and not only.has(id):
			continue
		var src := Image.load_from_file(a[0] + "/" + id + ".png")
		src.convert(Image.FORMAT_RGBA8)
		var t: Array = table[id]
		var c := Vector2(t[0], t[1]) * PREVIEW_TO_SRC
		var rc := float(t[2]) * PREVIEW_TO_SRC - 10.0
		if id == "boon":
			c = FRAME_CENTRE
			rc = FRAME_INNER - 2.0
		compose(src, frame, c, rc, float(t[3]) * PREVIEW_TO_SRC if t.size() > 3 else 0.0).save_png(a[1] + "/" + id + ".png")
		print("done ", id)
	quit()
