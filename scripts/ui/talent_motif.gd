class_name TalentMotif
extends RefCounted
## The painted motif of each of the Warrior's 19 Gifts (AP-4, ART P1-10, spec docs/art/ap4_spec.md 2.2): the same
## drawing as its TalentGlyph (the glyph is the skeleton, the motif dresses it), in vector paint for the places with room
## (a node of the tree, the Gift's detail in the Compêndio, its panel in the Livro). One recipe for all 19, as from one
## hand: up to three tones per shape with hard edges, the base in the branch's colour taken to the paper (Book.ink,
## saturation under SAT_MAX), the shade at SHADE of its value over the lower right, the light at LIGHT (no channel over
## LIGHT_CAP) over the upper left, a thread of engraved gilt (Book.GILT) on a lit edge of each main shape and an outline
## of the Livro's ink round everything; inner detail (facets, veins) only from DETAIL_FROM px of radius. Light always
## from the upper left. Never a cross, a sun, an eye, a chain of links, a lion or an upright blade with a guard.
##   TalentMotif.draw(self, &"quarto_corte", centre, radius, HeroLoadout.State.OPEN)
## Under LOD_UNDER px of radius it draws the glyph alone (TalentGlyph.draw), as does a Gift without a motif (false).
## tools/motif_sheet.gd draws the board and measures it (silhouettes apart, contrast, colour).

const SHADE := 0.62
const LIGHT := 1.22
const LIGHT_CAP := 0.9
const SAT_MAX := 0.58
const DETAIL_FROM := 22.0
const LOD_UNDER := 14.0
## Outline of ink, px for a radius (1.5 at the tree's 16 px at 720, 2 at its 24 px at 1080), clamped.
const OUTLINE_PER_R := 0.095
const OUTLINE_MIN := 1.5
const OUTLINE_MAX := 3.0
## A locked Gift: the motif at this strength, its outline still there.
const LOCKED_ALPHA := 0.35
const SEALED_ALPHA := 0.6

## The palette by key: the six branches (TalentNode.BRANCH_COLOR) and the few things the motifs show.
const PALE := Color(0.86, 0.82, 0.7)
const STONE := Color(0.6, 0.55, 0.47)
const STEEL := Color(0.72, 0.72, 0.68)

static var _cache := {}
static var _branches := {}


## The colour of a key on the paper (base tone).
static func tone(key: String) -> Color:
	var c: Color
	match key:
		"carmine": c = TalentNode.BRANCH_COLOR[TalentDef.Branch.COMBO]
		"rust": c = TalentNode.BRANCH_COLOR[TalentDef.Branch.FURIA]
		"emerald": c = TalentNode.BRANCH_COLOR[TalentDef.Branch.EMETH]
		"blue": c = TalentNode.BRANCH_COLOR[TalentDef.Branch.MAGIA]
		"gold": c = TalentNode.BRANCH_COLOR[TalentDef.Branch.BRIDGE]
		"terra": c = TalentNode.BRANCH_COLOR[TalentDef.Branch.SUSTAIN]
		"pale": return PALE
		"stone": return STONE
		"steel": return STEEL
		_: c = TalentNode.CENTRE
	var on_paper := Book.ink(c)
	# Book.ink keeps the text dark; the paint sits a step lighter, never over SAT_MAX
	return Color.from_hsv(on_paper.h, minf(on_paper.s, SAT_MAX), 0.52)


## The branch of a Gift (its TalentDef in data/talents/warrior), -1 when unknown.
static func branch_of(id: StringName) -> int:
	if _branches.is_empty():
		for f in DirAccess.get_files_at("res://data/talents/warrior"):
			if f.ends_with(".tres"):
				var t := load("res://data/talents/warrior/" + f) as TalentDef
				if t != null:
					_branches[t.id] = t.branch
	return int(_branches.get(id, -1))


static func has(id: StringName) -> bool:
	return not shapes(id).is_empty()


## Draws the Gift's motif in radius r around c. False when it has none (the caller draws its glyph or its branch's).
static func draw(ci: CanvasItem, id: StringName, c: Vector2, r: float, state: int = HeroLoadout.State.OPEN) -> bool:
	var parts := shapes(id)
	if parts.is_empty():
		return false
	var alpha := 1.0
	var grey := 0.0
	match state:
		HeroLoadout.State.LOCKED:
			alpha = LOCKED_ALPHA
		HeroLoadout.State.SEALED:
			alpha = SEALED_ALPHA
		HeroLoadout.State.BLOCKED:
			alpha = 0.75
			grey = 0.7
	if r < LOD_UNDER:
		var col := Color(Book.INK, alpha)
		return TalentGlyph.draw(ci, id, c, r, col, Color(Book.PAPER, alpha))
	var line := clampf(r * OUTLINE_PER_R, OUTLINE_MIN, OUTLINE_MAX)
	var ink := Color(Book.INK, alpha)
	var gilt := Color(Book.GILT.lightened(0.15), alpha)
	for part: Dictionary in parts:
		var poly: PackedVector2Array = _placed(part.p, c, r)
		var base := tone(part.k)
		if grey > 0.0:
			base = base.lerp(Color(base.get_luminance(), base.get_luminance(), base.get_luminance()), grey)
		if part.get("hollow", false):
			ci.draw_polyline(_closed(poly), Color(base, alpha), maxf(line, r * 0.07), true)
			ci.draw_polyline(_closed(poly), ink, maxf(1.0, line * 0.5), true)
			continue
		_paint(ci, poly, base, alpha)
		if part.get("main", false):
			_gilt_edge(ci, poly, gilt, maxf(1.0, line * 0.5))
		if r >= DETAIL_FROM and part.has("detail"):
			for seg: PackedVector2Array in part.detail:
				ci.draw_polyline(_placed(seg, c, r), Color(Book.INK, 0.5 * alpha), maxf(1.0, line * 0.5), true)
		ci.draw_polyline(_closed(poly), ink, line, true)
	return true


## The three tones of a shape: base, the shade over its lower right, the light over its upper left (hard edges).
static func _paint(ci: CanvasItem, poly: PackedVector2Array, base: Color, alpha: float) -> void:
	ci.draw_colored_polygon(poly, Color(base, alpha))
	var box := _box(poly)
	var mid := box.get_center()
	var reach := box.size.length() * 0.5
	var lit := Color(minf(base.r * LIGHT, LIGHT_CAP), minf(base.g * LIGHT, LIGHT_CAP), minf(base.b * LIGHT, LIGHT_CAP), alpha)
	var dark := Color(base.r * SHADE, base.g * SHADE, base.b * SHADE, alpha)
	var d := Vector2(1, 1).normalized()
	var n := Vector2(-d.y, d.x)
	for piece in Geometry2D.intersect_polygons(poly, _half(mid + d * reach * 0.05, d, n, reach * 3.0)):
		ci.draw_colored_polygon(piece, dark)
	for piece in Geometry2D.intersect_polygons(poly, _half(mid - d * reach * 0.4, -d, n, reach * 3.0)):
		ci.draw_colored_polygon(piece, lit)


## The half plane past p facing d, as a big square.
static func _half(p: Vector2, d: Vector2, n: Vector2, size: float) -> PackedVector2Array:
	return PackedVector2Array([p + n * size, p + n * size + d * size, p - n * size + d * size, p - n * size])


## The thread of gilt on the longest run of the shape's edges that face the light (upper left).
static func _gilt_edge(ci: CanvasItem, poly: PackedVector2Array, col: Color, width: float) -> void:
	var light := Vector2(-1, -1).normalized()
	var clockwise := _area(poly) > 0.0
	var best := PackedVector2Array()
	var run := PackedVector2Array()
	var length := 0.0
	var best_length := 0.0
	for i in poly.size() + 1:
		var a := poly[i % poly.size()]
		var b := poly[(i + 1) % poly.size()]
		var e := b - a
		var out := Vector2(e.y, -e.x) if clockwise else Vector2(-e.y, e.x)
		if i < poly.size() and out.normalized().dot(light) > 0.45:
			if run.is_empty():
				run.append(a)
			run.append(b)
			length += e.length()
		else:
			if length > best_length:
				best_length = length
				best = run
			run = PackedVector2Array()
			length = 0.0
	if best.size() >= 2:
		ci.draw_polyline(best, col, width, true)


static func _area(poly: PackedVector2Array) -> float:
	var s := 0.0
	for i in poly.size():
		var a := poly[i]
		var b := poly[(i + 1) % poly.size()]
		s += a.x * b.y - b.x * a.y
	return s * 0.5


static func _box(poly: PackedVector2Array) -> Rect2:
	var box := Rect2(poly[0], Vector2.ZERO)
	for p in poly:
		box = box.expand(p)
	return box


static func _placed(unit: PackedVector2Array, c: Vector2, r: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(unit.size())
	for i in unit.size():
		out[i] = c + unit[i] * r
	return out


static func _closed(poly: PackedVector2Array) -> PackedVector2Array:
	var out := poly.duplicate()
	if out.size() > 0:
		out.append(poly[0])
	return out


# ---------- the 19 motifs, in a unit circle (y down), as shapes: {p: polygon, k: colour key, main, hollow, detail} ----------

## The shapes of a Gift's motif (cached), [] when it has none.
static func shapes(id: StringName) -> Array:
	if _cache.has(id):
		return _cache[id]
	var out := _build(id)
	_cache[id] = out
	return out


static func _build(id: StringName) -> Array:
	var s: Array = []
	match id:
		&"quarto_corte":
			# three cuts in carmine, growing, and the fourth a longer narrow point in emerald on the same diagonal
			var d := Vector2(0.6, -0.8)
			var n := Vector2(0.8, 0.6)
			for k in 3:
				_add(s, _lens(n * (k - 1.6) * 0.36 + Vector2(-0.05, 0.05), d, 0.42 + 0.1 * k, 0.17), "carmine", k == 2)
			_add(s, _blade(n * 0.55 + Vector2(-0.12, 0.12) - d * 0.75, n * 0.55 + Vector2(-0.12, 0.12) + d * 0.88, 0.16), "emerald", true)
		&"passo_encadeado":
			for y: float in [0.3, 0.62]:
				_add_all(s, _stroke([Vector2(-0.98, y), Vector2(-0.62, y)], 0.1), "carmine")
			_add_all(s, _stroke([Vector2(-0.72, 0.9), Vector2(-0.15, 0.9), Vector2(0.25, 0.62), Vector2(0.52, 0.05), Vector2(0.78, -0.8)], 0.22), "carmine", true)
		&"golpe_sem_fim":
			_add(s, _ring(Vector2.ZERO, 0.78, 0.2, deg_to_rad(120), deg_to_rad(400)), "carmine", true)
			var end := deg_to_rad(400)
			var tip := Vector2.from_angle(end) * 0.78
			_add(s, _head(tip, Vector2.from_angle(end + PI * 0.5), 0.34), "carmine")
			for k in 3:
				var a := deg_to_rad(160 + k * 70)
				_add(s, _ring(Vector2.ZERO, 0.98, 0.07, a, a + deg_to_rad(22)), "carmine")
			_add(s, _lens(Vector2.ZERO, Vector2(0.6, -0.8), 0.34, 0.16), "carmine")
		&"impeto":
			for k in 2:
				_add(s, _chevron(Vector2(-0.72 + k * 0.5, 0.0), 0.26 + 0.08 * k, 0.1), "rust", false, true)
			_add(s, _chevron(Vector2(0.42, 0.0), 0.52, 0.3), "rust", true)
		&"avanco_feroz":
			_add_all(s, _stroke([Vector2(-0.45, -0.2), Vector2(0.38, -0.2)], 0.16), "rust")
			_add(s, _blade(Vector2(0.28, -0.2), Vector2(0.98, -0.2), 0.42), "rust", true)
			for y: float in [-0.5, 0.1]:
				_add_all(s, _stroke([Vector2(-1.0, y), Vector2(-0.6, y)], 0.09), "rust")
			_add(s, _ring(Vector2(-0.05, 0.42), 0.3, 0.12, deg_to_rad(-10), deg_to_rad(180)), "rust")
			_add(s, _head(Vector2(-0.35, 0.42), Vector2(0, -1), 0.2), "rust")
		&"furia_plena":
			_add(s, _flame3(Vector2(0, -0.05), 0.78), "rust", true, false, [PackedVector2Array([Vector2(0.0, 0.5), Vector2(0.02, -0.2)])])
			for k in 3:
				_add(s, _chevron_down(Vector2((k - 1) * 0.42, 0.78), 0.2, 0.1), "rust")
			for k in 3:
				_add(s, _diamond(Vector2((k - 1) * 0.46, -0.9 + absf(k - 1) * 0.12), 0.1, 0.13), "gold")
		&"corte_crescente":
			_wave(s, Vector2(0.05, 0.0), 0.9)
			for y: float in [-0.3, 0.3]:
				_add_all(s, _stroke([Vector2(-1.0, y), Vector2(-0.66, y)], 0.08), "emerald")
		&"fio_longo":
			_add(s, _blade(Vector2(-0.92, 0.92), Vector2(0.42, -0.42), 0.26), "emerald", true, false, [PackedVector2Array([Vector2(-0.75, 0.75), Vector2(0.25, -0.25)])])
			for k in 3:
				var at := Vector2(0.55 + k * 0.15, -0.55 - k * 0.15)
				_add(s, _diamond(at, 0.05, 0.05), "pale")
			# two ticks of measure on the lower right of the reach only (across the line they would read as a cross)
			for k in 2:
				var at := Vector2(0.66 + k * 0.26, -0.58 - k * 0.26)
				_add_all(s, _stroke([at, at + Vector2(0.14, 0.14)], 0.06), "pale")
		&"onda_atravessante":
			_add(s, _rect(Vector2(-0.13, -0.86), Vector2(0.26, 0.8)), "stone")
			_add(s, _rect(Vector2(-0.13, 0.04), Vector2(0.26, 0.82)), "stone")
			_wave(s, Vector2(-0.5, 0.0), 0.72)
			_wave(s, Vector2(0.55, 0.0), 0.72)
		&"lamina_faminta":
			var gem := _diamond(Vector2(0.12, 0.0), 0.5, 0.9)
			var low := Geometry2D.intersect_polygons(gem, _rect(Vector2(-1, 0), Vector2(2, 1)))
			_add(s, gem, "blue", false, true)
			for p in low:
				_add(s, p, "blue", true)
			_add(s, _blade(Vector2(-0.98, 0.5), Vector2(0.92, -0.48), 0.18), "steel")
		&"reserva":
			_add(s, _diamond(Vector2.ZERO, 0.72, 1.0), "blue", false, true)
			_add(s, _diamond(Vector2.ZERO, 0.58, 0.82), "blue", false, true)
			_add(s, _diamond(Vector2.ZERO, 0.36, 0.5), "blue", true, false, [PackedVector2Array([Vector2(-0.36, 0), Vector2(0, -0.5), Vector2(0.12, 0)])])
		&"coracao_da_emeth":
			for k in 4:
				var a := k * PI * 0.5
				_add(s, _ring(Vector2.ZERO, 0.84, 0.2, a - deg_to_rad(30), a + deg_to_rad(30)), "blue")
			_add(s, _gem_tall(Vector2.ZERO, 0.36, 0.58), "emerald", true, false, [PackedVector2Array([Vector2(-0.42, -0.2), Vector2(0, -0.05), Vector2(0.42, -0.2)]), PackedVector2Array([Vector2(0, -0.05), Vector2(0, 0.66)])])
		&"investida":
			_add(s, _hood(Vector2(0.25, 0.05), 0.62, 0.35), "gold", false, true)
			_add_all(s, _stroke([Vector2(-1.0, 0.05), Vector2(0.5, 0.05)], 0.14), "gold")
			_add(s, _blade(Vector2(0.4, 0.05), Vector2(1.0, 0.05), 0.36), "gold", true)
		&"sangue_quente":
			_add(s, _flame3(Vector2(0.38, -0.12), 0.6), "rust", false, true)
			_add(s, _flame3(Vector2(-0.22, 0.12), 0.78), "carmine", true)
		&"onda_carregada":
			_wave(s, Vector2(0.28, 0.0), 0.8)
			for k in 3:
				_add(s, _circle(Vector2(-0.95 + k * 0.32, 0.0), 0.07 + 0.04 * k), "pale")
		&"fio_do_passo":
			for y: float in [0.45, 0.68, 0.91]:
				_add_all(s, _stroke([Vector2(-1.0 + (y - 0.45), y), Vector2(-0.4 + (y - 0.45) * 0.5, y)], 0.1), "gold")
			_wave(s, Vector2(0.35, -0.3), 0.55)
		&"firmeza":
			_add(s, _rect(Vector2(-0.95, 0.66), Vector2(1.9, 0.3)), "stone", false, false, [PackedVector2Array([Vector2(0.1, 0.66), Vector2(0.1, 0.96)])])
			_add(s, _drop(Vector2(-0.38, 0.0), 0.62), "terra", true)
			_add(s, _diamond(Vector2(0.45, 0.12), 0.34, 0.5), "blue", true)
		&"respiro":
			_add(s, _drop(Vector2(-0.15, 0.12), 0.82), "terra", true)
			_add_all(s, _stroke([Vector2(-0.38, 0.45), Vector2(-0.15, 0.2), Vector2(0.08, 0.45)], 0.11), "pale")
			_add_all(s, _stroke(_arc_pts(Vector2(0.35, -0.68), 0.32, deg_to_rad(200), deg_to_rad(340), 8), 0.08), "pale")
		&"ainda_de_pe":
			_add(s, PackedVector2Array([Vector2(-1.0, 0.72), Vector2(-0.16, 0.72), Vector2(0.0, 0.84), Vector2(0.16, 0.72),
				Vector2(1.0, 0.72), Vector2(1.0, 0.9), Vector2(-1.0, 0.9)]), "stone")
			_add_all(s, _stroke([Vector2(0, 0.62), Vector2(0, -0.35)], 0.18), "terra")
			_add(s, _head(Vector2(0, -0.98), Vector2(0, -1), 0.44), "terra", true)
			_add(s, _diamond(Vector2(-0.62, 0.32), 0.09, 0.12), "stone")
			_add(s, _diamond(Vector2(0.6, 0.18), 0.08, 0.1), "stone")
	return s


static func _add(s: Array, p: PackedVector2Array, k: String, main := false, hollow := false, detail: Array = []) -> void:
	if p.size() < 3:
		return
	var part := {"p": p, "k": k}
	if main:
		part["main"] = true
	if hollow:
		part["hollow"] = true
	if not detail.is_empty():
		part["detail"] = detail
	s.append(part)


static func _add_all(s: Array, polys: Array, k: String, main := false) -> void:
	for p: PackedVector2Array in polys:
		_add(s, p, k, main)


## The Emeth's wave (W-1): belly to the right, a pale leading edge, an emerald body thinning backwards, a vein of old
## gold in the middle.
static func _wave(s: Array, c: Vector2, rad: float) -> void:
	var body := _crescent(c, rad, 0.5)
	if body.is_empty():
		return
	_add(s, body, "emerald", true)
	var edge := Geometry2D.intersect_polygons(body, _circle_poly(c + Vector2(-rad * 0.18, 0), rad * 1.0, 28, true))
	for p in edge:
		_add(s, p, "pale")
	_add_all(s, _stroke(_arc_pts(c + Vector2(-rad * 0.12, 0), rad * 0.82, -PI * 0.32, PI * 0.32, 10), maxf(0.04, rad * 0.06)), "gold")


static func _crescent(c: Vector2, rad: float, cut: float) -> PackedVector2Array:
	var outer := _circle_poly(c, rad, 32)
	var inner := _circle_poly(c - Vector2(rad * cut, 0), rad * 0.98, 32)
	var parts := Geometry2D.clip_polygons(outer, inner)
	return parts[0] if parts.size() > 0 else PackedVector2Array()


## The leading part of a crescent: what is outside a circle a little behind (the thin pale band of the edge).
static func _circle_poly(c: Vector2, rad: float, n: int, inverse := false) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n:
		out.append(c + Vector2.from_angle(TAU * i / n) * rad)
	if inverse:
		# a big square with the circle cut away is not a simple polygon: the band is outer minus this circle
		return _ring(c, rad * 1.5, rad * 1.0, 0.0, TAU)
	return out


static func _circle(c: Vector2, rad: float) -> PackedVector2Array:
	return _circle_poly(c, rad, 14)


static func _arc_pts(c: Vector2, rad: float, a0: float, a1: float, n: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n + 1:
		out.append(c + Vector2.from_angle(lerpf(a0, a1, float(i) / n)) * rad)
	return out


## A band of a circle of radius rad (middle of the band) and width w from angle a0 to a1.
static func _ring(c: Vector2, rad: float, w: float, a0: float, a1: float) -> PackedVector2Array:
	var n := maxi(6, int(absf(a1 - a0) / 0.12))
	var out := PackedVector2Array()
	for i in n + 1:
		out.append(c + Vector2.from_angle(lerpf(a0, a1, float(i) / n)) * (rad + w * 0.5))
	for i in range(n, -1, -1):
		out.append(c + Vector2.from_angle(lerpf(a0, a1, float(i) / n)) * (rad - w * 0.5))
	return out


static func _stroke(pts: Array, w: float) -> Array:
	return Geometry2D.offset_polyline(PackedVector2Array(pts), w * 0.5, Geometry2D.JOIN_MITER, Geometry2D.END_SQUARE)


## A slash: thin at both ends, w wide in the middle, half long each way along d.
static func _lens(mid: Vector2, d: Vector2, half: float, w: float) -> PackedVector2Array:
	d = d.normalized()
	var n := Vector2(-d.y, d.x)
	return PackedVector2Array([mid - d * half, mid - d * half * 0.45 + n * w * 0.45, mid + d * half * 0.2 + n * w * 0.5,
		mid + d * half, mid + d * half * 0.2 - n * w * 0.35, mid - d * half * 0.45 - n * w * 0.35])


## A blade from its heel to its point, w wide, no guard.
static func _blade(heel: Vector2, point: Vector2, w: float) -> PackedVector2Array:
	var d := (point - heel).normalized()
	var n := Vector2(-d.y, d.x)
	var shoulder := point - d * w * 1.4
	return PackedVector2Array([heel + n * w * 0.5, shoulder + n * w * 0.5, point, shoulder - n * w * 0.5, heel - n * w * 0.5])


static func _head(tip: Vector2, d: Vector2, size: float) -> PackedVector2Array:
	d = d.normalized()
	var n := Vector2(-d.y, d.x)
	return PackedVector2Array([tip, tip - d * size + n * size * 0.55, tip - d * size * 0.7, tip - d * size - n * size * 0.55])


static func _diamond(c: Vector2, hw: float, hh: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(0, -hh), c + Vector2(hw, 0), c + Vector2(0, hh), c + Vector2(-hw, 0)])


static func _gem_tall(c: Vector2, hw: float, hh: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(-hw * 0.55, -hh * 0.62), c + Vector2(hw * 0.55, -hh * 0.62), c + Vector2(hw, -hh * 0.3),
		c + Vector2(0, hh), c + Vector2(-hw, -hh * 0.3)])


static func _rect(at: Vector2, size: Vector2) -> PackedVector2Array:
	return PackedVector2Array([at, at + Vector2(size.x, 0), at + size, at + Vector2(0, size.y)])


## A chevron pointing right: arms s long, th thick.
static func _chevron(c: Vector2, s: float, th: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(-s * 0.55, -s), c + Vector2(-s * 0.55 + th, -s), c + Vector2(s * 0.45 + th, 0),
		c + Vector2(-s * 0.55 + th, s), c + Vector2(-s * 0.55, s), c + Vector2(s * 0.45, 0)])


static func _chevron_down(c: Vector2, s: float, th: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(-s, -s * 0.5), c + Vector2(0, s * 0.4), c + Vector2(s, -s * 0.5),
		c + Vector2(s, -s * 0.5 + th), c + Vector2(0, s * 0.4 + th), c + Vector2(-s, -s * 0.5 + th)])


## A flame of three tongues, s tall from its middle.
static func _flame3(c: Vector2, s: float) -> PackedVector2Array:
	var pts: Array[Vector2] = [Vector2(0.0, -1.1), Vector2(0.18, -0.55), Vector2(0.42, -0.78), Vector2(0.5, -0.25),
		Vector2(0.62, 0.2), Vector2(0.45, 0.62), Vector2(0.0, 0.85), Vector2(-0.45, 0.62), Vector2(-0.62, 0.2),
		Vector2(-0.5, -0.3), Vector2(-0.4, -0.72), Vector2(-0.18, -0.5)]
	var out := PackedVector2Array()
	for p in pts:
		out.append(c + p * s)
	return out


static func _drop(c: Vector2, s: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in TalentGlyph.DROP:
		out.append(c + p * s)
	return out


## A hooded figure with no face, leaning back as it falls.
static func _hood(c: Vector2, h: float, lean: float) -> PackedVector2Array:
	var pts: Array[Vector2] = [Vector2(0.0, -1.0), Vector2(0.32, -0.82), Vector2(0.4, -0.45), Vector2(0.62, 0.2),
		Vector2(0.7, 0.95), Vector2(-0.7, 0.95), Vector2(-0.6, 0.2), Vector2(-0.4, -0.45), Vector2(-0.32, -0.82)]
	var out := PackedVector2Array()
	var turn := Transform2D(lean, Vector2.ZERO)
	for p in pts:
		out.append(c + turn * (p * h))
	return out
