extends GutTest
## C13-03: the rarity of a card in sequence as in Hades II (rare 10%, epic 5%: 85.5 / 9.5 / 5; the guardian rare 90%,
## epic 7%: 9.3 / 83.7 / 7), the four rarities of decision D-52 with the legendary only by a trade (E3-01).

const DRAWS := 10000


func _shares(chances: Array[float], seed_: int) -> Array[float]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var seen: Array[float] = [0.0, 0.0, 0.0, 0.0]
	for i in DRAWS:
		seen[BoonState.roll_rarity(rng, chances)] += 1.0
	for r in 4:
		seen[r] /= DRAWS
	return seen


func test_the_odds_of_the_sequence() -> void:
	var odds := BoonState.rarity_odds(Boon.RARITY_CHANCE)
	assert_almost_eq(odds[0], 0.84645, 0.0001)
	assert_almost_eq(odds[1], 0.09405, 0.0001)
	assert_almost_eq(odds[2], 0.0495, 0.0001)
	assert_almost_eq(odds[3], 0.01, 0.0001, "the legendary 1% in the common draw (decision 10 of 2026-11-22)")
	var guardian := BoonState.rarity_odds(Boon.RARITY_CHANCE_GUARDIAN)
	assert_almost_eq(guardian[0], 0.09021, 0.0001, "the guardian's card is common now and then (Hades II)")
	assert_almost_eq(guardian[1], 0.81189, 0.0001)
	assert_almost_eq(guardian[2], 0.0679, 0.0001)
	assert_almost_eq(guardian[3], 0.03, 0.0001, "the legendary 3% at the guardian")


func test_ten_thousand_draws_within_one_point() -> void:
	for chances: Array[float] in [Boon.RARITY_CHANCE, Boon.RARITY_CHANCE_GUARDIAN]:
		var want := BoonState.rarity_odds(chances)
		for seed_ in [1, 2, 3]:
			var got := _shares(chances, seed_)
			for r in 4:
				assert_almost_eq(got[r], want[r], 0.01, "rarity %d, seed %d, chances %s" % [r, seed_, chances])


func test_the_stage_carries_hades_numbers() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	assert_eq(stage.rarity_chance, Boon.RARITY_CHANCE)
	assert_eq(stage.guardian_rarity_chance, Boon.RARITY_CHANCE_GUARDIAN)
	assert_almost_eq(stage.elo_chance, 0.12, 0.0001)
	assert_almost_eq(stage.trade_chance, 0.1, 0.0001)


func test_four_rarities_with_their_multipliers_and_names() -> void:
	assert_eq(Boon.Rarity.size(), 4)
	assert_eq(Boon.RARITY_MULT, [1.0, 1.5, 2.0, 2.5] as Array[float], "D-53 (a): fixed")
	assert_eq(T.t(Boon.RARITY_KEY[Boon.Rarity.LEGENDARY]), "Lendária")
	var gold := Boon.RARITY_COLOR[Boon.Rarity.LEGENDARY]
	assert_lt(gold.s, 0.6, "old gold, never bright yellow")


## E3-01: a card for an action already taken (10% a card) trades it for another one rarity higher at its level; an
## epic traded becomes legendary, a legendary stays legendary.
func test_a_trade_comes_one_rarity_higher_at_the_same_level() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var old := state.find(&"golpe_brasa")
	state.take(old, Boon.Rarity.EPIC)
	state.take(old)
	var card := state.trade_card(state.find(&"golpe_radiante"), rng, [0.0, 0.0, 0.0] as Array[float])
	assert_true(card.trade)
	assert_eq(card.replaces, old)
	assert_eq(card.rarity, Boon.Rarity.LEGENDARY)
	assert_eq(card.level, 2, "the level of the one it replaces")
	state.take_card(card)
	assert_eq(state.level(&"golpe_brasa"), 0, "the old one is gone")
	assert_eq(state.level(&"golpe_radiante"), 2)
	assert_eq(state.rarity(&"golpe_radiante"), Boon.Rarity.LEGENDARY)
	var again := state.trade_card(state.find(&"golpe_geada"), rng, [0.0, 0.0, 0.0] as Array[float])
	assert_eq(again.rarity, Boon.Rarity.LEGENDARY, "never past legendary")


func test_trades_come_about_one_card_in_ten() -> void:
	var catalog := BoonState.load_catalog()
	var rng := RandomNumberGenerator.new()
	rng.seed = 8
	var trades := 0
	var cards := 0
	for run in 2000:
		var state := BoonState.new(catalog)
		state.take(state.find(&"golpe_brasa"))
		for c in state.draw(rng, 3, Boon.RARITY_CHANCE, 0.0, 0.1):
			cards += 1
			if c.trade:
				trades += 1
				assert_eq(c.replaces.id, &"golpe_brasa")
				assert_gte(c.rarity, Boon.Rarity.RARE, "a common traded comes rare at least")
			else:
				assert_null(c.replaces, "with fresh gifts left a card never replaces without the trade")
	assert_almost_eq(float(trades) / cards, 0.1, 0.01)
