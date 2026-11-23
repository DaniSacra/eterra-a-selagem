extends SceneTree
## Finds the painted ring (centre, outer radius) of each medallion. For every ray from the middle of the sticker the
## outermost ring-coloured pixel is an outer-edge candidate; a RANSAC circle fit over those points picks the ring even
## when it is cut or off-centre, because the motif never lies on a long arc of one circle.
## Run: godot --headless --path . -s tools/art/medallion_fit.gd -- <dir> [out.json]   (json: id -> [cx, cy, r_outer])

static func ringish(c: Color) -> bool:
	if c.a < 0.5 or c.v < 0.4:
		return false
	var gold := c.s > 0.35 and c.h > 0.06 and c.h < 0.16
	var stone := c.s < 0.3 and c.v < 0.85
	return gold or stone

static func edge_points(img: Image) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var mid := Vector2(256, 256)
	for i in 720:
		var d := Vector2.from_angle(TAU * i / 720.0)
		var r := 262.0
		while r > 120.0:
			var p := mid + d * r
			if p.x >= 0 and p.y >= 0 and p.x < 512 and p.y < 512:
				var c := img.get_pixelv(Vector2i(p))
				if ringish(c):
					# confirm it is a band, not a speck: the pixel 6 px further in is ringish too
					var q := mid + d * (r - 6.0)
					if ringish(img.get_pixelv(Vector2i(q))):
						pts.append(p)
						break
			r -= 1.0
	return pts

static func circle3(a: Vector2, b: Vector2, c: Vector2) -> Vector3:
	var d := 2.0 * (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y))
	if absf(d) < 1e-3:
		return Vector3.ZERO
	var ux := ((a.length_squared()) * (b.y - c.y) + b.length_squared() * (c.y - a.y) + c.length_squared() * (a.y - b.y)) / d
	var uy := ((a.length_squared()) * (c.x - b.x) + b.length_squared() * (a.x - c.x) + c.length_squared() * (b.x - a.x)) / d
	return Vector3(ux, uy, Vector2(ux, uy).distance_to(a))

static func fit(img: Image) -> Vector3:
	var pts := edge_points(img)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var best := Vector3.ZERO
	var best_n := -1
	for it in 6000:
		var c := circle3(pts[rng.randi() % pts.size()], pts[rng.randi() % pts.size()], pts[rng.randi() % pts.size()])
		if c.z < 190.0 or c.z > 255.0 or absf(c.x - 256.0) > 70.0 or absf(c.y - 256.0) > 70.0:
			continue
		var n := 0
		for p in pts:
			if absf(Vector2(c.x, c.y).distance_to(p) - c.z) < 3.5:
				n += 1
		if n > best_n:
			best_n = n
			best = c
	# refine: mean of inliers' centre by a few small steps
	for step in 40:
		var cand := best + Vector3(rng.randf_range(-2, 2), rng.randf_range(-2, 2), rng.randf_range(-2, 2))
		var n := 0
		for p in pts:
			if absf(Vector2(cand.x, cand.y).distance_to(p) - cand.z) < 3.5:
				n += 1
		if n > best_n:
			best_n = n
			best = cand
	print("   inliers ", best_n, " of ", pts.size())
	return best

func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var out := {}
	var ids := []
	for f in DirAccess.get_files_at(a[0]):
		if f.ends_with(".png"):
			ids.append(f.get_basename())
	ids.sort()
	for id in ids:
		var img := Image.load_from_file(a[0] + "/" + id + ".png")
		img.convert(Image.FORMAT_RGBA8)
		var v := fit(img)
		out[id] = [snappedf(v.x, 0.1), snappedf(v.y, 0.1), snappedf(v.z, 0.1)]
		print("FIT ", id, " ", v)
	if a.size() > 1:
		var fh := FileAccess.open(a[1], FileAccess.WRITE)
		fh.store_string(JSON.stringify(out, "  "))
	quit()
