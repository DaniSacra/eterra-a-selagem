class_name ForgeTouch
extends Control
## A place on the Forja's bench the pointer can reach (docs/art/forge_spec.md 2): a mark on the weapon, a chip of the
## strip, the plate's hammer button, a bench's tab. It only reports: hovered (the focus goes here), down and up (the
## left button, for the hammer's tap and its hold). The keyboard and the pad go through ForgeScreen's own actions.

signal hovered
signal down
signal up


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE


func _ready() -> void:
	mouse_entered.connect(func() -> void: hovered.emit())


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if (event as InputEventMouseButton).pressed:
			down.emit()
		else:
			up.emit()
