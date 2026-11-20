extends GutTest
## Morvath's fight refined (cycle 9, Daniel's brief): reinforcements one by one under both ceilings, the storm's
## crescents leaving in turn, phase openers, combinations that never stack two attacks and always leave a way out,
## recoveries counted as windows, every effect drawn only over what hurts, the fight's numbers by attack, the short
## ending that keeps the paladin's control, and the bot's human reaction time.

const DEF := "res://data/bosses/morvath.tres"
const SAFE_SHARE := 0.8
const FLOOR := Rect2(-14.3, -13.3, 28.6, 26.6)

var def: BossDef


func before_all() -> void:
	def = load(DEF)


func _walk() -> float:
	return Feel.live().speed


# ---------- reinforcements ----------

func test_reinforcements_count_those_still_rising_and_stop_at_twenty() -> void:
	assert_eq(def.adds_total_cap, 20)
	assert_gt(def.rise_stagger, 0.2, "never all at once")
	assert_eq(BossRules.reinforce_room(4, 0, 0, 6, 0, 20), 4)
	assert_eq(BossRules.reinforce_room(4, 2, 2, 6, 4, 20), 2, "the rising count as standing")
	assert_eq(BossRules.reinforce_room(4, 0, 6, 6, 6, 20), 0)
	assert_eq(BossRules.reinforce_room(4, 0, 0, 6, 18, 20), 2, "the fight's ceiling")
	assert_eq(BossRules.reinforce_room(4, 0, 0, 6, 20, 20), 0)
	assert_eq(BossRules.reinforce_room(4, 0, 0, 6, 25, 20), 0, "never negative")
	assert_eq(BossRules.reinforce_room(0, 0, 0, 6, 0, 20), 0)


func test_the_dead_rise_one_by_one() -> void:
	var t := BossRules.rise_times(4, 0.7, def.rise_stagger)
	assert_eq(t.size(), 4)
	assert_almost_eq(t[0], 0.7, 0.001)
	for i in range(1, t.size()):
		assert_almost_eq(t[i] - t[i - 1], def.rise_stagger, 0.001)
	assert_eq(BossRules.rise_times(0, 0.7, 0.4).size(), 0)
	assert_eq(BossRules.rise_times(-2, 0.7, 0.4).size(), 0)


func test_the_ritual_is_not_over_while_its_dead_still_rise() -> void:
	assert_false(BossRules.ritual_over(1.0, def.ritual_time, 1, 0, 3), "the first fell, three still rising")
	assert_false(BossRules.ritual_over(1.0, def.ritual_time, 0, 0, 4), "none up yet")
	assert_true(BossRules.ritual_over(1.0, def.ritual_time, 4, 0, 0))
	assert_true(BossRules.ritual_over(def.ritual_time, def.ritual_time, 0, 0, 4), "time is up all the same")


# ---------- the storm ----------

func test_the_storm_leaves_in_turn_nearest_the_aim_first() -> void:
	var rng := RandomNumberGenerator.new()
	assert_gt(def.storm_stagger, 0.0)
	for i in 100:
		rng.seed = 300 + i
		var aim := Vector2.from_angle(rng.randf() * TAU)
		var dirs := BossRules.storm(def.storm_count, rad_to_deg(aim.angle()), def.storm_jitter, def.storm_min_gap, rng)
		var order := BossRules.storm_order(dirs, aim)
		assert_eq(order.size(), dirs.size())
		var seen := {}
		for k in order:
			seen[k] = true
		assert_eq(seen.size(), dirs.size(), "every crescent once")
		for k in dirs.size():
			assert_lte(absf(aim.angle_to(dirs[order[0]])), absf(aim.angle_to(dirs[k])) + 0.0001)
	assert_eq(BossRules.storm_order(PackedVector2Array(), Vector2.RIGHT).size(), 0)


# ---------- phases and combinations ----------

func test_each_phase_opens_on_its_own_pattern() -> void:
	var d := BossDirector.new(def)
	assert_eq(d.opener(1), &"")
	assert_eq(d.opener(2), &"", "the ritual opens the second by itself")
	assert_eq(d.opener(3), &"curse")
	assert_eq(d.opener(4), &"storm")
	assert_eq(d.opener(3, [&"curse"] as Array[StringName]), &"", "not when blocked")
	assert_eq(d.opener(9), &"")
	assert_eq(d.opener(0), &"")


func test_combinations_come_only_in_the_last_phase_and_never_repeat() -> void:
	var d := BossDirector.new(def)
	var rng := RandomNumberGenerator.new()
	rng.seed = 86  # BUG-109: the same draws, the same asserts, every run
	var seen := {}
	for i in 600:
		var id: StringName = [&"scythe", &"storm", &"eruptions", &"blades", &"dash", &"curse", &"summon"][i % 7]
		for phase in [1, 2, 3]:
			assert_eq(d.follow_up(id, phase, rng), &"", "%s in phase %d" % [id, phase])
		var next := d.follow_up(id, 4, rng)
		assert_ne(next, id)
		if next != &"":
			seen[id] = next
			assert_true(d.attacks.any(func(a: BossAttack) -> bool: return a.id == next and a.allowed_in(4)))
	assert_eq(seen, {&"scythe": &"storm", &"storm": &"dash", &"eruptions": &"scythe"})
	assert_true(BossRules.chain_ready(0, 0))
	assert_false(BossRules.chain_ready(1, 0), "a warning of the first still on the floor")
	assert_false(BossRules.chain_ready(0, 2), "its crescents still flying")


## The hazard of an attack aimed from `boss` at `at` (rng for the patterns that draw lots), and how long it warns.
func _hazard(id: StringName, boss: Vector2, at: Vector2, rng: RandomNumberGenerator) -> Array:
	var aim := (at - boss).normalized() if at.distance_to(boss) > 0.1 else Vector2.DOWN
	var w := BossDef.by_phase(def.windup_scale, 4)
	match id:
		&"scythe":
			var z := _zone(Ground.Shape.ARC, boss, aim, def.scythe_reach, def.scythe_degrees)
			return [func(q: Vector2) -> bool: return Ground.inside(z, q, Player.RADIUS * 0.6), def.scythe_windup * w]
		&"dash":
			var z := _zone(Ground.Shape.LINE, boss, aim, def.dash_length, def.dash_width)
			return [func(q: Vector2) -> bool: return Ground.inside(z, q, Player.RADIUS * 0.6), def.dash_windup * w]
		&"storm":
			var dirs := BossRules.storm(def.storm_count, rad_to_deg(aim.angle()), def.storm_jitter, def.storm_min_gap, rng)
			return [func(q: Vector2) -> bool:
				for d in dirs:
					if _in_soul_lane(boss, d, q):
						return true
				return false, def.storm_windup * w]
		&"eruptions":
			var spots := BossRules.eruptions(at, rng.randi_range(def.eruption_count.x, def.eruption_count.y), def.eruption_radius, Vector2.ZERO, def.eruption_lane, FloorShape.rect(FLOOR.size * 0.5, FLOOR.get_center()), rng)
			return [func(q: Vector2) -> bool:
				for s in spots:
					if q.distance_to(s) <= def.eruption_radius + Player.RADIUS * 0.6:
						return true
				return false, def.eruption_delay * w]
	return [func(_q: Vector2) -> bool: return false, 1.0]


func _zone(shape: Ground.Shape, at: Vector2, dir: Vector2, radius: float, width: float) -> Ground.Zone:
	var z := Ground.Zone.new()
	z.shape = shape
	z.pos = at
	z.dir = dir
	z.radius = radius
	z.width = width
	return z


func _in_soul_lane(from: Vector2, dir: Vector2, p: Vector2) -> bool:
	var d := p - from
	var along := d.dot(dir)
	return along >= -(Projectiles.SOUL_DEPTH + Player.RADIUS) and along <= def.blade_range and absf(d.cross(dir)) <= def.blade_width * 0.5 + Player.RADIUS * 0.5


## The safe points within walking distance (on the floor, out of the hazard, not inside the boss).
func _ways_out(p: Vector2, boss: Vector2, reach: float, hazard: Callable) -> PackedVector2Array:
	var out := PackedVector2Array()
	if not hazard.call(p):
		out.append(p)
	for ring in 16:
		var r := reach * (ring + 1) / 16.0
		for k in 48:
			var q := p + Vector2.from_angle(TAU * k / 48.0) * r
			if FLOOR.has_point(q) and q.distance_to(boss) > 1.4 + Player.RADIUS and not hazard.call(q):
				out.append(q)
	return out


## Every combination of the last phase: from anywhere, a way out of the first blow, and from wherever that way out
## leads, a way out of the second (aimed at him there, with only its own warning: chain_ready keeps them apart).
func test_every_combination_leaves_a_way_out_of_both_blows() -> void:
	var rng := RandomNumberGenerator.new()
	var pairs := {}
	for a in def.attacks:
		if a.then != &"" and a.then_from_phase > 0:
			pairs[a.id] = a.then
	assert_eq(pairs.size(), 3)
	for first: StringName in pairs:
		var second: StringName = pairs[first]
		var tried := 0
		for i in 120:
			rng.seed = 7000 + i
			var boss := Vector2(rng.randf_range(-11, 11), rng.randf_range(-10, 10))
			var p := boss + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(2.2, 12.0)
			if not FLOOR.has_point(p):
				continue
			var h1 := _hazard(first, boss, p, rng)
			var outs := _ways_out(p, boss, _walk() * float(h1[1]) * SAFE_SHARE, h1[0])
			assert_false(outs.is_empty(), "%s seed %d: a way out of the first" % [first, i])
			if outs.is_empty():
				continue
			# the hardest place the first leaves him in: the way out nearest the boss (the dash only comes from 9 m: the
			# nearest of those; with none the director picks another attack, tested alone)
			var least := 9.0 if second == &"dash" else 0.0
			var q := Vector2.INF
			for o in outs:
				if o.distance_to(boss) >= least and (q == Vector2.INF or o.distance_to(boss) < q.distance_to(boss)):
					q = o
			if q == Vector2.INF:
				continue
			tried += 1
			var h2 := _hazard(second, boss, q, rng)
			assert_false(_ways_out(q, boss, _walk() * float(h2[1]) * SAFE_SHARE, h2[0]).is_empty(),
				"%s then %s seed %d: a way out of the second" % [first, second, i])
		assert_gt(tried, 10, "%s then %s was tried" % [first, second])


func test_a_cursed_paladin_can_still_walk_out_of_every_warning() -> void:
	# the curse slows him: his warnings last as much longer, so walking out stays as possible as uncursed
	var c := CurseState.new()
	assert_eq(BossRules.cursed_windup(0.8, c.speed_scale()), 0.8, "uncursed: the same")
	c.apply(def.curse_time, def.curse_slow, def.curse_immunity)
	var windup := BossRules.cursed_windup(def.scythe_windup * BossDef.by_phase(def.windup_scale, 4), c.speed_scale())
	assert_almost_eq(windup * c.speed_scale(), def.scythe_windup * BossDef.by_phase(def.windup_scale, 4), 0.001)
	var rng := RandomNumberGenerator.new()
	var reach := _walk() * c.speed_scale() * windup * SAFE_SHARE
	for i in 300:
		rng.seed = 11000 + i
		var boss := Vector2(rng.randf_range(-11, 11), rng.randf_range(-10, 10))
		var p := boss + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(1.4 + Player.RADIUS, def.scythe_reach)
		if not FLOOR.has_point(p):
			continue
		var h := _hazard(&"scythe", boss, p, rng)
		# pinned in a corner of the hall (as uncursed) the dodge is the way out: the curse never locks it
		var cornered := not FLOOR.grow(-2.0).has_point(p)
		var dodge := Feel.live().dodge_speed * Feel.live().dodge_time * 0.75 if cornered else 0.0
		assert_false(_ways_out(p, boss, reach + dodge, h[0]).is_empty(), "seed %d: cursed, still a way out %s %s" % [i, boss, p])


func test_phase_times_add_up() -> void:
	assert_eq(BossRules.phase_times([30.0, 80.0, 100.0], 120.0), [30.0, 50.0, 20.0, 20.0] as Array[float])
	assert_eq(BossRules.phase_times([], 42.0), [42.0] as Array[float])


# ---------- what is drawn ----------

func test_the_scythe_and_the_dash_are_drawn_only_over_what_they_hurt() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var fx := game.fx
	var dir := Vector2.from_angle(0.7)
	fx.boss_scythe(Vector2(2, 3), dir, def.scythe_reach, def.scythe_degrees, 0.16, 0.55, Boss.VIOLET, Boss.SPECTRAL)
	assert_eq(fx.showing(&"boss_scythes"), 1)
	var z := _zone(Ground.Shape.ARC, Vector2(2, 3), dir, def.scythe_reach, def.scythe_degrees)
	for e: Dictionary in fx._boss_scythes:
		var mi: MeshInstance3D = e.node
		if not mi.visible:
			continue
		var arrays := mi.mesh.surface_get_arrays(0)
		for v: Vector3 in arrays[Mesh.ARRAY_VERTEX]:
			var w := mi.global_transform * v
			var d := Vector2(w.x, w.z) - z.pos
			assert_lte(d.length(), z.radius + 0.01, "a corner of the scythe past its reach")
			if d.length() > 0.6:
				assert_lte(rad_to_deg(absf(dir.angle_to(d))), def.scythe_degrees * 0.5 + 0.1, "a corner of the scythe outside its half circle")
	fx.boss_dash(Vector2(-3, 1), dir, def.dash_length, def.dash_width, def.dash_time, def.dash_time + 0.5, Boss.VIOLET, Boss.SPECTRAL)
	assert_eq(fx.showing(&"boss_wakes"), 1)
	var lane := _zone(Ground.Shape.LINE, Vector2(-3, 1), dir, def.dash_length, def.dash_width)
	for e: Dictionary in fx._boss_wakes:
		var mi: MeshInstance3D = e.node
		if not mi.visible:
			continue
		for v: Vector3 in mi.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
			var w := mi.global_transform * v
			assert_true(Ground.inside(lane, Vector2(w.x, w.z), 0.05), "a corner of the wake outside its lane")


func test_a_crescent_trail_stays_inside_its_hit() -> void:
	assert_almost_eq(Projectiles.SOUL_TRAIL, Projectiles.SOUL_DEPTH + Player.RADIUS, 0.001, "back as far as it hits")
	assert_lt(Projectiles.SOUL_TRAIL_WIDTH, 1.0, "narrower than the crescent")


# ---------- the fight in a real game ----------

var game: Game


func _start_fight() -> Boss:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	return game.boss


func _run(seconds: float, each: Callable = Callable(), safe: bool = true) -> void:
	var t := 0.0
	while t < seconds and game.boss != null:
		if safe:
			game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		if each.is_valid():
			each.call()
		t += 1.0 / 60.0


func _to_phase(boss: Boss, phase: int) -> void:
	_run(3.0)
	boss.e.hp = boss.e.max_hp * (def.thresholds[phase - 2] + 0.01)
	boss.phase = phase - 1
	boss._ritual_done = true
	boss.e.hp_floor = boss.e.max_hp * def.thresholds[phase - 2]
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0)
	_run(0.1)
	assert_eq(boss.phase, phase)


## The attacks of his that can hurt right now: the sources of his damaging warnings and of his shots in the air.
func _live_attacks() -> Dictionary:
	var live := {}
	for z in game.ground.zones:
		if z.kind == Ground.Kind.WARNING and z.power > 0.0 and z.source != &"" and z.source != &"adds":
			live[z.source] = true
	for s in game.projectiles.shots:
		if Projectiles.hostile(s) and s.source != &"":
			live[s.source] = true
	return live


func test_in_the_last_phase_combinations_never_stack_two_attacks() -> void:
	var boss := _start_fight()
	_to_phase(boss, 4)
	# every combination always, for the test (the director's own copies of the attacks); no layers here: a layer is
	# laid over its attack on purpose (E2), tested in test_layers_lay_only_eruptions_and_his_dead_over_an_attack
	var mine: Array[BossAttack] = []
	for a in boss.director.attacks:
		var c: BossAttack = a.duplicate()
		if c.then != &"":
			c.then_chance = 1.0
		c.layer_chance = 0.0
		mine.append(c)
	boss.director.attacks = mine
	var most := [0]
	var opened := [&""]
	boss.moment.connect(func(n: StringName) -> void:
		if opened[0] == &"" and Boss.ATTACKS.has(n):
			opened[0] = n)
	var spots := [Vector2(0, 6), Vector2(-9, -6), Vector2(10, 8), Vector2(3, -2)]
	for k in 6:
		game.player.place(spots[k % spots.size()])
		_run(6.0, func() -> void: most[0] = maxi(most[0], _live_attacks().size()))
	assert_eq(opened[0], &"storm", "the last phase opens on the storm")
	assert_gt(int(boss.stats.chains), 0, "combinations happened")
	assert_eq(most[0], 1, "never two of his attacks able to hurt at once")


## E2: late in the fight eruptions and his dead are laid over an attack (BossAttack.layers): at most that attack and
## eruptions can hurt at once (never two of his attacks proper), his dead never pass the phase's ceiling nor the
## fight's, and they rise away from the paladin. Every layer always, for the test.
func test_layers_lay_only_eruptions_and_his_dead_over_an_attack() -> void:
	for phase in [3, 4]:
		var boss := _start_fight()
		_to_phase(boss, phase)
		var mine: Array[BossAttack] = []
		for a in boss.director.attacks:
			var c: BossAttack = a.duplicate()
			c.then_chance = 0.0
			if not c.layers.is_empty():
				c.layer_chance = 1.0
			mine.append(c)
		boss.director.attacks = mine
		var cap := BossRules.adds_cap(def.adds_cap, phase)
		var worst := {"live": 0, "proper": 0, "adds": 0, "near": INF}
		var spots := [Vector2(0, 6), Vector2(-9, -6), Vector2(10, 8), Vector2(3, -2)]
		boss.cue.connect(func(n: StringName, at: Vector2, _d: Vector2, _s: float, _t: float) -> void:
			if n == &"rune":
				worst.near = minf(worst.near, at.distance_to(game.player.pos)))
		for k in 6:
			game.player.place(spots[k % spots.size()])
			_run(6.0, func() -> void:
				var live := _live_attacks()
				worst.live = maxi(worst.live, live.size())
				worst.proper = maxi(worst.proper, live.keys().filter(func(id: StringName) -> bool: return id != &"eruptions").size())
				worst.adds = maxi(worst.adds, Boss._standing(boss._adds)))
		var layers: Dictionary = boss.stats.layers
		assert_gt(int(layers.get(&"eruptions", 0)), 0, "phase %d: eruptions were laid over an attack" % phase)
		assert_gt(int(layers.get(&"summon", 0)), 0, "phase %d: his dead rose over an attack" % phase)
		assert_lte(worst.live, 2, "phase %d: an attack and its eruptions, nothing more" % phase)
		assert_lte(worst.proper, 1, "phase %d: never two of his attacks proper at once" % phase)
		assert_lte(worst.adds, cap, "phase %d: his dead never pass the ceiling" % phase)
		assert_lte(int(boss.stats.adds_total), def.adds_total_cap, "the fight's ceiling")
		assert_gte(worst.near, def.summon_clear - 0.01, "phase %d: his dead rise away from the paladin" % phase)
		game.queue_free()
		game = null


func test_the_storm_crescents_leave_one_at_a_time() -> void:
	var boss := _start_fight()
	_to_phase(boss, 4)
	game.player.place(Vector2(0, 8))
	boss._attack = &"storm"
	boss._go(Boss.State.STORM)
	var most := [0]
	var fired := [0]
	var before := [0]
	var wave := def.storm_windup + def.storm_stagger * (def.storm_count - 1) + def.storm_gap
	_run(wave * def.storm_waves + 1.0, func() -> void:
		var now := game.projectiles.shots.filter(func(s: Projectiles.Shot) -> bool: return s.kind == Projectiles.Kind.SOUL).size()
		if now > before[0]:
			most[0] = maxi(most[0], now - before[0])
			fired[0] += now - before[0]
		before[0] = now)
	assert_eq(fired[0], def.storm_count * def.storm_waves, "every wave of six")
	assert_eq(most[0], 1, "never two crescents in the same instant")


func test_recoveries_are_windows_and_blows_in_them_count() -> void:
	var boss := _start_fight()
	_run(3.0)
	game.player.place(boss.e.pos + Vector2(0, 3))
	boss._attack = &"scythe"
	boss._go(Boss.State.SCYTHE)
	var windows := int(boss.stats.windows)
	_run(1.2)
	assert_eq(boss.state, Boss.State.RECOVER, "spent after the sweep")
	assert_eq(int(boss.stats.windows), windows + 1)
	var punished := int(boss.stats.punished)
	game.combat.enemy_struck.emit(boss.e, [] as Array[StringName], 10.0)
	game.combat.enemy_struck.emit(boss.e, [] as Array[StringName], 10.0)
	assert_eq(int(boss.stats.punished), punished + 1, "one window, punished once")


func test_what_hurt_the_paladin_is_counted_by_attack() -> void:
	var boss := _start_fight()
	_run(3.0)
	game.player.place(boss.e.pos + Vector2(0, 2.5))
	game.player.invuln = 0.0
	boss._attack = &"scythe"
	boss._go(Boss.State.SCYTHE)
	_run(1.5, Callable(), false)
	assert_gt(int((boss.stats.hurt_by as Dictionary).get(&"scythe", 0)), 0, "the scythe hurt him")
	assert_eq(int((boss.stats.hits_by as Dictionary).get(&"scythe", 0)), 1)


func test_the_ending_is_short_and_keeps_control_then_signals() -> void:
	var boss := _start_fight()
	_to_phase(boss, 4)
	var started := [0]
	var finished := [{}]
	game.victory_started.connect(func() -> void: started[0] += 1)
	game.victory_finished.connect(func(stats: Dictionary) -> void: finished[0] = stats)
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0)
	assert_eq(boss.state, Boss.State.DYING)
	assert_eq(started[0], 1)
	assert_between(Boss.VICTORY_TIME, 3.0, 5.0, "a short ending")
	var t := [0.0]
	_run(10.0, func() -> void:
		t[0] += 1.0 / 60.0
		if game.boss != null:
			assert_eq(game.mode, Game.Mode.PLAY, "the paladin keeps his control while it plays"))
	assert_almost_eq(t[0], Boss.VICTORY_TIME, 0.05)
	assert_null(game.boss)
	assert_eq(game.mode, Game.Mode.ENDING)
	assert_true((finished[0] as Dictionary).has("time"), "the fight's numbers go with the signal")
	assert_eq((finished[0] as Dictionary).phase_time.size(), (finished[0] as Dictionary).phase_at.size() + 1)


func _beams_shown() -> int:
	var n := 0
	for b in game.fx._beams:
		if (b.node as Node3D).visible:
			n += 1
	return n


func test_his_dead_rise_out_of_summoning_circles_with_one_column_each() -> void:
	var boss := _start_fight()
	_run(3.0)
	var ids: Array[StringName] = [&"skeleton", &"skeleton"]
	var n := boss._call(ids, boss.e.pos, def.summon_ring, 6, 0.5, false)
	assert_eq(n, 2)
	var circles: Array[Ground.Zone] = []
	for z in game.ground.zones:
		if z.rune == Ground.Rune.SUMMON:
			circles.append(z)
	assert_eq(circles.size(), n, "one circle of summoning (Ground.Rune.SUMMON) under each")
	for z in circles:
		assert_eq(z.power, 0.0, "it hurts no one")
		assert_eq(z.source, &"adds")
	var beams := _beams_shown()
	var last := [int(boss.stats.adds_total), game.ground.dissolving()]
	var risen := int(boss.stats.adds_total)
	_run(0.5 + def.rise_stagger * n + 0.1, func() -> void:
		var up := int(boss.stats.adds_total) - int(last[0])
		if up > 0:
			# the dead stands up the step its circle lands, under that circle's column, and no other light
			assert_eq(game.ground.dissolving() - int(last[1]), up, "a column for each risen, the same step")
			assert_eq(_beams_shown(), beams, "no second column of light over his circle")
		last[0] = int(boss.stats.adds_total)
		last[1] = game.ground.dissolving())
	assert_eq(int(boss.stats.adds_total) - risen, n)


func test_a_summoning_ended_early_raises_no_column() -> void:
	var boss := _start_fight()
	_run(3.0)
	var ids: Array[StringName] = [&"skeleton"]
	boss._call(ids, boss.e.pos, def.summon_ring, 6, 1.0, true)
	var columns := game.ground.dissolving()
	for r in boss._rising:
		Ground.end_zone(r.rune)
	boss._rising.clear()
	_run(0.1)
	assert_eq(game.ground.dissolving(), columns, "the dead stays down and no energy rises")


# ---------- the bot ----------

func test_the_bot_answers_a_danger_only_after_its_reaction_time() -> void:
	var bot := Bot.new()
	bot.reaction = 0.25
	var out := Vector2.RIGHT
	var seen: Array[Vector2] = []
	for i in 30:
		bot._t = i / 60.0
		seen.append(bot._react(out))
	assert_eq(seen[0], Vector2.ZERO)
	assert_eq(seen[14], Vector2.ZERO, "0.23 s: not yet")
	assert_eq(seen[15], out, "0.25 s: now")
	var quick := Bot.new()
	quick.reaction = 0.0
	assert_eq(quick._react(out), out, "the old bot answers at once")


func test_blows_on_his_ward_neither_flash_nor_burn_him() -> void:
	var boss := _start_fight()
	_run(3.0)
	game.boons.take(load("res://data/boons/02_lamina_ardente.tres") as Boon)
	boss.e.burn_t = 2.0
	boss._start_ritual()
	assert_eq(boss.e.burn_t, 0.0, "a fire laid before the ward goes out under it")
	var hp := boss.e.hp
	var combo := game.combat.combo
	var finisher: Array[StringName] = [&"finisher"]
	game.combat.hit_enemy(boss.e, 60.0, finisher, Vector2.DOWN, 5.0, true, true)
	assert_eq(boss.e.hp, hp, "no damage through the ward")
	assert_lte(boss.e.flash_t, 0.0, "no flash on the ward")
	assert_eq(boss.e.burn_t, 0.0, "no burn through the ward")
	assert_eq(game.combat.combo, combo, "the ward does not feed the combo")


func test_fire_on_the_ground_does_not_take_hold_through_his_ward() -> void:
	var boss := _start_fight()
	_run(3.0)
	boss._start_ritual()
	var z := Ground.Zone.new()
	z.kind = Ground.Kind.EMBER
	z.power = 6.0
	game.combat.on_zone_hit(boss.e, z)
	game.combat.skill_hit(boss.e, 10.0, [] as Array[StringName], Vector2.DOWN, 0.0, &"burn", 6.0)
	assert_eq(boss.e.burn_t, 0.0, "embers and burning skills do not set him alight under the ward")


## C17, Q-09 (b): the Blades come close too: with the paladin within blade_step_within he steps back first, and both
## lanes start where he ends (never behind him), the crescents leaving from there.
func test_the_blades_step_back_when_he_is_close() -> void:
	var boss := _start_fight()
	_run(3.0)
	assert_eq(boss.def.attacks.filter(func(a: BossAttack) -> bool: return a.id == &"blades")[0].min_dist, 0.0)
	var at := boss.e.pos
	game.player.place(at + Vector2(0.0, 2.6))
	boss._attack = &"blades"
	boss._go(Boss.State.BLADES)
	_run(1.0 / 60.0)
	var lanes := game.ground.zones.filter(func(z: Ground.Zone) -> bool: return z.shape == Ground.Shape.LINE)
	assert_eq(lanes.size(), 2)
	_run(def.blade_step_time + 0.05)
	var back := boss.e.pos
	assert_almost_eq(back.distance_to(at), def.blade_step, 0.3, "a step back")
	assert_gt(back.distance_to(game.player.pos), at.distance_to(game.player.pos))
	for z: Ground.Zone in lanes:
		assert_lt(Vector2(z.node.position.x, z.node.position.z).distance_to(back + z.dir * z.radius * 0.5), 0.05,
			"each lane starts where he stands")
	var before := game.projectiles.shots.size()
	_run(def.blade_windup)
	assert_gt(game.projectiles.shots.size(), before, "the crescents left")
