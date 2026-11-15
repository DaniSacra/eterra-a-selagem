class_name PauseMenu
extends Control
## Pause: continue, the gifts held (Elos on their chain), the list of moves found so far, options, back to the title.

signal resumed

var _main: Control
var _sub: Control


func open() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_main = Control.new()
	_main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_main)
	var v := UiKit.column(_main, 340.0, 0.65)
	v.add_child(UiKit.title(T.t(&"pause_title"), 44))
	var first := UiKit.button(T.t(&"pause_continue"), func() -> void: resumed.emit())
	v.add_child(first)
	v.add_child(UiKit.button(T.t(&"pause_boons"), func() -> void: _show(_boons_screen())))
	v.add_child(UiKit.button(T.t(&"pause_moves"), func() -> void: _show(MovesScreen.new())))
	v.add_child(UiKit.button(T.t(&"pause_options"), func() -> void: _show(OptionsScreen.new())))
	v.add_child(UiKit.button(T.t(&"pause_quit"), func() -> void: get_tree().change_scene_to_file("res://scenes/boot.tscn")))
	first.grab_focus.call_deferred()


## The gifts panel, with the gifts of the run this pause belongs to (the Game above it).
func _boons_screen() -> BoonsScreen:
	var screen := BoonsScreen.new()
	var n := get_parent()
	while n != null and not n is Game:
		n = n.get_parent()
	if n != null:
		screen.state = (n as Game).boons
	return screen


func _show(screen: Control) -> void:
	_main.visible = false
	_sub = screen
	add_child(screen)
	screen.call(&"open")
	screen.connect(&"closed", func() -> void:
		_sub.queue_free()
		_sub = null
		_main.visible = true
		(_main.find_children("*", "Button", true, false)[0] as Button).grab_focus())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		if _sub:
			_sub.emit_signal(&"closed")
		else:
			resumed.emit()
