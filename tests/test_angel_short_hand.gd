extends GutTest
## PT-25-1: an angel met must put three cards on the table. Over many simulated runs (slots filling room by room) the
## family-only draw came up short; Encounter.cards completes the hand from the other families.

const RUNS := 120
const ROOMS := 14


func _family_only(state: BoonState, a: AngelDef, rng: RandomNumberGenerator) -> int:
	return state.draw(rng, 3, Boon.RARITY_CHANCE, Boon.ELO_CHANCE, Boon.TRADE_CHANCE,
		func(b: Boon) -> bool: return Encounter.belongs(state, b, a.family)).size()


func _global_supply(state: BoonState) -> int:
	var n := 0
	for b in state.catalog:
		if state.level(b.id) <= 0 and state.offerable(b):
			n += 1
	return n


func _simulate() -> Dictionary:
	var enc := Encounter.new(Encounter.load_catalog())
	var res := {"offers": 0, "short_before": 0, "short_after": 0}
	for seed_ in RUNS:
		var state := BoonState.new(BoonState.load_catalog())
		state.ult_open = true
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_ + 1
		for room in ROOMS:
			var pair := enc.pair(state, rng)
			var last: Array[BoonState.Card] = []
			for a in pair:
				var dice := Encounter.cards_dice(seed_, room, room, a.id)
				var dice2 := Encounter.cards_dice(seed_, room, room, a.id)
				res["offers"] += 1
				if _family_only(state, a, dice) < 3:
					res["short_before"] += 1
				var cards := Encounter.cards(state, a, dice2)
				if cards.size() < 3 and _global_supply(state) >= 3:
					res["short_after"] += 1
				elif cards.size() < 3:
					res["pool_dry"] = int(res.get("pool_dry", 0)) + 1
				last = cards
			if not last.is_empty():
				state.take_card(last[rng.randi() % last.size()])
	return res


func test_angel_hand_is_three_across_many_runs() -> void:
	var r := _simulate()
	gut.p("angel offers %d, short before the fix %d, after %d (whole catalog dry: %d)" % [r["offers"], r["short_before"], r["short_after"], r.get("pool_dry", 0)])
	assert_gt(r["offers"], 0)
	assert_eq(r["short_after"], 0, "an angel offered fewer than 3 cards")


func test_no_duplicates_and_nothing_held_in_a_completed_hand() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	state.ult_open = true
	for b in state.catalog:
		if b.slot == Boon.Slot.ATTACK and state.offerable(b):
			state.take(b)
			break
	for a in Encounter.load_catalog():
		var rng := RandomNumberGenerator.new()
		rng.seed = 7
		var ids := {}
		for c in Encounter.cards(state, a, rng):
			assert_false(ids.has(c.boon.id), "duplicate card")
			ids[c.boon.id] = true
			assert_eq(state.level(c.boon.id), 0, "a held Blessing came back")
