extends Node2D
## Title screen: the catacombs behind, the name of the game, the premise and the menu.
## Test switches that ask for a run (--bot, --shot, --smoke, --start, --stress) skip straight to it.

const GAME := "res://scenes/game.tscn"

var _menu: Control
var _sub: Control
var _first: Button


func _ready() -> void:
	App.apply_options()
	for key: String in ["bot", "smoke", "start", "stress", "play"]:
		if Dev.has(key):
			get_tree().change_scene_to_file.call_deferred(GAME)
			return
	if Dev.has("shot") and not Dev.has("title"):
		get_tree().change_scene_to_file.call_deferred(GAME)
		return
	_build_scene()
	_build_menu()
	Audio.music(&"title")
	if Dev.arg("screen") == "options":
		_show(OptionsScreen.new())
	elif Dev.arg("screen") == "moves":
		_show(MovesScreen.new())
	if Dev.has("shot"):
		_shot.call_deferred()


## The hall in front of the crypt door, with the paladin waiting under the broken window.
func _build_scene() -> void:
	var world := Node2D.new()
	world.y_sort_enabled = true
	var arena := Arena.new()
	add_child(arena)
	add_child(world)
	arena.build(world)
	var paladin := Art.animated(&"paladin")
	paladin.position = arena.door_pos + Vector2(-112, 58)
	paladin.play(&"idle")
	world.add_child(paladin)
	var light := Arena.make_light(Color(1.0, 0.93, 0.75), 80.0, 0.5)
	light.position = Vector2(0, -8)
	paladin.add_child(light)
	var cam := Camera2D.new()
	cam.position = arena.door_pos + Vector2(-40, 50)
	add_child(cam)
	cam.make_current()


func _build_menu() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_menu = Control.new()
	_menu.theme = UiKit.theme()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_menu)
	var shade := ColorRect.new()
	shade.color = Color(Color.html("#060408"), 0.5)
	shade.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	shade.offset_left = -150
	_menu.add_child(shade)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	box.offset_left = -142
	box.offset_right = -8
	box.offset_top = 10
	box.offset_bottom = -8
	_menu.add_child(box)
	box.add_child(UiKit.label(T.t(&"title"), Palette.c(&"neve", 1)))
	box.add_child(UiKit.label(T.t(&"subtitle"), Palette.c(&"luz", 0), UiKit.BIG))
	var premise := UiKit.label(T.t(&"premise"), Palette.c(&"neve", 0))
	premise.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	premise.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	premise.offset_left = 8
	premise.offset_top = -66
	premise.offset_right = 164
	premise.offset_bottom = -6
	premise.custom_minimum_size = Vector2(156, 50)
	_menu.add_child(premise)
	var gap := Control.new()
	gap.custom_minimum_size.y = 22
	box.add_child(gap)
	_first = UiKit.button(T.t(&"menu_play"), func() -> void: get_tree().change_scene_to_file(GAME))
	box.add_child(_first)
	box.add_child(UiKit.button(T.t(&"pause_moves"), func() -> void: _show(MovesScreen.new())))
	box.add_child(UiKit.button(T.t(&"pause_options"), func() -> void: _show(OptionsScreen.new())))
	if not OS.has_feature("web") and not OS.has_feature("mobile"):
		box.add_child(UiKit.button(T.t(&"menu_quit"), func() -> void: get_tree().quit()))
	var best: Array = Save.data.best_times
	if not best.is_empty():
		box.add_child(UiKit.label("%s: %s" % [T.t(&"end_best"), SaveData.format_time(best[0])], Palette.c(&"luz", 1)))
	_first.grab_focus.call_deferred()


func _show(screen: Control) -> void:
	_menu.visible = false
	_sub = screen
	_sub.add_child(UiKit.veil(0.6))
	_menu.get_parent().add_child(screen)
	screen.call(&"open")
	screen.connect(&"closed", _close_sub)


func _close_sub() -> void:
	if _sub:
		_sub.queue_free()
		_sub = null
	_menu.visible = true
	_first.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _sub and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_sub()


func _shot() -> void:
	await get_tree().create_timer(Dev.num("shot-at", 1.0)).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.resize(img.get_width() * 4, img.get_height() * 4, Image.INTERPOLATE_NEAREST)
	img.save_png(Dev.arg("shot"))
	get_tree().quit()
