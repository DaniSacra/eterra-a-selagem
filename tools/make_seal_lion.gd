extends SceneTree
## Turns the hand-drawn lion of the Chamber's seal (assets/textures/seal/lion.svg) into the distance field the seal's
## shader reads (assets/textures/seal/lion_sdf.res): red = signed distance to the lion's outline (0.5 on it, more
## inside), green = signed distance to its inner cuts (eye, mane, claws; 0.5 on their edge, more inside a cut), both
## SPREAD pixels to the full swing. Run it again after editing the drawing:
##   ~/tools/godot/godot --headless --path . -s tools/make_seal_lion.gd [-- preview.png]

const SVG := "res://assets/textures/seal/lion.svg"
const OUT := "res://assets/textures/seal/lion_sdf.res"
const SIZE := 512
## Pixels of distance from the edge to the full swing (0 or 1) of a channel.
const SPREAD := 24.0


func _initialize() -> void:
	var img := Image.new()
	var err := img.load_svg_from_string(FileAccess.get_file_as_string(SVG), float(SIZE) / 512.0)
	if err != OK:
		push_error("cannot read %s" % SVG)
		quit(1)
		return
	img.convert(Image.FORMAT_RGBA8)
	var body := PackedByteArray()
	var cuts := PackedByteArray()
	body.resize(SIZE * SIZE)
	cuts.resize(SIZE * SIZE)
	for y in SIZE:
		for x in SIZE:
			var c := img.get_pixel(x, y)
			body[y * SIZE + x] = 1 if c.a > 0.5 else 0
			# the cuts are drawn in red over the white body
			cuts[y * SIZE + x] = 1 if c.a > 0.5 and c.g < 0.5 else 0
	var body_d := _signed(body)
	var cuts_d := _signed(cuts)
	var out := Image.create(SIZE, SIZE, false, Image.FORMAT_RG8)
	for i in SIZE * SIZE:
		out.set_pixel(i % SIZE, i / SIZE, Color(_enc(body_d[i]), _enc(cuts_d[i]), 0.0))
	out.generate_mipmaps()
	var tex := ImageTexture.create_from_image(out)
	ResourceSaver.save(tex, OUT)
	print("saved %s" % OUT)
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		# a preview: the body in relief (lit from the top left), its cuts dark
		var prev := Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
		for y in SIZE:
			for x in SIZE:
				var i := y * SIZE + x
				var v := 0.25
				if body_d[i] > 0.0:
					v = 0.75 - (0.45 if cuts_d[i] > 0.0 else 0.0)
				elif body_d[i] > -3.0:
					v = 0.9
				prev.set_pixel(x, y, Color(v, v * 0.9, v * 0.7))
		prev.save_png(args[0])
	quit()


## Signed distance in pixels: positive inside the mask, negative outside.
func _signed(mask: PackedByteArray) -> PackedFloat32Array:
	var inv := PackedByteArray()
	inv.resize(mask.size())
	for i in mask.size():
		inv[i] = 1 - mask[i]
	var to_in := _edt(mask)
	var to_out := _edt(inv)
	var d := PackedFloat32Array()
	d.resize(mask.size())
	for i in mask.size():
		d[i] = to_out[i] - 0.5 if mask[i] == 1 else -(to_in[i] - 0.5)
	return d


func _enc(d: float) -> float:
	return clampf(0.5 + d / SPREAD * 0.5, 0.0, 1.0)


## Distance (pixels) from every pixel to the nearest pixel set in the mask: two passes of 8SSEDT (the nearest set
## pixel's offset carried from the neighbours).
func _edt(mask: PackedByteArray) -> PackedFloat32Array:
	var n := SIZE * SIZE
	var far := 100000
	var dx := PackedInt32Array()
	var dy := PackedInt32Array()
	dx.resize(n)
	dy.resize(n)
	for i in n:
		dx[i] = 0 if mask[i] == 1 else far
		dy[i] = 0 if mask[i] == 1 else far
	var passes: Array = [
		[0, 1, [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(1, -1)], [Vector2i(1, 0)]],
		[SIZE - 1, -1, [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(-1, 1)], [Vector2i(-1, 0)]],
	]
	for p: Array in passes:
		var y0: int = p[0]
		var step: int = p[1]
		var y := y0
		while y >= 0 and y < SIZE:
			for x in (range(SIZE) if step > 0 else range(SIZE - 1, -1, -1)):
				_relax(dx, dy, x, y, p[2])
			for x in (range(SIZE - 1, -1, -1) if step > 0 else range(SIZE)):
				_relax(dx, dy, x, y, p[3])
			y += step
	var d := PackedFloat32Array()
	d.resize(n)
	for i in n:
		d[i] = sqrt(float(dx[i]) * dx[i] + float(dy[i]) * dy[i]) if dx[i] < far else 1e5
	return d


func _relax(dx: PackedInt32Array, dy: PackedInt32Array, x: int, y: int, offs: Array) -> void:
	var i := y * SIZE + x
	var best := dx[i] * dx[i] + dy[i] * dy[i] if dx[i] < 100000 else 0x7fffffff
	for o: Vector2i in offs:
		var nx := x + o.x
		var ny := y + o.y
		if nx < 0 or ny < 0 or nx >= SIZE or ny >= SIZE:
			continue
		var j := ny * SIZE + nx
		if dx[j] >= 100000:
			continue
		var cx := dx[j] + o.x
		var cy := dy[j] + o.y
		var d := cx * cx + cy * cy
		if d < best:
			best = d
			dx[i] = cx
			dy[i] = cy
