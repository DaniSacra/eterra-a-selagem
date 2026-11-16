extends GutTest
## The Warrior's Mastery (MasteryCurve; guardian_spec.md 7, warrior_spec.md 4.4): 20 levels, 40 + 10 (n - 1) XP from n
## to n + 1, XP by source and first times, the retroactive XP of older saves (once, up to level 5).

var curve: MasteryCurve


func before_all() -> void:
	curve = HeroDef.warrior().mastery


func test_the_curve() -> void:
	assert_eq(curve.max_level, 20)
	assert_eq(curve.needed(1), 40)
	assert_eq(curve.needed(2), 50)
	assert_eq(curve.needed(19), 220)
	assert_eq(curve.needed(20), 0, "nothing past the top")
	for n in range(1, 20):
		assert_eq(curve.needed(n), 40 + 10 * (n - 1))
	assert_eq(curve.total_to(1), 0)
	assert_eq(curve.total_to(2), 40)
	assert_eq(curve.total_to(20), 2470, "2470 from 1 to 20")


func test_level_by_xp() -> void:
	assert_eq(curve.level_of(0), 1)
	assert_eq(curve.level_of(39), 1)
	assert_eq(curve.level_of(40), 2)
	assert_eq(curve.level_of(89), 2)
	assert_eq(curve.level_of(90), 3)
	assert_eq(curve.level_of(2469), 19)
	assert_eq(curve.level_of(2470), 20)
	assert_eq(curve.level_of(99999), 20, "never past the top")
	assert_eq(curve.progress(100), Vector2i(10, 60), "10 into level 3, which needs 60")
	for xp in [0, 1, 40, 333, 1234, 2470]:
		var n := curve.level_of(xp)
		assert_true(xp >= curve.total_to(n) and (n == 20 or xp < curve.total_to(n + 1)), "level %d holds %d" % [n, xp])


func test_devotion_is_five_plus_the_level() -> void:
	assert_eq(curve.devotion(1), 6)
	assert_eq(curve.devotion(20), 25)


func test_xp_by_source() -> void:
	var nothing := curve.run_xp({})
	assert_eq(nothing.total, 0)
	# a death in room 5 of the short descent: 3 fights won, the guardian not yet
	var died := curve.run_xp({"rooms": 3})
	assert_eq(died.total, 30)
	# Morvath reached and lost in phase 3, after 4 fights and the guardian
	var lost := curve.run_xp({"rooms": 4, "guardians": 1, "phase": 3})
	assert_eq(lost.rooms, 40)
	assert_eq(lost.guardians, 25)
	assert_eq(lost.phases, 30)
	assert_eq(lost.total, 95)
	# the phases count up to 4
	assert_eq(curve.run_xp({"phase": 9}).phases, 40)
	var won := curve.run_xp({"rooms": 4, "guardians": 1, "phase": 4, "victory": true})
	assert_eq(won.victory, 50)
	assert_eq(won.total, 40 + 25 + 40 + 50)


func test_first_times() -> void:
	var first := curve.run_xp({"new_boons": 6, "new_elos": 1, "new_psalms": 1, "first_guardian": true, "first_victory": true})
	assert_eq(first.first_boons, 12)
	assert_eq(first.first_elos, 10)
	assert_eq(first.first_psalms, 25)
	assert_eq(first.first_guardian, 25)
	assert_eq(first.first_victory, 100)
	assert_eq(first.total, 12 + 10 + 25 + 25 + 100)


func test_retroactive_xp_once_and_never_past_level_5() -> void:
	assert_eq(curve.retro_xp(0, 0), 0)
	assert_eq(curve.retro_xp(1, 0), 40)
	assert_eq(curve.retro_xp(2, 1), 140)
	assert_eq(curve.retro_xp(100, 50), curve.total_to(5))
	assert_eq(curve.level_of(curve.retro_xp(100, 50)), 5)
	assert_eq(curve.retro_xp(-3, -1), 0)


func test_a_death_keeps_the_xp() -> void:
	# the run's XP is added the same on any outcome (Game.award_mastery); only the victory's own source needs a win
	var death := curve.run_xp({"rooms": 2, "victory": false})
	assert_eq(death.total, 20)
	var data := SaveData.defaults()
	data.heroes.warrior.mastery_xp = 35
	data.heroes.warrior.mastery_xp += death.total
	assert_eq(curve.level_of(SaveData.merged(JSON.parse_string(JSON.stringify(data))).heroes.warrior.mastery_xp), 2, "saved and read back")
