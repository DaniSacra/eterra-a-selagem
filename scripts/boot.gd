extends Node3D
## Title screen: the hall of the catacombs behind, the paladin waiting before the crypt, the name and the menu.
## Test switches that ask for a run (--bot, --shot, --smoke, --start, --stress) skip straight to it.

const GAME := "res://scenes/game.tscn"

var _menu: Control
var _sub: Control
var _first: Button
var _cam: Camera3D
var _t := 0.0


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
	if Dev.arg("screen") == "options":
		_show(OptionsScreen.new())
	elif Dev.arg("screen") == "moves":
		_show(MovesScreen.new())
	if Dev.has("shot"):
		_shot.call_deferred()


func _build_scene() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.02, 0.015, 0.03)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.3, 0.32, 0.5)
	e.ambient_light_energy = 0.45
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.9
	e.glow_hdr_threshold = 0.85
	e.fog_enabled = true
	e.fog_light_color = Color(0.05, 0.04, 0.09)
	e.fog_density = 0.02
	env.environment = e
	add_child(env)
	var arena := Arena.new()
	add_child(arena)
	arena.build()
	arena.open_door()
	var knight: Node3D = (load(Player.MODEL) as PackedScene).instantiate()
	knight.position = Vector3(-7.0, 0, -22.0)
	knight.rotation.y = 0.75
	add_child(knight)
	for part in Player.HIDDEN_PARTS:
		var n := knight.find_child(part, true, false)
		if n:
			(n as Node3D).visible = false
	var anim := PoseBaker.find_player(knight)
	PoseBaker.find_skeleton(knight).add_child(Slender.new())
	anim.get_animation(&"Idle").loop_mode = Animation.LOOP_LINEAR
	anim.play(&"Idle")
	var light := OmniLight3D.new()
	light.position = knight.position + Vector3(0.5, 3.0, 1.5)
	light.light_color = Color(1.0, 0.78, 0.5)
	light.light_energy = 2.4
	light.omni_range = 11.0
	add_child(light)
	_cam = Camera3D.new()
	_cam.fov = 45.0
	add_child(_cam)
	_cam.make_current()
	_place_camera()


func _place_camera() -> void:
	var target := Vector3(-9.6 + sin(_t * 0.15) * 0.4, 1.3, -22.6)
	_cam.look_at_from_position(target + Vector3(5.5 + sin(_t * 0.2) * 0.6, 3.0, 8.0), target, Vector3.UP)


func _process(delta: float) -> void:
	_t += delta
	if _cam:
		_place_camera()


func _build_menu() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_menu = Control.new()
	_menu.theme = UiKit.theme()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_menu)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.01, 0.025, 0.55)
	shade.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	shade.offset_right = 520
	_menu.add_child(shade)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	box.offset_left = 60
	box.offset_right = 480
	box.offset_top = 70
	box.add_theme_constant_override(&"separation", 12)
	_menu.add_child(box)
	var name_l := UiKit.label(T.t(&"title"), UiKit.PALE, 30, UiKit.TITLE_FONT)
	box.add_child(name_l)
	var sub := UiKit.label(T.t(&"subtitle"), UiKit.GOLD, 66, UiKit.TITLE_FONT)
	sub.add_theme_constant_override(&"outline_size", 10)
	box.add_child(sub)
	var premise := UiKit.label(T.t(&"premise"), UiKit.PALE, 21)
	premise.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	premise.custom_minimum_size.x = 420
	box.add_child(premise)
	var gap := Control.new()
	gap.custom_minimum_size.y = 18
	box.add_child(gap)
	_first = UiKit.button(T.t(&"menu_play"), func() -> void: get_tree().change_scene_to_file(GAME), 360)
	box.add_child(_first)
	box.add_child(UiKit.button(T.t(&"menu_moves"), func() -> void: _show(MovesScreen.new()), 360))
	box.add_child(UiKit.button(T.t(&"menu_options"), func() -> void: _show(OptionsScreen.new()), 360))
	if not OS.has_feature("web") and not OS.has_feature("mobile"):
		box.add_child(UiKit.button(T.t(&"menu_quit"), func() -> void: get_tree().quit(), 360))
	var best: Array = Save.data.best_times
	if not best.is_empty():
		box.add_child(UiKit.label("%s: %s" % [T.t(&"end_best"), SaveData.format_time(best[0])], UiKit.GOLD, 22))
	var help := UiKit.label(T.t(&"title_controls") + "\n" + T.t(&"title_pad"), UiKit.DIM, 18)
	help.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	help.offset_top = -64
	help.offset_bottom = -14
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_menu.add_child(help)
	_first.grab_focus.call_deferred()


func _show(screen: Control) -> void:
	_menu.visible = false
	_sub = screen
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
	get_viewport().get_texture().get_image().save_png(Dev.arg("shot"))
	get_tree().quit()
