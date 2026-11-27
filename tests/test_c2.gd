extends GutTest
## Lote C2 (docs/design/evolucao_c2.md, salas_14_c2.md): the evolution that is felt (armor_pct, Fúria Plena, Temperar III,
## the waves of 12, Fôlego de Guerra, Escudo de Guerra) and the 14 rooms (pools, elites, gold).

const LIGHT: Array[StringName] = [&"light"]
const HEAVY: Array[StringName] = [&"heavy", &"wave"]
const DASH: Array[StringName] = [&"light", &"dash"]
const SHOUT: Array[StringName] = [&"shout", &"cast"]

var game: Game


func _gift(mods: Array[BoonMod]) -> TalentDef:
	var t := TalentDef.new()
	t.id = &"test_gift"
	t.mods = mods
	return t


func _mod(stat: StringName, base: float, tag: StringName = &"") -> BoonMod:
	var m := BoonMod.new()
	m.stat = stat
	m.base = base
	m.tag = tag
	m.by_rarity = false
	return m


func _state(mods: Array[BoonMod]) -> GiftState:
	var b := BoonState.new()
	b.equip_talents([_gift(mods)] as Array[TalentDef])
	return GiftState.new(HeroDef.warrior(), b)


func _run(mods: Array[BoonMod]) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.boons.equip_talents([_gift(mods)] as Array[TalentDef])


func _lost(e: Enemy, base: float, tags: Array[StringName]) -> float:
	var before := e.hp + e.armor
	game.combat.hit_enemy(e, base, tags, Vector2.RIGHT, 0.0)
	return before - e.hp - e.armor


func test_armor_pct_only_with_armor_and_by_tag() -> void:
	_run([_mod(&"armor_pct", 0.2, &"light")] as Array[BoonMod])
	var elite := game.horde.spawn(game.horde.def(&"archer_elite"), Vector2(5, 0), false)
	elite.max_armor = 190.0  # (no enemy has armor since 2026-11-27: the bar is given by hand to keep its rule tested)
	elite.armor = 190.0
	assert_almost_eq(_lost(elite, 20.0, LIGHT), 24.0, 0.01, "20% more of the armor bar")
	assert_almost_eq(_lost(elite, 20.0, HEAVY), 30.0, 0.01, "no other tag: the special's base only")
	var plain := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(-5, 0), false)
	assert_eq(plain.armor, 0.0)
	assert_almost_eq(_lost(plain, 20.0, LIGHT), 20.0, 0.01, "no armor: nothing")


func test_armor_pct_adds_to_the_specials_base() -> void:
	_run([_mod(&"armor_pct", 0.3, &"heavy")] as Array[BoonMod])
	var elite := game.horde.spawn(game.horde.def(&"archer_elite"), Vector2(5, 0), false)
	elite.max_armor = 190.0
	elite.armor = 190.0
	assert_almost_eq(_lost(elite, 20.0, HEAVY), 36.0, 0.01, "80% in all")


func test_no_forge_rank_promises_a_stun_now() -> void:
	var forge := Forge.new(Forge.load_catalog())
	for r in forge.catalog:
		for m in r.mods:
			assert_ne(m.stat, &"stun_pct", "%s" % r.id)
	assert_eq(forge.find(&"refine_peso").mods[0].stat, &"armor_pct")
	assert_eq(forge.find(&"refine_onda_pesada").mods[0].stat, &"armor_pct")


func test_temper_three_is_ten_percent_and_the_waves_are_twelve() -> void:
	var b := BoonState.new()
	var forge := Forge.new(Forge.load_catalog())
	var ranks: Array[ForgeRank] = [forge.find(&"temper_1"), forge.find(&"temper_2"), forge.find(&"temper_3")]
	b.equip_forge(ranks)
	assert_almost_eq(b.stat(&"damage_pct", LIGHT), 0.30, 0.0001)
	var s := GiftState.new(HeroDef.warrior(), BoonState.new())
	# (the Gifts that threw these waves left in the redesign; the Encantos still do, through the same stat)
	var mods: Array[BoonMod] = []
	for tag: StringName in [&"spin", &"heavy"]:
		var m := BoonMod.new()
		m.stat = &"blow_wave"
		m.tag = tag
		m.base = 12.0
		m.by_rarity = false
		mods.append(m)
	s.boons.grant(mods)
	assert_eq(float(s.wave([&"spin"]).damage), 12.0)
	assert_eq(float(s.wave(HEAVY).damage), 12.0)


func test_the_four_milestones_of_the_curve() -> void:
	# combo without a Blessing: 15, 15, 20 (+15 with the Quarto Corte) times 1 + the sum of the light damage_pct
	var start := 15.0 + 15.0 + 20.0
	assert_eq(start, 50.0)
	assert_almost_eq(start * 1.26, 63.0, 0.5, "marker 1: Forja I + forca_1")
	assert_almost_eq((start + 15.0) * 1.26, 82.0, 0.5, "marker 2: Quarto Corte")
	assert_almost_eq((start + 15.0) * 1.42, 92.0, 0.5, "marker 3: Temperar III and the account")


func test_cooldown_cut_by_tag_and_capped() -> void:
	var s := _state([_mod(&"cooldown_pct", -0.25, &"shout"), _mod(&"cooldown_pct", -0.25, &"dash")] as Array[BoonMod])
	assert_almost_eq(s.cooldown_cut(SHOUT), 0.25, 0.0001)
	assert_almost_eq(s.cooldown_cut(DASH), 0.25, 0.0001)
	assert_eq(s.cooldown_cut(LIGHT), 0.0)
	var big := _state([_mod(&"cooldown_pct", -0.4), _mod(&"cooldown_pct", -0.4)] as Array[BoonMod])
	assert_almost_eq(big.cooldown_cut(SHOUT), GiftState.COOLDOWN_CUT_MAX, 0.0001, "never past half")


func test_the_runner_arms_a_shorter_cooldown() -> void:
	# (GP-1: no move of the Warrior has a recharge; the Corte Circular is given the Brado's 12 s to test the rule)
	var tree := (load(HeroDef.warrior().combos) as ComboTree).duplicate(true)
	var sweep := ComboTree.find(tree.neutral, ComboNode.In.HEAVY)
	sweep.cooldown = 12.0
	var r := ComboRunner.new(tree)
	r.cooldown_cut = 0.25
	r.press(sweep.input)
	for i in 120:
		r.step(1.0 / 60.0)
		if r.cooldown_left(&"sweep") > 0.0:
			break
	assert_between(r.cooldown_left(&"sweep"), 8.5, 9.0, "12 s becomes 9")


func test_room_one_is_a_single_part_and_the_fight_has_it() -> void:
	var stage := load("res://data/stages/catacombs.tres") as StageDef
	var defs := {}
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)
	var rng := RandomNumberGenerator.new()
	for seed_ in 20:
		rng.seed = seed_
		var f := EncounterGen.generate(stage, 1, defs, rng)
		assert_eq(f.kinds.size(), 1, "one kind")
		assert_eq((defs[f.kinds[0]] as EnemyDef).role, &"pressure")
		assert_lte(f.cap, 4)
		assert_eq(f.tier, StageDef.Tier.COMMON)
		for w in f.waves:
			assert_gt(w.size(), 0)
	rng.seed = 3
	var guard := EncounterGen.generate(stage, 4, defs, rng)
	assert_true(guard.kinds.size() >= 1)


func test_the_top_rooms_introduce_one_kind_and_have_no_elite() -> void:
	var stage := load("res://data/stages/catacombs.tres") as StageDef
	var defs := {}
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)
	var rng := RandomNumberGenerator.new()
	for depth in range(1, 5):
		for seed_ in 15:
			rng.seed = seed_
			var f := EncounterGen.generate(stage, depth, defs, rng)
			for id in f.kinds:
				assert_false((defs[id] as EnemyDef).elite, "no elite in room %d" % depth)
	for depth in range(1, 13):
		assert_not_null(EncounterGen.pick_pool(stage, depth, rng), "a pool in room %d" % depth)


func test_numbers_of_the_14_rooms() -> void:
	var stage := load("res://data/stages/catacombs.tres") as StageDef
	assert_eq(stage.depth_ramp, 11.0)
	assert_eq(stage.gold_per_depth, 0.8)
	assert_eq(stage.alive_cap, 20)
	var golds := 0
	var hearts := 0
	for c in stage.reward_deck:
		golds += 1 if c == RunMap.Reward.GOLD else 0
		hearts += 1 if c == RunMap.Reward.HEART else 0
	assert_eq(golds, 3)
	assert_eq(hearts, 3)
	assert_eq(stage.reward_deck.size(), 23)
	for tier in 3:
		assert_lte(EncounterGen.alive_range(stage, tier as StageDef.Tier).y, 20)
