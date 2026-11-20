extends GutTest
## Lote 2B, drawing only (docs/qa/asset_report.md): GF-15 the run's start and stop lean (RunLean) with a 0.1 s mix,
## VX-17 the finisher holding its last pose before easing into the guard, B-b the dash with no mix. The answer to the
## stick and the blows' times are the feel probe's (tools/feel_probe_run.gd), unchanged.

const F := 1.0 / 60.0

var game: Game
var pad: Controls.VirtualPad


func after_each() -> void:
	Controls.virtual = null
	Controls.flush()
	Engine.time_scale = 1.0


func _room() -> Player:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	pad = Controls.VirtualPad.new()
	Controls.virtual = pad
	var p := game.player
	p.state = Player.State.MOVE
	p.invuln = 0.0
	p.runner.reset()
	return p


func _frame(p: Player, taps: Array = []) -> void:
	for a: StringName in taps:
		pad.press(a)
	p.step(F, pad.move, Vector2.UP)
	(p.get(&"_anim") as AnimationPlayer).advance(F)
	pad.end_frame()
	for a: StringName in pad.held.keys():
		pad.release(a)
	pad.released.clear()


func _model(p: Player) -> Node3D:
	return p.get(&"_model") as Node3D


func test_the_lean_is_a_pulse_forward_on_the_start_and_back_on_the_stop() -> void:
	var lean := RunLean.new()
	assert_eq(lean.step(false, F), 0.0, "standing still: nothing")
	var top := 0.0
	var frames := 0
	var a := lean.step(true, F)
	while a > 0.0 or frames == 0:
		top = maxf(top, a)
		a = lean.step(null, F)  # (the dodge and the blows keep it going)
		frames += 1
	assert_almost_eq(top, deg_to_rad(RunLean.START_DEG), 0.01, "leans into the first steps")
	assert_almost_eq(frames * F, RunLean.TIME, 2.0 * F, "and is upright again in TIME")
	var low := 0.0
	for i in 30:
		low = minf(low, lean.step(false, F))
	assert_almost_eq(low, -deg_to_rad(RunLean.STOP_DEG), 0.01, "rocks back on the stop")
	assert_eq(lean.step(false, F), 0.0, "and settles")
	assert_eq(RunLean.shape(0.0), 0.0)
	assert_eq(RunLean.shape(1.0), 0.0)
	assert_almost_eq(RunLean.shape(RunLean.PEAK_AT), 1.0, 0.001)


func test_he_leans_into_the_run_and_back_and_walks_the_same() -> void:
	var p := _room()
	var at := p.pos
	pad.move = Vector2.RIGHT
	var forward := 0.0
	for i in 20:
		_frame(p)
		forward = maxf(forward, _model(p).rotation.x)
	assert_gt(forward, deg_to_rad(RunLean.START_DEG) * 0.9, "leans forward as he sets off")
	assert_gt(p.pos.x - at.x, 20 * F * Feel.live().speed * 0.9, "the legs answer as before, from the first frame")
	pad.move = Vector2.ZERO
	var back := 0.0
	for i in 30:
		_frame(p)
		back = minf(back, _model(p).rotation.x)
	assert_lt(back, -deg_to_rad(RunLean.STOP_DEG) * 0.9, "rocks back as he stops")
	assert_almost_eq(_model(p).rotation.x, 0.0, 0.0001, "upright again")


func test_no_lean_in_a_blow() -> void:
	var p := _room()
	pad.move = Vector2.ZERO
	for i in 40:
		_frame(p)
	pad.move = Vector2.RIGHT
	_frame(p, [&"light_attack"])
	while p.runner.planted():
		assert_almost_eq(_model(p).rotation.x, 0.0, 0.0001, "planted in the blow, upright")
		_frame(p)


func test_the_finisher_holds_its_last_pose_then_eases_into_the_guard() -> void:
	var p := _room()
	pad.move = Vector2.ZERO
	var anim := p.get(&"_anim") as AnimationPlayer
	# the chain to the spin (cut3), each press when the next blow may come
	var spun := false
	for i in 240:
		var taps: Array = [&"light_attack"] if not spun else []
		_frame(p, taps)
		if p.runner.node != null and p.runner.node.tags.has(&"finisher"):
			spun = true
		if spun and not p.runner.is_attacking() and not anim.is_playing():
			break
	assert_true(spun, "the spin came")
	assert_eq(p.get(&"_current_anim"), &"Slash_C", "its clip is done and its pose stays")
	var held := 0
	while p.get(&"_current_anim") == &"Slash_C" and held < 120:
		_frame(p)
		held += 1
	assert_almost_eq(held * F, Player.FINISHER_HOLD, 2.0 * F, "held FINISHER_HOLD, not cut to the guard in a frame")
	assert_eq(p.get(&"_current_anim"), &"Idle", "then the guard")


func test_walking_cuts_the_finisher_hold() -> void:
	var p := _room()
	pad.move = Vector2.ZERO
	var anim := p.get(&"_anim") as AnimationPlayer
	var spun := false
	for i in 240:
		_frame(p, [&"light_attack"] if not spun else [])
		if p.runner.node != null and p.runner.node.tags.has(&"finisher"):
			spun = true
		if spun and not p.runner.is_attacking() and not anim.is_playing():
			break
	pad.move = Vector2.RIGHT
	_frame(p)
	assert_eq(p.get(&"_current_anim"), &"Run", "the stick cuts the held pose on its frame")


func test_the_dash_has_no_mix() -> void:
	var p := _room()
	pad.move = Vector2.RIGHT
	for i in 10:
		_frame(p)
	var anim := p.get(&"_anim") as AnimationPlayer
	_frame(p, [&"dodge"])
	assert_eq(anim.current_animation, &"Dash")
	assert_eq(p.get(&"_current_anim"), &"Dash")
	assert_lt(anim.current_animation_position, 0.1, "from its start")
