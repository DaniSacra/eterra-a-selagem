extends GutTest
## The RESULT step_ms_avg and step_ms_peak: measured only while enemies stand (BUG-012).


func test_frames_without_enemies_are_left_out() -> void:
	var t := StepTimer.new()
	t.add(9.0, false)
	t.add(1.0, true)
	t.add(3.0, true)
	t.add(20.0, false)
	assert_eq(t.frames, 2)
	assert_almost_eq(t.average(), 2.0, 0.0001)
	assert_almost_eq(t.peak, 3.0, 0.0001)


func test_nothing_measured_reads_zero() -> void:
	var t := StepTimer.new()
	t.add(5.0, false)
	assert_eq(t.frames, 0)
	assert_eq(t.average(), 0.0)
	assert_eq(t.peak, 0.0)


func test_the_run_reports_the_step_while_enemies_stand() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	for i in 30:
		game.player.invuln = 10.0
		game._timed_step(1.0 / 60.0)
	assert_gt(game.horde.count(), 0, "Morvath stands")
	assert_eq(game.step_timer.frames, 30)
	var r := game.result()
	assert_true(r.has("step_ms"), "the old key stays for the tools")
	assert_gt(float(r.step_ms_avg), 0.0)
	assert_gte(float(r.step_ms_peak), float(r.step_ms_avg))
