extends GutTest
## GF-12 (D-42): a blow stuns a common enemy without armor as in Hades II, per enemy (EnemyDef.stun_time): it stops,
## its wind-up is cut and never lands, its warning on the floor goes. Elites flinch only once their armor is broken,
## the guard's charge in flight is not cut, guardians and Morvath never flinch.

var game: Game
var landed := 0


## One enemy of this kind `gap` meters east of the paladin, in a room with nobody else (the fountain room).
func _alone(id: StringName, gap := 2.2) -> Enemy:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	landed = 0
	game.ground.hit_player.connect(func(_a: float, _f: Vector2) -> void: landed += 1)
	game.horde.hit_player.connect(func(_a: float, _f: Vector2) -> void: landed += 1)
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(game.player.pos + Vector2(gap, 0), 0.6), false)
	e.cooldown = 0.0
	return e


## Steps until the enemy is `t` seconds into a wind-up (false if it never winds up in 4 s).
func _into_windup(e: Enemy, t := 0.15) -> bool:
	for i in 240:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		if e.state == Enemy.State.WINDUP and e.state_t >= t:
			return true
	return false


## Steps `seconds`; returns the states it went through.
func _watch(e: Enemy, seconds: float) -> Array:
	var seen: Array = []
	for i in int(seconds * 60.0):
		game._step(1.0 / 60.0)
		if seen.is_empty() or seen[-1] != e.state:
			seen.append(e.state)
	return seen


func _blow(e: Enemy, amount := 5.0, big := false) -> void:
	game.horde.damage(e, amount, (e.pos - game.player.pos).normalized(), 0.0, Color.WHITE, false, big)


func test_a_skeleton_struck_in_its_windup_does_not_attack() -> void:
	var e := _alone(&"skeleton")
	assert_true(_into_windup(e), "it winds up")
	var warning := e.warning as Ground.Zone
	assert_not_null(warning, "its lunge is marked on the floor")
	game.player.invuln = 0.0
	var hp := game.player.hp
	_blow(e)
	assert_eq(e.state, Enemy.State.WALK, "the wind-up is cut")
	assert_almost_eq(e.stun_t, e.def.stun_time, 0.001, "stunned for its own time")
	assert_true(e.helpless(), "a stunned body does not act")
	assert_true(warning.cancelled, "its warning goes")
	var at := e.pos
	game._step(1.0 / 60.0)
	assert_false(game.ground.zones.has(warning), "gone from the floor on the next step")
	assert_almost_eq(e.pos.distance_to(at), 0.0, 0.05, "it stops walking")
	# the rest of the cut wind-up and the lunge it would have loosed: nothing lands
	var states := _watch(e, e.def.attack_windup - 0.15 + e.def.lunge_time)
	assert_false(states.has(Enemy.State.ATTACK), "the cut blow never comes")
	assert_eq(landed, 0, "nothing hit the paladin")
	assert_eq(game.player.hp, hp)
	assert_eq(game.horde.interrupts, 1)


func test_it_winds_up_again_in_full_after_the_stun() -> void:
	var e := _alone(&"skeleton")
	assert_true(_into_windup(e))
	_blow(e)
	var states := _watch(e, e.def.stun_time + Horde.REARM - 0.05)
	assert_false(states.has(Enemy.State.WINDUP), "E1c: no new wind-up before REARM after the stun (AUDIT.md P5)")
	states = _watch(e, 0.25)
	assert_true(states.has(Enemy.State.WINDUP), "ready again: a new wind-up, announced from its start")
	assert_lt(e.state_t, 0.25, "a fresh wind-up, not the cut one going on")
	assert_not_null(e.warning)


func test_an_elite_struck_in_its_windup_attacks() -> void:
	var e := _alone(&"skeleton_elite")
	assert_eq(e.armor, 0.0, "no yellow bar since 2026-11-27")
	assert_true(_into_windup(e))
	_blow(e, 1.0)
	assert_eq(e.state, Enemy.State.WINDUP, "a blow never flinches an elite: only its Quebra staggers it")
	assert_eq(e.stun_t, 0.0)
	var states := _watch(e, e.def.attack_windup)
	assert_true(states.has(Enemy.State.ATTACK), "its blow comes")
	assert_eq(game.horde.flinches, 0)


func test_a_strong_blow_stuns_longer() -> void:
	var e := _alone(&"skeleton")
	_blow(e, 5.0, true)
	assert_almost_eq(e.stun_t, e.def.stun_heavy_time, 0.001)
	assert_gt(e.def.stun_heavy_time, e.def.stun_time)


func test_the_guard_charge_in_flight_is_not_cut() -> void:
	var e := _alone(&"guard", 6.0)
	assert_true(e.def.stun_immune_attacking)
	e.state = Enemy.State.ATTACK
	e.state_t = 0.1
	e.aim = Vector2.LEFT
	_blow(e)
	assert_eq(e.state, Enemy.State.ATTACK, "the charge goes on")
	assert_eq(e.stun_t, 0.0)
	e.state = Enemy.State.WINDUP
	_blow(e)
	assert_eq(e.state, Enemy.State.WALK, "its wind-up is still cut")


func test_morvath_and_the_guardians_never_flinch() -> void:
	for id: StringName in [&"morvath", &"knight", &"priest_elder"]:
		var e := _alone(id, 6.0)
		e.armor = 0.0
		e.state = Enemy.State.WINDUP
		e.state_t = 0.2
		_blow(e, 5.0, true)
		assert_eq(e.state, Enemy.State.WINDUP, "%s: not cut" % id)
		assert_eq(e.stun_t, 0.0, "%s: not stunned" % id)
		assert_false(game.horde.flinch(e, e.def.stun_time), "%s: stun_time 0" % id)


func test_a_burn_tick_or_a_zone_does_not_flinch() -> void:
	var e := _alone(&"skeleton")
	assert_true(_into_windup(e))
	game.horde.damage(e, 2.0, Vector2.ZERO, 0.0)  # a zone's tick: no direction
	game.horde.damage(e, 2.0, Vector2.RIGHT, 0.0, Color.WHITE, false, false, false)  # a burn's tick: no flash
	assert_eq(e.state, Enemy.State.WINDUP)


func test_every_common_flinches_and_no_boss_or_guardian_does() -> void:
	for f in DirAccess.get_files_at("res://data/enemies/"):
		if not f.ends_with(".tres"):
			continue
		var d: EnemyDef = load("res://data/enemies/" + f)
		var common := (d.role != &"" and not d.elite) or d.id == &"skeleton_raised"  # the Coveiro's dead flinch like the skeleton; an elite only staggers by its Quebra
		if common:
			assert_gt(d.stun_time, 0.0, "%s flinches" % d.id)
			assert_gte(d.stun_heavy_time, d.stun_time, "%s: a strong blow at least as long" % d.id)
		else:
			assert_eq(d.stun_time, 0.0, "%s never flinches" % d.id)
			assert_eq(d.stun_heavy_time, 0.0, "%s never flinches" % d.id)


func test_a_broken_quebra_cuts_the_elites_wind_up() -> void:
	var e := _alone(&"skeleton_elite")
	assert_true(_into_windup(e))
	var warning := e.warning as Ground.Zone
	e.poise = 0.01
	game.horde.dealing = &"attack"
	game.horde.damage(e, 5.0, Vector2.RIGHT, 0.0)
	assert_eq(e.state, Enemy.State.WALK, "the stagger of the break is a stun")
	assert_gte(e.stun_t, e.def.poise_stun - 0.001)
	assert_true(warning.cancelled)
