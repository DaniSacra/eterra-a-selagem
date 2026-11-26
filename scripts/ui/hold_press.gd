class_name HoldPress
extends Control
## "Segure para confirmar" on a Button (PT-25-3, the Videira): holding accept (key or pad, while the button has the
## focus) or the left mouse button on it fills a ring over the button (HoldGauge, the Dons' rule); at the end `completed`
## fires once. Letting go, or the focus leaving, cancels and the ring drains back. The button's own `pressed` never fires
## from those presses (the press is consumed), so the hold is the only way to confirm. Draws the ring, nothing else.
##   HoldPress.attach(button, 0.8).completed.connect(func() -> void: ...)

signal completed

const TIME := 0.8
const DRAIN := 0.2
const RADIUS := 17.0
const WIDTH := 5.0

var gauge: HoldGauge
var button: Button
## Optional: a press only starts a hold while this returns true; otherwise it passes through as an ordinary press.
var gate := Callable()


static func attach(b: Button, time: float = TIME, drain: float = DRAIN) -> HoldPress:
	var h := HoldPress.new()
	h.gauge = HoldGauge.new(time, drain)
	h.button = b
	h.name = "hold_ring"
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	b.add_child(h)
	b.gui_input.connect(h._on_gui_input)
	b.focus_exited.connect(h.cancel)
	return h


func progress() -> float:
	return gauge.progress


func holding() -> bool:
	return gauge.held


## Starts the hold (a press): nothing while the button cannot be pressed.
func begin() -> void:
	if button.disabled or gauge.held:
		return
	gauge.start()
	Audio.play(&"ui_move")


func cancel() -> void:
	gauge.cancel()


## True when this event is the press or release that starts or ends a hold (accept action or left mouse).
static func is_press(event: InputEvent) -> bool:
	return event.is_action(&"ui_accept") or (event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT)


## Lets another control (a clay tag beside a star) start and end this hold with its own presses.
func forward(from: Control) -> void:
	from.gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if not is_press(event) or event.is_echo():
		return
	if event.is_pressed() and gate.is_valid() and not bool(gate.call()):
		return
	button.accept_event()
	if event.is_pressed():
		begin()
	else:
		cancel()


func _process(delta: float) -> void:
	if gauge.step(delta):
		completed.emit()
	queue_redraw()


func _draw() -> void:
	var p := gauge.progress
	if p <= 0.0:
		return
	var c := size * 0.5
	draw_circle(c, RADIUS + WIDTH, Color(0.02, 0.015, 0.02, 0.85))
	draw_arc(c, RADIUS, 0.0, TAU, 40, Color(UiKit.OLD_GOLD, 0.5), 2.0)
	draw_arc(c, RADIUS, -PI * 0.5, -PI * 0.5 + TAU * p, 40, UiKit.GOLD, WIDTH)
