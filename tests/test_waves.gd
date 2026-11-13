extends GutTest

var table: WaveTable


func before_each() -> void:
	table = load("res://data/waves/catacombs.tres")


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


func test_elites_come_at_five_and_ten_minutes() -> void:
	var elites := table.events.filter(func(e: WaveEvent) -> bool: return e.kind == WaveEvent.Kind.ELITE)
	assert_eq(elites.size(), 2)
	assert_eq(elites[0].time, 300.0)
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
	# the first minute ramps 0.7 -> 1.5 a second: about 66 spawns
	assert_between(total, 58, 74)


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
	assert_eq(seen, [300.0, 420.0, 600.0, 900.0] as Array[float])


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
