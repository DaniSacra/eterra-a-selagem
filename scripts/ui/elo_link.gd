class_name EloLink
extends Control
## An Elo (a gift forged from two others) drawn as its two source medallions joined by a chain of old gold, with the
## Elo's own medallion hanging in the middle of the chain. Used by the gift card, the gifts panel and the HUD greeting.
## The chain is drawn here, in code: links of old gold metal over ink, alternating seen from the front (a ring) and
## from the side (a bar). progress (0..1) draws the chain from both ends towards the middle (the moment it forms).

## Link colours: the HUD's old gold, a lit edge and a shadow, over ink.
const METAL := UiKit.OLD_GOLD
const METAL_LIT := Color("c9ab6e")
const METAL_DARK := Color("4a3a22")
## How far into a painted medallion (fraction of its side) the chain from a source runs, under the painted rim.
const RIM_INSET := 0.07

var elo: Boon
var sources: Array[Boon] = []
## 0..1: how much of the chain is drawn, from the two sources inwards.
var progress := 1.0:
	set(v):
		progress = clampf(v, 0.0, 1.0)
		queue_redraw()
var _big := 0.0
var _small := 0.0
var _gap := 0.0
var _link := 0.0
## The Elo's painted medallion (the gift card), with its own chain rim painted: the chain then stops at that rim.
var _art: TextureRect


## big: the Elo's medallion; small: each source's; gap: the chain between a source and the Elo.
## art: a painted medallion (BoonArt) in place of the drawn one; its painted chain rim is the only rim.
func setup(b: Boon, from: Array[Boon], big: float, small: float, gap: float, art: Texture2D = null) -> EloLink:
	elo = b
	sources = from
	_big = big
	_small = small
	_gap = gap
	_link = clampf(small * 0.34, 7.0, 18.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(big + (small + gap) * 2.0, big)
	var y := (big - small) * 0.5
	for i in mini(sources.size(), 2):
		var icon := BoonIcon.new().setup(sources[i], small)
		icon.position = Vector2(0.0 if i == 0 else big + small + gap * 2.0, y)
		icon.size = Vector2(small, small)
		add_child(icon)
	var main: Control
	if art:
		_art = BoonArt.rect(art, big)
		main = _art
	else:
		main = BoonIcon.new().setup(b, big)
		main.size = Vector2(big, big)
	main.position = Vector2(small + gap, 0.0)
	add_child(main)
	return self


## The Elo's drawn medallion (to show its level); null when it is painted.
func main_icon() -> BoonIcon:
	return get_child(get_child_count() - 1) as BoonIcon


## The painted medallion, when there is one.
func main_art() -> TextureRect:
	return _art


## The two source medallions, in order.
func source_icons() -> Array[BoonIcon]:
	var out: Array[BoonIcon] = []
	for c in get_children():
		if c is BoonIcon and (c as BoonIcon).boon != elo:
			out.append(c)
	return out


## "Elo de A e B", with the names the two sources already have.
static func caption(from: Array[Boon]) -> String:
	if from.size() < 2:
		return T.t(Boon.FAMILY_KEY[Boon.Family.DUO])
	return T.t(&"elo_of", {"a": T.t("boon_" + String(from[0].id)), "b": T.t("boon_" + String(from[1].id))})


func _draw() -> void:
	# behind the medallions (children draw on top): one chain from source to source, through the Elo
	var y := _big * 0.5
	var a := Vector2(_small * 0.5, y)
	var b := Vector2(_big + _small * 1.5 + _gap * 2.0, y)
	if _art == null:
		chain(self, a, b, _link, progress)
		return
	# a painted medallion: one short chain from each source into its painted rim (never a second rim over it)
	var into := _big * RIM_INSET
	chain(self, a, Vector2(_small + _gap + into, y), _link, progress)
	chain(self, Vector2(_small + _gap + _big - into, y), b, _link, progress)


## A chain from a to b, links about link pixels long. progress < 1 leaves out the middle (drawn from both ends).
static func chain(ci: CanvasItem, a: Vector2, b: Vector2, link: float, progress: float = 1.0) -> void:
	var d := b - a
	var length := d.length()
	if length < 1.0:
		return
	var dir := d / length
	var pitch := link * 0.7
	var n := maxi(1, floori(length / pitch))
	var half := length * 0.5 * progress
	var start := (length - (n - 1) * pitch) * 0.5
	# bars first, then the rings over them, as if threaded through
	for pass_ in [1, 0]:
		for i in n:
			var t := start + i * pitch
			if i % 2 != pass_ or minf(t, length - t) > half + pitch * 0.5:
				continue
			link_at(ci, a + dir * t, dir, link, i % 2 == 0)


## A ring of links around a circle (the rim of an Elo's medallion).
static func ring(ci: CanvasItem, c: Vector2, radius: float, link: float) -> void:
	var n := maxi(8, roundi(TAU * radius / (link * 0.7)) / 2 * 2)
	for pass_ in [1, 0]:
		for i in n:
			if i % 2 != pass_:
				continue
			var a := TAU * float(i) / n
			link_at(ci, c + Vector2.from_angle(a) * radius, Vector2.from_angle(a + PI * 0.5), link, i % 2 == 0)


## One link centred at p along dir. face: seen from the front (an open oval); otherwise from the side (a bar).
static func link_at(ci: CanvasItem, p: Vector2, dir: Vector2, length: float, face: bool) -> void:
	var th := maxf(1.2, length * 0.16)
	var side := dir.orthogonal()
	if face:
		var pts := PackedVector2Array()
		var steps := 14
		for k in steps + 1:
			var a := TAU * float(k) / steps
			pts.append(p + dir * cos(a) * length * 0.5 + side * sin(a) * length * 0.3)
		ci.draw_polyline(pts, UiKit.INK, th + 2.0, true)
		ci.draw_polyline(pts, METAL, th, true)
		# a lit edge on the upper half, so the metal reads as round
		var lit := PackedVector2Array()
		for k in range(steps / 2 + 1):
			var a := PI + PI * float(k) / (steps / 2)
			lit.append(p + dir * cos(a) * length * 0.5 + side * sin(a) * length * 0.3 * (1.0 if side.y >= 0.0 else -1.0))
		ci.draw_polyline(lit, METAL_LIT, maxf(1.0, th * 0.4), true)
	else:
		var h := dir * length * 0.42
		ci.draw_line(p - h, p + h, UiKit.INK, th * 1.6 + 2.0, true)
		ci.draw_line(p - h, p + h, METAL_DARK, th * 1.6, true)
		ci.draw_line(p - h * 0.8, p + h * 0.8, METAL, th * 0.8, true)
