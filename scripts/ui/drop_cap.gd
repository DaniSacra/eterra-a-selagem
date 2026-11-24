class_name DropCap
extends Control
## An illuminated capital for the Livro de Ahk (AP-4 1.4): the first letter of a paragraph in rubric Cinzel inside a
## square of engraved gilt filet with two sprays of leaves (never a cross nor a star), three lines tall, the first
## three lines of the paragraph beside it and the rest under it at the full column. The text is the paragraph's own
## (its first letter is the capital, the rest keeps its words); nothing is added.
##   var p := DropCap.paragraph(T.t(&"book_epigraph"), Book.INK, 22, 347.0)

const LINES := 3
const GAP := 10.0

var letter := ""


## The paragraph: capital and head side by side, the tail under both. Left aligned in a column `width` wide.
static func paragraph(text: String, color: Color, size: int, width: float, font: Font = UiKit.TEXT_FONT) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.name = "dropcap_paragraph"
	v.add_theme_constant_override(&"separation", 0)
	v.custom_minimum_size.x = width
	var line_h := ceilf(font.get_height(size))
	var cap := DropCap.new()
	cap.letter = text.substr(0, 1)
	cap.custom_minimum_size = Vector2(line_h * LINES, line_h * LINES)
	var parts := split(text.substr(1), font, size, width - cap.custom_minimum_size.x - GAP)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", int(GAP))
	row.add_child(cap)
	var head := Book.text(parts[0], color, size)
	head.name = "head"
	head.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(head)
	v.add_child(row)
	if parts[1] != "":
		var tail := Book.text(parts[1], color, size)
		tail.name = "tail"
		v.add_child(tail)
	return v


## The text cut after LINES lines of `width` (the head) and what is left (the tail), at word breaks.
static func split(text: String, font: Font, size: int, width: float) -> Array[String]:
	var p := TextParagraph.new()
	p.width = width
	p.break_flags = TextServer.BREAK_WORD_BOUND | TextServer.BREAK_MANDATORY
	p.add_string(text, font, size)
	var out: Array[String] = [text, ""]
	if p.get_line_count() > LINES:
		var cut := p.get_line_range(LINES - 1).y
		out = [text.substr(0, cut).strip_edges(), text.substr(cut).strip_edges()]
	return out


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN


func _draw() -> void:
	var s := minf(size.x, size.y)
	var box := Rect2(Vector2.ZERO, Vector2(s, s))
	# the filet: two lines of engraved gilt, the inner one thinner
	_engraved(self, box.grow(-1.0), 2.0)
	_engraved(self, box.grow(-6.0), 1.0)
	# two sprays of leaves in the corners the letter leaves free
	_spray(self, Vector2(s - 9.0, 11.0), Vector2(-1, 1), s * 0.22)
	_spray(self, Vector2(9.0, s - 11.0), Vector2(1, -1), s * 0.22)
	var fs := int(s * 0.7)
	var f := UiKit.TITLE_FONT
	var w := f.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base := Vector2((s - w) * 0.5, s * 0.5 + f.get_ascent(fs) * 0.35)
	draw_string(f, base + Vector2(0.8, 0.8), letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(Book.INK, Book.INK_VALUE))
	draw_string(f, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Book.RUBRIC)


static func _engraved(ci: CanvasItem, r: Rect2, width: float) -> void:
	var a := r.position
	var b := r.end
	ci.draw_rect(Rect2(a + Vector2(0, 1), r.size), Color(Book.INK, 0.4), false, width)
	ci.draw_rect(r, Book.GILT, false, width)
	ci.draw_line(a, Vector2(b.x, a.y), Book.GILT.lightened(0.3), 1.0)


## A curved stem from `from` toward `dir` with leaves on both sides.
static func _spray(ci: CanvasItem, from: Vector2, dir: Vector2, length: float, color: Color = Book.GILT) -> void:
	var prev := from
	for i in 4:
		var t := float(i + 1) / 4.0
		var p := from + Vector2(dir.x * length * t, dir.y * length * t * 0.35 + dir.y * length * 0.5 * t * t)
		ci.draw_line(prev, p, color, 1.4, true)
		var n := (p - prev).normalized()
		for side: float in [-1.0, 1.0]:
			var perp := Vector2(-n.y, n.x) * side
			_leaf(ci, p, (n * 0.5 + perp).normalized(), 6.0 - float(i), color)
		prev = p


static func _leaf(ci: CanvasItem, at: Vector2, d: Vector2, len: float, color: Color = Book.GILT) -> void:
	var perp := Vector2(-d.y, d.x) * len * 0.32
	var tip := at + d * len
	var mid := at + d * len * 0.5
	ci.draw_colored_polygon(PackedVector2Array([at, mid + perp, tip, mid - perp]), color)


# ---- the capital of a Gift's entry in the codex (Livro de Ahk, meta_screens_identity.md 1.1) ----

## How loud the letter is by the entry's rung: a plain letter, a letter with filigree, an illuminated one.
enum Rung { PLAIN, FILIGREE, ILLUMINATED }
## The square's side by rung, px at 720 lines (28, 34 and 44 px letters inside).
const RUNG_SIDE := [34.0, 42.0, 52.0]
const RUNG_LETTER := [28, 34, 44]


## A Gift's capital in `box`: `ink` is the branch's colour (`ink2`, when set, splits the capital on the diagonal: a
## bridge); `fill` 0..1 how much of the field is coloured, from the bottom (worn: 1; open or sealed: only the line
## of the letter); `faded` the pencilled outline of a locked one.
static func gift(ci: CanvasItem, box: Rect2, letter: String, rung: Rung, ink: Color, ink2: Color, fill: float, faded: bool) -> void:
	var s := minf(box.size.x, box.size.y)
	var r := Rect2(box.position, Vector2(s, s))
	var line := Color(Book.FADED, 0.5) if faded else ink
	var fs := int(RUNG_LETTER[rung] * s / RUNG_SIDE[rung])
	var f := UiKit.TITLE_FONT
	var w := f.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base := r.position + Vector2((s - w) * 0.5, s * 0.5 + f.get_ascent(fs) * 0.35)
	if rung != Rung.PLAIN or fill > 0.0:
		var edge := Color(Book.GILT, 0.35 if faded else 1.0)
		ci.draw_rect(r.grow(-1.0), edge, false, 2.0 if rung == Rung.ILLUMINATED else 1.2)
		if rung == Rung.ILLUMINATED:
			ci.draw_rect(r.grow(-5.0), Color(edge, 0.6), false, 1.0)
	if fill > 0.0:
		var top := r.end.y - s * fill
		var field := Rect2(Vector2(r.position.x + 2.0, top), Vector2(s - 4.0, r.end.y - 2.0 - top))
		if ink2.a > 0.0:
			# a bridge: split on the diagonal in the two branches' inks
			ci.draw_rect(field, ink)
			var cut := Geometry2D.intersect_polygons(PackedVector2Array([field.position, Vector2(field.end.x, field.position.y),
				field.end, Vector2(field.position.x, field.end.y)]),
				PackedVector2Array([r.position + Vector2(s, 0), r.position + Vector2(s, s), r.position + Vector2(0, s)]))
			for part in cut:
				ci.draw_colored_polygon(part, ink2)
		else:
			ci.draw_rect(field, ink)
	elif ink2.a > 0.0 and not faded:
		# a bridge not worn: the two inks as the two halves of the frame
		ci.draw_line(r.position + Vector2(s - 2, 3), r.position + Vector2(3, s - 2), ink2, 2.0, true)
	if rung == Rung.FILIGREE and not faded:
		_spray(ci, r.position + Vector2(s - 7.0, 9.0), Vector2(-1, 1), s * 0.2, Color(Book.GILT, 0.6))
	var lit := fill > 0.55
	var letter_color := Book.PAPER.lightened(0.35) if lit else line
	if lit:
		ci.draw_string(f, base + Vector2(0.8, 0.8), letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(Book.INK, 0.5))
		ci.draw_string(f, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, letter_color)
	else:
		# the open and sealed ones: the letter in the branch's ink on the bare paper (no field); the locked: a pencil line
		if faded:
			ci.draw_string_outline(f, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 2, Color(line, 0.9))
			ci.draw_string(f, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(Book.PAPER, 0.6))
		else:
			ci.draw_string(f, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, line)
