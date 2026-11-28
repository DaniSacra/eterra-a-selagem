extends GutTest
## PT-25-4 and PT-25-11, the combo's short step (combat review of 2026-11-26): it fades by its own decay (6, the finisher's
## 0.8 m peaks at 4.8 m/s, under the run), the same meters as before, the special's and the Brado's wind-up cut what is left
## of it, it never ends in an armed floor trap, and a body in the way stops it.

const F := 1.0 / 60.0

var game: Game
var pad: Controls.VirtualPad


func after_each() -> void:
	Controls.virtual = null
	Controls.flush()


func _run() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.equip_talents([] as Array[StringName])
	pad = Controls.VirtualPad.new()
	Controls.virtual = pad
	game.player.state = Player.State.MOVE
	game.player.invuln = 0.0
	game.player.runner.reset()


func _node(id: StringName) -> ComboNode:
	for path in ["res://data/combos/paladin_fifth.tres", "res://data/combos/paladin.tres"]:
		for n: ComboNode in (load(path) as ComboTree).all_nodes():
			if n.id == id:
				return n
	return null


## Lands the blow `id` as the runner would (the step starts), then lets the paladin stand 1 s; returns [meters, peak m/s].
func _land(id: StringName) -> Array[float]:
	var p := game.player
	var from := p.pos
	p.facing = Vector2.RIGHT
	p.runner.reset()
	p._step_in(_node(id))
	var peak := 0.0
	for i in 60:
		var before := p.pos
		p.step(F, Vector2.ZERO, Vector2.RIGHT)
		peak = maxf(peak, before.distance_to(p.pos) / F)
	return [from.distance_to(p.pos), peak]


func test_the_numbers() -> void:
	assert_eq(StepRules.DECAY, 4.5)
	assert_almost_eq(StepRules.speed(1.4), 6.3, 0.001, "the finisher's peak is under the run's 6.75 m/s")
	assert_lt(StepRules.speed(1.4), Feel.live().speed)
	assert_eq(StepRules.fade(Vector2(4.8, 0), 1.0), Vector2.ZERO, "never reverses")


func test_the_step_steers_toward_an_enemy_ahead() -> void:
	var o := Vector2.ZERO
	assert_eq(StepRules.steer(o, Vector2.RIGHT, Vector2.INF), Vector2.RIGHT, "nobody: straight")
	var d := StepRules.steer(o, Vector2.RIGHT, Vector2(2.0, 1.0))
	assert_almost_eq(d.angle(), Vector2(2, 1).angle(), 0.001, "within the cone: toward it")
	assert_eq(StepRules.steer(o, Vector2.RIGHT, Vector2(1.0, 3.0)), Vector2.RIGHT, "outside the cone")
	assert_eq(StepRules.steer(o, Vector2.RIGHT, Vector2(6.0, 0.0)), Vector2.RIGHT, "too far")


func test_a_fleeing_enemy_off_the_line_pulls_the_step() -> void:
	_run()
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(2.5, 1.5), false)
	e.cooldown = 99.0
	game.horde.rehash()
	game.player.pos = Vector2.ZERO
	game.player.facing = Vector2.RIGHT
	game.player.runner.reset()
	game.player._step_in(_node(&"cut3"))
	assert_gt(game.player._step.y, 0.5, "it bends toward the enemy")


func test_a_trap_under_the_end_stops_the_step_but_not_one_already_in_it() -> void:
	var slab: Array[Rect2] = [Rect2(1.0, -1.0, 2.0, 2.0)]
	assert_true(StepRules.into_trap(Vector2(0.4, 0), Vector2.RIGHT, 0.8, slab, 0.5))
	assert_false(StepRules.into_trap(Vector2(-3.0, 0), Vector2.RIGHT, 0.8, slab, 0.5), "far from it")
	assert_false(StepRules.into_trap(Vector2(1.5, 0), Vector2.RIGHT, 0.8, slab, 0.5), "already on it")
	assert_false(StepRules.into_trap(Vector2(0.4, 0), Vector2.LEFT, 0.8, slab, 0.5), "away from it")


func test_every_blow_of_the_combo_covers_its_meters_below_the_run() -> void:
	_run()
	for id: StringName in [&"cut1", &"cut2", &"cut3", &"cut4", &"thrust4"]:
		var node := _node(id)
		if node == null or node.step <= 0.0:
			continue
		game.player.pos = Vector2.ZERO
		var r := _land(id)
		assert_almost_eq(r[0], node.step, 0.15, "%s: the same meters" % id)
		assert_lt(r[1], 6.75, "%s: under the run" % id)
	assert_not_null(_node(&"cut4"))
	assert_not_null(_node(&"thrust4"))


func test_the_special_and_the_shout_cut_the_slide() -> void:
	_run()
	var p := game.player
	for input: ComboNode.In in [ComboNode.In.HEAVY, ComboNode.In.SHOUT, ComboNode.In.RUSH]:
		p._step = Vector2(4.8, 0)
		var n := ComboNode.new()
		n.input = input
		p._on_move_started(n)
		assert_eq(p._step, Vector2.ZERO, "input %d starts from a standstill" % input)
	p._step = Vector2(4.8, 0)
	var light := ComboNode.new()
	light.input = ComboNode.In.LIGHT
	p._on_move_started(light)
	assert_ne(p._step, Vector2.ZERO, "the next blow of the combo keeps the tail (it adds)")


func test_a_body_stops_the_step() -> void:
	_run()
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(1.2, 0), false)
	e.cooldown = 99.0
	game.player.pos = Vector2.ZERO
	game.horde.rehash()
	var r := _land(&"cut3")
	assert_lt(game.player.pos.x, e.pos.x - 0.5, "he stops at its edge instead of walking through it")
	assert_lt(r[0], 0.8)
