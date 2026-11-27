extends GutTest
## GP-8 technique A prototype (PaintedHall): the painter's camera puts the plan where the painting has it, the inverse
## agrees, and with --painted the hall is walkable and the doors stay reachable.

const STAGE := "res://data/stages/catacombs.tres"


func after_each() -> void:
	Dev.drop("painted")


func test_the_fit_camera_puts_the_doors_and_corners_on_the_painting() -> void:
	var p := PaintedHall.POSES[&"fit"]
	var want := {Vector3(7.6, 0, -15): Vector2(1300, 333), Vector3(11.8, 0, -15): Vector2(1525, 348),
		Vector3(-7.5, 0, -15): Vector2(484, 281), Vector3(14.0, 0, -15): Vector2(1650, 356)}
	for w: Vector3 in want:
		assert_lt(PaintedHall.to_pixel(p, w).distance_to(want[w]), 80.0, "%s lands near its pixel" % w)


func test_pixel_and_floor_are_inverses() -> void:
	var p := PaintedHall.POSES[&"fit"]
	for f in [Vector2(0, 0), Vector2(5, -10), Vector2(-3, 12)]:
		var px := PaintedHall.to_pixel(p, Vector3(f.x, 0, f.y))
		assert_lt(PaintedHall.to_floor(p, px).distance_to(f), 0.01)


func test_painted_hall_is_walkable_and_its_doors_reachable() -> void:
	Dev.put("painted", "1")
	var a := Arena.new()
	add_child_autofree(a)
	a.build((load(STAGE) as StageDef).layouts[0], 2, 1406)
	assert_not_null(a.get_node_or_null("PaintedHall"))
	assert_true(a.on_floor(a.start, Player.RADIUS), "the way in is on the floor")
	assert_eq(a.resolve(a.start, Player.RADIUS), a.start, "and free of colliders")
	for i in 2:
		var goal := a.resolve(a.door_goal(i), Player.RADIUS)
		assert_eq(a.exit_at(goal), i, "door %d is reached" % i)
	var far := a.resolve(Vector2(-12, 0), Player.RADIUS)
	assert_gt(far.x, PaintedHall.FLOOR.position.x, "nobody walks west of the painted floor")
