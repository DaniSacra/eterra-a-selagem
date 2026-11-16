extends GutTest
## The ritual's shield breaks when its first dead fall, not the reinforcements (BUG-002 of cycle 10); the HUD reads
## the count (Boss.ritual_left, ritual_total, ritual_changed); its numbers are kept when the paladin falls inside it
## (BUG-009); and a fight begun in the ritual's phase runs the ritual its name promises (BUG-010).

var def: BossDef
var game: Game


func before_all() -> void:
	def = load("res://data/bosses/morvath.tres")


func _start_fight() -> Boss:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	return game.boss


func _run(seconds: float) -> void:
	var t := 0.0
	while t < seconds and game.boss != null:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		t += 1.0 / 60.0


## Into the ritual, with its first dead all risen.
func _into_ritual(boss: Boss) -> void:
	_run(3.0)
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0)
	for i in 10 * 60:
		if boss.state == Boss.State.RITUAL:
			break
		_run(1.0 / 60.0)
	assert_eq(boss.state, Boss.State.RITUAL)
	_run(def.summon_windup + def.rise_stagger * def.ritual_raise.size() + 0.5)


func _adds(boss: Boss) -> Array[Enemy]:
	var out: Array[Enemy] = []
	for a in game.horde.list:
		if a != boss.e and a.alive:
			out.append(a)
	return out


func test_only_the_first_dead_break_the_shield_and_the_count_is_read() -> void:
	var boss := _start_fight()
	var heard: Array = []
	boss.ritual_changed.connect(func(left: int, total: int) -> void: heard.append([left, total]))
	assert_eq(boss.ritual_left(), 0, "no ritual yet")
	_into_ritual(boss)
	assert_eq(boss.ritual_total(), def.ritual_raise.size(), "the ritual begins with its four")
	assert_eq(boss.ritual_left(), def.ritual_raise.size())
	assert_eq(heard[0], [def.ritual_raise.size(), def.ritual_raise.size()], "told when it begins")
	var first := _adds(boss)
	assert_eq(first.size(), def.ritual_raise.size())
	# the reinforcements rise and are not counted
	_run(def.ritual_reinforce_every + def.summon_windup + def.rise_stagger * def.ritual_reinforce.size() + 0.3)
	var more := _adds(boss).filter(func(a: Enemy) -> bool: return not first.has(a))
	assert_gt(more.size(), 0, "reinforcements came")
	assert_eq(boss.ritual_left(), def.ritual_raise.size(), "they are not in the count")
	# three of the first fall: one left, the shield stands
	for i in first.size() - 1:
		game.horde.damage(first[i], 99999.0, Vector2.DOWN, 0.0)
	_run(0.1)
	assert_eq(boss.state, Boss.State.RITUAL)
	assert_eq(boss.ritual_left(), 1)
	assert_eq(heard[heard.size() - 1], [1, def.ritual_raise.size()], "told at each fall")
	# the last of the first falls: the shield breaks with the reinforcements still standing
	game.horde.damage(first[first.size() - 1], 99999.0, Vector2.DOWN, 0.0)
	_run(0.1)
	assert_ne(boss.state, Boss.State.RITUAL, "broken without killing the reinforcements")
	assert_false(boss.e.invulnerable)
	assert_eq(boss.ritual_left(), 0)
	assert_eq(heard[heard.size() - 1], [0, def.ritual_raise.size()], "told when it ends")
	assert_eq(int(boss.stats.ritual_raised), def.ritual_raise.size(), "only the first are counted as raised by it")
	assert_lt(float(boss.stats.ritual), def.ritual_time)


func test_the_ritual_is_measured_when_the_paladin_falls_inside_it() -> void:
	var boss := _start_fight()
	_into_ritual(boss)
	_run(2.0)
	game.player.invuln = 0.0
	game.player.hurt(9999.0, Vector2.ZERO)
	assert_false(game.player.alive())
	assert_gt(float(boss.stats.ritual), 0.0, "how long the ritual had lasted")
	assert_eq(int(boss.stats.ritual_raised), def.ritual_raise.size())
	assert_eq(int(boss.stats.died_phase), def.ritual_phase)


func test_a_fight_begun_in_the_ritual_phase_runs_the_ritual() -> void:
	var boss := _start_fight()
	# what --boss-hp=0.5 sets up: the second phase, the ritual not yet done
	boss.e.hp = boss.e.max_hp * 0.5
	boss.phase = def.ritual_phase
	boss._ritual_done = false
	boss.e.hp_floor = BossRules.hp_floor(boss.phase, def.thresholds) * boss.e.max_hp
	var ritual := [false]
	var t := 0.0
	while t < 10.0 and not ritual[0]:
		_run(1.0 / 60.0)
		ritual[0] = boss.state == Boss.State.RITUAL
		t += 1.0 / 60.0
	assert_true(ritual[0], "the ritual its name promises")
