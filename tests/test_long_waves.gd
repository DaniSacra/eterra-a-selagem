extends GutTest
## RD2-06 (the short rooms' rhythm) and RD2-10 (WallAim): a room at one of StageDef.long_depths always comes in 3 waves, each
## lighter, the last with an elite when a kind of the fight has one (from elite_from_depth); the others are as they were.
## The wall the charge ends against is found along its line.

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


func test_the_short_rooms_are_long() -> void:
	for depth in [2, 3, 4, 6, 7, 8, 9]:
		assert_true(EncounterGen.is_long(stage, depth), "room %d is long" % depth)
	for depth in [1, 5, 10]:
		assert_false(EncounterGen.is_long(stage, depth), "room %d is not" % depth)


func test_three_waves_the_last_with_an_elite() -> void:
	var with_elite := 0
	var tried := 0
	for depth in [4, 6, 7, 8, 9]:
		for seed_ in 12:
			var f := _fight(depth, seed_ + 1)
			if f.waves.is_empty():
				continue
			tried += 1
			assert_eq(f.waves.size(), 3, "room %d seed %d: 3 waves" % [depth, seed_])
			var last: Array = f.waves[2]
			var elite := false
			for id: StringName in last:
				elite = elite or (defs[id] as EnemyDef).elite
			var could := false
			for id in f.kinds:
				could = could or (defs[id] as EnemyDef).elite or ((defs[id] as EnemyDef).elite_version != &"" and defs.has((defs[id] as EnemyDef).elite_version))
			if could:
				assert_true(elite, "room %d seed %d: the last wave carries an elite" % [depth, seed_])
				with_elite += 1
			for w in f.waves:
				assert_gte(EncounterGen.bodies(w, defs), 1)
	assert_gt(with_elite, tried / 2, "most of them could")


func test_the_life_is_about_the_same() -> void:
	# the heads' rating of a long room is not above the room's difficulty by more than one head of the most expensive kind
	for depth in [2, 4, 7]:
		for seed_ in 8:
			var f := _fight(depth, seed_ + 1)
			var total := 0.0
			var dearest := 0.0
			for w in f.waves:
				for id: StringName in w:
					var r := (defs[id] as EnemyDef).rating
					total += r
					dearest = maxf(dearest, r)
			var want := EncounterGen.difficulty(stage, depth) * EncounterGen.budget(stage, depth)
			assert_lt(total, want * 1.35 + 3.0 * dearest, "room %d seed %d: %f of %f" % [depth, seed_, total, want])


func test_a_wall_is_found_along_the_line() -> void:
	var wall := func(p: Vector2) -> bool: return p.x > 9.9
	assert_almost_eq(WallAim.hit_at(Vector2.ZERO, Vector2.RIGHT, 14.0, wall), 10.0, 0.3)
	assert_eq(WallAim.hit_at(Vector2.ZERO, Vector2.RIGHT, 8.0, wall), -1.0, "too short to reach it")
	assert_eq(WallAim.hit_at(Vector2.ZERO, Vector2.LEFT, 14.0, wall), -1.0, "the other way: open floor")
	assert_eq(WallAim.hit_at(Vector2.ZERO, Vector2.ZERO, 14.0, wall), -1.0, "no direction")
