extends GutTest
## PT-1 (Daniel, 2026-11-23): melee blows and shots lay no mark on the floor, only areas do; the "!" over the enemy lights
## in the last Feel.bang_lead seconds before a blow and goes with it (landed or cut).

var game: Game


func _alone(id: StringName, gap := 2.2) -> Enemy:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(game.player.pos + Vector2(gap, 0), 0.6), false)
	e.cooldown = 0.0
	e.armor = 0.0
	return e


func _step() -> void:
	game.player.invuln = 0.0
	game.player.hp = game.player.max_hp
	game._step(1.0 / 60.0)


func _into(e: Enemy, state: Enemy.State) -> bool:
	for i in 300:
		_step()
		if e.state == state:
			return true
	return false


## The "!" is drawn with ink: the quads of the INK shape on this frame.
func _ink() -> int:
	game.horde.render()
	var n := 0
	for q: Array in game.horde.tells.put():
		n += int(q[0] == EnemyFx.Shape.INK)
	return n


func test_the_data_marks_only_the_areas() -> void:
	for id in [&"runner", &"runner_big", &"runner_elite", &"varredor", &"canalizador"]:
		assert_true((load("res://data/enemies/%s.tres" % id) as EnemyDef).ground_warning, "%s: an area" % id)
	for id in [&"skeleton", &"skeleton_elite", &"archer", &"mage", &"guard", &"knight", &"priest_elder", &"saltador"]:
		assert_false((load("res://data/enemies/%s.tres" % id) as EnemyDef).ground_warning, "%s: no mark" % id)


func test_a_melee_blow_lays_no_mark_on_the_floor() -> void:
	var e := _alone(&"skeleton")
	assert_true(_into(e, Enemy.State.WINDUP))
	var z := e.warning as Ground.Zone
	assert_not_null(z, "its zone still exists (time, damage, what the bot reads)")
	assert_true(z.silent)
	assert_false(z.node.visible, "but nothing is drawn")


func test_an_area_keeps_its_mark() -> void:
	var e := _alone(&"runner", 1.6)
	assert_true(_into(e, Enemy.State.WINDUP))
	var z := (e.warning as Ground.Zone) if e.warning != null else (e.warning2 as Ground.Zone)
	assert_not_null(z)
	assert_false(z.silent)
	assert_true(z.node.visible, "the runner's circle is drawn")


func test_the_bang_lights_in_the_last_instants_and_goes_with_the_blow() -> void:
	var e := _alone(&"skeleton")
	assert_true(_into(e, Enemy.State.WINDUP))
	var lead := Feel.live().bang_lead
	assert_gt(game.horde.strike_in(e), lead, "the wind-up starts further than the lead from its blow")
	assert_eq(_ink(), 0, "not lit at the start of the wind-up")
	var lit := false
	var left_at := -1.0
	for i in 120:
		_step()
		var due := game.horde.strike_in(e)
		if due > 0.0 and due <= lead:
			assert_gt(_ink(), 0, "lit inside the window (%.2f s left)" % due)
			lit = true
			left_at = due
		elif due > lead:
			assert_eq(_ink(), 0, "dark before the window")
		elif lit:
			break
	assert_true(lit, "it lit")
	assert_lte(left_at, lead)
	assert_eq(_ink(), 0, "gone when the blow came")


func test_a_cut_wind_up_takes_the_bang_away() -> void:
	var e := _alone(&"skeleton")
	assert_true(_into(e, Enemy.State.WINDUP))
	while game.horde.strike_in(e) > Feel.live().bang_lead:
		_step()
	assert_gt(_ink(), 0, "lit")
	assert_true(game.horde.interrupt(e))
	assert_lt(game.horde.strike_in(e), 0.0)
	assert_eq(_ink(), 0, "cut: gone")


func test_an_area_blow_has_no_bang() -> void:
	var e := _alone(&"runner", 1.6)
	assert_true(_into(e, Enemy.State.WINDUP))
	for i in 40:
		_step()
		assert_lt(game.horde.strike_in(e), 0.0, "the floor tells it, not the bang")
	assert_eq(_ink(), 0)
