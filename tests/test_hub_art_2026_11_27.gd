extends GutTest
## Hub art of 2026-11-27 (the PO's new approval, docs/art/painted_gpt/hub/): the Videira alone in the middle (no pavilion), the Portao
## da Aventura at the top of the main axis up the red carpet's flight, a round Mirante where it stood, the Ponto de Vigilia
## without any fire, the Aposento dos Herois off.

const YAW := 35.0


func _w(p: Vector2) -> Vector2:
	return HubPlan.to_world(p, YAW)


func _built() -> HubLook:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := Arena.new()
	add_child_autofree(a)
	a.build(HubPlan.layout())
	return a.look as HubLook


func test_the_portao_stands_at_the_top_of_the_main_axis_and_its_use_point_is_at_the_foot_of_the_carpet() -> void:
	var g := HubPlan.GATE
	assert_gt(g.y, 20.0, "the north end of the plan")
	assert_lt(g.x, HubPlan.PORTAL_TOP.x)
	assert_gt(g.z, HubPlan.PORTAL_TOP.x)
	assert_almost_eq(HubPlan.GATE_STEPS.x, HubPlan.USE[HubPlan.PORTAL].x, 0.01, "the flight and the use point share the axis")
	assert_lt(HubPlan.USE[HubPlan.PORTAL].y, HubPlan.GATE_STEPS.y - HubPlan.GATE_STEPS_HALF.y, "the hero stands before the flight")
	assert_almost_eq(HubPlan.GATE_STEPS.y + HubPlan.GATE_STEPS_HALF.y, g.y, 0.01, "the flight climbs to the terrace")
	assert_almost_eq(HubBlockout.GATE_TERRACE, HubPlan.GATE_TERRACE, 0.001, "the stair rises to what the terrace is drawn at")
	var l := HubPlan.layout(YAW)
	assert_true(l.floor.contains(HubPlan.use_point(HubPlan.PORTAL, YAW), Player.RADIUS))
	var a := Arena.new()
	add_child_autofree(a)
	a.build(l)
	assert_true(a.nav.reachable(_w(HubPlan.ARRIVAL), HubPlan.use_point(HubPlan.PORTAL, YAW)), "reached on foot from the arrival")


func test_the_old_gate_place_is_a_round_mirante_with_no_station() -> void:
	var m := HubPlan.MIRADOR
	var l := HubPlan.layout(YAW)
	assert_true(l.floor.covers(_w(Vector2(m.x, m.y))), "the middle is floor")
	assert_true(l.floor.covers(_w(Vector2(m.x + m.z * 0.9, m.y))), "the east end is floor")
	assert_false(l.floor.covers(_w(Vector2(m.x + m.z * 0.9, m.y + m.z * 0.9))), "a round end: the square's corner is gone")
	for id in HubPlan.STATIONS:
		assert_gt(HubPlan.USE[id].distance_to(Vector2(m.x, m.y)), m.z, "no station on the Mirante (%s)" % id)
	assert_eq(l.obstacles.filter(func(o: ArenaObstacle) -> bool: return o.piece == &"hub_bench").size(), HubPlan.MIRADOR_BENCHES.size(), "benches block")
	var a := Arena.new()
	add_child_autofree(a)
	a.build(l)
	assert_true(a.nav.reachable(_w(HubPlan.ARRIVAL), _w(Vector2(m.x, m.y))), "and it is reached on foot")


func test_the_videira_is_a_planter_with_a_tree_and_no_pavilion() -> void:
	var l := HubPlan.layout(YAW)
	var bed: ArenaObstacle
	for o in l.obstacles:
		if o.piece == &"hub_bed":
			bed = o
	assert_not_null(bed)
	assert_eq(bed.shape, ArenaObstacle.Shape.CIRCLE, "a round planter")
	assert_almost_eq(bed.radius, HubPlan.VINE_BED.z, 0.001)
	var look := _built()
	assert_not_null(look.find_child("VineCrown", true, false), "the great tree's crown")
	assert_null(look.find_child("PergolaRoof", true, false), "the pavilion's roof is gone")
	assert_not_null(look.vine_station, "the Videira's station (the vase and its vine) stays")


func test_the_ponto_de_vigilia_has_no_fire() -> void:
	var look := _built()
	var at := HubPlan.VIGIL_LANDING
	var centre := Vector2(at.x, at.y)
	var near := 0
	for n in look.find_children("*", "OmniLight3D", true, false):
		var l := n as OmniLight3D
		var p := HubPlan.to_local(Vector2(l.global_position.x, l.global_position.z))
		if p.distance_to(centre) < at.z + 3.0:
			near += 1
			assert_true(l.has_meta(ArenaKit.NOT_FIRE), "a light by the landing is a lamp, never a flame")
	assert_gt(near, 0, "but the landing is lit")
	assert_true(HubPlan.ARRIVAL.distance_to(centre) < at.z, "the hero appears on the landing")
