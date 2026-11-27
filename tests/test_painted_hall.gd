extends GutTest
## GP-8 (PaintedHall): each painted room has a painting that exists and the painter's camera of its capture; the projection
## puts the plan where the painting has it and its inverse agrees; the painted rooms keep their own collision and doors.

const STAGE := "res://data/stages/catacombs.tres"


func before_each() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)  # the painting is the stylized look's stone


func after_each() -> void:
	Dev.drop("painted")
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func _stage() -> StageDef:
	return load(STAGE) as StageDef


func test_every_painted_room_has_its_painting_and_a_game_camera_pose() -> void:
	for id: StringName in PaintedHall.ROOMS:
		var p := PaintedHall.pose_of(id)
		assert_true(ResourceLoader.exists(p[&"painting"]), "%s: the painting is in the project" % id)
		var tex := load(p[&"painting"]) as Texture2D
		assert_eq(Vector2i(tex.get_size()), Vector2i(1536, 1024), "%s: 3:2, the 16:9 frame stretched" % id)
		assert_eq(p[&"yaw"], Feel.live().cam_yaw, "%s: the painter's yaw is the game's" % id)
		assert_eq(p[&"pitch"], Feel.live().cam_pitch, "%s: the painter's pitch is the game's" % id)
		assert_eq(p[&"fov"], Feel.live().cam_fov, "%s: the painter's fov is the game's" % id)
		assert_gt(p[&"dist"], Feel.live().cam_distance_near, "%s: painted from further than the near camera" % id)


func test_the_painters_point_is_the_middle_of_the_painting() -> void:
	for id: StringName in PaintedHall.ROOMS:
		var p := PaintedHall.pose_of(id)
		var at: Vector2 = p[&"at"]
		var uv := PaintedHall.to_uv(p, Vector3(at.x, 0.0, at.y))
		assert_lt(uv.distance_to(Vector2(0.5, 0.5)), 0.001, "%s: it looks at its point" % id)


func test_the_plan_lands_inside_the_painting() -> void:
	# the hall's north-west and north-east floor corners and the doors' feet: in the frame
	var p := PaintedHall.pose_of(&"hall")
	for w in [Vector3(-16, 0, -15), Vector3(16, 0, -15), Vector3(CatacombHall.DOOR_X[0], 0, -15), Vector3(CatacombHall.DOOR_X[1], 0, -15), Vector3(0, 0, 15)]:
		var uv := PaintedHall.to_uv(p, w)
		assert_between(uv.x, 0.0, 1.0, "%s in x" % w)
		assert_between(uv.y, 0.0, 1.0, "%s in y" % w)


func test_uv_and_floor_are_inverses() -> void:
	for id: StringName in PaintedHall.ROOMS:
		var p := PaintedHall.pose_of(id)
		for f in [Vector2(0, 0), Vector2(5, -10), Vector2(-3, 12)]:
			var uv := PaintedHall.to_uv(p, Vector3(f.x, 0, f.y))
			assert_lt(PaintedHall.to_floor(p, uv).distance_to(f), 0.01, "%s %s" % [id, f])


func test_off_switch_and_default() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.layout = _stage().layouts[0]
	assert_eq(PaintedHall.wanted(a), PaintedHall.DEFAULT_ON, "the hall follows the default")
	Dev.put("painted", "off")
	assert_false(PaintedHall.wanted(a), "--painted=off turns it off")
	Dev.drop("painted")
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	assert_false(PaintedHall.wanted(a), "the classic look keeps its own stone")
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	Dev.put("painted", "1")
	assert_true(PaintedHall.wanted(a), "--painted forces it on")
	a.layout = _stage().layouts[1]
	assert_false(PaintedHall.wanted(a), "a room with no painting never is")


func test_painted_hall_keeps_collision_and_doors() -> void:
	var bare := Arena.new()
	add_child_autofree(bare)
	Dev.put("painted", "off")
	bare.build(_stage().layouts[0], 2, 1406)
	var a := Arena.new()
	add_child_autofree(a)
	Dev.put("painted", "1")
	a.build(_stage().layouts[0], 2, 1406)
	assert_not_null(a.get_node_or_null("PaintedHall"))
	assert_null(bare.get_node_or_null("PaintedHall"))
	assert_eq(a.pillars, bare.pillars, "the painted hall blocks where the bare one does")
	assert_eq(a.boxes, bare.boxes)
	assert_eq(a.exits, bare.exits)
	assert_eq(a.start, bare.start)
	for i in 2:
		var goal := a.resolve(a.door_goal(i), Player.RADIUS)
		assert_eq(a.exit_at(goal), i, "door %d is reached" % i)


func test_the_painted_hall_wears_the_painting_and_keeps_the_dynamic_pieces() -> void:
	Dev.put("painted", "1")
	var a := Arena.new()
	add_child_autofree(a)
	a.build(_stage().layouts[0], 2, 1406)
	var worn := 0
	var lights := 0
	for n in a.find_children("*", "", true, false):
		if n is GeometryInstance3D and (n as GeometryInstance3D).material_override is ShaderMaterial:
			var sh := ((n as GeometryInstance3D).material_override as ShaderMaterial).shader
			if sh != null and sh.resource_path.ends_with("painted.gdshader"):
				worn += 1
		if n is Light3D and (n as Light3D).visible:
			lights += 1
	assert_gt(worn, 100, "the stone wears the painting")
	assert_gt(lights, 5, "the lights stay on")


func test_a_door_gives_its_own_look_back_when_it_opens() -> void:
	Dev.put("painted", "1")
	var a := Arena.new()
	add_child_autofree(a)
	a.build(_stage().sala00_layout, 1, 1406)
	var node := a.get_node("PaintedHall") as PaintedHall
	assert_gt(node._worn.size(), 0, "the shut door wears the painting")
	var door: HallDoor = node._doors[0]
	door.open(0.0)
	node._process(0.0)
	assert_eq(node._worn.size(), 0, "opened: its leaves and its black inside are its own again")
