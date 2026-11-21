extends GutTest
## The robot turns the rooms' pieces on the pack as a player would, in the mould of Bot.column_plan (RP-09): it charges
## an unstable crystal whose column holds the pack (RP-14, Runas B) and lights an oil urn with the pack in its ring
## (RP-12, Cripta A), standing out of what will strike.

const DT := 1.0 / 60.0
var stage: StageDef = load("res://data/stages/catacombs.tres")


func _game(id: StringName, depth: int, variant: int) -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var base: RoomLayout = null
	for l in stage.layouts:
		if l.id == id:
			base = l
	game.rooms._enter(RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, depth, stage.layouts.find(base), variant))
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	return game


func test_the_bot_charges_a_crystal_whose_column_holds_the_pack() -> void:
	var game := _game(&"runes", 7, 1)
	var rf := game.rooms.runes
	assert_not_null(rf.crystals)
	for i in roundi(3.2 / DT):
		rf.step(DT)
	var guard := 0
	while rf.hazard.phase != ArenaHazard.Phase.REST and guard < 600:
		rf.step(DT)
		guard += 1
	var c: Vector2 = rf.crystals.def.crystals[0]
	var def := rf.hazard.def
	var mid := def.origin.x + (rf.crystals.col(0) + 0.5) * def.tile
	var p := Vector2(mid + 6.0, -4.0)
	game.horde.spawn(game.horde.def(&"skeleton"), Vector2(mid, -2.0), false)
	assert_null(Bot.crystal_plan(game, p), "one in the column: not worth it")
	game.horde.spawn(game.horde.def(&"skeleton"), Vector2(mid + 0.5, 3.0), false)
	var plan: Variant = Bot.crystal_plan(game, p)
	assert_not_null(plan, "two in its column: it goes for the crystal")
	assert_eq(plan.center, c)
	var x0 := def.origin.x + rf.crystals.col(0) * def.tile
	assert_true(plan.stand.x < x0 or plan.stand.x > x0 + def.tile, "he swings from out of the column it strikes")
	assert_true(game.arena.inside(plan.stand, Player.RADIUS), "from the floor")
	assert_lt(plan.stand.distance_to(c), Bot.REACH, "within a swing")
	assert_gt(plan.way.dot(c - plan.stand), 0.0, "swinging at it")


func test_the_bot_lights_an_urn_with_the_pack_in_its_ring() -> void:
	var game := _game(&"crypt", 9, 0)
	var uf := game.rooms.urns
	assert_not_null(uf)
	var urn: Vector2 = uf.hazard.def.urns[0]
	var p := urn + Vector2(-6.0, 0.0)
	game.horde.spawn(game.horde.def(&"skeleton"), urn + Vector2(-1.5, 1.2), false)
	assert_null(Bot.urn_plan(game, p), "one in the ring: not worth it")
	game.horde.spawn(game.horde.def(&"skeleton"), urn + Vector2(-1.2, -1.5), false)
	var plan: Variant = Bot.urn_plan(game, p)
	assert_not_null(plan, "two in the ring: it goes for the urn")
	assert_eq(plan.center, urn)
	assert_lt(plan.stand.distance_to(urn), Bot.REACH, "within a swing")
	assert_gt(plan.way.dot(urn - plan.stand), 0.0, "swinging at it")
	uf.hazard.stage[0] = UrnHazard.Stage.LIT
	assert_true(Bot.urn_plan(game, p) == null or Bot.urn_plan(game, p).center != urn, "never a lit urn again")


func test_no_plan_where_the_room_has_no_such_piece() -> void:
	var game := _game(&"crypt", 2, 1)
	game.horde.spawn(game.horde.def(&"skeleton"), Vector2(0, 0), false)
	game.horde.spawn(game.horde.def(&"skeleton"), Vector2(1, 0), false)
	assert_null(Bot.crystal_plan(game, Vector2.ZERO))
	assert_null(Bot.urn_plan(game, Vector2.ZERO))
