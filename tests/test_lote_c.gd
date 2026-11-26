extends GutTest
## Lote C of the 2026-11-24 round: the hit stop by blow (CB 1), the weight of the special and of the Explosão on contact
## (CB 2, KT 4), the hurt robot's ultimate (KT 3) and the log's counts of use (KT 9).

var game: Game


func _find(node: ComboNode, id: StringName, seen: Dictionary = {}) -> ComboNode:
	if node == null or seen.has(node):
		return null
	seen[node] = true
	if node.id == id:
		return node
	for n in node.next:
		var f := _find(n, id, seen)
		if f != null:
			return f
	return null


func _node(hero: HeroDef, id: StringName) -> ComboNode:
	var tree := load(hero.combos) as ComboTree
	for first in tree.neutral:
		var f := _find(first, id)
		if f != null:
			return f
	return null


func test_a_hit_stop_does_not_swallow_the_next_cut_of_a_tight_chain() -> void:
	# the 2nd cut lands 13 frames (0.217 s) after the 1st
	assert_lt(Combat.HIT_SLOW_COOLDOWN, 13.0 / 60.0, "the 2nd cut plays its own hit stop")
	assert_gte(Combat.HIT_SLOW_COOLDOWN, 0.15, "but never two in under 0.15 s")


func test_the_special_and_the_explosion_weigh_the_light_shots_do_not() -> void:
	var warrior := HeroDef.warrior()
	var maga := HeroDef.maga()
	assert_gt(Combat.shot_stop_ms(_node(warrior, &"lance")), 0.0, "the Lança (GP-1: no wave, its own hit stop)")
	assert_eq(Combat.shot_stop_ms(_node(maga, &"shard")), Combat.SHOT_STOP_MS, "the Explosão")
	assert_eq(Combat.shot_stop_ms(_node(maga, &"spark")), 0.0, "the Centelha")
	assert_almost_eq(Combat.SHOT_STOP_MS, 25.0, 0.01, "2 frames")


func test_the_explosion_wave_calls_the_hit_stop_and_shot_1_does_not() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	var e := game.horde.spawn(game.horde.def(&"skeleton"), game.player.pos + Vector2(3, 0), false)
	var tags: Array[StringName] = [&"heavy", &"wave"]
	var special := game.combat.throw_wave(_node(HeroDef.maga(), &"shard"), game.player.pos, Vector2.RIGHT, Color.WHITE, tags)
	assert_gt(special.stop_ms, 0.0)
	game.fx.hits.clear()
	game.combat.on_shot_hit(e, special)
	assert_true(game.fx.hits.active(), "the Explosão's contact starts a hit stop")
	game.fx.hits.clear()
	game.combat.on_shot_hit(e, special)
	assert_false(game.fx.hits.active(), "once per shot")
	var plain := game.projectiles.fire_wave(Projectiles.Kind.SPARK, game.player.pos, Vector2.RIGHT, 10.0, 6.0, 1.0, Color.WHITE, tags)
	game.combat.on_shot_hit(e, plain)
	assert_false(game.fx.hits.active(), "a shot with no stop_ms (the Maga's 1 and 2) has none")


func test_the_hurt_robot_spends_a_full_ultimate() -> void:
	assert_true(Bot.hurt_for_ult(true, 10.0, 40.0))
	assert_false(Bot.hurt_for_ult(true, 30.0, 40.0), "healthy")
	assert_false(Bot.hurt_for_ult(false, 5.0, 40.0), "not full")
	assert_false(Bot.hurt_for_ult(true, 16.0, 40.0), "40% exactly is not under it")


func test_the_log_counts_the_use_of_each_button() -> void:
	var u := RunLog.uses_of({"q": 3, "shift": 1, "space": 20, "dry_hits": 4})
	for k in RunLog.USE_KEYS:
		assert_true(u.has(k), k)
	assert_eq(u.e, 0)
	assert_eq(u.space, 20)
	assert_eq(RunLog.normalized({"version": 6, "outcome": "death"}).uses, {}, "an older line reads with no counts")
	assert_eq(RunLog.uses_of({}).dry_hits, 0)


func test_a_run_counts_its_uses() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game._on_dodged(Vector2.RIGHT)
	game.player.dodge_charges = 0
	game.player.was_hurt.emit(1.0)
	var u := RunLog.uses_of(game.uses)
	assert_eq(u.space, 1)
	assert_eq(u.dry_hits, 1)
	assert_true(RunReport.entry(game, "death", {}).has("uses"))
