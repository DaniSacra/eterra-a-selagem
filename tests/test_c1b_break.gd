extends GutTest
## C1b, Frente 1: the Quebra (Poise), the weights as data and the numbers of the first front.

func _weights() -> Dictionary:
	return Feel.live().poise_weights


func test_attack_takes_about_seven_blows_the_rest_one_or_two() -> void:
	var w := _weights()
	assert_between(1.0 / Poise.share(&"attack", w), 6.0, 8.0)
	for s in [&"special", &"dash", &"omega_attack", &"omega_special", &"shout", &"ultimate"]:
		assert_lte(ceilf(1.0 / Poise.share(s, w)), 2.0, str(s))
	assert_eq(Poise.share(&"ultimate", w), 1.0)


func test_effects_that_act_alone_take_none() -> void:
	var w := _weights()
	for s in [&"burn", &"embers", &"echo", &"psalm", &"shatter", &"mark", &"cast", &"skill", &"other", &""]:
		assert_eq(Poise.share(s, w), 0.0, str(s))


func test_wear_never_below_zero_and_settle_refills() -> void:
	assert_eq(Poise.wear(100.0, 100.0, 0.15), 85.0)
	assert_eq(Poise.wear(10.0, 100.0, 0.5), 0.0)
	assert_eq(Poise.settle(40.0, 100.0, 3.9, 4.0), 40.0)
	assert_eq(Poise.settle(40.0, 100.0, 4.0, 4.0), 100.0)


func test_who_takes_poise() -> void:
	assert_true(Poise.takes(100.0, 0.0, 0.0, false, false))
	assert_false(Poise.takes(0.0, 0.0, 0.0, false, false), "no poise: elite, guardian, boss")
	assert_false(Poise.takes(100.0, 1.0, 0.0, false, false), "frozen")
	assert_false(Poise.takes(100.0, 0.0, 0.5, false, false), "already stunned")
	assert_false(Poise.takes(100.0, 0.0, 0.0, true, false), "down or rising")
	assert_false(Poise.takes(100.0, 0.0, 0.0, false, true), "invulnerable")


func _def(id: String) -> EnemyDef:
	return load("res://data/enemies/%s.tres" % id) as EnemyDef


func test_poise_on_the_commons_and_since_SW_C5_on_the_elites_and_guardians() -> void:
	for id in ["skeleton", "runner", "mage", "archer"]:
		assert_eq(_def(id).poise, 100.0, id)
		assert_eq(_def(id).poise_growth, 1.0, id + " asks the same every time")
		assert_gt(_def(id + "_elite").poise, 0.0, id + " elite (SW-C5)")
		assert_lt(_def(id + "_elite").poise_mult, 1.0, id + " elite takes less of a blow")
	for id in ["trinca", "guard", "priest", "varredor", "morvath"]:
		assert_eq(_def(id).poise, 0.0, id)
	assert_gt(_def("knight").poise, 0.0, "the guardians (SW-C5)")


func test_common_life_and_warnings() -> void:
	assert_eq([_def("skeleton").hp, _def("runner").hp, _def("mage").hp, _def("archer").hp], [250.0, 200.0, 175.0, 150.0])  # SWORN Kingswood: Hammer, Boar, Mortoad, Axe Thrower
	# (2026-11-23, ENEMY_WINDUP 0.8: it was 0.75 and 0.85)
	assert_almost_eq(_def("skeleton").attack_windup, 0.6, 0.001)
	assert_almost_eq(_def("runner").attack_windup, 0.68, 0.001)
	assert_eq([_def("skeleton_elite").hp, _def("archer_elite").hp], [1500.0, 875.0])  # the Major Hammer x1.0 and the Major Axe x0.7, a ranged one kites (PT-28-7)
	assert_eq(HeroDef.warrior().hurt_invuln, 0.7)


func test_horde_breaks_a_common_by_the_button() -> void:
	var rule := StunRule.live
	StunRule.live = StunRule.Mode.NONE
	var game := (load("res://scenes/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	var h := game.horde
	h.clear_crowd()
	var e := h.spawn(h.def(&"skeleton"), Vector2(3, 0), false)
	e.hp = 10000.0
	e.max_hp = 10000.0
	h.dealing = &"special"
	h.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	# the bar is SWORN's stagger cap: poise_mult makes 20-damage light blows break it as many times as the cap says
	var mult := e.def.poise_mult
	assert_almost_eq(e.poise, 100.0 - 60.0 * mult, 0.01)
	assert_eq(e.broken_t, 0.0)
	h.dealing = &"burn"
	h.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_almost_eq(e.poise, 100.0 - 60.0 * mult, 0.01, "a burn takes none")
	h.dealing = &"special"
	h.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_gt(e.broken_t, 0.0)
	assert_almost_eq(e.stun_t, 2.0, 0.05)  # SWORN: a common stands stunned 2.0 s
	assert_eq(h.breaks.get("special"), 1)
	# open now: +40% damage, and no poise taken while stunned
	var before := e.hp
	h.damage(e, 10.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_almost_eq(before - e.hp, 14.0, 0.01)
	assert_eq(e.poise, 0.0, "no poise taken while stunned")
	for i in 150:
		h.dealing = &""
		game._step(1.0 / 60.0)
	assert_eq(e.broken_t, 0.0)
	assert_eq(e.poise, 100.0, "full again after the stun")
	h.dealing = &""
	StunRule.live = rule
