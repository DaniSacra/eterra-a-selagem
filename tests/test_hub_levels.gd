extends GutTest
## Hub refine round 2 (2026-11-26, docs/reference/hub.md): the hub has two levels joined by stairs. The height field is
## continuous on the floor (no pop between neighbours but the treads' own), the stations of the upper terrace stand on it,
## the lower ones and the garden stay low, and the built room is lifted by it (HubLevels).

const YAW := 35.0
const STEP_TOL := 0.01


func _w(p: Vector2) -> Vector2:
	return HubPlan.to_world(p, YAW)


func test_the_upper_terrace_stations_stand_high_and_the_rest_low() -> void:
	for id: StringName in [HubPlan.SMITH, HubPlan.BOOK, HubPlan.PORTAL]:
		assert_eq(HubPlan.height_at(HubPlan.USE[id]), HubPlan.TIER_H, "%s on the upper terrace" % id)
	for id: StringName in [HubPlan.VINE, HubPlan.VENDOR, HubPlan.TREE]:
		assert_eq(HubPlan.height_at(HubPlan.USE[id]), 0.0, "%s on the lower one" % id)
	assert_eq(HubPlan.height_at(HubPlan.ARRIVAL), 0.0, "he arrives low")
	assert_eq(HubPlan.ramp_at(Vector2(HubPlan.VINE_BED.x, HubPlan.VINE_BED.y)), 0.0, "the Videira's plaza stays low")
	assert_eq(HubPlan.ramp_at(Vector2(-6.0, 17.5)), HubPlan.TIER_H, "the gallery over the garden is high")


func test_a_flight_is_a_run_of_treads_from_the_lower_to_the_upper_level() -> void:
	for z in HubPlan.STAIRS:
		var mid_u := (z.x + z.z) * 0.5
		assert_eq(HubPlan.height_at(Vector2(mid_u, z.y - 0.1)), 0.0 if z.y - 0.1 < HubPlan.TIER_V else HubPlan.TIER_H, "below the foot")
		assert_almost_eq(HubPlan.height_at(Vector2(mid_u, z.y + 0.01)), HubPlan.TIER_H / HubPlan.STAIR_STEPS, STEP_TOL, "the first tread")
		assert_almost_eq(HubPlan.height_at(Vector2(mid_u, z.w - 0.01)), HubPlan.TIER_H, STEP_TOL, "the last tread is the upper floor")
		assert_almost_eq(HubPlan.ramp_at(Vector2(mid_u, (z.y + z.w) * 0.5)), HubPlan.TIER_H * 0.5, STEP_TOL, "the smooth field is the slope")
		var last := 0.0
		var y := z.y
		while y < z.w:
			var h := HubPlan.height_at(Vector2(mid_u, y))
			assert_gte(h, last - 0.0001, "the treads only go up")
			last = h
			y += 0.05


func test_the_field_has_no_pop_between_neighbours_on_the_floor() -> void:
	var l := HubPlan.layout(YAW)
	var step := 0.25
	var worst := 0.0
	var at := Vector2.ZERO
	var x := -34.0
	while x < 44.0:
		var v := -26.0
		while v < 32.0:
			var p := Vector2(x, v)
			# (the retaining wall's slits and the plaza's wall are not floor: the field jumps only across them)
			if l.floor.covers(_w(p)):
				for q: Vector2 in [p + Vector2(step, 0.0), p + Vector2(0.0, step)]:
					if l.floor.covers(_w(q)):
						var d := absf(HubPlan.height_at(p) - HubPlan.height_at(q))
						if d > worst:
							worst = d
							at = p
			v += step
		x += step
	var tread := HubPlan.TIER_H / HubPlan.STAIR_STEPS
	assert_lt(worst, tread + 0.02, "no step taller than a tread anywhere on the floor (worst %.2f at %s)" % [worst, at])


func test_the_arena_gives_the_feet_their_height() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(HubPlan.layout(YAW))
	assert_eq(a.ground_at(HubPlan.use_point(HubPlan.PORTAL, YAW)), HubPlan.TIER_H)
	assert_eq(a.ground_at(HubPlan.use_point(HubPlan.VINE, YAW)), 0.0)
	var other := Arena.new()
	add_child_autofree(other)
	other.build()
	assert_eq(other.ground_at(Vector2(3.0, 4.0)), 0.0, "every other room is flat")


func test_the_built_hub_is_lifted_where_the_upper_terrace_stands() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := Arena.new()
	add_child_autofree(a)
	a.build(HubPlan.layout())  # (the frame is turned by the camera's yaw: the layout's own)
	var look := a.look as HubLook
	assert_not_null(look)
	var lo := INF
	var hi := -INF
	for n in look.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.material_override == a.look.floor_mat and mi.mesh is ArrayMesh:
			var box := mi.global_transform * mi.get_aabb()
			lo = minf(lo, box.position.y)
			hi = maxf(hi, box.end.y)
	assert_almost_eq(lo, -HubPlan.PLAZA_DROP, 0.05, "the floor's lowest level (the plaza south of the Videira)")
	assert_almost_eq(hi, HubPlan.TIER_H, 0.05, "and its upper")
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func test_the_flight_is_drawn_tread_by_tread() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(HubPlan.layout())
	var tops := 0
	for n in a.look.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh is BoxMesh and absf((mi.mesh as BoxMesh).size.x - (HubPlan.STAIR_A.z - HubPlan.STAIR_A.x)) < 0.001 and (mi.mesh as BoxMesh).size.z < 1.0:
			tops += 1
	assert_gte(tops, HubPlan.STAIR_STEPS, "a block per tread on the Forja's flight")


## PT28-11 step 2: the south yard is plain floor (no sunken plaza, no raised block), and the Videira's plaza is open floor held
## by a retaining wall of slits against the terrace.
func test_the_south_yard_is_flat_open_floor_and_the_plaza_is_held_by_a_wall() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(HubPlan.layout(YAW))
	for p: Vector2 in [Vector2(-4.5, -15.7), Vector2(-5.5, -11.0)]:
		assert_true(a.nav.walkable(_w(p)), "the south yard is floor: %s" % p)
		assert_eq(HubPlan.height_at(p), 0.0)
	assert_true(a.nav.reachable(_w(HubPlan.ARRIVAL), _w(Vector2(-4.5, -15.7))), "on foot, from the arrival")
	for o in HubPlan.layout(YAW).obstacles:
		assert_ne(o.piece, &"hub_planter", "no raised block in the middle")
	assert_gt(HubPlan.garden_walls().size(), 0, "the wall slits")
	assert_true(a.nav.walkable(_w(Vector2(-10.0, 10.0))), "the plaza is walkable")
	assert_false(a.nav.walkable(_w(Vector2(-13.0, 12.0))), "the wall stands on the terrace's edge")
