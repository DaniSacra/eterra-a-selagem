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


func test_the_pointed_panel_has_the_portals_height_and_width() -> void:
	var mesh := HubFacades.ogive_mesh(HubBlockout.GATE_W, HubBlockout.GATE_SPRING, HubLook._portal_arc(), [], 10)
	var box := mesh.get_aabb()
	assert_almost_eq(box.size.y, HubLook.PORTAL_H, 0.05, "apex at the portal's height")
	assert_almost_eq(box.size.x, HubBlockout.GATE_W, 0.01, "as wide as the opening")


func test_the_faces_reserve_rects_on_the_south_walls_of_their_buildings() -> void:
	var rects := HubFacades.reserved()
	assert_gt(rects.size(), 4, "arch, banners, glass, glasshouse")
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


func test_the_garden_takes_the_big_basin_and_the_fountain_the_vines_bed() -> void:
	var basins := HubPlan.water()
	var areas: Array[float] = []
	for b in basins:
		var a := 0.0
		for i in b.size():
			a += b[i].cross(b[(i + 1) % b.size()])
		areas.append(absf(a) * 0.5)
	assert_eq(areas.find(areas.max()), HubScenery.GARDEN_BASIN, "the garden fills the biggest basin")
	var bed := Vector2(HubPlan.VINE_BED.x, HubPlan.VINE_BED.y)
	assert_true(_on_floor(bed), "the fountain stands on floor (the Videira's bed)")


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
