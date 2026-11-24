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
	var asked := [&"disciplina", &"forca_concentrada", &"apogeu", &"nope"]
	var top := HeroDef.warrior().mastery.max_level
	var dev := HeroDef.warrior().mastery.devotion(top)
	var kept := book.sanitized(asked, top, dev)
	assert_eq(kept, [&"disciplina", &"forca_concentrada"] as Array[StringName])
	var why := book.why_dropped(asked, kept, top, dev)
	assert_eq(why.get(&"apogeu"), Talents.Problem.NEEDS, "Apogeu needs Maestria Marcial")
	assert_eq(why.get(&"nope"), Talents.Problem.UNKNOWN)
	assert_false(why.has(&"forca_concentrada"))
	var low := book.sanitized(asked, 1, HeroDef.warrior().mastery.devotion(1))
	assert_eq(book.why_dropped(asked, low, 1, HeroDef.warrior().mastery.devotion(1)).get(&"forca_concentrada"), Talents.Problem.LOCKED,
		"Força Concentrada opens at Mastery 2")
	var with_entry := book.sanitized([&"disciplina", &"cadencia"], top, dev)
	assert_eq(with_entry, [&"disciplina", &"cadencia"] as Array[StringName], "with its entry Cadência stays")


func test_a_pomegranate_slice_grows_a_blessing_in_a_real_run() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var b := load("res://data/boons/02_lamina_ardente.tres") as Boon
	game.boons.take(b)
	var before := game.boons.level(b.id)
	assert_true(game.grow_random(), "a Blessing held can grow")
	assert_eq(game.boons.level(b.id), before + 1)
	assert_true(game.offer_cards.is_empty())


func _rise() -> Array[BoonMod]:
	var m := BoonMod.new()
	m.stat = &"rise_share"
	m.base = 0.5
	m.by_rarity = false
	return [m] as Array[BoonMod]


func test_ainda_de_pe_guards_the_descent_not_morvaths_fight() -> void:
	var gs := GiftState.new(HeroDef.warrior(), BoonState.new())
	gs.boons.grant(_rise())  # (Ainda de Pé is a Videira node now: a granted number)
	gs.rises = 1
	assert_almost_eq(gs.rise_life(40.0), 20.0, 0.01, "half of his life on the descent")
	gs.boss_room = true
	assert_false(gs.rise(), "in Morvath's room no rise (rise_boss_share 0)")
	assert_eq(gs.rises, 1, "the rise is not spent there")


func test_in_a_real_run_the_fall_before_morvath_is_final() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.boons.grant(_rise())
	game.hero_gifts.equip()
	game.start_boss(&"morvath")
	var p := game.player
	p.invuln = 0.0
	p.hurt(p.hp + 5.0, p.pos + Vector2.RIGHT)
	assert_false(p.alive(), "Ainda de Pé does not stand him up in Morvath's room")


## C17, QW-112 (GP P2-7): the robot takes the fountain only below 80% of its life; with more, any reward first.
func test_the_robot_drinks_only_when_hurt() -> void:
	var fountain := RunMap.Room.new(RunMap.Kind.FOUNTAIN, RunMap.Reward.NONE, 5, 0)
	var boon := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.BOON, 5, 0)
	var doors: Array[RunMap.Room] = [fountain, boon]
	assert_eq(Rooms.bot_door(doors, true, 0.5), 0, "hurt: the fountain")
	assert_eq(Rooms.bot_door(doors, true, 0.79), 0)
	assert_eq(Rooms.bot_door(doors, true, 0.8), 1, "80% and more: the Blessing")
	assert_eq(Rooms.bot_door(doors, true, 1.0), 1)
	var only: Array[RunMap.Room] = [fountain]
	assert_eq(Rooms.bot_door(only, true, 1.0), 0, "the only door is still taken")
