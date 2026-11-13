class_name PauseMenu
extends Control
## Pause: continue, the list of moves found so far, options, back to the title.

signal resumed

var _game: Game
var _main: Control
var _sub: Control


func open(game: Game) -> void:
	_game = game
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(UiKit.veil())
	_main = Control.new()
	_main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_main)
	var v := UiKit.column(_main, 110.0)
	var title := UiKit.label(T.t(&"pause_title"), Palette.c(&"luz", 0), UiKit.BIG)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var first := UiKit.button(T.t(&"pause_continue"), func() -> void: resumed.emit())
	v.add_child(first)
	v.add_child(UiKit.button(T.t(&"pause_moves"), func() -> void: _show(MovesScreen.new())))
	v.add_child(UiKit.button(T.t(&"pause_options"), func() -> void: _show(OptionsScreen.new())))
	v.add_child(UiKit.button(T.t(&"pause_quit"), func() -> void: get_tree().change_scene_to_file("res://scenes/boot.tscn")))
	first.grab_focus.call_deferred()


func _show(screen: Control) -> void:
	_main.visible = false
	_sub = screen
	add_child(screen)
	screen.call(&"open")
	screen.connect(&"closed", func() -> void:
		_sub.queue_free()
		_sub = null
		_main.visible = true
		(_main.find_child("*", true, false) as Control).grab_focus()
		for b in _main.find_children("*", "Button", true, false):
			(b as Button).grab_focus()
			break)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		if _sub:
			_sub.emit_signal(&"closed")
		else:
			resumed.emit()
