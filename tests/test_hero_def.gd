extends GutTest
## The Warrior as data (DT-013, HeroDef): the numbers the paladin had in constants (Player, Combat, Feel) unchanged,
## the passive, the two ultimates (numbers only) and the links to the Gifts and the Mastery.

var hero: HeroDef


func before_all() -> void:
	hero = HeroDef.warrior()


func test_the_warrior_loads() -> void:
	assert_not_null(hero)
	assert_eq(hero.id, &"warrior")
	assert_eq(hero.model, &"hero_explorer", "the model keeps its technical name")
	assert_ne(T.t(hero.name_key), String(hero.name_key), "the name has its text")
	assert_true(ResourceLoader.exists(hero.combos))
	assert_same(HeroDef.warrior(), hero, "loaded once")


func test_the_numbers_of_today() -> void:
	# Hades II's: life 30, 1.3 s safe after a blow, one dodge charge back in 0.74 s
	assert_eq(hero.max_hp, 30.0)
	assert_eq(hero.hurt_time, 0.18)
	assert_eq(hero.hurt_invuln, 1.3)
	assert_eq(hero.dodge_charges, 1)
	assert_almost_eq(hero.dodge_recharge, 0.74, 0.0001)
	assert_eq(hero.magick_max, 50.0)
	# the circle of light
	assert_eq(hero.cast_charge, 0.25)
	assert_eq(hero.cast_slow, 0.6)
	assert_eq(hero.cast_cooldown, 0.2)
	assert_almost_eq(hero.cast_attack_lock, 8.0 / 60.0, 0.000001)
	assert_eq(hero.cast_omega_time, 0.6)
	assert_eq(hero.cast_omega_cost, 20.0)
	assert_eq(hero.cast_radius, 5.4)
	assert_eq(hero.cast_time, 3.0)
	assert_eq(hero.cast_burst, 150.0)
	# the passive (D-56)
	assert_eq(hero.magick_on_finisher, 2.0)


func test_the_game_reads_the_hero() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	assert_same(game.player.hero, hero)
	assert_same(game.combat.hero, hero)
	assert_eq(game.player.max_hp, hero.max_hp)
	assert_eq(game.player.hp, hero.max_hp)
	assert_eq(game.player.magick.max_value, hero.magick_max)
	assert_eq(game.player.dodge_max, hero.dodge_charges)


func test_the_ultimates() -> void:
	assert_eq(hero.ultimates.size(), 2)
	var u1 := hero.ultimate(&"cleave")
	assert_eq(u1.kind, UltDef.Kind.CLEAVE)
	assert_eq(u1.charge, 60.0)
	assert_eq(u1.mastery_level, 6)  # B-2 (balance.md B.5)
	assert_eq(u1.length, 12.0)
	assert_eq(u1.width, 4.0)
	assert_eq(u1.core_damage, 300.0)
	assert_eq(u1.damage, 200.0)
	var u2 := hero.ultimate(&"vortex")
	assert_eq(u2.kind, UltDef.Kind.VORTEX)
	assert_eq(u2.charge, 70.0)
	assert_eq(u2.mastery_level, 10)
	assert_eq(u2.radius, 6.0)
	assert_eq(u2.duration, 4.0)
	assert_eq(u2.tick_damage, 8.0)
	assert_eq(u2.implode_damage, 120.0)
	assert_eq(u2.implode_radius, 3.0)
	for u in hero.ultimates:
		assert_true(u.tags.has(&"ultimate"))
		assert_false(u.tags.has(&"finisher") or u.tags.has(&"omega"), "%s is never a finisher nor an Omega" % u.id)
		assert_ne(T.t(u.name_key), String(u.name_key), "%s has its name" % u.id)
	assert_null(hero.ultimate(&"nope"))


func test_gifts_and_mastery_are_linked() -> void:
	assert_not_null(hero.mastery)
	assert_eq(hero.talents().catalog.size(), 19)
