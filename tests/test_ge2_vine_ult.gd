extends GutTest
## GE-2 of the heroes redesign: Respiro and Ainda de Pé are steps 4 and 5 of the Videira's Vida; the ultimate is the weapon's.

var vine := Vine.new(Vine.load_catalog())


func test_vida_has_five_steps_in_purchase_order() -> void:
	var ids := vine.nodes_of(&"vida").map(func(n: VineNode) -> StringName: return n.id)
	assert_eq(ids, [&"vida_1", &"vida_2", &"vida_3", &"respiro", &"ainda_de_pe"])
	assert_eq(Vine.BRANCHES.size(), 3, "no fourth branch")
	assert_eq(vine.nodes_of(&"provisao").size(), 3)


func test_the_new_nodes_carry_the_old_gifts_numbers() -> void:
	assert_eq(vine.find(&"respiro").mods[0].stat, &"room_heal")
	assert_eq(vine.find(&"respiro").mods[0].base, 2.0)
	assert_eq(vine.find(&"ainda_de_pe").mods[0].stat, &"rise_share")
	assert_eq(vine.find(&"ainda_de_pe").mods[0].base, 0.5)
	assert_eq(vine.find(&"ainda_de_pe").requires, &"respiro")
	assert_eq(vine.find(&"respiro").requires, &"vida_3")


func test_the_life_total_stays_at_fifteen() -> void:
	assert_eq(vine.life_total(&"ainda_de_pe"), 15)


func test_first_n_is_deterministic_and_takes_three_steps_only() -> void:
	var a := vine.first(9)
	assert_eq(a, vine.first(9))
	assert_eq(a.size(), 9)
	assert_false(a.has(&"respiro"), "the robot does not climb past step 3")
	assert_eq(vine.first(3), [&"vida_1", &"viajante", &"prata"] as Array[StringName])


func test_buying_walks_the_branch_and_grants_the_stats() -> void:
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, 500)
	MaterialPurse.give(d, MaterialPurse.MEMORY, 50)
	assert_eq(vine.problem(d, &"respiro"), Vine.Problem.NEEDS)
	for id in [&"vida_1", &"vida_2", &"vida_3", &"respiro", &"ainda_de_pe"]:
		assert_true(vine.buy(d, id), String(id))
	var state := BoonState.new()
	state.grant(vine.mods_of(Vine.bought_ids(d)))
	assert_eq(state.stat(&"room_heal"), 2.0)
	assert_eq(state.stat(&"rise_share"), 0.5)
	assert_eq(Vine.growth(d)[&"vida"], 5)


func test_every_hero_gets_the_gifts_of_the_vine_in_a_descent() -> void:
	var gs := GiftState.new(HeroDef.warrior(), _state_with_vine())
	assert_eq(gs.rises, 1)


func _state_with_vine() -> BoonState:
	var s := BoonState.new()
	s.grant(vine.mods_of(["respiro", "ainda_de_pe"]))
	return s


func test_the_ultimate_of_a_loadout_is_fixed() -> void:
	var data := SaveData.defaults()
	var block := SaveData.hero(data, "warrior")
	block.mastery_xp = HeroDef.warrior().mastery.total_to(12)
	block.ultimate = "vortex"
	data.runs = 6  # (SW-O5: the Ultimate's milestone)
	assert_eq(HeroLoadout.new(HeroDef.warrior(), data).ultimate(), &"cleave", "a saved choice is ignored")
	block.mastery_xp = 0
	assert_eq(HeroLoadout.new(HeroDef.warrior(), data).ultimate(), &"")
