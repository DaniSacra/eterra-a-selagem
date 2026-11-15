extends SceneTree
## Erases the four painted buttons from the title painting (docs/art/title_screen_spec.md, sections 1.2 and 1.3), so the
## real buttons can be drawn over them: inside the spec's polygons every pixel becomes the smooth continuation of the
## painting around it (a harmonic fill: coarse to fine, then relaxed), outside them nothing is touched.
## Run by tools/make_title_bg.sh:  godot --headless --path . -s tools/make_title_bg.gd [-- mask_out.png]

const REF := "res://assets/ui/title/title_screen_reference.png"
const OUT := "res://assets/ui/title/title_bg.png"
## Iniciar with its amber glow.
const START: Array[Vector2] = [Vector2(910, 446), Vector2(970, 387), Vector2(1331, 387), Vector2(1391, 446), Vector2(1331, 504), Vector2(970, 504)]
## Como Jogar; Configurações and Sair are the same shape further down. The frame plus 6 px.
const SMALL: Array[Vector2] = [Vector2(1000, 543), Vector2(1029, 509), Vector2(1274, 509), Vector2(1302, 543), Vector2(1274, 576), Vector2(1029, 576)]
const SMALL_STEPS: Array[float] = [0.0, 71.0, 142.0]
## The scenery torch behind the right tip of Iniciar keeps its whole flame above y = 408.
const FLAME_KEEP := Rect2(1343, 370, 24, 38)
## Rows and columns of painting kept around the polygons while working.
const PAD := 4
## Relaxation sweeps after the coarse fill: enough for the fill to lose the blocks of the coarse levels.
const SWEEPS := 120
## Half a level of noise before rounding to 8 bits, so the smooth fill does not band.
const DITHER := 0.5 / 255.0


func _initialize() -> void:
	var img := Image.load_from_file(ProjectSettings.globalize_path(REF))
	img.convert(Image.FORMAT_RGB8)
	var polys: Array[PackedVector2Array] = [PackedVector2Array(START)]
	for step in SMALL_STEPS:
		var p := PackedVector2Array()
		for v in SMALL:
			p.append(v + Vector2(0, step))
		polys.append(p)
	var box := Rect2()
	for p in polys:
		for v in p:
			box = Rect2(v, Vector2.ZERO) if box.size == Vector2.ZERO and box.position == Vector2.ZERO else box.expand(v)
	var area := Rect2i(box.grow(PAD + 1)).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	var w := area.size.x
	var h := area.size.y
	var cols := PackedColorArray()
	var known := PackedByteArray()
	cols.resize(w * h)
	known.resize(w * h)
	var holes := PackedInt32Array()
	for y in h:
		for x in w:
			var at := Vector2(area.position.x + x, area.position.y + y)
			var inside := false
			if not FLAME_KEEP.has_point(at):
				for p in polys:
					if Geometry2D.is_point_in_polygon(at, p):
						inside = true
						break
			var i := y * w + x
			known[i] = 0 if inside else 1
			if inside:
				holes.append(i)
			else:
				cols[i] = img.get_pixel(int(at.x), int(at.y))
	_pull_push(cols, known, w, h)
	for sweep in SWEEPS:
		# alternate the direction so the fill does not lean to one corner
		if sweep % 2 == 0:
			for i in holes:
				cols[i] = (cols[i - 1] + cols[i + 1] + cols[i - w] + cols[i + w]) * 0.25
		else:
			for k in range(holes.size() - 1, -1, -1):
				var i := holes[k]
				cols[i] = (cols[i - 1] + cols[i + 1] + cols[i - w] + cols[i + w]) * 0.25
	var rng := RandomNumberGenerator.new()
	rng.seed = 1151
	var clean := img.duplicate() as Image
	for i in holes:
		var c := cols[i]
		var n := rng.randf_range(-DITHER, DITHER)
		clean.set_pixel(area.position.x + i % w, area.position.y + i / w, Color(c.r + n, c.g + n, c.b + n))
	clean.save_png(ProjectSettings.globalize_path(OUT))

	# proof: read it back and count what changed outside the polygons (must be nothing)
	var back := Image.load_from_file(ProjectSettings.globalize_path(OUT))
	back.convert(Image.FORMAT_RGB8)
	var hole_set := {}
	for i in holes:
		hole_set[Vector2i(area.position.x + i % w, area.position.y + i / w)] = true
	var changed := 0
	for y in img.get_height():
		for x in img.get_width():
			if back.get_pixel(x, y) != img.get_pixel(x, y) and not hole_set.has(Vector2i(x, y)):
				changed += 1
	print("TITLE_BG erased %d px; pixels changed outside the polygons: %d (must be 0)" % [holes.size(), changed])
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		var mask := Image.create_empty(img.get_width(), img.get_height(), false, Image.FORMAT_L8)
		for at: Vector2i in hole_set:
			mask.set_pixelv(at, Color.WHITE)
		mask.save_png(args[0])
	quit(0 if changed == 0 else 1)


## Fills the unknown pixels from a half size copy of the picture (itself filled the same way): every hole starts as
## the average of the painting around it at the scale of its distance to the edge.
func _pull_push(cols: PackedColorArray, known: PackedByteArray, w: int, h: int) -> void:
	if w <= 1 and h <= 1:
		return
	if known.count(0) == 0:
		return
	var w2 := (w + 1) / 2
	var h2 := (h + 1) / 2
	var c2 := PackedColorArray()
	var k2 := PackedByteArray()
	c2.resize(w2 * h2)
	k2.resize(w2 * h2)
	for y in h2:
		for x in w2:
			var sum := Color(0, 0, 0)
			var n := 0
			for dy in 2:
				for dx in 2:
					var sx := x * 2 + dx
					var sy := y * 2 + dy
					if sx < w and sy < h and known[sy * w + sx] == 1:
						sum += cols[sy * w + sx]
						n += 1
			if n > 0:
				c2[y * w2 + x] = sum / float(n)
				k2[y * w2 + x] = 1
	_pull_push(c2, k2, w2, h2)
	for y in h:
		for x in w:
			if known[y * w + x] == 0:
				cols[y * w + x] = c2[(y / 2) * w2 + x / 2]
