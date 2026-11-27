extends GutTest
## C1e, lote C (inimigos_c1e.md): the Canalizador (a beam held in pulses that turns after the paladin), the Armadilheiro (plates on the floor
## where he stepped or ended a dodge) and the modifiers Regenerante and Eco: the pure rules, the data, the draw by room and all four in play.

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


func _step(n := 1, keep_hero := true) -> void:
	for i in n:
		if keep_hero:
			game.player.invuln = 0.0
			game.player.hp = game.player.max_hp
		game._step(1.0 / 60.0)


func _spawn(id: StringName, at: Vector2, mod: ModDef = null) -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), at, false, mod)
	e.armor = 0.0
	return e


# ---------- the pure rules ----------

func test_the_beam_turns_at_its_rate_and_no_faster() -> void:
	var d := BeamRules.turned(Vector2.RIGHT, Vector2.DOWN, 40.0, 0.5)
	assert_almost_eq(rad_to_deg(Vector2.RIGHT.angle_to(d)), 20.0, 0.01, "40 degrees a second for half a second")
	assert_almost_eq(BeamRules.turned(Vector2.RIGHT, Vector2.RIGHT, 40.0, 1.0).x, 1.0, 0.0001)
	var near := BeamRules.turned(Vector2.RIGHT, Vector2.RIGHT.rotated(0.01), 40.0, 1.0)
	assert_almost_eq(near.angle(), 0.01, 0.0001, "it never overshoots")
	assert_almost_eq(BeamRules.turned(Vector2.RIGHT, Vector2.ZERO, 40.0, 1.0).x, 1.0, 0.0001)


func test_the_pulses_come_one_every_interval_the_first_at_once() -> void:
	assert_true(BeamRules.pulse_due(0.0, 0.45, 0, 5))
	assert_false(BeamRules.pulse_due(0.2, 0.45, 1, 5))
	assert_true(BeamRules.pulse_due(0.45, 0.45, 1, 5))
	assert_false(BeamRules.pulse_due(9.0, 0.45, 5, 5), "five and no more")
	assert_almost_eq(BeamRules.hold_time(5, 0.45), 2.25, 0.001)


func test_a_plate_is_x_then_spikes_for_half_a_second_then_dormant_until_six_seconds() -> void:
	assert_eq(TrapRules.phase(0.0, 1.0, 0.5, 6.0), TrapRules.Phase.WARN)
	assert_eq(TrapRules.phase(0.99, 1.0, 0.5, 6.0), TrapRules.Phase.WARN)
	assert_eq(TrapRules.phase(1.0, 1.0, 0.5, 6.0), TrapRules.Phase.SPIKES)
	assert_eq(TrapRules.phase(1.49, 1.0, 0.5, 6.0), TrapRules.Phase.SPIKES)
	assert_eq(TrapRules.phase(1.5, 1.0, 0.5, 6.0), TrapRules.Phase.DORMANT)
	assert_eq(TrapRules.phase(5.99, 1.0, 0.5, 6.0), TrapRules.Phase.DORMANT)
	assert_eq(TrapRules.phase(6.0, 1.0, 0.5, 6.0), TrapRules.Phase.GONE)
	var p := TrapRules.Plate.new()
	p.at = Vector2(2, 2)
	assert_true(p.covers(Vector2(2.7, 1.3)))
	assert_false(p.covers(Vector2(3.0, 2.0)))


func test_the_beam_hurts_in_its_line_and_not_at_its_root() -> void:
	var from := Vector2.ZERO
	assert_true(BeamRules.hits(from, Vector2.RIGHT, Vector2(6, 0.2), 12.0, 0.5, 1.0))
	assert_false(BeamRules.hits(from, Vector2.RIGHT, Vector2(6, 1.5), 12.0, 0.5, 1.0), "beside it")
	assert_false(BeamRules.hits(from, Vector2.RIGHT, Vector2(0.6, 0), 12.0, 0.5, 1.0), "at its feet")
	assert_false(BeamRules.hits(from, Vector2.RIGHT, Vector2(13, 0), 12.0, 0.5, 1.0), "past its reach")
	assert_false(BeamRules.hits(from, Vector2.RIGHT, Vector2(-4, 0), 12.0, 0.5, 1.0), "behind it")


func test_a_plate_goes_where_the_last_dodge_ended_if_it_was_lately() -> void:
	var hero := Vector2(1, 1)
	var end := Vector2(6, -2)
	assert_eq(TrapRules.spot(hero, end, 1.0, 3.0), end)
	assert_eq(TrapRules.spot(hero, end, 3.0, 3.0), end)
	assert_eq(TrapRules.spot(hero, end, 3.1, 3.0), hero)
	var laid: Array[Vector2] = [Vector2(0, 0), Vector2(5, 5)]
	assert_false(TrapRules.may_lay(Vector2(0.5, 0), laid, 4, 1.28), "not on another plate")
	assert_true(TrapRules.may_lay(Vector2(3, 0), laid, 4, 1.28))
	assert_false(TrapRules.may_lay(Vector2(3, 0), laid, 2, 1.28), "no more than the most")


func test_the_mending_and_the_echo_are_bounded() -> void:
	assert_eq(SupportRules.mended(90.0, 100.0, 12.0), 100.0)
	assert_eq(SupportRules.mended(50.0, 100.0, 12.0), 62.0)
	assert_almost_eq(SupportRules.echo_hp(100.0, 0.4), 40.0, 0.001)
	assert_false(SupportRules.echo_rises(3.4, 3.5))
	assert_true(SupportRules.echo_rises(3.5, 3.5))


# ---------- the data ----------

func test_the_four_are_data_with_the_numbers_of_the_doc() -> void:
	var c := defs[&"canalizador"] as EnemyDef
	var a := defs[&"armadilheiro"] as EnemyDef
	for d in [c, a]:
		assert_eq(d.poise, 100.0, "the Quebra cuts it")
		assert_false(d.elite)
		assert_eq(d.per_room, 1)
		assert_ne(T.t(d.name_key), String(d.name_key))
		assert_ne(T.t(StringName("codex_role_" + String(d.role))), "codex_role_" + String(d.role))
		assert_true(CodexScreen.ENEMIES.has(d.id))
	assert_eq(c.behavior, EnemyDef.Behavior.BEAM)
	assert_eq(c.hp, 150.0)
	assert_eq(c.speed, 0.0)
	assert_eq(c.attack_damage, 5.0)
	assert_eq(c.shot_ticks, 5)
	assert_almost_eq(c.shot_interval, 0.45, 0.001)
	assert_eq(c.shot_turn, 40.0)
	assert_eq(c.attack_range, 12.0)
	assert_gte(c.attack_windup, 0.7)
	assert_eq(c.role, &"beam")
	assert_true(c.never_with.has(&"sweep"), "never with the Varredor")
	assert_eq(a.behavior, EnemyDef.Behavior.SUPPORT)
	assert_eq(a.hp, 150.0)
	assert_eq(a.plate_damage, 7.0)
	assert_gte(a.plate_time, 0.7)
	assert_eq(a.plate_max, 4)
	assert_eq(a.role, &"trap")
	for m in [&"regenerante", &"eco"]:
		var md := load("res://data/mods/%s.tres" % m) as ModDef
		assert_ne(T.t(md.name_key), String(md.name_key))
		assert_true(stage.mods.has(m))
	assert_eq((load("res://data/mods/regenerante.tres") as ModDef).regen_hp, 12.0)
	assert_eq((load("res://data/mods/eco.tres") as ModDef).echo_time, 3.5)
	assert_eq((load("res://data/mods/eco.tres") as ModDef).echo_share, 0.4)


func test_each_has_a_windup_sound_of_its_own() -> void:
	var c := CombatSounds.windup(defs[&"canalizador"])
	var a := CombatSounds.windup(defs[&"armadilheiro"])
	assert_eq(c, &"tell_beam")
	assert_eq(a, &"tell_trap")
	assert_true(Audio.SOUNDS.has(c) and Audio.SOUNDS.has(a))
	assert_true(FileAccess.file_exists("res://audio/tell_beam.ogg") and FileAccess.file_exists("res://audio/tell_trap.ogg"))


func test_they_come_from_their_room_never_with_the_sweeper_and_never_past_20_bodies() -> void:
	var seen := {&"canalizador": 0, &"armadilheiro": 0}
	for i in 900:
		var depth := 1 + i % 12
		var f := EncounterGen.generate(stage, depth, defs, rng)
		for id in seen:
			var n := 0
			for k in f.kinds:
				n += int(k == id)
			seen[id] += n
			var from := 6 if id == &"canalizador" else 9
			if depth < from:
				assert_eq(n, 0, "%s before its room (%d)" % [id, depth])
		assert_false(f.kinds.has(&"canalizador") and (f.kinds.has(&"varredor") or f.kinds.has(&"varredor_elite")), "never both")
		for w: Array in f.waves:
			assert_lte(EncounterGen.bodies(w, defs), 20)
			assert_lte(w.count(&"canalizador"), 1)
			assert_lte(w.count(&"armadilheiro"), 1)
	assert_gt(seen[&"canalizador"], 5)
	assert_gt(seen[&"armadilheiro"], 5)


func test_the_chain_room_never_has_the_armadilheiro() -> void:
	var chains := 0
	for l in stage.layouts:
		if l.banned_roles.has(&"sweep"):
			chains += 1
			assert_true(l.banned_roles.has(&"trap"), "the chain's floor and the plates never meet")
	assert_gt(chains, 0)


func test_the_mods_are_drawn_from_five_now() -> void:
	var got := {}
	for i in 600:
		var f := EncounterGen.generate(stage, 10 + i % 3, defs, rng)
		for id in f.mods:
			for m in f.mods[id]:
				got[m] = true
	for m in [&"furioso", &"detonante", &"escoltado", &"regenerante", &"eco"]:
		assert_true(got.has(m), "%s is drawn" % m)


# ---------- in the game ----------

func test_the_canalizador_threads_then_holds_five_pulses_and_rests() -> void:
	_room()
	var e := _spawn(&"canalizador", Vector2(8, 0))
	game.player.pos = Vector2.ZERO
	e.cooldown = 0.0
	var hurts: Array[float] = []
	game.horde.hit_player.connect(func(a: float, _f: Vector2) -> void: hurts.append(a))
	var windup_t := -1.0
	var attacking := false
	for i in 600:
		_step()
		game.player.pos = Vector2.ZERO
		if e.state == Enemy.State.WINDUP:
			windup_t = e.state_t
		if e.state == Enemy.State.ATTACK:
			attacking = true
			var tagged := false
			for z in game.ground.zones:
				tagged = tagged or z.tags.has(Horde.BEAM_TAG)
			assert_true(tagged, "the beam is on the floor")
		if attacking and e.state != Enemy.State.ATTACK:
			break
	assert_gte(windup_t, 0.7, "the thread showed 0.72 s")
	assert_true(attacking)
	assert_eq(e.blows, 5, "five pulses")
	assert_eq(hurts.size(), 5, "he stood in the line the whole time: every pulse hurt (the test lets him be hit again at once)")
	assert_almost_eq(hurts[0], 5.0, 0.01)
	assert_null(e.warning, "the beam is gone with the attack")
	assert_gt(e.cooldown, 1.0, "and it rests")
	assert_eq(e.pos, Vector2(8, 0), "planted")


func test_a_pulse_misses_who_stepped_out_of_the_line_and_the_beam_turns_after_him() -> void:
	_room()
	var e := _spawn(&"canalizador", Vector2(8, 0))
	game.player.pos = Vector2.ZERO
	e.cooldown = 0.0
	var hurts := 0
	game.horde.hit_player.connect(func(_a: float, _f: Vector2) -> void: hurts += 1)
	while e.state != Enemy.State.ATTACK:
		_step()
		game.player.pos = Vector2.ZERO
	var first := e.aim
	game.player.pos = Vector2(0, 5)
	for i in 60:
		_step()
		game.player.pos = Vector2(0, 5)
	assert_ne(e.aim, first, "it turned after him")
	assert_lte(absf(rad_to_deg(first.angle_to(e.aim))), 41.0 + 1.0, "no faster than 40 degrees a second (one second so far)")


func test_the_quebra_cuts_the_beam() -> void:
	_room()
	var e := _spawn(&"canalizador", Vector2(8, 0))
	e.cooldown = 0.0
	while e.state != Enemy.State.ATTACK:
		_step()
	assert_true(game.horde.interrupt(e))
	assert_ne(e.state, Enemy.State.ATTACK)
	assert_null(e.warning)
	var live := 0
	for z in game.ground.zones:
		live += int(z.tags.has(Horde.BEAM_TAG) and z.life > 0.0)
	assert_eq(live, 0, "no beam left on the floor")


func test_the_armadilheiro_lays_a_plate_that_warns_one_second_then_hurts() -> void:
	_room()
	var e := _spawn(&"armadilheiro", Vector2(6, 0))
	e.cooldown = 0.0
	var hurts: Array[float] = []
	game.ground.hit_player.connect(func(a: float, _f: Vector2) -> void: hurts.append(a))
	var plate: Ground.Zone = null
	for i in 240:
		_step()
		game.player.pos = Vector2.ZERO
		for z in game.ground.zones:
			if z.tags.has(Ground.PLATE_TAG):
				plate = z
		if plate != null:
			break
	assert_not_null(plate, "it laid one")
	assert_almost_eq(plate.total, 1.0, 0.001)
	assert_lt((plate.pos + Vector2(plate.radius * 0.5, 0.0)).distance_to(Vector2.ZERO), 1.0, "where he stood")
	assert_false(plate.node.visible, "the X is drawn by C1eMarks, not a red fill")
	assert_eq(hurts.size(), 0, "nothing yet")
	for i in 80:
		_step()
		game.player.pos = Vector2.ZERO
	assert_eq(hurts.size(), 1, "standing on it he took it once")
	assert_almost_eq(hurts[0], 7.0, 0.01)


func test_the_plate_lies_dormant_until_six_seconds_and_its_spikes_hurt_who_steps_on_them() -> void:
	_room()
	var e := _spawn(&"armadilheiro", Vector2(6, 0))
	e.cooldown = 0.0
	var hurts: Array[float] = []
	game.ground.hit_player.connect(func(a: float, _f: Vector2) -> void: hurts.append(a))
	game.player.pos = Vector2(-5, -5)
	for i in 240:
		_step()
		game.player.pos = Vector2(-5, -5)
		if not game.horde.plates_laid.is_empty():
			break
	assert_eq(game.horde.plates_laid.size(), 1, "it laid one")
	var plate: TrapRules.Plate = game.horde.plates_laid[0]
	e.cooldown = 99.0
	var far := Vector2(5, 5)
	game.player.pos = far
	for i in 400:
		if plate.age >= plate.warn + 0.1:
			break
		_step()
		game.player.pos = far
	assert_eq(plate.phase(), TrapRules.Phase.SPIKES)
	assert_eq(hurts.size(), 0, "he was not there at the landing")
	game.player.pos = plate.at
	_step()
	assert_eq(hurts.size(), 1, "stepping onto the spikes hurts")
	assert_almost_eq(hurts[0], 7.0, 0.01)
	_step(10)
	assert_eq(hurts.size(), 1, "once")
	for i in 600:
		if plate.age >= 5.5:
			break
		_step()
		game.player.pos = far
	assert_eq(plate.phase(), TrapRules.Phase.DORMANT)
	assert_true(game.horde.plates_laid.has(plate), "still lying at 5.5 s")
	hurts.clear()
	game.player.pos = plate.at
	_step()
	assert_eq(hurts.size(), 0, "dormant: no harm")
	for i in 600:
		if plate.age >= 6.2:
			break
		_step()
		game.player.pos = far
	assert_false(game.horde.plates_laid.has(plate), "gone at 6 s")


func test_the_plate_follows_the_last_dodge_and_a_dodge_over_it_is_safe() -> void:
	_room()
	var e := _spawn(&"armadilheiro", Vector2(6, 0))
	game.player.pos = Vector2.ZERO
	game.player.last_dodge_end = Vector2(-4, 3)
	game.player.dodge_age = 0.5
	e.cooldown = 0.0
	var plate: Ground.Zone = null
	for i in 240:
		game.player.dodge_age = 0.5
		_step()
		game.player.pos = Vector2.ZERO
		for z in game.ground.zones:
			if z.tags.has(Ground.PLATE_TAG):
				plate = z
		if plate != null:
			break
	assert_not_null(plate)
	assert_lt((plate.pos + Vector2(plate.radius * 0.5, 0.0)).distance_to(Vector2(-4, 3)), 1.0, "where the dodge ended")
	assert_lte(game.ground.zones.size(), 8)
	# the paladin in the middle of a dodge takes nothing (the dodge's own protection)
	game.player.pos = Vector2(-4, 3)
	var hp := game.player.hp
	game.player.invuln = 5.0
	for i in 80:
		game.player.invuln = 5.0
		game._step(1.0 / 60.0)
	assert_eq(game.player.hp, hp)


func test_never_more_than_four_plates() -> void:
	_room()
	var e := _spawn(&"armadilheiro", Vector2(6, 0))
	game.player.last_dodge_end = Vector2.ZERO
	for i in 900:
		e.cooldown = minf(e.cooldown, 0.0)
		game.player.dodge_age = 99.0
		game.player.pos = Vector2(randf_range(-6, 6), randf_range(-4, 4))
		_step()
		var n := 0
		for z in game.ground.zones:
			n += int(z.tags.has(Ground.PLATE_TAG) and z.life > 0.0)
		assert_lte(n, 4)


func test_the_regenerante_mends_after_three_calm_seconds_and_a_blow_resets_it() -> void:
	_room()
	var e := _spawn(&"skeleton", Vector2(9, 0), game.horde.mod(&"regenerante"))
	e.cooldown = 99.0
	e.hp = 50.0
	_step(150)
	assert_eq(e.hp, 50.0, "2.5 s is not enough")
	_step(40)
	assert_almost_eq(e.hp, 62.0, 0.5, "12 back after 3 s")
	game.horde.damage(e, 1.0, Vector2.RIGHT, 0.0)
	var hp := e.hp
	_step(150)
	assert_almost_eq(e.hp, hp, 0.01, "a blow restarted the wait")
	_step(40)
	assert_almost_eq(e.hp, hp + 12.0, 0.5)


func test_the_eco_lies_a_mound_and_rises_once_with_40_percent() -> void:
	_room()
	var e := _spawn(&"skeleton", Vector2(9, 0), game.horde.mod(&"eco"))
	e.cooldown = 99.0
	var fell := game.horde.damage(e, e.hp + 5.0, Vector2.RIGHT, 0.0)
	assert_false(fell, "not dead the first time")
	assert_true(e.alive)
	assert_eq(e.state, Enemy.State.DOWN)
	assert_true(e.invulnerable)
	_step(200)
	assert_eq(e.state, Enemy.State.DOWN, "3.3 s: still a mound")
	_step(30)
	assert_ne(e.state, Enemy.State.DOWN, "risen at 3.5 s")
	assert_almost_eq(e.hp, e.max_hp * 0.4, 0.01)
	assert_null(e.mod, "once")
	assert_true(game.horde.damage(e, e.hp + 5.0, Vector2.RIGHT, 0.0), "dead for good the second time")


func test_the_bot_goes_in_to_the_canalizador_and_stands_at_its_feet() -> void:
	_room()
	var e := _spawn(&"canalizador", Vector2(8, 0))
	e.cooldown = 0.0
	while e.state != Enemy.State.ATTACK:
		_step()
	var z: Ground.Zone = null
	for o in game.ground.zones:
		if o.tags.has(Horde.BEAM_TAG):
			z = o
	assert_not_null(z)
	game.player.pos = e.pos + e.aim * 0.8
	var bot := Bot.new()
	assert_eq(bot._danger(game), Vector2.ZERO, "within 1 m of its root the beam does not hurt")
	game.player.pos = e.pos + e.aim * 6.0
	assert_ne(bot._danger(game), Vector2.ZERO, "in the line he steps aside")


func test_the_bot_deals_with_the_canalizador_and_the_armadilheiro_within_a_minute() -> void:
	_room()
	var bot := Bot.new()
	game.bot = bot
	var old: Variant = Controls.virtual
	Controls.virtual = bot.pad
	var a := _spawn(&"armadilheiro", Vector2(7, -4))
	var c := _spawn(&"canalizador", Vector2(-8, 3))
	# (SW-C2: the spin hits for 30 and the pair fell in 9 s, before the first plate; GP-1: the Esmagador and the Corte kill faster still, so 5x life: the plates show)
	a.hp *= 5.0
	c.hp *= 5.0
	var taken := 0.0
	game.horde.hit_player.connect(func(x: float, _f: Vector2) -> void: taken += x)
	game.ground.hit_player.connect(func(x: float, _f: Vector2) -> void: taken += x)
	var dt := 1.0 / 60.0
	var t := 0.0
	var plates := 0
	while t < 60.0 and (a.alive or c.alive):
		game.player.hp = game.player.max_hp
		bot.step(dt, game)
		game._step(dt)
		for z in game.ground.zones:
			plates = maxi(plates, int(z.tags.has(Ground.PLATE_TAG)))
		t += dt
	Controls.virtual = old
	assert_false(a.alive, "the Armadilheiro fell (%.0f s)" % t)
	assert_false(c.alive, "the Canalizador fell (%.0f s)" % t)
	assert_eq(plates, 1, "it laid plates meanwhile")
	gut.p("bot took %.0f damage in %.1f s" % [taken, t])
