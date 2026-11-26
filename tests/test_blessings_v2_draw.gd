extends GutTest
## Blessings V2 (IMPLEMENTACAO_V2.md 6): the draw with nine angels: the same seed the same cards, an angel the hand already holds
## weighs three against one, a short hand completed from the others, never a dead card, an angel with nothing leaves before the
## door, and --angels=zerael,thunder forces the pair.

var state: BoonState


func before_each() -> void:
	state = BoonState.new(BoonState.load_catalog())
	state.ult_open = true


func _angel(id: StringName) -> AngelDef:
	for a in Encounter.load_catalog():
		if a.id == id:
			return a
	return null


func test_each_new_angel_starts_with_its_five_principals_and_three_cards() -> void:
	for id: StringName in [&"zerael", &"thunder"]:
		var a := _angel(id)
		assert_not_null(a, String(id))
		assert_eq(Encounter.supply(state, a), 5, "%s: no complement before a source of its condition" % id)
		var rng := RandomNumberGenerator.new()
		rng.seed = 4
		var cards := Encounter.cards(state, a, rng)
		assert_eq(cards.size(), 3)
		for c in cards:
			assert_true(Encounter.belongs(state, c.boon, a.family), "%s is of %s" % [c.boon.id, id])


func test_the_pair_can_be_forced_to_zerael_and_saarael() -> void:
	var book := Encounter.new(Encounter.load_catalog())
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var pair := book.pair(state, rng, ["zerael", "thunder"])
	assert_eq(pair.size(), 2)
	assert_eq(pair[0].id, &"zerael")
	assert_eq(pair[1].id, &"thunder")


func test_the_same_seed_gives_the_same_pairs_and_cards_with_nine_angels() -> void:
	var book := Encounter.new(Encounter.load_catalog())
	for seed_ in 12:
		var a := RandomNumberGenerator.new()
		var b := RandomNumberGenerator.new()
		a.seed = seed_
		b.seed = seed_
		var p1 := book.pair(state, a)
		var p2 := book.pair(state, b)
		assert_eq(p1.map(func(x: AngelDef) -> StringName: return x.id), p2.map(func(x: AngelDef) -> StringName: return x.id))
		var c1 := Encounter.cards(state, p1[0], a)
		var c2 := Encounter.cards(state, p2[0], b)
		assert_eq(c1.map(func(c: BoonState.Card) -> StringName: return c.boon.id), c2.map(func(c: BoonState.Card) -> StringName: return c.boon.id))


func test_an_angel_the_hand_holds_weighs_three_against_one() -> void:
	var book := Encounter.new(Encounter.load_catalog())
	state.take(state.find(&"golpe_peste"))
	var first := 0
	var n := 2000
	for i in n:
		var rng := RandomNumberGenerator.new()
		rng.seed = 1000 + i
		var order := book.weighted_order(state, book.catalog, rng)
		if order[0].id == &"zerael":
			first += 1
	# weight 3 against eight angels of weight 1: 3 / 11
	assert_almost_eq(first / float(n), 3.0 / 11.0, 0.04)


## A whole descent of the dice: at every step every angel that is met offers one to three valid cards, never a card that is
## dead (a slot held, a complement without its source, a Blessing already held), and the hand ends full of the 81.
func test_no_dead_card_in_a_whole_hand_and_a_short_angel_is_completed() -> void:
	var book := Encounter.new(Encounter.load_catalog())
	for seed_ in 6:
		var s := BoonState.new(BoonState.load_catalog())
		s.ult_open = true
		var rng := RandomNumberGenerator.new()
		rng.seed = 300 + seed_
		var steps := 0
		while steps < 90:
			steps += 1
			var pair := book.pair(s, rng)
			if pair.is_empty():
				break
			var angel := pair[rng.randi() % pair.size()]
			var cards := Encounter.cards(s, angel, rng)
			assert_gte(cards.size(), 1, "an eligible angel met with nothing (seed %d)" % seed_)
			assert_lte(cards.size(), 3)
			var ids := {}
			for c in cards:
				assert_false(ids.has(c.boon.id), "%s twice" % c.boon.id)
				ids[c.boon.id] = true
				assert_true(s.offerable(c.boon), "%s is a dead card (seed %d)" % [c.boon.id, seed_])
				assert_eq(s.level(c.boon.id), 0, "%s is held already" % c.boon.id)
			var picked := cards[rng.randi() % cards.size()]
			assert_gt(s.take_card(picked), 0)
		assert_gt(steps, 12, "a hand of many Blessings (seed %d)" % seed_)


func test_an_exhausted_new_angel_leaves_before_the_door() -> void:
	var thunder := _angel(&"thunder")
	for b in state.catalog:
		if not b.reserve and not b.is_duo() and b.family == thunder.family:
			state.take(b)
	assert_eq(Encounter.supply(state, thunder), 0)
	assert_false(Encounter.eligible(state, thunder))
	var book := Encounter.new(Encounter.load_catalog())
	var rng := RandomNumberGenerator.new()
	for seed_ in 30:
		rng.seed = seed_
		assert_false(book.pair(state, rng, ["thunder"]).has(thunder), "an angel with nothing is never met")


func test_affinity_picks_the_family_the_hand_holds_with_the_new_angels() -> void:
	var angels := Encounter.load_catalog()
	state.take(state.find(&"golpe_trovao"))
	state.take(state.find(&"pesado_trovao"))
	state.take(state.find(&"circulo_brasa"))
	var pick := Encounter.affinity(state, angels)
	assert_eq(pick.id, &"thunder")
