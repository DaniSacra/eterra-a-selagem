extends GutTest
## SW-R1 (the room budget in head costs, SWORN's Kingswood), SW-R2 (the anchor rooms of the descent), SW-R3 (spawns on the hero's far side).

const STAGE := "res://data/stages/catacombs.tres"

var stage: StageDef
var defs := {}


func before_all() -> void:
	stage = load(STAGE)
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)


func _fight(depth: int, seed_: int) -> EncounterGen.Fight:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	return EncounterGen.generate(stage, depth, defs, rng)


# ---------- SW-R1 ----------

func test_the_costs_are_in_the_data() -> void:
	assert_eq((defs[&"bone_rat"] as EnemyDef).cost_of(), 1, "small")
	assert_eq((defs[&"skeleton"] as EnemyDef).cost_of(), 3, "common")
	assert_eq((defs[&"guard"] as EnemyDef).cost_of(), 5, "heavy")
	assert_gte((defs[&"capitao"] as EnemyDef).cost_of(), 10, "the captain")
	for id in stage.enemies:
		var d := defs[id] as EnemyDef
		assert_gt(d.cost, 0, "%s has a cost of its own" % id)
		if d.elite_version != &"":
			assert_gt((defs[d.elite_version] as EnemyDef).cost, d.cost, "%s: the elite costs more" % id)


func test_a_cost_of_zero_comes_from_the_rating() -> void:
	var d := EnemyDef.new()
	d.rating = 20.0
	assert_eq(d.cost_of(), 12)
	d.cost = 4
	assert_eq(d.cost_of(), 4)


func test_the_curve_climbs_and_breathes_after_each_guardian() -> void:
	var c := stage.cost_curve
	assert_eq(c.size(), 12, "a budget for each of the 12 rooms of fight and guardian")
	assert_lt(c[5], c[3], "room 6, after the first guardian, is lighter than room 4")
	assert_lt(c[10], c[8], "room 11, after the second, is lighter than room 9")
	assert_lt(c[5], c[6], "and climbs again")
	assert_gt(c[11], c[0], "the last room asks more than the first")
	for d in [1, 2, 3, 4]:
		assert_gte(c[d], c[d - 1], "rooms 1 to 4 climb")


func test_a_room_is_a_horde_or_one_or_two_waves() -> void:
	var horde := 0
	var one := 0
	var two := 0
	for i in 200:
		var f := _fight(3, 100 + i)
		if f.mode == EncounterGen.Mode.HORDE:
			horde += 1
			assert_eq(f.waves.size(), 2, "the horde is an initial wave and its reserve")
		elif f.waves.size() == 1:
			one += 1
		else:
			assert_eq(f.waves.size(), 2)
			two += 1
	assert_between(horde, 70, 130, "half are hordes (%d of 200)" % horde)
	assert_gt(one, 20, "some of one wave")
	assert_gt(two, 20, "some of two")


func test_the_heads_cost_about_the_budget() -> void:
	for depth in [1, 2, 4, 6, 8, 9, 12]:
		for i in 12:
			var f := _fight(depth, 50 + i)
			var coef := 1.0
			var total := 0.0
			var dearest := 0.0
			for w in f.waves:
				total += EncounterGen.cost_of(w, defs)
				for id: StringName in w:
					dearest = maxf(dearest, (defs[id] as EnemyDef).cost_of())
			if f.mode == EncounterGen.Mode.HORDE:
				coef = stage.horde_initial + stage.horde_reserve
			elif f.waves.size() == 2:
				coef = stage.wave_coef_two * 2.0
			else:
				coef = stage.wave_coef_one
			var want := EncounterGen.cost_budget(stage, depth) * coef
			assert_lt(total, want * 1.8 + 3.0 * dearest + 8.0, "room %d: %f of %f" % [depth, total, want])
			assert_gt(total, want * 0.4, "room %d: %f of %f (not empty)" % [depth, total, want])


func test_a_depth_past_the_curve_takes_the_old_difficulty() -> void:
	assert_almost_eq(EncounterGen.cost_budget(stage, 40), EncounterGen.difficulty(stage, 40) * stage.cost_per_rating, 0.01)


func test_the_last_wave_of_a_room_may_carry_an_elite() -> void:
	var with_elite := 0
	for i in 30:
		var f := _fight(9, 400 + i)
		for id: StringName in f.waves[f.waves.size() - 1]:
			if (defs[id] as EnemyDef).elite:
				with_elite += 1
				break
	assert_gt(with_elite, 15, "in most of the deep rooms")


# ---------- SW-R2 ----------

func test_the_anchors_are_always_in_place() -> void:
	var R := RunMap.Reward
	var rest := 0
	for run in 300:
		var m := RunMap.new(stage, 700 + run)
		assert_lt(m.failures, RunMap.MAX_TRIES, "a graph kept the rules")
		assert_eq(m.miniboss_depth, 5)
		assert_eq(m.miniboss2_depth, 10)
		for r in m.layer(5):
			assert_eq(r.kind, RunMap.Kind.MINIBOSS, "guardian in room 5")
		for r in m.layer(10):
			assert_eq(r.kind, RunMap.Kind.MINIBOSS, "guardian in room 10")
		for r in m.layer(13):
			assert_eq(r.kind, RunMap.Kind.SHOP, "the shop in a fixed place")
		# PM-4: the rest after the first guardian (6) always; at most three fountains on any way (one before the second guardian)
		for d in [6]:
			var springs := m.layer(d).filter(func(r: RunMap.Room) -> bool: return r.kind == RunMap.Kind.FOUNTAIN)
			assert_eq(springs.size(), 1, "run %d: the rest after the guardian, room %d" % [run, d])
			rest += springs.size()
			assert_eq(m.layer(d).size(), 2, "the two doors stay together")
		assert_lte(_most_fountains(m), 3, "run %d: at most three fountains on any way" % run)
		var fights2 := m.layer(2).filter(func(r: RunMap.Room) -> bool: return r.kind == RunMap.Kind.COMBAT)
		assert_eq(fights2[0].reward, R.BOON, "room 2: a Blessing")
		assert_eq(m.layer(1)[0].reward, R.BOON, "room 1: a Blessing")
		if fights2.size() > 1:
			assert_eq(fights2[1].reward, R.HEART, "room 2: the heart")
		var fights7 := m.layer(7).filter(func(r: RunMap.Room) -> bool: return r.kind == RunMap.Kind.COMBAT)
		assert_eq(fights7[0].reward, R.POM, "room 7: fixed")
		var fights11 := m.layer(11).filter(func(r: RunMap.Room) -> bool: return r.kind == RunMap.Kind.COMBAT)
		assert_eq(fights11[0].reward, R.BOON, "room 11: a Blessing")
		if fights11.size() > 1:
			assert_eq(fights11[1].reward, R.GOLD)
	assert_eq(rest, 300)


func test_the_shorter_descents_keep_no_fixed_door() -> void:
	var st := Rooms.short_stage(stage, 6)
	assert_false(st.rest_after_guardian)
	assert_true(st.fixed_rewards.is_empty())


# ---------- SW-R3 ----------

func test_the_far_side_is_drawn_more_often() -> void:
	var rift := _arena(&"sanctuary")  # (the Fendas left the far-side draw for PM-3: their zones lie on both sides)
	assert_gt(rift.far_spawn, 0.0, "the Santuario draws from the far side")
	var left: Arena = autofree(Arena.new())
	left.layout = rift
	left.spawns = [Rect2(-19, -4, 6, 8), Rect2(13, -4, 6, 8)]
	var hero := Vector2(16, 0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var west := 0
	for i in 400:
		if Rooms.spawn_weights(left, hero)[0] > Rooms.spawn_weights(left, hero)[1]:
			west += 1
	assert_eq(west, 400, "the zone far from the hero weighs more")
	assert_gt(Rooms.spawn_weights(left, hero)[0], 3.0 * Rooms.spawn_weights(left, hero)[1])


func _arena(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


func test_the_fendas_raise_enemies_on_the_far_side_of_the_paladin() -> void:
	# (PM-3: the Fendas keep far_spawn 0 now; the mechanism is tried by setting it here) the hero fights on the east platform: with the far side weighing more, west of the rift rises a share of the heads (late zones open)
	var rift := _arena(&"rift")
	var a: Arena = add_child_autofree(Arena.new())
	a.build(rift, 2, 1406)
	var hero := Vector2(14, 0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var west := {true: 0, false: 0}
	for far in [true, false]:
		rift.far_spawn = 1.5 if far else 0.0
		for i in 300:
			if Rooms.spawn_point(a, hero, rng, true).x < 0.0:
				west[far] += 1
	rift.far_spawn = 0.0
	gut.p("rift, hero east: %d of 300 heads rise west with the far side, %d without" % [west[true], west[false]])
	assert_gt(west[true], west[false] + 40, "the far side is drawn more often (%d against %d of 300)" % [west[true], west[false]])


## PM-4: the most fountains (rests included) any way of the graph passes.
func _most_fountains(m: RunMap) -> int:
	var best := {}
	for d in range(m.last_depth(), 0, -1):
		for r in m.layer(d):
			var below := 0
			for n in r.next:
				below = maxi(below, best[n])
			best[r.id] = below + (1 if r.kind == RunMap.Kind.FOUNTAIN else 0)
	var top := 0
	for r in m.layer(1):
		top = maxi(top, best[r.id])
	return top
