class_name UltCard
extends BaseButton
## One ultimate on the last chapter of the Livro de Ahk, "Poder maior" (meta_screens_identity.md 1.1): a full-width
## illumination on the left page, its miniature (assets/ui/book/ult_<id>.png, else the placeholder) in a frame, its
## name and its state written beside it. Locked: only the sepia pencil base drawing and "Maestria N"; open: in colour;
## chosen: a frame of gold. Focus is the rubric line of the paper buttons; the mouse takes the focus with it.

const MIN_HEIGHT := 150.0
const NAME_SIZE := 22
const SUB_SIZE := 16

var def: UltDef
var tint := GiftArt.ULT_INK
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
	custom_minimum_size = Vector2(240.0, MIN_HEIGHT)
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(func() -> void:
		if not has_focus():
			grab_focus())
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	return self


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var gold := Color(GiftArt.ULT_INK.r, GiftArt.ULT_INK.g, GiftArt.ULT_INK.b)
	draw_rect(r, Book.BUTTON_PAPER if open else Color(Book.BUTTON_PAPER, Book.BUTTON_PAPER.a * 0.4))
	var line_col := Book.GILT if open else Color(Book.GILT, 0.45)
	if chosen:
		line_col = gold
		draw_rect(r.grow(-0.5), gold, false, 3.0)
		draw_rect(r.grow(-6.0), Color(gold, 0.6), false, 1.0)
	else:
		draw_rect(r.grow(-0.5), line_col, false, 1.0)
	if has_focus():
		draw_rect(r.grow(3.0), Book.RUBRIC, false, 1.6)
	var art_h := size.y - 24.0
	var art := Rect2(Vector2(14.0, 12.0), Vector2(minf(art_h * 1.25, size.x * 0.42), art_h))
	GiftArt.paint(self, art, StringName("ult_%s" % def.id), gold, T.t(def.name_key).substr(0, 1), not open)
	draw_rect(art, Color(Book.GILT, 0.8 if open else 0.35), false, 1.4)
	var x := art.end.x + 16.0
	var width := size.x - x - 14.0
	var y := art.position.y + 30.0
	draw_string(UiKit.TITLE_FONT, Vector2(x, y), GiftEntry._fit(T.t(def.name_key), UiKit.TITLE_FONT, NAME_SIZE, width),
		HORIZONTAL_ALIGNMENT_LEFT, -1, NAME_SIZE, Book.INK if open else Book.FADED)
	var sub := T.t(&"hero_ult_can_choose")
	var sub_col := Book.FADED
	if not open:
		sub = T.t(&"hero_ult_locked", {"n": def.mastery_level})
	elif chosen:
		sub = T.t(&"hero_ult_chosen")
		sub_col = Book.OK
	draw_string(UiKit.TEXT_FONT, Vector2(x, y + 28.0), sub, HORIZONTAL_ALIGNMENT_LEFT, width, SUB_SIZE, sub_col)
