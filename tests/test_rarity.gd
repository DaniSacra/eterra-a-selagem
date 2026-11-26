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
	assert_almost_eq(odds[0], 0.77381, 0.0001)
	assert_almost_eq(odds[1], 0.14739, 0.0001)
	assert_almost_eq(odds[2], 0.05880, 0.0001)
	assert_almost_eq(odds[3], 0.02, 0.0001, "the legendary 2% in the common draw (SW-B2)")
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
	assert_almost_eq(stage.elo_chance, 0.5, 0.0001)
	assert_eq(stage.elo_ramp, Boon.ELO_RAMP)
	assert_almost_eq(stage.trade_chance, 0.1, 0.0001)


func test_four_rarities_with_their_multipliers_and_names() -> void:
	assert_eq(Boon.Rarity.size(), 4)
	assert_eq(Boon.RARITY_MULT, [1.0, 1.5, 2.0, 2.5] as Array[float], "D-53 (a): fixed")
	assert_eq(T.t(Boon.RARITY_KEY[Boon.Rarity.LEGENDARY]), "Lendária")
	var gold := Boon.RARITY_COLOR[Boon.Rarity.LEGENDARY]
	assert_lt(gold.s, 0.6, "old gold, never bright yellow")


## (V1, 2026-11-26: nothing is replaced, so there are no trade cards; the odds above are all that is left of E3-01 here, and
## test_blessings_v1_draw holds that a held slot is out of the draw.)



## SW-B2: the curve against the SWORN's (79.5 / 14 / 4.5 / 1.5 / 0.5): common and rare close, the top three together
## (epic + legendary here) a little over their 6.5, so the epic comes about once and the legendary every other descent
## over the 24 cards of a descent's Blessing doors.
func test_the_curve_is_near_the_sworn_and_felt_each_descent() -> void:
	var odds := BoonState.rarity_odds(Boon.RARITY_CHANCE)
	assert_between(odds[0], 0.72, 0.82, "common (SWORN 79.5)")
	assert_between(odds[1], 0.12, 0.17, "rare (SWORN 14)")
	assert_between(odds[2] + odds[3], 0.065, 0.10, "epic and legendary (SWORN 6.5 for the top three)")
	assert_gt(odds[2] * 24.0, 1.0, "an epic offered in every descent, on average")
	assert_between(odds[3] * 24.0, 0.3, 1.0, "a legendary seen in about every other descent")
	assert_lt(odds[3], odds[2], "the legendary stays rarer than the epic")


## SW-B2: each rarity adds the same step (a half of the first level): common < rare < epic < legendary in every number a
## rarity scales, and the numbers it must not scale are marked.
func test_every_rarity_adds_one_step_to_every_scaled_number() -> void:
	var step := Boon.RARITY_MULT[1] - Boon.RARITY_MULT[0]
	for r in range(1, 4):
		assert_almost_eq(Boon.RARITY_MULT[r] - Boon.RARITY_MULT[r - 1], step, 0.0001, "rarity %d" % r)
	for b in BoonState.load_catalog():
		for m in b.mods:
			if not m.by_rarity or m.base == 0.0:
				continue
			for r in range(1, 4):
				var up := absf(m.at(1, Boon.RARITY_MULT[r])) - absf(m.at(1, Boon.RARITY_MULT[r - 1]))
				assert_gt(up, 0.0, "%s %s: rarity %d no stronger than the one before" % [b.id, m.stat, r])


## SW-B2: the chance of an Elo is none below three Blessings and climbs to the ceiling at ten.
func test_the_elo_chance_climbs_from_three_blessings_to_half() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	for held in [0, 1, 2]:
		assert_eq(stage.elo_now(held), 0.0, "%d Blessings: no Elo yet" % held)
	assert_gt(stage.elo_now(3), 0.0, "with three it can come")
	assert_almost_eq(stage.elo_now(10), 0.5, 0.0001)
	assert_almost_eq(stage.elo_now(25), 0.5, 0.0001, "it holds at the ceiling")
	for held in range(3, 10):
		assert_lt(stage.elo_now(held), stage.elo_now(held + 1), "climbs at %d" % held)
	assert_eq(BoonState.elo_chance_at(5, 0.5, [] as Array[float]), 0.0, "no ramp, no Elo")
