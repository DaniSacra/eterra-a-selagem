class_name HubGuideOverlay
extends Control
## PT-5: the unlock guide's face over the Santuário. One guide at a time (a queue): a breathing ring and an arrow on
## the station, and a plate in the StationSign's language with the sentence ({key} is the real key of interact now) and
## "any key continues". Any key, button or click moves on; after the last one the camera is handed back (done). The hub
## holds the hero and leans the camera on `current` meanwhile.
##   var g := HubGuideOverlay.new().setup(defs)

## The guide on show changed (null: none left) / all were seen.
signal changed(def: HubGuideDef)
signal done

## Seconds before a press moves on (the press that brought him here is no skip) and the plate's rise.
const GRACE := 0.5
const APPEAR := 0.25
const PLATE_W := 460.0
const EDGE := 16.0
const ARROW := 22.0
## Px from the station's anchor to the plate's near edge.
const GAP := 76.0
const RING := Color(0.98, 0.84, 0.5)

var queue: Array[HubGuideDef] = []
var current: HubGuideDef
var plate: PanelContainer
var text: Label
var hint: Label
var key: StationSign.KeyCap
var _t := 0.0
var _below := false


func setup(defs: Array[HubGuideDef]) -> HubGuideOverlay:
	queue = defs.duplicate()
	name = "HubGuideOverlay"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	plate = PanelContainer.new()
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_theme_stylebox_override(&"panel", UiKit.box(Color(0.035, 0.027, 0.04, 0.92), UiKit.OLD_GOLD, 2, 16, 6))
	add_child(plate)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override(&"separation", 8)
	plate.add_child(v)
	text = UiKit.label("", UiKit.PALE, 20, UiKit.BOLD_FONT)
	text.custom_minimum_size.x = PLATE_W
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(text)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 8)
	v.add_child(row)
	key = StationSign.KeyCap.new()
	row.add_child(key)
	hint = UiKit.label(T.t(&"guide_continue"), DoorSign.HINT_COLOR, 16, UiKit.BOLD_FONT)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(hint)
	Controls.device_changed.connect(func(_pad: bool) -> void: _refresh())
	_next()
	return self


func active() -> bool:
	return current != null


## The guide on show goes; the next comes, or the camera is handed back.
func advance() -> void:
	_next()


func _next() -> void:
	current = queue.pop_front() if not queue.is_empty() else null
	_t = 0.0
	visible = current != null
	_refresh()
	changed.emit(current)
	if current == null:
		done.emit()


## The sentence with the key of interact as it stands now (device, remapping) and the key plate beside the hint.
func _refresh() -> void:
	var k := UiKit.action_label(&"interact")
	key.set_key(k, Controls.using_pad)
	if current != null:
		text.text = T.t(current.text_key, {"key": k})


func _input(event: InputEvent) -> void:
	if current == null or _t < GRACE:
		return
	var press := false
	if event is InputEventKey:
		press = event.pressed and not event.echo
	elif event is InputEventMouseButton or event is InputEventJoypadButton:
		press = event.pressed
	if press:
		get_viewport().set_input_as_handled()
		advance()


func _process(delta: float) -> void:
	if current == null:
		return
	_t += delta
	queue_redraw()
	var anchor := _screen_point()
	var s := plate.get_combined_minimum_size()
	plate.size = s
	var view := get_viewport_rect().size
	var x := clampf(anchor.x - s.x * 0.5, EDGE, maxf(EDGE, view.x - s.x - EDGE))
	# above the arrow; where the anchor stands near the top of the screen, under it
	_below = anchor.y - GAP - s.y < EDGE
	var y := anchor.y + GAP if _below else anchor.y - GAP - s.y
	y = clampf(y, EDGE, maxf(EDGE, view.y - s.y - EDGE))
	var a := clampf(_t / APPEAR, 0.0, 1.0)
	plate.position = Vector2(x, y + (1.0 - a) * 8.0)
	plate.modulate.a = a


## Where the station's anchor lies on the screen.
func _screen_point() -> Vector2:
	var cam := get_viewport().get_camera_3d()
	if cam == null or current == null:
		return get_viewport_rect().size * 0.5
	var p := cam.unproject_position(HubPlan.anchor(current.station))
	var view := get_viewport_rect().size
	return Vector2(clampf(p.x, EDGE, view.x - EDGE), clampf(p.y, EDGE, view.y - EDGE))


func _draw() -> void:
	if current == null:
		return
	var a := clampf(_t / APPEAR, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.28 * a))
	var p := _screen_point()
	var breath := 0.5 + 0.5 * sin(_t * 3.2)
	for i in 3:
		draw_arc(p, 30.0 + breath * 8.0 + i * 9.0, 0.0, TAU, 48, Color(RING, (0.5 - i * 0.14) * a), 2.5)
	# the arrow bobs toward the station: down at it when the plate is above, up when below
	var dir := -1.0 if _below else 1.0
	var tip := p - Vector2(0, dir * (44.0 + sin(_t * 4.0) * 4.0))
	var pts := PackedVector2Array([tip, tip + Vector2(-ARROW * 0.6, -dir * ARROW), tip + Vector2(ARROW * 0.6, -dir * ARROW)])
	draw_colored_polygon(pts, Color(RING, a))
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[0]]), Color(0.1, 0.06, 0.02, a), 2.0)
