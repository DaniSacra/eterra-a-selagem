extends GutTest
## C17, BUG-110: --watchdog samples the run every 5 real seconds (frames, frames a second, mode, the world's rate,
## Engine.time_scale, the clock), for the console and the run's log.


func test_a_sample_every_five_real_seconds() -> void:
	var w := Watchdog.new()
	assert_true(w.tick(10.0, 600, "PLAY", 1.0, 1.0, 2.0).is_empty(), "the first call only starts the watch")
	assert_true(w.tick(14.9, 900, "PLAY", 1.0, 1.0, 6.9).is_empty())
	var s := w.tick(15.0, 900, "PLAY", 0.06, 0.06, 7.0)
	assert_eq(s.frames, 900)
	assert_almost_eq(float(s.fps), 60.0, 0.01, "300 frames in 5 s")
	assert_eq(s.mode, "PLAY")
	assert_almost_eq(float(s.rate), 0.06, 0.0001)
	assert_almost_eq(float(s.time), 7.0, 0.001)
	assert_true(Watchdog.line(s).begins_with("WATCH {"))
	# frames standing still: the engine or the system, not the game
	var still := w.tick(20.0, 900, "PLAY", 1.0, 1.0, 7.0)
	assert_eq(float(still.fps), 0.0)
	assert_eq(w.samples.size(), 2, "kept for the log")


func test_the_run_log_keeps_the_watch() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.watchdog = Watchdog.new()
	game.watchdog.tick(0.0, 0, "PLAY", 1.0, 1.0, 0.0)
	game.watchdog.tick(5.0, 300, "PLAY", 1.0, 1.0, 5.0)
	var e := game.run_entry("quit", {})
	assert_eq((e.watch as Array).size(), 1)
	game.watchdog = null
	assert_false(game.run_entry("quit", {}).has("watch"), "nothing without --watchdog")
