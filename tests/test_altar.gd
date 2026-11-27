extends GutTest
## The Altar Esquecido (E5): a door once per descent within its depths, two trades (life for a pomegranate, gold for
## Magia) or none, the robot's rule, and the trade in a real room with its log.

const STAGE := "res://data/stages/catacombs.tres"

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func test_the_options_ask_and_give() -> void:
	var o := Altar.options(stage, 100, 30, true)
	assert_eq(o.size(), 2)
	assert_eq(o[Altar.Option.LIFE].cost, stage.altar_life_cost)
	assert_true(o[Altar.Option.LIFE].ok)
	assert_true(o[Altar.Option.CANDLES].ok)
	assert_eq(o[Altar.Option.CANDLES].gain, stage.altar_magick)
	var poor := Altar.options(stage, stage.altar_gold_cost - 1, 19, false)
	assert_false(poor[Altar.Option.LIFE].ok, "nothing to grow")
	assert_false(poor[Altar.Option.CANDLES].ok, "not enough gold")
	assert_false(Altar.options(stage, 0, Altar.MIN_LIFE + stage.altar_life_cost - 1, true)[Altar.Option.LIFE].ok,
		"too little life left")
	for id in Altar.IDS:
		assert_ne(T.t(StringName("altar_" + String(id))), "altar_" + String(id), "%s has its text" % id)


func test_the_robot_chooses() -> void:
	assert_eq(Altar.bot_choice(Altar.options(stage, 0, 50, true), 50), Altar.Option.LIFE)
	assert_eq(Altar.bot_choice(Altar.options(stage, 125, 40, true), 40, 125), Altar.Option.CANDLES, "40 - 10 < 35; 125 - 75 keeps 50 for the shop")
	assert_eq(Altar.bot_choice(Altar.options(stage, 0, 40, true), 40), -1)


## DV-1: at most one altar in the graph, within its depths.
func test_once_per_descent_within_its_depths() -> void:
	var runs_with := 0
	for run in 400:
		var map := RunMap.new(stage, 300 + run)
		var altars := map.nodes.filter(func(r: RunMap.Room) -> bool: return r.kind == RunMap.Kind.ALTAR)
		assert_lte(altars.size(), 1)
		for o: RunMap.Room in altars:
			assert_between(o.depth, stage.altar_depth_min, stage.altar_depth_max)
		if not altars.is_empty():
			runs_with += 1
	assert_gt(runs_with, 120, "the altar comes up (%d of 400)" % runs_with)


func test_the_trade_in_a_real_room() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var rooms := game.rooms
	rooms.map.depth = 3
	rooms._enter(RunMap.Room.new(RunMap.Kind.ALTAR, RunMap.Reward.NONE, 4, -1))
	assert_eq(game.arena.layout.id, &"altar")
	assert_eq(rooms.phase, Rooms.Phase.OPEN, "no fight: its doors open at once")
	assert_eq(rooms.altar_options.size(), 2)
	rooms.gold = 100
	var magick := game.player.magick.max_value
	watch_signals(rooms)
	assert_true(rooms.take_altar(Altar.Option.CANDLES))
	assert_eq(rooms.gold, 100 - stage.altar_gold_cost)
	assert_almost_eq(game.player.magick.max_value, magick + stage.altar_magick, 0.01)
	assert_signal_emitted_with_parameters(rooms, "altar_used", [&"candles"])
	assert_false(rooms.take_altar(Altar.Option.LIFE), "only one trade")
	var e: Dictionary = game.room_tally.events.back()
	assert_eq(e.type, "altar")
	assert_eq(e.choice, "candles")
