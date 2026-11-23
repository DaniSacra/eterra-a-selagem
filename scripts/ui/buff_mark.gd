class_name BuffMark
extends Control
## A buff running (the Brado de Guerra's 5 s): a small diamond with the move's glyph, the frame's old gold line shrinking
## round it as the time runs out, and the seconds left beside it in lining figures. Hidden when none runs. Placed by
## Hud over the Q diamond. px at 720 lines.
##   var mark := BuffMark.new().setup(BoonIcon.SHOUT_GLYPH)
##   mark.show_left(2.4, 5.0)       # seconds left, of how many

const SIDE := 24.0
const FONT := 15
const GAP := 4.0
const WARM := Color("e8b45a")
## combate_c1_leitura 5: the emerald dot at the diamond corner while the Brado still absorbs blows (gifts.ward > 0).
const ABSORB := Color(0.30, 0.78, 0.45)

var glyph := BoonIcon.SHOUT_GLYPH
var left := 0.0
## It still absorbs a blow (the emerald dot).
var absorbing := false
var total := 1.0
var _text := ""


func setup(p_glyph: int) -> BuffMark:
	name = "BuffMark"
	glyph = p_glyph
	custom_minimum_size = Vector2(SIDE + GAP + 20.0, SIDE)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	return self


## seconds_left of total_s; 0 or less hides the mark.
func show_left(seconds_left: float, total_s: float, absorbs := false) -> void:
	visible = seconds_left > 0.0
	if absorbs != absorbing:
		absorbing = absorbs
		queue_redraw()
	var t := ceili(seconds_left)
	if not is_equal_approx(seconds_left, left) or total_s != total:
		left = seconds_left
		total = maxf(total_s, 0.01)
		_text = str(t)
		queue_redraw()


func _draw() -> void:
	var r := SIDE * 0.5
	var c := Vector2(r, r)
	draw_colored_polygon(ActionSlot._diamond(c, r + 1.5), Color(UiKit.INK, 0.92))
	draw_colored_polygon(ActionSlot._diamond(c, r), Color(UiKit.OLD_GOLD.darkened(0.5), 1.0))
	draw_colored_polygon(ActionSlot._diamond(c, r - UiKit.FRAME), Color(UiKit.INK, 1.0))
	BoonIcon.glyph(self, glyph, c, r * 0.42, ActionSlot.IVORY, WARM.darkened(0.5))
	var part := ActionSlot._sweep(c, r - UiKit.FRAME * 0.5, clampf(left / total, 0.0, 1.0))
	if part.size() > 1:
		draw_polyline(part, WARM, UiKit.FRAME, true)
	if absorbing:
		var dot := Vector2(SIDE - 3.0, 3.0)
		draw_circle(dot, 4.6, UiKit.INK)
		draw_circle(dot, 3.2, ABSORB)
	var font := UiKit.number_font()
	var at := Vector2(SIDE + GAP, (SIDE + font.get_ascent(FONT) - font.get_descent(FONT)) * 0.5).round()
	UiKit.draw_shadow(self, font, at, _text, FONT)
	draw_string_outline(font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT, 4, UiKit.INK)
	draw_string(font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT, UiKit.PALE)
