class_name RhythmMeter
extends Control
## HUD v3: the Ritmo de Batalha over the bars: a small lion medallion, the name, and a thin gold line under it that fills while the
## rhythm is armed (BattleRhythm.share(): the share of its time still to run). Quiet (dim, the line only a track) when it is not.
## Pure display: the HUD calls show_value().
##   meter.show_value(0.6)

const FONT := 14
const MEDAL := 11.0
const LINE_H := 2.0
const DIM := 0.55

var share := 0.0
var _text := ""


func setup(width: float) -> RhythmMeter:
	name = "RhythmMeter"
	custom_minimum_size = Vector2(width, MEDAL * 2.0 + 6.0)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text = T.t(&"hud_rhythm")
	return self


func show_value(v: float) -> void:
	v = snappedf(clampf(v, 0.0, 1.0), 0.01)
	if v != share:
		share = v
		queue_redraw()


## Armed: the rhythm has time left.
func armed() -> bool:
	return share > 0.0


func _draw() -> void:
	var a := 1.0 if armed() else DIM
	HudArt.medallion(self, &"bar_icon_supreme", Vector2(MEDAL, MEDAL + 1.0), MEDAL - 1.0, UiKit.GOLD)
	var font := UiKit.TITLE_FONT
	var base := Vector2(MEDAL * 2.0 + 7.0, MEDAL + 1.0 + (font.get_ascent(FONT) - font.get_descent(FONT)) * 0.5).round()
	UiKit.draw_shadow(self, font, base, _text, FONT)
	draw_string(font, base, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT, Color(UiKit.PALE, a))
	var x0 := MEDAL * 2.0 + 4.0
	var y := size.y - LINE_H
	draw_rect(Rect2(x0, y - 0.5, size.x - x0, LINE_H + 1.0), Color(UiKit.INK, 0.6))
	draw_rect(Rect2(x0, y, size.x - x0, LINE_H), Color(UiKit.OLD_GOLD, 0.45))
	if share > 0.0:
		draw_rect(Rect2(x0, y, (size.x - x0) * share, LINE_H), UiKit.GOLD)
