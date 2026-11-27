extends GutTest
## QA P1-1 (DT-RS3): a new room is built and first drawn on a black screen. The fade reaches black, the room is built,
## and the screen stays black for Rooms.HOLD_FRAMES drawn frames with the world not stepping (the first draw compiles
## the room's shaders, seconds on an iGPU); only then it fades in. Without a screen nothing waits (same RESULT).

func before_each() -> void:
	Dev.put("no-arrival", "1")


func after_each() -> void:
	Dev.drop("hold-frames")
	Dev.drop("no-arrival")


func test_without_a_screen_nothing_waits() -> void:
	assert_eq(Rooms.hold_frames(), 0, "headless: no hold, the smoke and the tests as before")


func test_the_new_room_is_held_black_and_the_world_waits() -> void:
	Dev.put("hold-frames", "2")
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var rooms := game.rooms
	for i in 400:
		if not rooms.holding() and rooms._fade.color.a == 0.0:
			break
		await get_tree().process_frame
	rooms._fade.color.a = 1.0  # (the door's fade-out reached black)
	var door: RunMap.Room = rooms.next_rooms[0]
	Dev.put("hold-frames", "4")
	var old := game.arena
	rooms._go(door)
	assert_ne(rooms.room, door, "a black frame is shown before the build")
	assert_true(rooms.holding(), "the world waits from the fade's black")
	# the build is spread over the black frames (Arena.build_async): the old room stays until the new one is whole
	var frames := 0
	while game.arena == old and frames < 400:
		await get_tree().process_frame
		frames += 1
		assert_true(rooms.holding(), "held through the build")
	assert_ne(game.arena, old, "the room is built")
	assert_true(frames > 3, "over several frames (%d)" % frames)
	assert_eq(rooms.room, door)
	assert_true(rooms.holding(), "and held")
	assert_eq(rooms._fade.color.a, 1.0, "on a black screen")
	var t := game.time
	var at := game.player.pos
	for i in 2:
		await get_tree().process_frame
	assert_true(rooms.holding(), "still held")
	assert_eq(game.time, t, "the world does not step while held")
	assert_eq(game.player.pos, at)
	await wait_process_frames(5)
	assert_false(rooms.holding(), "then it lets go")
	await wait_process_frames(3)
	assert_true(game.time > t, "and the world steps again")
	assert_true(rooms._fade.color.a < 1.0, "fading in")


## The descent's first room too (the opening frame was 1,9 s on the iGPU): on black, over frames, the world waiting,
## the placeholder never drawn; then the same room as without a screen.
func test_the_first_room_is_built_on_black_over_frames() -> void:
	Dev.put("hold-frames", "2")
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var rooms := game.rooms
	assert_true(rooms.holding(), "held from the start")
	assert_eq(rooms._fade.color.a, 1.0, "on black")
	assert_eq(game.arena.get_child_count(), 0, "the placeholder draws nothing")
	var t := game.time
	var frames := 0
	while game.arena.layout == null and game.arena.hall_look == null and frames < 400:
		await get_tree().process_frame
		frames += 1
	assert_true(frames > 3, "over several frames (%d)" % frames)
	assert_eq(game.time, t, "the world waits")
	for i in 400:
		if not rooms.holding():
			break
		await get_tree().process_frame
	assert_false(rooms.holding(), "then it lets go")
	assert_eq(game.player.pos, game.arena.start, "the hero where the room starts him")
	Dev.drop("hold-frames")
	var once: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(once)
	assert_eq(game.arena.get_child_count(), once.arena.get_child_count(), "the same room")
	assert_eq(game.arena.start, once.arena.start)
	assert_eq(game.arena.nav.free, once.arena.nav.free)


## The room built over frames is the room built at once: the same pieces, cover, walking grid and middle.
func test_the_spread_build_is_the_same_room() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var rooms: Array[RoomLayout] = [stage.trial_layout, stage.altar_layout, stage.boss_layout]
	for i in stage.layouts.size():
		rooms.append(stage.layouts[i].variant(i % stage.layouts[i].variant_count()))
	for l: RoomLayout in rooms:
		var once := Arena.new()
		add_child_autofree(once)
		once.build(l, 2, 1406)
		var spread := Arena.new()
		add_child_autofree(spread)
		await spread.build_async(l, 2, 1406, func() -> void: await get_tree().process_frame)
		assert_eq(_count(spread), _count(once), "%s: the same nodes" % l.id)
		assert_eq(spread.cover.size(), once.cover.size(), "%s: the same cover" % l.id)
		assert_eq(spread.nav.free, once.nav.free, "%s: the same walking grid" % l.id)
		assert_eq(spread.middle, once.middle, "%s: the same middle" % l.id)
		assert_eq(spread.exits, once.exits)


func _count(n: Node) -> int:
	var c := 1
	for k in n.get_children():
		c += _count(k)
	return c


## P1-1: what the title left of the shaders' warm-up ends before the first room under a black screen with a word
## (none without a screen: Warmup.start gives null and the run starts as before).
func test_the_warm_up_note() -> void:
	assert_null(Warmup.start(self, true), "headless: no warm-up, nothing waits")
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_physics_frames(1)
	assert_false(game._warming)
	assert_not_null(game.rooms, "the first room opened at once")
	var note := game._preparing_note()
	var words: Array = note.find_children("*", "Label", true, false)
	assert_eq(words.size(), 1)
	assert_eq((words[0] as Label).text, "Preparando as catacumbas")
	assert_eq(note.layer, 101, "over the warm-up's black")
	note.free()


## Sweep 2026-11-25, P0: the arrival's room (the guided descent's Antessala) never called _fade_in, so its hold stayed up
## for ever on a screen: the world never stepped, the clock stayed at 0:00, the robot stood still. With a screen
## (hold-frames forced) the world steps under the scene, the hero is given back and walks.
func test_the_arrival_gives_the_hero_back_on_a_screen() -> void:
	Dev.drop("no-arrival")
	Dev.put("hold-frames", "2")
	Dev.put("first", "1")
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var rooms := game.rooms
	for i in 600:
		if rooms._arrival != null:
			break
		await get_tree().process_frame
	var scene := rooms._arrival as ArrivalScene
	assert_not_null(scene, "the scene plays in the Antessala")
	if scene == null:
		Dev.drop("first")
		return
	for i in 400:
		if not rooms.holding():
			break
		await get_tree().process_frame
	assert_false(rooms.holding(), "the world is let go under the scene")
	scene.clock = 1.2
	scene.skip()
	var guard := 0
	while rooms._arrival != null and guard < 600:  # (finished frees it: the control is given)
		await get_tree().process_frame
		guard += 1
	assert_null(rooms._arrival, "the scene finished: the hero is given back")
	assert_false(game.cam.lean_free, "the camera is free of the scene")
	assert_true(game.player.visible)
	var t := game.time
	var from := game.player.pos
	Controls.virtual = Controls.VirtualPad.new()
	Controls.virtual.move = Vector2.RIGHT
	for i in 30:
		await get_tree().process_frame
	Controls.virtual = null
	assert_gt(game.time, t, "the clock of the world runs")
	assert_gt(game.player.pos.distance_to(from), 0.3, "and the hero walks")
	Dev.drop("first")
