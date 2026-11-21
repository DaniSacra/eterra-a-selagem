class_name BookSpread
extends Control
## An open book (art pack stage 2, board 04): a leather cover a little larger than the pages, the edges of the leaves
## under them, two parchment pages (book_page.gdshader: fibres, browned edges, the fold's shadow at the spine) with
## brackets of old gold in their outer corners and a petrol ribbon hanging from the foot. The spine sits at `spine`
## (share of the width): the Compendium's index page is narrower than its list. Content goes into the two pages,
## margin containers that follow the spine (left, right); everything is laid out by anchors, so it fills any screen.
## A single leaf (HUB-B3, the hub's small pages, HubPanel): setup(spine, true) shows one page (left) on the whole
## paper, browned on both sides and without fold, and the book is as big as that page's content (minimum size), so a
## container centres it.
##   var leaf := BookSpread.new().setup(0.5, true)    # leaf.left takes the content

const PAGE_SHADER := preload("res://assets/shaders/book_page.gdshader")
const COVER_SHADER := preload("res://assets/shaders/book_cover.gdshader")
## The cover past the pages and the leaves' edges under them, px at 720 lines.
const COVER := 12.0
const LEAVES := 4
## Inside each page, from its edges (the side by the spine a little more: the fold eats it).
const MARGIN := Vector2(30, 22)
const SPINE_MARGIN := 34.0
## The corner pieces on the cover: width, length of each arm, rivet radius (2 px at 1080 is 1.3 here).
const CORNER_WIDTH := 6.0
const CORNER_LENGTH := 34.0
const RIVET := 1.6
const RIBBON_WIDTH := 16.0
const RIBBON_DROP := 22.0

var spine := 0.5
## One leaf alone (left on the whole paper; right stays empty and hidden).
var single := false
var left: MarginContainer
var right: MarginContainer
var _cover: ColorRect
var _under: Control
var _paper: ColorRect
var _trim: Control
var _queued := false


func setup(p_spine: float = 0.5, p_single: bool = false) -> BookSpread:
	spine = p_spine
	single = p_single
	name = "book"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# the cover (leather, AP-4 1.1), then what sits between it and the pages (the leaves' edges, the ribbon)
	_cover = ColorRect.new()
	_cover.name = "cover"
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cm := ShaderMaterial.new()
	cm.shader = COVER_SHADER
	cm.set_shader_parameter(&"leather", Book.LEATHER)
	cm.set_shader_parameter(&"stitch", Book.LEATHER_EDGE.lightened(0.3))
	_cover.material = cm
	add_child(_cover)
	_under = Control.new()
	_under.name = "under"
	_under.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_under.draw.connect(_draw_under)
	add_child(_under)
	_paper = ColorRect.new()
	_paper.name = "paper"
	_paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := ShaderMaterial.new()
	m.shader = PAGE_SHADER
	m.set_shader_parameter(&"single", single)
	_paper.material = m
	add_child(_paper)
	_trim = Control.new()
	_trim.name = "trim"
	_trim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_trim.draw.connect(_draw_trim)
	add_child(_trim)
	left = _page("left_page", MARGIN.x, MARGIN.x if single else SPINE_MARGIN)
	right = _page("right_page", SPINE_MARGIN, MARGIN.x)
	right.visible = not single
	resized.connect(_layout)
	_layout()
	return self


func _page(id: String, from_left: float, from_right: float) -> MarginContainer:
	var p := MarginContainer.new()
	p.name = id
	p.add_theme_constant_override(&"margin_left", int(from_left))
	p.add_theme_constant_override(&"margin_right", int(from_right))
	p.add_theme_constant_override(&"margin_top", int(MARGIN.y))
	p.add_theme_constant_override(&"margin_bottom", int(MARGIN.y))
	add_child(p)
	# a page grown by its content for a moment (a label wrapping before it had its width) keeps that size unless it
	# is laid out again when its content shrinks back
	p.minimum_size_changed.connect(_relayout)
	if single:
		p.minimum_size_changed.connect(update_minimum_size)
	return p


## A single leaf is as big as its page's content with the cover round it (the open book fills what it is given).
func _get_minimum_size() -> Vector2:
	if not single or left == null:
		return Vector2.ZERO
	return left.get_combined_minimum_size() + Vector2(COVER * 2.0, COVER * 2.0 + LEAVES)


func _relayout() -> void:
	if not _queued:
		_queued = true
		_layout.call_deferred()


## The pages' rect inside this control (the cover round them).
func paper_rect() -> Rect2:
	return Rect2(Vector2(COVER, COVER), size - Vector2(COVER, COVER + LEAVES) * 2.0 + Vector2(0, LEAVES))


func _layout() -> void:
	_queued = false
	var r := paper_rect()
	_paper.position = r.position
	_paper.size = r.size
	_cover.size = size
	(_cover.material as ShaderMaterial).set_shader_parameter(&"size_px", size)
	_under.size = size
	_trim.position = Vector2.ZERO
	_trim.size = size
	var m := _paper.material as ShaderMaterial
	m.set_shader_parameter(&"size_px", r.size)
	m.set_shader_parameter(&"spine", spine)
	var sx := r.size.x if single else r.size.x * spine
	left.position = r.position
	left.size = Vector2(sx, r.size.y)
	right.position = r.position + Vector2(sx, 0)
	right.size = Vector2(r.size.x - sx, r.size.y)
	queue_redraw()
	_under.queue_redraw()
	_trim.queue_redraw()


func _draw() -> void:
	# the shadow of the cover on the table (the leather itself is the cover's shader)
	var cover := UiKit.box(Book.LEATHER, Book.LEATHER_EDGE, 0, 0, 0)
	cover.shadow_color = Color(0, 0, 0, 0.55)
	cover.shadow_size = 18
	draw_style_box(cover, Rect2(Vector2.ZERO, size))


func _draw_under() -> void:
	var r := paper_rect()
	# the leaves under the pages: thin pale lines below and beside them
	for i in LEAVES:
		var k := float(i + 1)
		var tone := Color(0.72, 0.64, 0.5).darkened(0.12 * k)
		_under.draw_rect(Rect2(r.position + Vector2(-k * 0.6, r.size.y + k - 1.0), Vector2(r.size.x + k * 1.2, 1.2)), tone)
	# the ribbon from the foot, by the spine of the right page (a single leaf: from its middle, UI review P2-6)
	var x := r.position.x + r.size.x * (0.5 if single else spine + (1.0 - spine) * 0.18)
	var top := r.end.y - 6.0
	var bottom := size.y + RIBBON_DROP
	var w := RIBBON_WIDTH * 0.5
	_under.draw_colored_polygon(PackedVector2Array([Vector2(x - w, top), Vector2(x + w, top), Vector2(x + w, bottom),
		Vector2(x, bottom - 7.0), Vector2(x - w, bottom)]), Book.RIBBON)
	_under.draw_line(Vector2(x - w + 2, top), Vector2(x - w + 2, bottom - 2), Book.RIBBON.lightened(0.25), 1.0)


## The corner pieces of old gold on the cover's four corners (they were on the pages), engraved: a pale pixel on the
## lit side, a dark one under, and two rivets each.
func _draw_trim() -> void:
	var t := CORNER_WIDTH
	var e := size
	for corner: Vector2 in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]:
		var at := Vector2(e.x * corner.x, e.y * corner.y)
		var sx := 1.0 if corner.x == 0.0 else -1.0
		var sy := 1.0 if corner.y == 0.0 else -1.0
		var arm_x := Rect2(at, Vector2(CORNER_LENGTH * sx, t * sy)).abs()
		var arm_y := Rect2(at, Vector2(t * sx, CORNER_LENGTH * sy)).abs()
		for arm: Rect2 in [arm_x, arm_y]:
			_gilt(arm)
		for k: float in [0.5, 1.0]:
			var rivet := at + Vector2(sx, sy) * Vector2(CORNER_LENGTH * 0.5 * k + t * 0.5 * (1.0 - k), t * 0.5)
			_rivet(rivet)
			_rivet(Vector2(at.x + sx * t * 0.5, at.y + sy * (CORNER_LENGTH * 0.5 * k + t * 0.5 * (1.0 - k))))


func _gilt(r: Rect2) -> void:
	_trim.draw_rect(r, Book.GILT)
	_trim.draw_rect(Rect2(r.position, Vector2(r.size.x, RIVET * 0.5)), Book.GILT.lightened(0.3))
	_trim.draw_rect(Rect2(r.position + Vector2(0, r.size.y - RIVET * 0.5), Vector2(r.size.x, RIVET * 0.5)), Color(Book.INK, 0.4))


func _rivet(at: Vector2) -> void:
	_trim.draw_circle(at, RIVET, Book.INK)
	_trim.draw_circle(at, RIVET * 0.6, Book.GILT.lightened(0.35))
