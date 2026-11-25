extends GutTest
## SW-O5: the milestones of the Santuário (Milestones, MilestoneDef, HubGate): what each one asks, one new thing per
## visit, the Ultimate, what an older save keeps, the first descent not opening the Forja. (The Coragem has its own
## tests, test_courage*, untouched.)

var _mastery2: int


func before_all() -> void:
	_mastery2 = HeroDef.warrior().mastery.total_to(2)


func after_each() -> void:
	HubGate.end_visit()


func _d(runs := 0, first := 0) -> Dictionary:
	var d := SaveData.defaults()
	d.runs = runs
	d.first = first
	return d


func test_new_save_has_only_the_portal() -> void:
	var d := _d()
	assert_true(Milestones.reached(d).is_empty())
	assert_eq(HubGate.open_ids(d), [HubPlan.PORTAL] as Array[StringName])
	assert_eq(Milestones.next_to_present(d), &"")
	assert_false(Milestones.ult_open(d))


func test_first_descent_done_or_skipped_opens_the_tree() -> void:
	assert_eq(Milestones.reached(_d(1, 1)), [&"tree"] as Array[StringName])
	assert_true(Milestones.open(_d(0, 2), &"tree"), "skipped counts")
	assert_false(Milestones.open(_d(0, 0), &"tree"))


func test_third_descent_opens_forge_and_book_one_per_visit() -> void:
	var d := _d(3, 1)
	assert_true(Milestones.open(d, &"forge") and Milestones.open(d, &"book"))
	HubGate.mark_presented(d, [HubPlan.TREE])
	HubGate.begin_visit(d)
	assert_eq(HubGate.to_present(d), [HubPlan.SMITH] as Array[StringName])
	assert_true(HubGate.is_open(d, HubPlan.SMITH))
	assert_false(HubGate.is_open(d, HubPlan.BOOK), "the Livro is open next visit")
	HubGate.mark_presented(d, HubGate.to_present(d))
	assert_false(HubGate.is_open(d, HubPlan.BOOK), "still not: the visit's pick is fixed")
	HubGate.end_visit()
	HubGate.begin_visit(d)
	assert_eq(HubGate.to_present(d), [HubPlan.BOOK] as Array[StringName])
	assert_true(HubGate.is_open(d, HubPlan.BOOK))


func test_fourth_descent_opens_the_vine() -> void:
	assert_false(Milestones.open(_d(3, 1), &"account"))
	assert_true(Milestones.open(_d(4, 1), &"account"))


func test_fifth_descent_or_first_stone_opens_the_vendor() -> void:
	assert_false(Milestones.open(_d(4, 1), &"vendor"))
	assert_true(Milestones.open(_d(5, 1), &"vendor"))
	var s := _d(1, 1)
	Oficios.block(s).items_total[String(OficiosDef.live().stone)] = 1
	assert_true(Milestones.open(s, &"vendor"), "the first Pedra Funda")


func test_ultimate_needs_six_descents_and_mastery_two() -> void:
	var d := _d(6, 1)
	SaveData.hero(d, SaveData.FIRST_HERO).mastery_xp = _mastery2
	assert_true(Milestones.ult_open(d))
	var one := _d(6, 1)
	SaveData.hero(one, SaveData.FIRST_HERO).mastery_xp = _mastery2 - 1
	assert_false(Milestones.ult_open(one), "Mastery 1")
	var few := _d(5, 1)
	SaveData.hero(few, SaveData.FIRST_HERO).mastery_xp = _mastery2
	assert_false(Milestones.ult_open(few), "the sixth descent not yet")


func test_the_loadout_has_no_ultimate_before_its_milestone() -> void:
	# (the Ultimate's own Mastery level is the data's, 3; the milestone asks 2 and 6 descents on top of it)
	var d := _d(2, 1)
	SaveData.hero(d, SaveData.FIRST_HERO).mastery_xp = HeroDef.warrior().mastery.total_to(3)
	assert_eq(HeroLoadout.new(HeroDef.warrior(), d).ultimate(), &"")
	d.runs = 6
	assert_ne(HeroLoadout.new(HeroDef.warrior(), d).ultimate(), &"")


func test_the_first_victory_opens_the_heroes_and_the_juramentos() -> void:
	var d := _d(2, 1)
	assert_false(Milestones.open(d, &"maga"))
	d.wins = 1
	assert_true(Milestones.open(d, &"maga"))
	assert_true(Juramentos.unlocked(d))


func test_the_first_descent_guardian_does_not_open_the_forge() -> void:
	var d := _d(1, 1)
	# the first descent writes neither firsts.guardian nor guardian_run
	assert_false(Milestones.open(d, &"forge"))
	SaveData.hero(d, SaveData.FIRST_HERO).firsts = {"guardian_run": 1}
	assert_true(Milestones.open(d, &"forge"), "a guardian of a counting descent does")


func test_an_old_save_keeps_what_it_had() -> void:
	var d := _d(3, 1)
	HubGate.mark_presented(d, [HubPlan.VENDOR])
	assert_true(HubGate.is_open(d, HubPlan.VENDOR), "Vendedor shown under the old rule, runs 3")
	var f := _d(1, 1)
	SaveData.hero(f, SaveData.FIRST_HERO).forge.temper = 1
	assert_true(HubGate.is_open(f, HubPlan.SMITH), "Temperar bought")
	# an old hero of Mastery 2 with 3 descents keeps the Ultimate (grandfather, called when an old file is read)
	var u := _d(3, 1)
	SaveData.hero(u, SaveData.FIRST_HERO).mastery_xp = _mastery2
	assert_false(Milestones.ult_open(u))
	Milestones.grandfather(u)
	assert_true(Milestones.ult_open(u))
	assert_true(HubGuide.shown(u).has("ult"), "and not told again")


func test_the_table_is_data_in_order_with_text() -> void:
	var defs := Milestones.catalog()
	assert_eq(defs.size(), 7)
	var last := -1
	for m in defs:
		assert_gt(m.order, last)
		last = m.order
		assert_true(HubGate.TEXT.has(m.opens), "%s has an opening sentence" % m.id)
	assert_eq(defs.map(func(m: MilestoneDef) -> StringName: return m.id), [&"tree", &"forge", &"book", &"account", &"vendor", &"ult", &"maga"])
