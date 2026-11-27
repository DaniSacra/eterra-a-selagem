extends GutTest
## GP-8 refinement (2026-11-27): what the painting has is shown once (water, the flames the painting lacks), and the gameplay
## data sits where the painting draws it (the stream, the slab, the pillars and posts of the two prologue rooms).

const STAGE := "res://data/stages/catacombs.tres"


func before_each() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)


func after_each() -> void:
	Dev.drop("painted")
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func _stage() -> StageDef:
	return load(STAGE) as StageDef


func _build(layout: RoomLayout, painted: bool, exits := 1) -> Arena:
	Dev.put("painted", "1" if painted else "off")
	var a := Arena.new()
	add_child_autofree(a)
	a.build(layout, exits, 1406)
	if not a.gaps.is_empty():
		# what Rooms does after a build: the stream, dressed by the painting when there is one
		var stream := GapFloor.new(a.gaps)
		a.add_child(stream)
		var node := a.get_node_or_null("PaintedHall") as PaintedHall
		if node != null:
			node.dress_late(stream)
	return a


func _near(n: Node, at: Vector2, r: float) -> bool:
	var w := (n as Node3D).global_position
	return Vector2(w.x, w.z).distance_to(at) <= r


func test_the_hall_hides_the_brazier_the_painting_lacks_and_keeps_the_aligned_ones() -> void:
	var at := Vector2(17.0, -14.8)
	var painted := _build(_stage().layouts[0], true, 2)
	var bare := _build(_stage().layouts[0], false, 2)
	for kind: Variant in [CPUParticles3D, OmniLight3D]:
		var hidden := 0
		var shown_bare := 0
		for n in painted.find_children("*", "", true, false):
			if is_instance_of(n, kind) and _near(n, at, 0.8) and not (n as Node3D).visible:
				hidden += 1
		for n in bare.find_children("*", "", true, false):
			if is_instance_of(n, kind) and _near(n, at, 0.8) and (n as Node3D).visible:
				shown_bare += 1
		assert_gt(hidden, 0, "the east pier's bowl is hidden under the painting")
		assert_eq(hidden, shown_bare, "--painted=off keeps all of them")
	var kept := 0
	for n in painted.find_children("*", "CPUParticles3D", true, false):
		var y := (n as Node3D).global_position.y
		if (n as Node3D).visible and y > 0.0 and y < 3.0:
			kept += 1
	assert_gte(kept, 12, "the braziers that fall on their painted flames keep burning (4 bowls, 3 layers)")


func test_the_painted_rooms_hide_their_3d_water() -> void:
	for layout: RoomLayout in [_stage().ante_layout, _stage().layouts[0]]:
		var a := _build(layout, true)
		var water := 0
		for n in a.find_children("*", "GeometryInstance3D", true, false):
			var g := n as GeometryInstance3D
			if g.material_override is ShaderMaterial and (g.material_override as ShaderMaterial).shader.resource_path.contains("shallow_water") \
					and g.is_visible_in_tree():
				water += 1
		assert_eq(water, 0, "%s: the painting has the water, no second one over it" % layout.id)
	var bare := _build(_stage().ante_layout, false)
	var kept := 0
	for n in bare.find_children("*", "GeometryInstance3D", true, false):
		var g := n as GeometryInstance3D
		if g.material_override is ShaderMaterial and (g.material_override as ShaderMaterial).shader.resource_path.contains("shallow_water"):
			kept += 1
	assert_gt(kept, 0, "--painted=off keeps the stream's water")


func test_the_antessala_stream_and_slab_sit_where_the_painting_draws_them() -> void:
	var l := _stage().ante_layout
	# measured on the painting (PaintedHall.to_floor over its corners): stream z -10.6 to -8.2, slab x -2.6 to 2.5, z -21.4 to -16.9
	assert_almost_eq(l.gaps[0].position.y, -10.6, 0.2)
	assert_almost_eq(l.gaps[0].end.y, -8.2, 0.2)
	var slab: Rect2 = l.hazard.plates[0]
	assert_almost_eq(slab.position.x, -2.6, 0.2)
	assert_almost_eq(slab.end.x, 2.5, 0.2)
	assert_almost_eq(slab.position.y, -21.4, 0.2)
	assert_almost_eq(slab.end.y, -16.9, 0.2)
	# the red warning is the plate's own rectangle: its north corner lands on the painted slab's (px of the 1536 x 1024 file)
	var uv := PaintedHall.to_uv(PaintedHall.pose_of(&"ante"), Vector3(slab.position.x, 0.0, slab.position.y))
	assert_lt((uv * Vector2(1536, 1024)).distance_to(Vector2(998.75, 275.0)), 20.0, "the plate's north corner is the painted one")


func test_the_pillars_of_the_sala00_and_the_posts_of_the_antessala_stand_on_the_painted_ones() -> void:
	var pillars: Array[Vector2] = []
	for o in _stage().sala00_layout.obstacles:
		if o.piece != &"altar":
			pillars.append(o.center)
	var painted: Array[Vector2] = [Vector2(-5.06, -5.16), Vector2(5.33, -5.49), Vector2(-5.48, 2.85), Vector2(5.10, 2.83)]
	assert_eq(pillars.size(), 4)
	for want in painted:
		assert_true(pillars.any(func(c: Vector2) -> bool: return c.distance_to(want) < 0.4), "a pillar by %s" % want)
	var posts: Array[Vector2] = []
	for o in _stage().ante_layout.obstacles:
		posts.append(o.center)
	assert_eq(posts.size(), 8)
	for z: float in [16.65, 2.15, -15.7]:
		assert_eq(posts.filter(func(c: Vector2) -> bool: return absf(c.y - z) < 0.5).size(), 2, "a pair of posts by z %s" % z)
