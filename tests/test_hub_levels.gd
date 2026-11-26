extends GutTest
## Hub refine round 2 (2026-11-26, docs/reference/hub.md): the hub has two levels joined by stairs. The height field is
## continuous on the floor (no pop between neighbours but the treads' own), the stations of the upper terrace stand on it,
## the lower ones and the garden stay low, and the built room is lifted by it (HubLevels).

const YAW := 35.0
const STEP_TOL := 0.01


func _w(p: Vector2) -> Vector2:
	return HubPlan.to_world(p, YAW)


func test_the_upper_terrace_stations_stand_high_and_the_rest_low() -> void:
	for id: StringName in [HubPlan.SMITH, HubPlan.BOOK, HubPlan.HEROES]:
		assert_eq(HubPlan.height_at(HubPlan.USE[id]), HubPlan.TIER_H, "%s on the upper terrace" % id)
	for id: StringName in [HubPlan.VINE, HubPlan.VENDOR, HubPlan.TREE, HubPlan.PORTAL]:
		assert_eq(HubPlan.height_at(HubPlan.USE[id]), 0.0, "%s on the lower one" % id)
	assert_eq(HubPlan.height_at(HubPlan.ARRIVAL), 0.0, "he arrives low")
	assert_eq(HubPlan.ramp_at(HubPlan.VINE_BED.x * Vector2.RIGHT + Vector2(0.0, 2.0)), 0.0, "the garden's fountain stays low")
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
			# (under the planter between the plaza's flights the floor is never reached: a solid piece stands on it)
			var pb := HubPlan.PLANTER_BOX
			if absf(p.x - pb.x) <= pb.z + 0.3 and absf(p.y - pb.y) <= pb.w + 0.6:
				v += step
				continue
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
	assert_eq(a.ground_at(HubPlan.use_point(HubPlan.HEROES, YAW)), HubPlan.TIER_H)
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
	var stand := look.hero_station
	assert_almost_eq(stand.position.y, HubPlan.HERO_PLINTH + 0.1, 0.01, "the heroes' standards stand on the plinth")
	var post := stand.find_child("post_warrior", false, false) as MeshInstance3D
	assert_not_null(post)
	assert_almost_eq(post.position.y - (HeroStation.PLINTH_TOP + HeroStation.POST.y * 0.5), HubPlan.TIER_H, 0.01, "and the terrace lifts them (a mesh node by its origin)")
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


## Round 3 (2026-11-26): the chasm south of the Videira is a lower plaza reached by two flights; nothing of the old void stays.
func test_the_plaza_is_a_lower_floor_reached_by_its_two_flights() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(HubPlan.layout(YAW))
	var mid := Vector2(-4.5, -15.7)
	assert_true(a.nav.walkable(_w(mid)), "the plaza's middle is floor")
	assert_eq(HubPlan.height_at(mid), -HubPlan.PLAZA_DROP, "PLAZA_DROP under the lower terrace")
	assert_eq(a.ground_at(_w(mid)), -HubPlan.PLAZA_DROP)
	assert_true(a.nav.reachable(_w(HubPlan.ARRIVAL), _w(mid)), "on foot, from the arrival")
	for f in HubPlan.PLAZA_FLIGHTS:
		var uc := (f.x + f.z) * 0.5
		assert_eq(HubPlan.height_at(Vector2(uc, f.w + 0.2)), 0.0, "the head of a flight is the terrace")
		assert_eq(HubPlan.height_at(Vector2(uc, f.y - 0.2)), -HubPlan.PLAZA_DROP, "its foot is the plaza")
		assert_true(a.nav.walkable(_w(Vector2(uc, (f.y + f.w) * 0.5))), "the flight is floor")
	# the slit keeps the corridors and the Portão's way apart from it: no floor between, and the way is not lowered
	assert_false(a.nav.walkable(_w(Vector2(-12.0, -14.0))), "a slit of void by the corridor")
	assert_eq(HubPlan.height_at(Vector2(4.5, -12.0)), 0.0, "the way to the Portão stays at the terrace")
	assert_eq(HubPlan.height_at(Vector2(-14.0, -14.0)), 0.0, "and the corridor of the first future door")
	var l := HubPlan.layout(YAW)
	for b: Vector4 in [HubPlan.PLANTER_BOX, HubPlan.PLAZA_BED]:
		assert_true(l.floor.covers(_w(Vector2(b.x, b.y))), "the bed and the planter stand on floor")
