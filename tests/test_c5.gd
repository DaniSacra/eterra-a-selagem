extends GutTest
## Lote C5 (CB-7, Daniel's names): the Trinca (three figures that rise again while another stands), the Varredor (a bar
## swung round its root, harmless at its feet), their place in the fights, and Morvath's curse at 55 degrees and 0.9 s.

var game: Game
var hits: Array[float] = []


func _room() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	hits.clear()
	game.ground.hit_player.connect(func(_a: float, _f: Vector2) -> void: hits.append(game.time))
	game.horde.hit_player.connect(func(_a: float, _f: Vector2) -> void: hits.append(game.time))


func _step(n := 1) -> void:
	for i in n:
		game.player.invuln = 0.0
		game.player.hp = game.player.max_hp
		game._step(1.0 / 60.0)


func _kill(e: Enemy) -> bool:
	return game.horde.damage(e, e.hp + e.armor + 1.0, Vector2.RIGHT, 0.0, Fx.GOLD, false, true)


func _trinca(id: StringName = &"trinca") -> Array[Enemy]:
	var out := game.horde.spawn_group(game.horde.def(id), Vector2(8, 0), false)
	for e in out:
		e.armor = 0.0
	return out


# ---------- the pure rules ----------

func test_the_bar_starts_behind_the_paladin_and_turns_the_way_shown() -> void:
	var toward := Vector2.RIGHT
	for way in [1.0, -1.0]:
		var start := SweepRules.start_dir(toward, way)
		assert_almost_eq(absf(start.angle_to(toward)), deg_to_rad(SweepRules.LEAD_DEGREES), 0.001)
		var later := SweepRules.dir_at(start, way, 200.0, 1.6, 0.8)
		assert_almost_eq(start.angle_to(later), way * deg_to_rad(100.0), 0.001, "half the time, half the turn")
		var past := SweepRules.dir_at(start, way, 200.0, 1.6, 9.0)
		assert_true(past.is_equal_approx(start.rotated(way * deg_to_rad(200.0))), "never past its turn")
		# the first spot he stood at is crossed after LEAD_DEGREES of the turn: 0.56 s, time to walk or dash
		assert_gt(SweepRules.LEAD_DEGREES / (200.0 / 1.6), 0.45)


func test_the_bar_does_not_hurt_at_its_feet_nor_past_its_reach() -> void:
	var root := Vector2(2, 2)
	var dir := Vector2.RIGHT
	assert_true(SweepRules.in_bar(root, dir, root + Vector2(3.0, 0.4), 5.5, 1.1, 1.6))
	assert_false(SweepRules.in_bar(root, dir, root + Vector2(1.5, 0.0), 5.5, 1.1, 1.6), "within 1.6 m of the Varredor")
	assert_false(SweepRules.in_bar(root, dir, root + Vector2(5.6, 0.0), 5.5, 1.1, 1.6), "past 5.5 m")
	assert_false(SweepRules.in_bar(root, dir, root + Vector2(3.0, 0.8), 5.5, 1.1, 1.6), "past half of 1.1 m across")
	assert_false(SweepRules.in_bar(root, dir, root - Vector2(3.0, 0.0), 5.5, 1.1, 1.6), "behind it")


func test_the_triangle_has_three_corners_apart_and_turns() -> void:
	var c := Vector2(1, 1)
	var a := TrioRules.slot_pos(c, 0.0, 0, 3, 0.0, 2.0)
	var b := TrioRules.slot_pos(c, 0.0, 1, 3, 0.0, 2.0)
	var d := TrioRules.slot_pos(c, 0.0, 2, 3, 0.0, 2.0)
	assert_almost_eq(a.distance_to(c), 2.0, 0.001)
	assert_almost_eq(a.distance_to(b), b.distance_to(d), 0.001, "an equal triangle")
	assert_almost_eq(b.distance_to(d), d.distance_to(a), 0.001)
	assert_false(TrioRules.slot_pos(c, 6.0, 0, 3, 0.0, 2.0).is_equal_approx(a), "it turns round him")
	assert_false(TrioRules.may_rise(3.4, 3.5, 2))
	assert_true(TrioRules.may_rise(3.5, 3.5, 1))
	assert_false(TrioRules.may_rise(9.0, 3.5, 0), "none left standing: none rises")


# ---------- the data ----------

func test_the_two_new_enemies_are_data_with_their_elites() -> void:
	var t: EnemyDef = load("res://data/enemies/trinca.tres")
	assert_eq(t.model, &"trio")
	assert_almost_eq(t.size, 0.85, 0.001)
	assert_eq(t.group, 3)
	assert_almost_eq(t.rise_time, 3.5, 0.001)
	assert_eq(t.max_attackers, 1, "one blow at a time")
	assert_eq(t.role, &"swarm")
	assert_eq(t.elite_version, &"trinca_elite")
	assert_true((load("res://data/enemies/trinca_elite.tres") as EnemyDef).elite)
	assert_eq((load("res://data/enemies/trinca_elite.tres") as EnemyDef).group, 4)
	var v: EnemyDef = load("res://data/enemies/varredor.tres")
	assert_eq(v.behavior, EnemyDef.Behavior.SWEEP)
	assert_eq(v.model, &"sweeper")
	assert_almost_eq(v.attack_range, 5.5, 0.001)
	assert_almost_eq(v.attack_width, 1.1, 0.001)
	assert_almost_eq(v.sweep_degrees, 200.0, 0.001)
	assert_almost_eq(v.sweep_time, 1.6, 0.001)
	assert_almost_eq(v.attack_windup, 0.72, 0.001)
	assert_almost_eq(v.sweep_clear, 1.6, 0.001)
	assert_almost_eq(v.recover_time, 1.4, 0.001, "its rest")
	assert_eq(v.per_room, 1)
	assert_eq(v.role, &"sweep")
	assert_eq(v.elite_version, &"varredor_elite")
	assert_true((load("res://data/enemies/varredor_elite.tres") as EnemyDef).elite)
	assert_eq(T.t(&"enemy_trinca"), "Trinca")
	assert_eq(T.t(&"enemy_varredor"), "Varredor")
	for id in [&"codex_role_swarm", &"codex_role_sweep"]:
		assert_ne(T.t(id), String(id))
		assert_false(T.t(id).contains("—"), "no dash")
	for id in [&"trio", &"sweeper"]:
		assert_true(ResourceLoader.exists("res://assets/baked/%s.res" % id))


func test_morvaths_curse_turns_less_and_for_less_time() -> void:
	var b: BossDef = load("res://data/bosses/morvath.tres")
	assert_almost_eq(b.curse_turn, 55.0, 0.001)
	assert_almost_eq(b.curse_homing, 0.9, 0.001)


# ---------- the fights ----------

func _defs(stage: StageDef) -> Dictionary:
	var defs := {}
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)
	return defs


func test_they_come_after_the_sixth_room_and_in_a_part_of_their_own() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	assert_true(stage.enemies.has(&"trinca") and stage.enemies.has(&"varredor_elite"))
	var sixth := EncounterGen.progress(stage, 6)
	var seventh := EncounterGen.progress(stage, 7)
	var seen := {}
	var first := 1.0
	for pool in stage.pools:
		for role: StringName in [&"swarm", &"sweep"]:
			if pool.roles.has(role):
				seen[role] = true
				first = minf(first, pool.from)
				assert_gt(pool.from, sixth, "not before the 7th room")
	assert_lte(first, seventh + 0.001, "they are there from the 7th")
	assert_eq(seen.size(), 2)


func test_never_two_varredores_nor_more_than_20_bodies_in_500_fights() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var defs := _defs(stage)
	var rng := RandomNumberGenerator.new()
	rng.seed = 55
	var with_trinca := 0
	var with_sweeper := 0
	for i in 500:
		var depth := rng.randi_range(7, 12)
		var fight := EncounterGen.generate(stage, depth, defs, rng)
		var sweepers := 0
		var trincas := 0
		for w in fight.waves:
			assert_lte(EncounterGen.bodies(w, defs), stage.alive_cap, "a wave never holds more bodies than the ceiling")
			for id: StringName in w:
				if (defs[id] as EnemyDef).role == &"sweep":
					sweepers += 1
				if (defs[id] as EnemyDef).role == &"swarm":
					trincas += 1
		assert_lte(sweepers, 1, "one Varredor a fight")
		with_trinca += int(trincas > 0)
		with_sweeper += int(sweepers > 0)
	assert_gt(with_trinca, 20, "they do come")
	assert_gt(with_sweeper, 20)


func test_a_head_of_a_trinca_counts_as_its_bodies_in_a_wave() -> void:
	var defs := {"trinca": load("res://data/enemies/trinca.tres"), "skeleton": load("res://data/enemies/skeleton.tres"),
		"trinca_elite": load("res://data/enemies/trinca_elite.tres")}
	assert_eq(EncounterGen.bodies([&"trinca", &"skeleton", &"skeleton"], defs), 5)
	assert_eq(EncounterGen.bodies([&"trinca_elite", &"trinca"], defs), 7)
	var waves: Array[Array] = [[&"skeleton"], [&"skeleton"]]
	var kinds: Array[StringName] = [&"skeleton"]
	EncounterGen.limit_per_room(waves, kinds, defs)
	assert_eq(waves[0].size() + waves[1].size(), 2, "kinds without a limit are left alone")


func test_the_chain_room_never_has_the_varredor() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var found := false
	for l in stage.layouts:
		if l.id == &"bridge":
			found = true
			assert_true(l.banned_roles.has(&"sweep"), "RP-11's chain and the Varredor's bar never share a room")
	assert_true(found)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var defs := _defs(stage)
	for l in stage.layouts:
		if l.id != &"bridge":
			continue
		for i in 300:
			var fight := EncounterGen.generate(stage, rng.randi_range(7, 12), defs, rng, 1.0, l)
			for id in fight.kinds:
				assert_ne((defs[id] as EnemyDef).role, &"sweep")


# ---------- the Trinca in the game ----------

func test_a_felled_figure_lies_hurt_by_nothing_and_rises_while_another_stands() -> void:
	_room()
	var three := _trinca()
	assert_eq(three.size(), 3)
	assert_eq(game.horde.count(), 3, "it counts as three of the standing")
	var a := three[0]
	assert_false(_kill(a), "it did not die")
	assert_true(a.alive)
	assert_eq(a.state, Enemy.State.DOWN)
	assert_true(a.invulnerable)
	assert_eq(game.horde.count(), 3)
	var hp := a.hp
	game.horde.damage(a, 50.0, Vector2.RIGHT, 0.0)
	assert_eq(a.hp, hp, "a mound takes nothing")
	_step(int(3.4 * 60.0))
	assert_eq(a.state, Enemy.State.DOWN, "not before 3.5 s")
	_step(int(0.3 * 60.0))
	assert_ne(a.state, Enemy.State.DOWN, "it rises at 3.5 s")
	assert_false(a.invulnerable)
	assert_almost_eq(a.hp, a.max_hp, 0.01)


func test_all_three_on_the_floor_is_the_end() -> void:
	_room()
	var three := _trinca()
	assert_false(_kill(three[0]))
	assert_false(_kill(three[1]))
	assert_true(_kill(three[2]), "the last one standing is felled for good")
	_step(3)
	assert_eq(game.horde.count(), 0, "and the two mounds go with it")
	assert_false(three[0].alive)
	assert_false(three[1].alive)


func test_a_mound_that_rose_stands_again_and_the_elite_is_four() -> void:
	_room()
	var four := _trinca(&"trinca_elite")
	assert_eq(four.size(), 4)
	assert_eq(game.horde.count(), 4)
	_kill(four[0])
	_kill(four[1])
	_kill(four[2])
	assert_true(four[3].alive and four[3].state != Enemy.State.DOWN)
	_step(int(3.8 * 60.0))
	var down := 0
	for e in four:
		down += int(e.state == Enemy.State.DOWN)
	assert_eq(down, 0, "all three rose while the fourth stood")


func test_the_figures_pounce_one_at_a_time() -> void:
	_room()
	var three := _trinca()
	for e in three:
		e.pos = game.arena.resolve(Vector2(4, 0) + Vector2.from_angle(randf() * TAU), 0.5)
		e.cooldown = 0.0
	var most := 0
	for i in 600:
		_step()
		var n := 0
		for e in three:
			n += int(e.state == Enemy.State.WINDUP or e.state == Enemy.State.ATTACK)
		most = maxi(most, n)
	assert_eq(most, 1, "never two blows at once")


func test_the_figures_keep_the_corners_of_a_triangle_while_they_wait() -> void:
	_room()
	var three := _trinca()
	for e in three:
		e.cooldown = 99.0
	_step(60 * 8)
	var spread := 0.0
	for e in three:
		assert_lt(e.pos.distance_to(game.player.pos), 4.0, "they closed in")
		for o in three:
			spread = maxf(spread, e.pos.distance_to(o.pos))
	assert_gt(spread, 1.8, "apart round him, not in a heap")


# ---------- the Varredor in the game ----------

func _sweeper_at(gap: float, id: StringName = &"varredor") -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(game.player.pos + Vector2(gap, 0), 0.6), false)
	e.armor = 0.0
	e.cooldown = 0.0
	return e


func test_the_varredor_shows_the_bar_and_its_way_then_sweeps_once() -> void:
	_room()
	game.player.pos = Vector2(-3, 0)
	var e := _sweeper_at(3.0)
	e.pos = Vector2.ZERO
	game.horde.target = game.player.pos
	var d := e.def
	_step()
	assert_eq(e.state, Enemy.State.WINDUP)
	var bar := e.warning as Ground.Zone
	var way := e.warning2 as Ground.Zone
	assert_not_null(bar)
	assert_not_null(way, "a thread ahead of the bar tells the way it will turn")
	assert_almost_eq(bar.radius, 5.5, 0.001)
	assert_almost_eq(bar.width, 1.1, 0.001)
	assert_almost_eq(bar.total, d.attack_windup, 0.05, "0.9 s of wind-up")
	assert_gt(absf(bar.dir.angle_to(way.dir)), deg_to_rad(20.0))
	assert_eq(bar.power, 0.0, "the warning hurts nothing: the swept bar does")
	assert_eq(hits.size(), 0)
	while e.state == Enemy.State.WINDUP:
		_step()
	assert_eq(e.state, Enemy.State.ATTACK)
	var swing := 0.0
	var n := 0
	while e.state == Enemy.State.ATTACK and n < 200:
		swing = e.state_t
		_step()
		n += 1
	assert_almost_eq(swing, 1.6, 0.03, "200 degrees in 1.6 s")
	assert_eq(e.state, Enemy.State.RECOVER)
	assert_lte(hits.size(), 1, "the bar hurts once a sweep")


func test_the_bar_catches_him_in_its_path_but_not_at_the_varredors_feet() -> void:
	# the same sweep, once with him 4 m out and once 1.0 m from it
	for gap in [4.0, 1.0]:
		_room()
		var e := _sweeper_at(gap)
		e.pos = Vector2(gap, 0)
		game.horde.target = game.player.pos
		for i in 60 * 4:
			game.player.pos = Vector2.ZERO
			_step()
			if e.state == Enemy.State.RECOVER:
				break
		if gap > 2.0:
			assert_eq(hits.size(), 1, "4 m out the bar comes round to him")
		else:
			assert_eq(hits.size(), 0, "at its feet nothing hurts")


func test_a_varredor_felled_mid_sweep_takes_its_bar_with_it() -> void:
	_room()
	game.player.pos = Vector2(-3, 0)
	var e := _sweeper_at(3.0)
	e.pos = Vector2.ZERO
	game.horde.target = game.player.pos
	while e.state != Enemy.State.ATTACK:
		_step()
	var bar := e.warning as Ground.Zone
	assert_not_null(bar)
	_kill(e)
	_step(3)
	assert_false(game.ground.zones.has(bar), "no bar stays lit on the floor")
