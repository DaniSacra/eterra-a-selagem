extends GutTest
## Blessings V1 (02_REGRAS, 04_TESTES): the draw. A held slot never comes back, nothing is replaced, a complement waits for
## what it asks and never doubles, 0, 1, 2 or 3 options, an angel without one leaves before the door, the same seed gives the
## same cards, the fallback is the rest card that already existed.

var state: BoonState


func before_each() -> void:
	state = BoonState.new(BoonState.load_catalog())
	state.ult_open = true


func _angels() -> Array[AngelDef]:
	return Encounter.load_catalog()


func _angel(id: StringName) -> AngelDef:
	for a in _angels():
		if a.id == id:
			return a
	return null


func _ids(cards: Array[BoonState.Card]) -> Array[StringName]:
	var out: Array[StringName] = []
	for c in cards:
		out.append(c.boon.id)
	return out


func test_a_held_slot_is_out_of_the_draw_and_nothing_is_replaced() -> void:
	state.take(state.find(&"golpe_brasa"))
	for seed_ in 80:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_
		for c in state.draw(rng, 3):
			assert_ne(c.boon.slot, Boon.Slot.ATTACK, "%s rides the attack, already held" % c.boon.id)
			assert_null(c.replaces, "a card that replaces")
			assert_false(c.trade, "a trade card")
	assert_false(state.offerable(state.find(&"golpe_geada")))
	assert_true(state.offerable(state.find(&"toque_geada")), "another slot is free")


func test_taking_a_card_whose_slot_was_filled_in_between_gives_nothing() -> void:
	var card := BoonState.Card.new(state.find(&"golpe_geada"))
	state.take(state.find(&"golpe_brasa"))
	assert_eq(state.take_card(card), 0, "revalidated when taken")
	assert_eq(state.level(&"golpe_geada"), 0)
	assert_eq(state.level(&"golpe_brasa"), 1, "the holder stays")


func test_a_complement_waits_for_what_it_asks() -> void:
	var combustion := state.find(&"combustao")
	assert_false(state.offerable(combustion), "no source of fire")
	state.take(state.find(&"golpe_geada"))
	assert_false(state.offerable(combustion), "frost is no fire")
	state.take(state.find(&"pesado_brasa"))
	assert_true(state.offerable(combustion))
	assert_true(BoonNeeds.lines(combustion, state.catalog).size() > 0, "the card says what it asks")
	state.take(combustion)
	state = BoonState.new(BoonState.load_catalog())
	state.ult_open = true
	var peso := state.find(&"pesado_marca")
	assert_false(state.offerable(peso), "Peso da Penumbra needs a source of Marca")
	state.take(state.find(&"olhar_rapido"))
	assert_true(state.offerable(peso))
	var shadow := state.find(&"sombra_revelada")
	assert_false(state.offerable(shadow), "Marca and Eco")
	state.take(peso)
	assert_true(state.offerable(shadow))
	var crystals := state.find(&"cristais_errantes")
	assert_false(state.offerable(crystals), "asks Estilhaçamento")
	state.take(state.find(&"estilhaco"))
	assert_true(state.offerable(crystals))
	assert_false(state.offerable(state.find(&"amparo")), "asks Passo Firme")
	state.take(state.find(&"passo_firme"))
	assert_true(state.offerable(state.find(&"amparo")))
	assert_false(state.offerable(state.find(&"turbilhao")), "asks Cadência")
	assert_false(state.offerable(state.find(&"cadencia")), "asks a Blessing of Galael")
	state.take(state.find(&"golpe_mare"))
	assert_true(state.offerable(state.find(&"cadencia")))
	assert_true(state.offerable(state.find(&"brisa_favoravel")))
	assert_false(state.offerable(state.find(&"prosperidade")), "asks one of Lumael")
	state.take(state.find(&"clarao"))
	assert_true(state.offerable(state.find(&"prosperidade")))
	assert_true(state.offerable(state.find(&"fortuna_celestial")), "a source of crit")


func test_the_ultimate_waits_for_its_action() -> void:
	state.ult_open = false
	for b in state.catalog:
		if b.slot == Boon.Slot.ULT:
			assert_false(state.offerable(b), "%s offered with the ultimate closed" % b.id)
	state.ult_open = true
	assert_true(state.offerable(state.find(&"chuva_brasas")))


func test_the_angel_offers_up_to_three_and_the_ones_it_has() -> void:
	var sarael := _angel(&"sarael")
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	assert_eq(Encounter.supply(state, sarael), 5, "no complement before a source of fire: the five principals")
	assert_eq(Encounter.cards(state, sarael, rng).size(), 3)
	# take the principals one by one: 4, 3, 2, 1, 0 principals left, complements join as fire is held
	var order: Array[StringName] = [&"golpe_brasa", &"pesado_brasa", &"circulo_brasa", &"passo_brasa", &"chuva_brasas"]
	var seen := {}
	for id in order:
		state.take(state.find(id))
		var n := Encounter.supply(state, sarael)
		var cards := Encounter.cards(state, sarael, rng)
		seen[cards.size()] = true
		assert_eq(cards.size(), mini(n, 3), "after %s" % id)
		assert_true(Encounter.eligible(state, sarael) == (n >= 1))
		for c in cards:
			assert_false(state.level(c.boon.id) > 0, "%s is held and offered again" % c.boon.id)
	for id: StringName in [&"combustao", &"chama_contagiosa", &"brasa_persistente"]:
		assert_true(Encounter.eligible(state, sarael), "a complement is left")
		var cards := Encounter.cards(state, sarael, rng)
		assert_gt(cards.size(), 0)
		state.take(state.find(id))
	# one left (Fogo Crescente): one card, as it is
	var last := Encounter.cards(state, sarael, rng)
	assert_eq(_ids(last), [&"fogo_crescente"] as Array[StringName])
	assert_true(Encounter.eligible(state, sarael))
	state.take(state.find(&"fogo_crescente"))
	assert_eq(Encounter.supply(state, sarael), 0)
	assert_false(Encounter.eligible(state, sarael), "an exhausted angel is not met")
	assert_eq(Encounter.cards(state, sarael, rng).size(), 0)


func test_two_cards_are_shown_as_two() -> void:
	var sarael := _angel(&"sarael")
	for id: StringName in [&"golpe_brasa", &"pesado_brasa", &"circulo_brasa", &"passo_brasa", &"combustao", &"chama_contagiosa", &"brasa_persistente"]:
		state.take(state.find(id))
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var cards := Encounter.cards(state, sarael, rng)
	assert_eq(cards.size(), 2, "the Supremo and Fogo Crescente")
	assert_eq(Encounter.supply(state, sarael), 2)


## Nivael holds the five slots: Sarael has no principal left (its slots are taken) and nothing it asks, so it leaves; the
## frost complements keep Nivael itself in play; nobody else has a card.
func _hold_nivael() -> void:
	for id in [&"golpe_geada", &"toque_geada", &"circulo_geada", &"floco_errante", &"peso_inverno"]:
		assert_gt(state.take(state.find(id)), 0, String(id))


func test_an_exhausted_angel_leaves_before_the_door_and_the_rest_card_is_the_fallback() -> void:
	var book := Encounter.new(_angels())
	var sarael := _angel(&"sarael")
	var nivael := _angel(&"nivael")
	_hold_nivael()
	assert_eq(Encounter.supply(state, sarael), 0)
	var rng := RandomNumberGenerator.new()
	for seed_ in 40:
		rng.seed = seed_
		var pair := book.pair(state, rng)
		assert_false(pair.has(sarael), "the exhausted angel in a pair (seed %d)" % seed_)
		assert_eq(pair.size(), 1)
		assert_eq(pair[0], nivael)
	# every angel exhausted: nobody comes, the old rest card (Game.open_cards([])) stays the answer
	for b in state.catalog:
		if not b.reserve and not b.is_duo() and b.family == nivael.family:
			state.take(b)
	rng.seed = 3
	assert_eq(book.pair(state, rng).size(), 0)


func test_one_angel_alone_is_met_when_the_others_have_nothing() -> void:
	var book := Encounter.new(_angels())
	_hold_nivael()
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var pair := book.pair(state, rng)
	assert_eq(pair.size(), 1)
	assert_eq(pair[0], _angel(&"nivael"))


func test_the_same_seed_gives_the_same_cards() -> void:
	var sarael := _angel(&"sarael")
	var a := RandomNumberGenerator.new()
	var b := RandomNumberGenerator.new()
	a.seed = 77
	b.seed = 77
	for round in 6:
		var one := Encounter.cards(state, sarael, a)
		var two := Encounter.cards(state, sarael, b)
		assert_eq(_ids(one), _ids(two))
		assert_eq(one.map(func(c: BoonState.Card) -> int: return c.rarity), two.map(func(c: BoonState.Card) -> int: return c.rarity))
		if one.is_empty():
			break
		state.take_card(one[0])


func test_a_card_is_never_doubled_inside_a_draw() -> void:
	for seed_ in 100:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_
		var ids := _ids(state.draw(rng, 3))
		var seen := {}
		for id in ids:
			assert_false(seen.has(id), "%s twice" % id)
			seen[id] = true


func test_principals_weigh_twice_a_complement() -> void:
	var list: Array[Boon] = [state.find(&"golpe_brasa"), state.find(&"combustao")]
	var principal := 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for i in 3000:
		var copy := list.duplicate()
		var pick := BoonState.pick_weighted(copy, rng)
		principal += 1 if pick.slot != Boon.Slot.NONE else 0
	assert_almost_eq(principal / 3000.0, 2.0 / 3.0, 0.04)


func test_rarity_keeps_its_chances_and_levels_are_kept() -> void:
	assert_eq(Boon.RARITY_MULT, [1.0, 1.5, 2.0, 2.5] as Array[float])
	var b := state.find(&"golpe_brasa")
	state.take(b, Boon.Rarity.EPIC)
	assert_eq(state.rarity(b.id), Boon.Rarity.EPIC)
	assert_almost_eq(state.slot_stat(&"cel_burn_dps", Boon.Slot.ATTACK), 7.0, 0.001, "an epic doubles the DPS")
	state.take(b, Boon.Rarity.EPIC)
	assert_eq(state.level(b.id), 2)
	assert_almost_eq(state.slot_stat(&"cel_burn_dps", Boon.Slot.ATTACK), 7.0 + 1.5, 0.001, "the gain of a level is not scaled twice")


func test_the_old_ids_still_load_and_can_be_held_by_a_save_or_a_test() -> void:
	# nothing was deleted: an old run's list of ids resolves, and an old Blessing is still takeable by hand
	for id: StringName in [&"brasas", &"redemoinho", &"omega_mare", &"passo_mare", &"ultimo_brasa", &"passo_claro", &"passos", &"investida_firme"]:
		var b := state.find(id)
		assert_not_null(b, String(id))
		if b != null:
			assert_true(b.reserve, "%s is out of the draw" % id)
			assert_gt(state.take(b), 0, "%s cannot be held" % id)
