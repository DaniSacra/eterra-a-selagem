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
	assert_eq(EncounterGen.difficulty(stage, 1), 81.0, "70 + 11 a room (14 rooms)")
	assert_eq(EncounterGen.difficulty(stage, 5), 125.0)


func test_waves_carry_about_the_difficulty() -> void:
	for depth in [1, 2]:
		for i in 40:
			var waves := EncounterGen.generate(stage, depth, defs, rng).waves
			assert_between(waves.size(), 1, 3)
			var total := 0.0
			for w in waves:
				assert_false(w.is_empty(), "no empty wave")
				for id: StringName in w:
					total += (defs[id] as EnemyDef).rating
			var want := EncounterGen.difficulty(stage, depth) * EncounterGen.budget(stage, depth)  # (C1b: a room's own share)
			assert_gte(total, want * 0.5, "depth %d" % depth)


func test_the_first_kind_is_in_every_wave() -> void:
	for i in 40:
		var fight := EncounterGen.generate(stage, 2, defs, rng)
		for w: Array in fight.waves:
			assert_true(w.has(fight.kinds[0]), "the highlight kind comes back")


func test_elites_wear_hades_armor() -> void:
	assert_eq((defs[&"skeleton"] as EnemyDef).hp, 95.0, "C1b: the common one 1.6 times tougher, the elite keeps 60 under its armor")
	assert_eq((defs[&"skeleton_elite"] as EnemyDef).armor, 80.0)
	assert_eq((defs[&"skeleton_elite"] as EnemyDef).hp, 60.0, "the elite keeps the same life, armor on top")


func test_map_runs_opening_guardian_shop_boss() -> void:
	var map := RunMap.new(stage, 11)
	var room := map.first()
	assert_eq(room.reward, RunMap.Reward.BOON, "the opening always gives a gift")
	map.enter(room)
	var kinds := []
	var fountains := 0
	while true:
		var doors := map.doors()
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
	assert_eq(kinds.count(RunMap.Kind.MINIBOSS), 2, "both guardians, then Morvath (Daniel, 2026-11-22)")
	assert_eq(kinds[kinds.size() - 2], RunMap.Kind.SHOP)
	assert_eq(map.depth, stage.rooms + 1)
	assert_lte(fountains, 2, "the fountain taken whenever its door shows (one before each guardian)")
	var guardian := kinds.find(RunMap.Kind.MINIBOSS) + 2
	assert_between(guardian, stage.miniboss_depth_min, stage.miniboss_depth_max)


func test_pom_is_only_promised_when_a_gift_can_grow() -> void:
	for s in 30:
		var map := RunMap.new(stage, s)
		for r in map.nodes:
			map.settle(map.doors_of(r), false)
		for r in map.nodes:
			assert_ne(r.reward, RunMap.Reward.POM, "seed %d: settled with nothing to grow" % s)


func test_nobody_stands_inside_a_solid_prop() -> void:
	var stairs := Rect2(-3.5, -14.0, 7.0, 7.4)  # from behind the wall to its foot
	var under := Arena.push_out_of_box(Vector2(0.5, -9.0), 0.5, stairs)
	assert_false(stairs.grow(0.49).has_point(under), "pushed out from under the stairs")
	assert_almost_eq(under.y, stairs.end.y + 0.5, 0.001, "the shortest way out, to the foot")
	var beside := Arena.push_out_of_box(Vector2(3.8, -8.0), 0.5, stairs)
	assert_almost_eq(beside.x, 4.0, 0.001, "a circle touching the side slides along it")
	assert_eq(Arena.push_out_of_box(Vector2(0, 0), 0.5, stairs), Vector2(0, 0), "far away: untouched")


func test_catacomb_hall_keeps_the_fight_on_it() -> void:
	var hall: RoomLayout = stage.layouts[0]
	assert_true(hall.platform, "every room is the catacomb hall")
	var arena := Arena.new()
	add_child_autofree(arena)
	arena.build(hall, 3, 7)
	assert_eq(arena.exits.size(), 3, "the portal, the east stairs and the south stairs")
	# nobody walks off into the abyss, on any side
	for far: Vector2 in [Vector2(30, 0), Vector2(-30, 0), Vector2(0, 30), Vector2(0, -30)]:
		assert_true(arena.on_floor(arena.resolve(far, 0.5), 0.5), "kept on the platform from %s" % far)
	# the middle is clear, and the paladin walks in clear of everything
	assert_eq(arena.resolve(Vector2.ZERO, 0.5), Vector2.ZERO)
	assert_eq(arena.resolve(arena.start, 0.5), arena.start)
	# from the landing by the way in, one walks straight north into the room (no seam between the two floors)
	var p := Vector2(-5.5, arena.start.y)
	for i in 200:
		p = arena.resolve(p + Vector2(0, -0.1), 0.5)
	assert_lt(p.y, 0.0, "walked from the landing into the room")
	# each door is reached from inside: its goal is reachable and leaves by it, its sign floats inside the room
	for i in 3:
		var goal := arena.resolve(arena.door_goal(i), 0.5)
		assert_eq(arena.exit_at(goal), i, "door %d is left by walking to it" % i)
		assert_true(arena.inside(arena.door_label(i)), "door %d's sign is inside" % i)
	assert_eq(arena.exit_at(Vector2.ZERO), -1)


func test_hall_doors_follow_the_count() -> void:
	for n in [0, 1, 2]:
		var arena := Arena.new()
		add_child_autofree(arena)
		arena.build(stage.layouts[0], n, 7)
		assert_eq(arena.exits.size(), n)
