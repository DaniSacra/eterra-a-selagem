class_name StationSign
extends Node3D
## The sign of the hub's station in focus (HUB-B3; docs/design/hub_spec_art.md 2.4): one at a time, only while a
## station is in focus, in the DoorSign's language (the station's name in warm gold, Alegreya Sans Bold with the dark
## outline, CAP_PX 19 at 1080 lines; a short line in pale; the veil of dark ink with cut corners) and, under them, the
## real key of the action on the HUD's key plate (round for a gamepad's face button) and the station's verb ("Descer",
## "Ler", verb). The key follows
## the device live (Controls.device_changed: E on the keyboard, A on the gamepad, whatever was remapped) and refresh()
## reads the binding again (after the Configurações). Drawn as interface text over its anchor (a CanvasLayer above
## the world, like the DoorSign): the text's bottom centre on the anchor, always inside the screen and never over the
## hero (hero_at: it rises above his head when the anchor would put it on him, and goes under his feet when the
## anchor is cut by the top of the screen). It comes up in APPEAR seconds.
## A click on it uses the station (pressed), so the mouse alone can use what the hero stands by.
##   var sign := StationSign.make(&"book", T.t(&"hub_book"), T.t(&"hub_book_desc"))
##   sign.position = HubPlan.anchor(&"book")
##   sign.pressed.connect(func() -> void: use(&"book"))

## A click on the sign.
signal pressed

const KEY_SIZE := 15
const KEY_H := 22.0
## Seconds to come up, and how far it rises meanwhile (px at 720 lines).
const APPEAR := 0.15
const RISE := 6.0
## Px between the sign and the hero's head, and from the screen's edges.
const HERO_GAP := 10.0
const EDGE := 8.0
## A sign whose top would come within this share of the screen's height from the top goes under the hero instead:
## its station stands at the top of the screen (the Portal seen from its foot) and the sign would cover it.
const TOP_BAND := 0.06
## Under the object (Rooms.prompt, benchmark_hades2_ui.md P0-1): the plate's top this far under the anchor (the foot
## of the reward, the shop item, the door's medallion), and never on the hero: where he covers that spot it goes under
## his feet, at most a few tens of pixels from the object.
const UNDER_GAP := 6.0
## The hero's drawn height (HeroBody.HEIGHT) and his half width on screen against his height.
const HERO_HEIGHT := 2.75
const HERO_HALF := 0.3
## The veil a little denser than the DoorSign's: the sign stands over a lit floor.
const VEIL := Color(0.035, 0.027, 0.04, 0.72)

var station: StringName
var action: StringName
var title: Label
var detail: Label
var key: KeyCap
var prompt: Label
## The line of the tool a gathering spot asks for ("Pede: Picareta"; null: none).
var need: Label
var plate: PanelContainer
## The hero's feet in the world (the sign never covers him); Vector3.INF: nobody to keep clear of.
var hero_at := Vector3.INF
## The plate hangs under its anchor (place_under) instead of standing on it (place).
var under := false
var hovered := false
var _layer: CanvasLayer
var _shown := 0.0


## A station's sign: its name, a short line (empty: none) and the action's key with "Interagir".
static func make(id: StringName, name_text: String, detail_text: String, p_action: StringName = &"interact") -> StationSign:
	var s := StationSign.new()
	s.name = "StationSign"
	s.station = id
	s.action = p_action
	s._layer = CanvasLayer.new()
	s._layer.layer = DoorSign.LAYER
	s.add_child(s._layer)
	s.plate = PanelContainer.new()
	s.plate.name = "plate"
	s.plate.visible = false
	s.plate.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	s.plate.add_theme_stylebox_override(&"panel", _veil())
	s._layer.add_child(s.plate)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override(&"separation", DoorSign.line_gap(DoorSign.DETAIL_SIZE))
	s.plate.add_child(v)
	s.title = DoorSign._label(name_text, DoorSign.TITLE_COLOR, DoorSign.FONT_SIZE)
	s.title.name = "title"
	s.title.visible = name_text != ""  # a prompt only (Rooms.prompt: the key and the verb over the hero)
	v.add_child(s.title)
	if detail_text != "":
		s.detail = DoorSign._label(detail_text, DoorSign.DETAIL_COLOR, DoorSign.DETAIL_SIZE)
		s.detail.name = "detail"
		v.add_child(s.detail)
	var row := HBoxContainer.new()
	row.name = "use"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 7)
	s.key = KeyCap.new()
	s.key.name = "key"
	row.add_child(s.key)
	s.prompt = DoorSign._label(verb(id), DoorSign.HINT_COLOR, DoorSign.NOTE_SIZE)
	s.prompt.name = "prompt"
	row.add_child(s.prompt)
	v.add_child(row)
	# Ofícios (10_ux.md 10.1): the vein's plate says the tool it asks for, under the key (Rooms.prompt: vein_note
	# without the pick, in the rose of what is missing; vein with it, quiet)
	var need := tool_line(id)
	if need != "":
		s.need = DoorSign._label(need, DoorSign.SHORT_COLOR if id == &"vein_note" else DoorSign.DETAIL_COLOR,
			DoorSign.NOTE_SIZE)
		s.need.name = "need"
		v.add_child(s.need)
	s.refresh()
	s.plate.gui_input.connect(s._on_input)
	s.plate.mouse_entered.connect(s._hover.bind(true))
	s.plate.mouse_exited.connect(s._hover.bind(false))
	return s


## The word beside the key: the station's own verb (hub_use_<id>: "Descer", "Ler", "Ver os Dons"...; UI review
## d2ff05d, P1-9), "Interagir" for a station without one.
static func verb(id: StringName) -> String:
	var key := "hub_use_%s" % id
	return T.t(key) if T.table.entries.has(key) else T.t(&"hub_use")


## The tool line of a use (the vein's: "Pede: Picareta" without the pick, "Com a Picareta" with it), "" for others.
static func tool_line(id: StringName) -> String:
	match id:
		&"vein_note":
			return T.t(&"oficio_needs", {"name": T.t(&"oficio_pick")})
		&"vein":
			return T.t(&"oficio_uses", {"name": T.t(&"oficio_pick")})
	return ""


## The verb greyed out (a spot that does nothing now: the vein already noted, still without the pick).
func dim_verb(on: bool = true) -> void:
	prompt.add_theme_color_override(&"font_color", Color(DoorSign.HINT_COLOR, 0.45) if on else DoorSign.HINT_COLOR)
	key.modulate.a = 0.5 if on else 1.0


func _ready() -> void:
	Controls.device_changed.connect(func(_pad: bool) -> void: refresh())


## Reads the action's key again (the device in use, a remapping).
func refresh() -> void:
	key.set_key(UiKit.action_label(action), Controls.using_pad)


## The text shown by the key plate now.
func key_text() -> String:
	return key.text


func _on_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		plate.accept_event()
		pressed.emit()


func _hover(on: bool) -> void:
	hovered = on
	key.line = UiKit.GOLD if on else UiKit.OLD_GOLD
	key.queue_redraw()
	title.add_theme_color_override(&"font_color", DoorSign.TITLE_COLOR.lightened(0.25) if on else DoorSign.TITLE_COLOR)


static func _veil() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = VEIL
	sb.set_corner_radius_all(DoorSign.VEIL_CUT)
	sb.corner_detail = 1
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 3
	sb.content_margin_bottom = 6
	return sb


## Where the plate goes on the screen (its top left): bottom centre on the anchor, inside the screen, above the hero.
## When the anchor stands too high for the sign to fit above it below TOP_BAND (the station at the top of the screen,
## like the Portal seen from its foot), or the hero leaves no room above him, it goes under his feet instead: pushed down to
## the edge it would lie over the station itself.
static func place(anchor: Vector2, s: Vector2, screen: Vector2, head: Vector2 = Vector2.INF,
		feet: Vector2 = Vector2.INF) -> Vector2:
	var at := anchor - Vector2(s.x * 0.5, s.y)
	var too_high := at.y < maxf(EDGE, screen.y * TOP_BAND)
	at = _inside(at, s, screen)
	if head == Vector2.INF:
		return at.round()
	var half := absf(feet.y - head.y) * HERO_HALF
	var hero := Rect2(head.x - half, head.y, half * 2.0, absf(feet.y - head.y)).grow(HERO_GAP)
	if not too_high and not Rect2(at, s).intersects(hero):
		return at.round()
	if not too_high and hero.position.y - s.y >= EDGE:
		at.y = hero.position.y - s.y
		return at.round()
	return _inside(Vector2(feet.x - s.x * 0.5, hero.end.y), s, screen).round()


## Where the plate goes when it hangs under its anchor (under): its top centre UNDER_GAP under the anchor, inside the
## screen; when that would touch the hero's box (his height from the feet up, HERO_GAP round it), under his feet.
static func place_under(anchor: Vector2, s: Vector2, screen: Vector2, head: Vector2 = Vector2.INF,
		feet: Vector2 = Vector2.INF) -> Vector2:
	var at := _inside(anchor + Vector2(-s.x * 0.5, UNDER_GAP), s, screen)
	if head == Vector2.INF:
		return at.round()
	var box := hero_box(head, feet)
	if Rect2(at, s).intersects(box):
		at = _inside(Vector2(at.x, ceilf(box.end.y)), s, screen)  # ceil: rounding never brings it back onto him
		if Rect2(at, s).intersects(box):
			# the bottom of the screen: over his head instead
			at.y = box.position.y - s.y
	return at.round()


## The hero's box on the screen, HERO_GAP round it: his height from the feet up, HERO_HALF of it to each side.
static func hero_box(head: Vector2, feet: Vector2) -> Rect2:
	var half := absf(feet.y - head.y) * HERO_HALF
	return Rect2(head.x - half, head.y, half * 2.0, absf(feet.y - head.y)).grow(HERO_GAP)


static func _inside(at: Vector2, s: Vector2, screen: Vector2) -> Vector2:
	return Vector2(clampf(at.x, EDGE, maxf(EDGE, screen.x - EDGE - s.x)),
			clampf(at.y, EDGE, maxf(EDGE, screen.y - EDGE - s.y)))


## Follows its anchor; hidden behind the camera or with the sign hidden.
func _process(delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	var at := global_position
	if cam == null or cam.is_position_behind(at) or not is_visible_in_tree():
		plate.visible = false
		return
	_shown = minf(_shown + delta / APPEAR, 1.0)
	var s := plate.get_combined_minimum_size()
	plate.size = s
	var head := Vector2.INF
	var feet := Vector2.INF
	if hero_at != Vector3.INF:
		head = cam.unproject_position(hero_at + Vector3(0, HERO_HEIGHT, 0))
		feet = cam.unproject_position(hero_at)
	var screen := get_viewport().get_visible_rect().size
	var p := place_under(cam.unproject_position(at), s, screen, head, feet) if under \
		else place(cam.unproject_position(at), s, screen, head, feet)
	plate.position = p + Vector2(0, RISE * (1.0 - _shown) * (-1.0 if under else 1.0))
	plate.modulate.a = _shown
	plate.visible = true


## The key or button on the HUD's key plate (ActionSlot.key_plate), round for a gamepad's face button.
class KeyCap:
	extends Control

	var text := ""
	var rounded := false
	var line := UiKit.OLD_GOLD
	## The key's font size and the plate's height (ActionBar uses its own).
	var font_size := StationSign.KEY_SIZE
	var height := StationSign.KEY_H

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size_flags_vertical = Control.SIZE_SHRINK_CENTER

	func set_key(p_text: String, pad: bool) -> void:
		text = p_text
		rounded = pad and p_text.length() <= 2
		var tw := UiKit.BOLD_FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		custom_minimum_size = Vector2(maxf(height, tw + 8.0), height)
		queue_redraw()

	func _draw() -> void:
		ActionSlot.key_plate(self, size * 0.5, text, font_size, height, rounded, line)
