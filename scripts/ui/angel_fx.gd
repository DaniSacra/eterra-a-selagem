class_name AngelFx
extends Control
## BC-3: the slow effect of an angel's family, drawn behind and around its figure (shared by the Encontro and the
## Bênção's screen, through AngelStage). Cheap: `_draw` only (additive, no particle nodes), every particle a pure
## function of time, so it runs in Compatibility. Embers (Chama), flakes and crystals (Geada), shafts of light (Luz),
## guard runes (Vigília), aiming marks and arrows (Marca), water spirals (Maré), veils of mist (Véu).
##   var fx := AngelFx.new().setup(Boon.Family.GEADA)   # set center, reach and strength (0..1) from outside

var family := Boon.Family.LUZ
## 0 off, 1 full: the angel in focus is lit, the other low.
var strength := 1.0
var center := Vector2.ZERO
var reach := 200.0
## The side the figure stands on: the arrows lean the other way when mirrored.
var flip := false
var _t := 0.0


func setup(f: Boon.Family, p_flip := false) -> AngelFx:
	family = f
	flip = p_flip
	_t = float(f) * 7.3
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = m
	return self


## A repeatable number in 0..1 for particle i and trait k.
static func hash01(i: int, k: int) -> float:
	return fposmod(sin(float(i) * 12.9898 + float(k) * 78.233) * 43758.5453, 1.0)


func _process(delta: float) -> void:
	if is_visible_in_tree():
		_t += delta
		queue_redraw()


func _draw() -> void:
	if strength < 0.02 or size.y < 1.0:
		return
	var col := AngelSeal.tint(family).lightened(0.25)
	for k in 7:
		draw_circle(center, reach * (1.1 - k * 0.12), Color(col, 0.02 * strength))
	match family:
		Boon.Family.CHAMA: _embers(col)
		Boon.Family.GEADA: _frost(col)
		Boon.Family.LUZ: _light(col)
		Boon.Family.VIGILIA: _runes(col)
		Boon.Family.MARCA: _marks(col)
		Boon.Family.MARE: _water(col)
		Boon.Family.VEU: _veils(col)


func _s() -> float:
	return size.y / 720.0


func _rise(i: int, speed: float) -> float:
	return fposmod(_t * (speed * (0.7 + 0.6 * hash01(i, 2))) + hash01(i, 3), 1.0)


func _embers(col: Color) -> void:
	var s := _s()
	for i in 34:
		var p := _rise(i, 0.06)
		var pos := Vector2(center.x + (hash01(i, 0) - 0.5) * reach * 1.7 + sin(_t * 0.7 + hash01(i, 1) * TAU) * 14.0 * s, size.y * (1.0 - p * 0.92))
		var a := sin(p * PI) * strength
		var r := (1.2 + 2.6 * hash01(i, 4)) * s
		draw_circle(pos, r * 2.8, Color(col, a * 0.12))
		draw_circle(pos, r, Color(col.lightened(0.3), a * 0.85))


func _frost(col: Color) -> void:
	var s := _s()
	for i in 30:
		var p := _rise(i, 0.04)
		var pos := Vector2(center.x + (hash01(i, 0) - 0.5) * reach * 1.8 + sin(_t * 0.5 + hash01(i, 1) * TAU) * 18.0 * s, size.y * p)
		var a := sin(p * PI) * strength * 0.8
		var sz := (3.0 + 5.0 * hash01(i, 4)) * s
		var ang := _t * (hash01(i, 1) - 0.5) + hash01(i, 0) * 3.0
		for k in 3:
			var v := Vector2.from_angle(ang + k * PI / 3.0) * sz
			draw_line(pos - v, pos + v, Color(col, a), maxf(1.0, 1.2 * s))
	for i in 5:
		var x := center.x + (i - 2) * reach * 0.42
		var h := (70.0 + 60.0 * hash01(i, 7)) * s * (0.85 + 0.15 * sin(_t * 0.6 + i))
		var w := 14.0 * s
		var pts := PackedVector2Array([Vector2(x - w, size.y), Vector2(x, size.y - h), Vector2(x + w, size.y)])
		draw_colored_polygon(pts, Color(col, 0.13 * strength))
		draw_polyline(pts, Color(col, 0.5 * strength), maxf(1.0, 1.4 * s))


func _light(col: Color) -> void:
	var s := _s()
	for i in 6:
		var x0 := center.x + (i - 2.5) * reach * 0.5 + sin(_t * 0.25 + i * 1.3) * 30.0 * s
		var w0 := (12.0 + 10.0 * hash01(i, 5)) * s
		var lean := size.y * 0.3 * (-1.0 if flip else 1.0)
		var a := (0.1 + 0.06 * sin(_t * 0.6 + i * 2.0)) * strength
		draw_polygon(PackedVector2Array([Vector2(x0 - w0, 0), Vector2(x0 + w0, 0), Vector2(x0 + lean + w0 * 3.0, size.y), Vector2(x0 + lean - w0 * 3.0, size.y)]),
			PackedColorArray([Color(col, a), Color(col, a), Color(col, 0.0), Color(col, 0.0)]))
	for i in 14:
		var p := _rise(i, 0.03)
		var pos := Vector2(center.x + (hash01(i, 0) - 0.5) * reach * 1.6, size.y * (1.0 - p))
		draw_circle(pos, (1.5 + 1.5 * hash01(i, 4)) * s, Color(SealMedal.IVORY, sin(p * PI) * 0.7 * strength))


func _runes(col: Color) -> void:
	var s := _s()
	var n := 10
	draw_set_transform(center, 0.0, Vector2(0.85, 1.05))
	draw_arc(Vector2.ZERO, reach, 0.0, TAU, 64, Color(col, 0.14 * strength), maxf(1.0, 1.2 * s))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for i in n:
		var ang := _t * 0.14 + i * TAU / n
		var pos := center + Vector2(cos(ang) * reach * 0.85, sin(ang) * reach * 1.05)
		var c := Color(col, (0.45 + 0.35 * sin(_t * 0.9 + i)) * strength)
		var g := 9.0 * s
		var w := maxf(1.2, 1.6 * s)
		match i % 4:
			0:
				draw_line(pos + Vector2(0, -g), pos + Vector2(0, g), c, w)
				draw_line(pos + Vector2(0, -g * 0.2), pos + Vector2(g * 0.7, -g), c, w)
			1:
				draw_polyline(PackedVector2Array([pos + Vector2(-g * 0.7, g * 0.5), pos + Vector2(0, -g), pos + Vector2(g * 0.7, g * 0.5)]), c, w)
			2:
				draw_line(pos + Vector2(0, -g), pos + Vector2(0, g), c, w)
				draw_line(pos + Vector2(-g * 0.6, -g * 0.3), pos + Vector2(g * 0.6, -g * 0.3), c, w)
				draw_line(pos + Vector2(-g * 0.4, g * 0.4), pos + Vector2(g * 0.4, g * 0.4), c, w)
			_:
				draw_polyline(PackedVector2Array([pos + Vector2(0, -g), pos + Vector2(g * 0.7, 0), pos + Vector2(0, g), pos + Vector2(-g * 0.7, 0), pos + Vector2(0, -g)]), c, w)


func _marks(col: Color) -> void:
	var s := _s()
	for i in 3:
		var ph := fposmod(_t / (4.0 + i) + hash01(i, 0), 1.0)
		var pos := center + Vector2((hash01(i, 1) - 0.5) * reach * 1.4, (hash01(i, 2) - 0.5) * size.y * 0.6)
		var closing := ph < 0.7
		var r := (lerpf(46.0, 16.0, ph / 0.7) if closing else lerpf(16.0, 40.0, (ph - 0.7) / 0.3)) * s
		var a := (minf(ph * 4.0, 1.0) if closing else 1.0 - (ph - 0.7) / 0.3) * 0.8 * strength
		var c := Color(col, a)
		draw_arc(pos, r, 0.0, TAU, 32, c, maxf(1.0, 1.5 * s))
		for k in 4:
			var d := Vector2.from_angle(k * PI * 0.5)
			draw_line(pos + d * (r - 6.0 * s), pos + d * (r + 8.0 * s), c, maxf(1.0, 1.5 * s))
		draw_circle(pos, 2.0 * s, c)
	var dir := Vector2(-0.35 if flip else 0.35, -1.0).normalized()
	for i in 7:
		var p := _rise(i, 0.09)
		var pos := Vector2(center.x + (hash01(i, 0) - 0.5) * reach * 1.8, size.y * (1.05 - p * 1.1))
		var c := Color(col, sin(p * PI) * 0.7 * strength)
		draw_line(pos, pos - dir * 26.0 * s, c, maxf(1.0, 1.4 * s))
		for sgn in [-1.0, 1.0]:
			draw_line(pos, pos - dir.rotated(sgn * 0.45) * 8.0 * s, c, maxf(1.0, 1.4 * s))


func _water(col: Color) -> void:
	var s := _s()
	for k in 3:
		var pts := PackedVector2Array()
		var cols := PackedColorArray()
		for j in 41:
			var th := j * 0.16
			var r := reach * (0.12 + th * 0.11)
			var a := th + _t * 0.35 + k * TAU / 3.0
			pts.append(center + Vector2(cos(a) * r * 0.8, sin(a) * r * 1.1))
			cols.append(Color(col, (1.0 - j / 40.0) * 0.35 * strength))
		draw_polyline_colors(pts, cols, maxf(1.2, 2.0 * s))
	for i in 16:
		var p := _rise(i, 0.07)
		var pos := Vector2(center.x + (hash01(i, 0) - 0.5) * reach * 1.7, size.y * (1.0 - p))
		draw_arc(pos, (3.0 + 5.0 * hash01(i, 4)) * s, 0.0, TAU, 12, Color(col, sin(p * PI) * 0.6 * strength), maxf(1.0, s))


func _veils(col: Color) -> void:
	for i in 7:
		var x := center.x + sin(_t * (0.07 + 0.03 * hash01(i, 0)) + hash01(i, 1) * TAU) * reach
		var y := size.y * (0.12 + 0.8 * hash01(i, 2)) + sin(_t * 0.2 + i) * 20.0 * _s()
		draw_set_transform(Vector2(x, y), 0.0, Vector2(2.6, 0.7))
		for k in 4:
			draw_circle(Vector2.ZERO, reach * (0.5 - k * 0.09) * 0.6, Color(col, 0.035 * strength))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
