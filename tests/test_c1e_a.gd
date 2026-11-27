extends GutTest
## C1e, lote A (inimigos_c1e.md): the Gritador (a shout that speeds and heals), the Coveiro (runs and raises two weak dead), the
## modifiers Furioso, Detonante and Escoltado, and the draw by band of rooms (new parts only from their room, one a fight, never
## the Coveiro with the swarm, never the parts of the room before, never past 20 bodies).

var stage: StageDef
var defs: Dictionary
var rng: RandomNumberGenerator
var game: Game


func before_each() -> void:
	stage = load("res://data/stages/catacombs.tres")
	defs = {}
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)
	rng = RandomNumberGenerator.new()
	rng.seed = 77


func _room() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


func _step(n := 1) -> void:
	for i in n:
		game.player.invuln = 0.0
		game.player.hp = game.player.max_hp
		game._step(1.0 / 60.0)


func _spawn(id: StringName, at: Vector2, mod: ModDef = null) -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), at, false, mod)
	e.armor = 0.0
	return e


# ---------- the pure rules ----------

func test_pace_adds_a_shout_and_a_modifier() -> void:
	assert_eq(SupportRules.pace(false, 0.3, 0.0), 1.0)
	assert_almost_eq(SupportRules.pace(true, 0.3, 0.0), 1.3, 0.001)
	assert_almost_eq(SupportRules.pace(true, 0.3, 0.25), 1.55, 0.001)
	assert_almost_eq(SupportRules.pace(false, 0.3, 0.25), 1.25, 0.001)


func test_a_shout_heals_a_share_never_past_the_most() -> void:
	assert_almost_eq(SupportRules.healed(50.0, 100.0, 0.1), 60.0, 0.001)
	assert_eq(SupportRules.healed(95.0, 100.0, 0.1), 100.0)


func test_the_dead_never_rise_on_the_paladin() -> void:
	var spots := SupportRules.spots(Vector2(10, 0), Vector2.ZERO, 2, 2.6, 80.0, 3.0)
	assert_eq(spots.size(), 2)
	for at in spots:
		assert_gte(at.distance_to(Vector2.ZERO), 3.0)
		assert_almost_eq(at.distance_to(Vector2(10, 0)), 2.6, 0.001)
	assert_true(SupportRules.spots(Vector2(1, 0), Vector2.ZERO, 2, 1.0, 80.0, 3.0).is_empty(), "too close: none rise")


func test_the_chance_of_a_modifier_is_none_then_10_and_rises() -> void:
	assert_eq(SupportRules.mod_chance(7, 8, 0.1, 0.05), 0.0)
	assert_almost_eq(SupportRules.mod_chance(8, 8, 0.1, 0.05), 0.10, 0.001)
	assert_almost_eq(SupportRules.mod_chance(10, 8, 0.1, 0.05), 0.20, 0.001)
	assert_eq(SupportRules.mod_chance(20, 8, 0.0, 0.05), 0.0, "a stage with no chance has none")
	assert_eq(SupportRules.cross(4).size(), 4)
	assert_true(SupportRules.cross(4)[1].is_equal_approx(Vector2.DOWN))


# ---------- data ----------

func test_the_new_ones_are_data() -> void:
	var g := defs[&"gritador"] as EnemyDef
	var c := defs[&"coveiro"] as EnemyDef
	for d in [g, c]:
		assert_eq(d.behavior, EnemyDef.Behavior.SUPPORT)
		assert_eq(d.per_room, 1)
		assert_eq(d.poise, 100.0, "the Quebra cuts the call")
		assert_gte(d.attack_windup, 0.7, "a warning of 0.7 s or more")
		assert_false(d.elite)
		assert_eq(d.elite_version, &"")
		assert_ne(T.t(d.name_key), String(d.name_key))
	assert_eq(g.hp, 150.0)
	assert_eq(g.shout_radius, 8.0)
	assert_eq(g.shout_time, 8.0)
	assert_almost_eq(g.shout_pace, 0.3, 0.001)
	assert_almost_eq(g.shout_heal, 0.1, 0.001)
	assert_eq(c.raise_count, 2)
	assert_eq(c.raise_max, 4)
	assert_eq(c.raise_kind, &"skeleton_raised")
	assert_gt(c.flee_speed, c.speed)
	assert_true(c.never_with.has(&"swarm"))
	var r := load("res://data/enemies/skeleton_raised.tres") as EnemyDef
	assert_eq(r.hp, 20.0, "a Snake of SWORN")
	assert_eq(r.attack_damage, 3.0)
	assert_eq(r.role, &"", "never drawn into a fight")
	for role in [&"rally", &"grave"]:
		assert_ne(T.t(StringName("codex_role_" + String(role))), "codex_role_" + String(role))
	assert_true(CodexScreen.ENEMIES.has(&"gritador"))
	assert_true(CodexScreen.ENEMIES.has(&"coveiro"))


func test_the_modifiers_are_data_with_a_ring_each() -> void:
	assert_eq(stage.mods.size(), 5)  # (lote C added the Regenerante and the Eco)
	var rings := []
	for id in stage.mods:
		var m := load("res://data/mods/%s.tres" % id) as ModDef
		assert_not_null(m, String(id))
		assert_ne(T.t(m.name_key), String(m.name_key))
		assert_false(rings.has(m.ring), "one colour a modifier")
		rings.append(m.ring)
	var det := load("res://data/mods/detonante.tres") as ModDef
	assert_eq(det.burst_arms, 4)
	assert_eq(det.burst_damage, 8.0)
	assert_gte(det.burst_time, 0.7)
	assert_eq((load("res://data/mods/escoltado.tres") as ModDef).escort_count, 2)
	assert_almost_eq((load("res://data/mods/furioso.tres") as ModDef).attack_pace, 0.25, 0.001)
	assert_eq(stage.mod_from_depth, 8)
	assert_eq(stage.mod_per_room, 2)


# ---------- the draw by band of rooms ----------

func _count(f: EncounterGen.Fight, id: StringName) -> int:
	var n := 0
	for w: Array in f.waves:
		n += w.count(id)
	return n


func test_the_new_parts_come_only_from_their_room_and_one_a_fight() -> void:
	var seen := {&"gritador": 0, &"coveiro": 0}
	for i in 600:
		var depth := 1 + i % 12
		var f := EncounterGen.generate(stage, depth, defs, rng)
		for id in [&"gritador", &"coveiro"]:
			var n := _count(f, id)
			seen[id] += n
			assert_lte(n, 1, "one a fight (per_room)")
			if depth < (6 if id == &"gritador" else 8):
				assert_eq(n, 0, "%s before its room (%d)" % [id, depth])
		assert_false(f.kinds.has(&"gritador") and f.kinds.has(&"coveiro"), "one new part of the band a fight")
		if f.kinds.has(&"coveiro"):
			assert_false(f.kinds.has(&"trinca") or f.kinds.has(&"trinca_elite"), "never the Coveiro with the swarm")
		var bodies := 0
		for w: Array in f.waves:
			bodies = maxi(bodies, EncounterGen.bodies(w, defs))
		assert_lte(bodies, 20, "never past 20 bodies")
	assert_gt(seen[&"gritador"], 5, "it does come")
	assert_gt(seen[&"coveiro"], 5, "it does come")


func test_a_fight_does_not_repeat_the_parts_of_the_room_before() -> void:
	var repeats := 0
	var drawn := 0
	for i in 300:
		var depth := 2 + i % 10
		var first := EncounterGen.generate(stage, depth - 1, defs, rng)
		var avoid := EncounterGen.roles_of(first.kinds, defs)
		var next := EncounterGen.generate(stage, depth, defs, rng, 1.0, null, avoid)
		drawn += 1
		if EncounterGen.same_parts(EncounterGen.roles_of(next.kinds, defs), avoid):
			repeats += 1
	assert_lt(repeats, drawn / 20, "a repeat only when the draw has no other way (%d of %d)" % [repeats, drawn])


func test_modifiers_none_before_room_8_two_at_most_never_on_elites_or_bigger_ones() -> void:
	var total := 0
	for i in 500:
		var depth := 1 + i % 12
		var f := EncounterGen.generate(stage, depth, defs, rng)
		var n := 0
		for id: StringName in f.mods:
			var d := defs[id] as EnemyDef
			assert_false(d.elite or d.big or d.group > 1 or d.per_room > 0, "a plain common head only: %s" % id)
			n += (f.mods[id] as Array).size()
		if depth < 8:
			assert_eq(n, 0, "none before room 8")
		assert_lte(n, 2)
		total += n
	assert_gt(total, 5, "they do come")


func test_a_room_with_a_hazard_may_have_modifiers() -> void:
	var l := RoomLayout.new()
	l.hazard = HazardDef.new()
	var n := 0
	for i in 200:
		n += EncounterGen.generate(stage, 9 + i % 3, defs, rng, 1.0, l).mods.size()
	assert_gt(n, 0, "almost every arena has one: the modifiers must come there")


# ---------- in the game ----------

func test_a_shout_speeds_and_heals_the_others_once() -> void:
	_room()
	var g := _spawn(&"gritador", Vector2(8, 0))
	var a := _spawn(&"skeleton", Vector2(10, 0))
	var far := _spawn(&"skeleton", Vector2(-25, 0))
	a.hp = a.max_hp * 0.5
	var before := a.hp
	g.cooldown = 0.0
	var speed := game.horde._speed(a)
	var seen_windup := false
	for i in 120:
		_step()
		seen_windup = seen_windup or g.state == Enemy.State.WINDUP
		if a.haste_t > 0.0:
			break
	assert_true(seen_windup, "it is warned first")
	assert_gt(a.haste_t, 7.0, "8 s of haste")
	assert_almost_eq(game.horde._speed(a), speed * 1.3, 0.001)
	assert_almost_eq(a.hp - before, a.max_hp * 0.1, 0.5, "10% of the life, once")
	assert_eq(far.haste_t, 0.0, "past the 8 m nothing")
	assert_lt(g.cooldown, 9.0 * 1.2 + 0.1)
	assert_gt(g.cooldown, 5.0, "the next shout is far off")


func test_a_cut_call_never_lands() -> void:
	_room()
	var g := _spawn(&"gritador", Vector2(8, 0))
	var a := _spawn(&"skeleton", Vector2(10, 0))
	g.cooldown = 0.0
	for i in 60:
		_step()
		if g.state == Enemy.State.WINDUP:
			break
	assert_eq(g.state, Enemy.State.WINDUP)
	assert_true(game.horde.interrupt(g))
	_step(60)
	assert_eq(a.haste_t, 0.0)


func test_the_gritador_runs_from_the_paladin_and_never_strikes() -> void:
	_room()
	var g := _spawn(&"gritador", Vector2(1.5, 0))
	g.cooldown = 99.0
	var d0 := g.pos.distance_to(game.player.pos)
	for i in 60:
		_step()
	assert_gt(g.pos.distance_to(game.player.pos), d0 + 0.3, "it ran")
	assert_gte(g.pos.distance_to(game.player.pos), 1.9, "to its 2 m and no farther")
	assert_eq(g.state, Enemy.State.WALK)


func test_the_coveiro_raises_two_weak_dead_away_from_the_paladin_up_to_four() -> void:
	_room()
	var c := _spawn(&"coveiro", Vector2(9, 0))
	var marks := 0
	for round in 5:
		c.cooldown = 0.0
		for i in 150:
			_step()
			c.pos = Vector2(9, 0)  # (held: the test is of the call, not of the run)
			if c.state == Enemy.State.WINDUP and c.spots.size() > 0:
				marks = maxi(marks, c.spots.size())
				for at in c.spots:
					assert_gte(at.distance_to(game.player.pos), 3.0, "marked 3 m from him at least")
	assert_eq(marks, 2, "two spots marked on the floor")
	var dead := game.horde.list.filter(func(e: Enemy) -> bool: return e.def.id == &"skeleton_raised" and e.alive)
	assert_gt(dead.size(), 0)
	assert_lte(dead.size(), 4, "never more than 4 of its own")
	for e: Enemy in dead:
		assert_eq(e.max_hp, 20.0 * game.horde.hp_scale * game.horde.vow_hp)


func test_the_dead_wait_for_room_under_the_ceiling() -> void:
	_room()
	game.horde.alive_cap = 3
	var c := _spawn(&"coveiro", Vector2(9, 0))
	_spawn(&"skeleton", Vector2(20, 5))
	c.cooldown = 0.0
	for i in 200:
		_step()
		c.pos = Vector2(9, 0)
	assert_lte(game.horde.count(), 3)


func test_furioso_comes_back_faster_and_keeps_its_warning() -> void:
	_room()
	var m := load("res://data/mods/furioso.tres") as ModDef
	var plain := _spawn(&"skeleton", Vector2(30, 0))
	var wild := _spawn(&"skeleton", Vector2(30, 5), m)
	plain.cooldown = 10.0
	wild.cooldown = 10.0
	game.horde._timers(plain, 1.0)
	game.horde._timers(wild, 1.0)
	assert_almost_eq(plain.cooldown, 9.0, 0.001)
	assert_almost_eq(wild.cooldown, 8.75, 0.001)
	assert_eq(wild.def.attack_windup, plain.def.attack_windup, "the warning is the kind's")
	assert_gte(wild.def.attack_windup, 0.6)


func test_escoltado_is_born_with_two_dead_round_it() -> void:
	_room()
	var m := load("res://data/mods/escoltado.tres") as ModDef
	var e := _spawn(&"skeleton", Vector2(12, 0), m)
	assert_eq(e.raised.size(), 2)
	assert_eq(game.horde.count(), 3)
	for r in e.raised:
		assert_eq(r.def.id, &"skeleton_raised")
	game.horde.alive_cap = 4
	var f := _spawn(&"skeleton", Vector2(-12, 0), m)
	assert_eq(f.raised.size(), 0 if game.horde.count() >= 4 else mini(2, 4 - 3), "under the ceiling")
	assert_lte(game.horde.count(), 4)


func test_detonante_leaves_four_lances_in_a_cross_warned() -> void:
	_room()
	var m := load("res://data/mods/detonante.tres") as ModDef
	var e := _spawn(&"skeleton", Vector2(12, 0), m)
	var zones := game.ground.zones.size()
	game.horde.damage(e, e.hp + e.armor + 1.0, Vector2.RIGHT, 0.0, Fx.GOLD, false, true)
	assert_eq(game.ground.zones.size() - zones, 4)
	var lines := game.ground.zones.filter(func(z: Ground.Zone) -> bool: return z.shape == Ground.Shape.LINE and z.pos.distance_to(Vector2(12, 0)) < 0.1)
	assert_eq(lines.size(), 4)
	for z: Ground.Zone in lines:
		assert_gte(z.total, 0.7, "warned 0.7 s")
		assert_almost_eq(z.power, 8.0 * game.horde._out(e), 0.01)
