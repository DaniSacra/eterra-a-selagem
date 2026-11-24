extends GutTest
## Ofícios, Roteiro A in a real run and in the hub: the head found in its marked room or by the guardian's pity, the
## vein noted without the pick and extracted with it (one press, vein_hold seconds standing at it, at most veins_max),
## the angels' preview, the RESULT, and the Forjador's and the Vendedor's sheets.

var game: Game


func _run(kind := RunMap.Kind.COMBAT) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(kind)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


## A vein spot on the current room's floor.
func _with_vein() -> Vector2:
	var at := game.arena.resolve(Vector2(4.0, 2.0), 0.6)
	game.rooms._layout = game.rooms._layout.duplicate()
	game.rooms._layout.gather_spots = PackedVector2Array([at])
	game.rooms.room.vein = true
	return at


func test_the_head_is_found_in_its_room() -> void:
	_run()
	game.oficios.wants_head = true
	game.rooms.room.find = game.oficios_def.head
	game.rooms.room.reward = RunMap.Reward.NONE
	game.rooms._room_cleared()
	assert_true(game.oficios.head_found)
	assert_eq(game.oficios.head_by, "room")
	assert_eq(game.result().oficios.finds, ["pick_head"])


func test_the_guardian_gives_the_head_by_pity() -> void:
	_run(RunMap.Kind.MINIBOSS)
	game.oficios.wants_head = true
	game.oficios.pity_due = true
	game.rooms.room.reward = RunMap.Reward.NONE
	game.rooms._room_cleared()
	assert_true(game.oficios.passed_guardian)
	assert_true(game.oficios.head_found)
	assert_eq(game.oficios.head_by, "pity")


func test_a_closed_vein_is_noted_and_an_open_one_extracted() -> void:
	_run()
	var at := _with_vein()
	game.rooms.room.reward = RunMap.Reward.NONE
	game.rooms._room_cleared()
	var vein := game.rooms._vein
	assert_not_null(vein, "the vein shows once the room is won")
	assert_eq(vein.state, VeinFloor.State.CLOSED, "no pick: closed")
	game.player.pos = at
	assert_eq(game.rooms.use_kind(), &"vein_note")
	game.rooms.use()
	game.rooms.step(0.016)
	assert_true(game.oficios.noted, "noted in the Livro")
	assert_eq(game.oficios.stones, 0)
	# with the pick: one press, then vein_hold seconds standing at it
	game.oficios.has_pick = true
	vein.set_state(VeinFloor.State.OPEN)
	assert_eq(game.rooms.use_kind(), &"vein")
	game.rooms.use()
	game.rooms.step(0.016)
	for i in 30:
		game.rooms.step(0.05)
	assert_eq(game.oficios.stones, 1)
	assert_eq(game.oficios.veins, 1)
	assert_eq(vein.state, VeinFloor.State.SPENT)
	assert_almost_eq(game.oficios.gather_s, game.oficios_def.vein_hold, 0.06)
	assert_false(game.rooms.usable(), "spent")
	assert_eq(game.result().oficios.gather.stones, 1)


func test_walking_off_stops_the_extraction() -> void:
	_run()
	var at := _with_vein()
	game.oficios.has_pick = true
	game.rooms.room.reward = RunMap.Reward.NONE
	game.rooms._room_cleared()
	game.player.pos = at
	game.rooms.use()
	game.rooms.step(0.016)
	game.rooms.step(0.5)
	game.player.pos = at + Vector2(3.0, 0.0)
	for i in 20:
		game.rooms.step(0.05)
	assert_eq(game.oficios.stones, 0)
	assert_lt(game.rooms._vein.progress, 0.0, "forgotten")


func test_no_vein_past_the_most() -> void:
	_run()
	_with_vein()
	game.oficios.has_pick = true
	game.oficios.veins = game.oficios_def.veins_max
	game.rooms.room.reward = RunMap.Reward.NONE
	game.rooms._room_cleared()
	assert_null(game.rooms._vein, "two a descent: no third (and the robot-free closed one only without the pick)")


func test_the_angels_preview_shows_the_next_layer() -> void:
	_run(RunMap.Kind.FOUNTAIN)
	game.oficios.preview = true
	game.rooms._preview_angels()
	var shown := 0
	var boons := 0
	for r in game.rooms.next_rooms:
		for id in r.next:
			var n := game.rooms.map.nodes[id]
			if n.reward == RunMap.Reward.BOON and not n.meeting and n.kind == RunMap.Kind.COMBAT:
				boons += 1
				if n.angel != &"":
					shown += 1
	assert_eq(shown, boons, "every Blessing's room behind the doors shows its angel")


func test_the_forjador_restores_and_the_vendedor_takes_the_order() -> void:
	var saved := Save.data
	Save.data = SaveData.defaults()
	var d := OficiosDef.live()
	Oficios.block(Save.data).seen.append(Oficios.VEIN)
	Oficios.block(Save.data).finds.append(String(d.head))
	MaterialPurse.give(Save.data, MaterialPurse.SILVER, 60)
	var hub: Hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	var done: Array[StringName] = []
	hub.oficio_done.connect(func(w: StringName) -> void: done.append(w))
	assert_eq(Hub.station_line(HubPlan.SMITH), &"oficio_has_order")
	hub.use(HubPlan.SMITH)
	var f := hub.host.screen as ForgeScreen
	assert_not_null(f, "the Forja, on the Oficina's bench")
	assert_eq(f.tab, ForgeScreen.Tab.WORKSHOP)
	for k in 3:
		f.press()
		f.release()
	assert_true(Oficios.has_tool(Save.data, d))
	assert_true(Oficios.has_tool(Save.data, d))
	assert_eq(MaterialPurse.amount(Save.data, MaterialPurse.SILVER), 40)
	await wait_process_frames(2)
	hub.host.close()
	await wait_process_frames(2)
	Oficios.add_item(Save.data, d, d.stone, 2)
	assert_eq(Hub.station_line(HubPlan.VENDOR), &"oficio_has_order")
	hub.use(HubPlan.VENDOR)
	var p := hub.host.screen as HubPanel
	assert_not_null(p, "the Vendedor's order")
	p.chosen.emit(&"deliver")
	assert_eq(Oficios.order_state(Save.data, d), Oficios.Order.DONE)
	assert_eq(MaterialPurse.amount(Save.data, MaterialPurse.SILVER), 10)
	assert_eq(done, [&"restore", &"deliver"] as Array[StringName])
	await wait_process_frames(2)
	hub.host.close()
	Save.data = saved


func test_the_robot_with_the_pick_goes_to_the_vein() -> void:
	_run()
	var at := _with_vein()
	game.oficios.has_pick = true
	game.rooms.room.reward = RunMap.Reward.NONE
	game.rooms._room_cleared()
	assert_eq(game.rooms.bot_goal(), game.rooms._vein.at, "the vein before the doors")
	assert_almost_eq((game.rooms._vein.at as Vector2).distance_to(at), 0.0, 0.7)
