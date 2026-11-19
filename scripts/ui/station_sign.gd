class_name StationSign
extends Node3D
## The sign of the hub's station in focus (HUB-B3; docs/design/hub_spec_art.md 2.4): one at a time, only while a
## station is in focus, in the DoorSign's language (the station's name in warm gold, Alegreya Sans Bold with the dark
## outline, CAP_PX 19 at 1080 lines; a short line in pale; the veil of dark ink with cut corners) and, under them, the
## real key of the action on the HUD's key plate (round for a gamepad's face button) and "Interagir". The key follows
## the device live (Controls.device_changed: E on the keyboard, A on the gamepad, whatever was remapped) and refresh()
## reads the binding again (after the Configurações). Drawn as interface text over its anchor (a CanvasLayer above
## the world, like the DoorSign): the text's bottom centre on the anchor, always inside the screen and never over the
## hero (hero_at: it rises above his head when the anchor would put it on him). It comes up in APPEAR seconds.
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
var plate: PanelContainer
## The hero's feet in the world (the sign never covers him); Vector3.INF: nobody to keep clear of.
var hero_at := Vector3.INF
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
	s.prompt = DoorSign._label(T.t(&"hub_use"), DoorSign.HINT_COLOR, DoorSign.NOTE_SIZE)
	s.prompt.name = "prompt"
	row.add_child(s.prompt)
	v.add_child(row)
	s.refresh()
	s.plate.gui_input.connect(s._on_input)
	s.plate.mouse_entered.connect(s._hover.bind(true))
	s.plate.mouse_exited.connect(s._hover.bind(false))
	return s


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
static func place(anchor: Vector2, s: Vector2, screen: Vector2, head: Vector2 = Vector2.INF,
		feet: Vector2 = Vector2.INF) -> Vector2:
	var at := anchor - Vector2(s.x * 0.5, s.y)
	at.x = clampf(at.x, EDGE, maxf(EDGE, screen.x - EDGE - s.x))
	at.y = clampf(at.y, EDGE, maxf(EDGE, screen.y - EDGE - s.y))
	if head != Vector2.INF:
		var half := absf(feet.y - head.y) * HERO_HALF
		var hero := Rect2(head.x - half, head.y, half * 2.0, absf(feet.y - head.y)).grow(HERO_GAP)
		if Rect2(at, s).intersects(hero):
			at.y = maxf(EDGE, hero.position.y - s.y)
	return at.round()


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
	var p := place(cam.unproject_position(at), s, get_viewport().get_visible_rect().size, head, feet)
	plate.position = p + Vector2(0, RISE * (1.0 - _shown))
	plate.modulate.a = _shown
	plate.visible = true


## The key or button on the HUD's key plate (ActionSlot.key_plate), round for a gamepad's face button.
class KeyCap:
	extends Control

	var text := ""
	var rounded := false
	var line := UiKit.OLD_GOLD

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size_flags_vertical = Control.SIZE_SHRINK_CENTER

	func set_key(p_text: String, pad: bool) -> void:
		text = p_text
		rounded = pad and p_text.length() <= 2
		var tw := UiKit.BOLD_FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, StationSign.KEY_SIZE).x
		custom_minimum_size = Vector2(maxf(StationSign.KEY_H, tw + 8.0), StationSign.KEY_H)
		queue_redraw()

	func _draw() -> void:
		ActionSlot.key_plate(self, size * 0.5, text, StationSign.KEY_SIZE, StationSign.KEY_H, rounded, line)
