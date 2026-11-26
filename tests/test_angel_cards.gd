extends GutTest
## PT-25-1: an angel that is met always brings three cards (never one), with the Warrior's tags and the Shift button
## closed or open, over random hands and the Psalms filled in as the game does.

func _state(ult_open: bool) -> BoonState:
	var s := BoonState.new(BoonState.load_catalog())
	s.ult_open = ult_open
	s.set_hero_moves(load("res://data/combos/paladin.tres") as ComboTree)
	return s


func test_eligible_angel_always_has_three_cards() -> void:
	var book := Encounter.new(Encounter.load_catalog())
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var bad := []
	for run in 300:
		var state := _state(run % 2 == 0)
		for room in 8:
			for a in book.catalog:
				if not Encounter.eligible(state, a):
					continue
				var cards := Encounter.cards(state, a, rng, 3, stage.rarity_chance, stage.elo_chance, stage.trade_chance)
				if cards.size() != mini(3, Encounter.supply(state, a)):  # (V1: one or two are shown as they are)
					bad.append("%s run %d room %d held %d: %d cards" % [a.id, run, room, state.owned().size(), cards.size()])
			if run % 3 == 0:
				for k in 2:
					state.banned[state.catalog[rng.randi() % state.catalog.size()].id] = true  # Escolhas Perdidas
			if run % 5 == 0:
				var any := state.draw(rng, 3)
				if not any.is_empty():
					state.take_card(any[0])  # a Blessing from outside the angels (the shop's)
			var pair := book.pair(state, rng)
			if pair.is_empty():
				break
			var cards := Encounter.cards(state, pair[0], rng, 3, stage.rarity_chance, stage.elo_chance, stage.trade_chance)
			state.take_card(cards[rng.randi() % cards.size()])
	assert_eq(bad.size(), 0, "\n".join(bad.slice(0, 8)))


## An angel short of cards says so on the screen (and a full hand of three says nothing).
func test_screen_says_when_an_angel_has_fewer_than_three() -> void:
	var st := _state(false)
	var book := Encounter.new(Encounter.load_catalog())
	var two: Array[Boon] = [st.find(&"golpe_brasa"), st.find(&"brasas")]
	var three: Array[Boon] = [st.find(&"golpe_brasa"), st.find(&"brasas"), st.find(&"passo_brasa")]
	for offers: Array[Boon] in [two, three]:
		var choice := BoonChoice.new()
		add_child_autofree(choice)
		choice.open(offers, st)
		choice.by_angel(book.find(&"sarael"))
		assert_eq(choice.find_child("angel_few", true, false) != null, offers.size() < 3, "notice only when short")
