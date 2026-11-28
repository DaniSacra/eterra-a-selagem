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
	# Every room of the stage is painted since lote 5 (2026-11-27): a made-up layout stands for a room with no plate.
	var bare := RoomLayout.new()
	bare.id = &"unpainted"
	a.layout = bare
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


func test_the_doors_keep_their_own_look_and_the_hazards_and_candles_stay_3d() -> void:
	Dev.put("painted", "1")
	var a := Arena.new()
	add_child_autofree(a)
	a.build(_stage().sala00_layout, 1, 1406)
	var node := a.get_node("PaintedHall") as PaintedHall
	assert_gt(node._doors.size(), 0)
	for d in node._doors:
		for g in d.find_children("*", "GeometryInstance3D", true, false):
			assert_false(_wears_painting(g), "a door's leaves are the game's own")
	var kept := 0
	for n in a.find_children("*", "Node3D", true, false):
		if n.get_meta(PaintedHall.KEEP_3D, false):
			kept += 1
			for g in n.find_children("*", "GeometryInstance3D", true, false):
				assert_false(_wears_painting(g), "a marked piece (the altar candles) is not dressed")
	assert_gte(kept, 2, "the altar's burnt-out and lit candles")
	var ante := Arena.new()
	add_child_autofree(ante)
	ante.build(_stage().ante_layout, 1, 1406)
	for g in ante.find_children("*", "GeometryInstance3D", true, false):
		if _under(g, HazardPiece):
			assert_false(_wears_painting(g), "the spike slab is the game's own")


func test_a_painted_room_with_a_hazard_is_painted_too() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.layout = _stage().ante_layout
	assert_not_null(a.layout.hazard)
	assert_true(PaintedHall.wanted(a), "the hazard is 3D on a clean plate")


func test_rooms_are_keyed_by_layout_and_variant() -> void:
	var l := _stage().layouts[0]
	assert_eq(PaintedHall.key_of(l), &"hall")
	assert_eq(PaintedHall.key_of(null), &"")
	var v := RoomLayout.new()
	v.id = &"unpainted"
	v.variant_index = 1
	assert_eq(PaintedHall.key_of(v), &"", "no entry: not painted")
	v.id = &"crypt"
	var table := {&"crypt": {}, &"crypt:1": {}}
	assert_eq(PaintedHall.key_of(v, table), &"crypt:1", "a variant with its own entry")
	v.variant_index = 2
	assert_eq(PaintedHall.key_of(v, table), &"crypt", "another variant uses its layout's")
	for id: StringName in PaintedHall.ROOMS:
		var vs: float = PaintedHall.pose_of(id)[&"v_span"]
		assert_true(vs == PaintedHall.STRETCH or vs == PaintedHall.UNIFORM, "%s: a known mapping" % id)


func _wears_painting(g: Node) -> bool:
	var m := (g as GeometryInstance3D).material_override as ShaderMaterial
	return m != null and m.shader != null and m.shader.resource_path == PaintedHall.SHADER


func _under(n: Node, cls: Variant) -> bool:
	var p := n.get_parent()
	while p != null:
		if is_instance_of(p, cls):
			return true
		p = p.get_parent()
	return false


## Lote 4: every layout of the stage that has a game plate resolves to its own entry (variants 0 and 1 of the crypt, rift,
## garden, sanctuary and bridge; the Knight's and the Elder's halls, the Provacao and the altar), and no entry is orphaned.
func test_lote4_rooms_resolve_to_their_entries() -> void:
	var st := _stage()
	var layouts: Array[RoomLayout] = []
	layouts.assign(st.layouts)
	for l: RoomLayout in [st.altar_layout, st.boss_layout]:
		if l != null:
			layouts.append(l)
	var seen := {}
	for l in layouts:
		for n in l.variant_count():
			var k := PaintedHall.key_of(l.variant(n))
			if k != &"":
				seen[k] = true
	for k: StringName in PaintedHall.ROOMS:
		if k in [&"hall", &"sala00", &"ante"]:
			continue
		assert_true(seen.has(k) or k == &"trial" or k == &"knight_hall" or k == &"elder_hall", "%s: some layout of the stage uses it" % k)
	for k: StringName in [&"crypt:0", &"crypt:1", &"rift:0", &"rift:1", &"garden:0", &"garden:1", &"sanctuary:0", &"sanctuary:1", &"bridge:0", &"bridge:1", &"altar"]:
		assert_true(seen.has(k), "%s resolves" % k)


## PT28-2: every painted room's exit stands closed behind real leaves (not just a dark hole), they stay the game's own over
## the plate, and clearing the room opens the one of the exit he takes.
func test_every_painted_exit_has_closed_leaves_that_open() -> void:
	Dev.put("painted", "1")
	var st := _stage()
	for l: RoomLayout in st.layouts:
		for v in l.variant_count():
			var lv := l.variant(v)
			# (the bridge's exits are stairs going down over the abyss, no doorway to close)
			if PaintedHall.key_of(lv) == &"" or lv.id == &"bridge":
				continue
			var a := Arena.new()
			add_child_autofree(a)
			a.build(lv, 2, 1406)
			var doors := a.find_children("*", "HallDoor", true, false)
			assert_gt(doors.size(), 0, "%s %d: the exit has leaves" % [lv.id, v])
			for d in doors:
				assert_false((d as HallDoor).is_open, "closed in the fight")
				for g in d.find_children("*", "GeometryInstance3D", true, false):
					assert_false(_wears_painting(g), "the leaves are the game's own over the plate")
			a.open_exit(0)
			var open := 0
			for d in doors:
				if (d as HallDoor).is_open:
					open += 1
			assert_eq(open, 1, "%s %d: exactly the door taken opens" % [lv.id, v])
