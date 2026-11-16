extends GutTest
## The Warrior's tree of Gifts (TalentDef, Talents; warrior_spec.md 4): its shape, the unlock order, Devotion,
## requirements that count only when equipped, apex and bridge rules, one Gift per action, and the plain-number Gifts
## summed with the Blessings in BoonState.stat.

const B := TalentDef.Branch
const TIER := TalentDef.Tier
const TOP := 20

var book: Talents
var hero: HeroDef


func before_all() -> void:
	hero = HeroDef.warrior()
	book = hero.talents()


func _check(ids: Array, level: int = TOP, devotion: int = 99) -> Talents.Problem:
	return book.check(ids, level, devotion).problem


func test_the_tree_has_four_branches_bridges_and_sustain() -> void:
	for branch in [B.COMBO, B.FURIA, B.EMETH, B.MAGIA]:
		for tier in [TIER.ENTRY, TIER.MIDDLE, TIER.APEX]:
			var found := book.catalog.filter(func(t: TalentDef) -> bool: return t.branch == branch and t.tier == tier)
			assert_eq(found.size(), 1, "branch %d has one Gift of tier %d" % [branch, tier])
	var bridges := book.catalog.filter(func(t: TalentDef) -> bool: return t.tier == TIER.BRIDGE)
	assert_eq(bridges.size(), 4)
	var joined := {}
	for t: TalentDef in bridges:
		assert_eq(t.joins.size(), 2)
		assert_true(TalentDef.neighbours(t.joins[0], t.joins[1]), "%s joins neighbours" % t.id)
		joined[[mini(t.joins[0], t.joins[1]), maxi(t.joins[0], t.joins[1])]] = true
	assert_eq(joined.size(), 4, "one bridge between each pair of neighbours")
	assert_eq(book.catalog.filter(func(t: TalentDef) -> bool: return t.tier == TIER.SUSTAIN).size(), 3)
	for t in book.catalog:
		if t.tier == TIER.APEX:
			assert_true(TalentDef.neighbours(t.branch, t.partner), "%s asks for a neighbouring branch" % t.id)
		assert_between(t.cost, 1, 5, "%s costs 1 to 5" % t.id)
		assert_ne(T.t(t.name_key), String(t.name_key), "%s has its name" % t.id)
		assert_ne(T.t(t.desc_key), String(t.desc_key), "%s has its text" % t.id)


func test_the_diamond() -> void:
	assert_true(TalentDef.neighbours(B.COMBO, B.FURIA))
	assert_true(TalentDef.neighbours(B.FURIA, B.MAGIA))
	assert_true(TalentDef.neighbours(B.MAGIA, B.EMETH))
	assert_true(TalentDef.neighbours(B.EMETH, B.COMBO))
	assert_false(TalentDef.neighbours(B.COMBO, B.MAGIA), "opposite corners")
	assert_false(TalentDef.neighbours(B.FURIA, B.EMETH), "opposite corners")


func test_the_first_six_and_the_unlock_order() -> void:
	# warrior_spec.md 4.2 (costs) and 4.4 (levels); 2 and 6 are the ultimates
	var first := {&"quarto_corte": [1, 3], &"impeto": [3, 2], &"corte_crescente": [4, 3], &"lamina_faminta": [5, 2],
		&"passo_encadeado": [7, 2], &"avanco_feroz": [8, 3]}
	for id: StringName in first:
		var t := book.find(id)
		assert_eq(t.unlock_level, first[id][0], "%s unlocks at %d" % [id, first[id][0]])
		assert_eq(t.cost, first[id][1], "%s costs %d" % [id, first[id][1]])
	assert_true(book.unlocked_at(2).is_empty())
	assert_true(book.unlocked_at(6).is_empty())
	assert_eq(hero.ultimate(&"cleave").mastery_level, 2)
	assert_eq(hero.ultimate(&"vortex").mastery_level, 6)
	for level in range(1, TOP + 1):
		if level != 2 and level != 6:
			assert_false(book.unlocked_at(level).is_empty(), "level %d unlocks a Gift" % level)
	assert_eq(book.unlocked(TOP).size(), book.catalog.size(), "everything by level 20")
	assert_eq(book.unlocked(1).map(func(t: TalentDef) -> StringName: return t.id), [&"quarto_corte"])
	# the apexes come last (15 and on)
	for t in book.catalog:
		if t.tier == TIER.APEX:
			assert_gte(t.unlock_level, 15, "%s is late" % t.id)


func test_devotion_bounds_the_loadout() -> void:
	var curve := hero.mastery
	assert_eq(book.cost([&"quarto_corte", &"impeto"]), 5)
	# level 3: devotion 8
	assert_eq(_check([&"quarto_corte", &"impeto"], 3, curve.devotion(3)), Talents.Problem.OK)
	assert_eq(book.cost([&"quarto_corte", &"impeto", &"corte_crescente"]), 8)
	assert_eq(_check([&"quarto_corte", &"impeto", &"corte_crescente"], 4, 7), Talents.Problem.DEVOTION, "8 of 7")
	assert_eq(_check([&"quarto_corte", &"impeto", &"corte_crescente"], 4, curve.devotion(4)), Talents.Problem.OK, "8 of 9")


func test_locked_unknown_twice() -> void:
	assert_eq(_check([&"impeto"], 2), Talents.Problem.LOCKED)
	assert_eq(_check([&"impeto"], 3), Talents.Problem.OK)
	assert_eq(_check([&"nope"]), Talents.Problem.UNKNOWN)
	assert_eq(_check([&"impeto", &"impeto"]), Talents.Problem.TWICE)
	assert_eq(_check([]), Talents.Problem.OK, "nothing equipped is valid")


func test_a_requirement_counts_only_when_equipped() -> void:
	# unlocked (level 20) but not equipped: the middle cannot stand alone
	assert_eq(_check([&"passo_encadeado"]), Talents.Problem.NEEDS)
	assert_eq(_check([&"quarto_corte", &"passo_encadeado"]), Talents.Problem.OK)
	assert_eq(book.check([&"passo_encadeado"], TOP, 99).id, &"passo_encadeado", "names the Gift")
	assert_eq(_check([&"fio_longo"]), Talents.Problem.NEEDS)
	assert_eq(_check([&"corte_crescente", &"fio_longo"]), Talents.Problem.OK)
	# order does not matter
	assert_eq(_check([&"fio_longo", &"corte_crescente"]), Talents.Problem.OK)


func test_an_apex_needs_its_middle_and_its_neighbour() -> void:
	var line := [&"quarto_corte", &"passo_encadeado"]
	assert_eq(_check(line + [&"golpe_sem_fim"]), Talents.Problem.NEEDS, "no Furia Gift")
	assert_eq(_check(line + [&"corte_crescente", &"golpe_sem_fim"]), Talents.Problem.NEEDS, "Emeth is a neighbour, but it asks for Furia")
	assert_eq(_check(line + [&"impeto", &"golpe_sem_fim"]), Talents.Problem.OK)
	assert_eq(_check([&"quarto_corte", &"impeto", &"golpe_sem_fim"]), Talents.Problem.NEEDS, "no middle")
	# each apex asks for its own partner
	assert_eq(_check([&"impeto", &"avanco_feroz", &"quarto_corte", &"furia_plena"]), Talents.Problem.OK)
	assert_eq(_check([&"corte_crescente", &"fio_longo", &"lamina_faminta", &"onda_atravessante"]), Talents.Problem.OK)
	assert_eq(_check([&"lamina_faminta", &"reserva", &"corte_crescente", &"coracao_da_emeth"]), Talents.Problem.OK)
	assert_eq(_check([&"lamina_faminta", &"reserva", &"impeto", &"coracao_da_emeth"]), Talents.Problem.NEEDS, "Magia's apex asks for Emeth")


func test_a_bridge_needs_both_entries() -> void:
	assert_eq(_check([&"quarto_corte", &"investida"]), Talents.Problem.NEEDS)
	assert_eq(_check([&"impeto", &"investida"]), Talents.Problem.NEEDS)
	assert_eq(_check([&"quarto_corte", &"impeto", &"investida"]), Talents.Problem.OK)
	assert_eq(_check([&"impeto", &"lamina_faminta", &"sangue_quente"]), Talents.Problem.OK)
	assert_eq(_check([&"lamina_faminta", &"corte_crescente", &"onda_carregada"]), Talents.Problem.OK)
	assert_eq(_check([&"corte_crescente", &"quarto_corte", &"fio_do_passo"]), Talents.Problem.OK)
	# sustain needs only the centre
	assert_eq(_check([&"firmeza", &"respiro", &"ainda_de_pe"]), Talents.Problem.OK)


func test_one_gift_per_action() -> void:
	# Passo Encadeado and Fio do Passo both change the dash
	var both := [&"quarto_corte", &"passo_encadeado", &"corte_crescente", &"fio_do_passo"]
	assert_eq(_check(both), Talents.Problem.SLOT_TAKEN)
	assert_eq(book.can_add([&"quarto_corte", &"passo_encadeado", &"corte_crescente"], &"fio_do_passo", TOP, 99), Talents.Problem.SLOT_TAKEN)
	assert_eq(book.can_add([&"quarto_corte", &"corte_crescente"], &"fio_do_passo", TOP, 99), Talents.Problem.OK)
	# every Gift that changes an action rides on one with tags the Blessings see (they keep seeing the action)
	for t in book.catalog:
		if t.slot != Boon.Slot.NONE:
			assert_ne(Boon.SLOT_TAG[t.slot], &"", "%s keeps its action's tags" % t.id)


func test_a_saved_loadout_is_cleaned() -> void:
	# a Gift that does not exist, one locked, one whose need went with it, one over the Devotion
	var clean := book.sanitized([&"quarto_corte", &"nope", &"passo_encadeado", &"impeto"], 3, 8)
	assert_eq(clean, [&"quarto_corte", &"impeto"] as Array[StringName], "passo_encadeado is locked at 3")
	assert_eq(book.sanitized([&"passo_encadeado"], TOP, 99), [] as Array[StringName], "a middle without its entry goes")
	assert_eq(book.sanitized([&"quarto_corte", &"passo_encadeado"], TOP, 99), [&"quarto_corte", &"passo_encadeado"] as Array[StringName])
	assert_eq(book.sanitized([&"quarto_corte", &"impeto", &"corte_crescente"], 4, 7), [&"quarto_corte", &"impeto"] as Array[StringName], "over the Devotion")
	assert_eq(book.check(book.sanitized([&"impeto", &"golpe_sem_fim", &"quarto_corte"], TOP, 99), TOP, 99).problem, Talents.Problem.OK)


func test_number_gifts_add_up_with_the_blessings() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	var light: Array[StringName] = [&"light"]
	var heavy: Array[StringName] = [&"heavy"]
	assert_eq(state.stat(&"reach_pct", light), 0.0)
	state.equip_talents(book.defs([&"corte_crescente", &"fio_longo", &"firmeza", &"lamina_faminta", &"reserva"]))
	assert_almost_eq(state.stat(&"reach_pct", light), 0.15, 0.0001, "Fio Longo: light moves reach 15% more")
	assert_eq(state.stat(&"reach_pct", heavy), 0.0, "only the attack")
	assert_eq(state.stat(&"max_hp"), 10.0, "Firmeza")
	assert_eq(state.stat(&"magick_max"), 30.0, "Firmeza and Reserva")
	# a Blessing on the same number adds up (golpe_firme: reach of light moves)
	var firme := state.find(&"golpe_firme")
	state.take(firme, Boon.Rarity.EPIC)
	assert_almost_eq(state.stat(&"reach_pct", light), 0.15 + firme.mods[0].value(1), 0.0001, "Gift and Blessing in one sum, the Gift never scaled by rarity")
	state.equip_talents([])
	assert_almost_eq(state.stat(&"reach_pct", light), firme.mods[0].value(1), 0.0001)
	assert_eq(state.stat(&"max_hp"), 0.0, "the cache follows what is equipped")
