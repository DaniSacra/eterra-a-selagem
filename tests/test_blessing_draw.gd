extends GutTest
## SW-B2: the draw of Blessings as the SWORN's: an angel the hand already holds weighs 3 against 1 of a new one, an Elo
## only comes with three Blessings or more and its chance climbs to 50%.

var stage: StageDef
var state: BoonState
var angels: Array[AngelDef]


func before_each() -> void:
	stage = load("res://data/stages/catacombs.tres")
	state = BoonState.new(BoonState.load_catalog())
	angels = Encounter.load_catalog()


func test_an_angel_held_weighs_three_against_one() -> void:
	state.take(state.find(&"brasas"))
	var held: AngelDef = null
	var fresh: Array[AngelDef] = []
	for a in angels:
		if Encounter.holds(state, a):
			held = a
		else:
			fresh.append(a)
	assert_not_null(held, "the hand holds one angel's family")
	assert_eq(Encounter.HELD_WEIGHT, 3.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var first: Dictionary = {}
	for i in 20000:
		var a: AngelDef = Encounter.weighted_order(state, angels, rng)[0]
		first[a.id] = int(first.get(a.id, 0)) + 1
	var total := 0.0
	for a in fresh:
		total += float(first.get(a.id, 0))
	var per_fresh := total / fresh.size()
	assert_almost_eq(float(first.get(held.id, 0)) / per_fresh, 3.0, 0.25, "the held one comes first 3 times to 1")


func test_nothing_held_is_a_fair_draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var first: Dictionary = {}
	for i in 14000:
		var a: AngelDef = Encounter.weighted_order(state, angels, rng)[0]
		first[a.id] = int(first.get(a.id, 0)) + 1
	for a in angels:
		assert_almost_eq(float(first.get(a.id, 0)) / 14000.0, 1.0 / angels.size(), 0.02)


func _elos_in(draws: int, held: int) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var n := 0
	for i in draws:
		for c in state.draw(rng, 3, Boon.RARITY_CHANCE, stage.elo_now(held), 0.0):
			if c.boon.is_duo():
				n += 1
	return n


func test_the_duo_waits_for_three_blessings() -> void:
	var vapor := state.find(&"vapor")
	for s in state.sources(vapor):
		state.take(s)
	assert_eq(state.owned().size(), 2)
	assert_true(state.forged(vapor), "the Elo can be formed")
	assert_eq(_elos_in(2000, state.owned().size()), 0, "never with two")
	state.take(state.find(&"escudo"))
	assert_eq(state.owned().size(), 3)
	assert_gt(_elos_in(2000, state.owned().size()), 0, "it can come with three")
