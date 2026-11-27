extends GutTest
## PT-27a: a Heart's door gives life and nothing else. A Heart's room is never a meeting nor shows an angel, settle never
## turns it into a Blessing, and every door a Blessing shows with one angel (no meeting) holds a full hand of cards.

var stage: StageDef


func before_each() -> void:
	stage = load("res://data/stages/catacombs.tres")


func test_a_heart_room_never_turns_into_a_blessing() -> void:
	var hearts := 0
	for s in 300:
		var map := RunMap.new(stage, hash([s, Rooms.MAP_SALT]))
		for r in map.nodes:
			if r.reward != RunMap.Reward.HEART:
				continue
			hearts += 1
			assert_false(r.meeting, "seed %d: a Heart's room is no meeting" % s)
			assert_eq(r.angel, &"", "seed %d: a Heart's room shows no angel" % s)
			var doors_: Array[RunMap.Room] = [r]
			map.settle(doors_, false, false, false)
			assert_eq(r.reward, RunMap.Reward.HEART, "seed %d: settle keeps the Heart" % s)
	assert_gt(hearts, 0)


func test_a_door_angel_always_has_three_cards() -> void:
	var enc := Encounter.new(Encounter.load_catalog())
	var state := BoonState.new(BoonState.load_catalog())
	state.ult_open = true
	var rng := RandomNumberGenerator.new()
	rng.seed = 27
	for room in 14:
		for a in enc.pair(state, rng):
			var cards := Encounter.cards(state, a, Encounter.cards_dice(27, room, room, a.id))
			assert_eq(cards.size(), 3, "room %d, %s" % [room, a.id])
		var mine := enc.pair(state, rng)
		if not mine.is_empty():
			var c := Encounter.cards(state, mine[0], Encounter.cards_dice(27, room, room, mine[0].id))
			if not c.is_empty():
				state.take_card(c[0])


## DT-2: the Warrior offers the Corte do Juízo alone; the Voragem stays in the data, in reserve, and is never announced.
func test_the_warrior_shows_only_the_cleave() -> void:
	var hero: HeroDef = load("res://data/heroes/warrior.tres")
	var seen: Array[StringName] = []
	for lvl in range(1, hero.mastery.max_level + 1):
		var ult := hero.ult_for_weapon(lvl)
		if ult != null and not seen.has(ult.id):
			seen.append(ult.id)
	assert_eq(seen.size(), 1, "one ultimate in play")
	assert_false(seen[0] == &"vortex")
	var loadout := HeroLoadout.new(hero, {})
	for n in range(1, hero.mastery.max_level + 1):
		for line in loadout.unlocks_at(n):
			assert_ne(line, T.t(&"ult_vortex"))
