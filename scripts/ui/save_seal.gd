class_name SaveSeal
extends CanvasLayer
## The small seal that says the game was saved (benchmark_hades2_ui.md P2-4): at the foot of the screen on the right,
## over the action bar's row, a ring of old gold with the diamond pressed in it and "Salvo", for SHOWN seconds every
## time the save is written (Save.written: the end of a descent, a Gift equipped, a forging...). Never without a save
## (--nosave, tests: Save.write does nothing). Over everything (LAYER), never takes the mouse.
##   Save.written.connect(SaveSeal.flash)   # Save makes one the first time

const LAYER := 120
## Seconds on screen, to come and to go.
const SHOWN := 1.0
const IN := 0.15
const OUT := 0.3
const RING := 11.0
const TEXT_SIZE := 15
## From the bottom right corner (px at 720 lines): over the action bar's row.
const CORNER := Vector2(28, 54)

var _box: HBoxContainer
var _tween: Tween


func _ready() -> void:
	layer = LAYER
	_box = HBoxContainer.new()
	_box.name = "saved"
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_theme_constant_override(&"separation", 7)
	_box.anchor_left = 1.0
	_box.anchor_right = 1.0
	_box.anchor_top = 1.0
	_box.anchor_bottom = 1.0
	_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_box.offset_right = -CORNER.x
	_box.offset_bottom = -CORNER.y
	add_child(_box)
	var mark := Control.new()
	mark.custom_minimum_size = Vector2(RING * 2.0 + 2.0, RING * 2.0 + 2.0)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mark.draw.connect(func() -> void:
		var c := mark.size * 0.5
		mark.draw_circle(c, RING, UiKit.INK)
		mark.draw_arc(c, RING, 0.0, TAU, 32, UiKit.OLD_GOLD, 2.0, true)
		var h := RING * 0.5
		mark.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -h), c + Vector2(h * 0.8, 0), c + Vector2(0, h), c + Vector2(-h * 0.8, 0)]), UiKit.GOLD))
	_box.add_child(mark)
	var l := UiKit.shadow(UiKit.label(T.t(&"saved"), UiKit.PALE, TEXT_SIZE, UiKit.BOLD_FONT))
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_box.add_child(l)
	_box.modulate.a = 0.0


## Shows the seal for SHOWN seconds (again from the start when it was already on show).
func show_saved() -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_box, ^"modulate:a", 1.0, IN)
	_tween.tween_interval(SHOWN)
	_tween.tween_property(_box, ^"modulate:a", 0.0, OUT)


## The seal shown, made the first time (Save calls this on every write).
static func flash(host: Node) -> SaveSeal:
	var s := host.get_node_or_null(^"SaveSeal") as SaveSeal
	if s == null:
		s = SaveSeal.new()
		s.name = "SaveSeal"
		host.add_child(s)
	s.show_saved()
	return s
