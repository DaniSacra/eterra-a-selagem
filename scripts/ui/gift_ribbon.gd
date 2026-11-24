class_name GiftRibbon
extends BaseButton
## A chapter's ribbon of the Livro de Ahk (meta_screens_identity.md 1.1): a marker ribbon in the branch's ink hanging
## from the top of the page, its tail notched. The open one hangs lower and its name is bright; at its tip a gold dot
## for each Gift worn in that chapter (up to three, then "+N"). The last ribbon is gold: "Poder maior", the ultimates.
## Focus shows the chapter, like the book's own bookmarks; the mouse takes it with it.

const HANG := 34.0
const HANG_OPEN := 42.0
const FONT := 15
const PAD := 10.0
const NOTCH := 7.0

var branch := 0
var title := ""
var tint := Book.INK
var open := false:
	set(v):
		open = v
		queue_redraw()
var worn := 0:
	set(v):
		worn = v
		queue_redraw()


func setup(p_branch: int, p_title: String, p_tint: Color) -> GiftRibbon:
	branch = p_branch
	title = p_title
	tint = p_tint
	name = "ribbon_%d" % branch
	focus_mode = Control.FOCUS_ALL
	var w := UiKit.BOLD_FONT.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT).x
	custom_minimum_size = Vector2(w + PAD * 2.0, HANG_OPEN + 4.0)
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	mouse_entered.connect(func() -> void:
		if not has_focus():
			grab_focus())
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	return self


func _draw() -> void:
	var h := HANG_OPEN if open else HANG
	var w := size.x
	var body := PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(w * 0.5, h - NOTCH), Vector2(0, h)])
	var shade := tint.darkened(0.45)
	draw_colored_polygon(body, tint if open else tint.darkened(0.12))
	draw_polyline(PackedVector2Array([body[0], body[4], body[3], body[2], body[1]]), shade, 1.2, true)
	draw_line(Vector2(3, 0), Vector2(3, h - 4.0), Color(1, 1, 1, 0.12), 1.0)
	if has_focus():
		draw_polyline(PackedVector2Array([Vector2(-2, 0), Vector2(-2, h + 2.0), Vector2(w * 0.5, h - NOTCH + 2.0), Vector2(w + 2, h + 2.0), Vector2(w + 2, 0)]),
			Book.RUBRIC, 1.8, true)
	var f := UiKit.BOLD_FONT
	var tw := f.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT).x
	var col := Book.MARK_IVORY if open else Color(Book.MARK_IVORY, 0.8)
	draw_string(f, Vector2((w - tw) * 0.5, 19.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT, col)
	if worn > 0:
		var dots := mini(worn, 3)
		var x0 := w * 0.5 - (dots - 1) * 5.0 - (7.0 if worn > 3 else 0.0)
		for i in dots:
			draw_circle(Vector2(x0 + i * 10.0, h - 7.0), 3.0, Book.GILT.lightened(0.5))
		if worn > 3:
			draw_string(UiKit.BOLD_FONT, Vector2(x0 + dots * 10.0 - 4.0, h - 3.0), "+%d" % (worn - 3), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Book.MARK_IVORY)
