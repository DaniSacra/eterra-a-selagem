extends GutTest
## E6 (balancing the first region, docs/design/e6_balance.md): the robot weighs the Provação's curses and the altar
## like a sensible player, the Gifts asked for and left out say why, and the shop's pomegranate slice never breaks.

const STAGE := "res://data/stages/catacombs.tres"

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _card(blessing: StringName, curse: StringName, rarity: int) -> Trials.Card:
	var t := Trials.new(Trials.load_catalog())
	var c := Trials.Card.new()
	for d in t.catalog:
		if d.id == blessing:
			c.blessing = d
		if d.id == curse:
			c.curse = d
	c.rarity = rarity
	return c


func test_the_robot_leaves_poverty_while_the_shop_is_ahead() -> void:
	var cards: Array[Trials.Card] = [_card(&"trial_golpe", &"trial_pobreza", 2), _card(&"trial_vigor", &"trial_ferida", 0),
		_card(&"trial_pesado", &"trial_fragil", 1)]
	assert_eq(Trials.bot_card(cards, true), 1, "an epic blessing does not pay for reaching the shop without gold")
	assert_eq(Trials.bot_card(cards, false), 0, "with no shop ahead no gold costs nothing: the epic one")


func test_the_robot_weighs_rarity_against_the_curse() -> void:
	var cards: Array[Trials.Card] = [_card(&"trial_golpe", &"trial_fragil", 0), _card(&"trial_vigor", &"trial_pressa", 2)]
	assert_eq(Trials.bot_card(cards, true), 1, "a lighter curse and an epic blessing")
	var even: Array[Trials.Card] = [_card(&"trial_golpe", &"trial_horda", 0), _card(&"trial_vigor", &"trial_pressa", 0)]
	assert_eq(Trials.bot_card(even, true), 0, "a tie goes to the first card")
	for id: StringName in Trials.BOT_CURSE_COST:
		assert_true(Trials.new(Trials.load_catalog()).catalog.any(func(d: TrialDef) -> bool: return d.id == id),
			"%s is a real curse" % id)


func test_the_robot_keeps_gold_for_the_shop_at_the_altar() -> void:
	var cost := stage.altar_gold_cost
	assert_eq(Altar.bot_choice(Altar.options(stage, cost, 40, true), 40, cost), -1,
		"the candles would leave nothing for the shop's healing")
	var rich := cost + Altar.BOT_GOLD_KEEP
	assert_eq(Altar.bot_choice(Altar.options(stage, rich, 40, true), 40, rich), Altar.Option.CANDLES)
	assert_eq(Altar.bot_choice(Altar.options(stage, 0, 50, true), 50, 0), Altar.Option.LIFE)


func test_the_robot_walks_into_the_altar_only_to_trade() -> void:
	var altar := RunMap.Room.new(RunMap.Kind.ALTAR, RunMap.Reward.NONE, 3, -1)
	var heart := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.HEART, 3, 0)
	var doors: Array[RunMap.Room] = [altar, heart]
	assert_eq(Rooms.bot_door(doors), 0, "a trade to make: the altar before a heart")
	assert_eq(Rooms.bot_door(doors, false), 1, "nothing to trade: any fight first")
	var only: Array[RunMap.Room] = [altar]
	assert_eq(Rooms.bot_door(only, false), 0, "the only door is still taken")


func test_the_gifts_left_out_say_why() -> void:
	var book := HeroDef.warrior().talents()
	var asked := [&"quarto_corte", &"impeto", &"reserva", &"nope"]
	var top := HeroDef.warrior().mastery.max_level
	var dev := HeroDef.warrior().mastery.devotion(top)
	var kept := book.sanitized(asked, top, dev)
	assert_eq(kept, [&"quarto_corte", &"impeto"] as Array[StringName])
	var why := book.why_dropped(asked, kept, top, dev)
	assert_eq(why.get(&"reserva"), Talents.Problem.NEEDS, "Reserva is the Magia branch's middle: it needs Lâmina Faminta")
	assert_eq(why.get(&"nope"), Talents.Problem.UNKNOWN)
	assert_false(why.has(&"impeto"))
	var low := book.sanitized(asked, 1, HeroDef.warrior().mastery.devotion(1))
	assert_eq(book.why_dropped(asked, low, 1, HeroDef.warrior().mastery.devotion(1)).get(&"impeto"), Talents.Problem.LOCKED,
		"Ímpeto opens at Mastery 3")
	var with_entry := book.sanitized([&"lamina_faminta", &"reserva"], top, dev)
	assert_eq(with_entry, [&"lamina_faminta", &"reserva"] as Array[StringName], "with its entry Reserva stays")


func test_a_pomegranate_slice_grows_a_blessing_in_a_real_run() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var b := load("res://data/boons/02_lamina_ardente.tres") as Boon
	game.boons.take(b)
	var before := game.boons.level(b.id)
	assert_true(game.grow_random(), "a Blessing held can grow")
	assert_eq(game.boons.level(b.id), before + 1)
	assert_true(game.offer_cards.is_empty())


func test_ainda_de_pe_guards_the_descent_not_morvaths_fight() -> void:
	var gs := GiftState.new(HeroDef.warrior(), BoonState.new())
	var t := HeroDef.warrior().talents()
	gs.boons.equip_talents(t.defs([&"ainda_de_pe"]))
	gs.rises = 1
	assert_almost_eq(gs.rise_life(40.0), 20.0, 0.01, "half of his life on the descent")
	gs.boss_room = true
	assert_false(gs.rise(), "in Morvath's room no rise (rise_boss_share 0)")
	assert_eq(gs.rises, 1, "the rise is not spent there")


func test_in_a_real_run_the_fall_before_morvath_is_final() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.equip_talents([&"ainda_de_pe"] as Array[StringName])
	game.start_boss(&"morvath")
	var p := game.player
	p.invuln = 0.0
	p.hurt(p.hp + 5.0, p.pos + Vector2.RIGHT)
	assert_false(p.alive(), "Ainda de Pé does not stand him up in Morvath's room")
