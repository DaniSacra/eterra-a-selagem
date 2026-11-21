class_name MapGraph
extends Control
## The descent drawn on the right page of the map (MapScreen): the entrance at the top, Morvath at the foot, one row
## per depth with its number in the margin. Each room is a small medallion of ink with the mark the doors' signs use
## (DoorGlyph: the reward's, or the room's own for the fountain, the shop, the altar, the Provação and Morvath, "?"
## while hidden), the chevrons of a hard fight or of the guardian beside it, and the guardian's name. The way walked
## is a line of rubric, the room stood in has a double ring of petrol, the doors open from it a ring and links of
## gilt, the rooms still reachable plain ink, and the branches left behind faded. One room has the focus (a ring of
## rubric); left and right walk its depth, up and down the next ones (DescentMap.step); the pointer focuses the room
## under it. Sizes in pixels at 720 lines.

signal focused(id: int)

## The medallion's radius and the mark inside it (the marks stand 18 px or more at 720 lines).
const RADIUS := 17.0
const MARK := 20.0
const BADGE := 14.0
const GUTTER := 34.0
const BOSS_GROW := 5.0
const NAME_SIZE := 14
const DEPTH_SIZE := 15
const DISC := Color(0.15, 0.1, 0.07)
const DISC_EDGE := Color(0.3, 0.22, 0.13)
## The petrol of the room stood in (the ribbon's, lit to read on the paper).
const HERE := Color(0.08, 0.42, 0.42)
## The faded share of what is left behind.
const BEHIND_ALPHA := 0.3
const PATH_WIDTH := 3.2
const DOOR_WIDTH := 2.6
const LINK_WIDTH := 1.4
## The pointer focuses a room within this far of its centre.
const PICK := RADIUS + 8.0

## MAP-08: the newest stretch of the way walked (into the room stood in) drawn so far, 0..1 (draw_in animates it).
var ink := 1.0:
	set(v):
		ink = clampf(v, 0.0, 1.0)
		queue_redraw()
var map: DescentMap
var focus_id := -1
var _marks: Dictionary = {}
var _badges: Dictionary = {}
var _names: Dictionary = {}


func setup(m: DescentMap) -> MapGraph:
	map = m
	name = "graph"
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(320, maxf(map.depths(), 1) * 40.0)
	for id: int in map.rooms:
		var g := DoorGlyph.new().setup(map.mark(id), MARK)
		g.name = "mark_%d" % id
		add_child(g)
		_marks[id] = g
		var b := map.badge(id)
		if b != DoorGlyph.Kind.NONE:
			var bg := DoorGlyph.new().setup(b, BADGE)
			bg.name = "badge_%d" % id
			add_child(bg)
			_badges[id] = bg
		var short := map.guardian_short(id)
		if (map.room(id) as DescentMap.Room).kind == RunMap.Kind.BOSS:
			short = T.t(&"map_morvath")
		if short != "":
			var l := Book.label(short, Book.RUBRIC, NAME_SIZE, UiKit.BOLD_FONT)
			l.name = "name_%d" % id
			l.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(l)
			_names[id] = l
	resized.connect(_layout)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	return self


## Where a room's medallion stands in this control.
func centre(id: int) -> Vector2:
	var r := map.room(id)
	if r == null:
		return Vector2.ZERO
	var rows := maxf(map.depths(), 1)
	var row_h := size.y / rows
	var n: int = (map.layers[r.depth - 1] as Array).size()
	var w := size.x - GUTTER - 70.0
	return Vector2(GUTTER + w * (r.index + 0.5) / float(n), row_h * (r.depth - 0.5))


func set_focus(id: int) -> void:
	if id == focus_id or map.room(id) == null:
		return
	focus_id = id
	queue_redraw()
	focused.emit(id)


func _layout() -> void:
	for id: int in _marks:
		var c := centre(id)
		var g: DoorGlyph = _marks[id]
		g.size = g.custom_minimum_size
		g.position = c - g.size * 0.5
		var faded := map.state(id) == DescentMap.State.BEHIND
		g.modulate.a = BEHIND_ALPHA + 0.1 if faded else 1.0
		var x := c.x + radius(id) + 5.0
		if _badges.has(id):
			var b: DoorGlyph = _badges[id]
			b.size = b.custom_minimum_size
			b.position = Vector2(x, c.y - b.size.y * 0.5)
			b.modulate.a = g.modulate.a
			x += b.size.x + 4.0
		if _names.has(id):
			var l: Label = _names[id]
			l.reset_size()
			l.position = Vector2(x, c.y - l.size.y * 0.5)
			l.modulate.a = g.modulate.a
	queue_redraw()


func _draw() -> void:
	if map == null:
		return
	var rows := maxf(map.depths(), 1)
	var row_h := size.y / rows
	var font := UiKit.TITLE_FONT
	var here_depth := map.room(map.current).depth if map.room(map.current) else 0
	for d in map.depths():
		var col := Book.RUBRIC if d + 1 == here_depth else Book.FADED
		draw_string(font, Vector2(0, row_h * (d + 0.5) + DEPTH_SIZE * 0.36), str(d + 1), HORIZONTAL_ALIGNMENT_RIGHT,
			GUTTER - 12.0, DEPTH_SIZE, col)
	# the links under the medallions: those left behind first, the way walked and the doors last
	for pass_ in 3:
		for id: int in map.rooms:
			var r := map.room(id)
			for to: int in r.next:
				if map.room(to) == null:
					continue
				var kind := _link_kind(id, to)
				if kind != pass_:
					continue
				_link(id, to, kind)
	for id: int in map.rooms:
		_room(id)


## 0: a link left behind, 1: a link still open ahead, 2: walked or from the room stood in to an open door.
func _link_kind(a: int, b: int) -> int:
	if map.walked(a, b) or (a == map.current and map.doors.has(b)):
		return 2
	var sa := map.state(a)
	var sb := map.state(b)
	if sb == DescentMap.State.BEHIND or sa == DescentMap.State.BEHIND or sa == DescentMap.State.DONE:
		return 0
	return 1


func _link(a_id: int, b_id: int, kind: int) -> void:
	var a := centre(a_id)
	var b := centre(b_id)
	var dir := (b - a).normalized()
	var from := a + dir * (radius(a_id) + 2.0)
	var to := b - dir * (radius(b_id) + 2.0)
	match kind:
		0:
			draw_line(from, to, Color(Book.INK, 0.14), LINK_WIDTH, true)
		1:
			draw_line(from, to, Color(Book.INK, 0.5), LINK_WIDTH, true)
		2:
			if map.walked(a_id, b_id):
				if ink < 1.0 and b_id == map.current and _newest_from() == a_id:
					# MAP-08: the stretch into the room stood in draws itself in ink, a blot at the nib
					to = from.lerp(to, ink)
					if ink > 0.0:
						draw_circle(to, PATH_WIDTH * 0.85, Book.RUBRIC)
				if ink > 0.0 or b_id != map.current:
					draw_line(from, to, Book.RUBRIC, PATH_WIDTH, true)
			else:
				draw_line(from, to, Book.GILT, DOOR_WIDTH, true)


## The room the way walked came from into the room stood in (-1: none, the first room).
func _newest_from() -> int:
	var at := map.path.find(map.current)
	return map.path[at - 1] if at > 0 else -1


## MAP-08: draws the newest stretch of the way walked in ink over `seconds` (real time), after `wait`.
func draw_in(seconds: float, wait: float = 0.0) -> void:
	if _newest_from() < 0:
		return
	ink = 0.0
	var t := create_tween().set_ignore_time_scale(true)
	t.tween_property(self, ^"ink", 1.0, seconds).set_delay(wait).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## A room's medallion radius: Morvath's a little larger (his three chevrons are his mark).
func radius(id: int) -> float:
	var r := map.room(id)
	return RADIUS + BOSS_GROW if r != null and r.kind == RunMap.Kind.BOSS and not r.hidden else RADIUS


func _room(id: int) -> void:
	var c := centre(id)
	var st := map.state(id)
	var a := BEHIND_ALPHA if st == DescentMap.State.BEHIND else 1.0
	var rad := radius(id)
	if st == DescentMap.State.DOOR:
		draw_circle(c, rad + 8.0, Color(Book.GILT, 0.16))
	draw_circle(c, rad, Color(DISC, a))
	var ring := DISC_EDGE
	var width := 1.5
	match st:
		DescentMap.State.DONE:
			ring = Book.RUBRIC
			width = 2.2
		DescentMap.State.CURRENT:
			ring = HERE
			width = 3.0
			draw_arc(c, rad + 5.0, 0.0, TAU, 40, HERE, 1.6, true)
		DescentMap.State.DOOR:
			ring = Book.GILT
			width = 2.6
		DescentMap.State.AHEAD:
			ring = Book.FADED
	draw_arc(c, rad - width * 0.5, 0.0, TAU, 40, Color(ring, a), width, true)
	if id == focus_id:
		var r := rad + (9.0 if st == DescentMap.State.CURRENT else 6.0)
		var col := Book.RUBRIC if has_focus() else Color(Book.RUBRIC, 0.6)
		draw_arc(c, r, 0.0, TAU, 44, col, 2.2, true)
		# a small diamond on its left (the right side carries the chevrons and the guardian's name)
		var p := c - Vector2(r + 6.0, 0)
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -4.5), p + Vector2(4.5, 0), p + Vector2(0, 4.5),
			p + Vector2(-4.5, 0)]), col)


func _gui_input(event: InputEvent) -> void:
	var dir := Vector2i.ZERO
	if event.is_action_pressed(&"ui_left", true):
		dir = Vector2i.LEFT
	elif event.is_action_pressed(&"ui_right", true):
		dir = Vector2i.RIGHT
	elif event.is_action_pressed(&"ui_up", true):
		dir = Vector2i.UP
	elif event.is_action_pressed(&"ui_down", true):
		dir = Vector2i.DOWN
	if dir != Vector2i.ZERO:
		var to := map.step(focus_id, dir)
		if to != focus_id:
			set_focus(to)
			accept_event()
		elif dir.y != 0:
			# no room further up or down: the focus stays on the map
			accept_event()
		return
	if event is InputEventMouseMotion or (event is InputEventMouseButton and (event as InputEventMouseButton).pressed):
		var at := pick((event as InputEventMouse).position)
		if at >= 0:
			set_focus(at)
		if event is InputEventMouseButton and not has_focus():
			grab_focus()


## The room under a point of this control, -1 for none.
func pick(at: Vector2) -> int:
	var best := -1
	var best_d := PICK
	for id: int in map.rooms:
		var d := centre(id).distance_to(at)
		if d < best_d:
			best_d = d
			best = id
	return best
