class_name AhkVignette
extends Control
## The vignette over the title of the Livro de Ahk (AP-4 1.4): three objects in sepia ink and no figure, no face, no
## hand: a half open papyrus roll with lines of writing that read as nothing (as the hub's page), a quill in its
## inkwell and a shut roll under a seal of rubric wax with the lion of the Chamber's seal (the same drawing, in the
## wax's own colour). Contours 1.4 px, hatching on the sides away from the light (top left), a wash of FADED there.
## Drawn in a 240 x 133 box and scaled to what it is given.
##   v := AhkVignette.new()   # custom_minimum_size is the 240 x 133 box

const BOX := Vector2(240, 133)
const LINE := 1.4
const WASH := Color(0.38, 0.31, 0.23, 0.15)
const WAX := Color(0.47, 0.13, 0.09)
## The seal's centre and radius in the box.
const SEAL_AT := Vector2(209, 93)
const SEAL_R := 12.0

var _lion: TextureRect


func _init() -> void:
	name = "vignette"
	custom_minimum_size = BOX
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lion = TextureRect.new()
	_lion.texture = SealEmblem.LION
	_lion.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lion.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_lion.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = SealEmblem.SHADER
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter(&"spread", SealEmblem.SPREAD)
	mat.set_shader_parameter(&"gold", WAX.darkened(0.45))
	mat.set_shader_parameter(&"cut_color", WAX.darkened(0.45))
	_lion.material = mat
	add_child(_lion)
	resized.connect(_place)
	_place()


func _scale() -> float:
	return minf(size.x / BOX.x, size.y / BOX.y) if size.x > 0.0 else 1.0


func _place() -> void:
	var u := _scale()
	var d := SEAL_R * 1.5 * u
	_lion.position = _origin() + SEAL_AT * u - Vector2(d, d) * 0.5
	_lion.size = Vector2(d, d)
	queue_redraw()


func _origin() -> Vector2:
	return (size - BOX * _scale()) * 0.5


func _draw() -> void:
	var u := _scale()
	draw_set_transform(_origin(), 0.0, Vector2(u, u))
	_papyrus()
	_inkwell()
	_closed_roll()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _stroke(pts: PackedVector2Array, w: float = LINE, c: Color = Book.INK) -> void:
	draw_polyline(pts, c, w, true)


## The open roll: a sheet with a rolled end on each side (cylinders) and lines of writing that mean nothing.
func _papyrus() -> void:
	var l := 14.0
	var r := 128.0
	var t := 22.0
	var b := 102.0
	var sheet := PackedVector2Array([Vector2(l + 8, t), Vector2(r - 8, t), Vector2(r - 8, b), Vector2(l + 8, b)])
	draw_colored_polygon(sheet, Color(Book.PAPER.lightened(0.12), 0.9))
	draw_colored_polygon(PackedVector2Array([Vector2(l + 8, b - 22), Vector2(r - 8, b - 22), Vector2(r - 8, b), Vector2(l + 8, b)]), WASH)
	_stroke(PackedVector2Array([Vector2(l + 8, t), Vector2(r - 8, t)]))
	_stroke(PackedVector2Array([Vector2(l + 8, b), Vector2(r - 8, b)]))
	# the writing: short ink strokes in lines, never letters
	var rng := RandomNumberGenerator.new()
	rng.seed = 20
	for row in 8:
		var y := t + 9.0 + row * 8.2
		var x := l + 17.0
		var end := r - 17.0 - (rng.randf() * 22.0 if row % 3 == 2 else 0.0)
		while x < end:
			var run := 4.0 + rng.randf() * 9.0
			var x2 := minf(x + run, end)
			draw_line(Vector2(x, y), Vector2(x2, y + rng.randf_range(-0.4, 0.4)), Color(Book.INK, 0.7), 1.1, true)
			x = x2 + 2.6
	# the rolls at both ends: a cylinder seen from the side, ellipse caps, hatching on the right-hand one
	_roll(Vector2(l, t - 2.0), Vector2(l + 16, b + 2.0), true)
	_roll(Vector2(r - 16, t - 2.0), Vector2(r, b + 2.0), false)
	# the shadow of the sheet on the table
	draw_line(Vector2(l + 4, b + 7), Vector2(r - 2, b + 7), Color(Book.FADED, 0.35), 1.0, true)


func _roll(a: Vector2, b: Vector2, left: bool) -> void:
	var w := b.x - a.x
	var cx := (a.x + b.x) * 0.5
	draw_rect(Rect2(a, b - a), Color(Book.PAPER.darkened(0.04), 0.95))
	draw_rect(Rect2(Vector2(cx + (0.0 if left else -w * 0.15), a.y), Vector2(w * (0.5 if left else 0.65), b.y - a.y)), WASH)
	_stroke(PackedVector2Array([Vector2(a.x, a.y), Vector2(a.x, b.y)]))
	_stroke(PackedVector2Array([Vector2(b.x, a.y), Vector2(b.x, b.y)]))
	for y: float in [a.y, b.y]:
		_ellipse(Vector2(cx, y), w * 0.5, 3.4)
	# hatching on the side away from the light
	var hx := b.x - 3.0
	for y in range(int(a.y) + 6, int(b.y) - 4, 4):
		draw_line(Vector2(hx, y), Vector2(hx - 3.5, y + 3.0), Color(Book.INK, 0.5), 1.0, true)
	# the spiral of the roll's end on the near cap
	_stroke(PackedVector2Array([Vector2(cx - w * 0.2, a.y), Vector2(cx, a.y + 1.4), Vector2(cx + w * 0.22, a.y - 0.4)]), 1.0)


func _ellipse(c: Vector2, rx: float, ry: float, w: float = LINE, color: Color = Book.INK) -> void:
	var pts := PackedVector2Array()
	for i in 25:
		var a := TAU * float(i) / 24.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(pts, color, w, true)


## A quill in an inkwell: a squat jar with a lip, a feather leaning out of it.
func _inkwell() -> void:
	var c := Vector2(158, 96)
	var jar := PackedVector2Array([c + Vector2(-13, -12), c + Vector2(13, -12), c + Vector2(17, 14), c + Vector2(-17, 14)])
	draw_colored_polygon(jar, Color(Book.PAPER.darkened(0.06), 0.95))
	draw_colored_polygon(PackedVector2Array([c + Vector2(2, -12), c + Vector2(13, -12), c + Vector2(17, 14), c + Vector2(2, 14)]), WASH)
	_stroke(PackedVector2Array([jar[0], jar[3], jar[2], jar[1]]))
	_ellipse(c + Vector2(0, -12), 13.0, 3.6)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-9, -12), c + Vector2(0, -14.2), c + Vector2(9, -12), c + Vector2(0, -9.8)]), Color(Book.INK, 0.85))
	for y in [-4, 2, 8]:
		draw_line(c + Vector2(8, y), c + Vector2(13.5, y + 3.5), Color(Book.INK, 0.5), 1.0, true)
	# the feather: a shaft from the jar's mouth up and to the right, a vane of two barbed halves
	var tip := Vector2(196, 18)
	var root := c + Vector2(-2, -12)
	_stroke(PackedVector2Array([root, tip]), 1.6)
	var d := (tip - root).normalized()
	var perp := Vector2(-d.y, d.x)
	var base := root + d * 18.0
	var vane := PackedVector2Array()
	for i in 9:
		var t := float(i) / 8.0
		vane.append(base.lerp(tip, t) + perp * sin(t * PI) * 13.0 * (1.0 - t * 0.2))
	for i in 9:
		var t := 1.0 - float(i) / 8.0
		vane.append(base.lerp(tip, t))
	draw_colored_polygon(vane, Color(Book.PAPER.lightened(0.1), 0.9))
	var outer := PackedVector2Array()
	for i in 9:
		var t := float(i) / 8.0
		outer.append(base.lerp(tip, t) + perp * sin(t * PI) * 13.0 * (1.0 - t * 0.2))
	_stroke(outer, 1.2)
	for i in range(1, 8):
		var t := float(i) / 8.0
		var q := base.lerp(tip, t)
		draw_line(q, q + perp * sin(t * PI) * 13.0 * (1.0 - t * 0.2) - d * 3.0, Color(Book.INK, 0.5), 1.0, true)


## The shut roll lying across the foot with a ribbon and a wax seal on it.
func _closed_roll() -> void:
	var a := Vector2(186, 84)
	var b := Vector2(236, 106)
	draw_rect(Rect2(a, b - a), Color(Book.PAPER.darkened(0.04), 0.95))
	draw_rect(Rect2(Vector2(a.x, a.y + 12.0), Vector2(b.x - a.x, b.y - a.y - 12.0)), WASH)
	_stroke(PackedVector2Array([a, Vector2(b.x, a.y)]))
	_stroke(PackedVector2Array([Vector2(a.x, b.y), b]))
	_ellipse(Vector2(a.x, (a.y + b.y) * 0.5), 3.4, (b.y - a.y) * 0.5)
	_ellipse(Vector2(b.x, (a.y + b.y) * 0.5), 3.4, (b.y - a.y) * 0.5)
	# the ribbon under the seal
	for dx: float in [-5.0, 5.0]:
		draw_line(Vector2(SEAL_AT.x + dx, a.y), Vector2(SEAL_AT.x + dx, b.y), Color(Book.INK, 0.8), 1.0, true)
	# the wax: a disc with an uneven edge, a lit rim on the upper left and a dark one under it
	var rim := PackedVector2Array()
	for i in 29:
		var ang := TAU * float(i) / 28.0
		rim.append(SEAL_AT + Vector2(cos(ang), sin(ang)) * SEAL_R * (1.0 + 0.09 * sin(ang * 5.0 + 1.0)))
	draw_colored_polygon(rim, WAX)
	draw_arc(SEAL_AT, SEAL_R * 0.8, PI * 0.9, PI * 1.6, 12, WAX.lightened(0.3), 1.2, true)
	draw_arc(SEAL_AT, SEAL_R * 0.8, -PI * 0.1, PI * 0.6, 12, WAX.darkened(0.45), 1.2, true)
	_stroke(rim, 1.2, Color(Book.INK, 0.8))
