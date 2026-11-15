extends SceneTree
## Captures of the gift screens inside a real run (the game, the bot fighting behind), for UI review:
## an Elo on the gift card, the "Elo formado" greeting, the gifts panel from the pause.
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/ui_lab.gd -- --lab-out=C:/x/elo --bot --hold --seed=5 [--stress=300]
## Writes <lab-out>_card.png, _formed.png and _panel.png. Calls the run's own methods; nothing here ships.

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
	for id in HELD:
		game.call(&"_take", boons.call(&"find", id))
	# a typed Array[Boon] from the run itself, refilled with the cards to show
	var offers: Array = boons.call(&"offers", RandomNumberGenerator.new(), 1)
	offers.clear()
	for id in OFFER:
		offers.append(boons.call(&"find", id))
	game.call(&"_open_choice", offers)
	await create_timer(0.9).timeout
	await _shot("card")
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


func _shot(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "%s_%s.png" % [_out, tag]
	root.get_texture().get_image().save_png(path)
	print("LAB saved ", path)
