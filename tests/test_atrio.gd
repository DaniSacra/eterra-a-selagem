extends GutTest
## Chapter II, A-2, A-3 and the end screen of A-6: the Átrio (fountain once, Galael's Graça, the merchant, the portal that opens only after the
## choice), the passage once, and the preview's end that is no victory.

var game: Game


func after_each() -> void:
	Dev.drop("chapter2")


func _start(on := true) -> void:
	if on:
		Dev.put("chapter2")
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)


func _into_atrio() -> void:
	_start()
	await game.rooms._enter(game.rooms._atrio_room())


# ---------- the pure rules ----------

func test_the_portal_is_shut_until_the_grace_is_chosen_and_the_choice_is_once() -> void:
	var a := Atrio.new()
	assert_false(a.portal_open())
	assert_false(a.choose(9), "a bad option")
	assert_true(a.choose(Atrio.Grace.HEAL))
	assert_true(a.portal_open())
	assert_false(a.choose(Atrio.Grace.LEVELS), "a second choice does nothing")
	assert_eq(a.chosen, Atrio.Grace.HEAL)


func test_grace_without_blessings_is_the_heal_only_and_applying_falls_back() -> void:
	var st := BoonState.new([])
	var o := Atrio.options(st)
	assert_true(o[Atrio.Grace.HEAL].ok)
	assert_false(o[Atrio.Grace.RARITY].ok)
	assert_false(o[Atrio.Grace.LEVELS].ok)
	assert_eq(Atrio.bot_choice(o), Atrio.Grace.HEAL)
	var rng := RandomNumberGenerator.new()
	for asked in [Atrio.Grace.RARITY, Atrio.Grace.LEVELS]:
		var r := Atrio.apply(asked, st, rng)
		assert_eq(r.option, Atrio.Grace.HEAL, "ineligible falls back to the heal")
		assert_almost_eq(float(r.heal), Atrio.HEAL_SHARE, 0.0001)


func test_grace_raises_rarity_and_levels_within_the_ceilings() -> void:
	var st := BoonState.new(BoonState.load_catalog())
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var held: Array[Boon] = []
	for b in st.catalog:
		if held.size() < 3 and b.slot != Boon.Slot.NONE and st.take(b) > 0:
			held.append(b)
	if held.size() < 2:
		pending("not enough Blessings to hold")
		return
	var before := held.map(func(b: Boon) -> int: return st.level(b.id))
	var r := Atrio.apply(Atrio.Grace.LEVELS, st, rng)
	if r.option == Atrio.Grace.LEVELS:
		assert_eq((r.boons as Array).size(), Atrio.LEVELS_COUNT)
		var up := 0
		for i in held.size():
			up += st.level(held[i].id) - before[i]
		assert_eq(up, Atrio.LEVELS_COUNT)
	for i in 5:
		Atrio.apply(Atrio.Grace.RARITY, st, rng)
	for b in held:
		assert_lte(st.rarity(b.id), Atrio.RARITY_CEILING, "never past the epic")


func test_the_preview_ends_only_at_the_chamber_of_a_later_region() -> void:
	assert_true(Regions.preview_over(1, RunMap.Kind.BOSS))
	assert_false(Regions.preview_over(0, RunMap.Kind.BOSS), "Morvath's chamber is Chapter I's")
	assert_false(Regions.preview_over(1, RunMap.Kind.COMBAT))
	assert_true(Regions.leads_on(0, true))
	assert_false(Regions.leads_on(0, false), "the switch off: the end screen as always")
	assert_false(Regions.leads_on(1, true), "no region after the last")


# ---------- the room ----------

func test_switch_off_no_atrio() -> void:
	_start(false)
	assert_false(game.rooms.begin_atrio())


func test_the_atrio_has_the_fountain_the_merchant_and_two_spots_on_free_floor() -> void:
	await _into_atrio()
	var r := game.rooms
	assert_eq(r.room.kind, RunMap.Kind.ATRIO)
	assert_eq(r.phase, Rooms.Phase.OPEN)
	assert_eq(r._atrio_spots.size(), 2)
	assert_false(r.shop().is_empty(), "the merchant")
	assert_not_null(game.fountain_target(), "the fountain")
	for s in r._atrio_spots:
		assert_true(game.arena.nav.walkable(s.at), String(s.kind))
		for p in r.shop():
			assert_gte((s.at as Vector2).distance_to(p.at), 4.0)
		assert_gte((s.at as Vector2).distance_to(Rooms.FOUNTAIN_SPOT), 5.0)
	assert_true(game.arena.nav.reachable(game.arena.start, Rooms.ATRIO_PORTAL))
	assert_true(game.arena.nav.reachable(game.arena.start, Rooms.ATRIO_GRACE))


func test_the_fountain_heals_once() -> void:
	await _into_atrio()
	game.player.hp = 10.0
	game.player.place(Rooms.FOUNTAIN_SPOT)
	game._step_fountain()
	var healed := game.player.hp
	assert_gt(healed, 10.0 + game.player.max_hp * 0.3)
	game.player.hp = 10.0
	game._step_fountain()
	assert_eq(game.player.hp, 10.0, "the second time nothing")


func test_the_portal_waits_for_the_grace_and_the_passage_is_made_once() -> void:
	await _into_atrio()
	var r := game.rooms
	assert_false(r.take_portal(), "shut before the choice")
	assert_eq(r.regions.index, 0)
	assert_true(r.take_grace(Atrio.Grace.HEAL))
	assert_false(r.take_grace(Atrio.Grace.HEAL), "one Graça only")
	assert_true(r.atrio.portal_open())
	assert_true(r.take_portal())
	assert_eq(r.regions.index, 1)
	assert_eq(r.regions.passages, 1)
	assert_false(r.take_portal(), "the second press does nothing")
	assert_eq(r.regions.passages, 1)


func test_the_grace_heals_a_share_of_the_most_life() -> void:
	await _into_atrio()
	game.player.hp = 20.0
	game.rooms.take_grace(Atrio.Grace.HEAL)
	assert_almost_eq(game.player.hp, minf(20.0 + game.player.max_hp * Atrio.HEAL_SHARE, game.player.max_hp), 0.5)


# ---------- the end of the preview ----------

func test_the_preview_end_is_no_victory() -> void:
	_start()
	var wins := int(Save.data.wins)
	var runs := int(Save.data.runs)
	game.rooms.regions.index = 1
	game.end_preview()
	assert_eq(int(Save.data.wins), wins, "no win added")
	assert_eq(int(Save.data.runs), runs)
	var end := game._screen as EndScreen
	assert_not_null(end)
	assert_not_null(end.find_child("preview", true, false))
	await get_tree().process_frame
	assert_null(end.find_child("again", true, false), "only the way home")
	assert_eq(T.t(&"end_preview"), "Fim da prévia do Capítulo II")
	assert_false(T.t(&"end_preview").contains("—"))
