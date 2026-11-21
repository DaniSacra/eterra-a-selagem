extends GutTest
## C20 (GP P2-3): the run pauses by itself when the window loses its focus or the controller in use is unplugged;
## never for the robot nor a smoke or capture run, and only in play (AutoPause, Game.auto_pause).

var _was_pad := false


func before_each() -> void:
	_was_pad = Controls.using_pad


func after_each() -> void:
	Controls.using_pad = _was_pad
	Dev.drop("no-auto-pause")


func test_the_rule() -> void:
	assert_true(AutoPause.wanted(AutoPause.Why.FOCUS, true, false), "focus lost in play pauses")
	assert_false(AutoPause.wanted(AutoPause.Why.FOCUS, false, false), "not outside of play")
	assert_false(AutoPause.wanted(AutoPause.Why.FOCUS, true, true), "never the robot")
	assert_true(AutoPause.wanted(AutoPause.Why.PAD, true, false, true), "the pad he plays with, unplugged")
	assert_false(AutoPause.wanted(AutoPause.Why.PAD, true, false, false), "a pad he does not use: nothing")
	assert_true(AutoPause.robot_run(true))
	Dev.put("no-auto-pause")
	assert_true(AutoPause.robot_run(false), "--no-auto-pause")


func _game() -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	return game


func test_focus_lost_in_play_opens_the_pause() -> void:
	var game := _game()
	assert_eq(game.mode, Game.Mode.PLAY)
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert_eq(game.mode, Game.Mode.PAUSE, "the pause opens")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert_eq(game.mode, Game.Mode.PAUSE, "once")


func test_the_unplugged_pad_pauses_only_when_in_use() -> void:
	var game := _game()
	Controls.using_pad = false
	game._on_pad_connection(0, false)
	assert_eq(game.mode, Game.Mode.PLAY, "playing on the keyboard: nothing")
	game._on_pad_connection(0, true)
	assert_eq(game.mode, Game.Mode.PLAY, "a pad plugged in: nothing")
	Controls.using_pad = true
	game._on_pad_connection(0, false)
	assert_eq(game.mode, Game.Mode.PAUSE, "his pad unplugged: the pause opens")


func test_never_for_the_robot() -> void:
	var game := _game()
	game.bot = Bot.new()
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert_eq(game.mode, Game.Mode.PLAY, "the robot plays on")
	game.bot = null
