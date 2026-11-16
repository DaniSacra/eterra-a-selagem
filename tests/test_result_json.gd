extends GutTest
## E1a-5 (B-c): the RESULT line of the smoke runs is JSON any tool can read (printed as a Dictionary, the boss's attacks
## came out as &"scythe" keys). A fight with Morvath, as `--start=boss` plays it, a few seconds in.

var game: Game


func test_the_result_of_a_fight_with_morvath_is_json() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	assert_not_null(game.boss)
	for i in 8 * 60:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
	var line := game.result_line()
	assert_true(line.begins_with("RESULT "))
	var json := JSON.new()
	assert_eq(json.parse(line.trim_prefix("RESULT ")), OK, "%s at line %d" % [json.get_error_message(), json.get_error_line()])
	var r: Dictionary = json.data
	assert_true(r.has("boss"), "the fight's numbers are there")
	assert_true((r.boss as Dictionary).has("attacks"))
	assert_gt((r.boss.attacks as Dictionary).size(), 0, "he attacked")
	for k: String in (r.boss.attacks as Dictionary):
		assert_false(k.begins_with("&"), "plain names, no StringName marks: %s" % k)
	assert_eq(int(r.kills), game.kills)
	assert_eq(r.keys().size(), game.result().keys().size(), "every field of result()")
