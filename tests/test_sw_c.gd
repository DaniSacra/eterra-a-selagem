extends GutTest
## SW-C4 (damage and warning of the commons), SW-C5 (poise of elites, guardians and Morvath, each break asking 1.25 times more),
## SW-C7 (the pack of bone rats) and SW-C8 (the Capitao that calls). Numbers: docs/design/sworn_rea_kingswood_2026-11-25.md.

func _def(id: String) -> EnemyDef:
	return load("res://data/enemies/%s.tres" % id) as EnemyDef


func _game() -> Game:
	var game := (load("res://scenes/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	return game


# ---------- SW-C4 ----------

func test_commons_hit_for_a_tenth_to_a_fifth_of_forty() -> void:
	for id in ["skeleton", "runner", "mage", "archer", "guard", "priest", "varredor", "saltador", "lancador", "skeleton_big", "runner_big", "trinca", "bone_rat"]:
		var d := _def(id)
		assert_between(d.attack_damage, 3.0, 8.0, id)
	assert_lte(_def("armadilheiro").plate_damage, 8.0)
	assert_lte(_def("guard").close_damage, 8.0)


func test_warnings_by_weight() -> void:
	for id in ["skeleton", "runner", "mage", "archer", "priest", "saltador", "lancador", "trinca", "bone_rat"]:
		assert_between(_def(id).attack_windup, 0.5, 0.7001, id + " common")
	for id in ["skeleton_elite", "runner_elite", "mage_elite", "archer_elite", "guard_elite", "priest_elite", "trinca_elite", "priest_elder", "skeleton_big"]:
		assert_between(_def(id).attack_windup, 0.7 if id in ["guard_elite", "skeleton_big"] else 0.8, 1.0001, id + " elite")
	for id in ["varredor", "varredor_elite", "canalizador", "runner_big"]:
		assert_between(_def(id).attack_windup, 1.2, 1.6, id + " big area")
	assert_eq(_def("capitao").attack_windup, 1.2)


# ---------- SW-C5 ----------

func test_each_break_asks_one_and_a_quarter_more() -> void:
	assert_eq(Poise.full_after(100.0, 0, 1.25), 100.0)
	assert_eq(Poise.full_after(100.0, 1, 1.25), 125.0)
	assert_almost_eq(Poise.full_after(100.0, 3, 1.25), 195.3125, 0.001)
	assert_eq(Poise.full_after(100.0, 5, 1.0), 100.0, "the commons' never grows")
	assert_eq(Poise.full_after(100.0, 2, 0.5), 100.0, "never smaller")


func test_poise_on_elites_guardians_and_morvath() -> void:
	for id in ["skeleton_elite", "runner_elite", "mage_elite", "archer_elite", "guard_elite", "priest_elite", "trinca_elite", "varredor_elite"]:
		var d := _def(id)
		assert_gt(d.poise, 0.0, id)
		assert_eq(d.poise_stun, 2.5, id)
		assert_eq(d.poise_growth, 1.25, id)
	for id in ["knight", "priest_elder"]:
		assert_eq(_def(id).poise_stun, 3.5, id)
		assert_eq(_def(id).poise_growth, 1.25, id)
	var b := load("res://data/bosses/morvath.tres") as BossDef
	assert_eq(b.posture_stun, 3.5)
	assert_eq(b.posture_growth, 1.25)
	assert_eq(_def("skeleton").poise_growth, 1.0, "the commons are as they were")
	assert_eq(_def("skeleton").poise_stun, 1.2)


func test_elite_breaks_stuns_2_5_s_then_asks_more() -> void:
	var rule := StunRule.live
	StunRule.live = StunRule.Mode.NONE
	var game := _game()
	var h := game.horde
	var e := h.spawn(h.def(&"skeleton_elite"), Vector2(3, 0), false)
	e.hp = 100000.0
	e.max_hp = 100000.0
	e.armor = 0.0
	e.cooldown = 99.0
	assert_eq(e.poise_full, 100.0)
	# the special takes 0.6 x 0.5 = 0.3 of the bar: the fourth breaks it (0.7, 0.4, 0.1, 0)
	h.dealing = &"special"
	for i in 3:
		h.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_eq(e.broken_t, 0.0)
	h.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_almost_eq(e.broken_t, 2.5, 0.01)
	assert_eq(e.poise_breaks, 1)
	assert_eq(h.breaks.get("special"), 1)
	var before := e.hp
	h.damage(e, 10.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_almost_eq(before - e.hp, 12.5, 0.01, "+25% while it is open")
	h.dealing = &""
	for i in 180:
		game._step(1.0 / 60.0)
	assert_eq(e.broken_t, 0.0)
	assert_eq(e.poise_full, 125.0, "the next break asks 1.25 times more")
	assert_eq(e.poise, 125.0)
	h.dealing = &"special"
	for i in 4:
		h.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_eq(e.poise_breaks, 1, "0.3 of a bigger bar: four blows no longer break it")
	h.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_eq(e.poise_breaks, 2)
	h.dealing = &""
	StunRule.live = rule


func test_guardian_stuns_3_5_s() -> void:
	var game := _game()
	var h := game.horde
	var e := h.spawn(h.def(&"knight"), Vector2(6, 0), false)
	e.cooldown = 99.0
	e.hp = 100000.0
	e.max_hp = 100000.0
	h.dealing = &"ultimate"  # a whole bar x 0.3: four of them
	for i in 3:
		h.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_eq(e.broken_t, 0.0)
	h.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_almost_eq(e.broken_t, 3.5, 0.01)
	assert_almost_eq(e.stun_t, 3.5, 0.01)
	h.dealing = &""


func test_morvath_posture_grows_with_each_break() -> void:
	var game := _game()
	var b := load("res://data/bosses/morvath.tres") as BossDef
	var full := Poise.full_after(b.posture, 0, b.posture_growth)
	var next := Poise.full_after(b.posture, 1, b.posture_growth)
	assert_almost_eq(next / full, 1.25, 0.0001)
	assert_not_null(game)


# ---------- SW-C7 ----------

func test_bone_rat_dies_to_one_blow() -> void:
	var d := _def("bone_rat")
	assert_lte(d.hp, 15.0, "the first blow of the Warrior is 15")
	assert_gt(d.speed, _def("skeleton").speed)
	assert_between(d.attack_damage, 2.0, 4.0)
	assert_true(d.blocks_body, "solid like every body")
	assert_eq(d.role, &"scurry")
	assert_ne(T.t(d.name_key), String(d.name_key))


func test_a_wave_with_rats_has_a_pack() -> void:
	var st := load("res://data/stages/catacombs.tres") as StageDef
	var defs := {}
	for id in st.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)
	var rng := RandomNumberGenerator.new()
	var seen := 0
	for seed_n in 200:
		rng.seed = seed_n
		var depth := 3 + seed_n % 9
		var fight := EncounterGen.generate(st, depth, defs, rng)
		for w in fight.waves:
			var n := w.count(&"bone_rat")
			if n > 0:
				seen += 1
				assert_between(n, 4, 6, "a pack: 4 to 6 rats (depth %d, seed %d)" % [depth, seed_n])
	assert_gt(seen, 0, "the rats are drawn")


func test_pack_bodies_count_half() -> void:
	var defs := {&"bone_rat": _def("bone_rat"), &"skeleton": _def("skeleton")}
	assert_eq(EncounterGen.bodies([&"bone_rat", &"bone_rat", &"bone_rat", &"bone_rat", &"skeleton"], defs), 3)


# ---------- SW-C8 ----------

func test_captain_data() -> void:
	var d := _def("capitao")
	var base := _def("skeleton").hp
	assert_between(d.hp / base, 5.0, 6.0, "5 to 6 times a common's life")
	assert_true(d.no_push)
	assert_eq(d.attack_windup, 1.2)
	assert_between(d.raise_count, 4, 5)
	assert_eq(d.per_room, 1)
	assert_eq(d.behavior, EnemyDef.Behavior.KNIGHT)
	assert_ne(T.t(d.name_key), String(d.name_key))


func test_captain_is_never_pushed_a_common_is() -> void:
	var game := _game()
	var h := game.horde
	var cap := h.spawn(h.def(&"capitao"), Vector2(3, 0), false)
	var sk := h.spawn(h.def(&"skeleton"), Vector2(-3, 0), false)
	cap.cooldown = 99.0
	h.damage(cap, 1.0, Vector2.RIGHT, 8.0, Color.WHITE, false)
	h.damage(sk, 1.0, Vector2.RIGHT, 8.0, Color.WHITE, false)
	assert_eq(cap.push, Vector2.ZERO)
	assert_gt(sk.push.length(), 1.0)


func test_captain_calls_its_soldiers() -> void:
	var game := _game()
	var h := game.horde
	h.target = Vector2(0, 0)
	var cap := h.spawn(h.def(&"capitao"), Vector2(8, 0), false)
	assert_eq(cap.rows, 2, "its first act is the call")
	var calls := 0
	for i in 600:
		game._step(1.0 / 60.0)
		calls = maxi(calls, cap.raised.size())
		if calls >= 4:
			break
	assert_gte(calls, 4, "it calls 4 to 5")
	assert_lte(calls, 5)


func test_poise_wears_under_the_armor_too() -> void:
	var game := _game()
	var h := game.horde
	var e := h.spawn(h.def(&"skeleton_elite"), Vector2(3, 0), false)
	e.cooldown = 99.0
	assert_gt(e.armor, 0.0)
	h.dealing = &"special"
	h.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_almost_eq(e.poise, 70.0, 0.01, "the armor holds, the stun bar wears")
	h.dealing = &""
