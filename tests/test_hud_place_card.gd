extends GutTest
## N1 2.4: the arena's name card never overlaps a boss's bar (it stands under the bar's real height) and is styled as a card.


func _hud() -> Hud:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_process_frames(2)
	return game.hud


func test_place_card_stands_under_the_boss_bar() -> void:
	var hud := await _hud()
	hud.show_place("Fonte de Luz")
	hud._boss_box.visible = true
	hud._place_phase_box()
	var bottom: float = hud._boss_box.position.y + hud._boss_box.get_combined_minimum_size().y
	assert_gt(hud._phase_box.position.y, bottom, "the card clears the bar")
	assert_true(hud._phase_rule_top.visible, "card has its filets")


func test_phase_name_has_no_filets() -> void:
	var hud := await _hud()
	hud.show_phase("O Ritual. Derrube os mortos.")
	assert_false(hud._phase_rule_top.visible)
