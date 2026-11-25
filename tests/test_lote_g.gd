extends GutTest
## Lote G (2026-11-25): the rupture has a name (G-1), the spin is not cut before it lands (G-2), the finisher's death is
## heavier (G-3), every --start= begins on full life (G-4).


func test_every_source_morvath_sets_has_a_cause_and_a_name() -> void:
	# G-1 (QA2-04): the Ruptura laid its zone as "rupture", which DefeatCause did not know ("unknown" in RoomTally)
	for id: StringName in [&"scythe", &"reap", &"blades", &"storm", &"barrage", &"eruptions", &"ritual", &"rupture", &"curse", &"dash"]:
		var cause := DefeatCause.of(id, &"")
		assert_eq(DefeatCause.key(cause), String(id), "%s is counted by its own name" % id)
		assert_true(T.t(DefeatCause.text_key(cause)) != String(DefeatCause.text_key(cause)), "%s has a text" % id)
	assert_eq(DefeatCause.key(DefeatCause.of(&"", &"")), "unknown")


func test_boss_sources_in_the_code_are_all_known() -> void:
	var src := FileAccess.get_file_as_string("res://scripts/game/boss.gd")
	var re := RegEx.create_from_string("source = (?:&\"([a-z_]+)\")")
	for m in re.search_all(src):
		var id := StringName(m.get_string(1))
		if id == &"adds":
			continue  # his dead: the kind of the dead names it
		assert_true(DefeatCause.BOSS_ATTACKS.has(id), "%s is a known boss attack" % id)


## G-2 was undone by SW-C1 (2026-11-25, approved by Daniel): the dodge cuts any blow, the spin's windup too.
func test_the_dodge_cuts_the_spin_in_its_windup_since_sw_c1() -> void:
	var runner := ComboRunner.new(load("res://data/combos/paladin.tres") as ComboTree)
	var L := ComboNode.In.LIGHT
	var hit_by: Array[StringName] = []
	runner.move_hit.connect(func(n: ComboNode) -> void: hit_by.append(n.id))
	for i in 2:
		runner.press(L)
		runner.step(0.0)
		assert_true(runner.can_cancel(), "blows 1 and 2 are cut in their windup")
		var t := 0.0
		while t < runner.node.duration() + 0.01:
			runner.step(1.0 / 120.0)
			t += 1.0 / 120.0
	runner.press(L)
	runner.step(0.0)
	assert_eq(runner.node.id, &"cut3")
	assert_eq(runner.phase, ComboRunner.Phase.WINDUP)
	assert_true(runner.can_cancel(), "the spin's windup is cut by the dodge (SW-C1)")
	var steps := 0
	while runner.phase == ComboRunner.Phase.WINDUP and steps < 400:
		runner.step(1.0 / 120.0)
		steps += 1
	assert_true(hit_by.has(&"cut3"), "it landed")
	assert_true(runner.can_cancel(), "from the blow on, its recovery is cut by the dodge")


func test_a_finisher_death_is_thrown_farther_and_gone_sooner() -> void:
	assert_almost_eq(DeathWeight.push(8.0, true), 12.0, 0.001, "1.5 times")
	assert_almost_eq(DeathWeight.push(8.0, false), 8.0, 0.001, "blow 1 keeps it")
	assert_almost_eq(DeathWeight.show_time(true), 0.35, 0.001)
	assert_almost_eq(DeathWeight.show_time(false), Horde.DEATH_SHOW, 0.001)
	assert_lt(DeathWeight.dissolve_from(true), DeathWeight.show_time(true))


func test_the_body_remembers_how_it_fell() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	var shown := {}
	for big in [false, true]:
		var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3, 0), false)
		game.horde.damage(e, 9999.0, Vector2.RIGHT, 8.0, Fx.GOLD, false, big)
		shown[big] = e.death_show
	assert_almost_eq(float(shown[false]), Horde.DEATH_SHOW, 0.001)
	assert_almost_eq(float(shown[true]), 0.35, 0.001)


func test_every_start_begins_on_full_life() -> void:
	for kind in Game.ROOM_STARTS.values():
		var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
		add_child_autofree(game)
		await game.rooms.start_at(kind)
		assert_eq(game.player.hp, game.player.max_hp, "start %s on full life" % kind)
		game.queue_free()
