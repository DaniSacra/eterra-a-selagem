extends GutTest
## C1b, Frente 2 (combate_c1b.md): the bigger soldier and runner (life about 5 times, own longer warning, a second blow or
## burst, one a fight from the 4th room, beside another part, never past 20 bodies) and the budget with breath between rooms.

var stage: StageDef
var defs: Dictionary
var rng: RandomNumberGenerator


func before_each() -> void:
	stage = load("res://data/stages/catacombs.tres")
	defs = {}
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)
	rng = RandomNumberGenerator.new()
	rng.seed = 41


func _bigs(f: EncounterGen.Fight) -> int:
	var n := 0
	for w: Array in f.waves:
		for id: StringName in w:
			if (defs[id] as EnemyDef).big:
				n += 1
	return n


func test_the_bigger_ones_are_data_not_elites() -> void:
	for pair in [[&"skeleton", &"skeleton_big"], [&"runner", &"runner_big"]]:
		var c := defs[pair[0]] as EnemyDef
		var b := defs[pair[1]] as EnemyDef
		assert_eq(c.big_version, pair[1])
		assert_true(b.big)
		assert_false(b.elite)
		assert_eq(b.armor, 0.0)
		assert_eq(b.model, c.model, "the same figure")
		assert_gt(b.size, c.size)
		assert_gte(b.hp, c.hp * 3.0, "about 5 times the common life of before C1b (3 times the 1.6 times tougher one of now)")
		assert_gt(b.attack_windup, c.attack_windup, "its own, longer warning")
		assert_eq(b.strikes, 2, "a second blow, a behavior that already exists")
		assert_gt(b.rating, c.rating, "it pays more gold by rating")
		assert_eq((defs[String(pair[0]) + "_elite"] as EnemyDef).big_version, &"", "an elite has no bigger one")
	assert_eq((defs[&"skeleton_elite"] as EnemyDef).armor, 80.0, "the elites stay as they were")
	assert_ne(T.t(&"enemy_skeleton_big"), "enemy_skeleton_big")
	assert_ne(T.t(&"enemy_runner_big"), "enemy_runner_big")


func test_a_bigger_one_never_comes_as_a_part_of_a_fight() -> void:
	for i in 80:
		var f := EncounterGen.generate(stage, 1 + i % 12, defs, rng)
		for id in f.kinds:
			assert_false((defs[id] as EnemyDef).big, "kinds are drawn, a bigger one is put in")


func test_at_most_one_from_the_4th_room_always_beside_another_kind() -> void:
	var seen := 0
	for i in 400:
		var depth := 1 + i % 12
		var f := EncounterGen.generate(stage, depth, defs, rng)
		var n := _bigs(f)
		assert_lte(n, 1, "one a fight")
		if n > 0:
			seen += 1
			assert_gte(depth, 4, "never before the 4th room")
			assert_gte(f.kinds.size(), 2, "with another part to support")
			var last: Array = f.waves[f.waves.size() - 1]
			var others := 0
			for id: StringName in last:
				if not (defs[id] as EnemyDef).big and (defs[id] as EnemyDef).role != (defs[last.filter(func(x: StringName) -> bool: return (defs[x] as EnemyDef).big)[0]] as EnemyDef).role:
					others += 1
			assert_gt(others, 0, "a head of another role stands beside it")
		for w: Array in f.waves:
			assert_lte(EncounterGen.bodies(w, defs), maxi(f.ceiling, f.kinds.size()) + 1, "within the bodies the room allows")
			assert_lte(f.ceiling, 20)
	assert_gt(seen, 20, "it does come")


func test_no_bigger_one_in_an_arena_with_a_hazard() -> void:
	var room := RoomLayout.new()
	room.hazard = HazardDef.new()
	for i in 200:
		assert_eq(_bigs(EncounterGen.generate(stage, 6 + i % 6, defs, rng, 1.0, room)), 0)


func test_add_big_pays_with_heads_and_keeps_the_other_kind() -> void:
	var f := EncounterGen.Fight.new()
	f.kinds = [&"skeleton", &"mage"] as Array[StringName]
	var w: Array[StringName] = [&"skeleton", &"skeleton", &"skeleton", &"skeleton", &"skeleton", &"mage"]
	f.waves = [w] as Array[Array]
	assert_true(EncounterGen.add_big(f, Vector2i(3, 6), defs, rng))
	assert_eq(w.count(&"skeleton_big"), 1)
	assert_eq(w.count(&"mage"), 1)
	assert_gte(w.count(&"skeleton"), 1)
	var lone := EncounterGen.Fight.new()
	lone.kinds = [&"skeleton"] as Array[StringName]
	lone.waves = [[&"skeleton", &"skeleton"] as Array[StringName]] as Array[Array]
	assert_false(EncounterGen.add_big(lone, Vector2i(3, 6), defs, rng), "never alone")


func test_the_budget_has_a_valley_after_a_hard_room_and_starts_light() -> void:
	assert_eq(EncounterGen.budget(stage, 1), stage.room_budget[0])
	assert_lt(stage.room_budget[0], 0.8, "the first rooms are small")
	for d in [4, 8, 12]:
		assert_lt(stage.room_budget[d - 1], stage.room_budget[d - 2], "room %d is easier than the one before" % d)
	assert_eq(EncounterGen.budget(stage, 40), 1.0, "past the list: whole")
	for v in stage.room_budget:
		assert_between(v, 0.5, 1.0)


func test_two_parts_or_more_from_the_3rd_room() -> void:
	for depth in range(3, 13):
		for i in 30:
			var f := EncounterGen.generate(stage, depth, defs, rng)
			if f.kinds.is_empty():
				continue
			assert_gte(f.kinds.size(), 2, "depth %d" % depth)
			assert_lte(f.cap, 20)
