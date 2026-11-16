extends SceneTree
## Captures of the gift screens inside a real run (the game, the bot fighting behind), for UI review:
## an Elo on the gift card, the "Elo formado" greeting, the gifts panel from the pause.
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/ui_lab.gd -- --lab-out=C:/x/elo --bot --hold --seed=5 [--stress=300]
## Writes <lab-out>_card.png, _formed.png and _panel.png. Calls the run's own methods; nothing here ships.
## Gift card only (writes <lab-out>_card.png and, with --focus-move, <lab-out>_card_focus.png after one ui_right):
##   --card-only [--offer=a,b,c] [--held=x,y] [--rarity=0,2,1] [--rest]

const GAME := "res://scenes/game.tscn"
## Gifts held before the Elo is offered: both sources of Vapor and of Aurora Gelada, and a few more for the panel.
const HELD: Array[StringName] = [&"brasas", &"toque_geada", &"onda_maior", &"escudo", &"passos", &"golpe_brasa", &"estilhaco"]
const OFFER: Array[StringName] = [&"vapor", &"aurora", &"redemoinho"]
const ELO := &"vapor"
const START := 7.0

var _out := ""


func _initialize() -> void:
	# never hold the GPU if something breaks halfway
	create_timer(60.0).timeout.connect(quit)
	_run.call_deferred()


func _run() -> void:
	# untyped on purpose: a -s script compiles before the autoloads exist, so it cannot name the game's classes
	_out = Dev.arg("lab-out", "elo")
	var game: Node = (load(GAME) as PackedScene).instantiate()
	root.add_child(game)
	await create_timer(START).timeout
	var boons: Variant = game.get(&"boons")
	for id in _ids("held", HELD):
		game.call(&"_take", boons.call(&"find", id))
	# a typed Array[Boon] from the run itself, refilled with the cards to show
	var offers: Array = boons.call(&"offers", RandomNumberGenerator.new(), 1)
	offers.clear()
	for id in _ids("offer", OFFER):
		offers.append(boons.call(&"find", id))
	game.call(&"_open_choice", offers)
	if Dev.has("rest"):
		# the run takes the rest at once when nothing is left to offer; show its card over the paused fight
		offers.clear()
	if Dev.has("rarity") or Dev.has("rest"):
		# the rarities to show, in card order: reopen the screen with them (the run rolled its own)
		var rar: Dictionary = game.get(&"_offer_rarity")
		var parts := Dev.arg("rarity", "").split(",", false)
		for i in mini(parts.size(), offers.size()):
			rar[offers[i].get(&"id")] = int(parts[i])
		var old: Node = game.get(&"_screen")
		var parent := old.get_parent()
		old.free()
		var choice: Node = ClassDB.instantiate(&"Control")
		choice.set_script(load("res://scripts/ui/boon_choice.gd"))
		parent.add_child(choice)
		choice.call(&"open", offers, boons, rar)
		choice.connect(&"chosen", Callable(game, &"_on_chosen"))
		game.set(&"_screen", choice)
	await create_timer(0.9).timeout
	await _shot("card")
	if Dev.has("focus-move"):
		var ev := InputEventAction.new()
		ev.action = &"ui_right"
		ev.pressed = true
		Input.parse_input_event(ev)
		await create_timer(0.3).timeout
		await _shot("card_focus")
	if Dev.has("card-only"):
		quit()
		return
	game.call(&"_on_chosen", boons.call(&"find", ELO))
	await create_timer(0.55).timeout
	await _shot("formed")
	await create_timer(1.0).timeout
	await _shot("formed_late")
	await create_timer(2.0).timeout
	game.call(&"_open_pause")
	var pause: Node = game.get(&"_screen")
	pause.call(&"_show", pause.call(&"_boons_screen"))
	await create_timer(0.4).timeout
	await _shot("panel")
	quit()


func _ids(key: String, fallback: Array[StringName]) -> Array[StringName]:
	if not Dev.has(key):
		return fallback
	var out: Array[StringName] = []
	for id in Dev.arg(key).split(",", false):
		out.append(StringName(id))
	return out


func _shot(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "%s_%s.png" % [_out, tag]
	root.get_texture().get_image().save_png(path)
	print("LAB saved ", path)
