extends GutTest
## A Videira, V1 (data and rules; it replaced "O Preparo"): the nine nodes and their costs and coins, the order inside a
## branch, each effect (life, the merchant before every guardian, +1 shop item, the healing shelf, +10% of each material),
## the save's version 12 with the exact refund of the old tree, and the robot's --vine / --account.

const R := RunMap.Reward

var tree := Vine.new(Vine.load_catalog())


func _data(silver := 0, memory := 0) -> Dictionary:
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, silver)
	MaterialPurse.give(d, MaterialPurse.MEMORY, memory)
	return d


func _game(n: int, key := "vine") -> Game:
	Dev.put(key, str(n))
	var g: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(g)
	return g


func after_each() -> void:
	Dev.drop("vine")
	Dev.drop("account")
	Save.write()


# ---------- data ----------

func test_eleven_nodes_three_branches_costs_and_coins() -> void:
	assert_eq(tree.catalog.size(), 11, "Vida has Respiro and Ainda de Pé as steps 4 and 5 (redesign G)")
	assert_eq(tree.branches(), [&"vida", &"provisao", &"perseveranca"] as Array[StringName])
	for branch in tree.branches():
		var nodes := tree.nodes_of(branch)
		assert_eq(nodes.size(), 5 if branch == &"vida" else 3, "%s nodes" % branch)
		for i in 3:
			assert_eq(nodes[i].step, i + 1)
			assert_eq(nodes[i].cost, ([3, 6, 10] if branch == &"provisao" else [5, 10, 20])[i], "%s step %d" % [branch, i + 1])
			assert_eq(nodes[i].material, MaterialPurse.MEMORY if branch == &"provisao" else MaterialPurse.SILVER)
			assert_eq(nodes[i].requires, &"" if i == 0 else nodes[i - 1].id)
			assert_false(nodes[i].mods.is_empty())
			assert_ne(T.t(nodes[i].name_key), String(nodes[i].name_key))
			assert_ne(T.t(nodes[i].desc_key), String(nodes[i].desc_key))
			assert_false(T.t(nodes[i].desc_key).contains("—"), "no dash")
	for stat: StringName in [&"damage_pct", &"revive", &"room_heal_pct", &"rarity_bonus", &"gold_pct"]:
		for n in tree.catalog:
			for m in n.mods:
				assert_ne(m.stat, stat, "no damage and nothing of the old tree")
	assert_eq(T.t(&"vine_line"), "Raízes que fortalecem todas as jornadas")


func test_the_branch_order_and_the_states() -> void:
	var d := _data(100, 0)
	assert_eq(tree.state(d, &"vida_2"), Vine.State.LOCKED, "step 2 waits for step 1")
	assert_eq(tree.problem(d, &"vida_3"), Vine.Problem.NEEDS)
	assert_false(tree.buy(d, &"vida_2"))
	assert_eq(tree.state(d, &"vida_1"), Vine.State.AVAILABLE)
	assert_eq(tree.state(d, &"viajante"), Vine.State.SHORT, "Provisão is paid in Memória and he has none")
	var heard := []
	tree.bought.connect(func(id: StringName) -> void: heard.append(id))
	assert_true(tree.buy(d, &"vida_1"))
	assert_eq(heard, [&"vida_1"])
	assert_eq(tree.state(d, &"vida_1"), Vine.State.OWNED)
	assert_false(tree.buy(d, &"vida_1"), "once")
	assert_eq(tree.balance(d, &"vida_1"), 95)
	assert_eq(tree.state(d, &"vida_2"), Vine.State.AVAILABLE)
	assert_true(tree.buy(d, &"vida_2") and tree.buy(d, &"vida_3"))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 100 - 35)
	assert_eq(tree.bought_count(d), 3)
	assert_eq(tree.problem(d, &"nada"), Vine.Problem.UNKNOWN)


func test_the_coins_are_the_right_ones() -> void:
	var d := _data(50, 7)
	assert_true(tree.buy(d, &"viajante"))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.MEMORY), 4)
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 50, "Provisão takes no Prata")
	assert_true(tree.buy(d, &"prata"))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 45)
	assert_eq(MaterialPurse.amount(d, MaterialPurse.MEMORY), 4, "Perseverança takes no Memória")
	assert_false(tree.buy(d, &"estoque"), "6 Memória and he has 4")


# ---------- effects ----------

func test_life_is_five_each() -> void:
	var b := BoonState.new([] as Array[Boon])
	b.grant(tree.mods_of(["vida_1", "vida_2", "vida_3"]))
	assert_eq(b.stat(&"max_hp"), 15.0)
	var g := _game(9)
	assert_eq(g.vine_nodes, 9)
	assert_eq(g.player.max_hp, g.hero.max_hp + 15.0)


func test_a_merchant_before_every_guardian() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var with_it := 0
	for s in 40:
		var map := RunMap.new(stage, 7000 + s, -1, 3, true)
		for g: int in [map.miniboss_depth, map.miniboss2_depth]:
			if g <= 2:
				continue
			var kinds := map.layer(g - 1).map(func(r: RunMap.Room) -> int: return r.kind)
			assert_true(kinds.has(RunMap.Kind.FOUNTAIN), "the fountain stays (seed %d)" % s)
			assert_true(kinds.has(RunMap.Kind.SHOP), "the merchant takes the other door (seed %d, layer %d)" % [s, g - 1])
			for r in map.layer(g - 1):
				if r.kind == RunMap.Kind.SHOP:
					assert_true(map.is_route_shop(r), "a route shop, never the last one")
			with_it += 1
	assert_gt(with_it, 40, "both guardians of every seed")


func test_the_merchant_keeps_the_rules_of_the_graph() -> void:
	# the rules (arena uses, no arena twice in a row...) are checked by the graph itself and it draws again when one breaks:
	# with the merchant it must still find a graph every time, and not need many more tries
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var plain_failures := 0
	var traveler_failures := 0
	for s in 60:
		plain_failures += RunMap.new(stage, 9000 + s).failures
		var map := RunMap.new(stage, 9000 + s, -1, 3, true)
		traveler_failures += map.failures
		assert_lt(map.failures, RunMap.MAX_TRIES, "seed %d drew a graph" % s)
		assert_eq(map.last_depth(), stage.rooms + 1)
	assert_lte(traveler_failures, plain_failures + 60, "no more than one more try a graph")


func test_the_traveler_is_drawn_in_a_real_descent() -> void:
	var g := _game(2)
	assert_eq(g.boons.stat(&"traveler"), 1.0, "the first two the robot takes: vida_1 and O Viajante")
	assert_true(g.rooms.map.traveler)
	var shops := g.rooms.map.nodes.filter(func(r: RunMap.Room) -> bool: return r.kind == RunMap.Kind.SHOP and g.rooms.map.is_route_shop(r))
	assert_gte(shops.size(), 1)


func test_stock_one_more_and_a_healing_shelf() -> void:
	var g := _game(9)
	var heart := {"item": R.HEART, "price": 125, "group": 1}
	var base: Array[Dictionary] = [{"item": R.BOON, "price": 150, "group": 0}, heart, {"item": R.MAGICK, "price": 100, "group": 2}]
	var any := func(_i: int) -> bool: return true
	var picks := base.duplicate(true)
	g.rooms._vine_stock(picks, any)
	assert_eq(picks.size(), 4, "Estoque: one more")
	assert_true(picks.any(func(p: Dictionary) -> bool: return p.item == R.HEAL), "Reserva: the cure is there")
	var items := picks.map(func(p: Dictionary) -> int: return p.item)
	for i in items.size():
		assert_eq(items.count(items[i]), 1, "all different")
	# a shop with the cure already shown only gets the extra one
	var again: Array[Dictionary] = [{"item": R.HEAL, "price": 50, "group": 1}]
	g.rooms._vine_stock(again, any)
	assert_eq(again.size(), 2)
	# nothing bought: the shelf as it was
	var plain := _game_without_vine()
	var same := base.duplicate(true)
	plain.rooms._vine_stock(same, any)
	assert_eq(same, base)


func _game_without_vine() -> Game:
	Dev.drop("vine")
	var g: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(g)
	return g


func test_materials_ten_percent_each() -> void:
	var purse := MaterialPurse.new()
	purse.bonus = {MaterialPurse.SILVER: 0.1, MaterialPurse.MEMORY: 0.1, &"all": 0.0}
	assert_eq(purse.add(MaterialPurse.SILVER, &"door", 10), 11)
	assert_eq(purse.add(MaterialPurse.MEMORY, &"door", 10), 11)
	assert_eq(purse.add(MaterialPurse.EMERALD, &"boss", 5), 5, "the third node is not bought")
	var all := MaterialPurse.new()
	all.bonus = {&"all": 0.1}
	assert_eq(all.add(MaterialPurse.EMERALD, &"boss", 10), 11)
	var small := MaterialPurse.new()
	small.bonus = {MaterialPurse.SILVER: 0.1, &"all": 0.1}
	var got := 0
	for i in 10:
		got += small.add(MaterialPurse.SILVER, &"door", 1)
	assert_eq(got, 12, "the fraction is kept: 10 x 1 with 20% is 12")
	var plain := MaterialPurse.new()
	assert_eq(plain.add(MaterialPurse.SILVER, &"door", 7), 7, "without the Videira nothing changes")


func test_the_purse_of_a_descent_reads_the_stats() -> void:
	var g := _game(6)
	assert_almost_eq(float(g.materials.bonus[MaterialPurse.SILVER]), 0.25, 0.001)
	assert_almost_eq(float(g.materials.bonus[MaterialPurse.MEMORY]), 0.25, 0.001)
	assert_almost_eq(float(g.materials.bonus[&"all"]), 0.0, 0.001, "step 3 is not in the first six")
	var all := _game(9)
	assert_almost_eq(float(all.materials.bonus[&"all"]), 0.25, 0.001)


# ---------- the robot ----------

func test_the_robot_takes_whole_steps_with_requirements_before() -> void:
	var ids := tree.first(6)
	assert_eq(ids.size(), 6)
	for id in ids:
		var req := tree.find(id).requires
		assert_true(req == &"" or ids.has(req))
	assert_eq(tree.first(0).size(), 0)
	assert_eq(tree.first(99).size(), 9)


func test_account_is_the_old_name_of_the_option() -> void:
	var a := _game(3, "account")
	assert_eq(a.vine_nodes, 3)
	assert_eq(a.player.max_hp, a.hero.max_hp + 5.0, "vida_1 only: the three of the first step")


# ---------- the save ----------

func test_open_after_the_forge() -> void:
	var d := SaveData.defaults()
	assert_false(Vine.open(d))
	SaveData.hero(d, SaveData.FIRST_HERO).firsts = {"guardian": 1}
	assert_true(Vine.open(d))
	var e := SaveData.defaults()
	Vine.bought_ids(e).append("vida_1")
	assert_true(Vine.open(e), "who bought keeps it open")


func test_save_version_12_opens_older_files_with_nothing_bought() -> void:
	assert_eq(SaveData.VERSION, 17)
	for v in [1, 6, 7, 9, 11]:
		var out := SaveData.merged({"version": v, "runs": 2})
		assert_eq(out.version, SaveData.VERSION)
		assert_eq(Vine.bought_ids(out), [])
		assert_false(out.has("account"))
	var v7 := SaveData.merged(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save_v7.json")))
	assert_eq(MaterialPurse.amount(v7, MaterialPurse.SILVER), 42, "what he had stays")
	var kept := SaveData.merged({"version": 12, "vine": {"bought": ["vida_1", 3, "viajante"]}})
	assert_true(Vine.bought_ids(kept).has("vida_1") and Vine.bought_ids(kept).has("viajante"))


func test_the_old_tree_comes_back_as_what_he_paid() -> void:
	var v11 := SaveData.merged(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save_v11.json")))
	# vida_1 12, vida_2 25, forca_1 30, ouro_1 12 (Prata: 79); bencao_1 6, renascer 20 (Memória: 26)
	assert_eq(MaterialPurse.amount(v11, MaterialPurse.SILVER), 10 + 79)
	assert_eq(MaterialPurse.amount(v11, MaterialPurse.MEMORY), 2 + 26)
	assert_eq(MaterialPurse.amount(v11, MaterialPurse.EMERALD), 1, "the Esmeralda untouched")
	assert_eq(int(v11.materials_total.silver), 200, "a refund is not brought home")
	assert_eq(Vine.bought_ids(v11), [], "nothing of the new tree is bought")
	assert_eq(v11.version, SaveData.VERSION)
	assert_eq(v11.hub.guided, ["forge"])
	# opened again as a version 12 file the refund is not paid twice
	var again := SaveData.merged(v11)
	assert_eq(MaterialPurse.amount(again, MaterialPurse.SILVER), 89)
	# the table is the whole old catalog (12 nodes); an unknown or repeated id gives nothing
	assert_eq(SaveData.LEGACY_PREPARO.size(), 12)
	var odd := SaveData.merged({"version": 10, "materials": {"silver": 0, "memory": 0, "emerald": 0},
		"account": {"bought": ["vida_1", "vida_1", "nada", 4]}})
	assert_eq(MaterialPurse.amount(odd, MaterialPurse.SILVER), 12)
	var all := SaveData.defaults()
	SaveData.refund_preparo(all, {"bought": SaveData.LEGACY_PREPARO.keys()})
	assert_eq(MaterialPurse.amount(all, MaterialPurse.SILVER), 12 + 15 + 25 + 30 + 12 + 30 + 45 + 30 + 60)
	assert_eq(MaterialPurse.amount(all, MaterialPurse.MEMORY), 6 + 20 + 12)
