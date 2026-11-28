extends GutTest
## BG-4: every station's use point is on the hub's walkable floor, in the same island as the arrival (the robot's hub tour
## and the player both reach it), and the hub smoke tour ends with every station reached.

const YAW := 35.0


func test_every_use_point_is_reached_from_the_arrival() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	var l := HubPlan.layout(YAW)
	a.build(l)
	var start := l.hero_spawn
	for id in HubPlan.STATIONS:
		var p := HubPlan.use_point(id, YAW)
		assert_true(a.nav.walkable(p), "%s use point on free floor" % id)
		assert_true(a.nav.reachable(start, p), "%s reached from the arrival" % id)
