extends GutTest
## Maga M2 (docs/design/heroes/maga_m2.md): her own Mastery, the 23 Gifts of the triangle tree, the two ultimates. The tree and
## the pure rules first, then each Gift in play (a run in the fountain room with --hero=maga and the Gifts equipped).

const DT := 1.0 / 60.0

var game: Game
var pad := Controls.VirtualPad.new()


func after_each() -> void:
	Controls.virtual = null
	Controls.clear_presses()
	Dev.drop("hero")


func _book() -> Talents:
	return HeroDef.maga().talents()


func _ids(ids: Array) -> Array[StringName]:
	var out: Array[StringName] = []
	for id: Variant in ids:
		out.append(StringName(id))
	return out


# ---------- the tree ----------

func test_the_catalog_has_23_gifts_in_three_branches_six_bridges_and_five_sustain() -> void:
	var cat := _book().catalog
	assert_eq(cat.size(), 23)
	var by := {}
	var cost := 0
	for t in cat:
		by[t.branch] = int(by.get(t.branch, 0)) + 1
		cost += t.cost
		assert_ne(T.t(t.name_key), String(t.name_key), "%s has a name" % t.id)
		assert_ne(T.t(t.desc_key), String(t.desc_key), "%s has a description" % t.id)
	var B := TalentDef.Branch
	assert_eq([by[B.PIRO], by[B.ARCA], by[B.CTRL], by[B.BRIDGE], by[B.SUSTAIN]], [4, 4, 4, 6, 5])
	assert_eq(cost, 67, "the plan's 67 of Devotion in all")


func test_the_three_branches_are_neighbours_of_each_other() -> void:
	var B := TalentDef.Branch
	for a: TalentDef.Branch in [B.PIRO, B.ARCA, B.CTRL]:
		for b: TalentDef.Branch in [B.PIRO, B.ARCA, B.CTRL]:
			assert_eq(TalentDef.neighbours(a, b), a != b)
	assert_false(TalentDef.neighbours(B.PIRO, B.COMBO), "the Warrior's diamond is another tree")


func test_the_levels_unlock_the_gifts_in_the_planned_order() -> void:
	var book := _book()
	var at := {1: [&"brasa_viva"], 2: [&"eco_arcano"], 3: [&"circulo_expandido"], 4: [&"cadeia_curta"], 5: [&"pavio_longo"],
		6: [&"prisao_sigilada"], 7: [&"combustao"], 8: [&"selo_duplo"], 9: [&"suspensao_larga"], 10: [&"firmeza"],
		11: [&"chama_que_marca"], 12: [&"selo_no_chao", &"reserva"], 13: [&"brasa_que_prende", &"respiro"], 14: [&"leitura_rapida"],
		15: [&"passo_de_brasa"], 16: [&"inferno_runico"], 17: [&"ainda_de_pe", &"passo_longo"], 18: [&"ruptura"],
		19: [&"brasa_gemea"], 20: [&"contencao_perfeita"]}
	for level: int in at:
		var got: Array[StringName] = []
		for t in book.unlocked_at(level):
			got.append(t.id)
		got.sort()
		var want: Array = at[level].duplicate()
		want.sort()
		assert_eq(got, want, "level %d" % level)
	assert_eq(book.find(&"brasa_viva").memory_cost, 0, "the first one comes open")
	assert_eq(book.find(&"eco_arcano").memory_cost, 2)


func test_an_entry_needs_only_the_centre_and_a_middle_its_branch_entry() -> void:
	var book := _book()
	assert_eq(book.check(_ids(["eco_arcano"]), 2, 7).problem, Talents.Problem.OK)
	assert_eq(book.check(_ids(["pavio_longo"]), 5, 10).problem, Talents.Problem.NEEDS)
	assert_eq(book.check(_ids(["brasa_viva", "pavio_longo"]), 5, 10).problem, Talents.Problem.OK)


func test_pavio_longo_and_cadeia_curta_share_the_attack_and_exclude_each_other() -> void:
	var book := _book()
	var both := _ids(["brasa_viva", "eco_arcano", "pavio_longo", "cadeia_curta"])
	var r := book.check(both, 5, 20)
	assert_eq(r.problem, Talents.Problem.SLOT_TAKEN)
	assert_eq(r.id, &"cadeia_curta")


func test_the_apexes_take_a_partner_in_the_planned_cycle() -> void:
	var book := _book()
	# Inferno Rúnico: Piromancia's middle and a Gift of Arcanismo
	var inferno := ["brasa_viva", "combustao", "eco_arcano", "inferno_runico"]
	assert_eq(book.check(_ids(inferno), 16, 25).problem, Talents.Problem.OK)
	assert_eq(book.check(_ids(["brasa_viva", "combustao", "circulo_expandido", "inferno_runico"]), 16, 25).problem, Talents.Problem.NEEDS,
		"a Gift of Selos is no partner of the Inferno")
	# Ruptura: Arcanismo's middle and a Gift of Selos
	assert_eq(book.check(_ids(["eco_arcano", "selo_duplo", "circulo_expandido", "ruptura"]), 18, 25).problem, Talents.Problem.OK)
	assert_eq(book.check(_ids(["eco_arcano", "selo_duplo", "brasa_viva", "ruptura"]), 18, 25).problem, Talents.Problem.NEEDS)
	# Contenção Perfeita: Selos' middle and a Gift of Piromancia
	assert_eq(book.check(_ids(["circulo_expandido", "prisao_sigilada", "brasa_viva", "contencao_perfeita"]), 20, 25).problem, Talents.Problem.OK)


func test_a_bridge_needs_the_entries_of_the_two_branches_it_joins() -> void:
	var book := _book()
	assert_eq(book.check(_ids(["brasa_viva", "chama_que_marca"]), 11, 25).problem, Talents.Problem.NEEDS)
	assert_eq(book.check(_ids(["brasa_viva", "eco_arcano", "chama_que_marca"]), 11, 25).problem, Talents.Problem.OK)
	assert_eq(book.check(_ids(["eco_arcano", "circulo_expandido", "selo_no_chao", "leitura_rapida"]), 14, 25).problem, Talents.Problem.OK)


func test_the_planned_montages_fit_their_devotion() -> void:
	var book := _book()
	var estudiosa := ["brasa_viva", "eco_arcano", "circulo_expandido", "cadeia_curta", "prisao_sigilada"]
	assert_eq(book.check(estudiosa, 6, 11).problem, Talents.Problem.OK)
	assert_eq(book.cost(estudiosa), 11)
	var incendiaria := ["brasa_viva", "pavio_longo", "combustao", "eco_arcano", "chama_que_marca", "firmeza", "respiro"]
	assert_eq(book.check(incendiaria, 13, 17).problem, Talents.Problem.OK)
	var carcereira := ["circulo_expandido", "prisao_sigilada", "suspensao_larga", "contencao_perfeita", "selo_no_chao", "leitura_rapida",
		"eco_arcano", "brasa_viva", "firmeza"]
	assert_eq(book.check(carcereira, 20, 25).problem, Talents.Problem.OK)
	assert_eq(book.cost(carcereira), 24)


func test_the_maga_has_a_mastery_of_her_own_with_the_same_numbers() -> void:
	var hero := HeroDef.maga()
	assert_ne(hero.mastery.resource_path, HeroDef.warrior().mastery.resource_path)
	assert_eq(hero.mastery.max_level, 20)
	assert_eq(hero.mastery.level_of(2470), 20, "2470 XP in all")
	assert_eq(hero.mastery.devotion(1), 6)
	assert_eq(hero.mastery.devotion(20), 25)


func test_the_two_ultimates_open_at_mastery_two_and_six() -> void:
	var hero := HeroDef.maga()
	assert_eq(hero.ultimates.size(), 2)
	assert_eq([hero.ultimates[0].id, hero.ultimates[0].mastery_level], [&"storm", 2])
	assert_eq([hero.ultimates[1].id, hero.ultimates[1].mastery_level], [&"dome_abs", 6])
	assert_eq(hero.ultimates[1].kind, UltDef.Kind.DOME)
	assert_null(hero.ult_for(&"", 1), "none before the Mastery opens one")
	assert_eq(hero.ult_for(&"", 2).id, &"storm")
	assert_eq(hero.ult_for(&"dome_abs", 5).id, &"storm", "not yet open: the first")
	assert_eq(hero.ult_for(&"dome_abs", 6).id, &"dome_abs")
	assert_eq(hero.ultimates[1].dome_blast_cost, 5.0)


# ---------- the pure rules ----------

func test_where_the_selo_comes_with_the_gifts() -> void:
	var kit := HeroDef.maga().arcane
	assert_eq([kit.lays_seal(1, false), kit.lays_seal(2, false), kit.lays_seal(3, false)], [false, false, true], "as it was")
	assert_eq([kit.lays_seal(1, true), kit.lays_seal(2, true)], [false, true], "the second inside the Círculo")
	assert_eq([kit.lays_seal(1, false, -1), kit.lays_seal(2, false, -1)], [false, true], "Cadeia Curta: the second")
	assert_true(kit.lays_seal(1, true, -1), "Cadeia Curta inside the Círculo: the first")
	assert_true(kit.lays_seal(1, true, 0, -1), "Contenção Perfeita: the first inside the Círculo")
	assert_false(kit.lays_seal(1, false, 0, -1), "and only inside it")
	assert_true(kit.lays_seal(1, false, 0, 0, true), "the Suspensão Absoluta: every shot")
	assert_eq([ArcaneKit.chain_step([&"seal"] as Array[StringName]), ArcaneKit.chain_step([&"seal2"] as Array[StringName]),
		ArcaneKit.chain_step([&"bolt1"] as Array[StringName])], [3, 2, 1])


func test_a_double_selo_makes_the_blasts_bonus_forty_percent_bigger() -> void:
	var kit := HeroDef.maga().arcane
	assert_eq(kit.blast_hit_n(0, false), 32.0)
	assert_eq(kit.blast_hit_n(1, false), kit.blast_hit(true, false), "one Selo: as before")
	assert_almost_eq(kit.blast_hit_n(2, false), 32.0 + 44.0 * 1.4, 0.001, "44 becomes 61.6")
	assert_almost_eq(kit.blast_hit_n(2, true), (32.0 + 44.0 * 1.4) * 1.5, 0.001)


func test_the_selo_book_holds_two_and_a_leap_lives_its_own_seconds() -> void:
	var book := SealBook.new(8.0, 2)
	var a := Node.new()
	assert_true(book.lay(a))
	assert_true(book.lay(a), "the second")
	assert_false(book.lay(a), "no third")
	assert_eq(book.count(a), 2)
	var b := Node.new()
	book.lay(b, 1)
	assert_false(book.lay(b, 1), "the storm's limit of one")
	assert_eq(book.count(b), 1)
	var c := Node.new()
	book.lay(c, -1, 4.0)
	assert_eq(book.left(c), 4.0)
	a.free()
	b.free()
	c.free()


# ---------- in play ----------

func _start(talents: Array = []) -> void:
	Dev.put("hero", "maga")
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	for e in game.horde.list.duplicate():
		e.alive = false
	game.horde.list.clear()
	Controls.virtual = pad
	pad.aim = Vector2.RIGHT
	game.player.pos = Vector2.ZERO
	game.player.facing = Vector2.RIGHT
	game.equip_talents(_ids(talents))
	game.player.magick.value = game.player.magick.max_value
	_step()


func _step(n := 1) -> void:
	for i in n:
		game._step(DT)
		pad.end_frame()
		for a: StringName in pad.held.keys():
			pad.release(a)
		pad.released.clear()


## A standing dummy (never moves, never acts): the blast's targets.
func _dummy(at: Vector2, id := &"skeleton") -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), at, false)
	e.hp = 5000.0
	e.max_hp = 5000.0
	e.cooldown = 999.0
	e.stun_t = 1000.0
	return e


func _blast() -> void:
	pad.press(&"heavy_attack")
	_step(40)


func _shot(tags: Array[StringName]) -> Projectiles.Shot:
	var s := Projectiles.Shot.new()
	s.tags = tags
	s.pos = game.player.pos
	return s


func test_brasa_viva_burns_the_selos_target_and_those_beside_it() -> void:
	_start([&"brasa_viva"])
	var marked := _dummy(Vector2(6, 0))
	var beside := _dummy(Vector2(6, 1.2))
	var far := _dummy(Vector2(6, 3.0))  # (3 m off the Selo: in the blast, past the burn)
	game.arcane.lay(marked)
	_blast()
	assert_gt(marked.burn_t, 0.0)
	assert_eq(marked.burn_dps, 4.0)
	assert_gt(beside.burn_t, 0.0, "within 1.5 m of it")
	assert_eq(far.burn_t, 0.0)


func test_without_a_selo_nothing_burns_from_brasa_viva() -> void:
	_start([&"brasa_viva"])
	var bare := _dummy(Vector2(6, 0))
	_blast()
	assert_eq(bare.burn_t, 0.0)


func test_eco_arcano_gives_one_more_magia_for_each_selo() -> void:
	_start([&"eco_arcano"])
	game.arcane.lay(_dummy(Vector2(6, 0)))
	game.arcane.lay(_dummy(Vector2(6.5, 0.6)))
	var magick := game.player.magick.value
	_blast()
	# -10 paid, +1 the finisher, +2 for each of the two Selos (1 and 1 more)
	assert_almost_eq(game.player.magick.value, magick - 10.0 + 1.0 + 4.0, 0.01)


func test_selo_duplo_holds_two_and_the_blast_takes_both() -> void:
	_start([&"eco_arcano", &"selo_duplo"])
	var e := _dummy(Vector2(6, 0))
	assert_true(game.arcane.lay(e))
	assert_true(game.arcane.lay(e), "the second Selo")
	assert_eq(game.arcane.seals.count(e), 2)
	_blast()
	assert_eq(e.hp, 5000.0 - roundf(32.0 + 44.0 * 1.4), "61.6 for the bonus of two")
	assert_false(game.arcane.seals.has(e))
	assert_eq(game.arcane.resonance.points, 2, "a point for each Selo")


func test_without_selo_duplo_the_second_chain_only_restarts_the_clock() -> void:
	_start([])
	var e := _dummy(Vector2(6, 0))
	assert_true(game.arcane.lay(e))
	assert_false(game.arcane.lay(e))
	assert_eq(game.arcane.seals.count(e), 1)


func test_the_tempestade_lays_one_selo_even_with_selo_duplo() -> void:
	_start([&"eco_arcano", &"selo_duplo"])
	var e := _dummy(Vector2(6, 0))
	game.arcane.lay(e, 1)
	game.arcane.lay(e, 1)
	assert_eq(game.arcane.seals.count(e), 1)


func test_cadeia_curta_lays_the_selo_on_the_second_shot() -> void:
	_start([&"eco_arcano", &"cadeia_curta"])
	var e := _dummy(Vector2(6, 0))
	game.arcane.shot_landed(e, _shot([&"arcane", &"bolt1"] as Array[StringName]))
	assert_false(game.arcane.seals.has(e), "not the first")
	game.arcane.shot_landed(e, _shot([&"arcane", &"bolt2", &"seal2"] as Array[StringName]))
	assert_true(game.arcane.seals.has(e), "the second")


func test_without_cadeia_curta_the_second_shot_lays_none_outside_the_circle() -> void:
	_start([])
	var e := _dummy(Vector2(6, 0))
	game.arcane.shot_landed(e, _shot([&"arcane", &"bolt2", &"seal2"] as Array[StringName]))
	assert_false(game.arcane.seals.has(e))
	game.arcane.shot_landed(e, _shot([&"arcane", &"bolt3", &"seal"] as Array[StringName]))
	assert_true(game.arcane.seals.has(e))


func test_cadeia_curta_makes_the_third_shot_five_weaker() -> void:
	_start([&"cadeia_curta"])
	var third: Array[StringName] = [&"light", &"bolt", &"arcane", &"seal", &"finisher"]
	var second: Array[StringName] = [&"light", &"bolt", &"arcane", &"seal2"]
	assert_almost_eq(15.0 * (1.0 + game.boons.stat(&"damage_pct", third)), 10.0, 0.01)
	assert_eq(game.boons.stat(&"damage_pct", second), 0.0)


func test_ruptura_makes_the_selo_leap_to_the_nearest_bare_enemy() -> void:
	_start([&"eco_arcano", &"selo_duplo", &"circulo_expandido", &"ruptura"])
	var marked := _dummy(Vector2(6, 0))
	var near := _dummy(Vector2(6, 6.0))  # (outside the blast, 6 m: too far to leap)
	var close := _dummy(Vector2(9.0, 0.0))  # (3 m off, outside the blast's 3.2... in range of the leap)
	game.arcane.lay(marked)
	_blast()
	assert_true(game.arcane.seals.has(close), "the nearest without a Selo within 4 m")
	assert_false(game.arcane.seals.has(near))
	assert_between(game.arcane.seals.left(close), Arcane.LEAP_SECONDS - 1.0, Arcane.LEAP_SECONDS)
	assert_eq(game.arcane.tally.leaps, 1)


func test_combustao_burns_all_the_blast_reaches_and_widens_it() -> void:
	_start([&"brasa_viva", &"combustao"])
	var bare := _dummy(Vector2(6, 0))
	var wide := _dummy(Vector2(6, 3.7))  # outside 3.2, inside 4.0
	_blast()
	assert_gt(bare.burn_t, 0.0)
	assert_eq(bare.burn_dps, 3.0)
	assert_lt(wide.hp, 5000.0, "the blast is a quarter wider")


func test_pavio_longo_and_chama_que_marca_burn_the_shots() -> void:
	_start([&"brasa_viva", &"pavio_longo"])
	var any: Array[StringName] = [&"light", &"bolt", &"arcane"]
	var third: Array[StringName] = [&"light", &"bolt", &"arcane", &"seal", &"finisher"]
	assert_eq(game.boons.stat(&"burn_dps", any), 2.0)
	assert_eq(game.boons.stat(&"burn_dps", third), 4.0)
	game.equip_talents(_ids([&"brasa_viva", &"eco_arcano", &"chama_que_marca"]))
	assert_eq(game.boons.stat(&"burn_dps", any), 0.0, "Chama que Marca burns only the shot that lays the Selo")
	assert_eq(game.boons.stat(&"burn_dps", third), 4.0)


func test_inferno_runico_leaves_embers_only_after_the_amplified_blast() -> void:
	_start([&"brasa_viva", &"combustao", &"eco_arcano", &"inferno_runico"])
	_dummy(Vector2(6, 0))
	var zones := game.ground.zones.size()
	_blast()
	assert_eq(game.ground.zones.size(), zones, "the plain blast: none")
	game.arcane.resonance.add(6)
	_step()
	game.player.magick.value = 50.0
	_blast()
	var ember: Ground.Zone = null
	for z in game.ground.zones:
		if z.kind == Ground.Kind.EMBER:
			ember = z
	assert_not_null(ember, "embers on the floor")
	assert_eq(ember.power, 8.0)
	assert_almost_eq(ember.life, 4.0, 0.7)


func test_brasa_gemea_throws_a_second_blast_at_half_after_three_selos() -> void:
	_start([&"brasa_viva", &"eco_arcano", &"chama_que_marca", &"brasa_gemea"])
	var a := _dummy(Vector2(6, 0))
	var b := _dummy(Vector2(6.6, 0.8))
	var c := _dummy(Vector2(6.6, -0.8))
	for e in [a, b, c]:
		game.arcane.lay(e)
	pad.press(&"heavy_attack")
	_step(18)  # (the windup is 0.18 s: the first blast has fallen)
	var after_first := a.hp
	assert_between(after_first, 5000.0 - 76.0 - 6.0, 5000.0 - 76.0, "76 (and a tick of the burn)")
	_step(40)
	assert_eq(game.arcane.tally.twins, 1)
	assert_between(after_first - a.hp, 38.0, 38.0 + 6.0, "half of what it took")


func test_brasa_gemea_needs_three_selos() -> void:
	_start([&"brasa_viva", &"eco_arcano", &"chama_que_marca", &"brasa_gemea"])
	game.arcane.lay(_dummy(Vector2(6, 0)))
	game.arcane.lay(_dummy(Vector2(6.6, 0.8)))
	_blast()
	_step(40)
	assert_eq(game.arcane.tally.twins, 0)


func _circle() -> void:
	pad.press(&"shout")
	_step(40)


func test_circulo_expandido_widens_the_circle_and_contencao_perfeita_lengthens_it() -> void:
	_start([&"circulo_expandido"])
	_dummy(Vector2(6, 0))
	assert_almost_eq(game.arcane._circle_size(), 4.0, 0.001, "3.2 and a quarter")
	game.equip_talents(_ids([&"circulo_expandido", &"prisao_sigilada", &"brasa_viva", &"contencao_perfeita"]))
	_circle()
	assert_almost_eq(game.arcane.circle.life, 6.0, 0.7, "6 s: 4 and 2 more")


func test_contencao_perfeita_lays_the_selo_on_the_first_shot_inside_the_circle() -> void:
	_start([&"circulo_expandido", &"prisao_sigilada", &"brasa_viva", &"contencao_perfeita"])
	var e := _dummy(Vector2(6, 0))
	_circle()
	game.arcane.shot_landed(e, _shot([&"arcane", &"bolt1"] as Array[StringName]))
	assert_true(game.arcane.seals.has(e))


func test_prisao_sigilada_roots_the_commons_when_the_pull_closes() -> void:
	_start([&"circulo_expandido", &"prisao_sigilada"])
	var centre := _dummy(Vector2(6, 0))
	var common := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(6, 2.0), false)
	common.cooldown = 999.0
	var elite := game.horde.spawn(game.horde.def(&"guard_elite"), Vector2(6, -2.0), false)
	elite.cooldown = 999.0
	centre.stun_t = 0.0
	common.stun_t = 0.0
	elite.stun_t = 0.0
	pad.press(&"shout")
	_step(int((0.2 + 0.4) / DT) + 2)  # (the windup, then the 0.4 s pull)
	assert_gt(common.stun_t, 0.0, "held in place")
	assert_lte(common.stun_t, 0.6)
	assert_eq(elite.stun_t, 0.0, "a guardian is only slowed")


func test_selo_no_chao_marks_all_inside_when_the_circle_closes() -> void:
	_start([&"eco_arcano", &"circulo_expandido", &"selo_no_chao"])
	var a := _dummy(Vector2(6, 0))
	var b := _dummy(Vector2(6, 2.0))
	var out := _dummy(Vector2(6, 9.0))
	pad.press(&"shout")
	_step(int((0.2 + 0.4) / DT) + 2)
	assert_true(game.arcane.seals.has(a))
	assert_true(game.arcane.seals.has(b))
	assert_false(game.arcane.seals.has(out))


func test_brasa_que_prende_burns_and_hurts_all_inside_when_the_circle_closes() -> void:
	_start([&"brasa_viva", &"circulo_expandido", &"brasa_que_prende"])
	var a := _dummy(Vector2(6, 0))
	pad.press(&"shout")
	_step(int((0.2 + 0.4) / DT) + 2)
	assert_between(a.hp, 5000.0 - 12.0 - 4.0, 5000.0 - 12.0)
	assert_gt(a.burn_t, 0.0)
	assert_eq(a.burn_dps, 4.0)


func test_the_circle_does_nothing_more_without_gifts() -> void:
	_start([])
	var a := _dummy(Vector2(6, 0))
	pad.press(&"shout")
	_step(int((0.2 + 0.4) / DT) + 2)
	assert_eq(a.hp, 5000.0)
	assert_eq(a.burn_t, 0.0)
	assert_false(game.arcane.seals.has(a))


func test_suspensao_larga_widens_and_lengthens_the_dome() -> void:
	_start([&"circulo_expandido", &"suspensao_larga"])
	pad.press(&"rush")
	_step(30)
	assert_not_null(game.arcane.dome)
	assert_almost_eq(game.arcane.dome.radius, 3.4, 0.01)
	assert_gt(game.arcane.dome.life, 2.5, "3.5 s, not 2.5")


func test_leitura_rapida_cuts_the_recharge_of_the_circle_and_the_dome() -> void:
	_start([&"eco_arcano", &"circulo_expandido", &"selo_no_chao", &"leitura_rapida"])
	var circle: Array[StringName] = [&"shout", &"cast", &"arcane"]
	var dome: Array[StringName] = [&"dash", &"arcane", &"dome"]
	var blast: Array[StringName] = [&"heavy", &"blast", &"arcane", &"finisher"]
	assert_eq(game.hero_gifts.state.cooldown_cut(circle), 0.25)
	assert_eq(game.hero_gifts.state.cooldown_cut(dome), 0.25)
	assert_eq(game.hero_gifts.state.cooldown_cut(blast), 0.0)


func test_passo_de_brasa_flashes_where_she_was_and_leaves_embers_where_she_lands() -> void:
	_start([&"brasa_viva", &"circulo_expandido", &"passo_de_brasa"])
	var near := _dummy(Vector2(1.2, 0.0))
	var far := _dummy(Vector2(1.2, 5.0))
	var zones := game.ground.zones.size()
	pad.move = Vector2.RIGHT
	pad.press(&"dodge")
	_step(2)
	assert_between(near.hp, 5000.0 - 12.0 - 4.0, 5000.0 - 12.0, "12 and a tick of the burn")
	assert_gt(near.burn_t, 0.0)
	assert_eq(far.hp, 5000.0)
	assert_gt(game.ground.zones.size(), zones, "embers where she came out")


func test_passo_longo_goes_eighty_centimetres_further() -> void:
	_start([&"passo_longo"])
	pad.move = Vector2.RIGHT
	pad.press(&"dodge")
	_step(2)
	assert_between(game.player.pos.x, 4.5 * 1.18, 4.5 * 1.18 + 0.6, "4.5 and 0.8 more")


func test_the_sustain_gifts_give_life_magia_and_the_rise() -> void:
	_start([&"firmeza", &"reserva", &"respiro", &"ainda_de_pe"])
	assert_eq(game.player.max_hp, 40.0)
	assert_eq(game.player.magick.max_value, 50.0 + 10.0 + 20.0)
	assert_eq(game.boons.stat(&"room_heal"), 2.0)
	assert_eq(game.boons.stat(&"rise_share"), 0.5)


# ---------- the Suspensão Absoluta ----------

func _absolute() -> void:
	game.arcane.open_absolute(HeroDef.maga().ultimate(&"dome_abs"))


func test_the_dome_walks_with_her_for_eight_seconds() -> void:
	_start([])
	_absolute()
	assert_not_null(game.arcane.ultra)
	assert_eq(game.arcane.ultra.radius, 5.5)
	game.player.pos = Vector2(3, 0)
	_step(2)
	assert_almost_eq(game.arcane.ultra.node.position.x, game.player.pos.x, 0.5, "it follows her")
	_step(int(8.0 / DT))
	assert_null(game.arcane.ultra)


func test_inside_it_every_shot_lays_a_selo_and_hits_thirty_percent_harder() -> void:
	_start([])
	var e := _dummy(Vector2(4, 0))
	game.arcane.shot_landed(e, _shot([&"arcane", &"bolt1"] as Array[StringName]))
	assert_false(game.arcane.seals.has(e), "outside it the first shot lays none")
	_absolute()
	var shot := _shot([&"arcane", &"bolt1"] as Array[StringName])
	shot.pos = e.pos
	assert_almost_eq(game.arcane.shot_mult(shot), 1.2, 0.001)
	game.arcane.shot_landed(e, shot)
	assert_true(game.arcane.seals.has(e), "the first shot lays one")
	var far := _shot([&"arcane", &"bolt1"] as Array[StringName])
	far.pos = Vector2(20, 0)
	assert_eq(game.arcane.shot_mult(far), 1.0, "past the dome")


func test_inside_it_the_blast_costs_five() -> void:
	_start([])
	_absolute()
	_step()
	assert_almost_eq(game.player.blast_discount, 0.5, 0.001)
	_dummy(Vector2(6, 0))
	var magick := game.player.magick.value
	_blast()
	assert_almost_eq(game.player.magick.value, magick - 5.0 + 1.0, 0.01, "5 paid, 1 back for the finisher")


func test_the_dome_holds_the_shots_of_commons_but_not_morvaths_nor_a_guardians() -> void:
	_start([])
	_absolute()
	var common := game.projectiles.fire(Projectiles.Kind.BOLT, Vector2(4, 0), Vector2(-1, 0), 8.0, 5.0)
	common.by = &"archer"
	var boss := game.projectiles.fire(Projectiles.Kind.BOLT, Vector2(4, 1), Vector2(-1, 0), 8.0, 5.0)
	boss.by = &""
	_step(2)
	assert_true(common.frozen, "an archer's shot hangs in the air")
	assert_false(boss.frozen, "Morvath's own goes on")


func test_the_dome_slows_everything_inside_even_the_boss() -> void:
	_start([])
	var e := _dummy(Vector2(3, 0))
	e.slow_t = 0.0
	_absolute()
	_step(2)
	assert_gt(e.slow_t, 0.0)


func test_the_second_ultimate_is_let_go_with_the_button_when_it_is_full() -> void:
	_start([])
	Dev.put("ultimate", "dome_abs")
	game.ults.equip(HeroDef.maga().ultimate(&"dome_abs"))
	Dev.drop("ultimate")
	game.ults.charge.add(1000.0)
	_step()
	assert_true(game.player.ult_ready)
	pad.press(&"ultimate")
	_step(40)
	assert_not_null(game.arcane.ultra)
	assert_eq(game.ults.uses, 1)


func test_a_new_room_takes_the_dome_away() -> void:
	_start([])
	_absolute()
	game.arcane.clear()
	assert_null(game.arcane.ultra)
	assert_eq(game.player.blast_discount, 0.0)


# ---------- the Blessings on her buttons (maga_m2.md 4) ----------

func _grant(stat: StringName, base: float, tag: StringName = &"") -> void:
	var m := BoonMod.new()
	m.stat = stat
	m.base = base
	m.tag = tag
	m.by_rarity = false
	game.boons.grant([m] as Array[BoonMod])


func test_the_dome_is_the_rush_button_for_the_skills_and_the_blessings_of_the_e() -> void:
	_start([])
	var dome: ComboNode = null
	for n in game.player.tree.all_nodes():
		if n.id == &"dome":
			dome = n
	assert_not_null(dome)
	assert_true(dome.has_tag(&"dash"), "the tag the E's Blessings read")
	assert_eq(Skills.trigger_of(dome), SkillDef.Trigger.RUSH)


func test_the_skill_of_the_special_falls_where_the_blast_fell_and_the_q_s_where_the_circle_stands() -> void:
	_start([])
	assert_eq(game.arcane.spot_of(SkillDef.Trigger.SPECIAL), Vector2.INF, "nothing thrown yet: at her feet")
	var e := _dummy(Vector2(6, 0))
	_blast()
	assert_eq(game.arcane.spot_of(SkillDef.Trigger.SPECIAL), Vector2(6, 0), "where it fell (it clings to nothing: no Selo)")
	assert_not_null(e)
	_circle()
	assert_eq(game.arcane.spot_of(SkillDef.Trigger.SHOUT), game.arcane.circle.at)
	assert_eq(game.arcane.spot_of(SkillDef.Trigger.RUSH), Vector2.INF)


func test_the_blessings_of_the_e_touch_each_enemy_that_comes_into_the_dome_once() -> void:
	_start([])
	_grant(&"burn_dps", 4.0, &"dash")
	var inside := _dummy(Vector2(1.5, 0))
	var outside := _dummy(Vector2(8, 0))
	pad.press(&"rush")
	_step(30)
	assert_gt(inside.burn_t, 0.0, "burning")
	assert_eq(outside.burn_t, 0.0)


func test_the_blessings_of_the_q_put_their_status_on_all_in_the_circle_when_it_closes() -> void:
	_start([])
	_grant(&"weak_time", 3.0, &"cast")
	var a := _dummy(Vector2(6, 0))
	pad.press(&"shout")
	_step(int((0.2 + 0.4) / DT) + 2)
	assert_gt(a.weak_t, 0.0, "weakened")


func test_a_push_blessing_makes_the_circle_draw_further() -> void:
	_start([])
	var centre := _dummy(Vector2(6, 0))
	var common := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(6, 3.0), false)
	common.cooldown = 999.0
	common.stun_t = 1000.0
	_grant(&"push_pct", 0.5, &"shout")
	pad.press(&"shout")
	_step(60)
	assert_almost_eq(common.pos.distance_to(centre.pos), 3.0 - 1.8, 0.25, "1.2 m and a half more (bodies keep their 1 m apart)")


func test_a_reach_blessing_lengthens_her_shots() -> void:
	_start([])
	_grant(&"reach_pct", 0.5, &"light")
	_dummy(Vector2(8, 0))
	pad.press(&"light_attack")
	_step(14)
	var longest := 0.0
	for s in game.projectiles.shots:
		longest = maxf(longest, s.life + s.flown / 30.0)
	assert_almost_eq(longest, 11.0 * 1.5 / 30.0, 0.04, "11 m of flight became 16.5")


func test_a_wave_size_blessing_widens_the_blast_and_a_shatter_one_breaks_the_frozen() -> void:
	_start([])
	_grant(&"wave_size_pct", 0.25, &"blast")
	var wide := _dummy(Vector2(6, 3.7))  # outside 3.2, inside 4.0
	_dummy(Vector2(6, 0))
	_blast()
	assert_lt(wide.hp, 5000.0)


func test_a_shatter_blessing_breaks_the_frozen_with_the_blast() -> void:
	_start([])
	_grant(&"shatter_pct", 0.5, &"blast")
	var frozen := _dummy(Vector2(6, 0))
	frozen.frozen_t = 5.0
	_blast()
	assert_lt(frozen.hp, 5000.0 - 32.0 - 5.0, "more than the plain 32")


# ---------- the Blessings of the E and the Passo that were missing, the film and the first Selo ----------

func test_a_shield_blessing_opens_the_dome_with_the_shield_ready() -> void:
	_start([])
	_grant(&"dome_shield", 1.0)
	game.player.shield_ready = false
	pad.press(&"rush")
	_step(30)
	assert_true(game.player.shield_ready)


func test_a_heal_blessing_gives_life_back_for_each_enemy_the_dome_held_when_it_ends() -> void:
	_start([])
	_grant(&"dome_heal", 2.0, &"dash")
	var a := _dummy(Vector2(1.5, 0))
	var b := _dummy(Vector2(0, 1.5))
	a.stun_t = 1000.0
	b.stun_t = 1000.0
	game.player.hp = 10.0
	pad.press(&"rush")
	_step(30)
	game.arcane.dome.life = 0.01
	_step(3)
	assert_almost_eq(game.player.hp, 14.0, 0.01, "2 for each of the two")


func test_a_push_blessing_shoves_what_stands_on_the_rim_of_the_dome_outward() -> void:
	_start([])
	_grant(&"push_pct", 0.8, &"dash")
	var e := _dummy(Vector2(2.4, 0))  # the dome is 2.6 m: the rim
	e.stun_t = 1000.0
	var core := _dummy(Vector2(0, 1.0))
	core.stun_t = 1000.0
	pad.press(&"rush")
	_step(30)
	assert_gt(e.pos.x, 2.6, "pushed out")
	assert_almost_eq(core.pos.y, 1.0, 0.3, "the middle is left alone")


func test_the_passo_lays_embers_where_she_left_and_where_she_came_out() -> void:
	_start([])
	_grant(&"dodge_ember_dps", 6.0)
	var from := game.player.pos
	pad.press(&"dodge")
	_step(3)
	var near_from := 0
	var near_to := 0
	for z in game.ground.zones:
		if z.kind != Ground.Kind.EMBER:
			continue
		if z.pos.distance_to(from) < 0.5:
			near_from += 1
		if z.pos.distance_to(game.player.pos) < 0.5:
			near_to += 1
	assert_gt(near_from, 0)
	assert_gt(near_to, 0)


func test_the_big_dome_wears_the_film_and_the_clock_and_takes_them_away() -> void:
	_start([])
	_absolute()
	var d := game.arcane.ultra
	assert_true(d.node.material_override is ShaderMaterial, "hexagon film")
	assert_not_null(d.clock)
	var clock := d.clock
	_step(30)
	assert_lt(float((clock.material_override as ShaderMaterial).get_shader_parameter(&"left")), 1.0, "the clock runs down")
	game.arcane.clear()
	await get_tree().process_frame
	assert_false(is_instance_valid(clock))


func test_the_first_selo_detonated_gives_10_xp_once() -> void:
	var curve := HeroDef.maga().mastery
	assert_eq(curve.run_xp({"first_seal": true}).first_seal, 10)
	assert_eq(curve.run_xp({}).first_seal, 0)
