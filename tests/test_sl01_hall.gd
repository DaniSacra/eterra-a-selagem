extends GutTest
## SL-01 (docs/art/ref/sala01_2026-11-25, local only): room 1, the catacomb hall, from the approved painting and its plan.
## Two doors in the north wall (D1, D2) closed in combat, closed with their signs when the way is ready, only the chosen
## one opening on black; the old east stairs and the lion are gone; the stream is walkable and the rubble blocks nothing.

const STAGE := "res://data/stages/catacombs.tres"


func _hall(exits := 2) -> Arena:
	var stage: StageDef = load(STAGE)
	var a := Arena.new()
	add_child_autofree(a)
	a.build(stage.layouts[0], exits, 1406)
	return a


func test_the_two_doors_stand_where_the_plan_puts_them() -> void:
	var a := _hall()
	assert_eq(a.exits.size(), 2)
	for i in 2:
		assert_almost_eq(a.exits[i].x, CatacombHall.DOOR_X[i], 0.001, "door %d at the plan's x" % i)
		assert_true(a.exit_zones[i].has_point(a.exits[i]), "door %d: its spot is in its zone" % i)
		assert_eq(a.exit_inward[i], Vector2(0, 1), "door %d looks south into the hall" % i)
	assert_almost_eq(CatacombHall.DOOR_X[1] - CatacombHall.DOOR_X[0], 6.4, 0.001, "2026-11-27: centres 6.4 m apart")
	var between := CatacombHall.DOOR_X[1] - CatacombHall.DOOR_X[0] - CatacombHall.HALL_DOOR.x - 2.0 * CatacombHall.DOOR_FRAME
	assert_gte(between, CatacombHall.NICHE.x, "the wall between the frames takes the statue's niche")
	assert_almost_eq((CatacombHall.DOOR_X[0] + CatacombHall.DOOR_X[1]) * 0.5, CatacombHall.MID_STATUE.x, 0.001, "the statue stands midway")
	assert_gte(CatacombHall.HALL_DOOR.y, CatacombHall.DOOR_CLEAR.y * 1.4, "the hall's doors are monumental")
	assert_false(a.exit_zones[0].intersects(a.exit_zones[1]), "the two zones never overlap: one place, one choice")


func test_each_door_is_reached_from_inside_and_the_wall_stays_shut() -> void:
	var a := _hall()
	for i in 2:
		var goal := a.resolve(a.door_goal(i), Player.RADIUS)
		assert_eq(a.exit_at(goal), i, "door %d is left by walking to it" % i)
		# walking north through its middle stops at the wall: nobody crosses before the choice
		var p := Vector2(CatacombHall.DOOR_X[i], -8.0)
		for _s in 120:
			p = a.resolve(p + Vector2(0, -0.1), Player.RADIUS)
		assert_gt(p.y, -CatacombHall.HALF.y, "door %d: the paladin stays in the hall" % i)
		assert_false(a.on_floor(Vector2(CatacombHall.DOOR_X[i], -CatacombHall.HALF.y - 1.2), Player.RADIUS),
			"door %d: no floor beyond the wall to walk on" % i)
	assert_eq(a.exit_at(Vector2.ZERO), -1)


func test_the_old_east_stairs_are_gone() -> void:
	var a := _hall(3)
	assert_eq(a.exits.size(), 3, "the count of doors is as it was: the two of the north wall and the south stairs")
	for i in 3:
		var e := a.exits[i]
		assert_false(e.x > 12.5 and e.y > -12.5 and e.y < 4.0, "no door on the east side (door %d at %s)" % [i, e])
	assert_gt(a.exits[2].y, 0.0, "the third is the south stairs")
	# the old gap of the east balustrade is closed: nobody walks out of the hall there
	var out := a.resolve(Vector2(15.5, -11.8), Player.RADIUS)
	assert_lt(out.x, 15.0, "kept inside at the old east stairs")


func test_the_signs_hang_in_the_doorway_on_their_own_anchor() -> void:
	var a := _hall()
	assert_false(a.exit_rod, "no rod: the medallions hang free in their closed doors")
	var p := a.door_anchor(0)
	var q := a.door_anchor(1)
	assert_almost_eq(p.x, CatacombHall.DOOR_X[0], 0.01)
	assert_almost_eq(q.x, CatacombHall.DOOR_X[1], 0.01)
	assert_almost_eq(p.z, -CatacombHall.HALF.y + CatacombHall.DOOR_SIGN.x, 0.01, "in the doorway (PT-25-10)")
	assert_almost_eq(q.z, -CatacombHall.HALF.y + CatacombHall.DOOR_SIGN.x, 0.01)
	assert_between(p.y, 1.5, CatacombHall.HALL_DOOR.y - 1.5, "the disc fits inside the door's height")
	assert_gt(Vector2(p.x, p.z).distance_to(Vector2(q.x, q.z)), 4.0, "never over one another")
	assert_eq(a.door_at_anchor(Vector2(p.x, p.z)), 0)
	assert_eq(a.door_at_anchor(Vector2(q.x, q.z)), 1)
	assert_between(a.door_sign_y(0), 0.0, p.y, "the text starts under its medallion")


func test_three_states_of_the_doors() -> void:
	var a := _hall()
	var d0 := a.hall_look.door_leaves(0)
	var d1 := a.hall_look.door_leaves(1)
	assert_not_null(d0)
	assert_not_null(d1)
	# combat and ready: both closed (the signs are Rooms', the doors only stand shut)
	assert_false(d0.is_open)
	assert_false(d1.is_open)
	assert_almost_eq(d0.swing(), 0.0, 0.0001)
	# the choice: only the chosen one opens
	a.open_exit(1)
	assert_false(d0.is_open, "the other stays shut")
	assert_true(d1.is_open)
	assert_almost_eq(d0.swing(), 0.0, 0.0001, "and its leaves have not moved")
	await get_tree().create_timer(HallDoor.OPEN_TIME + 0.3).timeout
	assert_almost_eq(d1.swing(), HallDoor.OPEN_ANGLE, 0.001, "the leaves swing all the way in")
	# no door for the south stairs, a number out of range or none: nothing happens
	a.open_exit(2)
	a.open_exit(-1)
	assert_false(d0.is_open)


func test_the_doors_have_no_portal_and_no_stairs_and_no_lion() -> void:
	var a := _hall(2)
	var kit: ArenaKit = a._kit
	assert_eq(kit.portals.size(), 0, "no portal sheet in the hall")
	for n in a.find_children("*", "GeometryInstance3D", true, false):
		var m := (n as GeometryInstance3D).material_override as ShaderMaterial
		if m != null:
			assert_ne(m.shader, ArenaKit.BANNER_LION_SHADER, "no lion on a banner of the enemy's ground")


func test_the_stream_is_walkable_and_the_rubble_blocks_nothing() -> void:
	var a := _hall()
	for p in CatacombHall.WATER_LINE:
		assert_false(a.overlaps(p, Player.RADIUS), "the stream's line at %s is free floor" % p)
		assert_eq(a.resolve(p, Player.RADIUS), p, "and walked through, never pushed")
	for pool in CatacombHall.WATER_POOLS:
		assert_eq(a.resolve(Vector2(pool.x, pool.y), Player.RADIUS), Vector2(pool.x, pool.y), "pools are walkable too")
	for pile in CatacombHall.RUBBLE_PILES:
		assert_false(a.overlaps(Vector2(pile.x, pile.y), Player.RADIUS), "rubble at %s blocks nothing" % [Vector2(pile.x, pile.y)])
	assert_lte(CatacombHall.RUBBLE_TOP, 0.3, "nothing over 0.3 m on the walkable floor")


func test_the_ground_of_the_stylized_look_holds_the_water() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := _hall()
	var ground := a.find_child("HallGround", true, false)
	assert_not_null(ground, "the stylized look's stream and rubble")
	var waters := 0
	for c in ground.get_children():
		var m := (c as GeometryInstance3D).material_override as ShaderMaterial if c is GeometryInstance3D else null
		if m != null and m.shader == preload("res://assets/shaders/shallow_water.gdshader"):
			waters += 1
	assert_eq(waters, 1 + CatacombHall.WATER_POOLS.size(), "the stream and its pools")


func test_the_hall_door_arch_is_pointed_and_as_tall_as_the_plan() -> void:
	var spring := HallDoor.spring_of(CatacombHall.HALL_DOOR.x, CatacombHall.HALL_DOOR.y, CatacombHall.DOOR_ARC)
	assert_between(spring, 1.0, CatacombHall.HALL_DOOR.y - 0.5, "the springing line lies under the apex")
	var o := HallDoor.outline(CatacombHall.HALL_DOOR.x, CatacombHall.HALL_DOOR.y, CatacombHall.DOOR_ARC)
	var top := 0.0
	for p in o:
		top = maxf(top, p.y)
	assert_almost_eq(top, CatacombHall.HALL_DOOR.y, 0.001, "the apex is the door's height")
	assert_almost_eq(o[0].x, -CatacombHall.HALL_DOOR.x * 0.5, 0.001)
	assert_almost_eq(o[o.size() - 1].x, CatacombHall.HALL_DOOR.x * 0.5, 0.001)


func test_hall_door_opens_with_a_tween_too() -> void:
	var root := Node3D.new()
	add_child_autofree(root)
	var d := HallDoor.make(root, Vector3.ZERO, 2.4, 3.6, 0.8)
	d.open(0.05)
	assert_true(d.is_open)
	await get_tree().create_timer(0.3).timeout
	assert_almost_eq(d.swing(), HallDoor.OPEN_ANGLE, 0.001)
