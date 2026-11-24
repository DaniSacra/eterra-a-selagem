extends GutTest
## Balance 2026-11-24: every won fight room gives back a base of life (StageDef.room_heal_base), on top of the Respiro.

func test_only_fight_rooms_heal() -> void:
	assert_eq(Rooms.base_room_heal(RunMap.Kind.COMBAT, 3.0), 3.0)
	assert_eq(Rooms.base_room_heal(RunMap.Kind.MINIBOSS, 3.0), 3.0)
	for k: RunMap.Kind in [RunMap.Kind.FOUNTAIN, RunMap.Kind.SHOP, RunMap.Kind.TRIAL, RunMap.Kind.ALTAR]:
		assert_eq(Rooms.base_room_heal(k, 3.0), 0.0)


func test_clearing_a_room_heals_without_passing_the_max() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await get_tree().process_frame
	game.rooms.room = RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.NONE, 2)
	assert_eq(game.rooms.stage.room_heal_base, 3.0)
	game.player.hp = game.player.max_hp - 10.0
	var before := game.player.hp
	game.rooms._room_cleared()
	assert_almost_eq(game.player.hp, before + 3.0, 0.01)
	game.player.hp = game.player.max_hp - 1.0
	game.rooms._room_cleared()
	assert_eq(game.player.hp, game.player.max_hp)
