class_name ScreenHost
extends Node
## The host of the screens opened over the title and the hub (HUB-01, HUB-B1): it adds a screen to its layer, calls
## its open(...) with the arguments given, closes it on the screen's own signal (closed, or another the caller names)
## or on Esc and B (ui_cancel, which a screen's own pages see first: a page inside it closes before it does), and,
## when it closes, forgets every press so far (Controls.clear_presses): the Enter, click or button that closed it never
## reaches what is under it (a swing, the hub's interact). It was the title's _open and _close_sub (boot.gd).
##   host.open(OptionsScreen.new())                     # its signal closed closes it
##   host.open(pause, [], &"resumed")
##   host.closed.connect(func(_s: Control) -> void: menu.visible = true)

## A screen was put on show, and the one on show closed (it is being freed).
signal opened(screen: Control)
signal closed(screen: Control)

## The screen on show (null: none).
var screen: Control
## Where screens are added (a Control or a CanvasLayer of the caller's).
var layer: Node


func _init(parent_of_screens: Node = null) -> void:
	layer = parent_of_screens
	name = "ScreenHost"


## Shows a screen (false, and nothing done, while another is on show): adds it, calls open with args, and closes it
## on close_signal.
func open(s: Control, args: Array = [], close_signal: StringName = &"closed") -> bool:
	if is_open():
		s.queue_free()
		return false
	screen = s
	(layer if layer != null else self).add_child(s)
	s.callv(&"open", args)
	if s.has_signal(close_signal):
		s.connect(close_signal, close, CONNECT_ONE_SHOT)
	opened.emit(s)
	return true


func is_open() -> bool:
	return screen != null and is_instance_valid(screen)


## Closes the screen on show (nothing when none).
func close() -> void:
	if not is_open():
		screen = null
		return
	var s := screen
	screen = null
	s.queue_free()
	Controls.clear_presses()
	closed.emit(s)


func _unhandled_input(event: InputEvent) -> void:
	if is_open() and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
