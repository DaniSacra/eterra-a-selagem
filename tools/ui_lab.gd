extends SceneTree
## Captures of the gift screens inside a real run (the game, the bot fighting behind), for UI review:
## an Elo on the gift card, the "Elo formado" greeting, the gifts panel from the pause.
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/ui_lab.gd -- --lab-out=C:/x/elo --bot --hold --seed=5 [--stress=300]
## Writes <lab-out>_card.png, _formed.png and _panel.png. Calls the run's own methods; nothing here ships.
## Gift card only (writes <lab-out>_card.png and, with --focus-move, <lab-out>_card_focus.png after one ui_right):
##   --card-only [--offer=a,b,c] [--held=x,y] [--rarity=0,2,1] [--upgrade=0,1,0] [--rest]
##   [--held-rarity=2,0] (the rarity of each held Blessing, in --held order; the rest as the run gives them)
##   (--upgrade marks cards as exchanges one rarity up, E3-01: the offer is read as {rarity, upgrade})
##   --trade: the first offer comes as the rules' trade (BoonState.trade_card) through Game._open_choice, as in a run
## E3: --new-boon=id takes one Blessing never seen (writes _newboon.png with the "Bênção nova" greeting);
##   --codex=boons|elos opens the Compendium on that tab over sample save data (writes _codex.png, no run);
##   --shop [--gold=110] shows the run's own shop signs with that much gold (writes _shop.png;
##   start the run with --start=shop and without --bot: the robot walks on to Morvath before the capture).
## E4: --codex=psalms|enemies|morvath|arenas too (sample data with some found, some not);
##   --psalm-card=id offers that Psalm between two Blessings in the run, holding what opens it (writes _psalm.png),
##   then picks it and writes _psalm_banner.png with the "Salmo descoberto" greeting over the fight.
## E5: --trial (start with --start=trial) opens the Provação's cards (_trial.png), takes the first (--pick=n) and shows
##   the seal in the HUD (_trial_seal.png), then wins its fights (_trial_won.png, the gold seal and the greeting);
##   --altar [--gold=N] [--held=a,b] (start with --start=altar) opens the altar's trades (_altar.png);
##   --slab (start with --start=fountain --hero-hp=N) shows the Provação's slab and its sign there (_slab.png).
## Rejogabilidade (Fatia 1): --meeting opens a room's Blessing by two angels (_meeting.png), then the cards of the
##   first (_meeting_cards.png); start without --bot. --found greets a door's Prata and Memória (_found.png).
## Rejogabilidade (Fatia 2): --enchant opens the Encanto's cards (_enchant.png; start without --bot);
##   --doors=boon,meeting,enchant,psalm puts those rewards behind the room's doors in order (boon: one angel, meeting:
##   two; or any RewardIcon id, a reward's like gold or a room's like shop) and opens them with the hero standing
##   before them (_doors.png); --shop --route rebuilds the shelf as a route
##   shop of three items, --want-enchant until an Encanto is on it (both put the hero before the shelf's middle);
##   --cursed lays Morvath's curse on the hero (_cursed.png, the HUD's condition seal).

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
	if Dev.has("found"):
		# Rejogabilidade, Fatia 1: the greeting of a material found (a door of Prata, then Memória) over the fight
		var rooms: Variant = game.get(&"rooms")
		rooms.call(&"found", MaterialPurse.SILVER, &"door", 10)
		rooms.call(&"found", MaterialPurse.MEMORY, &"door", 3)
		await create_timer(0.35).timeout
		await _shot("found")
		quit()
		return
	if Dev.has("enchant"):
		game.set(&"bot", null)
		game.call(&"open_enchant_choice")
		await create_timer(0.9).timeout
		await _shot("enchant")
		quit()
		return
	if Dev.has("cursed"):
		# the HUD with Morvath's curse on the hero (the condition's seal over the row), over the fight
		(game.get(&"player") as Variant).call(&"apply_curse", 8.0, 0.3, 0.0)
		await create_timer(0.8).timeout
		await _shot("cursed")
		quit()
		return
	if Dev.has("doors"):
		await _doors(game)
		quit()
		return
	if Dev.has("meeting"):
		# Rejogabilidade, Fatia 1: a room's Blessing by two angels (the Encontro, EncounterScreen, _meeting.png), then
		# the first angel's cards on the choice screen (_meeting_cards.png); start without --bot
		var rooms: Variant = game.get(&"rooms")
		game.call(&"open_boon_choice", rooms.get(&"stage").get(&"rarity_chance"), -1.0, true)
		await create_timer(0.6).timeout
		await _shot("meeting")
		var enc: Variant = game.get(&"encounters")
		var screen: Variant = game.get(&"_screen")
		screen.set(&"_opened_at", 0)
		(screen.get(&"buttons")[0] as Button).pressed.emit()
		await create_timer(0.9).timeout
		await _shot("meeting_cards")
		quit()
		return
	if Dev.has("trial") or Dev.has("altar") or Dev.has("slab"):
		await _events(game)
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
	var held_rarity := Dev.arg("held-rarity", "").split(",", false)
	var held := _ids("held", HELD)
	for i in held.size():
		if i < held_rarity.size():
			# a held Blessing at a given rarity (the legendary trade needs an epic one on its action)
			boons.call(&"take", boons.call(&"find", held[i]), int(held_rarity[i]))
		else:
			game.call(&"_take", boons.call(&"find", held[i]))
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
	# C17, BUG-103: with --bot the robot leaves the shop for Morvath before START, and rebuilding the shelf there put
	# the shop's signs in the Câmara do Selo (ui/shop_720_shop.jpg); only in the shop itself, and without --bot
	var here: Variant = rooms.get(&"room")
	if here == null or int(here.get(&"kind")) != 3:  # RunMap.Kind.SHOP
		push_error("ui_lab --shop: not in the shop (start with --start=shop and without --bot)")
		return
	if not boons.call(&"can_grow"):
		game.call(&"_take", boons.call(&"find", &"brasas"))
		var pedestals: Array = rooms.get(&"_pedestals")
		for p: Dictionary in pedestals:
			(p.node as Node).free()
			if is_instance_valid(p.get("shaft")):
				(p.shaft as Node).free()  # (its light over the item, RewardShaft, a child of the room)
		pedestals.clear()
		rooms.call(&"_build_shop")
	if Dev.has("route") or Dev.has("want-enchant"):
		if Dev.has("route"):
			# a shop of the way (DV-2): in a layer before the last (RunMap.is_route_shop)
			here.set(&"depth", 7)
		for i in 40:
			var pedestals: Array = rooms.get(&"_pedestals")
			for p: Dictionary in pedestals:
				(p.node as Node).free()
			pedestals.clear()
			rooms.call(&"_build_shop")
			var has := false
			for p: Dictionary in rooms.get(&"_pedestals"):
				has = has or int(p.item) == RunMap.Reward.ENCHANT
			if has or not Dev.has("want-enchant"):
				break
	rooms.set(&"gold", int(Dev.arg("gold", "110")))
	if Dev.has("route") or Dev.has("want-enchant"):
		# the hero before the middle of the shelf, so the whole of it shows
		var mid := Vector2.ZERO
		var pedestals: Array = rooms.get(&"_pedestals")
		for p: Dictionary in pedestals:
			mid += (p.at as Vector2) / pedestals.size()
		(game.get(&"player") as Variant).set(&"pos", mid + Vector2(2.5, 2.5))
		game.call(&"snap_camera")
	await create_timer(0.6).timeout
	await _shot("shop")


## Fatia 2: the next rooms' doors with the rewards asked for (--doors=boon,meeting,enchant,psalm), their signs made
## again by the run's own code (Rooms._marker, _sign_angel), the hero standing before them.
func _doors(game: Node) -> void:
	game.set(&"bot", null)
	var rooms: Node = game.get(&"rooms")
	(game.get(&"horde") as Variant).call(&"clear_crowd")
	rooms.call(&"_open_doors")
	var want := Dev.arg("doors", "boon,meeting,enchant").split(",", false)
	var next: Array = rooms.get(&"next_rooms")
	var labels: Array = rooms.get(&"_door_labels")
	var arena: Variant = game.get(&"arena")
	var encounters: Variant = game.get(&"encounters")
	var mid := Vector2.ZERO
	for i in next.size():
		var r: Variant = next[i]
		var w := want[i % want.size()]
		# any RewardIcon id works: a reward's (gold, pom, silver...) or a room kind's with no reward (shop, fountain...)
		var reward: int = RunMap.Reward.BOON
		var kind: int = RunMap.Kind.COMBAT
		if RunMap.Reward.has(w.to_upper()):
			reward = RunMap.Reward[w.to_upper()]
		elif RunMap.Kind.has(w.to_upper()):
			reward = RunMap.Reward.NONE
			kind = RunMap.Kind[w.to_upper()]
		elif w != "meeting":
			push_warning("--doors: no reward or room %s" % w)
		r.set(&"kind", kind)
		r.set(&"meeting", w == "meeting")
		r.set(&"reward", reward)
		r.set(&"angel", encounters.call(&"door_angel", r) if w == "boon" else &"")
		(labels[i] as Node).free()
		var at: Vector2 = arena.call(&"door_label", i)
		mid += at / next.size()
		var glyph: int = (load("res://scripts/ui/door_glyph.gd") as GDScript).call(&"of", rooms.call(&"door_info", i))
		var marker: Node3D = rooms.call(&"_marker", at, r.get(&"reward"), rooms.call(&"door_text", r), kind, glyph)
		labels[i] = marker
		rooms.call(&"_sign_angel", marker, r)
	var player: Variant = game.get(&"player")
	player.set(&"pos", mid * 0.55)
	game.call(&"snap_camera")
	await create_timer(1.0).timeout
	await _shot("doors")


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


## E5: the Provação's cards, its seal and its turn; the altar's trades; the slab and its sign.
func _events(game: Node) -> void:
	var rooms: Node = game.get(&"rooms")
	game.set(&"bot", null)
	if Dev.has("slab"):
		var stage: Variant = rooms.get(&"stage")
		stage.set(&"trial_chance", 1.0)
		(rooms.get(&"trials") as Variant).set(&"last_shown", -1000)
		(rooms.get(&"map") as Variant).set(&"depth", 3)
		rooms.call(&"_roll_slab")
		await create_timer(0.8).timeout
		await _shot("slab")
		return
	if Dev.has("altar"):
		rooms.set(&"gold", int(Dev.arg("gold", "40")))
		# --held=a,b: Blessings in hand first (the pomegranate's trade needs one that can grow)
		var boons: Variant = game.get(&"boons")
		for id in _ids("held", [] as Array[StringName]):
			game.call(&"_take", boons.call(&"find", id))
		rooms.call(&"_choose_altar")
		await create_timer(0.9).timeout
		await _shot("altar")
		return
	rooms.call(&"_choose_trial")
	await create_timer(0.9).timeout
	await _shot("trial")
	game.call(&"close_screen")
	rooms.call(&"take_trial", int(Dev.arg("pick", "0")))
	await create_timer(0.8).timeout
	await _shot("trial_seal")
	var left: int = (rooms.get(&"trials") as Variant).get(&"left")
	for i in left:
		rooms.call(&"_fight_won")
	await create_timer(0.6).timeout
	await _shot("trial_won")


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
