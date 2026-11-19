extends GutTest
## The Runas Instáveis are heard (docs/design/combat_cadence.md 7, P1): one sound as a pattern arms and one crack as it
## strikes, however many tiles it lights; nothing while the floor rests or once the fight is over; under Morvath's
## warnings (no ducking).

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0

var _frame := 0


func _runes() -> RoomLayout:
	var stage: StageDef = load(STAGE)
	for l in stage.layouts:
		if l.id == &"runes":
			return l
	return null


func _count(sound: StringName) -> int:
	return Audio.heard.filter(func(h: Array) -> bool: return h[0] == sound).size()


func after_each() -> void:
	Audio.listen(false)


func test_the_events_have_recipes_and_never_duck() -> void:
	for e: StringName in [&"rune_arm", &"rune_fire"]:
		assert_true(CombatSounds.EVENTS.has(e), String(e))
		var sound: StringName = CombatSounds.EVENTS[e]
		assert_true(Audio.SOUNDS.has(sound), "%s has a recipe" % sound)
		assert_false(Audio.WARN_CUES.has(sound), "%s does not duck the music like Morvath's warnings" % sound)
	assert_ne(CombatSounds.EVENTS[&"rune_arm"], CombatSounds.EVENTS[&"rune_fire"], "arming and striking sound apart")


func test_one_sound_per_arming_and_one_per_strike_nothing_at_rest() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rebuild_room(_runes(), 2, 1406)
	game.horde.clear_crowd()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var rf := RuneFloor.new(game, _runes().hazard, rng)
	game.player.place(Vector2(100, 100))  # off the floor's tiles: nothing may come near him
	_frame = 0
	Audio.listen(true, func() -> int: return _frame * 1000 / 60)
	var armed := 0
	var fired := 0
	var most_rects := 0
	var calm_heard := -1
	for i in 60 * 14:
		_frame = i
		var before := rf.hazard.phase
		rf.step(DT)
		var after := rf.hazard.phase
		if after != before and after == ArenaHazard.Phase.ARM:
			armed += 1
			most_rects = maxi(most_rects, rf.hazard.rects().size())
		elif after != before and after == ArenaHazard.Phase.FIRE:
			fired += 1
		if i == 60 * 3 - 5:
			calm_heard = Audio.heard.size()
	assert_eq(calm_heard, 0, "nothing in the first 3 s of calm")
	assert_gt(armed, 2, "several patterns in 14 s")
	assert_gt(most_rects, 1, "a pattern lights more than one run of tiles")
	assert_eq(_count(&"rune_arm"), armed, "one sound per arming, not per tile")
	assert_eq(_count(&"rune_crack"), fired, "one crack per strike")
	# the fight is over: the floor stops and stays silent
	rf.stop()
	var n := Audio.heard.size()
	for i in 60 * 5:
		_frame += 1
	assert_eq(Audio.heard.size(), n, "nothing once the floor stopped")


func test_a_fight_in_the_runes_is_heard_and_falls_silent_when_won() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 6, game.rooms.stage.layouts.find(_runes()), 0)
	game.rooms._enter(r)
	_frame = 0
	Audio.listen(true, func() -> int: return _frame * 1000 / 60)
	for i in 60 * 5:
		_frame = i
		game.rooms.step(DT)
		game.ground.step(DT)
	assert_gte(_count(&"rune_arm"), 1, "the floor armed within 5 s and was heard")
	game.rooms._room_cleared()
	var n := _count(&"rune_arm") + _count(&"rune_crack")
	for i in 60 * 6:
		_frame += 1
		game.rooms.step(DT)
		game.ground.step(DT)
	assert_eq(_count(&"rune_arm") + _count(&"rune_crack"), n, "a won room's floor is silent")
