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


func test_every_fight_room_rises_one_by_one() -> void:
	for depth in [1, 2, 3, 4, 6, 7, 8, 9, 11, 12]:
		assert_true(EncounterGen.is_long(stage, depth), "room %d is long" % depth)
	for depth in [5, 10]:
		assert_false(EncounterGen.is_long(stage, depth), "room %d is a guardian's" % depth)


func test_the_last_wave_carries_an_elite() -> void:
	# (SW-R1: a room is one wave, two or a horde; the last of them carries the elite when a kind of the fight has one)
	var with_elite := 0
	var tried := 0
	for depth in [4, 6, 7, 8, 9]:
		for seed_ in 12:
			var f := _fight(depth, seed_ + 1)
			if f.waves.is_empty():
				continue
			tried += 1
			var last: Array = f.waves[f.waves.size() - 1]
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


func test_a_wall_is_found_along_the_line() -> void:
	var wall := func(p: Vector2) -> bool: return p.x > 9.9
	assert_almost_eq(WallAim.hit_at(Vector2.ZERO, Vector2.RIGHT, 14.0, wall), 10.0, 0.3)
	assert_eq(WallAim.hit_at(Vector2.ZERO, Vector2.RIGHT, 8.0, wall), -1.0, "too short to reach it")
	assert_eq(WallAim.hit_at(Vector2.ZERO, Vector2.LEFT, 14.0, wall), -1.0, "the other way: open floor")
	assert_eq(WallAim.hit_at(Vector2.ZERO, Vector2.ZERO, 14.0, wall), -1.0, "no direction")
