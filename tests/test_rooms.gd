extends GutTest
## The descent room by room: the encounter generator (Hades II numbers) and the map of rooms and doors.

var stage: StageDef
var defs: Dictionary
var rng: RandomNumberGenerator


func before_each() -> void:
	stage = load("res://data/stages/catacombs.tres")
	defs = {}
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)
	rng = RandomNumberGenerator.new()
	rng.seed = 11


func test_difficulty_grows_with_depth() -> void:
	assert_eq(EncounterGen.difficulty(stage, 1), 70.0)
	assert_eq(EncounterGen.difficulty(stage, 5), 130.0)


func test_cap_and_types_follow_depth() -> void:
	assert_eq(EncounterGen.cap(stage, 1), 4)
	assert_eq(EncounterGen.cap(stage, 9), 7)
	assert_eq(EncounterGen.type_count(stage, 1), 2)
	assert_eq(EncounterGen.type_count(stage, 5), 3)
	assert_eq(EncounterGen.type_count(stage, 20), 3, "never more than max_types")


func test_waves_add_up_to_about_the_difficulty() -> void:
	for depth in [1, 4, 8]:
		for i in 40:
			var waves := EncounterGen.generate(stage, depth, defs, rng)
			assert_between(waves.size(), 1, 3)
			var total := 0.0
			for w in waves:
				assert_false(w.is_empty(), "no empty wave")
				for id: StringName in w:
					total += (defs[id] as EnemyDef).rating
			var want := EncounterGen.difficulty(stage, depth)
			assert_between(total, want * 0.5, want * 2.2, "depth %d" % depth)


func test_the_first_kind_is_in_every_wave() -> void:
	for i in 40:
		var waves := EncounterGen.generate(stage, 6, defs, rng)
		var first: Array = waves[0]
		for w: Array in waves:
			assert_true(w.has(first[0]) or waves[0].has(w[0]), "the highlight kind comes back")


func test_no_elites_early_and_never_two_elite_kinds() -> void:
	for i in 60:
		for id in EncounterGen.pick_types(stage, 1, defs, rng):
			assert_false((defs[id] as EnemyDef).elite, "no elite at depth 1")
		var elites := 0
		var picked := EncounterGen.pick_types(stage, 8, defs, rng)
		for id in picked:
			if (defs[id] as EnemyDef).elite:
				elites += 1
				assert_false(picked.has(StringName(String(id).trim_suffix("_elite"))), "never with its plain version")
		assert_lte(elites, 1)


func test_elites_wear_hades_armor() -> void:
	assert_eq((defs[&"skeleton"] as EnemyDef).hp, 60.0)
	assert_eq((defs[&"skeleton_elite"] as EnemyDef).armor, 80.0)
	assert_eq((defs[&"skeleton_elite"] as EnemyDef).hp, 60.0, "the elite keeps the same life, armor on top")


func test_map_runs_opening_guardian_shop_boss() -> void:
	var map := RunMap.new(stage, rng)
	var room := map.first()
	assert_eq(room.reward, RunMap.Reward.BOON, "the opening always gives a gift")
	map.enter(room)
	var kinds := []
	var fountains := 0
	while true:
		var doors := map.options(true)
		assert_between(doors.size(), 1, 3)
		var rewards := {}
		for d in doors:
			if d.kind == RunMap.Kind.COMBAT:
				assert_false(rewards.has(d.reward), "two doors never promise the same reward")
				rewards[d.reward] = true
		var next := doors[doors.size() - 1]
		for d in doors:
			if d.kind == RunMap.Kind.FOUNTAIN:
				next = d
		map.enter(next)
		kinds.append(next.kind)
		if next.kind == RunMap.Kind.FOUNTAIN:
			fountains += 1
		if next.kind == RunMap.Kind.BOSS:
			break
	assert_eq(kinds.count(RunMap.Kind.MINIBOSS), 1)
	assert_eq(kinds[kinds.size() - 2], RunMap.Kind.SHOP)
	assert_eq(map.depth, stage.rooms + 1)
	assert_eq(fountains, 1, "the fountain comes once (forced at its last depth)")
	var guardian := kinds.find(RunMap.Kind.MINIBOSS) + 2
	assert_between(guardian, stage.miniboss_depth_min, stage.miniboss_depth_max)


func test_pom_is_only_promised_when_a_gift_can_grow() -> void:
	var map := RunMap.new(stage, rng)
	map.enter(map.first())
	for i in 30:
		for d in map.options(false):
			assert_ne(d.reward, RunMap.Reward.POM)


func test_nobody_stands_inside_a_solid_prop() -> void:
	var stairs := Rect2(-3.5, -14.0, 7.0, 7.4)  # from behind the wall to its foot
	var under := Arena.push_out_of_box(Vector2(0.5, -9.0), 0.5, stairs)
	assert_false(stairs.grow(0.49).has_point(under), "pushed out from under the stairs")
	assert_almost_eq(under.y, stairs.end.y + 0.5, 0.001, "the shortest way out, to the foot")
	var beside := Arena.push_out_of_box(Vector2(3.8, -8.0), 0.5, stairs)
	assert_almost_eq(beside.x, 4.0, 0.001, "a circle touching the side slides along it")
	assert_eq(Arena.push_out_of_box(Vector2(0, 0), 0.5, stairs), Vector2(0, 0), "far away: untouched")
