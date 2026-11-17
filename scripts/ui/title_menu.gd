class_name TitleMenu
extends Control
## The five buttons of the title screen (Iniciar over the painted one; O Guerreiro, Como Jogar, Configurações and Sair
## in the column under it, TitleButton.FRAMES).
## Follows the origin and the scale of the art (TitleBackdrop), never the screen's anchors.

signal start_pressed
signal hero_pressed
signal howto_pressed
signal settings_pressed
signal quit_pressed

const ART_SIZE := Vector2(1672, 941)
const INTRO_DELAY := 0.6
const INTRO_TIME := 0.35
const INTRO_STAGGER := 0.06
const NAV_ACTIONS: Array[StringName] = [
	&"ui_up", &"ui_down", &"ui_left", &"ui_right", &"ui_focus_next", &"ui_focus_prev"]

var buttons: Array[TitleButton] = []
var _backdrop: Control
var _ring := false
var _quiet := false
var _intro: Tween


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# the menu itself never takes the mouse: only the buttons do, inside their hexagons
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var signals: Array[Signal] = [start_pressed, hero_pressed, howto_pressed, settings_pressed, quit_pressed]
	for kind: TitleButton.Kind in TitleButton.Kind.values():
		var b := TitleButton.new(kind)
		var out := signals[kind]
		b.pressed.connect(func() -> void:
			Audio.play(&"ui_ok")
			out.emit())
		b.focus_entered.connect(func() -> void:
			if not _quiet:
				Audio.play(&"ui_move"))
		b.mouse_entered.connect(_set_ring.bind(false))
		buttons.append(b)
		add_child(b)
	_wire()


func _ready() -> void:
	resized.connect(_layout)
	_layout()


## `backdrop` is the TitleBackdrop (duck-typed): art_rect(), art_scale() and the signal layout_changed.
func setup(backdrop: Control) -> void:
	_backdrop = backdrop
	if backdrop and backdrop.has_signal(&"layout_changed") and not backdrop.is_connected(&"layout_changed", _layout):
		backdrop.connect(&"layout_changed", _layout)
	_layout()


## Entrance: each button rises 6 units in 0.35 s, from 0.6 s on, one after the other.
func intro() -> void:
	finish_intro()
	_intro = create_tween().set_parallel()
	var i := 0
	for b in buttons:
		b.appear = 0.0
		if b.visible:
			_intro.tween_property(b, ^"appear", 1.0, INTRO_TIME).set_delay(INTRO_DELAY + INTRO_STAGGER * i) \
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			i += 1


## Ends the entrance at once (any key before the buttons are in).
func finish_intro() -> void:
	if _intro and _intro.is_valid():
		_intro.kill()
	_intro = null
	for b in buttons:
		b.appear = 1.0


## Focus on Iniciar, silent and without the ring (the still screen looks like the painting).
func focus_first() -> void:
	_quiet = true
	for b in buttons:
		if b.visible and not b.disabled:
			b.grab_focus()
			break
	_quiet = false


## Sair does not exist in the browser or on a phone; the other three keep their places.
func set_quit_visible(v: bool) -> void:
	var quit := buttons[TitleButton.Kind.QUIT]
	if quit.has_focus() and not v:
		buttons[TitleButton.Kind.SETTINGS].grab_focus()
	quit.visible = v
	_wire()


## Locks the buttons during a transition; they keep their look. `greyed` shows the disabled state instead.
func set_enabled(v: bool, greyed: bool = false) -> void:
	for b in buttons:
		b.disabled = not v
		b.greyed = greyed and not v
		b.mouse_filter = Control.MOUSE_FILTER_STOP if v else Control.MOUSE_FILTER_IGNORE
		b.queue_redraw()


func button(kind: TitleButton.Kind) -> TitleButton:
	return buttons[kind]


## Where the art's corner sits in this control, and its scale (from the backdrop, or the same contain rule alone).
func art_origin() -> Vector2:
	if _has_backdrop():
		var rect: Rect2 = _backdrop.call(&"art_rect")
		return get_global_transform().affine_inverse() * (_backdrop.get_global_transform() * rect.position)
	return ((size - ART_SIZE * art_scale()) * 0.5).floor()


func art_scale() -> float:
	if _has_backdrop():
		return _backdrop.call(&"art_scale")
	return minf(size.x / ART_SIZE.x, size.y / ART_SIZE.y)


func _has_backdrop() -> bool:
	return is_instance_valid(_backdrop) and _backdrop.has_method(&"art_rect") and _backdrop.has_method(&"art_scale")


func _layout() -> void:
	var origin := art_origin()
	var s := art_scale()
	for b in buttons:
		b.place(origin, s)


## Up and down walk the visible buttons without wrapping; left and right stay put.
func _wire() -> void:
	var shown: Array[TitleButton] = []
	for b in buttons:
		if b.visible:
			shown.append(b)
	for i in shown.size():
		var b := shown[i]
		var me := b.get_path_to(b)
		var up := b.get_path_to(shown[maxi(i - 1, 0)])
		var down := b.get_path_to(shown[mini(i + 1, shown.size() - 1)])
		b.focus_neighbor_top = up
		b.focus_previous = up
		b.focus_neighbor_bottom = down
		b.focus_next = down
		b.focus_neighbor_left = me
		b.focus_neighbor_right = me


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or not (event is InputEventKey or event is InputEventJoypadButton \
			or event is InputEventJoypadMotion):
		return
	for action in NAV_ACTIONS:
		if event.is_action_pressed(action):
			_navigated()
			return


## First navigation by keys or gamepad: the ring shows from now on (and a lost focus comes back to the menu).
func _navigated() -> void:
	_set_ring(true)
	if buttons.any(func(b: TitleButton) -> bool: return b.has_focus()):
		return
	var owner_ := get_viewport().gui_get_focus_owner()
	if owner_ == null and not buttons[0].disabled:
		focus_first()
		get_viewport().set_input_as_handled()


func _set_ring(v: bool) -> void:
	if _ring == v:
		return
	_ring = v
	for b in buttons:
		b.show_ring = v
