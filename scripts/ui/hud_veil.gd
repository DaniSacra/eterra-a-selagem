class_name HudVeil
extends Control
## A short veil of dark ink with cut corners behind HUD text that stands over the scene (the clock, the hit count and
## the move's name; UI review d2ff05d, P1-2): the DoorSign's veil, lighter, fitted each frame round the text of the
## labels it covers (only the part a label's alignment fills, not its whole box) and as faded as the most visible of
## them. Hidden when none of them shows.
##   var veil := HudVeil.new()
##   add_child(veil)
##   move_child(veil, 0)          # under the text
##   veil.covers = [clock]
##   veil.follow()                # each frame

const COLOR := Color(0.035, 0.027, 0.04, 0.55)
## The corners cut this far, px at 720 lines (DoorSign.VEIL_CUT).
const CUT := 6.0
## Room round the text, px at 720 lines.
const PAD := Vector2(10, 2)

var covers: Array[Control] = []


func _init() -> void:
	name = "veil"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


## Fits the veil round what it covers now.
func follow() -> void:
	var r := Rect2()
	var any := false
	var alpha := 0.0
	for c in covers:
		if not c.is_visible_in_tree() or c.modulate.a < 0.02:
			continue
		var t := text_rect(c)
		if t.size.x < 1.0:
			continue
		r = t if not any else r.merge(t)
		any = true
		alpha = maxf(alpha, c.modulate.a)
	visible = any
	if not any:
		return
	r = r.grow_individual(PAD.x, PAD.y, PAD.x, PAD.y)
	global_position = r.position
	size = r.size
	modulate.a = alpha
	queue_redraw()


## The part of a control's box its text fills on screen (a label: by its alignment and scale; other controls: the box).
static func text_rect(c: Control) -> Rect2:
	var box := c.get_global_rect()
	var l := c as Label
	if l == null or l.text == "":
		return box if l == null else Rect2()
	var s := l.get_combined_minimum_size() * l.scale
	var x := box.position.x
	match l.horizontal_alignment:
		HORIZONTAL_ALIGNMENT_RIGHT:
			x = box.end.x - s.x
		HORIZONTAL_ALIGNMENT_CENTER:
			x = box.get_center().x - s.x * 0.5
	return Rect2(Vector2(x, box.position.y), s)


func _draw() -> void:
	var w := size.x
	var h := size.y
	var k := minf(CUT, minf(w, h) * 0.5)
	draw_colored_polygon(PackedVector2Array([Vector2(k, 0), Vector2(w - k, 0), Vector2(w, k), Vector2(w, h - k),
		Vector2(w - k, h), Vector2(k, h), Vector2(0, h - k), Vector2(0, k)]), COLOR)
