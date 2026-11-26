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
	# never the Escudo: its shield would take the blow below (the offer depends on the pool, which grows with new Blessings)
	# (GP-2: a fixed offensive Blessing; the pool of 9 angels can offer one whose guard takes the blow below)
	var b: Boon = game.boons.find(&"golpe_peste")
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


# ---------- version 3 (DT-015, E2a): the hero, the Mastery, the Gifts ----------

func test_version_2_lines_are_still_read() -> void:
	var back := RunLog.read("res://tests/fixtures/runs_v2.jsonl")
	assert_eq(back.size(), 2)
	var old := back[0]
	assert_eq(int(old.version), 2, "an older line keeps its version")
	assert_eq(old.outcome, "death")
	assert_eq(old.defeated_by, "enemy_mage")
	assert_eq(old.hero, "warrior", "every older run was the first hero's")
	assert_eq(old.xp, 0)
	assert_eq(old.talents, [])
	assert_eq(old.ultimate, "")
	for k in RunLog.FIELDS:
		assert_true(old.has(k), "a version 2 line reads with %s" % k)
	var now := back[1]
	assert_eq(int(now.version), 3)
	assert_eq(float(now.xp), 175.0, "a version 3 line is read as written")
	assert_eq(now.map, {}, "a line before the graph reads with an empty map (version 4)")
	for r: Dictionary in now.get("rooms", []):
		assert_eq(int(r.node), -1)
	assert_eq(now.talents, ["quarto_corte"])


func test_a_run_logs_the_hero_its_mastery_and_gifts() -> void:
	_start(RunMap.Kind.FOUNTAIN)
	var heard: Array = []
	game.run_logged.connect(func(_o: String, e: Dictionary) -> void: heard.append(e))
	game.talents.assign([&"quarto_corte"])
	game.ultimate = "cleave"
	game.rooms.won.assign([RunMap.Kind.COMBAT, RunMap.Kind.COMBAT, RunMap.Kind.MINIBOSS])
	game.log_run("quit")
	var e: Dictionary = heard[0]
	assert_eq(int(e.version), RunLog.VERSION)
	assert_eq(int(e.map.seed), game.rooms.map.map_seed, "the log carries the graph (version 4)")
	assert_false((e.map.edges as Array).is_empty())
	assert_eq(e.hero, "warrior")
	assert_eq(e.talents, ["quarto_corte"])
	assert_eq(e.ultimate, "cleave")
	var curve := HeroDef.warrior().mastery
	assert_eq(e.xp_by.rooms, 2 * curve.room_xp)
	assert_eq(e.xp_by.guardians, curve.guardian_xp)
	assert_false(e.xp_by.has("total"), "the total is xp")
	assert_eq(e.xp, int(game.mastery_gain("quit", Save.data).total))
	assert_gte(e.mastery_level, 1)


func test_the_mastery_of_a_run_goes_into_the_save_data_and_a_death_keeps_it() -> void:
	_start(RunMap.Kind.FOUNTAIN)
	var data := SaveData.defaults()
	var curve := HeroDef.warrior().mastery
	game.rooms.won.assign([RunMap.Kind.COMBAT, RunMap.Kind.COMBAT, RunMap.Kind.COMBAT, RunMap.Kind.MINIBOSS])
	game.boss_stats = {"max_phase": 3}
	game.seen_boons = {&"brasas": true, &"vapor": true}
	game.elos_formed = {&"vapor": true}
	var gain := game.mastery_gain("death", data)
	assert_eq(gain.rooms, 3 * curve.room_xp)
	assert_eq(gain.guardians, curve.guardian_xp)
	assert_eq(gain.phases, 3 * curve.phase_xp)
	assert_eq(gain.victory, 0, "a death is no victory")
	assert_eq(gain.first_boons, 2 * curve.first_boon_xp)
	assert_eq(gain.first_elos, curve.first_elo_xp)
	assert_eq(gain.first_guardian, curve.first_guardian_xp)
	assert_eq(gain.first_victory, 0)
	game.award_mastery(gain, "death", data)
	assert_eq(data.heroes.warrior.mastery_xp, gain.total, "a death keeps the XP")
	assert_true((data.heroes.warrior.unlocked as Array).has("disciplina"))
	assert_eq(data.codex.boons.brasas.seen, 1)
	assert_eq(data.codex.elos.vapor.formed, 1)
	assert_eq(int(data.heroes.warrior.firsts.guardian), 1)
	# the same run again: the first times are gone, the rest counts again
	var again := game.mastery_gain("victory", data)
	assert_eq(again.first_boons, 0)
	assert_eq(again.first_elos, 0)
	assert_eq(again.first_guardian, 0)
	assert_eq(again.victory, curve.victory_xp)
	assert_eq(again.first_victory, curve.first_victory_xp)
	game.award_mastery(again, "victory", data)
	assert_eq(data.heroes.warrior.mastery_xp, gain.total + again.total)
	assert_eq(game.mastery_gain("victory", data).first_victory, 0, "one first victory")


func test_without_a_save_nothing_is_awarded() -> void:
	_start(RunMap.Kind.FOUNTAIN)
	var before := JSON.stringify(Save.data)
	game.rooms.won.assign([RunMap.Kind.COMBAT])
	game.log_run("death")
	assert_eq(JSON.stringify(Save.data), before, "the tests (as --nosave) never touch the save data")


func test_a_quit_with_no_room_won_and_under_ten_seconds_is_not_kept() -> void:
	assert_false(RunLog.worth_keeping("quit", 0, 3.0))
	assert_true(RunLog.worth_keeping("quit", 1, 3.0), "a room was won")
	assert_true(RunLog.worth_keeping("quit", 0, 10.0), "ten seconds in")
	assert_true(RunLog.worth_keeping("death", 0, 2.0), "a death always counts")
	assert_true(RunLog.worth_keeping("victory", 0, 2.0))


# ---------- version 8 (BL-11, CF-08, RD-04): cause, oaths, hazard blows by room ----------

func test_version_7_lines_read_with_the_version_8_fields() -> void:
	var old := RunLog.normalized({"version": 7, "outcome": "death", "rooms": [{"depth": 1, "hp_in": 40.0}]})
	assert_eq(old.cause, "")
	assert_eq(old.oaths, {})
	assert_eq(int(old.courage), 0)
	assert_eq(int(old.version), 7, "keeps its own version")
	assert_eq(RunLog.hp_enter(old.rooms[0]), 40.0, "hp_enter reads hp_in")


func test_entries_count_the_hazards_blows_on_him_and_on_the_enemies() -> void:
	var room := {"depth": 4, "hp_in": 30.0, "hits_by": {"runes": 2, "skeleton": 3, "plates": 1},
		"hazard": {"kind": "runes", "strikes": 5, "also": {"strikes": 2}, "more": [{"strikes": 1}]}}
	var result := {"rooms": [room]}
	var e := RunLog.entry(result, {"cause": "runes"})
	var r: Dictionary = e.rooms[0]
	assert_eq(int(r.hazard_hits_hero), 3, "runes and plates, not the skeleton")
	assert_eq(int(r.hazard_hits_enemy), 8)
	assert_eq(float(r.hp_enter), 30.0)
	assert_false(result.rooms[0].has("hazard_hits_hero"), "the RESULT is not touched")
	assert_eq(e.cause, "runes")


func test_a_run_that_ends_in_death_logs_its_cause_and_oaths() -> void:
	_start(RunMap.Kind.FOUNTAIN)
	game.last_hurt = DefeatCause.of(&"scythe", &"")
	var e := game.run_entry("death", {"total": 0})
	assert_eq(e.cause, "scythe")
	assert_true(e.has("oaths"))
	assert_eq(game.run_entry("victory", {"total": 0}).cause, "", "only a death has a cause")
