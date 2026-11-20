class_name UltCard
extends BaseButton
## One ultimate on the hero screen (E2-06), on the book's paper like its buttons (Book.button): its name and, under
## it, its state written: "Escolhida" in the page's green, "Pode escolher", or the Mastery level that opens it.
## Chosen: a green line and a second one inside. Focus is the rubric line of the paper buttons; the mouse takes the
## focus with it.

const SIZE := Vector2(206, 62)
const NAME_SIZE := 19
const SUB_SIZE := 15

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
	# on the book's paper (UI review d2ff05d, P1-6): the paper buttons' fills, the state always written
	var r := Rect2(Vector2.ZERO, size)
	var fill := Book.BUTTON_PAPER if open else Color(Book.BUTTON_PAPER, Book.BUTTON_PAPER.a * 0.4)
	if chosen:
		fill = Color(Book.OK, 0.16)
	draw_rect(r, fill)
	var line := Book.OK if chosen else (Book.GILT if open else Color(Book.GILT, 0.45))
	draw_rect(r.grow(-0.5), line, false, 1.0 if not chosen else 2.0)
	if chosen:
		draw_rect(r.grow(-4.0), Color(Book.OK, 0.5), false, 1.0)
	if has_focus():
		draw_rect(r.grow(3.0), Book.RUBRIC, false, 1.6)
	var title := T.t(def.name_key)
	draw_string(UiKit.BOLD_FONT, Vector2(14.0, 26.0), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 24.0, NAME_SIZE,
		Book.INK if open else Book.FADED)
	var sub := T.t(&"hero_ult_can_choose")
	var sub_col := Book.FADED
	if not open:
		sub = T.t(&"hero_ult_locked", {"n": def.mastery_level})
	elif chosen:
		sub = T.t(&"hero_ult_chosen")
		sub_col = Book.OK
	draw_string(UiKit.TEXT_FONT, Vector2(14.0, 48.0), sub, HORIZONTAL_ALIGNMENT_LEFT, size.x - 24.0, SUB_SIZE, sub_col)
