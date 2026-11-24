extends GutTest
## Daniel's notes while playing, 2026-11-23 night (docs/backlog.md PT-3, PT-7, PT-8): no hit count, larger angels,
## and the guardians' doors each showing their own angel.

var game: Game


func _run(kind := RunMap.Kind.COMBAT) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(kind)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


func test_the_hit_count_is_never_shown() -> void:
	_run()
	await wait_process_frames(2)
	game.hud.on_combo(12)
	await wait_process_frames(2)
	assert_false(game.hud._combo.visible, "PT-3: no count")
	assert_false(game.hud._combo_word.visible)


func test_the_angels_are_larger_than_before() -> void:
	# the painting is 2:3: its height sets its size (it was 270 in the meeting, 380 in the list)
	assert_gte(BoonChoice.FIGURE.y, 420.0)


func test_a_guardians_door_is_no_meeting_and_the_two_show_different_angels() -> void:
	_run()
	var map := game.rooms.map
	var guardians: Array[RunMap.Room] = []
	for n: RunMap.Room in map.nodes:
		if n.kind == RunMap.Kind.MINIBOSS:
			assert_false(n.meeting, "PT-8: the door shows its angel")
			if n.depth == map.miniboss_depth:
				guardians.append(n)
	assert_eq(guardians.size(), 2, "the two guardians side by side")
	for g in guardians:
		g.angel = &""
	for g in guardians:
		assert_true(Rooms.shows_angel(g))
		g.angel = game.encounters.door_angel(g, Rooms._angels_of(guardians))
	assert_ne(guardians[0].angel, &"")
	assert_ne(guardians[0].angel, guardians[1].angel, "two different Blessings to choose between")


func test_a_door_angel_avoids_the_one_beside_it() -> void:
	_run()
	var r: RunMap.Room = game.rooms.map.nodes[1]
	var first := game.encounters.door_angel(r)
	var other := game.encounters.door_angel(r, [first] as Array[StringName])
	assert_ne(other, first)
	assert_eq(game.encounters.door_angel(r), first, "the same dice, the same angel")


func test_the_knights_shield_lands_where_he_stood_and_marks_a_red_circle() -> void:
	# Daniel, 2026-11-23: no following; a large round mark where the hero was as it left the hand (the wave comes after)
	_run()
	await wait_process_frames(2)
	var k := game.horde.spawn(game.horde.def(&"knight"), Vector2(8, 0), false)
	game.player.pos = Vector2(0, 0)
	game.horde.target = game.player.pos
	game.horde._loose_shield(k)
	var s: Horde.Shield = game.horde.shields[0]
	var at := s.land
	assert_not_null(s.mark, "a red circle on the floor")
	assert_almost_eq(s.mark.radius, k.def.throw_half, 0.001)
	assert_gte(k.def.throw_half, 2.0, "larger than the old 1.5 m square")
	game.player.pos = Vector2(-5, 3)
	game.horde.target = game.player.pos
	game.horde._step_shields(0.3)
	assert_eq(s.land, at, "it never follows him")
