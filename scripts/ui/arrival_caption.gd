class_name ArrivalCaption
extends Control
## SW-O1: the arrival's single line, a subtitle at the foot of the screen: Alegreya, ivory, a shadow, no box, centred,
## above the row of actions. It comes in IN seconds, stays and goes out OUT seconds. Child of the Hud; display only.
##   caption.show_line(&"arrival_line")        # the whole fade: IN + HOLD + OUT
##   caption.show_line(&"arrival_line", 2.5)   # the short one of a skipped arrival
##   caption.clear()

const IN := 0.5
const HOLD := 4.0
const OUT := 0.6
## The short stay after a skip (SW-O1).
const SKIPPED := 2.5
## Pixels above the bottom edge: over the row of actions (the TipToast stands at 172 too, they never meet).
const BOTTOM := 215.0
const TEXT_PX := 24
const WIDTH_RATIO := 0.8
## At most this many lines (a longer text is cut with "..." rather than reach the row of actions).
const MAX_LINES := 2

var _label: Label
var _tween: Tween
## The key on show (&"" none).
var key := &""


func _ready() -> void:
	name = "ArrivalCaption"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label = UiKit.shadow(UiKit.label("", UiKit.PALE, TEXT_PX, UiKit.TEXT_FONT))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.max_lines_visible = MAX_LINES
	_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_label.anchor_left = (1.0 - WIDTH_RATIO) * 0.5
	_label.anchor_right = 1.0 - (1.0 - WIDTH_RATIO) * 0.5
	_label.anchor_top = 1.0
	_label.anchor_bottom = 1.0
	_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_label.offset_bottom = -BOTTOM
	_label.modulate.a = 0.0
	add_child(_label)


## The words of key at the foot: in IN, held, out OUT. seconds: the whole stay (0: IN + HOLD + OUT); never shorter than IN + OUT.
func show_line(new_key: StringName, seconds: float = 0.0) -> void:
	key = new_key
	var total := seconds if seconds > 0.0 else IN + HOLD + OUT
	_label.text = T.t(new_key)
	if _tween != null:
		_tween.kill()
	_tween = create_tween().set_ignore_time_scale(true)
	_tween.tween_property(_label, "modulate:a", 1.0, IN)
	_tween.tween_interval(maxf(total - IN - OUT, 0.0))
	_tween.tween_property(_label, "modulate:a", 0.0, OUT)
	_tween.tween_callback(func() -> void: key = &"")


## Gone at once.
func clear() -> void:
	if _tween != null:
		_tween.kill()
	key = &""
	if _label != null:
		_label.modulate.a = 0.0
