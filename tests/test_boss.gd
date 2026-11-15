extends GutTest


func test_phases_change_at_60_and_25_percent() -> void:
	assert_eq(BossRules.phase_for(1.0), 1)
	assert_eq(BossRules.phase_for(0.61), 1)
	assert_eq(BossRules.phase_for(0.6), 2)
	assert_eq(BossRules.phase_for(0.26), 2)
	assert_eq(BossRules.phase_for(0.25), 3)
	assert_eq(BossRules.phase_for(0.0), 3)


func test_ring_spreads_bullets_evenly() -> void:
	var dirs := BossRules.ring(8, 0.0)
	assert_eq(dirs.size(), 8)
	assert_almost_eq(dirs[0].angle(), 0.0, 0.001)
	assert_almost_eq(dirs[2].angle(), PI * 0.5, 0.001)
	for d in dirs:
		assert_almost_eq(d.length(), 1.0, 0.001)
	assert_almost_eq(BossRules.ring(8, 0.3)[0].angle(), 0.3, 0.001, "the offset turns the whole ring, leaving gaps to dodge through")


func test_fan_is_centred_on_the_aim() -> void:
	var dirs := BossRules.fan(Vector2.RIGHT, 5, 1.0)
	assert_eq(dirs.size(), 5)
	assert_almost_eq(dirs[2].angle(), 0.0, 0.001)
	assert_almost_eq(dirs[0].angle(), -0.5, 0.001)
	assert_almost_eq(dirs[4].angle(), 0.5, 0.001)
	assert_eq(BossRules.fan(Vector2.UP, 1, 1.0)[0], Vector2.UP)


func test_mist_closes_in_and_then_holds() -> void:
	assert_eq(BossRules.mist_radius(0.0, 400.0, 100.0, 10.0), 400.0)
	assert_eq(BossRules.mist_radius(5.0, 400.0, 100.0, 10.0), 250.0)
	assert_eq(BossRules.mist_radius(99.0, 400.0, 100.0, 10.0), 100.0)


func test_morvath_is_an_undead_heavy_boss_with_art_for_every_attack() -> void:
	var def: EnemyDef = load("res://data/enemies/morvath.tres")
	assert_eq(def.behavior, EnemyDef.Behavior.BOSS)
	assert_true(def.undead)
	assert_true(def.heavy)
	var anims: Dictionary = (load("res://assets/baked/morvath.res") as BakedModel).anims
	for a in ["idle", "walk", "slash1", "slash2", "slash3", "dash_windup", "dash", "summon", "rain", "volley", "stunned", "roar", "death"]:
		assert_true(anims.has(a), a)


func test_warnings_know_who_stands_inside() -> void:
	var z := Ground.Zone.new()
	z.pos = Vector2.ZERO
	z.radius = 20.0
	assert_true(Ground.inside(z, Vector2(19, 0)))
	assert_false(Ground.inside(z, Vector2(21, 0)))
	z.shape = Ground.Shape.LINE
	z.dir = Vector2.RIGHT
	z.radius = 100.0
	z.width = 10.0
	assert_true(Ground.inside(z, Vector2(50, 4)))
	assert_false(Ground.inside(z, Vector2(50, 6)))
	assert_false(Ground.inside(z, Vector2(-5, 0)), "behind the start of the line")
	z.shape = Ground.Shape.ARC
	z.radius = 40.0
	z.width = 90.0
	assert_true(Ground.inside(z, Vector2(30, 10)))
	assert_false(Ground.inside(z, Vector2(-30, 0)), "behind the swing")
	assert_false(Ground.inside(z, Vector2(50, 0)), "past the reach")


## The crash Daniel hit (exported game, 0xc0000094): phase 1, the paladin far away, right after a dash left Morvath
## nothing to choose, and `randi() % 0` took the game down.
func test_morvath_always_has_an_attack_to_choose() -> void:
	for phase in [1, 2, 3]:
		for dist in [0.0, 5.0, 12.5, 40.0]:
			for last: StringName in [&"", &"slashes", &"dash", &"rain", &"summon", &"volley"]:
				for summon in [true, false]:
					var options := BossRules.attacks(phase, dist, last, summon)
					assert_gt(options.size(), 0, "phase %d dist %.1f last %s" % [phase, dist, last])
					if dist > BossRules.SLASH_CHOICE_RANGE:
						assert_false(options.has(&"slashes"), "no slashes from afar")


func test_morvath_far_away_after_a_dash_dashes_again() -> void:
	assert_eq(BossRules.attacks(1, 20.0, &"dash", false), [&"dash"] as Array[StringName])
	assert_false(BossRules.attacks(1, 5.0, &"dash", false).has(&"dash"), "close by, he does not repeat the dash")
