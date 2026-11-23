extends SceneTree
## Rebuilds the painted Blessing medallions (assets/ui/boons/*.png) from the ChatGPT paintings by image processing.
## Per file: finds the painted ring (a circle fitted to its gold pixels), cuts the painting inside it, erases the small
## seal of the lower right corner, sets the painting under ONE complete gold ring centred on the canvas and puts the
## seal, enlarged, at the centre over a darkened halo. See docs/art/medallions_rev02.md.
##
## Run (autoloads do not load with -s, harmless errors about controls.gd are expected):
##   ~/tools/godot/godot --headless --path . -s tools/art/fix_boon_medallions.gd -- SRC_DIR OUT_DIR [only_id ...]
## SRC_DIR holds the untouched ChatGPT paintings (512x512, circular alpha), OUT_DIR is where the result goes
## (assets/ui/boons). The 7 older medallions (KEEP) are skipped. Never run it on its own output.
## Debug: with DEBUG_DIR set in the environment (ETERRA_FIX_DEBUG) it also writes the fitted circles over the source.

const KEEP := ["aurora", "brasas", "escudo", "onda_maior", "redemoinho", "toque_geada", "vapor"]
const S := 512
const CEN := 255.5
const R_OUT := 248.0  # the canvas disc, as the paintings' alpha
const RING_W := 31.0
const BADGE_R := 114.0  # about 45% of the whole diameter
const ANG := 120
## Search window of the painted ring (the ChatGPT frames share one geometry; a free search locks onto the scene's gold).
const RING_CX := Vector2i(268, 293)
const RING_CY := Vector2i(255, 281)
const RING_R := Vector2i(224, 248)

# ring bands from the inner edge (t=0) to the outer edge (t=1): to, colour. Gold with a lit bead, dark edges.
const BANDS := [
	[0.10, Color8(38, 26, 14)], [0.22, Color8(120, 84, 40)], [0.34, Color8(176, 128, 62)],
	[0.50, Color8(232, 190, 108)], [0.62, Color8(190, 140, 66)], [0.74, Color8(134, 94, 44)],
	[0.90, Color8(96, 66, 32)], [1.01, Color8(34, 22, 12)]]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var src_dir: String = args[0] if args.size() > 0 else "res://assets/ui/boons"
	var out_dir: String = args[1] if args.size() > 1 else "res://assets/ui/boons"
	var only: Array = args.slice(2)
	var dbg := OS.get_environment("ETERRA_FIX_DEBUG")
	var report := PackedStringArray()
	for f in DirAccess.get_files_at(src_dir):
		if not f.ends_with(".png"):
			continue
		var id := f.get_basename()
		if id in KEEP or (only.size() > 0 and not id in only):
			continue
		var im := Image.load_from_file(src_dir.path_join(f))
		if im == null or im.get_width() != S:
			continue
		im.convert(Image.FORMAT_RGBA8)
		var gold := _gold_mask(im)
		var ring := _fit_ring(gold)
		var seal := _fit_seal(gold)
		report.append("%s ring %s seal %s" % [id, ring, seal])
		if dbg != "":
			_debug(im, ring, seal).save_png(dbg.path_join("fit_" + f))
		var out := _build(im, ring, seal)
		out.save_png(out_dir.path_join(f))
	print("\n".join(report))
	quit()


func _gold_mask(im: Image) -> PackedByteArray:
	var m := PackedByteArray()
	m.resize(S * S)
	for y in S:
		for x in S:
			var c := im.get_pixel(x, y)
			if c.a > 0.5 and c.r > 0.28 and c.r > c.b * 1.6 and c.r >= c.g and c.g > c.b * 1.1:
				m[y * S + x] = 1
	return m


func _ring_score(m: PackedByteArray, cx: float, cy: float, r: float, cs: PackedFloat32Array, sn: PackedFloat32Array) -> int:
	var n := 0
	for i in ANG:
		for dr in [-8.0, 0.0, 8.0]:
			var x := int(cx + (r + dr) * cs[i])
			var y := int(cy + (r + dr) * sn[i])
			if x >= 0 and y >= 0 and x < S and y < S:
				n += m[y * S + x]
		for dr in [-30.0, -22.0, -14.0]:
			var x := int(cx + (r + dr) * cs[i])
			var y := int(cy + (r + dr) * sn[i])
			if x >= 0 and y >= 0 and x < S and y < S:
				n -= m[y * S + x]
	return n


func _trig() -> Array:
	var cs := PackedFloat32Array()
	var sn := PackedFloat32Array()
	for i in ANG:
		cs.append(cos(TAU * i / ANG))
		sn.append(sin(TAU * i / ANG))
	return [cs, sn]


## The painted ring: (cx, cy, inner radius). A free fit of the gold pixels locks onto the scene's own gold in half of
## the files (measured over the 70: centres from 244 to 304), while the ChatGPT frames share one geometry (the ring is
## clipped by the canvas on the left and bottom the same way in every file), so the circle is a constant, found by
## measuring the clearest frame (golpe_geada) and checked over all 70 with ETERRA_FIX_DEBUG overlays.
const RING_FIXED := Vector3(281.0, 270.0, 208.0)


func _fit_ring(_m: PackedByteArray) -> Vector3:
	return RING_FIXED


## The seal: (x, y, outer radius), the bronze band that rings the dark disc, in the lower right.
func _fit_seal(m: PackedByteArray) -> Vector3:
	var t := _trig()
	var best := -99999
	var b := Vector3(368, 365, 82)
	for cy in range(340, 392, 3):
		for cx in range(340, 396, 3):
			for r in range(72, 96, 2):
				var n := 0
				for i in ANG:
					for dr in [-6.0, -3.0, 0.0]:
						var x := int(cx + (r + dr) * t[0][i])
						var y := int(cy + (r + dr) * t[1][i])
						n += m[y * S + x]
					for dr in [-30.0, -22.0]:
						var x := int(cx + (r + dr) * t[0][i])
						var y := int(cy + (r + dr) * t[1][i])
						n -= m[y * S + x]
				if n > best:
					best = n
					b = Vector3(cx, cy, r)
	var c := b
	for cy in range(int(c.y) - 2, int(c.y) + 3):
		for cx in range(int(c.x) - 2, int(c.x) + 3):
			for r in range(int(c.z) - 2, int(c.z) + 3):
				var n := 0
				for i in ANG:
					for dr in [-6.0, -3.0, 0.0]:
						var x := int(cx + (r + dr) * t[0][i])
						var y := int(cy + (r + dr) * t[1][i])
						n += m[y * S + x]
					for dr in [-30.0, -22.0]:
						var x := int(cx + (r + dr) * t[0][i])
						var y := int(cy + (r + dr) * t[1][i])
						n -= m[y * S + x]
				if n > best:
					best = n
					b = Vector3(cx, cy, r)
	return b


func _debug(im: Image, ring: Vector3, seal: Vector3) -> Image:
	var d := im.duplicate()
	for i in 1440:
		var a := TAU * i / 1440
		for p in [Vector3(ring.x, ring.y, ring.z), Vector3(seal.x, seal.y, seal.z)]:
			var x := int(p.x + p.z * cos(a))
			var y := int(p.y + p.z * sin(a))
			if x >= 0 and y >= 0 and x < S and y < S:
				d.set_pixel(x, y, Color.GREEN if p.z == ring.z else Color.RED)
	return d


func _bilinear(im: Image, x: float, y: float) -> Color:
	x = clampf(x, 0.0, S - 1.001)
	y = clampf(y, 0.0, S - 1.001)
	var x0 := int(x)
	var y0 := int(y)
	var fx := x - x0
	var fy := y - y0
	var a := im.get_pixel(x0, y0).lerp(im.get_pixel(x0 + 1, y0), fx)
	var b := im.get_pixel(x0, y0 + 1).lerp(im.get_pixel(x0 + 1, y0 + 1), fx)
	return a.lerp(b, fy)


## The painting with the seal rubbed out: inside the seal's disc each pixel is the inverse-distance blend of colours
## sampled round the disc's edge (only where that edge lies on the painting, inside the ring and the canvas), then
## feathered into the painting. (Reflecting the outside in picked up the black beyond the canvas.)
func _erase_seal(im: Image, seal: Vector3) -> Image:
	var out := im.duplicate()
	var R := seal.z + 18.0
	var pts := PackedVector2Array()
	var cols: Array[Color] = []
	for i in 96:
		var a := TAU * i / 96
		var p := Vector2(seal.x, seal.y) + Vector2(cos(a), sin(a)) * (R + 4.0)
		if p.distance_to(Vector2(CEN, CEN)) < R_OUT - 40.0 and p.distance_to(Vector2(RING_FIXED.x, RING_FIXED.y)) < RING_FIXED.z - 6.0:
			pts.append(p)
			cols.append(_bilinear(im, p.x, p.y))
	if pts.size() < 6:
		return out
	var box := int(R * 1.3)
	var patch := Image.create(2 * box, 2 * box, false, Image.FORMAT_RGBA8)
	for py in 2 * box:
		for px in 2 * box:
			var q := Vector2(seal.x + px - box + 0.5, seal.y + py - box + 0.5)
			if q.distance_to(Vector2(seal.x, seal.y)) > R * 1.2:
				continue
			var acc := Color(0, 0, 0, 0)
			var wsum := 0.0
			for k in pts.size():
				var d2 := maxf(4.0, q.distance_squared_to(pts[k]))
				var w := 1.0 / (d2 * d2)
				acc += cols[k] * w
				wsum += w
			var c := acc / wsum
			c.a = 1.0
			patch.set_pixel(px, py, c)
	patch = _blur(patch, 5)
	for py in 2 * box:
		for px in 2 * box:
			var dx := px - box + 0.5
			var dy := py - box + 0.5
			var d := sqrt(dx * dx + dy * dy)
			var w := 1.0 - smoothstep(R * 0.9, R * 1.15, d)
			if w <= 0.0:
				continue
			var x := int(seal.x) + px - box
			var y := int(seal.y) + py - box
			if x < 0 or y < 0 or x >= S or y >= S:
				continue
			var o: Color = out.get_pixel(x, y)
			var p := patch.get_pixel(px, py)
			out.set_pixel(x, y, Color(o.lerp(p, w), o.a))
	return out


func _blur(im: Image, rad: int) -> Image:
	var w := im.get_width()
	var h := im.get_height()
	var tmp := im.duplicate()
	for pass_i in 2:
		for y in h:
			for x in w:
				var acc := Color(0, 0, 0, 0)
				var n := 0
				for k in range(-rad, rad + 1):
					var xx := x + k
					if xx >= 0 and xx < w:
						acc += im.get_pixel(xx, y)
						n += 1
				tmp.set_pixel(x, y, acc / n)
		for y in h:
			for x in w:
				var acc := Color(0, 0, 0, 0)
				var n := 0
				for k in range(-rad, rad + 1):
					var yy := y + k
					if yy >= 0 and yy < h:
						acc += tmp.get_pixel(x, yy)
						n += 1
				im.set_pixel(x, y, acc / n)
	return im


func _ring_color(t: float, ang: float) -> Color:
	var prev := 0.0
	var col: Color = BANDS[0][1]
	for b in BANDS:
		if t < b[0]:
			col = b[1]
			# soften the band edges
			var u: float = (t - prev) / (b[0] - prev)
			if u < 0.25 and prev > 0.0:
				col = (BANDS[BANDS.find(b) - 1][1] as Color).lerp(col, 0.5 + u * 2.0)
			break
		prev = b[0]
	# light from the upper left
	var lit := 0.82 + 0.28 * cos(ang + 2.36)
	return Color(col.r * lit, col.g * lit, col.b * lit, 1.0)


func _build(src0: Image, ring: Vector3, seal: Vector3) -> Image:
	var src := _erase_seal(src0, seal)
	var r_in := R_OUT - RING_W
	var sc := r_in / ring.z  # painting scale
	var out := Image.create(S, S, false, Image.FORMAT_RGBA8)
	for y in S:
		for x in S:
			var dx := x + 0.5 - 256.0
			var dy := y + 0.5 - 256.0
			var d := sqrt(dx * dx + dy * dy)
			var a := clampf(R_OUT + 0.5 - d, 0.0, 1.0)
			if a <= 0.0:
				continue
			var col: Color
			var ang := atan2(dy, dx)
			var ringc := _ring_color(clampf((d - r_in) / RING_W, 0.0, 1.0), ang)
			if d < r_in + 1.0:
				var p := _bilinear(src, ring.x + dx / sc, ring.y + dy / sc)
				p.a = 1.0
				# the rim throws a soft shadow inside
				var sh := 1.0 - 0.45 * (1.0 - smoothstep(0.0, 14.0, r_in - d))
				p = Color(p.r * sh, p.g * sh, p.b * sh, 1.0)
				col = p.lerp(ringc, clampf(d - (r_in - 0.5), 0.0, 1.0))
			else:
				col = ringc
			col.a = a
			out.set_pixel(x, y, col)
	# halo behind the badge, then the badge itself (the seal's disc, enlarged)
	var k := BADGE_R / (seal.z + 9.0)
	var halo := BADGE_R * 1.55
	for y in S:
		for x in S:
			var dx := x + 0.5 - 256.0
			var dy := y + 0.5 - 256.0
			var d := sqrt(dx * dx + dy * dy)
			if d > halo:
				continue
			var o: Color = out.get_pixel(x, y)
			if o.a <= 0.0:
				continue
			var dark := 0.55 * (1.0 - smoothstep(BADGE_R * 0.8, halo, d))
			var b := Color(o.r * (1.0 - dark) * 0.85, o.g * (1.0 - dark) * 0.85, o.b * (1.0 - dark) * 0.85, o.a)
			if d < BADGE_R + 0.5:
				var s := _bilinear(src0, seal.x + dx / k, seal.y + dy / k)
				var cover := clampf(BADGE_R + 0.5 - d, 0.0, 1.0)
				# levels: the pictogram reads brighter against its dark plate (64 px and grey)
				s = Color(clampf((s.r - 0.05) * 1.45, 0, 1), clampf((s.g - 0.05) * 1.45, 0, 1), clampf((s.b - 0.05) * 1.45, 0, 1), s.a)
				b = b.lerp(Color(s.r, s.g, s.b, o.a), cover)
				# seal pixels that were see-through at its rim (semi-transparent bronze): darken so it reads as a plate
				if d > BADGE_R * 0.9:
					b = b.lerp(Color(b.r * 0.55, b.g * 0.5, b.b * 0.45, o.a), 0.5 * smoothstep(0.9, 1.0, d / BADGE_R) * cover)
			out.set_pixel(x, y, b)
	return out
