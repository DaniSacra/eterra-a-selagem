extends GutTest


func test_merged_fills_missing_keys_and_keeps_valid_ones() -> void:
	var out := SaveData.merged({"options": {"master": 0.3, "bogus": 1}, "wins": 2.0})
	assert_eq(out.options.master, 0.3)
	assert_eq(out.options.sfx, SaveData.defaults().options.sfx)
	assert_false(out.options.has("bogus"))
	assert_eq(out.wins, 2, "JSON numbers come back as floats and are read as ints")
	assert_eq(typeof(out.wins), TYPE_INT)
	assert_eq(SaveData.merged({"wins": "many"}).wins, 0)


func test_merged_survives_garbage() -> void:
	assert_eq(SaveData.merged(null).version, SaveData.VERSION)
	assert_eq(SaveData.merged("x").best_times, [])


func test_best_times_keep_the_fastest_in_order() -> void:
	var d := SaveData.defaults()
	assert_true(SaveData.add_best_time(d, 1000.0))
	assert_false(SaveData.add_best_time(d, 1100.0))
	assert_true(SaveData.add_best_time(d, 950.0))
	for i in 6:
		SaveData.add_best_time(d, 2000.0 + i)
	assert_eq(d.best_times.size(), SaveData.MAX_BEST_TIMES)
	assert_eq(d.best_times[0], 950.0)


func test_moves_are_discovered_once() -> void:
	var d := SaveData.defaults()
	assert_true(SaveData.discover_move(d, "spin"))
	assert_false(SaveData.discover_move(d, "spin"))


func test_format_time() -> void:
	assert_eq(SaveData.format_time(905.4), "15:05")


func test_player_text_has_no_dash_and_keeps_placeholders() -> void:
	var table: TextTable = load("res://data/text_pt.tres")
	for key: String in table.entries:
		assert_false((table.entries[key] as String).contains("—"), key)
		assert_false((table.entries[key] as String).contains("–"), key)
	assert_eq(table.text(&"PALADIN_1"), "PALADIN_1")


func test_the_game_opens_in_full_screen() -> void:
	assert_true(SaveData.defaults().options.fullscreen, "full screen by default")
	# an older file kept the old windowed default: it switches once
	var old := SaveData.merged({"version": 1, "options": {"fullscreen": false}})
	assert_true(old.options.fullscreen)
	# from version 2 on, a player who picked a window keeps it
	var chosen := SaveData.merged({"version": 2, "options": {"fullscreen": false}})
	assert_false(chosen.options.fullscreen)
