class_name UltCard
extends BaseButton
## One ultimate on the hero screen (E2-06): its name and, under it, "Escolhida" in old gold, nothing when it can be
## chosen, or a lock and the Mastery level that opens it. Chosen: a brighter line and an emerald one inside (the
## Emeth's). Focus is the ivory line of the Gift nodes; the mouse takes the focus with it.

const SIZE := Vector2(206, 62)
const NAME_SIZE := 19
const SUB_SIZE := 15
const EMERALD := Color("3fae7c")

var def: UltDef
var open := false:
	set(v):
		open = v
		queue_redraw()
var chosen := false:
	set(v):
		chosen = v
		queue_redraw()


func setup(p_def: UltDef) -> UltCard:
	def = p_def
	name = String(def.id)
	custom_minimum_size = SIZE
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(func() -> void:
		if not has_focus():
			grab_focus())
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	return self


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var ink := UiKit.INK if open else TalentNode.LOCK_INK
	if chosen:
		ink = UiKit.INK.lerp(EMERALD.darkened(0.6), 0.45)
	draw_rect(r, ink)
	var line := UiKit.OLD_GOLD.lightened(0.45) if chosen else (UiKit.OLD_GOLD if open else TalentNode.LOCK_LINE)
	draw_rect(r.grow(-1.0), line, false, UiKit.FRAME)
	if chosen:
		draw_rect(r.grow(-5.0), Color(EMERALD, 0.7), false, 1.0)
	if has_focus():
		draw_rect(r.grow(3.0), TalentNode.FOCUS, false, 1.6)
	var title := T.t(def.name_key)
	var font := UiKit.BOLD_FONT
	var col := UiKit.PALE if open else UiKit.DIM
	var at := Vector2(14.0, 26.0)
	UiKit.draw_shadow(self, font, at, title, NAME_SIZE)
	draw_string(font, at, title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 24.0, NAME_SIZE, col)
	var sub := ""
	var sub_col := UiKit.DIM
	if not open:
		sub = T.t(&"hero_ult_locked", {"n": def.mastery_level})
	elif chosen:
		sub = T.t(&"hero_ult_chosen")
		sub_col = UiKit.GOLD
	if sub != "":
		draw_string(UiKit.TEXT_FONT, Vector2(14.0, 48.0), sub, HORIZONTAL_ALIGNMENT_LEFT, size.x - 24.0, SUB_SIZE, sub_col)
