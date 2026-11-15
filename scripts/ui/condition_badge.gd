class_name ConditionBadge
extends Control
## A condition on the paladin (a boss's curse), beside his medallion: a small round seal in the HUD's frame with its
## rune, a ring of its colour around it that empties as it runs out, and its name and what it does in two short
## lines. It pops in when the condition lands and fades when it ends. Nothing shows while there is none.

const SIZE := 30.0
const RING_WIDTH := 3.0
## Seconds to pop in and to fade out.
const POP := 0.22
const FADE := 0.3
const NAME_SIZE := 15
const DETAIL_SIZE := 14
const TEXT_GAP := 7.0

var color := Color(0.62, 0.32, 0.95)
var title := ""
var detail := ""
## 0..1: the share of the condition still to run (0: none).
var ratio := 0.0:
	set(v):
		v = clampf(v, 0.0, 1.0)
		if v > 0.0 and ratio == 0.0:
			_pop = 1.0
		ratio = v
		if v > 0.0:
			_last = v
var _show := 0.0
var _pop := 0.0
## The ring as it was when the condition ended (so it fades out still drawn).
var _last := 0.0


func setup(tint: Color, name_text: String, detail_text: String) -> ConditionBadge:
	color = tint
	title = name_text
	detail = detail_text
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(SIZE + TEXT_GAP + _text_width(), SIZE)
	size = custom_minimum_size
	return self


## How much of it shows now (0 hidden, 1 whole).
func shown() -> float:
	return _show


func _process(delta: float) -> void:
	var was := _show
	_show = move_toward(_show, 1.0 if ratio > 0.0 else 0.0, delta / (POP if ratio > 0.0 else FADE))
	_pop = maxf(0.0, _pop - delta / POP)
	if _show > 0.0 or was > 0.0:
		queue_redraw()


func _draw() -> void:
	if _show <= 0.0:
		return
	var a := _show
	var r := SIZE * 0.5 * (1.0 + 0.3 * _pop)
	var c := Vector2(SIZE * 0.5, SIZE * 0.5)
	draw_circle(c, r + 1.5, Color(UiKit.INK, 0.92 * a))
	draw_circle(c, r, Color(UiKit.OLD_GOLD, a))
	draw_circle(c, r - UiKit.FRAME, Color(UiKit.INK, a))
	draw_circle(c, r - UiKit.FRAME - 0.5, Color(color.darkened(0.78), a))
	# the time left: a ring of its colour inside the frame, emptying clockwise from the top
	var ring_r := r - UiKit.FRAME - RING_WIDTH * 0.5 - 0.5
	draw_arc(c, ring_r, 0.0, TAU, 40, Color(color.darkened(0.55), 0.7 * a), RING_WIDTH, true)
	var left := ratio if ratio > 0.0 else _last
	if left > 0.0:
		draw_arc(c, ring_r, -PI * 0.5, -PI * 0.5 + TAU * left, maxi(4, ceili(40 * left)), Color(color.lightened(0.15), a), RING_WIDTH, true)
	rune(self, c, r * 0.42, Color(color.lightened(0.55), a), maxf(1.5, r * 0.11))
	# the name and what it does, beside it
	var x := SIZE + TEXT_GAP
	_text(UiKit.TITLE_FONT, title, Vector2(x, SIZE * 0.5 - 2.0), NAME_SIZE, Color(color.lightened(0.6), a))
	_text(UiKit.TEXT_FONT, detail, Vector2(x, SIZE * 0.5 + DETAIL_SIZE - 1.0), DETAIL_SIZE, Color(UiKit.PALE, 0.9 * a))


## The curse's rune: a stave with two branches bent down and a short cross stroke (the same family as the runes that
## turn around the paladin, CurseAura).
static func rune(ci: CanvasItem, c: Vector2, r: float, ink: Color, width: float) -> void:
	ci.draw_line(c + Vector2(0, -r), c + Vector2(0, r), ink, width, true)
	ci.draw_line(c + Vector2(0, -r * 0.35), c + Vector2(-r * 0.7, -r * 0.9), ink, width, true)
	ci.draw_line(c + Vector2(0, -r * 0.35), c + Vector2(r * 0.7, -r * 0.9), ink, width, true)
	ci.draw_line(c + Vector2(-r * 0.55, r * 0.3), c + Vector2(r * 0.55, r * 0.3), ink, width, true)


func _text(font: Font, text: String, at: Vector2, px: int, ink: Color) -> void:
	if text == "":
		return
	var shade := Color(UiKit.SHADOW, UiKit.SHADOW.a * ink.a)
	draw_string_outline(font, at + Vector2(0, UiKit.SHADOW_DROP), text, HORIZONTAL_ALIGNMENT_LEFT, -1, px, UiKit.SHADOW_SPREAD, shade)
	draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, px, 4, Color(UiKit.INK, ink.a))
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, px, ink)


func _text_width() -> float:
	return maxf(UiKit.TITLE_FONT.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, NAME_SIZE).x,
		UiKit.TEXT_FONT.get_string_size(detail, HORIZONTAL_ALIGNMENT_LEFT, -1, DETAIL_SIZE).x) + 4.0
