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
const BOSS_GROW := 8.5
const NAME_SIZE := 14
const DEPTH_SIZE := 15
## The medallion's body: the page's ink a third lighter than the ink itself, never black (AP-4 1.7: luma 35 to 50).
const DISC := Color(0.208, 0.143, 0.091)
## The hair ring of paper between the gilt ring and the ink.
const PAPER_RING := Color(0.83, 0.75, 0.6)
## Morvath's wax seal: dark muted violet (hue 275 to 290, saturation up to 0.45, value up to 0.45).
const WAX := Color(0.364, 0.252, 0.42)
## What the room's row is above its centre when the entrance vignette (the cave mouth) is drawn, and the strata.
const TOP_PAD := 36.0
const STRATA_STEP := 0.04
const FEATHER := 36.0
const DASH := 3.0
## The petrol of the room stood in (the ribbon's, lit to read on the paper).
const HERE := Color(0.08, 0.42, 0.42)
## The faded share of what is left behind.
const BEHIND_ALPHA := 0.3
const PATH_WIDTH := 3.2
const DOOR_WIDTH := 2.6
const LINK_WIDTH := 1.4
## A link still reachable: ink, 2 px at 1080.
const REACH_WIDTH := 1.8
## The pointer focuses a room within this far of its centre.
const PICK := RADIUS + 8.0
## The find's diamond, half its height (px at 720 lines).
const FIND := 8.0
const FIND_PAPER := Color(0.84, 0.77, 0.62)

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
	custom_minimum_size = Vector2(320, maxf(map.depths(), 1) * 40.0 + TOP_PAD)
	for id: int in map.rooms:
		var seal := (map.room(id) as DescentMap.Room).kind == RunMap.Kind.BOSS and not (map.room(id) as DescentMap.Room).hidden
		var g := DoorGlyph.new().setup(map.mark(id), MARK * (1.3 if seal else 1.0))
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
	var row_h := row_height()
	var n: int = (map.layers[r.depth - 1] as Array).size()
	var w := size.x - GUTTER - 70.0
	return Vector2(GUTTER + w * (r.index + 0.5) / float(n), TOP_PAD + row_h * (r.depth - 0.5))


## One depth's height: what is left under the entrance vignette shared by the depths.
func row_height() -> float:
	return (size.y - TOP_PAD) / maxf(map.depths(), 1)


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
		g.modulate.a = 0.5 if faded else 1.0
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
	var row_h := row_height()
	var font := UiKit.number_font()
	var here_depth := map.room(map.current).depth if map.room(map.current) else 0
	_strata(row_h)
	_cave_mouth()
	for d in map.depths():
		var col := Book.RUBRIC if d + 1 == here_depth else Book.FADED
		draw_string(font, Vector2(0, TOP_PAD + row_h * (d + 0.5) + DEPTH_SIZE * 0.36), str(d + 1), HORIZONTAL_ALIGNMENT_RIGHT,
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
			# left behind: dashed ink at 0.35
			draw_dashed_line(from, to, Color(Book.INK, 0.35), LINK_WIDTH, DASH, true)
		1:
			draw_line(from, to, Color(Book.INK, 0.85), REACH_WIDTH, true)
		2:
			if map.walked(a_id, b_id):
				if ink < 1.0 and b_id == map.current and _newest_from() == a_id:
					# MAP-08: the stretch into the room stood in draws itself in ink, a blot at the nib
					to = from.lerp(to, ink)
					if ink > 0.0:
						draw_circle(to, PATH_WIDTH * 0.85, Book.RUBRIC)
				if ink > 0.0 or b_id != map.current:
					draw_line(from, to, Book.RUBRIC, PATH_WIDTH, true)
					draw_circle(from, PATH_WIDTH * 0.5, Book.RUBRIC)
					draw_circle(to, PATH_WIDTH * 0.5, Book.RUBRIC)
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
	var r_ := map.room(id)
	if r_ != null and r_.kind == RunMap.Kind.BOSS and not r_.hidden:
		wax_seal(self, c, rad, a)
		if st == DescentMap.State.CURRENT:
			draw_arc(c, rad + 5.0, 0.0, TAU, 40, HERE, 2.0, true)
		elif st == DescentMap.State.DOOR:
			draw_circle(c, rad + 8.0, Color(Book.GILT, 0.16))
			draw_arc(c, rad + 2.0, 0.0, TAU, 40, Book.GILT, 2.4, true)
	else:
		medallion(self, c, rad, st)
	if r_ != null and r_.find != &"":
		find_diamond(self, c + Vector2(rad + 5.0, -(rad + 5.0)) * 0.74, a)
	if id == focus_id:
		var r := rad + (9.0 if st == DescentMap.State.CURRENT else 6.0)
		var col := Book.RUBRIC if has_focus() else Color(Book.RUBRIC, 0.6)
		draw_arc(c, r, 0.0, TAU, 44, col, 2.2, true)
		# a small diamond on its left (the right side carries the chevrons and the guardian's name)
		var p := c - Vector2(r + 6.0, 0)
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -4.5), p + Vector2(4.5, 0), p + Vector2(0, 4.5),
			p + Vector2(-4.5, 0)]), col)


## A room's medallion as the map and the legend draw it (AP-4 1.7): a body of ink, a hair ring of paper, then the ring
## by the room's state (the common one in engraved gilt, the way walked in rubric, the room stood in a double ring of
## petrol, a door opened gilt with its halo); a room left behind has a faded body and a ring of ink.
static func medallion(ci: CanvasItem, c: Vector2, rad: float, st: DescentMap.State, alpha: float = 1.0) -> void:
	var behind := st == DescentMap.State.BEHIND
	if st == DescentMap.State.DOOR:
		ci.draw_circle(c, rad + 8.0, Color(Book.GILT, 0.16))
	ci.draw_circle(c, rad, Color(Book.FADED, BEHIND_ALPHA) if behind else DISC)
	var ring := Book.GILT
	var width := 2.0
	match st:
		DescentMap.State.DONE:
			ring = Book.RUBRIC
			width = 2.2
		DescentMap.State.CURRENT:
			ring = HERE
			width = 3.0
			ci.draw_arc(c, rad + 5.0, 0.0, TAU, 40, HERE, 1.6, true)
		DescentMap.State.DOOR:
			width = 2.6
		DescentMap.State.BEHIND:
			ring = Color(Book.INK, 0.6)
	if not behind:
		ci.draw_arc(c, rad - width - 0.6, 0.0, TAU, 36, Color(PAPER_RING, 0.9), 1.0, true)
	var r_mid := rad - width * 0.5
	ci.draw_arc(c, r_mid, 0.0, TAU, 40, ring, width, true)
	if ring == Book.GILT:
		# engraved: a pale hair on the upper left, a dark one under the lower right
		ci.draw_arc(c, r_mid + width * 0.25, PI * 0.8, PI * 1.7, 20, Book.GILT.lightened(0.3), 1.0, true)
		ci.draw_arc(c, r_mid - width * 0.25, -PI * 0.15, PI * 0.7, 20, Color(Book.INK, 0.4), 1.0, true)


## Morvath at the foot of the descent: a lump of dark violet wax with an uneven edge (its mark, the three chevrons,
## stands on it), a lit rim on the upper left and a dark one on the lower right.
static func wax_seal(ci: CanvasItem, c: Vector2, rad: float, alpha: float = 1.0) -> void:
	var edge := PackedVector2Array()
	for i in 41:
		var a := TAU * float(i) / 40.0
		edge.append(c + Vector2(cos(a), sin(a)) * rad * (1.0 + 0.055 * sin(a * 7.0 + 0.6) + 0.03 * sin(a * 3.0)))
	ci.draw_colored_polygon(edge, Color(WAX, alpha))
	ci.draw_arc(c, rad * 0.8, PI * 0.8, PI * 1.7, 20, Color(WAX.lightened(0.22), alpha), 1.6, true)
	ci.draw_arc(c, rad * 0.8, -PI * 0.15, PI * 0.7, 20, Color(WAX.darkened(0.4), alpha), 1.6, true)
	ci.draw_polyline(edge, Color(Book.INK, 0.8 * alpha), 1.4, true)


## The strata (AP-4 1.7): every two depths a wash 4% darker than the one above, soft where they meet and fading out
## towards the sides, so the page reads as layers going down.
func _strata(row_h: float) -> void:
	var layers := ceili(map.depths() / 2.0)
	var x0 := GUTTER - 4.0
	var x1 := size.x - 4.0
	for k in layers:
		var y0 := TOP_PAD + row_h * 2.0 * k
		var y1 := minf(TOP_PAD + row_h * 2.0 * (k + 1), size.y)
		var a_k := STRATA_STEP * k
		var a_n := STRATA_STEP * (k + 1) if k + 1 < layers else a_k
		var soft := minf(14.0, (y1 - y0) * 0.5)
		# the wash is flat over the layer and runs into the next one over `soft` px at its foot
		_wash(x0, x1, y0 if k == 0 else y0 + soft * 0.0, y1 - soft, a_k, a_k)
		_wash(x0, x1, y1 - soft, y1, a_k, (a_k + a_n) * 0.5)


## A strip of black wash from alpha `top` to `bottom`, feathered to nothing at its two ends.
func _wash(x0: float, x1: float, y0: float, y1: float, top: float, bottom: float) -> void:
	if y1 <= y0 or (top <= 0.0 and bottom <= 0.0):
		return
	var xs := [x0, x0 + FEATHER, x1 - FEATHER, x1]
	var fs := [0.0, 1.0, 1.0, 0.0]
	for i in 3:
		draw_polygon(PackedVector2Array([Vector2(xs[i], y0), Vector2(xs[i + 1], y0), Vector2(xs[i + 1], y1), Vector2(xs[i], y1)]),
			PackedColorArray([Color(0, 0, 0, top * fs[i]), Color(0, 0, 0, top * fs[i + 1]),
				Color(0, 0, 0, bottom * fs[i + 1]), Color(0, 0, 0, bottom * fs[i])]))


## Above the first room, the mouth of the catacombs in ink: an arch of three stones over steps going down. No figure.
func _cave_mouth() -> void:
	var first := -1
	for id: int in map.rooms:
		if (map.room(id) as DescentMap.Room).depth == 1:
			first = id
			break
	if first < 0:
		return
	var c := centre(first)
	var base := Vector2(c.x, c.y - RADIUS - 6.0)
	var w := 13.0
	var legs := 7.0
	var ink := Color(Book.INK, 0.9)
	# the dark of the opening and the steps in it
	var arch := PackedVector2Array()
	for i in 13:
		var a := PI + PI * float(i) / 12.0
		arch.append(base + Vector2(0, -legs) + Vector2(cos(a) * w, sin(a) * w))
	var hole := PackedVector2Array([base + Vector2(-w, 0)])
	hole.append_array(arch)
	hole.append(base + Vector2(w, 0))
	draw_colored_polygon(hole, Color(Book.INK, 0.8))
	for k in 3:
		var y := base.y - 1.0 - k * 3.2
		var half := w * (1.0 - k * 0.28)
		draw_line(Vector2(base.x - half, y), Vector2(base.x + half, y), Color(Book.PAPER, 0.55), 1.2, true)
	# the stone round it: the arch, its legs and the two joints that make three stones
	draw_polyline(PackedVector2Array([base + Vector2(-w, 0), base + Vector2(-w, -legs)] + Array(arch) + [base + Vector2(w, -legs), base + Vector2(w, 0)]), ink, 2.2, true)
	for ang: float in [PI * 4.0 / 3.0, PI * 5.0 / 3.0]:
		var d := Vector2(cos(ang), sin(ang))
		var o := base + Vector2(0, -legs)
		draw_line(o + d * (w - 5.0), o + d * (w + 4.0), ink, 1.6, true)
	draw_line(base + Vector2(-w - 4.0, 0), base + Vector2(w + 4.0, 0), ink, 1.6, true)


## The diamond of a room that keeps a find (Ofícios, 10_ux.md 10.7): old gold with a dark edge on the medallion's
## upper right, the only mark of it on the map.
static func find_diamond(ci: CanvasItem, at: Vector2, alpha: float = 1.0) -> void:
	var r := FIND
	# a patch of paper under it: a link passing there stops short of it
	ci.draw_circle(at, r + 3.0, Color(FIND_PAPER, alpha))
	var d := PackedVector2Array([at + Vector2(0, -r), at + Vector2(r * 0.8, 0), at + Vector2(0, r), at + Vector2(-r * 0.8, 0)])
	ci.draw_colored_polygon(d, Color(UiKit.OLD_GOLD, alpha))
	d.append(d[0])
	ci.draw_polyline(d, Color(Book.INK, alpha), 2.0, true)
	ci.draw_circle(at, r * 0.22, Color(Book.INK, alpha * 0.8))


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
