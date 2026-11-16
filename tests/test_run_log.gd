extends GutTest
## The log of each run (QW-001 of cycle 10): one JSON line per run with the RESULT, the gifts, the device, Omegas,
## dodges and what hurt the paladin last; "Derrotado por" names it (QW-003); a run without a save keeps no record
## (BUG-008).

const PATH := "user://test_runs.jsonl"

var game: Game


func before_each() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


func after_all() -> void:
	before_each()


func test_the_tests_never_write_this_machines_save_or_log() -> void:
	assert_false(Save.enabled, "the GUT pre-run hook turns the save off")


func test_entries_are_one_json_line_each_and_read_back() -> void:
	var result := {"time": 81.5, "hp": 0, "room": 3, "boss": {"ritual": 12.3}}
	for outcome in RunLog.OUTCOMES:
		var e := RunLog.entry(result, {"outcome": outcome, "omegas": 2})
		assert_false(RunLog.line(e).contains("\n"), "one line")
		assert_eq(RunLog.append(PATH, e), OK)
	var back := RunLog.read(PATH)
	assert_eq(back.size(), 3)
	assert_eq(back[1].outcome, "death")
	assert_eq(float(back[2].time), 81.5)
	assert_eq(float(back[0].boss.ritual), 12.3, "the RESULT goes in whole")
	assert_eq(int(back[0].version), RunLog.VERSION)
	assert_eq(result.has("outcome"), false, "the result itself is not changed")


func test_a_damaged_line_is_skipped() -> void:
	RunLog.append(PATH, {"outcome": "quit"})
	var f := FileAccess.open(PATH, FileAccess.READ_WRITE)
	f.seek_end()
	f.store_line("{not json")
	f = null
	RunLog.append(PATH, {"outcome": "victory"})
	assert_eq(RunLog.read(PATH).size(), 2)


func test_the_device_is_named() -> void:
	assert_eq(RunLog.device(true, false), "keyboard")
	assert_eq(RunLog.device(false, true), "gamepad")
	assert_eq(RunLog.device(true, true), "both")
	assert_eq(RunLog.device(false, false), "none")


func test_a_cause_is_named_by_the_attack_else_the_kind() -> void:
	assert_eq(DefeatCause.text_key(DefeatCause.of(&"storm", &"")), &"killer_storm")
	assert_eq(DefeatCause.text_key(DefeatCause.of(&"adds", &"mage"), &"enemy_mage"), &"enemy_mage", "his dead by their kind")
	assert_eq(DefeatCause.text_key(DefeatCause.of(null, &"skeleton"), &"enemy_skeleton"), &"enemy_skeleton")
	assert_eq(DefeatCause.text_key(DefeatCause.of(null, null)), DefeatCause.UNKNOWN)
	for id in DefeatCause.BOSS_ATTACKS:
		var key := DefeatCause.text_key(DefeatCause.of(id, &""))
		assert_ne(T.t(key), String(key), "%s has its text" % key)
	assert_ne(T.t(DefeatCause.UNKNOWN), String(DefeatCause.UNKNOWN))
	assert_true(T.t(&"defeated_by", {"name": "X"}).contains("X"))


func _start(kind: RunMap.Kind = RunMap.Kind.BOSS) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(kind)


func test_a_real_run_counts_and_names_what_hurt_last() -> void:
	_start()
	var heard: Array = []
	game.run_logged.connect(func(outcome: String, e: Dictionary) -> void: heard.append([outcome, e]))
	var b: Boon = game.boons.offers(RandomNumberGenerator.new(), 1)[0]
	game._take(b)
	game.player.dodged.emit(Vector2.RIGHT)
	game.player.cast_released.emit(game.player.pos, true)
	game.player.cast_released.emit(game.player.pos, false)
	# a blow of one of his dead (a skeleton, its own swing)
	game.horde.last_by = &"skeleton"
	game.player.invuln = 0.0
	game._on_hit_player(3.0, Vector2.ZERO, game.horde)
	assert_eq(game.defeated_by(), &"enemy_skeleton")
	# a warning of his scythe
	game.ground.last_source = &"scythe"
	game.ground.last_by = &""
	game.player.invuln = 0.0
	game._on_hit_player(3.0, Vector2.ZERO, game.ground)
	assert_eq(game.defeated_by(), &"killer_scythe")
	assert_eq(T.t(game.defeated_by()), "Foice Sepulcral")
	game.player.invuln = 0.0
	game.player.hurt(9999.0, Vector2.ZERO)
	assert_eq(heard.size(), 1, "logged once, as it ends")
	assert_eq(heard[0][0], "death")
	var e: Dictionary = heard[0][1]
	for k in RunLog.FIELDS:
		assert_true(e.has(k), "the entry has %s" % k)
	for k in game.result():
		assert_true(e.has(k), "the entry has the RESULT's %s" % k)
	assert_eq(e.gifts[0].id, String(b.id))
	assert_eq(e.omegas, 1)
	assert_eq(e.dodges, 1)
	assert_eq(e.defeated_by, "killer_scythe")
	assert_eq(e.last_hurt.attack, "scythe")
	assert_false(FileAccess.file_exists(RunLog.PATH) and RunLog.read(RunLog.PATH).any(func(x: Dictionary) -> bool: return x.get("when") == e.when and x.get("time") == e.time), "nothing written with the save off")
	game.log_run("quit")
	assert_eq(heard.size(), 1, "never twice")


func test_a_warning_or_shot_carries_the_kind_that_laid_it() -> void:
	_start(RunMap.Kind.FOUNTAIN)
	game.horde.acting = &"mage"
	var z := game.ground.add_warning(Vector2.ZERO, 2.0, 1.0, 3.0)
	var s := game.projectiles.fire(Projectiles.Kind.BOLT, Vector2.ZERO, Vector2.RIGHT, 5.0, 3.0)
	game.horde.acting = &""
	var mine := game.ground.add_warning(Vector2.ZERO, 2.0, 1.0, 3.0)
	assert_eq(z.by, &"mage")
	assert_eq(s.by, &"mage")
	assert_eq(mine.by, &"", "outside the crowd's step: nobody's")


func test_no_new_best_time_without_a_save() -> void:
	var data := SaveData.defaults()
	assert_false(SaveData.record_win_time(data, 100.0, false), "no save: no record")
	assert_true((data.best_times as Array).is_empty(), "nothing kept")
	assert_true(SaveData.record_win_time(data, 100.0, true))
	assert_false(SaveData.record_win_time(data, 120.0, true), "slower")
