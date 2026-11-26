extends GutTest
## Lote D of the 2026-11-24 round: what a child who dies in room 5 takes home (Prata by room, Memória on reaching the
## guardian), the prices within reach and the fairer combat numbers (balance.md "Lote D").

var game: Game


func _run(kind: RunMap.Kind) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(kind)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


func _find(hero: HeroDef, id: StringName) -> ComboNode:
	var tree := load(hero.combos) as ComboTree
	var seen := {}
	var todo: Array[ComboNode] = []
	todo.assign(tree.neutral)
	while not todo.is_empty():
		var n: ComboNode = todo.pop_back()
		if n == null or seen.has(n):
			continue
		seen[n] = true
		if n.id == id:
			return n
		todo.append_array(n.next)
	return null


func test_only_fight_rooms_leave_silver() -> void:
	assert_eq(Rooms.room_silver(RunMap.Kind.COMBAT, 1), 1)
	assert_eq(Rooms.room_silver(RunMap.Kind.MINIBOSS, 1), 1)
	for k: RunMap.Kind in [RunMap.Kind.FOUNTAIN, RunMap.Kind.SHOP, RunMap.Kind.TRIAL, RunMap.Kind.ALTAR]:
		assert_eq(Rooms.room_silver(k, 1), 0)


func test_the_stage_numbers() -> void:
	var st := load("res://data/stages/catacombs.tres") as StageDef
	assert_eq([st.silver_room, st.silver_elite, st.memory_guardian_reach], [1, 2, 1])
	assert_eq(StageDef.new().silver_room, 0, "the default pays nothing")
	assert_eq(StageDef.new().memory_guardian_reach, 0)


func test_a_won_combat_room_brings_a_silver() -> void:
	_run(RunMap.Kind.COMBAT)
	game.rooms._room_cleared()
	assert_eq(game.materials.report().silver.room, game.rooms.stage.silver_room)
	assert_eq(game.materials.total(MaterialPurse.SILVER), 1)


func test_a_won_fountain_room_brings_nothing() -> void:
	_run(RunMap.Kind.FOUNTAIN)
	game.rooms._room_cleared()
	assert_eq(game.materials.total(MaterialPurse.SILVER), 0)


func test_reaching_the_guardian_brings_a_memory_even_unwon() -> void:
	_run(RunMap.Kind.MINIBOSS)
	var r := game.materials.report()
	assert_eq(r.memory.reach, game.rooms.stage.memory_guardian_reach)
	assert_eq(r.memory.guardian, 0, "the win itself is paid on the clear")
	game.rooms._room_cleared()
	assert_eq(game.materials.report().memory.guardian, game.rooms.stage.memory_guardian)


func test_gifts_of_mastery_2_to_5_cost_one_memory() -> void:
	for hero: HeroDef in [HeroDef.warrior(), HeroDef.maga()]:
		for t: TalentDef in hero.talents().catalog:
			if t.unlock_level <= 1:
				assert_eq(t.memory_cost, 0, String(t.id))
			elif t.unlock_level <= 5:
				assert_eq(t.memory_cost, 1, String(t.id))
			else:
				assert_eq(t.memory_cost, t.cost, String(t.id))


func test_the_prices() -> void:
	var trade: Dictionary = OficiosDef.live().trades[0]
	assert_eq([trade.give_n, trade.get_n], [5, 1])
	var vine := Vine.new(Vine.load_catalog())
	var costs := {}
	for b in vine.branches():
		costs[b] = vine.nodes_of(b).map(func(n: VineNode) -> int: return n.cost)
	assert_eq(costs[&"provisao"], [3, 6, 10])
	assert_eq(costs[&"vida"], [5, 10, 20, 30, 12], "Respiro (Prata 30) and Ainda de Pé (Memória 12) after the three of life")
	assert_eq(vine.find(&"prata").mods[0].value(1), 0.25)
	var forge := Forge.new(Forge.load_catalog())
	assert_eq([forge.find(&"temper_1").cost, forge.find(&"temper_2").cost], [20, 45])


func test_combat_for_those_who_read_late() -> void:
	assert_eq(Feel.live().bang_lead, 0.45)
	assert_eq((load("res://data/enemies/knight.tres") as EnemyDef).recharge_windup, 0.55)
	assert_eq(HeroDef.warrior().ultimate(&"cleave").charge, 75.0)
	assert_eq(HeroDef.maga().ultimate(&"converge").charge, 75.0)
	var maga := HeroDef.maga()
	assert_eq(_find(maga, &"spark").glint, 0.0)
	assert_eq(_find(HeroDef.warrior(), &"smash").hit_stop_ms, 90.0)
	assert_eq(_find(maga, &"shard").hit_stop_ms, 25.0)
	assert_eq(_find(maga, &"spark").hit_stop_ms, 0.0, "nothing on the light shots")
