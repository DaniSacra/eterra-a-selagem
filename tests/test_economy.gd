extends GutTest
## E3 economy with Hades II's rules: the doors' deck (C13-02), the gold of a fight dropped by the enemies (C13-04),
## the shop in three groups, and the damage ledger by source (DT-016, E3-05).

const R := RunMap.Reward

var stage: StageDef


func before_all() -> void:
	stage = load("res://data/stages/catacombs.tres")


func _any(_card: int) -> bool:
	return true


func test_the_deck_is_drawn_without_putting_back_then_filled_again() -> void:
	var deck := RewardDeck.new(stage.reward_deck)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2
	var counts := {}
	for i in stage.reward_deck.size():
		var c := deck.draw(rng, _any)
		counts[c] = counts.get(c, 0) + 1
	for c in stage.reward_deck:
		assert_eq(counts[c], Array(stage.reward_deck).count(c), "each card exactly as often as it is in the deck")
	assert_eq(deck.left.size(), 0)
	assert_eq(deck.refills, 0)
	assert_ne(deck.draw(rng, _any), -1, "an empty deck fills again")
	assert_eq(deck.refills, 1)
	assert_eq(deck.left.size(), stage.reward_deck.size() - 1)


func test_a_card_that_does_not_fit_stays_in_the_deck() -> void:
	var deck := RewardDeck.new(PackedInt32Array([R.POM, R.BOON, R.GOLD]))
	var rng := RandomNumberGenerator.new()
	var no_pom := func(c: int) -> bool: return c != R.POM
	assert_ne(deck.draw(rng, no_pom), R.POM)
	assert_ne(deck.draw(rng, no_pom), R.POM)
	assert_eq(deck.left, [R.POM] as Array[int], "the pomegranate waits for a gift that can grow")
	assert_ne(deck.draw(rng, no_pom), R.POM, "nothing fits: filled again, still no pomegranate")
	assert_eq(deck.refills, 1)
	var none := func(_c: int) -> bool: return false
	assert_eq(deck.draw(rng, none), -1)


func test_the_deck_has_hades_shape() -> void:
	var cards := Array(stage.reward_deck)
	assert_gte(cards.count(R.BOON), 4)
	assert_eq(cards.count(R.POM), 2)
	assert_eq(cards.count(R.HEART), 3)
	assert_eq(cards.count(R.MAGICK), 2)
	assert_eq(cards.count(R.GOLD), 3)


## DV-1: every fight of the graph took its card off the deck when the map was drawn (the deck filled again as it ran
## out), and no two doors of a room promise the same.
func test_doors_of_a_room_never_repeat_and_the_deck_runs_down() -> void:
	var big := 0
	# (a deck of 8 cards, so graphs of two rooms a layer run it down; the stage's of 21 seldom ends in a descent)
	var small: StageDef = stage.duplicate()
	small.reward_deck = PackedInt32Array([R.BOON, R.BOON, R.BOON, R.BOON, R.POM, R.HEART, R.MAGICK, R.GOLD])
	small.fixed_rewards = {}  # (SW-R2: the fixed doors take no card off the deck)
	for s in 50:
		var map := RunMap.new(small, s)
		var fights := 0
		for r in map.nodes:
			if r.kind == RunMap.Kind.COMBAT and r.depth > 1:
				fights += 1
			var seen := {}
			for d in map.doors_of(r):
				if d.kind == RunMap.Kind.COMBAT:
					assert_false(seen.has(d.reward), "seed %d room %d: two doors promise the same" % [s, r.id])
					seen[d.reward] = true
		if fights > small.reward_deck.size():
			big += 1
			assert_gte(map.deck.refills, 1, "seed %d: the deck ran down and was filled again" % s)
		assert_lt(map.deck.left.size(), small.reward_deck.size(), "seed %d: the cards drawn are off the deck" % s)
	assert_gt(big, 10, "graphs with more fights than cards in the deck")


func test_the_gold_of_a_fight() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for depth in [1, 5, 10]:
		for i in 50:
			var cap := GoldPurse.ceiling_at(stage, depth, rng)
			assert_between(cap, 10 + floori(0.8 * depth), 15 + floori(0.8 * depth), "depth %d" % depth)
	# ten enemies of rating 10: each leaves a tenth of the ceiling 70% of the time, never past it
	var total := 0
	var fights := 2000
	for f in fights:
		var purse := GoldPurse.for_fight(stage, 4, 100.0, rng)
		var got := 0
		for k in 10:
			got += purse.drop(10.0, rng)
		assert_lte(got, purse.ceiling)
		total += got
	var mean := float(total) / fights
	assert_almost_eq(mean, 0.7 * (12.5 + floori(0.8 * 4)), 1.0, "about 70% of the ceiling on average")


func test_the_shop_has_three_groups_with_hades_prices() -> void:
	assert_eq(stage.shop_groups.size(), 3)
	var price := {}
	for g in stage.shop_groups:
		assert_eq(g.items.size(), g.prices.size())
		for i in g.items.size():
			price[g.items[i]] = g.prices[i]
	assert_eq(price[R.BOON], 150)
	assert_eq(price[R.HEAL], 50, "the cure costs 50 (C13-04)")
	assert_eq(price[R.HEART], 125)
	assert_eq(price[R.MAGICK], 100)
	assert_eq(price[R.POM], 100)
	assert_eq(price[R.POM_SLICE], 50)
	assert_eq(price[R.ENCHANT], 200, "an Encanto 200, Hades II's hammer (Fatia 2)")
	var rng := RandomNumberGenerator.new()
	# (no Encanto either: this checks the pomegranates' rule alone)
	var no_pom := func(item: int) -> bool: return item != R.POM and item != R.POM_SLICE and item != R.ENCHANT
	for i in 100:
		var g: ShopGroup = stage.shop_groups[2]
		assert_eq(g.items[g.pick(rng, no_pom)], R.MAGICK, "no pomegranate when nothing can grow")
	assert_ne(T.t(RunMap.REWARD_KEY[R.POM_SLICE]), String(RunMap.REWARD_KEY[R.POM_SLICE]), "the slice has a name")
	var counts := [1, 2, 2]
	for g in 3:
		assert_eq(stage.shop_groups[g].count, counts[g], "1 + 2 + 2: the five items of the last shop before the boss")
		var picked := stage.shop_groups[g].pick_all(rng, func(_i: int) -> bool: return true)
		assert_eq(picked.size(), counts[g])
		if picked.size() == 2:
			assert_ne(stage.shop_groups[g].items[picked[0]], stage.shop_groups[g].items[picked[1]], "two different items")


func test_the_shop_in_a_real_run() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.SHOP)
	assert_false(game.rooms.map.is_route_shop(game.rooms.map.here), "--start=shop is the shop before Morvath, never a route shop")
	var shelf := game.rooms.shop()
	assert_eq(shelf.size(), 5, "the Blessing, healing, the heart, the Magia tonic and an Encanto (no pomegranate: nothing to grow)")
	var groups := {}
	var items := {}
	for item: Dictionary in shelf:
		groups[item.group] = true
		items[item.item] = true
		assert_true(item.has("price") and item.has("affordable") and item.has("at"))
	assert_eq(groups.size(), 3)
	assert_true(items.has(R.HEAL), "healing for 50 is always there")
	assert_true(items.has(R.ENCHANT), "the Encanto with the tonic when nothing can grow (Fatia 2)")
	assert_false(items.has(R.POM) or items.has(R.POM_SLICE))
	# the gold falls from the enemies, not when the room is won
	game.rooms.gold = 0
	game.rooms.purse = GoldPurse.for_fight(stage, 3, 10.0, RandomNumberGenerator.new())
	game.rooms.purse.chance = 1.0
	game.rooms.phase = Rooms.Phase.FIGHT
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3, 3), false)
	game.horde.damage(e, 9999.0, Vector2.RIGHT, 0.0)
	assert_gt(game.rooms.gold, 0, "the skeleton left its share")


func test_the_damage_ledger_by_source() -> void:
	assert_eq(DealtBy.source([&"light"] as Array[StringName]), &"attack")
	assert_eq(DealtBy.source([&"light", &"spin", &"finisher"] as Array[StringName]), &"attack")
	assert_eq(DealtBy.source([&"heavy", &"wave"] as Array[StringName]), &"special")
	assert_eq(DealtBy.source([&"light", &"thrust", &"finisher", &"omega"] as Array[StringName]), &"omega_attack")
	assert_eq(DealtBy.source([&"heavy", &"wave", &"charge", &"omega"] as Array[StringName]), &"omega_special")
	assert_eq(DealtBy.source([&"light", &"dash"] as Array[StringName]), &"dash")
	assert_eq(DealtBy.source([&"cast"] as Array[StringName]), &"cast")
	assert_eq(DealtBy.source([&"ultimate", &"light"] as Array[StringName]), &"ultimate")
	assert_eq(DealtBy.source([&"skill", &"chama", &"brasas"] as Array[StringName]), &"brasas")
	var d := DealtBy.new()
	d.add(&"attack", 10.0)
	d.add(&"attack", 5.4)
	d.add(&"brasas", 30.0)
	d.add(&"", 2.0)
	d.add(&"cast", 0.0)
	var r := d.report()
	assert_eq(r.keys()[0], "brasas", "largest first")
	assert_eq(r.attack, 15)
	assert_eq(r.other, 2)
	assert_false(r.has("cast"))


func test_the_result_reports_what_dealt_the_damage() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3, 3), false)
	game.combat.hit_enemy(e, 20.0, [&"light"] as Array[StringName], Vector2.RIGHT, 0.0)
	game.horde.dealing = &"burn"
	game.horde.damage(e, 5.0, Vector2.ZERO, 0.0)
	game.horde.dealing = &""
	var r := game.result()
	assert_true(r.has("dealt_by"))
	assert_eq(int(r.dealt_by.attack), 20)
	assert_eq(int(r.dealt_by.burn), 5)
	var line := game.result_line()
	assert_true(line.contains("\"dealt_by\""))


## C17, BUG-103: going from the shop to Morvath, no sign of the shop stands in the Câmara do Selo (the capture that
## showed them came from tools/ui_lab.gd --shop rebuilding the shop after the robot had already left it).
func test_no_shop_sign_in_the_chamber() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.SHOP)
	assert_gt(_signs(game), 0, "the shop has its signs")
	game.rooms._enter(game.rooms.next_rooms[0])
	await wait_process_frames(2)
	assert_eq(game.rooms.room.kind, RunMap.Kind.BOSS)
	assert_eq(_signs(game), 0, "no sign of the shop in Morvath's chamber")
	assert_true(game.rooms.shop().is_empty())


func _signs(game: Node) -> int:
	var n := 0
	for node in game.find_children("*", "", true, false):
		if node is DoorSign and not node.is_queued_for_deletion():
			n += 1
	return n
