extends GutTest

var table: WaveTable


func before_each() -> void:
	# the tests below check the designed 15-minute timeline; the shipped pace is checked on its own
	table = (load("res://data/waves/catacombs.tres") as WaveTable).duplicate()
	table.pace = 1.0


func _director(seed_value: int = 1) -> WaveDirector:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return WaveDirector.new(table, rng)


func test_the_run_is_covered_until_the_boss_with_no_gaps() -> void:
	assert_eq(table.boss_time(), 900.0, "Morvath comes at 15 minutes")
	var t := 0.0
	while t < table.boss_time():
		assert_not_null(table.segment_at(t), "no segment at %d s" % int(t))
		t += 5.0


func test_elites_come_at_three_and_ten_minutes() -> void:
	var elites := table.events.filter(func(e: WaveEvent) -> bool: return e.kind == WaveEvent.Kind.ELITE)
	assert_eq(elites.size(), 2)
	assert_eq(elites[0].time, 180.0)
	assert_eq(elites[0].enemy, &"knight")
	assert_eq(elites[1].time, 600.0)
	assert_eq(elites[1].enemy, &"priest")


func test_the_fountain_springs_once() -> void:
	assert_eq(table.events.filter(func(e: WaveEvent) -> bool: return e.kind == WaveEvent.Kind.FOUNTAIN).size(), 1)


func test_density_only_grows_and_reaches_300() -> void:
	var last := 0
	var t := 0.0
	while t < 899.0:
		var cap := table.segment_at(t).cap(t)
		assert_gte(cap, last, "cap dropped at %d s" % int(t))
		last = cap
		t += 10.0
	assert_eq(table.segments[table.segments.size() - 1].cap_end, 300)


func test_every_enemy_in_the_table_exists() -> void:
	for s in table.segments:
		assert_eq(s.weights.size(), s.enemies.size())
		for id in s.enemies:
			assert_true(ResourceLoader.exists("res://data/enemies/%s.tres" % id), String(id))


func test_spawns_follow_the_rate() -> void:
	var d := _director()
	var total := 0
	for i in 600:
		total += d.step(0.1, 0).size()
	# the first minute ramps 0.5 -> 0.75 a second: about 37 spawns
	assert_between(total, 33, 42)


func test_about_120_to_150_enemies_in_the_first_three_minutes() -> void:
	var d := _director()
	var total := 0
	for i in 1800:
		total += d.step(0.1, 0).size()
	assert_between(total, 120, 150)


## Ember and Blade pacing: the common crowd (not the heavy ones) falls in one or two light blows,
## even at three minutes when it has toughened up, before any gift.
## As in Hades II, the common foot soldier falls to one full chain of the attack (20 + 25 + 60), and the
## smallest one to the first two swings.
func test_common_enemies_fall_to_one_attack_chain() -> void:
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	var cut1 := ComboTree.find(tree.neutral, ComboNode.In.LIGHT)
	var chain := cut1.damage + cut1.following()[0].damage + cut1.following()[0].following()[0].damage
	assert_lte((load("res://data/enemies/skeleton.tres") as EnemyDef).hp, chain)
	assert_lte((load("res://data/enemies/runner.tres") as EnemyDef).hp, cut1.damage + cut1.following()[0].damage)


func test_spawns_never_pass_the_cap() -> void:
	var d := _director()
	var alive := 0
	for i in 3000:
		alive += d.step(0.1, alive).size()
		assert_lte(alive, table.segment_at(d.time).cap(d.time) if table.segment_at(d.time) else alive)


func test_a_full_hall_spawns_nothing_and_does_not_bank_spawns() -> void:
	var d := _director()
	for i in 100:
		assert_eq(d.step(0.1, 9999).size(), 0)
	assert_lte(d.step(0.1, 0).size(), 1, "spawns missed while full are not saved up")


func test_events_fire_once_and_in_order() -> void:
	var d := _director()
	var seen: Array[float] = []
	for i in 9100:
		d.step(0.1, 0)
		for e in d.due_events():
			seen.append(e.time)
	assert_eq(seen, [180.0, 420.0, 600.0, 900.0] as Array[float])


func test_stopped_director_keeps_the_clock_but_spawns_nothing() -> void:
	var d := _director()
	d.stopped = true
	assert_eq(d.step(5.0, 0).size(), 0)
	assert_eq(d.time, 5.0)


func test_enemies_get_tougher_with_time() -> void:
	var d := _director()
	assert_eq(d.hp_scale(), 1.0)
	d.step(300.0, 9999)
	assert_almost_eq(d.hp_scale(), 1.0 + table.hp_per_minute * 5.0, 0.001)


func test_only_listed_enemies_are_picked() -> void:
	var d := _director(5)
	var seg := table.segments[2]
	for i in 200:
		assert_true(seg.enemies.has(d.pick(seg)))


func test_levels_cost_more_each_time() -> void:
	for lv in range(1, 40):
		assert_gt(Leveling.needed(lv + 1), Leveling.needed(lv))
	assert_eq(Leveling.needed(1), 5)


func test_experience_carries_over_and_can_give_two_levels() -> void:
	var r := Leveling.add(1, 3, 2)
	assert_eq(r, {"level": 2, "xp": 0, "gained": 1})
	r = Leveling.add(1, 0, Leveling.needed(1) + Leveling.needed(2) + 1)
	assert_eq(r.level, 3)
	assert_eq(r.xp, 1)
	assert_eq(r.gained, 2)


## The MVP plays the timeline five times as fast: Morvath at three minutes of play.
func test_the_shipped_run_meets_morvath_at_three_minutes() -> void:
	var shipped: WaveTable = load("res://data/waves/catacombs.tres")
	assert_almost_eq(shipped.boss_play_time(), 180.0, 0.01)


## A faster timeline brings each stage sooner but spawns at the same rate per second of play.
func test_pace_moves_the_timeline_not_the_spawn_rate() -> void:
	var slow := _director(3)
	var quick_table := table.duplicate() as WaveTable
	quick_table.pace = 5.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var quick := WaveDirector.new(quick_table, rng)
	var slow_n := 0
	var quick_n := 0
	for i in 600:
		slow_n += slow.step(0.05, 0).size()
		quick_n += quick.step(0.05, 0).size()
	assert_almost_eq(slow.time, 30.0, 0.01)
	assert_almost_eq(quick.time, 150.0, 0.01)
	# the quick one is already in denser stages, so it spawns at least as much, never five times as much
	assert_gte(quick_n, slow_n)
	assert_lt(quick_n, slow_n * 5)
