class_name ForgeBench
extends Control
## The Forja's bench (docs/art/forge_spec.md 1 and 5): the cloth with the Emeth lying on it (EmethView flat, the tip to
## the right, 1000 px in the 1280 x 720 stage) and over it the four points of the weapon: Despertar (the pommel's
## setting), Refinar (the two arms of the guard, Ataque above and Especial below), Inscrever (the plane of the blade) and
## Temperar (the three notches of the edge). Everything the player changed shows on the weapon: the awake stone, the
## rings with their letters, the engraved lines, the lit notches. A struck point glows (heat), sparks fly on a strike,
## steam rises when the piece is tempered. On the Oficina's bench the Picareta lies in the Emeth's place.
## The screen feeds it the state (the variables below) and the marks' touch places; it draws and keeps the effects.
##   bench.temper = 2; bench.focus = &"temper"; bench.hit(&"temper", 1)

const CLOTH := Color("3a2a1e")
const EMBER := Color("e07a2a")
const EMBER_LIT := Color("f5a050")
const IRON := Color("2a2620")
const RING := Color("5a5650")
## The edge of the blade's top: y at x (it slopes down to the tip).
static func edge_y(x: float) -> float:
	return (182.0 + 0.149 * (x - 585.0) if x < 800.0 else 214.0 + 0.11 * (x - 800.0)) + 5.0


## Where each point's mark sits (centre) and its label (centre), as the spec's table.
## (The spec's x for the guard and the edge was for a sketch; these follow the Emeth's own model: the pommel's setting,
## the guard's two prongs, the plane of the blade and the edge's middle notch.)
const AT := {&"awaken": Vector2(208, 262), &"attack": Vector2(490, 206), &"special": Vector2(490, 320),
	&"inscribe": Vector2(740, 262), &"temper": Vector2(880, 228), &"pick": Vector2(640, 262)}
const LABEL_AT := {&"awaken": Vector2(208, 168), &"attack": Vector2(490, 168), &"special": Vector2(490, 168),
	&"inscribe": Vector2(740, 168), &"temper": Vector2(880, 168), &"pick": Vector2(640, 168)}
const LABEL_KEY := {&"awaken": &"forge_awaken", &"attack": &"forge_track_refine", &"special": &"forge_track_refine",
	&"inscribe": &"forge_inscribe", &"temper": &"forge_track_temper", &"pick": &"oficio_pick"}
const NOTCH_X: Array[float] = [800.0, 880.0, 960.0]
const EMETH_AT := Vector2(150, 182)
const EMETH_SIZE := Vector2(1000, 160)
const CLOTH_RECT := Rect2(60, 200, 1160, 130)
## The letter engraved on a ring by the Refinar on it.
const LETTER := {&"refine_fio": "F", &"refine_peso": "P", &"refine_pressa": "R", &"refine_onda_larga": "L",
	&"refine_onda_pesada": "S", &"refine_onda_pronta": "O"}
const GEM := {&"sede": Color("f0a040"), &"impeto": Color("6a9ad8"), &"eco": Color("ece4cc")}
const MARK_HIT := 64.0

class Spark:
	var pos: Vector2
	var vel: Vector2
	var life: float
	var total: float
	var size: float


## What the weapon shows (the screen sets these).
var workshop := false
var temper := 0
## slot -> {letter}: the Refinar on each action ("" none).
var rings := {&"attack": "", &"special": ""}
var gem: StringName = &""
var lines := 0
var pick_look := PickMark.Look.LOST
## The marks that exist (a point without its tool is covered by a cloth with a lock).
var marks: Array[StringName] = []
var sealed := {}
## The marks with something to do now (an ember rim).
var doing := {}
var focus: StringName = &"temper"
## The heat of the struck point, 0 to 0.5 (a quarter a strike), where.
var heat := 0.0
var heat_target := 0.0
var heat_at: StringName = &"temper"
var emeth: EmethView
var emeth_tex: TextureRect
var _over: Control
var _t := 0.0
var _kick := 0.0
var _flash := 0.0
var _flash_r := 40.0
var _flash_at := Vector2.ZERO
var _steam := 0.0
var _steam_at := Vector2.ZERO
var _sparks: Array[Spark] = []
var _rng := RandomNumberGenerator.new()
## 0 to 1: the marks appear from the pommel to the tip (the opening).
var reveal := 1.0:
	set(v):
		reveal = v
		queue_redraw()
		if _over != null:
			_over.queue_redraw()
## No sparks and no additive glow (the browser's Compatibility).
var plain_fx := false


func setup() -> ForgeBench:
	name = "bench"
	size = Vector2(1280, 720)
	custom_minimum_size = size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rng.seed = 7
	var tex := ForgeArt.texture("emeth_flat.png")
	if tex != null:
		emeth_tex = TextureRect.new()
		emeth_tex.texture = tex
		emeth_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		emeth_tex.stretch_mode = TextureRect.STRETCH_SCALE
		emeth_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		emeth_tex.position = EMETH_AT
		emeth_tex.size = EMETH_SIZE
		add_child(emeth_tex)
	else:
		emeth = EmethView.new().setup(EMETH_SIZE, true)
		emeth.position = EMETH_AT
		add_child(emeth)
	_over = Over.new()
	_over.name = "over"
	_over.size = size
	_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_over)
	return self


## The touch place of a mark, a square centred on it.
static func touch_rect(mark: StringName) -> Rect2:
	return Rect2(AT[mark] - Vector2.ONE * MARK_HIT * 0.5, Vector2.ONE * MARK_HIT)


## A strike on a mark (1, 2 or 3): the weapon kicks 3 px, a flash and the sparks; the third is bigger and ends in steam.
func hit(mark: StringName, n: int) -> void:
	var at: Vector2 = AT[mark]
	_kick = 1.0
	_flash = 1.0
	_flash_at = at
	_flash_r = 80.0 if n >= 3 else 40.0
	if not plain_fx:
		_burst(at, 14 if n >= 3 else 6)
	if n >= 3:
		_steam = 1.0
		_steam_at = at


func _burst(at: Vector2, count: int) -> void:
	for i in count:
		var s := Spark.new()
		s.pos = at + Vector2(_rng.randf_range(-8, 8), _rng.randf_range(-6, 6))
		s.vel = Vector2(_rng.randf_range(-70, 70), _rng.randf_range(-190, -80))
		s.total = _rng.randf_range(0.22, 0.34)
		s.life = s.total
		s.size = _rng.randf_range(1.5, 3.0)
		_sparks.append(s)


func _process(delta: float) -> void:
	_t += delta
	heat = move_toward(heat, heat_target, delta * (0.6 if heat_target < heat else 3.0))
	_kick = maxf(0.0, _kick - delta / 0.08)
	_flash = maxf(0.0, _flash - delta / 0.1)
	_steam = maxf(0.0, _steam - delta / 0.5)
	for s in _sparks:
		s.life -= delta
		s.pos += s.vel * delta
		s.vel.y += 380.0 * delta
	_sparks = _sparks.filter(func(s: Spark) -> bool: return s.life > 0.0)
	var dy := roundf(_kick * 3.0)
	if emeth != null:
		emeth.position.y = EMETH_AT.y + dy
	if emeth_tex != null:
		emeth_tex.position.y = EMETH_AT.y + dy
	_over.queue_redraw()


func _draw() -> void:
	_paint_cloth()
	if workshop:
		var whole := ForgeArt.texture("pick_whole.png")
		var head := ForgeArt.texture("pick_head.png")
		var art := whole if pick_look == PickMark.Look.WHOLE else (head if pick_look == PickMark.Look.HEAD else null)
		if art != null:
			draw_texture_rect(art, Rect2(AT[&"pick"] - Vector2(310, 110), Vector2(620, 220)), false)
		else:
			PickMark.paint(self, pick_look, AT[&"pick"], 220.0, false)


func _paint_cloth() -> void:
	var tex := ForgeArt.texture("cloth.png")
	if tex != null:
		draw_texture_rect(tex, CLOTH_RECT, false)
		return
	var r := CLOTH_RECT
	# a soft shadow under it, then the cloth with a hem that droops a little and sags at the corners
	draw_rect(Rect2(r.position + Vector2(8, 12), r.size), Color(0, 0, 0, 0.35))
	var top := PackedVector2Array()
	var steps := 24
	for i in steps + 1:
		var x := r.position.x + r.size.x * float(i) / steps
		top.append(Vector2(x, r.position.y + 2.0 * sin(float(i) * 1.7)))
	var poly := PackedVector2Array(top)
	poly.append(Vector2(r.end.x + 4, r.end.y + 6))
	poly.append(Vector2(r.position.x - 4, r.end.y + 8))
	draw_colored_polygon(poly, CLOTH)
	# the fold: a darker line and a lighter one, and the lower edge fading into the dark
	draw_line(Vector2(r.position.x + 20, r.position.y + 70), Vector2(r.end.x - 30, r.position.y + 76), CLOTH.darkened(0.3), 2.0)
	draw_line(Vector2(r.position.x + 20, r.position.y + 73), Vector2(r.end.x - 30, r.position.y + 79), CLOTH.lightened(0.12), 1.0)
	for k in 6:
		var y := r.end.y - 6.0 + k * 3.0
		draw_rect(Rect2(r.position.x - 4, y, r.size.x + 8, 3.0), Color(UiKit.INK, 0.18 * (k + 1)))


## The weapon's overlay: marks, rings, stone, lines, notches, labels and the effects.
class Over extends Control:
	func _draw() -> void:
		(get_parent() as ForgeBench)._paint_over(self)


func _paint_over(ci: Control) -> void:
	var dy := roundf(_kick * 3.0)
	# the heat round the struck point, 25% then 50% of the ember
	if heat > 0.01 and AT.has(heat_at):
		var c: Vector2 = AT[heat_at] + Vector2(0, dy)
		for k in 6:
			ci.draw_circle(c, 110.0 - k * 16.0, Color(EMBER, heat * 0.22))
	if workshop:
		_labels(ci, [&"pick"])
		_marks(ci, [&"pick"], dy)
		_effects(ci)
		return
	_notches(ci, dy)
	_lines(ci, dy)
	_rings(ci, dy)
	_gem(ci, dy)
	_marks(ci, marks, dy)
	_labels(ci, marks)
	_effects(ci)


func _alpha_of(mark: StringName) -> float:
	# the marks appear from the pommel to the tip: 40 ms each (the opening)
	var x: float = (AT[mark] as Vector2).x
	return clampf(reveal * 1.6 - (x - 150.0) / 1000.0 * 0.6, 0.0, 1.0)


func _notches(ci: Control, dy: float) -> void:
	for i in 3:
		var lit := temper > i
		var x: float = NOTCH_X[i]
		var y := edge_y(x) + dy
		var p := PackedVector2Array([Vector2(x - 10, y - 2), Vector2(x + 10, y - 2), Vector2(x, y + 15)])
		ci.draw_colored_polygon(p, EMBER_LIT if lit else Color(0.05, 0.04, 0.05, 0.85))
		if lit:
			ci.draw_circle(Vector2(x, y + 8), 13.0, Color(EMBER, 0.25))


func _lines(ci: Control, dy: float) -> void:
	for i in lines:
		var y := 252.0 + i * 11.0 + dy
		var x := 566.0
		var n := 9 + (i * 3) % 4
		for k in n:
			var w := 4.0 + float((k * 5 + i * 3) % 4)
			ci.draw_rect(Rect2(x, y, w, 4.0), UiKit.OLD_GOLD)
			x += w + 2.0


const SOCKET_BG := Color(0.20, 0.13, 0.07)


func _rings(ci: Control, dy: float) -> void:
	if not marks.has(&"attack"):
		return
	for slot: StringName in [&"attack", &"special"]:
		var c: Vector2 = AT[slot] + Vector2(0, dy)
		var letter: String = rings[slot]
		var on := letter != ""
		if on:
			ci.draw_circle(c, 15.0, Color(0.04, 0.03, 0.03, 0.85))
		else:
			_socket(ci, c, 15.0, "F")
		ci.draw_arc(c, 14.0, 0.0, TAU, 28, UiKit.OLD_GOLD.lightened(0.2) if on else RING, 4.0, true)
		if on:
			ci.draw_string(UiKit.BOLD_FONT, c + Vector2(-20, 5), letter, HORIZONTAL_ALIGNMENT_CENTER, 40, 14, UiKit.PARCHMENT)


## Empty bronze setting: dark-bronze cavity, inner shadow on the upper half, old-gold rim and a faint
## silhouette of what goes in (a diamond for the gem, the letter for a ring).
func _socket(ci: Control, c: Vector2, r: float, letter: String) -> void:
	ci.draw_circle(c, r, SOCKET_BG)
	ci.draw_arc(c, r - 1.5, PI, TAU, 20, Color(0.12, 0.075, 0.04), 3.0, true)
	ci.draw_arc(c, r, 0.0, TAU, 32, Color(UiKit.OLD_GOLD, 0.7), 2.0, true)
	var ghost := Color(UiKit.PARCHMENT, 0.18)
	if letter == "":
		var k := r * 0.55
		ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -k), c + Vector2(k, 0), c + Vector2(0, k), c + Vector2(-k, 0)]), ghost)
	else:
		ci.draw_string(UiKit.BOLD_FONT, c + Vector2(-20, 5), letter, HORIZONTAL_ALIGNMENT_CENTER, 40, 14, ghost)


func _gem(ci: Control, dy: float) -> void:
	if not marks.has(&"awaken"):
		return
	var c: Vector2 = AT[&"awaken"] + Vector2(0, dy)
	if gem == &"":
		_socket(ci, c, 19.0, "")
		return
	ci.draw_circle(c, 19.0, SOCKET_BG)
	var col: Color = Color("f0a040")
	for k: StringName in GEM:
		if String(gem).contains(String(k)):
			col = GEM[k]
	ci.draw_circle(c, 22.0, Color(col, 0.22))
	var r := 12.0
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)]), col)
	ci.draw_polyline(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0), c + Vector2(0, -r)]), col.lightened(0.5), 1.5, true)


func _marks(ci: Control, list: Array, dy: float) -> void:
	for m: StringName in list:
		var a := _alpha_of(m)
		var c: Vector2 = AT[m] + Vector2(0, dy)
		var kind_ring := m == &"attack" or m == &"special"
		var is_gem := m == &"awaken"
		if not kind_ring and not is_gem:
			var r := 14.0
			var d := PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])
			ci.draw_colored_polygon(d, Color(IRON, 0.9 * a))
			d.append(d[0])
			ci.draw_polyline(d, Color(UiKit.OLD_GOLD, a), 2.0, true)
		if doing.get(m, false):
			ci.draw_arc(c, 24.0, 0.0, TAU, 32, Color(EMBER, a * (0.7 + 0.3 * sin(_t * 4.0))), 2.0, true)
		if m == focus:
			ci.draw_arc(c, 30.0, 0.0, TAU, 36, Color(UiKit.GOLD, a), 2.5, true)
		if sealed.get(m, false):
			ci.draw_rect(Rect2(c - Vector2(26, 22), Vector2(52, 44)), Color(0.165, 0.15, 0.125, 0.92))
			ci.draw_rect(Rect2(c + Vector2(-8, -2), Vector2(16, 12)), UiKit.DIM)
			ci.draw_arc(c + Vector2(0, -2), 6.0, PI, TAU, 10, UiKit.DIM, 2.5)


func _labels(ci: Control, list: Array) -> void:
	var done := {}
	for m: StringName in list:
		var key: StringName = LABEL_KEY[m]
		var focused_here := m == focus or ((m == &"attack" or m == &"special") and (focus == &"attack" or focus == &"special"))
		if done.has(key):
			continue
		done[key] = true
		var dim: bool = sealed.get(m, false) and not (m == &"attack" or m == &"special")
		var col := UiKit.GOLD if focused_here else (UiKit.DIM if dim else UiKit.PALE)
		var size_px := 20 if focused_here else 18
		var at: Vector2 = LABEL_AT[m]
		ci.draw_string(UiKit.TITLE_FONT, Vector2(at.x - 100, at.y), T.t(LABEL_KEY[m]), HORIZONTAL_ALIGNMENT_CENTER, 200, size_px, Color(col, _alpha_of(m)))


func _effects(ci: Control) -> void:
	if _flash > 0.0:
		for k in 4:
			ci.draw_circle(_flash_at, _flash_r * (1.0 - k * 0.2), Color(1.0, 0.86, 0.62, 0.16 * _flash))
	for s in _sparks:
		ci.draw_circle(s.pos, s.size, Color(EMBER_LIT, clampf(s.life / s.total, 0.0, 1.0)))
	if _steam > 0.0:
		var k := 1.0 - _steam
		for i in 5:
			var p := _steam_at + Vector2(sin(float(i) * 2.1 + _t * 3.0) * 12.0, -k * 90.0 - i * 10.0)
			ci.draw_circle(p, 10.0 + k * 14.0 + i, Color(0.95, 0.95, 0.92, 0.18 * _steam))
