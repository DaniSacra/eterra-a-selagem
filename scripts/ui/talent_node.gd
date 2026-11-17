class_name TalentNode
extends BaseButton
## One node of the Gift tree on the hero screen (E2-06): a diamond of ink with a line of old gold and the glyph of its
## branch (Combo two crossed blades, Fúria a flame, Emeth a crystal, Magia a four-pointed star of light, never the sun;
## a bridge two linked diamonds, sustain a drop; the centre the Emeth's blade). Locked: no glyph, a small lock and the
## Mastery level that opens it. Equipped: the ink takes the branch's colour and the line brightens. The cost is a row
## of small diamonds under it. Focus (mouse, keys or gamepad: the mouse takes the focus with it) is an ivory line.

## The branch's colour, muted (TalentDef.Branch; the centre is CENTRE).
const BRANCH_COLOR: Array[Color] = [Color("c9bfa8"), Color("c8643c"), Color("3fae7c"), Color("4f9cc6"), Color("a88e5c"), Color("b8665a")]
const CENTRE := Color("3fae7c")
const LOCK_LINE := Color("4a4239")
const LOCK_INK := Color(0.035, 0.03, 0.04, 0.96)
const FOCUS := Color(1.0, 0.95, 0.84, 0.95)
const SIDE := 46.0
## The cost's diamonds under the node: their half size and step.
const PIP := 3.2
const PIP_STEP := 9.0
const LEVEL_SIZE := 15

## Glyph outlines in units of the glyph's radius (convex enough to triangulate).
const FLAME: Array[Vector2] = [Vector2(0.1, -1.15), Vector2(0.45, -0.45), Vector2(0.68, 0.15), Vector2(0.55, 0.65),
	Vector2(0.2, 0.92), Vector2(-0.2, 0.92), Vector2(-0.55, 0.65), Vector2(-0.68, 0.15), Vector2(-0.4, -0.35),
	Vector2(-0.2, -0.75)]
const TONGUE: Array[Vector2] = [Vector2(0.05, -0.05), Vector2(0.28, 0.45), Vector2(0.15, 0.78), Vector2(-0.15, 0.78),
	Vector2(-0.28, 0.45)]
const DROP: Array[Vector2] = [Vector2(0.0, -1.0), Vector2(0.35, -0.4), Vector2(0.6, 0.15), Vector2(0.55, 0.55),
	Vector2(0.3, 0.82), Vector2(0.0, 0.9), Vector2(-0.3, 0.82), Vector2(-0.55, 0.55), Vector2(-0.6, 0.15),
	Vector2(-0.35, -0.4)]

enum Glyph { COMBO, FURIA, EMETH, MAGIA, BRIDGE, SUSTAIN, CENTRE }

var def: TalentDef
var glyph := Glyph.CENTRE
var state := HeroLoadout.State.OPEN:
	set(v):
		state = v
		queue_redraw()
var _flash := 0.0


func setup(p_def: TalentDef, side: float = SIDE) -> TalentNode:
	def = p_def
	glyph = Glyph.CENTRE if def == null else (def.branch as int) as Glyph
	custom_minimum_size = Vector2(side, side)
	size = custom_minimum_size
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(func() -> void:
		if not has_focus():
			grab_focus())
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	name = String(def.id) if def else "centre"
	return self


func color() -> Color:
	return CENTRE if def == null else BRANCH_COLOR[def.branch]


## A short shake of the line when a rule refuses it.
func refuse() -> void:
	_flash = 1.0
	set_process(true)


func _process(delta: float) -> void:
	_flash = maxf(_flash - delta / 0.35, 0.0)
	queue_redraw()
	if _flash <= 0.0:
		set_process(false)


func _has_point(point: Vector2) -> bool:
	var d := (point - size * 0.5).abs()
	return d.x + d.y <= size.x * 0.5 + 2.0


func _draw() -> void:
	var c := size * 0.5 + Vector2(sin(_flash * 40.0) * 3.0 * _flash, 0.0)
	var h := size.x * 0.5
	var locked := state == HeroLoadout.State.LOCKED
	var on := state == HeroLoadout.State.EQUIPPED or def == null
	var tint := color()
	var ink := LOCK_INK if locked else UiKit.INK
	if on:
		ink = UiKit.INK.lerp(tint.darkened(0.45), 0.55)
	var line := LOCK_LINE if locked else UiKit.OLD_GOLD
	if on:
		line = UiKit.OLD_GOLD.lightened(0.45)
	if _flash > 0.0:
		line = line.lerp(Color(1.0, 0.62, 0.5), _flash)
	var outer := _diamond(c, h)
	draw_colored_polygon(outer, ink)
	draw_polyline(_closed(outer), line, UiKit.FRAME, true)
	draw_polyline(_closed(_diamond(c, h - 5.0)), Color(line, 0.4 if not locked else 0.25), 1.0, true)
	if has_focus():
		draw_polyline(_closed(_diamond(c, h + 4.0)), FOCUS, 1.6, true)
	if locked:
		_draw_lock(c, def.unlock_level if def else 1)
	else:
		var g := tint.lightened(0.25) if on else (UiKit.PARCHMENT if state == HeroLoadout.State.OPEN else UiKit.DIM.darkened(0.15))
		_draw_glyph(c, h * 0.5, g)
	if def != null and def.cost > 0:
		var pip := UiKit.OLD_GOLD.lightened(0.3) if not locked else LOCK_LINE.lightened(0.2)
		var x0 := c.x - (def.cost - 1) * PIP_STEP * 0.5
		for i in def.cost:
			draw_colored_polygon(_diamond(Vector2(x0 + i * PIP_STEP, size.y + 7.0), PIP), pip)


func _draw_lock(c: Vector2, level: int) -> void:
	var col := UiKit.DIM.darkened(0.1)
	# a padlock over the number
	var body := Rect2(c + Vector2(-5.0, -10.0), Vector2(10.0, 7.0))
	draw_arc(c + Vector2(0.0, -10.0), 3.4, PI, TAU, 10, col, 1.6, true)
	draw_rect(body, col)
	var n := str(level)
	var font := UiKit.number_font()
	var w := font.get_string_size(n, HORIZONTAL_ALIGNMENT_LEFT, -1, LEVEL_SIZE).x
	draw_string(font, c + Vector2(-w * 0.5, 11.0), n, HORIZONTAL_ALIGNMENT_LEFT, -1, LEVEL_SIZE, col)


## The branch's glyph inside a radius r around c.
func _draw_glyph(c: Vector2, r: float, col: Color) -> void:
	match glyph:
		Glyph.COMBO:
			# two crossed blades, each with a short guard
			for s: float in [-1.0, 1.0]:
				var a := c + Vector2(-r * s, r)
				var b := c + Vector2(r * s, -r)
				draw_line(a, b, col, 2.2, true)
				var g := a.lerp(b, 0.22)
				var across := (b - a).normalized().orthogonal() * r * 0.32
				draw_line(g - across, g + across, col, 2.0, true)
		Glyph.FURIA:
			# a flame: a pointed tip leaning a little, a round foot, a dark tongue inside
			draw_colored_polygon(_shape(c, r, FLAME), col)
			draw_colored_polygon(_shape(c, r, TONGUE), UiKit.INK)
		Glyph.EMETH, Glyph.CENTRE:
			# a crystal: a long diamond with its middle facet
			var crystal := PackedVector2Array([c + Vector2(0, -r * 1.1), c + Vector2(r * 0.5, 0), c + Vector2(0, r * 1.1), c + Vector2(-r * 0.5, 0)])
			draw_colored_polygon(crystal, col)
			draw_line(c + Vector2(0, -r * 1.1), c + Vector2(0, r * 1.1), Color(UiKit.INK, 0.6), 1.2, true)
			if glyph == Glyph.CENTRE:
				draw_line(c + Vector2(-r * 0.7, r * 0.45), c + Vector2(r * 0.7, r * 0.45), col, 2.0, true)
		Glyph.MAGIA:
			# a four-pointed star of light (never the sun)
			var star := PackedVector2Array()
			for i in 8:
				var d := Vector2.from_angle(i * PI * 0.25 - PI * 0.5)
				star.append(c + d * (r if i % 2 == 0 else r * 0.3))
			draw_colored_polygon(star, col)
		Glyph.BRIDGE:
			draw_polyline(_closed(_diamond(c + Vector2(-r * 0.45, 0), r * 0.5)), col, 1.8, true)
			draw_polyline(_closed(_diamond(c + Vector2(r * 0.45, 0), r * 0.5)), col, 1.8, true)
		Glyph.SUSTAIN:
			# a drop
			draw_colored_polygon(_shape(c, r, DROP), col)


## A shape given in units of r around c.
static func _shape(c: Vector2, r: float, pts: Array[Vector2]) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(c + p * r)
	return out


static func _diamond(c: Vector2, h: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(0, -h), c + Vector2(h, 0), c + Vector2(0, h), c + Vector2(-h, 0)])


static func _closed(poly: PackedVector2Array) -> PackedVector2Array:
	var out := poly.duplicate()
	out.append(poly[0])
	return out
