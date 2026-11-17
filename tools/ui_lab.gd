extends SceneTree
## Captures of the gift screens inside a real run (the game, the bot fighting behind), for UI review:
## an Elo on the gift card, the "Elo formado" greeting, the gifts panel from the pause.
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/ui_lab.gd -- --lab-out=C:/x/elo --bot --hold --seed=5 [--stress=300]
## Writes <lab-out>_card.png, _formed.png and _panel.png. Calls the run's own methods; nothing here ships.
## Gift card only (writes <lab-out>_card.png and, with --focus-move, <lab-out>_card_focus.png after one ui_right):
##   --card-only [--offer=a,b,c] [--held=x,y] [--rarity=0,2,1] [--upgrade=0,1,0] [--rest]
##   (--upgrade marks cards as exchanges one rarity up, E3-01: the offer is read as {rarity, upgrade})
## E3: --new-boon=id takes one Blessing never seen (writes _newboon.png with the "Bênção nova" greeting);
##   --codex=boons|elos opens the Compendium on that tab over sample save data (writes _codex.png, no run);
##   --shop puts the shop's three groups and the healing on signs with gold short for some (writes _shop.png;
##   start the run with --start=shop).

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
	game.call(&"_open_choice", offers)
	if Dev.has("rest"):
		# the run takes the rest at once when nothing is left to offer; show its card over the paused fight
		offers.clear()
	if Dev.has("rarity") or Dev.has("rest") or Dev.has("upgrade"):
		# the rarities to show, in card order: reopen the screen with them (the run rolled its own); an exchange is
		# given the way the rules may hand it over, a Dictionary {rarity, upgrade} (the run's own dictionary stays plain)
		var rar: Dictionary = (game.get(&"_offer_rarity") as Dictionary).duplicate()
		var parts := Dev.arg("rarity", "").split(",", false)
		var ups := Dev.arg("upgrade", "").split(",", false)
		for i in offers.size():
			var id: Variant = offers[i].get(&"id")
			var r := int(parts[i]) if i < parts.size() else int(rar.get(id, 0))
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
	var screen: Control = ClassDB.instantiate(&"Control")
	screen.set_script(load("res://scripts/ui/codex_screen.gd"))
	root.add_child(screen)
	var tab := 2 if Dev.arg("codex") == "elos" else 1
	screen.call(&"open", tab, data)
	await create_timer(0.5).timeout
	await _shot("codex")


## The shop room with its signs remade as the three groups and the healing (C13-04), gold short for the dearer ones.
func _shop(game: Node) -> void:
	var rooms: Node = game.get(&"rooms")
	var sign_script: GDScript = load("res://scripts/ui/door_sign.gd")
	var groups := ["shop_group_boon", "shop_group_care", "shop_group_growth", "shop_group_care"]
	var names := ["reward_boon", "reward_heal", "reward_pom", "reward_heart"]
	var prices := [150, 50, 100, 125]
	var gold := 110
	rooms.set(&"gold", gold)
	var pedestals: Array = rooms.get(&"_pedestals")
	var tr: Node = root.get_node("/root/T") if root.has_node("/root/T") else null
	for i in pedestals.size():
		var node: Node3D = pedestals[i].node
		for c in node.get_children():
			if c.get_script() == sign_script:
				c.free()
		var k := mini(i, names.size() - 1)
		var title: String = tr.call(&"t", names[k]) if tr else names[k]
		var group: String = tr.call(&"t", groups[k]) if tr else groups[k]
		var s: Node3D = sign_script.call(&"shop", title, prices[k], group)
		s.position.y = 2.7
		node.add_child(s)
		s.call(&"set_gold", gold)
	await create_timer(0.6).timeout
	await _shot("shop")


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
