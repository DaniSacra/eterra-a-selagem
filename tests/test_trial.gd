extends GutTest
## The Provação (E5; Hades II's Chaos): the slab's cost and chance by depth, the cards (a blessing at a drawn rarity
## and a curse for 3 to 5 fights), the curse acting on the fight's numbers and turning into its blessing, and the
## whole way in a real room: the slab, the payment, the chamber, the card, the seal fields for the UI, the log.

const STAGE := "res://data/stages/catacombs.tres"

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _rng(s: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = s
	return r


func test_the_catalog_is_data() -> void:
	var defs := Trials.load_catalog()
	var blessings := defs.filter(func(d: TrialDef) -> bool: return d.kind == TrialDef.Kind.BLESSING)
	var curses := defs.filter(func(d: TrialDef) -> bool: return d.kind == TrialDef.Kind.CURSE)
	assert_gte(blessings.size(), 3, "three cards can be drawn")
	assert_gte(curses.size(), 3)
	for d in defs:
		assert_false(d.mods.is_empty(), "%s does something" % d.id)
		assert_ne(T.t(d.name_key), String(d.name_key), "%s has a name" % d.id)
		assert_ne(T.t(d.desc_key), String(d.desc_key), "%s has a description" % d.id)
		assert_false(T.t(d.desc_key).contains("—"), "no em-dash")
		if d.kind == TrialDef.Kind.CURSE:
			assert_eq(d.encounters, Vector2i(3, 5), "%s lasts 3 to 5 fights" % d.id)


func test_cost_and_who_may_pay() -> void:
	assert_eq(Trials.cost(stage, 2), 11, "ceil(10 + 0.5 x 2)")
	assert_eq(Trials.cost(stage, 3), 12, "ceil(10 + 1.5)")
	assert_eq(Trials.cost(stage, 7), 14)
	assert_false(Trials.can_pay(stage, 3, 12.0), "the cost or less: never")
	assert_true(Trials.can_pay(stage, 3, 12.5))
	assert_true(Trials.bot_accepts(stage, 3, 30, 30), "30 - 12 = 18 >= 0.6 x 30")
	assert_false(Trials.bot_accepts(stage, 3, 29, 30), "17 < 18: the robot keeps its life")


func test_where_and_how_often_the_slab_shows() -> void:
	var t := Trials.new(Trials.load_catalog())
	assert_false(t.may_show(stage, 1), "never in the first room")
	assert_false(t.may_show(stage, stage.trial_depth_max + 1))
	assert_true(t.may_show(stage, 2))
	var shown := 0
	var rng := _rng(5)
	for k in 4000:
		var tt := Trials.new(t.catalog)
		if tt.roll(stage, 3, rng):
			shown += 1
	assert_almost_eq(shown / 4000.0, stage.trial_chance, 0.03, "20% per room won")
	var u := Trials.new(t.catalog)
	while not u.roll(stage, 2, rng):
		pass
	for d in range(3, 8):
		assert_false(u.roll(stage, d, rng), "cooldown of 10 rooms (one per descent of 7)")
	var v := Trials.new(t.catalog)
	v.take(v.offers(rng, 1, stage.trial_rarity_chance)[0])
	assert_false(v.may_show(stage, 4), "not while a curse is carried")


func test_cards_are_distinct_and_rarities_follow_the_chaos() -> void:
	var t := Trials.new(Trials.load_catalog())
	var rng := _rng(9)
	var rare := 0
	var epic := 0
	for k in 3000:
		var cards := t.offers(rng, 3, stage.trial_rarity_chance)
		assert_eq(cards.size(), 3)
		var b := {}
		var c := {}
		for card in cards:
			b[card.blessing.id] = true
			c[card.curse.id] = true
			assert_between(card.encounters, 3, 5)
			if card.rarity == 1:
				rare += 1
			elif card.rarity == 2:
				epic += 1
			assert_lt(card.rarity, 3, "no heroic from the Provação")
		assert_eq(b.size(), 3, "three different blessings")
		assert_eq(c.size(), 3, "three different curses")
	# (the rarer is rolled first, as in Hades II: rare = 0.9 x 40%)
	assert_almost_eq(rare / 9000.0, 0.36, 0.03)
	assert_almost_eq(epic / 9000.0, 0.1, 0.02)
	var v: Dictionary = t.offers(rng, 1, stage.trial_rarity_chance)[0].view()
	for k in ["blessing", "blessing_name", "blessing_desc", "blessing_value", "rarity", "curse", "curse_name",
			"curse_desc", "curse_value", "encounters"]:
		assert_true(v.has(k), "the split card reads %s" % k)


func test_the_curse_lasts_its_fights_then_turns() -> void:
	var t := Trials.new(Trials.load_catalog())
	var card := Trials.Card.new()
	for d in t.catalog:
		if d.id == &"trial_vigor":
			card.blessing = d
		if d.id == &"trial_pressa":
			card.curse = d
	card.rarity = 1
	card.encounters = 3
	t.take(card)
	assert_almost_eq(t.curse(&"enemy_speed_pct"), 0.25, 0.001)
	assert_null(t.fight_won())
	assert_null(t.fight_won())
	assert_eq(t.left, 1)
	assert_eq(t.fight_won(), card, "the third fight turns it")
	assert_null(t.active)
	assert_eq(t.curse(&"enemy_speed_pct"), 0.0)
	var mods := Trials.blessing_mods(card)
	assert_almost_eq(mods[0].at(1, 1.0), 15.0 * 1.5, 0.01, "rare: 1.5 times the blessing")
	var boons := BoonState.new()
	var before := boons.stat(&"max_hp")
	boons.grant(mods)
	assert_almost_eq(boons.stat(&"max_hp") - before, 22.5, 0.01, "the blessing is kept for the run")


func _game() -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	return game


## The whole way in a real game: the slab after a won fight, paid on stepping, the chamber with its cards, one taken
## (its curse on the fight's numbers), the doors of the room before, its fights won, the blessing, the log.
func test_the_way_through_the_provacao() -> void:
	var game := _game()
	var rooms := game.rooms
	rooms.stage.trial_chance = 1.0
	rooms.map.depth = 3
	rooms._enter(RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 3, 1, 0))
	var doors := rooms.next_rooms.duplicate()
	game.horde.clear_crowd()
	rooms._open_doors()
	assert_not_null(rooms.slab, "the slab shows")
	var at: Vector2 = rooms.slab.at
	assert_gt(game.arena.shape().edge_distance(at), 2.0, "on open floor")
	var hp := game.player.hp
	game.player.place(at)
	rooms.step(0.5)
	assert_almost_eq(game.player.hp, hp, 0.01, "not before it arms")
	rooms.step(1.0)
	assert_almost_eq(game.player.hp, hp - Trials.cost(rooms.stage, 3), 0.01, "he paid its life")
	await wait_seconds(0.9)
	assert_eq(rooms.room.kind, RunMap.Kind.TRIAL, "in the chamber")
	assert_eq(rooms.phase, Rooms.Phase.EVENT, "doors shut until a card is taken")
	assert_eq(rooms.trial_cards.size(), 3)
	assert_eq(rooms.next_rooms, doors, "the doors of the room before")
	watch_signals(rooms)
	var card := rooms.trial_cards[1]
	rooms.take_trial(1)
	assert_signal_emitted(rooms, "trial_taken")
	assert_eq(rooms.phase, Rooms.Phase.OPEN)
	assert_eq(rooms.trials.active, card, "the HUD seal reads trials.active and trials.left")
	assert_eq(rooms.trials.left, card.encounters)
	var w := card.curse.id
	if w == &"trial_pressa":
		assert_almost_eq(game.horde.speed_scale, 1.25, 0.001)
	elif w == &"trial_ferida":
		assert_almost_eq(game.player.heal_scale, 0.5, 0.001)
	elif w == &"trial_fragil":
		assert_almost_eq(game.player.hurt_scale, 1.25, 0.001)
	elif w == &"trial_horda":
		var waves: Array[Array] = [[&"skeleton", &"archer"]]
		assert_eq(rooms._cursed_waves(waves)[0].size(), 3, "one more in each wave")
	var max_hp := game.player.max_hp
	for i in card.encounters:
		rooms._fight_won()
	assert_signal_emitted(rooms, "trial_turned")
	assert_null(rooms.trials.active)
	assert_eq(game.horde.speed_scale, 1.0, "the curse is gone")
	assert_eq(game.player.heal_scale, 1.0)
	if card.blessing.id == &"trial_vigor":
		assert_gt(game.player.max_hp, max_hp, "the blessing is his")
	var types := game.room_tally.events.map(func(e: Dictionary) -> String: return e.type)
	for t in ["trial_shown", "trial_paid", "trial_offered", "trial_taken", "trial_turned"]:
		assert_true(types.has(t), "the log says %s" % t)


## Every curse acts where it should: speed, healing, blows taken, waves, gold.
func test_every_curse_acts() -> void:
	var game := _game()
	var rooms := game.rooms
	for d in rooms.trials.catalog:
		if d.kind != TrialDef.Kind.CURSE:
			continue
		var c := Trials.Card.new()
		c.curse = d
		c.blessing = d
		rooms.trials.take(c)
		rooms._apply_curse()
		var changed := game.horde.speed_scale != 1.0 or game.player.heal_scale != 1.0 or game.player.hurt_scale != 1.0 \
			or rooms.trials.curse(&"wave_extra") > 0.0 or rooms.trials.curse(&"gold_pct") < 0.0
		assert_true(changed, "%s acts" % d.id)
		rooms.trials.active = null
		rooms._apply_curse()


## The slab not stepped on is refused in the log; with too little life it only says so.
func test_refused_and_too_poor() -> void:
	var game := _game()
	var rooms := game.rooms
	rooms.stage.trial_chance = 1.0
	rooms.map.depth = 4
	rooms._enter(RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 4, 2, 0))
	game.horde.clear_crowd()
	rooms._open_doors()
	assert_not_null(rooms.slab)
	var cost := Trials.cost(rooms.stage, 4)
	game.player.hp = cost
	game.player.place(rooms.slab.at)
	rooms.step(1.5)
	rooms.step(0.1)
	assert_eq(rooms.room.kind, RunMap.Kind.COMBAT, "the cost or less cannot pay")
	assert_eq(game.player.hp, float(cost))
	rooms._leave(rooms.next_rooms[0])
	var types := game.room_tally.events.map(func(e: Dictionary) -> String: return e.type)
	assert_true(types.has("trial_refused"))
