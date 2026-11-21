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
	_engraved(box.grow(-1.0), 2.0)
	_engraved(box.grow(-6.0), 1.0)
	# two sprays of leaves in the corners the letter leaves free
	_spray(Vector2(s - 9.0, 11.0), Vector2(-1, 1), s * 0.22)
	_spray(Vector2(9.0, s - 11.0), Vector2(1, -1), s * 0.22)
	var fs := int(s * 0.7)
	var f := UiKit.TITLE_FONT
	var w := f.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base := Vector2((s - w) * 0.5, s * 0.5 + f.get_ascent(fs) * 0.35)
	draw_string(f, base + Vector2(0.8, 0.8), letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(Book.INK, Book.INK_VALUE))
	draw_string(f, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Book.RUBRIC)


func _engraved(r: Rect2, width: float) -> void:
	var a := r.position
	var b := r.end
	draw_rect(Rect2(a + Vector2(0, 1), r.size), Color(Book.INK, 0.4), false, width)
	draw_rect(r, Book.GILT, false, width)
	draw_line(a, Vector2(b.x, a.y), Book.GILT.lightened(0.3), 1.0)


## A curved stem from `from` toward `dir` with leaves on both sides.
func _spray(from: Vector2, dir: Vector2, length: float) -> void:
	var prev := from
	for i in 4:
		var t := float(i + 1) / 4.0
		var p := from + Vector2(dir.x * length * t, dir.y * length * t * 0.35 + dir.y * length * 0.5 * t * t)
		draw_line(prev, p, Book.GILT, 1.4, true)
		var n := (p - prev).normalized()
		for side: float in [-1.0, 1.0]:
			var perp := Vector2(-n.y, n.x) * side
			_leaf(p, (n * 0.5 + perp).normalized(), 6.0 - float(i))
		prev = p


func _leaf(at: Vector2, d: Vector2, len: float) -> void:
	var perp := Vector2(-d.y, d.x) * len * 0.32
	var tip := at + d * len
	var mid := at + d * len * 0.5
	draw_colored_polygon(PackedVector2Array([at, mid + perp, tip, mid - perp]), Book.GILT)
