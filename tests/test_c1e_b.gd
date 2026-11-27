extends GutTest
## C1e, lote B (inimigos_c1e.md): the Saltador (a leap that lands where the paladin was, marked by four corners in L, never a disc) and
## the Lançador (an axe that flies out and back along the same line), the pure rules, the data, the draw by room and the two in play.

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
	rng.seed = 91


func _room() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


func _step(n := 1, keep_hero := true) -> void:
	for i in n:
		if keep_hero:
			game.player.invuln = 0.0
			game.player.hp = game.player.max_hp
		game._step(1.0 / 60.0)


func _spawn(id: StringName, at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), at, false)
	e.armor = 0.0
	return e


# ---------- the pure rules ----------

func test_the_circle_is_hit_by_its_edge_and_not_beyond() -> void:
	var land := Vector2(3, 4)
	assert_true(LeapRules.in_area(land, land, 1.5))
	assert_true(LeapRules.in_area(land, land + Vector2(1.0, -1.0), 1.5), "inside the circle")
	assert_false(LeapRules.in_area(land, land + Vector2(1.4, -1.4), 1.5), "a circle now (Daniel, 2026-11-23), not a square")
	assert_false(LeapRules.in_area(land, land + Vector2(1.7, 0), 1.5))
	assert_true(LeapRules.in_area(land, land + Vector2(1.7, 0), 1.5, 0.3), "the body's margin")
	assert_false(LeapRules.in_area(land, land + Vector2(0, 2.0), 1.5, 0.3))


func test_the_jump_is_straight_and_high_in_the_middle() -> void:
	var a := Vector2(0, 0)
	var b := Vector2(6, 0)
	assert_eq(LeapRules.pos_at(a, b, 0.0, 0.5), a)
	assert_almost_eq(LeapRules.pos_at(a, b, 0.25, 0.5).x, 3.0, 0.001)
	assert_eq(LeapRules.pos_at(a, b, 9.0, 0.5), b)
	assert_almost_eq(LeapRules.height_at(0.0, 0.5), 0.0, 0.001)
	assert_almost_eq(LeapRules.height_at(0.25, 0.5), LeapRules.PEAK, 0.001)
	assert_almost_eq(LeapRules.height_at(0.5, 0.5), 0.0, 0.01)


func test_the_corners_close_on_the_square_and_the_spot_locks_at_the_end() -> void:
	assert_almost_eq(LeapRules.corner_at(0.0, 0.8, 1.5), 1.5 * LeapRules.OPEN, 0.001)
	assert_almost_eq(LeapRules.corner_at(0.8, 0.8, 1.5), 1.5, 0.001)
	assert_lt(LeapRules.corner_at(0.5, 0.8, 1.5), LeapRules.corner_at(0.2, 0.8, 1.5))
	assert_true(LeapRules.follows(0.4, 0.8, 0.3))
	assert_false(LeapRules.follows(0.6, 0.8, 0.3))
	assert_gte(LeapRules.warning(0.8, 0.5), 0.7)


func test_the_axe_turns_short_of_stone_and_lives_out_and_back() -> void:
	assert_eq(ThrowRules.out_range(11.0, 20.0), 11.0)
	assert_almost_eq(ThrowRules.out_range(11.0, 6.0), 6.0 - ThrowRules.EDGE, 0.001)
	assert_eq(ThrowRules.out_range(11.0, 0.2), ThrowRules.MIN_RANGE)
	assert_almost_eq(ThrowRules.turn_age(11.0, 9.0), 11.0 / 9.0, 0.001)
	assert_gt(ThrowRules.life(11.0, 9.0), 2.0 * ThrowRules.turn_age(11.0, 9.0))
	assert_almost_eq(ThrowRules.warn_age(1.2), 0.8, 0.001)
	assert_eq(ThrowRules.warn_age(0.2), 0.0)


# ---------- the data ----------

func test_the_two_are_data_with_the_numbers_of_the_doc() -> void:
	var s := defs[&"saltador"] as EnemyDef
	var l := defs[&"lancador"] as EnemyDef
	for d in [s, l]:
		assert_eq(d.poise, 100.0, "the Quebra cuts it")
		assert_gte(d.attack_windup, 0.6)
		assert_false(d.elite)
		assert_eq(d.elite_version, &"")
		assert_ne(T.t(d.name_key), String(d.name_key))
		assert_ne(T.t(StringName("codex_role_" + String(d.role))), "codex_role_" + String(d.role))
		assert_true(CodexScreen.ENEMIES.has(d.id))
	assert_eq(s.behavior, EnemyDef.Behavior.LEAP)
	assert_eq(s.hp, 175.0)
	assert_eq(s.attack_damage, 9.0)
	assert_eq(s.role, &"leap")
	assert_almost_eq(s.leap_half, 1.8, 0.001, "a red circle of 1.8 m (Daniel, 2026-11-23)")
	assert_eq(s.recover_time, 0.8)
	assert_eq(l.behavior, EnemyDef.Behavior.ARCHER)
	assert_true(l.shot_return)
	assert_eq(l.hp, 150.0)
	assert_eq(l.attack_damage, 7.0)
	assert_eq(l.shot_speed, 9.0)
	assert_eq(l.shot_range, 11.0)
	assert_eq(l.role, &"throw")
	assert_true(l.shot_line, "a line on the floor first")


func test_they_come_from_their_room_and_never_past_20_bodies() -> void:
	var seen := {&"saltador": 0, &"lancador": 0}
	for i in 600:
		var depth := 1 + i % 12
		var f := EncounterGen.generate(stage, depth, defs, rng)
		for id in seen:
			var n := 0
			for k in f.kinds:
				n += int(k == id)
			seen[id] += n
			var from := 3 if id == &"saltador" else 4
			if depth < from:
				assert_eq(n, 0, "%s before its room (%d)" % [id, depth])
		for w: Array in f.waves:
			assert_lte(EncounterGen.bodies(w, defs), 20)
	assert_gt(seen[&"saltador"], 5)
	assert_gt(seen[&"lancador"], 5)


# ---------- in the game ----------

func test_the_saltador_marks_follows_then_lands_where_he_was_and_hurts_there() -> void:
	_room()
	var e := _spawn(&"saltador", Vector2(5.5, 0))
	game.player.pos = Vector2.ZERO
	e.cooldown = 0.0
	var hurts: Array[float] = []
	game.horde.hit_player.connect(func(a: float, _f: Vector2) -> void: hurts.append(a))
	var windup := false
	for i in 120:
		_step()
		if e.state == Enemy.State.WINDUP:
			windup = true
			break
	assert_true(windup, "it winds up at 4 to 7 m")
	# the spot is taken as the wind-up begins and never follows him (Daniel, 2026-11-23), a red circle on the floor
	var held := e.lands_at
	assert_not_null(e.warning, "the red circle")
	assert_almost_eq((e.warning as Ground.Zone).radius, e.def.leap_half, 0.001)
	game.player.pos = Vector2(-4, -3)
	_step(5)
	assert_eq(e.lands_at, held, "never follows")
	var up := false
	for i in 90:
		_step()
		if e.state == Enemy.State.ATTACK:
			up = up or (e.invulnerable and e.y > 0.0)
		if e.state == Enemy.State.RECOVER:
			break
	assert_true(up, "off the floor and untouchable in the air")
	assert_false(e.invulnerable)
	assert_eq(e.y, 0.0)
	assert_lt(e.pos.distance_to(held), 0.6, "it lands on the marked spot")
	assert_eq(hurts.size(), 0, "he had left the square")
	assert_eq(e.state, Enemy.State.RECOVER, "then it rests, low")


func test_standing_in_the_square_takes_the_blow() -> void:
	_room()
	var e := _spawn(&"saltador", Vector2(5.5, 0))
	e.cooldown = 0.0
	var hurts: Array[float] = []
	game.horde.hit_player.connect(func(a: float, _f: Vector2) -> void: hurts.append(a))
	for i in 240:
		_step()
		if e.state == Enemy.State.RECOVER:
			break
	assert_eq(e.state, Enemy.State.RECOVER)
	assert_eq(hurts.size(), 1, "he stood still in the square")


func test_a_cut_wind_up_never_lands() -> void:
	_room()
	var e := _spawn(&"saltador", Vector2(5.5, 0))
	e.cooldown = 0.0
	for i in 120:
		_step()
		if e.state == Enemy.State.WINDUP:
			break
	assert_true(game.horde.interrupt(e))
	assert_ne(e.state, Enemy.State.ATTACK)
	assert_false(e.invulnerable)


func test_the_axe_goes_out_turns_and_comes_back_hurting_each_way() -> void:
	_room()
	game.player.pos = Vector2(5, 0)
	var origin := Vector2(0, 0)
	game.horde.acting = &"lancador"
	var s := game.projectiles.fire(Projectiles.Kind.ORB, origin, Vector2.RIGHT, 9.0, 9.0, 0.5, ThrowRules.life(11.0, 9.0))
	game.horde.acting = &""
	s.back_at = ThrowRules.turn_age(11.0, 9.0)
	s.origin = origin
	var hits: Array[float] = []
	game.projectiles.hit_player.connect(func(a: float, _f: Vector2) -> void: hits.append(a))
	var turned := false
	var warned := false
	for i in 400:
		game.player.invuln = 0.0
		game.player.pos = Vector2(5, 0)
		game.projectiles.step(1.0 / 60.0)
		game.ground.step(1.0 / 60.0)
		if s.vel.x < 0.0:
			turned = true
		for z in game.ground.zones:
			if z.kind == Ground.Kind.WARNING:
				warned = true
		if not game.projectiles.shots.has(s):
			break
	assert_true(turned, "it flew back")
	assert_true(warned, "its way back showed a line")
	assert_eq(hits.size(), 2, "once out and once back")
	assert_false(game.projectiles.shots.has(s), "gone when it is home")


func test_the_lancador_throws_an_axe_that_returns() -> void:
	_room()
	var e := _spawn(&"lancador", Vector2(7, 0))
	e.cooldown = 0.0
	var back := false
	var fired := false
	for i in 600:
		_step(1, false)
		game.player.hp = game.player.max_hp
		for s in game.projectiles.shots:
			fired = true
			if s.back_at > 0.0 and s.origin != Vector2.ZERO:
				back = true
		if fired and game.projectiles.shots.is_empty():
			break
	assert_true(fired, "it threw")
	assert_true(back, "an axe that turns")


func test_the_bot_leaves_the_square_it_would_land_in() -> void:
	_room()
	var e := _spawn(&"saltador", Vector2(5.5, 0))
	e.cooldown = 0.0
	for i in 120:
		_step()
		if e.state == Enemy.State.WINDUP and e.state_t > 0.3:
			break
	assert_ne(Bot.leap_escape(game.horde.list, e.lands_at), Vector2.ZERO)
	assert_eq(Bot.leap_escape(game.horde.list, e.lands_at + Vector2(5, 5)), Vector2.ZERO)
