extends GutTest
## Morvath harder (Daniel, 2026-11-23, like the knight): nothing on the floor but the eruptions, a "!" over him before every attack, no
## walking after the paladin (he picks by distance: far the far attacks and his dead, near the scythe), shorter pauses, and in the
## last phases the barrage, a machine gun of crescents one after the other, each aimed at where the paladin stands as it leaves.

const DEF := "res://data/bosses/morvath.tres"
const DT := 1.0 / 60.0

var game: Game
var def: BossDef


func before_all() -> void:
	def = load(DEF)


func _fight() -> Boss:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	return game.boss


func _to_phase(boss: Boss, phase: int) -> void:
	boss.e.hp = boss.e.max_hp * (boss.def.thresholds[phase - 2] + 0.01)
	boss.phase = phase - 1
	boss._ritual_done = phase > boss.def.ritual_phase
	boss.e.hp_floor = boss.e.max_hp * boss.def.thresholds[phase - 2]
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0)
	game._step(DT)


## The paladin runs round the chamber (out of reach and not hurt), watching every step.
func _run(seconds: float, each: Callable) -> void:
	var t := 0.0
	var a := 0.0
	while t < seconds and game.boss != null:
		game.player.invuln = 10.0
		a += DT * 0.35
		game.player.place(Vector2.from_angle(a) * 8.0)
		game._step(DT)
		each.call()
		t += DT


# ---------- the data ----------

func test_the_pace_and_the_choice_by_distance_are_data() -> void:
	assert_lte(def.gap_max, 0.7, "short pauses between attacks")
	assert_lte(def.reap_recovery, 1.5, "the double reap no longer leaves him standing")
	assert_lt(def.near, def.far)
	var by := {}
	for a in def.attacks:
		by[a.id] = a
	assert_lt((by[&"scythe"] as BossAttack).max_dist, 9.0, "the scythe is for when the paladin is near")
	assert_lt((by[&"reap"] as BossAttack).max_dist, 7.0)
	for id in [&"blades", &"barrage", &"curse", &"summon"]:
		assert_lt((by[id] as BossAttack).near_bias, 1.0, "%s is for when he is away" % id)
		assert_gt((by[id] as BossAttack).far_bias, 1.0)
	assert_gt((by[&"barrage"] as BossAttack).weight_in(4), (by[&"barrage"] as BossAttack).weight_in(3), "the last phase leans on it")
	assert_false(by.has(&"storm"), "no fan of crescents any more")
	assert_eq(def.phase_openers[3], &"barrage")
	assert_eq(def.summon_raise, [&"mage", &"mage"] as Array[StringName], "he calls his casters")


func test_far_he_picks_far_attacks_and_near_the_scythe() -> void:
	var d := BossDirector.new(def)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for phase in [3, 4]:
		var near_melee := 0
		var far_melee := 0
		for i in 300:
			d.cooldowns.clear()
			d.history.clear()
			var close := d.choose(phase, 3.0, 0.0, [], rng)
			var away := d.choose(phase, 13.0, 0.0, [], rng)
			near_melee += int(close == &"scythe" or close == &"reap")
			far_melee += int(away == &"scythe" or away == &"reap")
		assert_eq(far_melee, 0, "phase %d: nothing of the foice when the paladin is far" % phase)
		assert_gt(near_melee, 150, "phase %d: near, mostly the foice" % phase)
	var far_late := 0
	for i in 300:
		d.cooldowns.clear()
		d.history.clear()
		var id := d.choose(4, 13.0, 0.0, [], rng)
		far_late += int(id == &"barrage" or id == &"curse" or id == &"summon")
	assert_gt(far_late, 150, "far, in the last phase, mostly the far attacks")


# ---------- the fight ----------

func test_he_does_not_walk_after_the_paladin() -> void:
	var boss := _fight()
	var last := [Vector2.INF, -1]
	var moved := [0.0]
	_run(30.0, func() -> void:
		if boss.state == Boss.State.CHASE and last[1] == Boss.State.CHASE and boss.e.pos.distance_to(last[0]) > 0.0001:
			moved[0] = maxf(moved[0], boss.e.pos.distance_to(last[0]))
		last[0] = boss.e.pos
		last[1] = boss.state)
	assert_eq(moved[0], 0.0, "between attacks he stands")


func test_only_the_eruptions_mark_the_floor() -> void:
	var boss := _fight()
	var seen := {"hidden": 0, "shown": 0, "eruptions": 0}
	var check := func() -> void:
		for z in game.ground.zones:
			if z.kind != Ground.Kind.WARNING or z.source == &"adds":
				continue
			if z.eruption or z.rune != Ground.Rune.NONE:
				seen.eruptions += 1
			elif z.silent and z.node != null and not z.node.visible:
				seen.hidden += 1
			else:
				seen.shown += 1
	_run(30.0, check)
	_to_phase(boss, 3)
	_run(30.0, check)
	_to_phase(boss, 4)
	_run(30.0, check)
	assert_eq(int(seen.shown), 0, "nothing of his on the floor but the eruptions")
	assert_gt(int(seen.hidden), 20, "his attacks' zones were there, hidden")
	assert_gt(int(seen.eruptions), 0, "the eruptions still show")


## Each of his attacks, one by one: the "!" (Horde.strike_in under Feel.bang_lead) lights before it lands.
func test_every_attack_is_announced_by_the_bang() -> void:
	var lead := Feel.live().bang_lead
	for id: StringName in [&"scythe", &"reap", &"blades", &"dash", &"eruptions", &"summon", &"curse", &"barrage"]:
		var boss := _fight()
		_run(2.5, func() -> void: pass)
		_to_phase(boss, 4)
		var mine := BossAttack.new()
		mine.id = id
		mine.cooldown = 0.0
		mine.streak = 99
		boss.director.attacks = [mine] as Array[BossAttack]
		boss.director.openers = [&"", &"", &"", &""] as Array[StringName]
		var announced := [false]
		var landed := [false]
		_run(14.0, func() -> void:
			if boss._attack == id and boss.state != Boss.State.RECOVER:
				var due := game.horde.strike_in(boss.e)
				if due > 0.0 and due <= lead:
					announced[0] = true
			if boss._attack == id:
				landed[0] = true)
		assert_true(landed[0], "%s came" % id)
		assert_true(announced[0], "the '!' lit before %s" % id)
		game.queue_free()
		await get_tree().process_frame


func test_the_barrage_aims_at_the_paladin_every_shot() -> void:
	for phase in [3, 4]:
		var boss := _fight()
		_run(2.5, func() -> void: pass)
		_to_phase(boss, phase)
		var mine := BossAttack.new()
		mine.id = &"barrage"
		mine.streak = 99
		boss.director.attacks = [mine] as Array[BossAttack]
		boss.director.openers = [&"", &"", &"", &""] as Array[StringName]
		var errors: Array[float] = []
		var dirs: Array[Vector2] = []
		var times: Array[float] = []
		var clock := [0.0]
		boss.moment.connect(func(n: StringName) -> void:
			if n == &"barrage_shot":
				var s: Projectiles.Shot = boss._shots.back()
				var want := (game.player.pos - boss.e.pos).normalized()
				errors.append(rad_to_deg(want.angle_to(s.vel.normalized())))
				dirs.append(s.vel.normalized())
				times.append(clock[0]))
		_run(10.0, func() -> void: clock[0] += DT)
		var count := int(BossDef.by_phase(def.barrage_count, phase))
		assert_gte(errors.size(), count, "phase %d: a whole barrage" % phase)
		for i in count:
			assert_lt(absf(errors[i]), 0.5, "phase %d, shot %d: aimed where the paladin stands as it leaves" % [phase, i])
		var turned := 0.0
		for i in range(1, count):
			turned = maxf(turned, absf(rad_to_deg(dirs[i - 1].angle_to(dirs[i]))))
			assert_almost_eq(times[i] - times[i - 1], BossDef.by_phase(def.barrage_gap, phase), 0.05, "one after the other")
		assert_gt(turned, 1.0, "phase %d: it follows the paladin, the shots do not all go one way" % phase)
		game.queue_free()
		await get_tree().process_frame


func test_the_pauses_between_attacks_are_short() -> void:
	var boss := _fight()
	_run(40.0, func() -> void: pass)
	_to_phase(boss, 3)
	_run(40.0, func() -> void: pass)
	var idle: Dictionary = boss.idle.report()
	assert_gt(int(idle.n), 6, "he attacked often")
	assert_lt(float(idle.mean), 0.55, "the mean stand between two attacks (it was 0.65)")
