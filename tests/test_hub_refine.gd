extends GutTest
## Hub refine round 1 (2026-11-26): what the refinement leans on stays true (docs/reference/hub.md): the pointed panel is the
## portal's own curve, the faces' reserved rects sit on south walls, the way's glow is laid on floor, the garden takes the
## big basin, and the hub builds with its new pieces (lanterns, fountain light, cliffs' rock).


func _on_floor(p: Vector2) -> bool:
	var inside := false
	for poly in HubPlan.floor_polys():
		if Geometry2D.is_point_in_polygon(p, poly):
			inside = true
	if not inside:
		return false
	for w in HubPlan.water():
		if Geometry2D.is_point_in_polygon(p, w):
			return false
	return true


func test_the_pointed_panel_has_the_gates_height_and_width() -> void:
	var mesh := HubFacades.ogive_mesh(HubBlockout.GATE_W, HubBlockout.GATE_SPRING, HubBlockout.gate_arc(), [], 10)
	var box := mesh.get_aabb()
	assert_almost_eq(box.size.y, HubBlockout.gate_apex(), 0.05, "apex at the gate's height (the portal's proportions)")
	assert_almost_eq(box.size.x, HubBlockout.GATE_W, 0.01, "as wide as the opening")


func test_the_faces_reserve_rects_on_the_south_walls_of_their_buildings() -> void:
	var rects := HubFacades.reserved()
	assert_gt(rects.size(), 2, "glass, glass, glasshouse")
	var in_building := 0
	for r in rects:
		for b in HubPlan.BUILDINGS:
			var br: Vector4 = b[&"rect"]
			if absf(r.position.y + r.size.y * 0.5 - br.y) < 1.6 and r.get_center().x > br.x - 1.0 and r.get_center().x < br.z + 1.0:
				in_building += 1
				break
	assert_gte(in_building, rects.size() - 1, "all but the glasshouse (against the Alquimista's wall) stand at a face")


func test_the_ways_glow_lies_on_floor_on_both_sides() -> void:
	for line: Array[Vector2] in [HubScenery.PATH_MAIN, HubScenery.PATH_GATE]:
		for i in line.size() - 1:
			var a := line[i]
			var b := line[i + 1]
			var side := Vector2(-(b - a).normalized().y, (b - a).normalized().x) * HubScenery.PATH_WIDTH * 0.5
			for t in [0.0, 0.5, 1.0]:
				var p := a.lerp(b, t)
				assert_true(_on_floor(p) and _on_floor(p + side) and _on_floor(p - side), "the glow at %s is on the floor" % p)


func test_the_videira_stands_alone_in_the_open_plaza() -> void:
	var bed := Vector2(HubPlan.VINE_BED.x, HubPlan.VINE_BED.y)
	assert_true(_on_floor(bed), "the Videira's bed stands on floor, in the old garden basin")
	assert_true(Geometry2D.is_point_in_polygon(bed, PackedVector2Array(HubPlan.GARDEN)), "at the open plaza's centre")


func test_the_hub_builds_with_its_rock_lanterns_and_lights() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := Arena.new()
	add_child_autofree(a)
	a.build(HubPlan.layout())
	var lanterns := a.find_children("Lanterns", "MultiMeshInstance3D", true, false)
	assert_eq(lanterns.size(), 1, "one MultiMesh for every lantern")
	assert_gt((lanterns[0] as MultiMeshInstance3D).multimesh.instance_count, 20, "the rails' and the doors' lanterns")
	var cliffs := 0
	for n in a.find_children("*", "MeshInstance3D", true, false):
		var sm := (n as MeshInstance3D).material_override as ShaderMaterial
		if sm != null and sm.shader == HubLook.CLIFF_SHADER:
			cliffs += 1
	assert_gt(cliffs, 0, "the cliffs are the mountain's rock")
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func test_the_pointed_panel_faces_the_camera() -> void:
	# Godot draws the clockwise side: seen from +z (the camera, south) the first triangle must wind clockwise, or the leaf of
	# a door is culled and the doorway shows black (round 4)
	var arrays := HubFacades.ogive_mesh(2.0, 1.0, 0.8).surface_get_arrays(0)
	var v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var cross := (v[1] - v[0]).cross(v[2] - v[0])
	assert_lt(cross.z, 0.0, "clockwise from +z")


func test_the_gate_facade_stands_on_its_footprint_clear_of_the_use_point() -> void:
	var g := HubPlan.GATE
	var wall := HubBlockout.GATE_WALL_U
	assert_gte(wall.x, g.x + 0.4, "the wall keeps off the west edge where the hero stands")
	assert_lte(wall.y, g.z, "and ends at the footprint's east edge")
	assert_gte(HubBlockout.GATE_FRONT, g.y, "its face is inside the footprint's south edge")
	assert_lte(HubBlockout.GATE_FRONT + HubBlockout.GATE_DEPTH, g.w, "and its back inside the north one")
	assert_lt(HubBlockout.GATE_TOP, HubPlan.GATE_HEIGHT, "lower than the solid box (the camera sees past it)")


func test_no_fall_hangs_in_a_trench_or_pit_of_the_floor() -> void:
	var s := HubScenery.new(null)
	# the 1.5 m trench between the Dons' court (south edge v -9) and the bridge deck (v -10.5) is not open void
	assert_false(s._open_void(Vector2(15.0, -9.05), Vector2(0.0, -1.0)), "a trench is not a place for a fall")
	# the bridge's south face and the Portão's cliff are
	assert_true(s._open_void(Vector2(16.4, -15.7), Vector2(0.0, -1.0)), "under the bridge the drop is open")
	var drawn := 0
	for e in s._edge_points(1.5, 0.05, 0.0, false, true):
		var normal: Vector2 = e[1]
		if normal.y <= -0.95 and e[0].y >= -16.0 and s._open_void(e[0], normal):
			drawn += 1
	gut.p("south edge points open to the void: %d" % drawn)
	assert_gt(drawn, 3, "enough open edge for the extra falls")
