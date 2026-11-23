extends GutTest
## The account's tree "O Preparo" (Lote 5): the data, buying, the order the robot takes, the save's version 10 and the
## effects (rarity, life, second life).

var tree := Account.new(Account.load_catalog())


func _data(silver := 0, memory := 0) -> Dictionary:
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, silver)
	MaterialPurse.give(d, MaterialPurse.MEMORY, memory)
	return d


func test_the_catalog_is_between_8_and_12_nodes_with_valid_requirements() -> void:
	assert_between(tree.catalog.size(), 8, 12)
	var seen: Array[StringName] = []
	for n in tree.catalog:
		assert_gt(n.cost, 0)
		assert_false(n.mods.is_empty(), "%s has numbers" % n.id)
		assert_true(n.requires == &"" or seen.has(n.requires), "%s: its requirement comes earlier" % n.id)
		assert_ne(T.t(n.name_key), String(n.name_key), "%s has a name" % n.id)
		assert_ne(T.t(n.desc_key), String(n.desc_key), "%s has a text" % n.id)
		seen.append(n.id)


func test_buy_spends_keeps_and_refuses_what_it_cannot() -> void:
	var d := _data(20)
	assert_eq(tree.problem(d, &"vida_1"), Account.Problem.OK)
	assert_true(tree.buy(d, &"vida_1"))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 8)
	assert_eq(tree.problem(d, &"vida_1"), Account.Problem.OWNED)
	assert_false(tree.buy(d, &"vida_1"), "once")
	assert_eq(tree.problem(d, &"vida_2"), Account.Problem.SHORT, "25 Prata and he has 8")
	assert_eq(tree.problem(d, &"renascer"), Account.Problem.NEEDS)
	assert_eq(tree.problem(d, &"nada"), Account.Problem.UNKNOWN)


func test_costs_grow_along_a_branch() -> void:
	for n in tree.catalog:
		if n.requires != &"" and tree.find(n.requires).material == n.material:
			assert_gt(n.cost, tree.find(n.requires).cost, "%s costs more than %s" % [n.id, n.requires])


func test_mods_sum_in_the_boon_state() -> void:
	var b := BoonState.new([] as Array[Boon])
	b.grant(tree.mods_of(["vida_1", "vida_2", "ouro_1", "renascer"]))
	assert_eq(b.stat(&"max_hp"), 16.0)
	assert_almost_eq(b.stat(&"gold_pct"), 0.15, 0.001)
	assert_eq(b.stat(&"revive"), 1.0)


func test_robot_takes_the_first_nodes_with_requirements_before() -> void:
	var ids := tree.first(7)
	assert_eq(ids.size(), 7)
	for id in ids:
		var req := tree.find(id).requires
		assert_true(req == &"" or ids.has(req))
	assert_eq(tree.first(0).size(), 0)


func test_open_after_the_forge() -> void:
	var d := SaveData.defaults()
	assert_false(Account.open(d))
	SaveData.hero(d, SaveData.FIRST_HERO).firsts = {"guardian": 1}
	assert_true(Account.open(d))
	var e := SaveData.defaults()
	Account.bought(e).append("vida_1")
	assert_true(Account.open(e), "who bought keeps it open")


func test_rarity_bonus_moves_the_first_steps_only() -> void:
	var base: Array[float] = [0.10, 0.05, 0.0]
	assert_eq(Account.better(base, 0.0), base)
	var more := Account.better(base, 0.08)
	assert_almost_eq(more[0], 0.18, 0.001)
	assert_almost_eq(more[1], 0.09, 0.001)
	assert_eq(more[2], 0.0)
	assert_eq(base[0], 0.10, "the stage's own chances are not changed")


func test_save_version_10_migrates_older_files() -> void:
	assert_gte(SaveData.VERSION, 10, "v11 (PT-5, hub.guided) keeps the account")
	for v in [1, 6, 7, 9]:
		var out := SaveData.merged({"version": v, "runs": 2})
		assert_eq(out.version, SaveData.VERSION)
		assert_eq(Account.bought(out), [])
	var v7 := SaveData.merged(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save_v7.json")))
	assert_eq(MaterialPurse.amount(v7, MaterialPurse.SILVER), 42, "what he had stays")
	assert_eq(Account.bought(v7), [])
	var kept := SaveData.merged({"version": 10, "account": {"bought": ["vida_1", 3, "forca_1"]}})
	assert_eq(Account.bought(kept).size() >= 2, true)
	assert_true(Account.bought(kept).has("vida_1") and Account.bought(kept).has("forca_1"))


func test_account_option_equips_the_game() -> void:
	var g := _game(3)
	assert_eq(g.account_nodes, 3)
	assert_eq(g.player.max_hp, g.hero.max_hp + 16.0, "the first 3 nodes: Vigor I, Fôlego da Sala, Vigor II")


func test_second_life_stands_him_up_once() -> void:
	var g := _game(7)
	assert_eq(g.player.revives, 1)
	g.player.hurt(g.player.max_hp + 10.0, g.player.pos + Vector2.RIGHT)
	assert_true(g.player.alive())
	assert_almost_eq(g.player.hp, g.player.max_hp * Account.REVIVE_HP, 0.01)
	assert_eq(g.player.revives, 0)
	g.player.invuln = 0.0
	g.player.hurt(g.player.max_hp + 10.0, g.player.pos + Vector2.RIGHT)
	assert_false(g.player.alive(), "only once")


func _game(n: int) -> Game:
	Dev.put("account", str(n))
	var g: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(g)
	return g


func after_each() -> void:
	Dev.drop("account")
