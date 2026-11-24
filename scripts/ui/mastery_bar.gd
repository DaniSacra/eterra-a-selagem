class_name MasteryBar
extends Control
## A hero's Mastery at a glance (docs/design/warrior_spec.md 7, piece 2): the level on a small diamond of old gold and
## the XP bar of that level, with "Maestria" over its left end and "30 de 50 XP" over its right end. `xp` is the whole
## XP (the level comes out of it through the MasteryCurve), so the end screen can tween it across level-ups: the bar
## fills, empties and the number goes up (level_changed). The hero screen and the end screen share it.

signal level_changed(level: int)

## Height of the whole control and of the bar, side of the level's diamond, in pixels at 720 lines.
const HEIGHT := 46.0
const BAR := 10.0
const DIAMOND := 44.0
const GAP := 12.0
const LABEL_SIZE := 16
const LEVEL_SIZE := 22
const FILL_LOW := Color("6f5a33")
const FILL_HIGH := Color("c9a764")
const BACK := Color(0.05, 0.04, 0.06, 0.9)

var curve: MasteryCurve
## The whole XP shown (a float so a tween can run it).
var xp := 0.0:
	set(v):
		xp = maxf(v, 0.0)
		var now := level()
		if now != _level:
			_level = now
			level_changed.emit(now)
		queue_redraw()
var _level := 1
## On the parchment of the Livro de Ahk (HeroScreen): the words in ink, no shadow.
var paper := false


func setup(p_curve: MasteryCurve, p_xp: int, width: float = 360.0) -> MasteryBar:
	curve = p_curve
	xp = p_xp
	_level = level()
	custom_minimum_size = Vector2(width, HEIGHT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


func level() -> int:
	return curve.level_of(int(xp)) if curve else 1


## XP inside the current level and what the level needs (need 0 at the top).
func progress() -> Vector2i:
	return curve.progress(int(xp)) if curve else Vector2i.ZERO


## 0..1: how full the bar is now (full at the top level).
func fill() -> float:
	var p := progress()
	if p.y <= 0:
		return 1.0
	return clampf((xp - curve.total_to(level())) / float(p.y), 0.0, 1.0)


func xp_text() -> String:
	var p := progress()
	if p.y <= 0:
		return T.t(&"hero_xp_max")
	return T.t(&"hero_xp", {"a": p.x, "b": p.y})


func _draw() -> void:
	var cy := size.y * 0.5
	# the level on a diamond of old gold, the number in Cinzel
	var c := Vector2(DIAMOND * 0.5, cy)
	var h := DIAMOND * 0.5
	var outer := PackedVector2Array([c + Vector2(0, -h), c + Vector2(h, 0), c + Vector2(0, h), c + Vector2(-h, 0)])
	draw_colored_polygon(outer, UiKit.INK)
	draw_polyline(_closed(outer), UiKit.OLD_GOLD.lightened(0.2), UiKit.FRAME, true)
	var inner := PackedVector2Array([c + Vector2(0, -h + 5), c + Vector2(h - 5, 0), c + Vector2(0, h - 5), c + Vector2(-h + 5, 0)])
	draw_polyline(_closed(inner), Color(UiKit.OLD_GOLD, 0.45), 1.0, true)
	var n := str(level())
	var font := UiKit.TITLE_FONT
	var w := font.get_string_size(n, HORIZONTAL_ALIGNMENT_LEFT, -1, LEVEL_SIZE).x
	var at := c + Vector2(-w * 0.5, font.get_ascent(LEVEL_SIZE) * 0.38)
	UiKit.draw_shadow(self, font, at, n, LEVEL_SIZE)
	draw_string(font, at, n, HORIZONTAL_ALIGNMENT_LEFT, -1, LEVEL_SIZE, UiKit.GOLD)
	# the bar under its two labels
	var x0 := DIAMOND + GAP
	var bar := Rect2(x0, cy + 4.0, size.x - x0 - 2.0, BAR)
	# on the parchment the track is an ink rail (no black block): paper 15% darker, a 1.5 px ink outline
	draw_rect(bar, Book.PAPER.darkened(0.15) if paper else BACK)
	var f := fill()
	if f > 0.0:
		var filled := Rect2(bar.position, Vector2(bar.size.x * f, bar.size.y))
		draw_polygon(PackedVector2Array([filled.position, Vector2(filled.end.x, filled.position.y), filled.end,
			Vector2(filled.position.x, filled.end.y)]), PackedColorArray([FILL_LOW, FILL_HIGH, FILL_HIGH, FILL_LOW]))
		draw_line(Vector2(filled.end.x, bar.position.y), Vector2(filled.end.x, bar.end.y), UiKit.PALE, 1.5)
	if paper:
		draw_rect(bar.grow(1.0), Book.INK, false, 1.5)
	else:
		draw_rect(bar.grow(1.0), UiKit.OLD_GOLD, false, UiKit.FRAME * 0.75)
	var text_font := UiKit.BOLD_FONT
	var label := T.t(&"hero_mastery_level", {"n": level()})  # the diamond alone never said it was the level (B10)
	var base := cy - 4.0
	if not paper:
		UiKit.draw_shadow(self, text_font, Vector2(x0, base), label, LABEL_SIZE)
	draw_string(text_font, Vector2(x0, base), label, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE, Book.INK if paper else UiKit.PARCHMENT)
	var right := xp_text()
	var num := UiKit.number_font()
	var rw := num.get_string_size(right, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE).x
	var rat := Vector2(bar.end.x - rw, base)
	if not paper:
		UiKit.draw_shadow(self, num, rat, right, LABEL_SIZE)
	draw_string(num, rat, right, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE, Book.FADED if paper else UiKit.DIM.lightened(0.2))


static func _closed(poly: PackedVector2Array) -> PackedVector2Array:
	var out := poly.duplicate()
	out.append(poly[0])
	return out
