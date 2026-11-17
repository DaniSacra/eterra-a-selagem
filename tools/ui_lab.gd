extends SceneTree
## Captures of the gift screens inside a real run (the game, the bot fighting behind), for UI review:
## an Elo on the gift card, the "Elo formado" greeting, the gifts panel from the pause.
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/ui_lab.gd -- --lab-out=C:/x/elo --bot --hold --seed=5 [--stress=300]
## Writes <lab-out>_card.png, _formed.png and _panel.png. Calls the run's own methods; nothing here ships.
## Gift card only (writes <lab-out>_card.png and, with --focus-move, <lab-out>_card_focus.png after one ui_right):
##   --card-only [--offer=a,b,c] [--held=x,y] [--rarity=0,2,1] [--upgrade=0,1,0] [--rest]
##   (--upgrade marks cards as exchanges one rarity up, E3-01: the offer is read as {rarity, upgrade})
##   --trade: the first offer comes as the rules' trade (BoonState.trade_card) through Game._open_choice, as in a run
## E3: --new-boon=id takes one Blessing never seen (writes _newboon.png with the "Bênção nova" greeting);
##   --codex=boons|elos opens the Compendium on that tab over sample save data (writes _codex.png, no run);
##   --shop [--gold=110] shows the run's own shop signs with that much gold (writes _shop.png;
##   start the run with --start=shop).
## E4: --codex=psalms|enemies|morvath|arenas too (sample data with some found, some not);
##   --psalm-card=id offers that Psalm between two Blessings in the run, holding what opens it (writes _psalm.png),
##   then picks it and writes _psalm_banner.png with the "Salmo descoberto" greeting over the fight.

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
	if Dev.has("codex"):
		await _codex()
		quit()
		return
	var game: Node = (load(GAME) as PackedScene).instantiate()
	root.add_child(game)
	await create_timer(START).timeout
	if Dev.has("shop"):
		await _shop(game)
		quit()
		return
	var boons: Variant = game.get(&"boons")
	if Dev.has("psalm-card"):
		await _psalm_card(game, boons)
		quit()
		return
	if Dev.has("new-boon"):
		game.call(&"_take", boons.call(&"find", StringName(Dev.arg("new-boon"))))
		await create_timer(0.6).timeout
		await _shot("newboon")
		quit()
		return
	for id in _ids("held", HELD):
		game.call(&"_take", boons.call(&"find", id))
	# a typed Array[Boon] from the run itself, refilled with the cards to show
	var offers: Array = boons.call(&"offers", RandomNumberGenerator.new(), 1)
	offers.clear()
	for id in _ids("offer", OFFER):
		offers.append(boons.call(&"find", id))
	if Dev.has("trade"):
		# the run's own path (Game._open_choice with the rules' cards): the first offer drawn as a trade of the Blessing
		# on its action (BoonState.trade_card), the others as plain cards
		var cards: Array = []
		for i in offers.size():
			cards.append(boons.call(&"trade_card", offers[i], RandomNumberGenerator.new()) if i == 0 else offers[i])
		game.call(&"_open_choice", cards)
	else:
		game.call(&"_open_choice", offers)
	if Dev.has("rest"):
		# the run takes the rest at once when nothing is left to offer; show its card over the paused fight
		offers.clear()
	if Dev.has("rarity") or Dev.has("rest") or Dev.has("upgrade"):
		# the rarities to show, in card order: reopen the screen with them (the run rolled its own); an exchange is
		# given the way the run hands it over, a Dictionary {rarity, upgrade}
		var rar: Dictionary = (game.get(&"_offer_rarity") as Dictionary).duplicate()
		var parts := Dev.arg("rarity", "").split(",", false)
		var ups := Dev.arg("upgrade", "").split(",", false)
		for i in offers.size():
			var id: Variant = offers[i].get(&"id")
			var r := int(parts[i]) if i < parts.size() else int((load("res://scripts/ui/boon_choice.gd") as GDScript).call(&"offer_of", rar.get(id)).rarity)
			rar[id] = {"rarity": r, "upgrade": i < ups.size() and ups[i] == "1"}
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


## The Compendium on the Bênçãos or Elos tab over sample save data: some Blessings met (one many times), two Elos
## formed, one Elo whose two Blessings were met (its recipe shows, its name does not).
func _codex() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.045, 0.06)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var data: Dictionary = (load("res://scripts/core/save_data.gd") as GDScript).call(&"defaults")
	var seen := {"brasas": 6, "toque_geada": 4, "onda_maior": 3, "escudo": 2, "passos": 1, "golpe_brasa": 5,
		"estilhaco": 2, "consolo": 1, "lamina_ardente": 1, "circulo_radiante": 2, "passo_geada": 1}
	for id: String in seen:
		data.codex.boons[id] = {"seen": seen[id]}
	data.codex.elos["vapor"] = {"formed": 2}
	data.codex.elos["aurora"] = {"formed": 1}
	data.codex.psalms["sentinela"] = {"seen": 2, "taken": 1}
	data.codex.psalms["pastor"] = {"seen": 1}
	data.codex.enemies = {"skeleton": {"defeated": 64, "elite": 5}, "runner": {"defeated": 31, "elite": 2},
		"mage": {"defeated": 18}, "archer": {"defeated": 12}, "guard": {"defeated": 7}, "knight": {"defeated": 1},
		"morvath": {"met": 3, "phase": 3}}
	data.codex.arenas = {"hall": {"entered": 9}, "crypt": {"entered": 3}, "garden": {"entered": 2}, "seal_chamber": {"entered": 3}}
	var screen: Control = ClassDB.instantiate(&"Control")
	screen.set_script(load("res://scripts/ui/codex_screen.gd"))
	root.add_child(screen)
	var tab: int = {"boons": 1, "elos": 2, "psalms": 3, "enemies": 4, "morvath": 5, "arenas": 6}.get(Dev.arg("codex"), 1)
	screen.call(&"open", tab, data)
	await create_timer(0.5).timeout
	await _shot("codex")


## The shop room with its signs remade as the three groups and the healing (C13-04), gold short for the dearer ones.
func _shop(game: Node) -> void:
	# the run's own shop (Rooms._build_shop puts DoorSign.shop on every item); 110 gold: some prices short. With a
	# Blessing held the growth items can show too: the shelf is set again after taking one (five items)
	var rooms: Node = game.get(&"rooms")
	var boons: Variant = game.get(&"boons")
	if not boons.call(&"can_grow"):
		game.call(&"_take", boons.call(&"find", &"brasas"))
		var pedestals: Array = rooms.get(&"_pedestals")
		for p: Dictionary in pedestals:
			(p.node as Node).free()
		pedestals.clear()
		rooms.call(&"_build_shop")
	rooms.set(&"gold", int(Dev.arg("gold", "110")))
	await create_timer(0.6).timeout
	await _shot("shop")


## A Psalm card between two Blessings in the run (holding one thing of each of its groups), then picked: the card and
## the greeting.
func _psalm_card(game: Node, boons: Variant) -> void:
	var psalms: Variant = game.get(&"psalms")
	var p: Variant = psalms.call(&"find", StringName(Dev.arg("psalm-card")))
	var levels: Dictionary = boons.get(&"levels")
	for group: PackedStringArray in p.get(&"requires"):
		for entry in group:
			if not entry.begins_with("dom:"):
				levels[StringName(entry)] = 1
				break
	var card_script: Variant = (load("res://scripts/core/boon_state.gd") as GDScript).get(&"Card")
	var cards: Array = []
	for id in [&"brasas", &"", &"onda_maior"]:
		var c: Variant = card_script.new(boons.call(&"find", id) if id != &"" else null)
		if id == &"":
			c.set(&"psalm", p)
		cards.append(c)
	# the robot would take the Psalm at once (Game._open_choice): a person's screen, the robot back after the pick;
	# first the greetings of what was just put in the hand (an Elo formed) run out
	await create_timer(1.0).timeout
	var bot: Variant = game.get(&"bot")
	game.set(&"bot", null)
	await _quiet(game)
	game.call(&"_open_choice", cards)
	await create_timer(0.9).timeout
	await _shot("psalm")
	await _quiet(game)
	game.call(&"choose_card", cards[1])
	game.set(&"bot", bot)
	await create_timer(0.7).timeout
	await _shot("psalm_banner")


## The greetings of the hand put in by the lab (an Elo formed, Blessings new) go at once, so the Psalm's own shows.
func _quiet(game: Node) -> void:
	var banner: Node = (game.get(&"hud") as Node).call(&"banner")
	(banner.get(&"_queue") as Array).clear()
	banner.set(&"_t", 99.0)
	await process_frame
	await process_frame


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
