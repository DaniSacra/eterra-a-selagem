extends GutTest
## The Supremo heals a tenth of the max life as it starts (Game.ULT_HEAL).


func test_ult_start_heals_a_tenth() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_frames(2)
	game.player.hp = 10.0
	game.player.ult_started.emit(Vector2.RIGHT)
	assert_almost_eq(game.player.hp, 10.0 + game.player.max_hp * Game.ULT_HEAL, 0.01)
	assert_eq(Game.ULT_HEAL, 0.10)
