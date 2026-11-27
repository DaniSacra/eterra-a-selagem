extends GutTest
## 2026-11-26, the Antessala and the Sala 00 (package antessala_sala00): the prologue's rules (Prologue), the save's `ante`, the two
## layouts, and the flow through Rooms (a new save: Antessala, Sala 00, room 1; every other descent: Sala 00, room 1; one Blessing at
## the altar; the count of rooms untouched; the arrival gives the hero back; the breakables give nothing).

const STAGE := "res://data/stages/catacombs.tres"

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func after_each() -> void:
	for k in ["first", "autopick", "hold-frames", "arrival"]:
		Dev.drop(k)
	Controls.virtual = null
	Save.data["ante"] = 0
	FirstTips.shown(Save.data).erase("altar")


# ---------- the rules ----------

func test_the_enum_keeps_its_numbers_and_the_two_rooms_are_no_rooms_of_the_graph() -> void:
	assert_eq(int(RunMap.Kind.ANTE), 7, "no saved number moves")
	assert_eq(int(RunMap.Kind.SALA00), 8, "the Sala 00 comes last")
	assert_eq(RunMap.KIND_KEY.size(), RunMap.Kind.size())
	assert_true(Prologue.is_prologue(RunMap.Kind.ANTE) and Prologue.is_prologue(RunMap.Kind.SALA00))
	assert_false(Prologue.is_prologue(RunMap.Kind.COMBAT))
	for seed_value in [1, 5, 11]:
		var m := RunMap.new(stage, seed_value)
		for r in m.nodes:
			assert_false(Prologue.is_prologue(r.kind), "the long descent draws neither")
		assert_eq(m.layers.size(), stage.rooms + 2, "the count of rooms and Morvath's depth do not move")
	assert_eq(stage.rooms + 1, 14, "Sala 1 de 14")


func test_a_new_save_meets_the_antessala_then_the_sala_00_and_every_other_descent_only_the_sala_00() -> void:
	var new_save := SaveData.defaults()
	assert_eq(Prologue.kinds(true, new_save), [RunMap.Kind.ANTE, RunMap.Kind.SALA00] as Array[RunMap.Kind])
	assert_eq(Prologue.kinds(false, new_save), [RunMap.Kind.SALA00] as Array[RunMap.Kind], "off the guided descent never the Antessala")
	Prologue.cross_ante(new_save)
	assert_eq(Prologue.kinds(true, new_save), [RunMap.Kind.SALA00] as Array[RunMap.Kind], "crossed once, never again")


func test_the_save_keeps_the_antessala_per_file_and_an_old_one_never_gets_it() -> void:
	assert_eq(SaveData.defaults().ante, 0)
	var played := SaveData.defaults()
	played["version"] = 18
	played.erase("ante")
	played["runs"] = 3
	assert_eq(SaveData.merged(played).ante, 1, "a save that descended never receives it")
	var done := SaveData.defaults()
	done["version"] = 18
	done.erase("ante")
	done["first"] = FirstDescent.SKIPPED
	assert_eq(SaveData.merged(done).ante, 1, "nor one whose guided descent is skipped")
	var fresh := SaveData.defaults()
	fresh["version"] = 18
	fresh.erase("ante")
	assert_eq(SaveData.merged(fresh).ante, 0, "a new one still has it ahead")
	# three saves, three states: one does not leak into the next
	var a := SaveData.merged(fresh)
	var b := SaveData.merged(fresh)
	Prologue.cross_ante(a)
	assert_eq(b.ante, 0)
	assert_true(Prologue.ante_due(b, true) and not Prologue.ante_due(a, true))


func test_the_arrival_is_full_at_the_antessala_and_from_the_hub_and_short_between_the_two() -> void:
	assert_eq(Prologue.arrival(RunMap.Kind.ANTE, false), Prologue.Arrival.FULL)
	assert_eq(Prologue.arrival(RunMap.Kind.SALA00, false), Prologue.Arrival.FULL, "from the Santuário")
	assert_eq(Prologue.arrival(RunMap.Kind.SALA00, true), Prologue.Arrival.SHORT, "from the Antessala")
	for k in [RunMap.Kind.COMBAT, RunMap.Kind.MINIBOSS, RunMap.Kind.SHOP, RunMap.Kind.BOSS]:
		assert_eq(Prologue.arrival(k, false), Prologue.Arrival.NONE, "no comet in the rooms of the descent")
	assert_lt(Prologue.SHORT_FROM, ArrivalTimeline.T_CONTROL)
	assert_gte(Prologue.SHORT_FROM, ArrivalTimeline.T_OPEN, "the short one starts with the comet already falling")


func test_the_altar_gives_one_blessing_and_the_door_waits_for_it() -> void:
	var g := Prologue.Grant.new()
	assert_true(g.may_offer())
	assert_false(g.door_open())
	g.offer()
	assert_false(g.may_offer(), "opened once: never opened again")
	g.offer()
	g.step(false)
	g.step(false)
	assert_false(g.door_open(), "the screen is still over it: not taken")
	g.step(true)
	assert_false(g.door_open())
	g.step(false)
	g.step(true)
	g.step(true)
	assert_true(g.door_open(), "taken: the screen is gone for two steps")
	assert_false(g.may_offer(), "and the altar is spent")
	g.offer()
	assert_true(g.door_open(), "asking again changes nothing")


# ---------- the two rooms ----------

func test_the_antessala_and_the_sala_00_are_made_to_the_plan() -> void:
	var a := stage.ante_layout
	assert_eq(a.half, Vector2(7.0, 24.0), "14 x 48 m")
	assert_eq(a.exits.size(), 1, "one door")
	assert_eq(a.exits[0].mouth.size.x, 3.0, "3 m clear")
	assert_eq(a.hero_spawn, Vector2(0.0, 20.0))
	assert_eq(a.look, &"ante")
	assert_eq(a.gaps.size(), 1)
	assert_almost_eq(a.gaps[0].size.y, 2.6, 0.001, "the canal of 2.6 m")
	assert_true(a.hazard != null and a.hazard.kind == HazardDef.Kind.PLATES, "the existing slab")
	assert_gte(a.hazard.hero_damage, 1.0)
	assert_eq(a.breakables.size(), 6)
	var cols := a.obstacles.filter(func(o: ArenaObstacle) -> bool: return o.piece == &"column")
	assert_eq(cols.size(), 8)
	var s := stage.sala00_layout
	assert_eq(s.half, Vector2(9.0, 8.0), "18 x 16 m")
	assert_eq(s.hero_spawn, Vector2(0.0, 6.0))
	assert_eq(s.exits.size(), 1)
	assert_eq(s.look, &"sala00")
	assert_true(s.gaps.is_empty() and s.hazard == null and s.breakables.is_empty() and s.spawns.is_empty(), "no hazard, nothing to break, nobody")
	var altar := s.obstacles.filter(func(o: ArenaObstacle) -> bool: return o.piece == &"altar")
	assert_eq(altar.size(), 1)
	assert_eq((altar[0] as ArenaObstacle).center, Vector2.ZERO, "the altar in the middle")
	assert_eq(s.obstacles.size(), 5, "four columns and the altar")
	for l in [a, s]:
		assert_true(ArenaRoom.LOOKS.has(l.look))
		assert_true(l.spawns.is_empty(), "no spawn of enemies")


func test_both_rooms_build_and_the_hero_walks_from_the_way_in_to_the_door() -> void:
	for l: RoomLayout in [stage.ante_layout, stage.sala00_layout]:
		var arena := Arena.new()
		add_child_autofree(arena)
		arena.build(l, 1, 1406)
		assert_eq(arena.exits.size(), 1, "%s: one door" % l.id)
		assert_eq(arena.resolve(arena.start, Player.RADIUS), arena.start, "%s: the way in is floor" % l.id)
		var goal := arena.resolve(arena.door_goal(0), Player.RADIUS)
		assert_eq(arena.exit_at(goal), 0, "%s: the robot's goal leaves by the door" % l.id)
		for p in arena.pillars:
			assert_gte(arena.start.distance_to(Vector2(p.x, p.y)), p.z + Player.RADIUS, "%s: the spawn is clear" % l.id)


# ---------- the flow in the game ----------

func _game() -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_physics_frames(2)
	return game


func test_every_descent_opens_in_the_sala_00_and_goes_on_to_room_one_with_one_blessing() -> void:
	Dev.put("autopick", "1")
	var game := await _game()
	var rooms := game.rooms
	assert_eq(rooms.room.kind, RunMap.Kind.SALA00, "Hub to Sala 00")
	assert_eq(rooms.depth(), 0, "no depth moved")
	assert_eq(rooms.next_rooms.size(), 1)
	assert_eq(rooms.next_rooms[0].depth, 1, "the Sala 00 leads to room 1")
	assert_eq(game.boons.owned().size(), 0)
	assert_true(rooms._door_locked(), "the door is shut until the Blessing is taken")
	assert_true(rooms.altar.may_offer())
	# the hero stands at the altar and uses it
	game.player.place(rooms._altar_front())
	assert_true(rooms.usable(), "the prompt is there")
	assert_eq(rooms.use_kind(), &"altar_bless")
	rooms.use()
	await wait_physics_frames(30)
	assert_eq(game.boons.owned().size(), 1, "one Blessing, taken")
	assert_true(rooms.altar.door_open())
	assert_false(rooms._door_locked(), "the door is open now")
	# asking again (the interface left and come back to) gives nothing more and draws nothing again
	game.player.place(rooms._altar_front())
	assert_false(rooms.usable() and rooms.use_kind() == &"altar_bless", "the altar is spent")
	rooms.use()
	await wait_physics_frames(30)
	assert_eq(game.boons.owned().size(), 1, "not twice")
	# through the door: room 1, at depth 1, "Sala 1 de 14"
	game.player.place(game.arena.exits[0])
	rooms.use()
	for i in 120:
		if rooms.room.kind == RunMap.Kind.COMBAT:
			break
		await get_tree().process_frame
	assert_eq(rooms.room.kind, RunMap.Kind.COMBAT)
	assert_eq(rooms.room.depth, 1)
	assert_eq(rooms.depth(), 1)
	assert_eq(game.boons.owned().size(), 1, "the Blessing came with him, once")


func test_a_new_saves_guided_descent_goes_antessala_sala_00_room_one_and_writes_the_crossing_once() -> void:
	Dev.put("first", "1")
	Dev.put("autopick", "1")
	var game := await _game()
	var rooms := game.rooms
	assert_eq(rooms.room.kind, RunMap.Kind.ANTE, "a new save begins in the Antessala")
	assert_not_null(rooms.lesson)
	assert_eq(rooms.next_rooms[0].kind, RunMap.Kind.SALA00)
	assert_true(rooms._door_locked())
	assert_eq(Save.data.ante, 0)
	assert_eq(game.boons.owned().size(), 0, "no Blessing in the Antessala")
	for e in [&"finisher", &"heavy", &"power", &"special", &"crossed", &"passed"]:
		rooms.lesson.feed(e)
	await wait_physics_frames(30)
	assert_false(rooms._door_locked(), "every lesson done: the door opens, with no Blessing asked")
	assert_eq(game.boons.owned().size(), 0)
	rooms._leave(rooms.next_rooms[0])
	for i in 200:
		if rooms.room.kind == RunMap.Kind.SALA00:
			break
		await get_tree().process_frame
	assert_eq(rooms.room.kind, RunMap.Kind.SALA00)
	assert_true(rooms._from_ante, "the short arrival")
	assert_eq(Save.data.ante, 1, "the crossing is written as he goes through the door")
	assert_eq(rooms.depth(), 0, "the Sala 00 is no room: Sala 1 stays room 1")
	assert_eq(rooms.room.angel, &"sarael", "the first Blessing of a new save is the angel's of the guided descent")
	assert_eq(rooms.next_rooms[0].depth, 1)
	assert_eq(Prologue.kinds(true, Save.data), [RunMap.Kind.SALA00] as Array[RunMap.Kind], "and the Antessala is not met again")


## Daniel's playtest, 2026-11-27: holding the attack never closed the "Segure" tip (the Esmagador is an Omega by its tag and fed
## nothing). Each of the Warrior's four mouse blows, as the player strikes it, closes its own step.
func test_each_mouse_blow_of_the_warrior_closes_its_own_step() -> void:
	Dev.put("first", "1")
	Dev.put("autopick", "1")
	var game := await _game()
	var rooms := game.rooms
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	var step_of := {&"smash": &"heavy", &"sweep": &"power", &"lance": &"special"}
	for n in tree.all_nodes():
		if step_of.has(n.id):
			assert_false(rooms.lesson.is_done(step_of[n.id]))
			game.player.struck.emit(n, Vector2.ZERO, Vector2.RIGHT)
			assert_true(rooms.lesson.is_done(step_of[n.id]), String(n.id))
	assert_false(rooms.lesson.is_done(&"attack"), "no click of the chain yet")
	for n in tree.all_nodes():
		if n.has_tag(&"finisher"):
			game.player.struck.emit(n, Vector2.ZERO, Vector2.RIGHT)
	assert_true(rooms.lesson.is_done(&"attack"))


func test_the_breakables_of_the_antessala_give_nothing() -> void:
	Dev.put("first", "1")
	var game := await _game()
	var rooms := game.rooms
	assert_eq(rooms.room.kind, RunMap.Kind.ANTE)
	var kills := game.kills
	var gold := rooms.gold
	var owned := game.boons.owned().size()
	var silver := game.materials.total(MaterialPurse.SILVER)
	var memory := game.materials.total(MaterialPurse.MEMORY)
	var hp := game.player.hp
	assert_not_null(game.breaks)
	for p in game.breaks.rules.pieces:
		game.breaks.rules.circle(p.at, 0.3, Breakables.Source.HERO)
		game.breaks.rules.circle(p.at, 0.3, Breakables.Source.HERO)
	assert_eq(game.breaks.rules.broken_count(), 6, "all six break")
	await wait_physics_frames(3)
	assert_eq(game.kills, kills, "no kill counted")
	assert_eq(rooms.gold, gold, "no gold")
	assert_eq(game.boons.owned().size(), owned)
	assert_eq(game.materials.total(MaterialPurse.SILVER), silver, "no material")
	assert_eq(game.materials.total(MaterialPurse.MEMORY), memory)
	assert_eq(game.player.hp, hp)


func test_the_trap_in_the_antessala_never_takes_the_last_of_his_life() -> void:
	Dev.put("first", "1")
	var game := await _game()
	assert_eq(game.rooms.room.kind, RunMap.Kind.ANTE)
	assert_true(game.player.guard_death)
	game.player.invuln = 0.0
	game.player.hp = 4.0
	game.player.hurt(30.0, Vector2.ZERO)
	assert_eq(game.player.hp, 1.0, "left at 1")
	game.player.invuln = 0.0
	game.player.hurt(30.0, Vector2.ZERO)
	assert_gte(game.player.hp, 1.0, "never dead there")
	assert_true(game.player.alive())


func test_the_arrival_holds_the_buttons_and_gives_the_hero_back() -> void:
	Dev.put("hold-frames", "2")
	var game := await _game()
	var rooms := game.rooms
	for i in 600:
		if rooms.arriving():
			break
		await get_tree().process_frame
	assert_eq(rooms.room.kind, RunMap.Kind.SALA00)
	assert_true(rooms.arriving(), "the comet is falling: from the Santuário, the whole of it")
	var scene := rooms._arrival as ArrivalScene
	assert_not_null(scene)
	var at := game.player.pos
	var magick := game.player.magick.value
	Controls.virtual = Controls.VirtualPad.new()
	Controls.virtual.move = Vector2.RIGHT
	Controls.virtual.press(&"light_attack")
	for i in 20:
		await get_tree().process_frame
	assert_lt(game.player.pos.distance_to(at), 0.05, "he does not move")
	assert_eq(game.player.magick.value, magick, "nor spend")
	Controls.virtual = null
	scene.clock = 1.2
	scene.skip()
	var guard := 0
	while rooms.arriving() and guard < 600:
		await get_tree().process_frame
		guard += 1
	assert_false(rooms.arriving(), "control is back")
	assert_false(game.cam.lean_free)
	assert_true(game.player.visible)
	Controls.virtual = Controls.VirtualPad.new()
	Controls.virtual.move = Vector2.RIGHT
	for i in 90:
		await get_tree().process_frame
	assert_gt(game.player.pos.distance_to(at), 0.3, "and he walks")


func test_the_short_arrival_starts_with_the_comet_already_falling() -> void:
	var game := await _game()
	var scene := ArrivalScene.new()
	game.add_child(scene)
	scene.play(game, Vector2(0.0, 3.0), Prologue.SHORT_FROM, false)
	assert_almost_eq(scene.clock, Prologue.SHORT_FROM, 0.001)
	assert_true(scene._captioned, "no line over the short one")
	scene._restore()
	scene.queue_free()
