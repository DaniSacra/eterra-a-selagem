extends GutTest
## C1c, item 1 (docs/design/kit_c1c.md): the buttons feed each other. Magia by attack hit (0.5, once a swing) and by Quebra
## (3), the Brado's recharge shortened by hits (0.3 s) and Quebras (1.5 s) down to a floor of 8 s, capped against loops.

const SH := ComboNode.In.SHOUT

var hero: HeroDef
var feed: KitFeed


func before_each() -> void:
	# GP-1: the Warrior has no Brado to recharge (cd_refund_*, cd_floor are 0 in his data); the rules stay for a hero that has one
	# (the Maga's), so they are tested with the numbers the Warrior had
	hero = (load("res://data/heroes/warrior.tres") as HeroDef).duplicate()
	hero.cd_refund_hit = 0.3
	hero.cd_refund_break = 1.5
	hero.cd_floor = 8.0
	feed = KitFeed.new(hero)


func test_the_numbers_are_data() -> void:
	var warrior: HeroDef = load("res://data/heroes/warrior.tres")
	assert_eq(warrior.magick_on_break, 3.0)
	assert_eq([warrior.cd_refund_hit, warrior.cd_refund_break, warrior.cd_floor], [0.0, 0.0, 0.0], "GP-1: no Brado, nothing to refund")
	var tree: ComboTree = load(hero.combos)
	for id: StringName in [&"cut1", &"cut2", &"cut3"]:
		assert_eq(_node(tree, id).magick_per_hit, 0.5, str(id))


func _node(tree: ComboTree, id: StringName) -> ComboNode:
	return _find(tree.neutral, id)


func _find(list: Array[ComboNode], id: StringName) -> ComboNode:
	for n in list:
		if n.id == id:
			return n
		var deeper := _find(n.following(), id)
		if deeper != null:
			return deeper
	return null


func test_ten_hits_give_five_magick() -> void:
	var total := 0.0
	for i in 10:
		feed.step(0.5)  # slow enough that the cap never bites
		total += feed.hit_magick(0.5)
	assert_almost_eq(total, 5.0, 0.001)


func test_a_break_gives_three() -> void:
	assert_eq(feed.break_magick(&"attack"), 3.0)


func test_four_breaks_in_one_second_stop_at_the_cap() -> void:
	var total := 0.0
	for i in 4:
		feed.step(0.1)
		total += feed.break_magick(&"attack")
	assert_eq(total, 3.0, "3 a second at most")
	feed.step(1.0)
	assert_eq(feed.break_magick(&"attack"), 3.0, "the window moved on")


func test_hits_and_breaks_share_the_cap() -> void:
	feed.step(0.1)
	assert_eq(feed.break_magick(&"attack"), 3.0)
	assert_eq(feed.hit_magick(0.5), 0.0)


func test_no_magick_from_the_shout_or_the_ultimate() -> void:
	for s in [&"shout", &"dash", &"ultimate", &"burn", &"cast", &"embers"]:
		assert_eq(feed.break_magick(s), 0.0, str(s))
		assert_eq(feed.break_refund(s), 0.0, str(s))


func test_one_wave_refunds_at_most_eight() -> void:
	feed.wave_thrown()
	var total := 0.0
	for i in 12:  # a full room: a Quebra every half second
		feed.step(1.0)
		total += feed.break_magick(&"special")
	assert_eq(total, 8.0)
	feed.wave_thrown()
	feed.step(1.0)
	assert_eq(feed.break_magick(&"special"), 3.0, "the next wave starts over")


func _armed_runner() -> ComboRunner:
	# the Corte Circular as a move on the Brado's button, 12 s of recharge (what the Brado was)
	var tree: ComboTree = (load(hero.combos) as ComboTree).duplicate(true)
	var move := ComboTree.find(tree.neutral, ComboNode.In.HEAVY)
	move.input = SH
	move.cooldown = 12.0
	var runner := ComboRunner.new(tree)
	runner.press(SH)
	for i in 120:
		runner.step(1.0 / 60.0)
	return runner


func test_the_shout_is_back_by_hits_but_never_before_the_floor() -> void:
	var runner := _armed_runner()
	var id := ComboTree.find(runner.tree.neutral, SH).id
	assert_gt(runner.cooldown_left(id), 0.0)
	var t := 0.0
	for i in 40:
		runner.cooldown_refund(id, hero.cd_refund_hit, hero.cd_floor)
	assert_gt(runner.cooldown_left(id), 0.0, "40 hits do not free it at once")
	var age := 2.0  # the 120 steps above
	while runner.cooldown_left(id) > 0.0:
		runner.step(1.0 / 60.0)
		age += 1.0 / 60.0
		t += 1.0 / 60.0
		runner.cooldown_refund(id, 1.5, hero.cd_floor)
		assert_lt(t, 20.0)
	assert_gte(age, hero.cd_floor - 0.05, "never back before 8 s")


func test_the_floor_is_the_most_it_gives() -> void:
	var runner := _armed_runner()
	var id := ComboTree.find(runner.tree.neutral, SH).id
	var taken := runner.cooldown_refund(id, 100.0, hero.cd_floor)
	assert_almost_eq(taken, 12.0 - 8.0, 0.05)  # 12 s armed, 8 s the floor
	assert_gt(runner.cooldown_left(id), 0.0)


func test_a_ready_move_gives_nothing() -> void:
	var runner := ComboRunner.new(load(hero.combos))
	assert_eq(runner.cooldown_refund(&"shout", 1.0, 8.0), 0.0)


func test_in_the_game_hits_and_breaks_feed() -> void:
	var game := (load("res://scenes/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	var p := game.player
	p.magick.value = 10.0
	var cut1 := ComboTree.find(p.tree.neutral, ComboNode.In.LIGHT)
	game.combat.landed.emit(cut1, cut1.tags, 5)
	assert_almost_eq(p.magick.value, 10.5, 0.001, "once a swing, not for each of the five")
	game.horde.poise_broken.emit(null, &"attack")
	assert_almost_eq(p.magick.value, 13.0, 0.001, "the Quebra tops up to the cap of 3 a second: 0.5 + 2.5")
	game.horde.poise_broken.emit(null, &"shout")
	assert_almost_eq(p.magick.value, 13.0, 0.001, "not the Brado's")
