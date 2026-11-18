extends GutTest
## QA T5 (2026-11-17): reproductions of what the integrated QA found, handed to the owners.
## Q-T5-2 (owner: gameplay-engineer, end screen with ui-ux-designer): a run without a save (--nosave, the tests)
## awards no Mastery (test_run_log.gd, test_without_a_save_nothing_is_awarded), but Game.mastery_report is still
## filled, so the victory screen says "+220 XP" and fills the Mastery bar for XP that is never kept
## (docs/gallery/t5/before/50_tela_vitoria.jpg and after/50_tela_vitoria.jpg).

var game: Game


func test_without_a_save_the_end_screen_promises_no_mastery() -> void:
	assert_false(Save.enabled, "the GUT pre-run hook turns the save off, as --nosave")
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.rooms.won.assign([RunMap.Kind.COMBAT, RunMap.Kind.COMBAT, RunMap.Kind.MINIBOSS])
	game.log_run("victory")
	var report: Dictionary = game.mastery_report
	var shown := int((report.get("gain", {}) as Dictionary).get("total", 0))
	assert_eq(shown, 0, "no XP shown at the end when nothing is saved (shown %d)" % shown)
