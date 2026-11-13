class_name Ending
extends Node2D
## The sealing: the king's tomb closes, the four swords rise over it, and the epitaph the RPG player already knows.

const CORNERS: Array[Vector2] = [Vector2(-34, -14), Vector2(34, -14), Vector2(-34, 16), Vector2(34, 16)]
const LINES: Array[StringName] = [&"ending_1", &"ending_2", &"ending_3"]

var _skip := false
var _armed := false


func _unhandled_input(event: InputEvent) -> void:
	if _armed and (event.is_action_pressed(&"light_attack") or event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"pause")):
		_skip = true


func play(game: Game) -> void:
	var at := game.arena.resolve(game.boss_fell_at, 30.0)
	game.hud.visible = false
	game.focus = at + Vector2(0, 18)
	Audio.music(&"seal")
	await _wait(0.8)
	var tomb := Art.sprite(&"seal_tomb")
	tomb.position = at
	game.world.add_child(tomb)
	game.arena.add_obstacle(at + Vector2(0, -8), 16.0)
	game.fx.ring(at, 40.0, &"luz", 0.5)
	game.fx.burst(&"light", at + Vector2(0, -12))
	game.fx.shake(3.0)
	Audio.play(&"seal")
	var glow := Arena.make_light(Color(1.0, 0.93, 0.7), 120.0, 0.0)
	glow.position = at + Vector2(0, -10)
	game.add_child(glow)
	_armed = true
	# the paladin walks to the foot of the tomb
	game.player.position = game.arena.resolve(at + Vector2(0, 34), Player.RADIUS)
	var text := _text_box(game)
	for i in CORNERS.size():
		await _wait(0.7)
		var sword := Art.animated(&"seal_sword")
		sword.position = at + CORNERS[i]
		sword.play(&"shine")
		game.world.add_child(sword)
		game.fx.burst(&"light", sword.position + Vector2(0, -14))
		game.fx.streak(sword.position + Vector2(0, 4), Vector2.UP, 40.0, 6.0, &"luz", 0.35)
		glow.energy = 0.2 * (i + 1)
		Audio.play(&"sword_rise", 1.0 + 0.12 * i)
	for key in LINES:
		text.text = T.t(key)
		text.visible_ratio = 0.0
		var shown := 0.0
		var length := maxf(text.text.length() / 30.0, 1.0)
		while shown < length + 2.4 and not _skip:
			shown += get_process_delta_time()
			text.visible_ratio = minf(shown / length, 1.0)
			await get_tree().process_frame
		if _skip:
			break
	text.get_parent().queue_free()


func _wait(seconds: float) -> void:
	var t := 0.0
	while t < seconds and not _skip:
		t += get_process_delta_time()
		await get_tree().process_frame


func _text_box(game: Game) -> Label:
	var panel := PanelContainer.new()
	panel.theme = UiKit.theme()
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 30
	panel.offset_right = -30
	panel.offset_top = -52
	panel.offset_bottom = -8
	game.ui.add_child(panel)
	var l := UiKit.label("", Palette.c(&"luz", 0))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(240, 34)
	panel.add_child(l)
	return l
