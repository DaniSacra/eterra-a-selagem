extends GutTest
## SW-REA (docs/design/sworn_rea_butcher_2026-11-25.md): the Cavaleiro's phases by life, the guard by time with a reach and a
## still tail, the roar, and the shorter recoveries of everyone.

func _game() -> Game:
	var game := (load("res://scenes/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	return game


func _knight(game: Game, at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(&"knight"), at, false)
	e.cooldown = 99.0
	e.rows = 0
	return e


func test_rules_are_pure() -> void:
	var marks := PackedFloat32Array([0.8, 0.4])
	assert_eq(KnightPhase.crossed(marks, 1.0), 0)
	assert_eq(KnightPhase.crossed(marks, 0.8), 1)
	assert_eq(KnightPhase.crossed(marks, 0.39), 2)
	assert_false(KnightPhase.roar_due(marks, 0, 0.9))
	assert_true(KnightPhase.roar_due(marks, 0, 0.7))
	assert_false(KnightPhase.roar_due(marks, 1, 0.7))
	assert_true(KnightPhase.roar_due(marks, 1, 0.3))
	assert_true(KnightPhase.guard_open(0.8, 6.0, 0.7, 5.0))
	assert_false(KnightPhase.guard_open(0.8, 6.0, 0.9, 5.0), "life over its band")
	assert_false(KnightPhase.guard_open(0.8, 6.0, 0.7, 7.0), "the paladin too far")
	assert_true(KnightPhase.guard_open(1.0, 0.0, 1.0, 30.0), "no gates")


func test_data_is_the_butchers() -> void:
	var d := load("res://data/enemies/knight.tres") as EnemyDef
	assert_eq(d.hp, 3000.0, "SWORN's Questing Beast")
	assert_eq(d.armor, 0.0, "no yellow bar")
	assert_almost_eq(d.speed, 6.0, 0.02)
	assert_eq(d.attack_windup, 0.65)
	assert_eq(d.lunge_time, 0.3)
	assert_eq(d.recover_time, 0.9)
	assert_eq(d.raise_max, 4)
	assert_gt(d.gap_max, 0.0, "gap_max 0 would bring back AFTER_RECOVER")
	assert_lte(d.gap_max, 0.15)
	assert_eq(d.roar_marks.size(), 2)
	assert_eq(d.guard_up_reach, 6.0)
	assert_eq(d.guard_up_rest, 2.0)
	var charges := 0
	for m in d.moves:
		if m.id == &"charge" and m.from_life >= 1.0:
			charges += int(m.count)
	assert_eq(charges, 1, "the base charge is one at a time")


func test_no_guard_in_the_first_phase_nor_far_away() -> void:
	var game := _game()
	var e := _knight(game, Vector2(3, 0))
	game.player.pos = Vector2.ZERO
	e.guard_cd = 0.0
	for i in 60:
		game._step(1.0 / 60.0)
	assert_ne(e.memo, Horde.KNIGHT_GUARD, "full toughness: no guard by time")
	e.armor = e.max_armor * 0.6
	e.hp = e.max_hp * 0.6
	e.roars = 1
	e.pos = Vector2(8, 0)
	e.guard_cd = 0.0
	e.cooldown = 99.0
	for i in 20:
		game._step(1.0 / 60.0)
	assert_ne(e.memo, Horde.KNIGHT_GUARD, "the paladin beyond 6 m")


func test_roar_at_80_stands_and_is_given_once() -> void:
	var game := _game()
	game.player.pos = Vector2.ZERO
	var e := _knight(game, Vector2(9, 0))
	e.armor = e.max_armor * 0.7
	e.hp = e.max_hp * 0.7
	var roared := false
	for i in 30:
		game._step(1.0 / 60.0)
		if e.memo == Horde.KNIGHT_ROAR:
			roared = true
			break
	assert_true(roared)
	assert_eq(e.roars, 1)
	var at := e.pos
	for i in 60:
		game._step(1.0 / 60.0)
	assert_eq(e.pos, at, "it does not move while it roars")
	for i in 120:
		game._step(1.0 / 60.0)
	assert_ne(e.memo, Horde.KNIGHT_ROAR, "the roar ends by itself")
	assert_eq(e.roars, 1, "no second roar under the same mark")


func test_guard_ends_standing_still() -> void:
	var game := _game()
	game.player.pos = Vector2.ZERO
	var e := _knight(game, Vector2(5, 0))
	e.armor = e.max_armor * 0.7
	e.hp = e.max_hp * 0.7
	e.roars = 1
	e.guard_t = 0.05
	e.guard_cd = 99.0
	for i in 8:
		game._step(1.0 / 60.0)
	assert_gt(e.still_t, 1.0, "2 s standing at the end of the guard")
	var at := e.pos
	for i in 60:
		game._step(1.0 / 60.0)
	assert_eq(e.pos, at)


func test_call_only_from_60_with_a_cooldown() -> void:
	var game := _game()
	game.player.pos = Vector2.ZERO
	var e := _knight(game, Vector2(9, 0))
	e.call_cd = 0.0
	e.move_cd[0] = 99.0
	e.cooldown = 0.0
	for i in 20:
		game._step(1.0 / 60.0)
	assert_ne(e.memo, Horde.KNIGHT_CALLS, "not in the first phases")


func test_recoveries_are_shorter() -> void:
	for pair in [[&"skeleton", 0.75], [&"runner", 0.8], [&"trinca", 0.7], [&"bone_rat", 0.6], [&"skeleton_big", 1.1], [&"runner_big", 1.0],
			[&"varredor", 1.1], [&"capitao", 1.0], [&"saltador", 0.8], [&"mage", 0.65], [&"guard", 1.0]]:
		var d := load("res://data/enemies/%s.tres" % pair[0]) as EnemyDef
		assert_eq(d.recover_time, pair[1], String(pair[0]))
	assert_almost_eq((load("res://data/enemies/guard.tres") as EnemyDef).attack_windup, 0.7, 0.001)
	assert_almost_eq((load("res://data/enemies/skeleton_big.tres") as EnemyDef).attack_windup, 0.7, 0.001)
	var c := load("res://data/enemies/capitao.tres") as EnemyDef
	assert_eq(c.gap_max, 0.8)
	var m := load("res://data/bosses/morvath.tres") as BossDef
	assert_eq(m.gap_max, 0.3)
	assert_eq(m.gap_max0, 0.1)


func test_guard_opens_in_phase_two_within_reach() -> void:
	var game := _game()
	game.player.pos = Vector2.ZERO
	var e := _knight(game, Vector2(5, 0))
	e.roars = 1
	e.hp = e.max_hp * 0.7
	e.armor = e.max_armor * 0.7
	e.guard_cd = 0.0
	var raised := false
	for i in 120:
		game._step(1.0 / 60.0)
		if e.memo == Horde.KNIGHT_GUARD or e.guard_t > 0.0:
			raised = true
			break
	assert_true(raised, "at 70% with the paladin 5 m away it raises its guard")
