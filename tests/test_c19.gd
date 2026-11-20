extends GutTest
## C19 "Variedade do combate e da descida" (docs/backlog.md; cadence criteria in docs/design/combat_cadence.md 8.2):
## the soldier elite's two blades and the runner elite's double burst (EnemyDef.strikes, strike_gap: data), Morvath's
## Double Reap close in, the Omega charging at Hades II's numbers, the threads of the mage's orb and the elder's fan,
## and the use button at rewards, shop items and doors (Q-13).

var game: Game
var hits: Array[float] = []


## One enemy of this kind `gap` meters east of the paladin, alone in the fountain room, its armor gone.
func _alone(id: StringName, gap := 2.2) -> Enemy:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	hits.clear()
	game.ground.hit_player.connect(func(_a: float, _f: Vector2) -> void: hits.append(game.time))
	game.horde.hit_player.connect(func(_a: float, _f: Vector2) -> void: hits.append(game.time))
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(game.player.pos + Vector2(gap, 0), 0.6), false)
	e.cooldown = 0.0
	e.armor = 0.0
	return e


func _step(n := 1) -> void:
	for i in n:
		game.player.invuln = 0.0
		game.player.hp = game.player.max_hp
		game._step(1.0 / 60.0)


func _into(e: Enemy, state: Enemy.State) -> bool:
	for i in 300:
		_step()
		if e.state == state:
			return true
	return false


func test_the_elites_two_blows_are_data() -> void:
	var soldier: EnemyDef = load("res://data/enemies/skeleton_elite.tres")
	assert_eq(soldier.strikes, 2)
	assert_almost_eq(soldier.strike_gap, 0.2, 0.001, "Hades' Guard elite: 0.2 s apart")
	assert_almost_eq(soldier.recover_time, 1.5, 0.001)
	var runner: EnemyDef = load("res://data/enemies/runner_elite.tres")
	assert_eq(runner.strikes, 2)
	assert_gte(runner.strike_gap, 0.5, "a new ring needs 0.5 s to be read")
	assert_eq((load("res://data/enemies/skeleton.tres") as EnemyDef).strikes, 1, "the common ones strike once")


func test_the_soldier_elite_strikes_twice_both_warned_from_its_windup() -> void:
	var e := _alone(&"skeleton_elite")
	assert_true(_into(e, Enemy.State.WINDUP), "it winds up")
	var first := e.warning as Ground.Zone
	var second := e.warning2 as Ground.Zone
	assert_not_null(second, "the second blade's thread shows in the wind-up")
	# he steps aside during the wind-up: the second blade follows him until its end
	game.player.pos = Vector2(1.5, 1.6)
	while e.state == Enemy.State.WINDUP:
		_step()
	var aim := e.aim2
	assert_almost_eq(aim.angle_to(game.player.pos - e.lands_at), 0.0, 0.15, "aimed where he stood at the end of the wind-up")
	game.player.pos = Vector2(-3, 3)  # he moves again: the second blade keeps its aim
	var landed: Array[float] = []
	for i in 90:
		var b := e.blows
		_step()
		if e.blows > b:
			landed.append(e.state_t)
	assert_eq(landed.size(), 2, "two blades")
	assert_almost_eq(landed[1] - landed[0], e.def.strike_gap, 1.5 / 60.0, "strike_gap apart")
	assert_almost_eq(e.aim.angle_to(aim), 0.0, 0.001, "the second kept where he stood")
	assert_true(first.life <= 0.0 and second.life <= 1.0 / 60.0, "each thread full on its own blade")
	assert_eq(e.state, Enemy.State.RECOVER, "then its recovery")


func test_the_second_blade_hurts_who_stayed_and_a_stun_cuts_it() -> void:
	var e := _alone(&"skeleton_elite", 2.0)
	assert_true(_into(e, Enemy.State.ATTACK))
	while e.blows < 1:
		_step()
	assert_not_null(e.warning2, "after the first blade its second thread is still on the floor")
	while e.blows < 2 and e.state == Enemy.State.ATTACK:
		_step()
	assert_null(e.warning2, "handed to the second blade as it lands")
	# again, and this time a blow after the first blade cuts the second
	e = _alone(&"skeleton_elite", 2.0)
	assert_true(_into(e, Enemy.State.WINDUP))
	var thread := e.warning2 as Ground.Zone
	while e.blows < 1:
		_step()
	var before := hits.size()
	game.horde.damage(e, 5.0, (e.pos - game.player.pos).normalized(), 0.0, Color.WHITE, false)
	assert_ne(e.state, Enemy.State.ATTACK, "stunned out of its attack")
	_step(30)
	assert_eq(e.blows, 1, "the second blade never came")
	assert_eq(hits.size(), before, "nothing more hit him")
	assert_true(thread == null or thread.cancelled or thread.life <= 0.0)


func test_the_runner_elite_bursts_twice() -> void:
	var e := _alone(&"runner_elite", 1.2)
	assert_true(_into(e, Enemy.State.ATTACK))
	var rings: Array[float] = []
	var bursts: Array[float] = []
	for i in 80:
		var b := e.blows
		_step()
		if e.blows > b:
			bursts.append(e.state_t)
			if e.blows == 1 and e.warning2 != null:
				rings.append(e.state_t)
	assert_eq(bursts.size(), 2, "two bursts")
	assert_almost_eq(bursts[1] - bursts[0], e.def.strike_gap, 1.5 / 60.0)
	assert_eq(rings.size(), 1, "the second ring is born on the frame of the first burst")
	assert_almost_eq(rings[0], bursts[0], 0.001)
	assert_eq(hits.size(), 2, "he stood in both")
	var w := game.horde.windup_report()
	assert_true(w.has("runner_elite") and w.runner_elite.has("punished"), "RESULT counts blows in its window")


func test_morvath_reaps_twice_close_in() -> void:
	var def: BossDef = load("res://data/bosses/morvath.tres")
	var reap: BossAttack = null
	for a in def.attacks:
		if a.id == &"reap":
			reap = a
	assert_not_null(reap, "the Double Reap is an attack of his")
	assert_eq(reap.from_phase, 1)
	assert_lte(reap.max_dist, 6.0, "close in")
	assert_eq(reap.streak, 1, "never twice in a row")
	assert_almost_eq(def.reap_windup, 0.85, 0.001, "Hecate's right: 0.85")
	assert_almost_eq(def.reap2_windup, 0.5, 0.001)
	assert_almost_eq(def.reap_recovery, 2.2, 0.001)
	assert_true(Boss.ATTACKS.has(&"reap"))
	assert_true(DefeatCause.BOSS_ATTACKS.has(&"reap"))
	assert_ne(T.t(&"killer_reap"), "killer_reap")
	assert_false(T.t(&"killer_reap").contains("—"))


func test_morvath_reap_in_a_real_fight() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	var boss := game.boss
	for i in 200:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		if boss.state == Boss.State.CHASE:
			break
	game.player.pos = boss.e.pos + Vector2(0, 2.5)
	boss.director.cooldowns.clear()
	boss._attack = &"reap"
	boss.director.used(&"reap")
	boss._go(Boss.State.REAP)
	var warns: Array = []
	var strikes: Array[float] = []
	boss.moment.connect(func(m: StringName) -> void:
		if m == &"reap_warn":
			warns.append(boss._clock)
		elif m == &"reap_strike":
			strikes.append(boss._clock))
	for i in 360:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		if boss.state == Boss.State.RECOVER:
			break
	assert_eq(warns.size(), 2, "both sweeps warned on the floor")
	assert_eq(strikes.size(), 2, "two sweeps")
	var def := boss.def
	assert_almost_eq(strikes[0] - warns[0], def.reap_windup, 2.0 / 60.0, "the first warned its whole wind-up")
	assert_almost_eq(warns[1] - strikes[0], def.reap_active, 2.0 / 60.0, "the second born as the first's active time ends")
	assert_almost_eq(strikes[1] - warns[1], def.reap_pause + def.reap2_windup, 2.0 / 60.0, "0.85 s to read it")
	assert_eq(boss.state, Boss.State.RECOVER)
	assert_almost_eq(boss._recover_time, def.reap_recovery, 0.001, "then the long window")


func test_the_omega_charge_walks_at_hades_numbers() -> void:
	var hero := HeroDef.warrior()
	assert_almost_eq(hero.charge_move_light, 0.03, 0.0001, "Swing5SelfSlowCharge 0.03")
	assert_almost_eq(hero.charge_turn_light, 0.0, 0.0001, "RotationMultiplier 1e-8")
	assert_almost_eq(hero.charge_move_heavy, 0.6, 0.0001, "inferred from WeaponStaffBoltInstantStop")
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	var p := game.player
	p.charging = true
	p._charge_action = &"light_attack"
	assert_almost_eq(p.charge_move_scale(), 0.03, 0.0001)
	p._charge_action = &"heavy_attack"
	assert_almost_eq(p.charge_move_scale(), 0.6, 0.0001)
	p._start_dodge(Vector2.RIGHT)
	assert_false(p.charging, "the dodge cuts the charge")
	assert_almost_eq(p.charge_move_scale(), 1.0, 0.0001)


func test_the_mage_and_the_elder_show_their_aim_threads() -> void:
	var e := _alone(&"mage", 9.0)
	game.player.pos = Vector2.ZERO
	assert_true(_into(e, Enemy.State.WINDUP), "the mage winds up")
	assert_eq(e.fan.size(), 1, "one thread for its burst")
	var z := e.fan[0] as Ground.Zone
	assert_eq(z.shape, Ground.Shape.LINE)
	assert_almost_eq(z.total, e.def.attack_windup + 1.0 / 60.0, 0.001, "full on the frame its first orb leaves")
	assert_almost_eq(z.dir.angle_to(game.player.pos - e.pos), 0.0, 0.2, "toward him")
	var elder := _alone(&"priest_elder", 9.0)
	elder.memo = 1  # its next cast is the fan, not the raising
	assert_true(_into(elder, Enemy.State.WINDUP))
	assert_eq(elder.fan.size(), elder.def.shot_count, "one thread per orb of its fan")
	game.horde.damage(elder, 1.0, Vector2.RIGHT, 0.0)
	game.horde.interrupt(elder)
	assert_true(elder.fan.is_empty(), "a cut cast takes its threads")


func test_rewards_and_doors_wait_for_the_use_button() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var rooms := game.rooms
	rooms.start_at(RunMap.Kind.COMBAT)
	game.horde.clear_crowd()
	rooms._room_cleared()
	if rooms.phase == Rooms.Phase.REWARD:
		game.player.place(rooms._reward_at)
		assert_true(rooms.usable())
		rooms.step(0.0)
		assert_eq(rooms.phase, Rooms.Phase.REWARD, "standing on it takes nothing")
		assert_not_null(rooms.prompt, "the key shows over him at the reward")
		assert_eq(rooms.prompt.prompt.text, T.t(&"hub_use_reward"))
		assert_ne(rooms.prompt.key_text(), "", "with the real key")
		rooms.use()
		rooms.step(0.0)
		assert_ne(rooms.phase, Rooms.Phase.REWARD, "interact takes it")
	if rooms.phase == Rooms.Phase.OPEN and not game.arena.exit_zones.is_empty():
		var zone: Rect2 = game.arena.exit_zones[0]
		game.player.pos = zone.get_center()
		var room_before := rooms.room
		rooms.step(0.0)
		assert_eq(rooms.room, room_before, "at the door's foot without the button: he stays")
		assert_true(rooms.usable())
		assert_eq(rooms.prompt.prompt.text, T.t(&"hub_use_door"), "the door's verb over him")
		game.player.pos = Vector2(1000, 1000)
		rooms.step(0.0)
		assert_null(rooms.prompt, "away from it, no key")


## G-2: the Forja's rank shows on the Emeth in his hand (EmethSword.set_temper on the blade's material).
func test_the_forge_rank_shows_on_the_blade() -> void:
	Dev._args["forge"] = "2"
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	Dev._args.erase("forge")
	assert_eq(game.player.temper, 2)
	var blade := game.player._blade_mat
	if blade != null:
		assert_almost_eq(float(blade.get_shader_parameter(&"temper")), 2.0, 0.001)
	game.player.set_temper(0)
	if blade != null:
		assert_almost_eq(float(blade.get_shader_parameter(&"temper")), 0.0, 0.001)
