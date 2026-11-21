extends GutTest
## QA P1-1 (DT-RS3): a new room is built and first drawn on a black screen. The fade reaches black, the room is built,
## and the screen stays black for Rooms.HOLD_FRAMES drawn frames with the world not stepping (the first draw compiles
## the room's shaders, seconds on an iGPU); only then it fades in. Without a screen nothing waits (same RESULT).

func after_each() -> void:
	Dev.drop("hold-frames")


func test_without_a_screen_nothing_waits() -> void:
	assert_eq(Rooms._hold_frames(), 0, "headless: no hold, the smoke and the tests as before")


func test_the_new_room_is_held_black_and_the_world_waits() -> void:
	Dev.put("hold-frames", "2")
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_physics_frames(2)
	var rooms := game.rooms
	var door: RunMap.Room = rooms.next_rooms[0]
	Dev.put("hold-frames", "4")
	rooms._go(door)
	assert_ne(rooms.room, door, "a black frame is shown before the build")
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(rooms.room, door, "the room is built")
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
