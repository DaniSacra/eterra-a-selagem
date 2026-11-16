extends GutTest
## Morvath's fight in four phases (Daniel's request of 2026-11-15): the pure rules (phases, director, patterns that
## always leave a way out, ritual, summons, curse) and, at the end, the fight itself in a real game scene (the
## shield only in the ritual, the special locked by the curse, nothing of his left once he falls).

const DEF := "res://data/bosses/morvath.tres"
## The paladin's walking speed (Feel) and body, and how much of a warning's time a test lets him use: what is
## proven walkable with 80% of the time is walkable for a person.
const SAFE_SHARE := 0.8
## A hall the size of the catacomb hall's floor (CatacombHall.HALF, less the margin a body keeps from its edge).
const FLOOR := Rect2(-14.3, -13.3, 28.6, 26.6)

var def: BossDef


func before_all() -> void:
	def = load(DEF)


func _walk() -> float:
	return Feel.live().speed


# ---------- phases ----------

func test_four_phases_at_66_33_and_15_percent() -> void:
	var t := def.thresholds
	assert_eq(t, PackedFloat32Array([0.66, 0.33, 0.15]))
	assert_eq(BossRules.phase_for(1.0, t), 1)
	assert_eq(BossRules.phase_for(0.67, t), 1)
	assert_eq(BossRules.phase_for(0.66, t), 2)
	assert_eq(BossRules.phase_for(0.34, t), 2)
	assert_eq(BossRules.phase_for(0.33, t), 3)
	assert_eq(BossRules.phase_for(0.16, t), 3)
	assert_eq(BossRules.phase_for(0.15, t), 4)
	assert_eq(BossRules.phase_for(0.0, t), 4)


func test_each_phase_begins_once_and_in_order() -> void:
	var t := def.thresholds
	var phase := 1
	var ratio := 1.0
	var seen: Array[int] = [1]
	# blows far bigger than a phase: each stops at the next threshold
	for blow in 12:
		ratio = maxf(ratio - 0.9, BossRules.hp_floor(phase, t))
		var next := BossRules.next_phase(phase, ratio, t)
		assert_true(next == phase or next == phase + 1, "one step at a time")
		if next != phase:
			phase = next
			seen.append(phase)
	assert_eq(seen, [1, 2, 3, 4] as Array[int])
	assert_eq(ratio, 0.0, "the last phase has no floor: he can fall")
	assert_eq(BossRules.next_phase(3, 0.9, t), 3, "never back")
	assert_almost_eq(BossRules.hp_floor(1, t), 0.66, 0.0001)
	assert_eq(BossRules.hp_floor(4, t), 0.0)


func test_morvath_keeps_hades_life_and_his_numbers_are_data() -> void:
	var enemy: EnemyDef = load("res://data/enemies/morvath.tres")
	assert_eq(enemy.hp, 6050.0)
	assert_eq(def.enemy, &"morvath")
	assert_eq(def.ritual_phase, 2)
	assert_eq(def.ritual_time, 20.0)
	assert_eq(def.ritual_cap, 6)
	assert_eq(def.storm_count, 6)
	for n in [def.scythe_damage, def.blade_damage, def.storm_damage, def.eruption_damage, def.curse_damage, def.dash_damage]:
		assert_between(n, 4.0, 14.0, "every blow on the scale of Hades II's first guardian (4 to 14)")


func test_morvath_is_an_undead_heavy_boss_with_art_for_every_attack() -> void:
	var enemy: EnemyDef = load("res://data/enemies/morvath.tres")
	assert_eq(enemy.behavior, EnemyDef.Behavior.BOSS)
	assert_true(enemy.undead)
	assert_true(enemy.heavy)
	var anims: Dictionary = (load("res://assets/baked/morvath.res") as BakedModel).frames
	for a in ["idle", "walk", "slash1", "slash2", "dash_windup", "dash", "summon", "rain", "volley", "stunned", "roar", "death"]:
		assert_true(anims.has(a), a)


# ---------- patterns ----------

func test_ring_spreads_bullets_evenly() -> void:
	var dirs := BossRules.ring(8, 0.0)
	assert_eq(dirs.size(), 8)
	assert_almost_eq(dirs[2].angle(), PI * 0.5, 0.001)
	assert_almost_eq(BossRules.ring(8, 0.3)[0].angle(), 0.3, 0.001)


func test_fan_is_centred_on_the_aim() -> void:
	var dirs := BossRules.fan(Vector2.RIGHT, 5, 1.0)
	assert_almost_eq(dirs[2].angle(), 0.0, 0.001)
	assert_almost_eq(dirs[0].angle(), -0.5, 0.001)
	assert_eq(BossRules.fan(Vector2.UP, 1, 1.0)[0], Vector2.UP)


func test_the_aim_leads_a_moving_paladin_only_partly() -> void:
	var still := BossRules.aim_at(Vector2.ZERO, Vector2(10, 0), Vector2.ZERO, 10.0, 0.45)
	assert_almost_eq(still.angle(), 0.0, 0.001)
	var moving := BossRules.aim_at(Vector2.ZERO, Vector2(10, 0), Vector2(0, 6.75), 10.0, 0.45)
	var perfect := Vector2(10, 6.75).angle()
	assert_gt(moving.angle(), 0.05, "he leads a little")
	assert_lt(moving.angle(), perfect * 0.6, "never a perfect lead")


## A point is safe from a crescent when it is out of its lane (the crescent sweeps the whole lane ahead of its start).
func _in_soul_lane(from: Vector2, dir: Vector2, p: Vector2, half_width: float, reach: float) -> bool:
	var d := p - from
	var along := d.dot(dir)
	return along >= -(Projectiles.SOUL_DEPTH + Player.RADIUS) and along <= reach and absf(d.cross(dir)) <= half_width + Player.RADIUS * 0.5


## A safe point within walking distance: on the floor, out of every hazard, not inside the boss.
func _escape(p: Vector2, boss: Vector2, reach: float, hazard: Callable) -> bool:
	for ring in 16:
		var r := reach * (ring + 1) / 16.0
		for k in 48:
			var q := p + Vector2.from_angle(TAU * k / 48.0) * r
			if FLOOR.has_point(q) and q.distance_to(boss) > 1.4 + Player.RADIUS and not hazard.call(q):
				return true
	return not hazard.call(p)


func test_the_blades_leave_an_opening_and_can_be_walked_out_of() -> void:
	var rng := RandomNumberGenerator.new()
	var reach := _walk() * def.blade_windup * BossDef.by_phase(def.windup_scale, 3) * SAFE_SHARE
	var half := def.blade_width * 0.5
	for i in 300:
		rng.seed = i
		var boss := Vector2(rng.randf_range(-11, 11), rng.randf_range(-10, 10))
		var p := Vector2(rng.randf_range(FLOOR.position.x, FLOOR.end.x), rng.randf_range(FLOOR.position.y, FLOOR.end.y))
		if p.distance_to(boss) < 3.5 or p.distance_to(boss) > def.blade_range - 1.0:
			continue
		var dirs := BossRules.soul_pair((p - boss).normalized(), def.blade_spread, 1.0 if i % 2 == 0 else -1.0)
		assert_almost_eq(rad_to_deg(dirs[0].angle_to(dirs[1])) * (1.0 if i % 2 == 0 else -1.0), def.blade_spread, 0.01)
		var hazard := func(q: Vector2) -> bool:
			return _in_soul_lane(boss, dirs[0], q, half, def.blade_range) or _in_soul_lane(boss, dirs[1], q, half, def.blade_range)
		assert_true(hazard.call(p), "one crescent flies at him")
		assert_true(_escape(p, boss, reach, hazard), "seed %d: a way out of the blades" % i)
	# the wedge between them: from about 6 m out there is room for the paladin between the two lanes
	var d := (def.blade_width + Player.RADIUS * 2.0 + 0.4) / (2.0 * sin(deg_to_rad(def.blade_spread) * 0.5))
	assert_lt(d, 7.0, "the opening shows at the distances he throws them from")
	var mid := Vector2.from_angle(deg_to_rad(def.blade_spread) * 0.5) * (d + 0.5)
	assert_false(_in_soul_lane(Vector2.ZERO, Vector2.RIGHT, mid, half, def.blade_range) or _in_soul_lane(Vector2.ZERO, Vector2.from_angle(deg_to_rad(def.blade_spread)), mid, half, def.blade_range))


func test_the_six_souls_never_close_every_way_out() -> void:
	var rng := RandomNumberGenerator.new()
	var reach := _walk() * def.storm_windup * BossDef.by_phase(def.windup_scale, 4) * SAFE_SHARE
	var half := def.blade_width * 0.5
	for i in 200:
		rng.seed = 1000 + i
		var boss := Vector2(rng.randf_range(-11, 11), rng.randf_range(-10, 10))
		var p := boss + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(1.4 + Player.RADIUS, 20.0)
		if not FLOOR.has_point(p):
			continue
		for wave in def.storm_waves:
			var offset := rad_to_deg((p - boss).angle()) + def.storm_turn * wave
			var dirs := BossRules.storm(def.storm_count, offset, def.storm_jitter, def.storm_min_gap, rng)
			assert_eq(dirs.size(), 6)
			assert_true(BossRules.min_gap(dirs) >= def.storm_min_gap - 0.01, "seed %d: neighbours never close the gap" % i)
			var hazard := func(q: Vector2) -> bool:
				for d in dirs:
					if _in_soul_lane(boss, d, q, half, def.blade_range):
						return true
				return false
			assert_true(_escape(p, boss, reach, hazard), "seed %d wave %d: a way out of the storm" % [i, wave])


func test_eruptions_always_leave_a_way_out() -> void:
	var rng := RandomNumberGenerator.new()
	var reach := _walk() * def.eruption_delay * BossDef.by_phase(def.windup_scale, 4) * SAFE_SHARE
	var near := 0
	for i in 500:
		rng.seed = 5000 + i
		var p := Vector2(rng.randf_range(FLOOR.position.x, FLOOR.end.x), rng.randf_range(FLOOR.position.y, FLOOR.end.y))
		var n := rng.randi_range(def.eruption_count.x, def.eruption_count.y)
		var spots := BossRules.eruptions(p, n, def.eruption_radius, Vector2.ZERO, def.eruption_lane, FloorShape.rect(FLOOR.size * 0.5, FLOOR.get_center()), rng)
		assert_between(spots.size(), 1, n)
		if spots[0].distance_to(p) < def.eruption_radius:
			near += 1
		var hazard := func(q: Vector2) -> bool:
			for s in spots:
				if q.distance_to(s) <= def.eruption_radius + Player.RADIUS * 0.6:
					return true
			return false
		assert_true(_escape(p, Vector2(999, 999), reach, hazard), "seed %d: a way out of the eruptions" % i)
	assert_eq(near, 500, "one always erupts under the paladin (he must move)")


func test_the_scythe_can_be_walked_out_of() -> void:
	var rng := RandomNumberGenerator.new()
	var reach := _walk() * def.scythe_windup * BossDef.by_phase(def.windup_scale, 4) * SAFE_SHARE
	for i in 300:
		rng.seed = 9000 + i
		var boss := Vector2(rng.randf_range(-12, 12), rng.randf_range(-11, 11))
		var dir := Vector2.from_angle(rng.randf() * TAU)
		var z := Ground.Zone.new()
		z.shape = Ground.Shape.ARC
		z.pos = boss
		z.dir = dir
		z.radius = def.scythe_reach
		z.width = def.scythe_degrees
		var p := boss + dir.rotated(rng.randf_range(-1.4, 1.4)) * rng.randf_range(1.4 + Player.RADIUS, def.scythe_reach)
		if not FLOOR.has_point(p):
			continue
		var hazard := func(q: Vector2) -> bool: return Ground.inside(z, q, Player.RADIUS * 0.6)
		assert_true(_escape(p, boss, reach, hazard), "seed %d: a way out of the scythe" % i)


# ---------- the director ----------

func _director() -> BossDirector:
	return BossDirector.new(def)


func test_the_director_always_has_something_to_choose() -> void:
	var rng := RandomNumberGenerator.new()
	var ids: Array[StringName] = [&"", &"scythe", &"blades", &"dash", &"eruptions", &"summon", &"curse", &"storm"]
	for phase in [1, 2, 3, 4]:
		for dist in [0.0, 3.0, 8.0, 12.0, 40.0]:
			for last in ids:
				for blocked: Array[StringName] in [[] as Array[StringName], [&"summon", &"curse"] as Array[StringName]]:
					var d := _director()
					if last != &"":
						d.used(last)
						d.used(last)
					var id := d.choose(phase, dist, 0.0, blocked, rng)
					assert_ne(id, &"", "phase %d dist %.0f last %s" % [phase, dist, last])
					assert_false(blocked.has(id))
	assert_eq(BossDirector.new().choose(1, 5.0, 0.0, [], rng), &"", "no attacks at all: nothing, never a crash")


func test_the_director_only_uses_what_the_phase_allows() -> void:
	var rng := RandomNumberGenerator.new()
	var by_phase := {}
	for phase in [1, 2, 3, 4]:
		var seen := {}
		var d := _director()
		for i in 400:
			var id := d.choose(phase, [2.0, 7.0, 14.0][i % 3], 0.0 if i % 2 else 2.0, [], rng)
			seen[id] = true
			d.used(id)
			d.step(1.5)
		by_phase[phase] = seen
	for id in [&"eruptions", &"summon", &"curse", &"storm"]:
		assert_false((by_phase[1] as Dictionary).has(id), "phase 1: %s" % id)
	assert_true((by_phase[1] as Dictionary).has(&"scythe"))
	assert_true((by_phase[1] as Dictionary).has(&"blades"))
	assert_true((by_phase[2] as Dictionary).has(&"eruptions"))
	assert_false((by_phase[2] as Dictionary).has(&"curse"))
	assert_true((by_phase[3] as Dictionary).has(&"curse"))
	assert_false((by_phase[4] as Dictionary).has(&"blades"), "in the last phase the blades become the storm")
	assert_true((by_phase[4] as Dictionary).has(&"storm"))
	assert_true((by_phase[4] as Dictionary).has(&"scythe"), "what came before stays")


func _share(phase: int, dist: float, still: float, id: StringName) -> float:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var hits := 0
	for i in 2000:
		if _director().choose(phase, dist, still, [], rng) == id:
			hits += 1
	return hits / 2000.0


func test_the_director_reads_where_the_paladin_is() -> void:
	assert_gt(_share(1, 3.0, 0.0, &"scythe"), _share(1, 3.0, 0.0, &"blades") * 2.0, "close: the scythe")
	assert_gt(_share(1, 14.0, 0.0, &"blades"), _share(1, 14.0, 0.0, &"scythe") * 2.0, "far: the blades")
	assert_gt(_share(2, 7.0, 2.0, &"eruptions"), _share(2, 7.0, 0.0, &"eruptions") * 1.8, "standing still: the eruptions")
	assert_eq(_share(1, 2.0, 0.0, &"dash"), 0.0, "no dash at his feet")


func test_the_director_does_not_repeat_too_much_and_keeps_cooldowns() -> void:
	var rng := RandomNumberGenerator.new()
	var d := _director()
	var run := 0
	var last := &""
	for i in 600:
		var id := d.choose(2 + i % 3, [2.0, 7.0, 14.0][i % 3], 0.0, [], rng)
		run = run + 1 if id == last else 1
		last = id
		assert_lte(run, 2, "never the same three times in a row")
		if id != &"scythe":
			assert_lte(run, 1, "only the scythe comes twice in a row")
		d.used(id)
		d.step(1.0)
	var c := _director()
	c.used(&"eruptions")
	assert_false(c.valid(2, 7.0, []).any(func(a: BossAttack) -> bool: return a.id == &"eruptions"), "on cooldown")
	c.used(&"scythe")
	c.step(def.attacks.filter(func(a: BossAttack) -> bool: return a.id == &"eruptions")[0].cooldown)
	assert_true(c.valid(2, 7.0, []).any(func(a: BossAttack) -> bool: return a.id == &"eruptions"), "back after its cooldown")


# ---------- ritual, summons, curse ----------

func test_the_ritual_ends_by_time_or_when_its_dead_fall() -> void:
	assert_true(BossRules.ritual_over(def.ritual_time, def.ritual_time, 4, 4), "time is up")
	assert_true(BossRules.ritual_over(5.0, def.ritual_time, 4, 0), "they all fell")
	assert_false(BossRules.ritual_over(5.0, def.ritual_time, 4, 2))
	assert_false(BossRules.ritual_over(0.0, def.ritual_time, 0, 0), "nothing raised yet: not over")


func test_summons_never_pass_their_ceiling() -> void:
	assert_eq(BossRules.summon_count(4, 0, def.ritual_cap), 4)
	assert_eq(BossRules.summon_count(4, 4, def.ritual_cap), 2, "near the ceiling, fewer")
	assert_eq(BossRules.summon_count(2, 6, def.ritual_cap), 0, "at it, none")
	assert_eq(BossRules.summon_count(2, 9, def.ritual_cap), 0)
	assert_eq(BossRules.adds_cap(def.adds_cap, 1), 0, "the first phase brings nobody")
	for phase in [2, 3, 4, 9]:
		assert_between(BossRules.adds_cap(def.adds_cap, phase), 1, 6)
	assert_lte(def.ritual_raise.size(), def.ritual_cap)


func test_the_curse_slows_locks_ends_and_leaves_a_moment_of_immunity() -> void:
	var c := CurseState.new()
	assert_true(c.apply(def.curse_time, def.curse_slow, def.curse_immunity))
	assert_true(c.active())
	assert_almost_eq(c.speed_scale(), 0.7, 0.001, "30% slower")
	assert_false(c.apply(def.curse_time, def.curse_slow, def.curse_immunity), "no second curse on top")
	c.step(def.curse_time + 0.01)
	assert_false(c.active())
	assert_eq(c.speed_scale(), 1.0)
	assert_false(c.apply(def.curse_time, def.curse_slow, def.curse_immunity), "immune right after")
	c.step(def.curse_immunity + 0.01)
	assert_true(c.apply(def.curse_time, def.curse_slow, def.curse_immunity), "then it can land again")
	c.clear()
	assert_false(c.active())
	assert_eq(c.immune_left, 0.0)


# ---------- the fight in a real game ----------

var game: Game


func _start_fight() -> Boss:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	return game.boss


func _run(seconds: float, each: Callable = Callable()) -> void:
	var t := 0.0
	while t < seconds and game.boss != null:
		# the paladin stands still and cannot be hurt: the test watches Morvath
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		if each.is_valid():
			each.call()
		t += 1.0 / 60.0


func test_morvath_is_hurt_everywhere_but_behind_the_ritual_shield() -> void:
	var boss := _start_fight()
	assert_not_null(boss)
	var outside := [0]
	_run(3.0, func() -> void:
		if boss.e.invulnerable:
			outside[0] += 1)
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0)
	assert_almost_eq(boss.e.hp / boss.e.max_hp, 0.66, 0.001, "the blow stops at the threshold")
	for i in 8 * 60:
		if boss.state == Boss.State.RITUAL:
			break
		_run(1.0 / 60.0, func() -> void:
			if boss.e.invulnerable and boss.state != Boss.State.RITUAL:
				outside[0] += 1)
	assert_eq(boss.phase, 2)
	assert_eq(boss.state, Boss.State.RITUAL)
	assert_true(boss.e.invulnerable)
	assert_eq(game.horde.count(), 1, "nobody rises in the shield's first instant")
	var before := boss.e.hp
	game.horde.damage(boss.e, 500.0, Vector2.DOWN, 0.0)
	assert_eq(boss.e.hp, before, "the shield takes nothing")
	# his dead rise one by one (a rune first), never two in the same moment
	var peak := [game.horde.count() - 1]
	var last := [game.horde.count()]
	_run(def.summon_windup + def.rise_stagger * def.ritual_raise.size() + 0.5, func() -> void:
		assert_lte(game.horde.count() - last[0], 1, "one rises at a time")
		last[0] = game.horde.count()
		peak[0] = maxi(peak[0], game.horde.count() - 1))
	assert_eq(peak[0], def.ritual_raise.size(), "two soldiers and two casters")
	# his dead fall: the ritual ends at once
	for a in game.horde.list.duplicate():
		if a != boss.e:
			game.horde.damage(a, 99999.0, Vector2.DOWN, 0.0)
	_run(0.1)
	assert_ne(boss.state, Boss.State.RITUAL)
	assert_false(boss.e.invulnerable)
	assert_lt(boss.stats.ritual, def.ritual_time)
	_run(20.0, func() -> void:
		if boss.e.invulnerable:
			outside[0] += 1
		assert_lte(game.horde.count() - 1, 6, "never more than 6 of his standing"))
	assert_eq(outside[0], 0, "never invulnerable outside the ritual")
	assert_lte(boss.stats.adds_total, def.adds_total_cap)


func test_the_ritual_ends_by_itself_after_its_time() -> void:
	var boss := _start_fight()
	_run(3.0)
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0)
	_run(8.0)
	assert_eq(boss.state, Boss.State.RITUAL)
	var peak := [0]
	_run(def.ritual_time + 0.5, func() -> void: peak[0] = maxi(peak[0], game.horde.count() - 1))
	assert_ne(boss.state, Boss.State.RITUAL, "over after %d s even with his dead standing" % def.ritual_time)
	assert_lte(peak[0], def.ritual_cap, "reinforcements stop at the ceiling")


func test_the_curse_locks_the_special_but_not_the_attack() -> void:
	_start_fight()
	var pad := Controls.VirtualPad.new()
	var old: Variant = Controls.virtual
	Controls.virtual = pad
	game.player.state = Player.State.MOVE
	assert_true(game.player.apply_curse(def.curse_time, def.curse_slow, def.curse_immunity))
	pad.press(&"heavy_attack")
	game.player.step(1.0 / 60.0, Vector2.ZERO, Vector2.RIGHT)
	assert_false(game.player.runner.is_attacking(), "the special is locked")
	pad.release(&"heavy_attack")
	pad.end_frame()
	pad.press(&"light_attack")
	game.player.step(1.0 / 60.0, Vector2.ZERO, Vector2.RIGHT)
	assert_true(game.player.runner.is_attacking(), "the attack is not")
	Controls.virtual = old


func test_nothing_of_his_outlives_him() -> void:
	var boss := _start_fight()
	_run(3.0)
	# into his last phase, with everything going at once
	boss.e.hp = boss.e.max_hp * 0.16
	boss.phase = 3
	boss.e.hp_floor = boss.e.max_hp * 0.15
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0)
	_run(2.0)
	assert_eq(boss.phase, 4)
	boss._raise(&"skeleton", Vector2(4, 4))
	boss._raise(&"mage", Vector2(-4, 4))
	game.player.apply_curse(def.curse_time, def.curse_slow, def.curse_immunity)
	boss._go(Boss.State.STORM)
	_run(1.2)
	boss._erupt()
	game.projectiles.fire_curse(boss.e.pos, Vector2.DOWN, 7.0, 6.0, 0.5, 4.0, 75.0, 1.4)
	assert_true(game.projectiles.hostile_left())
	assert_false(game.ground.zones.is_empty())
	# the killing blow (the last phase has no floor)
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0)
	assert_eq(boss.state, Boss.State.DYING)
	assert_false(game.projectiles.hostile_left(), "no shot of his flies after him")
	assert_true(game.ground.zones.filter(func(z: Ground.Zone) -> bool: return z.kind == Ground.Kind.WARNING).is_empty(), "no warning stays")
	assert_false(game.player.curse.active(), "the curse lifts")
	await get_tree().process_frame
	assert_eq(game.horde.count(), 0, "his summons go with him")
	_run(Boss.VICTORY_TIME + 0.2)
	assert_null(game.boss)
	assert_false(game.projectiles.hostile_left())
