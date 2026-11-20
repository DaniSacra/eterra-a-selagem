extends SceneTree
## Captures of the menus around the run for UI review (stage 1B of the art pack): the pause over the frozen fight (with
## few and with many Blessings), Suas Bênçãos (top and scrolled), the defeat and the victory (the sealing, then the
## summary); and, on the title, Como Jogar, Configurações (each tab) and Músicas.
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/menu_lab.gd -- --nosave --lab-out=C:/x/m --bot --hold --seed=5
## tools/gpu.sh run ... -s tools/menu_lab.gd -- --nosave --lab-out=C:/x/m --title-screens
## Writes <lab-out>_<name>.png. Calls the screens' own methods; nothing here ships.

const GAME := "res://scenes/game.tscn"
const BOOT := "res://scenes/boot.tscn"
## A run with a full hand: one Blessing on each action, ten that act alone and six Elos.
const MANY: Array[StringName] = [&"golpe_brasa", &"toque_geada", &"circulo_radiante", &"passos", &"brasas", &"redemoinho",
	&"lamina_ardente", &"estilhaco", &"peso_inverno", &"consolo", &"onda_maior", &"flagelo", &"escudo", &"firmeza",
	&"vapor", &"aurora", &"chama_viva", &"bastiao", &"rastro", &"passo_frio"]
const FEW: Array[StringName] = [&"golpe_brasa", &"brasas", &"escudo"]

var _out := ""


func _initialize() -> void:
	create_timer(90.0).timeout.connect(quit)
	_run.call_deferred()


func _run() -> void:
	_out = Dev.arg("lab-out", "menu")
	if Dev.has("title-screens"):
		await _title()
	else:
		await _game()
	quit()


func _game() -> void:
	var game: Node = (load(GAME) as PackedScene).instantiate()
	root.add_child(game)
	await create_timer(7.0).timeout
	var boons: Variant = game.get(&"boons")
	for id in FEW:
		game.call(&"_take", boons.call(&"find", id))
	await create_timer(0.3).timeout
	game.call(&"_open_pause")
	await create_timer(0.4).timeout
	await _shot("pause")
	game.call(&"_close_screen")
	game.call(&"_back_to_play")
	for id in MANY:
		game.call(&"_take", boons.call(&"find", id))
	game.call(&"_open_pause")
	var pause: Node = game.get(&"_screen")
	await create_timer(0.4).timeout
	await _shot("pause_many")
	pause.call(&"_show", pause.call(&"_boons_screen"))
	await create_timer(0.4).timeout
	await _shot("boons")
	await _focus_last(pause)
	await _shot("boons_end")
	game.call(&"_close_screen")
	game.call(&"_back_to_play")
	await process_frame
	var gain: Dictionary = load("res://scripts/core/hero_def.gd").call(&"warrior").get(&"mastery").call(&"run_xp",
		{"rooms": 5, "guardians": 1, "new_boons": 2})
	var ui: Node = game.get(&"ui")
	var stats := {"time": 412.0, "level": 0, "kills": 63, "best_combo": 17, "boons": 20, "defeated_by": &"enemy_skeleton",
		"mastery": {"gain": gain, "xp_before": 120}, "materials": {"silver": 4, "memory": 0}}
	var end: Node = (load("res://scripts/ui/end_screen.gd") as GDScript).new()
	ui.add_child(end)
	end.call(&"open", false, stats, false)
	await create_timer(2.2).timeout
	await _shot("defeat")
	end.queue_free()
	await process_frame
	var won := stats.duplicate()
	won.erase("defeated_by")
	won.materials = {"silver": 24, "memory": 7, "emerald": 2}
	won.tools = ["tool_refine"]
	won.mastery = {"gain": load("res://scripts/core/hero_def.gd").call(&"warrior").get(&"mastery").call(&"run_xp",
		{"rooms": 10, "guardians": 1, "phase": 4, "victory": true}), "xp_before": 120}
	end = (load("res://scripts/ui/end_screen.gd") as GDScript).new()
	ui.add_child(end)
	end.call(&"open", true, won, false)
	await create_timer(0.7).timeout
	await _shot("victory_closing")
	await create_timer(0.9).timeout
	await _shot("victory_seal")
	await create_timer(2.9).timeout
	await _shot("victory")


## The last focusable row of the open sub-screen takes the focus, so its list scrolls to the end.
func _focus_last(holder: Node) -> void:
	var last: Control
	for c: Node in holder.find_children("*", "Control", true, false):
		var ctl := c as Control
		if ctl.focus_mode == Control.FOCUS_ALL and ctl.is_visible_in_tree() and not ctl is Button:
			last = ctl
	if last:
		last.grab_focus()
	await create_timer(0.4).timeout


func _title() -> void:
	# the title applies the saved window size (App.apply_options): keep the size this lab was started with
	var want := root.size
	var boot: Node = (load(BOOT) as PackedScene).instantiate()
	root.add_child(boot)
	await process_frame
	root.size = want
	await create_timer(1.6).timeout
	var howto: Control = (load("res://scripts/ui/how_to_screen.gd") as GDScript).new()
	boot.call(&"_open", howto, 2)
	await create_timer(0.5).timeout
	await _shot("howto")
	howto.call(&"_show_tab", 1)
	await create_timer(0.3).timeout
	await _shot("howto_controls")
	boot.call(&"_close_sub")
	await create_timer(0.3).timeout
	var options: Control = (load("res://scripts/ui/options_screen.gd") as GDScript).new()
	boot.call(&"_open", options, 3)
	await create_timer(0.5).timeout
	await _shot("options")
	var tabs: Array = options.find_children("tab_*", "Button", true, false)
	for t: Node in tabs:
		(t as Button).grab_focus()
		await create_timer(0.3).timeout
		await _shot("options_" + String(t.name))
	options.call(&"_open_music")
	await create_timer(0.5).timeout
	await _shot("music")


func _press(action: StringName) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	Input.parse_input_event(e)
	var r := InputEventAction.new()
	r.action = action
	r.pressed = false
	Input.parse_input_event(r)


func _shot(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "%s_%s.png" % [_out, tag]
	root.get_texture().get_image().save_png(path)
	print("LAB saved ", path)
