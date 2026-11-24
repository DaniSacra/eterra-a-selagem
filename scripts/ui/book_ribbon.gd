class_name BookRibbon
extends RefCounted
## The silk ribbons that mark the Livro de Ahk's chapters (docs/art/book_spec.md 1) and the dog-ears of its pages.
## A ribbon stands out of the top of the cover, its end cut in a swallow's tail with the chapter's mark in old gold; in
## focus it rises 6 px; the open one hangs on over the page with the chapter's name written down it in ivory.
## Placeholder: drawn (a feather, the lion or the eight-pointed star, a hammer) until assets/ui/book/ribbon.png.

enum Mark { FEATHER, HERO, HAMMER }

const WIDTH := 44.0
const HEIGHT := 44.0
## How far the open ribbon hangs past its button, over the page; how much a ribbon in focus rises.
const DROP := 70.0
const LIFT := 6.0
const NOTCH := 7.0
const MARK_SIZE := 9.0
const NAME_SIZE := 13
const EAR := 34.0
const OPENING_TINT := Color("6a4a2e")
const OFICIOS_TINT := Color("8a6a2a")
const MAGA_TINT := Color("6a3a14")


## The ribbon of a chapter (a toggle button: pressed is the chapter on show). `hero` draws the lion or the star.
static func make(title: String, tint: Color, mark: Mark, hero: HeroDef = null) -> Button:
	var b := UiKit.button("", Callable(), 0.0)
	b.toggle_mode = true
	b.tooltip_text = title
	b.set_meta(&"title", title)
	b.custom_minimum_size = Vector2(WIDTH, HEIGHT)
	b.size_flags_vertical = Control.SIZE_SHRINK_END
	var empty := StyleBoxEmpty.new()
	for st: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"focus"]:
		b.add_theme_stylebox_override(st, empty)
	var tongue := Control.new()
	tongue.name = "ribbon"
	tongue.show_behind_parent = true
	tongue.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tongue.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tongue.draw.connect(_draw_ribbon.bind(tongue, b, tint, mark, hero))
	b.add_child(tongue)
	for sig: Signal in [b.toggled, b.focus_entered, b.focus_exited, b.mouse_entered, b.mouse_exited]:
		sig.connect(func(_a: Variant = null) -> void: tongue.queue_redraw())
	return b


## The ribbon of the chapter on show lies over the page; the others stay behind the cover.
static func set_open(b: Button, open: bool) -> void:
	b.set_pressed_no_signal(open)
	b.custom_minimum_size.y = HEIGHT + (Book.MARK_RISE if open else 0.0)
	var tongue := b.get_node("ribbon") as Control
	tongue.show_behind_parent = not open
	tongue.z_index = 1 if open else 0
	tongue.queue_redraw()


static func _draw_ribbon(t: Control, b: Button, tint: Color, mark: Mark, hero: HeroDef) -> void:
	var open := b.button_pressed
	var up := LIFT if (b.has_focus() or b.is_hovered()) and not open else 0.0
	var w := t.size.x
	var h := t.size.y + (DROP if open else 0.0)
	var body := tint if open else tint.darkened(0.15)
	t.draw_colored_polygon(_shape(w, h, NOTCH, Vector2(1.3, 1.3 - up)), Color(Book.INK, 0.35))
	t.draw_colored_polygon(_shape(w, h, NOTCH, Vector2(0, -up)), body)
	t.draw_line(Vector2(0.7, NOTCH * 0.2 - up), Vector2(0.7, h - up), body.lightened(0.28), 1.0)
	t.draw_line(Vector2(w - 0.7, NOTCH * 0.2 - up), Vector2(w - 0.7, h - up), body.darkened(0.45), 1.0)
	if b.has_focus():
		t.draw_polyline(PackedVector2Array([Vector2(0, h - up), Vector2(0, -up), Vector2(w * 0.5, NOTCH - up), Vector2(w, -up),
			Vector2(w, h - up)]), UiKit.GOLD, 1.5)
	var gold := Book.GILT.lightened(0.35)
	var at := NOTCH + 3.0 + MARK_SIZE - up
	_draw_mark(t, Vector2(w * 0.5, at), MARK_SIZE, mark, hero, gold)
	if open:
		_draw_name(t, String(b.get_meta(&"title", "")), Vector2(w * 0.5, at + MARK_SIZE + 8.0), h - at - MARK_SIZE - 12.0)


## The name down the ribbon (reading downwards), ivory, smaller if it would not fit `room`.
static func _draw_name(t: Control, text: String, top: Vector2, room: float) -> void:
	var font := UiKit.TITLE_FONT
	var size := NAME_SIZE
	while size > 9 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > room:
		size -= 1
	var len := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	t.draw_set_transform(top + Vector2(size * 0.35, 0.0), PI * 0.5)
	t.draw_string(font, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_LEFT, len + 4.0, size, Book.MARK_IVORY)
	t.draw_set_transform(Vector2.ZERO, 0.0)


static func _draw_mark(ci: CanvasItem, c: Vector2, r: float, mark: Mark, hero: HeroDef, col: Color) -> void:
	match mark:
		Mark.FEATHER:
			# a quill: the shaft on a slant, the vane a leaf on its upper half
			var a := c + Vector2(-r * 0.7, r)
			var z := c + Vector2(r * 0.7, -r)
			ci.draw_line(a, z, col, 1.5, true)
			ci.draw_colored_polygon(PackedVector2Array([z, c + Vector2(r * 0.9, r * 0.1), c + Vector2(-r * 0.1, -r * 0.1)]), col)
		Mark.HERO:
			GiftArt.corner(ci, c, r * 0.9, hero, col)
		Mark.HAMMER:
			ci.draw_line(c + Vector2(-r * 0.6, r), c + Vector2(r * 0.3, -r * 0.5), col, 2.0, true)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.1, -r), c + Vector2(r, -r * 0.45), c + Vector2(r * 0.7, -r * 0.05),
				c + Vector2(-r * 0.4, -r * 0.55)]), col)


static func _shape(w: float, h: float, notch: float, at: Vector2) -> PackedVector2Array:
	return PackedVector2Array([at, at + Vector2(w * 0.5, notch), at + Vector2(w, 0), at + Vector2(w, h), at + Vector2(0, h)])


## A folded corner at the outer foot of a page (click to turn that way). `left`: the left page's.
static func ear(left: bool) -> Button:
	var b := Button.new()
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.custom_minimum_size = Vector2(EAR, EAR)
	b.size = b.custom_minimum_size
	b.draw.connect(func() -> void:
		var s := b.size
		var x_out := 0.0 if left else s.x
		var x_in := s.x - x_out
		# the turned-up corner: a pale triangle on its shadow, its fold pointing at the page's middle
		var tri := PackedVector2Array([Vector2(x_out, 0), Vector2(x_out, s.y), Vector2(x_in, s.y)])
		var shadow := PackedVector2Array([tri[0] + Vector2(1.5, 1.5), tri[1], tri[2] + Vector2(1.5, 1.5)])
		b.draw_colored_polygon(shadow, Color(Book.INK, 0.3))
		b.draw_colored_polygon(tri, Book.PAPER.lightened(0.18 if b.is_hovered() else 0.05))
		b.draw_line(tri[0], tri[2], Color(Book.GILT, 0.75), 1.0, true))
	b.mouse_entered.connect(b.queue_redraw)
	b.mouse_exited.connect(b.queue_redraw)
	return b
