extends SceneTree
## Cuts the three painted gift medallions out of the reference board (docs/art/ref/boon_cards/02_medalhoes.png, local
## only, made by AI) into PNGs with real transparency outside the frame: assets/ui/boons/vapor.png, aurora.png,
## redemoinho.png (left to right on the board). The board's background is an almost flat dark grey: the mask is
## the grey reached from outside (a flood fill), so the bumps of the chain rims (Vapor, Aurora), the gaps between their
## outer links and the bronze rim (Redemoinho) keep their real contour; the dark metal inside the links stays. The edge is eroded one
## pixel (no dark fringe) and feathered over about two.
##   ~/tools/godot/godot --headless --path . -s tools/cut_medallions.gd   then: ~/tools/godot/godot --headless --path . --import

const BOARD := "res://docs/art/ref/boon_cards/02_medalhoes.png"
const OUT_DIR := "res://assets/ui/boons/"
const IDS: Array[String] = ["vapor", "aurora", "redemoinho"]
## Output side in pixels: the card shows the medallion at up to about 200 px at 1080 lines.
const SIDE := 512
## A pixel reached from outside is background while its largest channel difference from the grey stays under this.
const NEAR := 0.06
## A pixel no lighter than the background and this close to grey is the board's drop shadow.
const SHADOW_GREY := 0.035
## For finding each medallion's square: a pixel clearly far from the background.
const FAR := 0.075


func _initialize() -> void:
	var board := Image.load_from_file(ProjectSettings.globalize_path(BOARD))
	board.convert(Image.FORMAT_RGBA8)
	var bg := _average(board, Rect2i(4, 4, 24, 24))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var third := board.get_width() / IDS.size()
	for i in IDS.size():
		var region := Rect2i(i * third, 0, third, board.get_height())
		var box := _bounds(board, region, bg)
		var out := _cut(board, box, bg)
		out.resize(SIDE, SIDE, Image.INTERPOLATE_LANCZOS)
		var path := ProjectSettings.globalize_path(OUT_DIR + IDS[i] + ".png")
		out.save_png(path)
		print("MEDALLION %s box=%s -> %s" % [IDS[i], box, path])
	quit()


func _average(img: Image, r: Rect2i) -> Color:
	var sum := Color(0, 0, 0, 0)
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			sum += img.get_pixel(x, y)
	return sum / float(r.get_area())


## Near the board's grey, or the board's shadow: grey and darker than it (the dark metal is brown, the insides coloured).
func _background(c: Color, bg: Color) -> bool:
	if _far(c, bg) <= NEAR:
		return true
	var hi := maxf(c.r, maxf(c.g, c.b))
	var lo := minf(c.r, minf(c.g, c.b))
	return hi <= maxf(bg.r, maxf(bg.g, bg.b)) + 0.01 and hi - lo < SHADOW_GREY


func _far(c: Color, bg: Color) -> float:
	return maxf(absf(c.r - bg.r), maxf(absf(c.g - bg.g), absf(c.b - bg.b)))


## The square around the medallion in a region: the extent of the pixels far from the background (a few stray ones
## do not count: a row or column needs several).
func _bounds(img: Image, region: Rect2i, bg: Color) -> Rect2i:
	var x0 := region.end.x
	var x1 := region.position.x
	var y0 := region.end.y
	var y1 := region.position.y
	for y in range(region.position.y, region.end.y):
		var n := 0
		var first := -1
		var last := -1
		for x in range(region.position.x, region.end.x):
			if _far(img.get_pixel(x, y), bg) > FAR:
				n += 1
				if first < 0:
					first = x
				last = x
		if n >= 6:
			y0 = mini(y0, y)
			y1 = maxi(y1, y)
			x0 = mini(x0, first)
			x1 = maxi(x1, last)
	var side := maxi(x1 - x0, y1 - y0) + 1
	var c := Vector2i((x0 + x1) / 2, (y0 + y1) / 2)
	return Rect2i(c - Vector2i(side, side) / 2, Vector2i(side, side))


func _cut(img: Image, box: Rect2i, bg: Color) -> Image:
	var w := box.size.x
	var r := w * 0.5
	# everything is the medallion except the background reached from outside: a flood over near-grey pixels (the dark
	# metal inside the links and the dark gap behind the bronze rim are enclosed, so they stay)
	var mask := PackedFloat32Array()
	mask.resize(w * w)
	mask.fill(1.0)
	var near := PackedByteArray()
	near.resize(w * w)
	for y in w:
		for x in w:
			var p := box.position + Vector2i(x, y)
			var out_of := Vector2(x + 0.5 - r, y + 0.5 - r).length() > r * 1.01
			var inside := p.x >= 0 and p.y >= 0 and p.x < img.get_width() and p.y < img.get_height()
			near[y * w + x] = 1 if out_of or not inside or _background(img.get_pixel(p.x, p.y), bg) else 0
	var todo: Array[Vector2i] = []
	for i in w:
		for q in [Vector2i(i, 0), Vector2i(i, w - 1), Vector2i(0, i), Vector2i(w - 1, i)]:
			todo.append(q)
	while not todo.is_empty():
		var q: Vector2i = todo.pop_back()
		if q.x < 0 or q.y < 0 or q.x >= w or q.y >= w:
			continue
		var k := q.y * w + q.x
		if mask[k] == 0.0 or near[k] == 0:
			continue
		mask[k] = 0.0
		todo.append(q + Vector2i(1, 0))
		todo.append(q + Vector2i(-1, 0))
		todo.append(q + Vector2i(0, 1))
		todo.append(q + Vector2i(0, -1))
	# only the medallion itself: the largest piece once thin bridges are cut (2 px erosion), grown back, so loose bits
	# of the board's shadow next to the chain go; then one pixel off the edge (no half-grey fringe) and a small blur
	var body := _dilate(_largest(_erode(mask, w, 2), w), w, 3)
	var eroded := _erode(mask, w, 1)
	for k in eroded.size():
		eroded[k] = minf(eroded[k], body[k])
	var out := Image.create(w, w, false, Image.FORMAT_RGBA8)
	for y in w:
		for x in w:
			var a := 0.0
			var n := 0
			for oy in range(-1, 2):
				for ox in range(-1, 2):
					var qx := x + ox
					var qy := y + oy
					if qx >= 0 and qy >= 0 and qx < w and qy < w:
						a += eroded[qy * w + qx]
						n += 1
			a /= n
			var p := box.position + Vector2i(x, y)
			var c := Color(0, 0, 0, 0)
			if a > 0.0 and p.x >= 0 and p.y >= 0 and p.x < img.get_width() and p.y < img.get_height():
				c = img.get_pixel(p.x, p.y)
				c.a = a
			out.set_pixel(x, y, c)
	return out


func _erode(m: PackedFloat32Array, w: int, times: int) -> PackedFloat32Array:
	var cur := m
	for t in times:
		var nxt := PackedFloat32Array()
		nxt.resize(w * w)
		for y in w:
			for x in w:
				var v := cur[y * w + x]
				if v > 0.0 and (x == 0 or y == 0 or x == w - 1 or y == w - 1 or cur[y * w + x - 1] == 0.0 \
						or cur[y * w + x + 1] == 0.0 or cur[(y - 1) * w + x] == 0.0 or cur[(y + 1) * w + x] == 0.0):
					v = 0.0
				nxt[y * w + x] = v
		cur = nxt
	return cur


func _dilate(m: PackedFloat32Array, w: int, times: int) -> PackedFloat32Array:
	var cur := m
	for t in times:
		var nxt := cur.duplicate()
		for y in range(1, w - 1):
			for x in range(1, w - 1):
				if cur[y * w + x] == 0.0 and (cur[y * w + x - 1] > 0.0 or cur[y * w + x + 1] > 0.0 \
						or cur[(y - 1) * w + x] > 0.0 or cur[(y + 1) * w + x] > 0.0):
					nxt[y * w + x] = 1.0
		cur = nxt
	return cur


## Only the largest 4-connected piece of the mask.
func _largest(m: PackedFloat32Array, w: int) -> PackedFloat32Array:
	var label := PackedInt32Array()
	label.resize(w * w)
	var best := 0
	var best_n := 0
	var next := 1
	for start in w * w:
		if m[start] == 0.0 or label[start] != 0:
			continue
		var n := 0
		var todo: Array[int] = [start]
		label[start] = next
		while not todo.is_empty():
			var k: int = todo.pop_back()
			n += 1
			var x := k % w
			for q in [k - 1 if x > 0 else -1, k + 1 if x < w - 1 else -1, k - w, k + w]:
				if q >= 0 and q < w * w and m[q] > 0.0 and label[q] == 0:
					label[q] = next
					todo.append(q)
		if n > best_n:
			best_n = n
			best = next
		next += 1
	var out := PackedFloat32Array()
	out.resize(w * w)
	for k in w * w:
		out[k] = 1.0 if label[k] == best else 0.0
	return out
