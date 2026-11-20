class_name MapScreen
extends Control
## The descent's map (DV-1, MAP-03), a page of the Livro de Ahk (BookSpread, Book). The right page draws the descent
## (MapGraph: the entrance at the top, Morvath at the foot, the way walked, the room stood in, the doors open now and
## the branches left behind); the left page tells the room in focus (its name, the room's number, the reward, the
## guardian, the arena and how it stands now), a short legend of the marks (the doors' own, DoorGlyph) and Voltar.
## The focus starts on the first open door; the arrows, the d-pad and the pointer walk the rooms. The map key (M, Back
## on the gamepad), the pause key (Esc, Start) and Voltar close it. Opened from the HUD (the map key, the "Mapa [M]"
## button: the run stops under it through Game.open_screen) and from the pause (a page of it). It only reads: choosing
## is still crossing a door in the arena.

signal closed

## The spine: the left page (the room in focus, the legend) narrower than the map's.
const SPINE := 0.37
const OUTER := Vector2(22, 10)
const TEXT_SIZE := 16
const LEGEND_SIZE := 15
const LEGEND_ROW := 22.0
const LEGEND_MARK := 18.0
const BACK_WIDTH := 170.0
## The legend: each mark and its name (the marks of the signs, then how a room reads).
const LEGEND: Array[Array] = [
	[DoorGlyph.Kind.BLESSING, &"reward_boon"], [DoorGlyph.Kind.POMEGRANATE, &"reward_pom"],
	[DoorGlyph.Kind.HEART, &"reward_heart"], [DoorGlyph.Kind.MAGICK, &"reward_magick"],
	[DoorGlyph.Kind.GOLD, &"reward_gold"], [DoorGlyph.Kind.SILVER, &"material_silver_short"],
	[DoorGlyph.Kind.MEMORY, &"material_memory_short"], [DoorGlyph.Kind.FOUNTAIN, &"room_fountain"],
	[DoorGlyph.Kind.SHOP, &"room_shop"], [DoorGlyph.Kind.ALTAR, &"room_altar"],
	[DoorGlyph.Kind.TRIAL, &"room_trial"], [DoorGlyph.Kind.UNKNOWN, &"map_legend_hidden"],
	[DoorGlyph.Kind.HARD, &"door_hard"], [DoorGlyph.Kind.GUARDIAN, &"room_miniboss"],
	[DoorGlyph.Kind.BOSS, &"map_morvath"],
]
## How a room reads (DescentMap.State), drawn as on the map.
const STATES: Array[Array] = [[DescentMap.State.CURRENT, &"map_key_current"], [DescentMap.State.DOOR, &"map_key_door"],
	[DescentMap.State.DONE, &"map_key_done"], [DescentMap.State.BEHIND, &"map_key_behind"]]

var map: DescentMap
var graph: MapGraph
var _title: Label
var _lines: VBoxContainer
var _back: Button
var _closing := false


## m: the descent to show (null: the run this screen belongs to, DescentMap.from_game).
func open(m: DescentMap = null) -> void:
	map = m if m != null else DescentMap.from_game(_game())
	name = "map_screen"
	theme = Book.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.0, 0.02, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var frame := MarginContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override(&"margin_left", int(OUTER.x))
	frame.add_theme_constant_override(&"margin_right", int(OUTER.x))
	frame.add_theme_constant_override(&"margin_top", int(OUTER.y))
	frame.add_theme_constant_override(&"margin_bottom", int(BookSpread.RIBBON_DROP))
	add_child(frame)
	var book := BookSpread.new().setup(SPINE)
	frame.add_child(book)
	_left_page(book.left)
	graph = MapGraph.new().setup(map)
	book.right.add_child(graph)
	graph.focus_neighbor_left = graph.get_path_to(_back)
	graph.focus_neighbor_top = graph.get_path_to(graph)
	graph.focus_neighbor_bottom = graph.get_path_to(graph)
	_back.focus_neighbor_right = _back.get_path_to(graph)
	_back.focus_neighbor_top = _back.get_path_to(graph)
	graph.focused.connect(_show)
	var start := map.first_focus()
	graph.set_focus(start)
	graph.grab_focus.call_deferred()


func _left_page(page: MarginContainer) -> void:
	var v := VBoxContainer.new()
	v.name = "left"
	v.add_theme_constant_override(&"separation", 6)
	page.add_child(v)
	v.add_child(Book.heading(T.t(&"map_title"), 28, 260))
	var here := map.room(map.current)
	if here != null:
		var at := Book.text(T.t(&"map_here", {"n": here.depth, "of": map.depths()}), Book.FADED, TEXT_SIZE)
		at.name = "here"
		v.add_child(at)
	v.add_child(Book.section(T.t(&"map_focus")))
	_title = Book.label("", Book.INK, 20, UiKit.TITLE_FONT)
	_title.name = "focus_title"
	v.add_child(_title)
	_lines = VBoxContainer.new()
	_lines.name = "focus_lines"
	_lines.add_theme_constant_override(&"separation", 0)
	v.add_child(_lines)
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gap.custom_minimum_size.y = 4
	v.add_child(gap)
	v.add_child(Book.section(T.t(&"map_legend")))
	var grid := GridContainer.new()
	grid.name = "legend"
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 14)
	grid.add_theme_constant_override(&"v_separation", 0)
	v.add_child(grid)
	# only the marks this descent's map has (UI review d2ff05d, P2-9: the legend had grown past the page)
	var present := legend_kinds(map)
	for entry: Array in LEGEND:
		if not present.has(entry[0]):
			continue
		grid.add_child(_legend_row(_legend_mark(entry[0] as DoorGlyph.Kind), T.t(entry[1] as StringName)))
	for entry: Array in STATES:
		grid.add_child(_legend_row(_state_mark(entry[0] as DescentMap.State), T.t(entry[1] as StringName)))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override(&"separation", 12)
	v.add_child(foot)
	_back = Book.button(T.t(&"back"), func() -> void: close(), BACK_WIDTH)
	_back.name = "back"
	_back.custom_minimum_size.y = 40
	foot.add_child(_back)
	var hint := Book.label(T.t(&"map_close_hint", {"key": Controls.label(&"map")}), Book.FADED, 14)
	hint.name = "hint"
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	foot.add_child(hint)


## The marks a descent's map shows (its rooms' marks and chevrons), for the legend.
static func legend_kinds(m: DescentMap) -> Dictionary:
	var out := {}
	for id: int in m.rooms:
		out[m.mark(id)] = true
		out[m.badge(id)] = true
	return out


func _legend_row(mark: Control, text: String) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override(&"separation", 6)
	h.custom_minimum_size.y = LEGEND_ROW
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(mark)
	var l := Book.label(text, Book.INK, LEGEND_SIZE)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(l)
	return h


## A mark of the legend as it stands on the map: in its ink medallion, the chevrons of a fight bare beside it.
func _legend_mark(kind: DoorGlyph.Kind) -> Control:
	var box := Control.new()
	box.custom_minimum_size = Vector2(LEGEND_MARK + 14.0, LEGEND_MARK + 2.0)
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bare := kind == DoorGlyph.Kind.HARD or kind == DoorGlyph.Kind.GUARDIAN
	var boss := kind == DoorGlyph.Kind.BOSS
	var g := DoorGlyph.new().setup(kind, LEGEND_MARK * (0.8 if bare else (0.62 if boss else 0.95)))
	g.size = g.custom_minimum_size
	g.position = (box.custom_minimum_size - g.size) * 0.5
	if not bare:
		box.draw.connect(func() -> void:
			var c := box.size * 0.5
			var r := LEGEND_MARK * 0.62
			box.draw_circle(c, r, MapGraph.DISC)
			box.draw_arc(c, r - 0.7, 0.0, TAU, 28, MapGraph.DISC_EDGE, 1.4, true))
	box.add_child(g)
	return box


## How a room reads, as a small medallion with the map's ring (or, for the way walked, its line).
func _state_mark(st: DescentMap.State) -> Control:
	var box := Control.new()
	box.custom_minimum_size = Vector2(LEGEND_MARK + 14.0, LEGEND_MARK + 2.0)
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.draw.connect(_draw_state.bind(box, st))
	return box


static func _draw_state(box: Control, st: DescentMap.State) -> void:
	var c := box.size * 0.5
	var r := LEGEND_MARK * 0.5
	match st:
		DescentMap.State.DONE:
			box.draw_line(c - Vector2(r + 6, 0), c + Vector2(r + 6, 0), Book.RUBRIC, MapGraph.PATH_WIDTH, true)
			box.draw_circle(c, r * 0.7, MapGraph.DISC)
			box.draw_arc(c, r * 0.7 - 1.0, 0.0, TAU, 24, Book.RUBRIC, 2.0, true)
		DescentMap.State.CURRENT:
			box.draw_circle(c, r * 0.7, MapGraph.DISC)
			box.draw_arc(c, r * 0.7 - 1.2, 0.0, TAU, 24, MapGraph.HERE, 2.4, true)
			box.draw_arc(c, r * 0.7 + 3.0, 0.0, TAU, 24, MapGraph.HERE, 1.4, true)
		DescentMap.State.DOOR:
			box.draw_circle(c, r + 2.0, Color(Book.GILT, 0.16))
			box.draw_circle(c, r * 0.7, MapGraph.DISC)
			box.draw_arc(c, r * 0.7 - 1.2, 0.0, TAU, 24, Book.GILT, 2.4, true)
		_:
			box.draw_circle(c, r * 0.7, Color(MapGraph.DISC, MapGraph.BEHIND_ALPHA))
			box.draw_arc(c, r * 0.7 - 0.7, 0.0, TAU, 24, Color(MapGraph.DISC_EDGE, MapGraph.BEHIND_ALPHA), 1.4, true)


## The left page tells the room in focus.
func _show(id: int) -> void:
	_title.text = map.title(id)
	for c in _lines.get_children():
		c.queue_free()
	var first := true
	for line in map.lines(id):
		var l := Book.text(line, Book.INK if first else Book.FADED, TEXT_SIZE)
		_lines.add_child(l)
		first = false
	# how it stands now, last, in ink (in the rubric it read as an error; UI review d2ff05d, P2-9)
	if _lines.get_child_count() > 0:
		(_lines.get_child(_lines.get_child_count() - 1) as Label).add_theme_color_override(&"font_color", Book.INK)


## The text on the left page now (tests).
func focus_text() -> String:
	var parts: PackedStringArray = [_title.text]
	for c in _lines.get_children():
		if not c.is_queued_for_deletion():
			parts.append((c as Label).text)
	return "\n".join(parts)


func close() -> void:
	if _closing:
		return
	_closing = true
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"map") or event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


## The run this map belongs to (the Game above it), or null.
func _game() -> Node:
	var n := get_parent()
	while n != null and not n is Game:
		n = n.get_parent()
	return n
