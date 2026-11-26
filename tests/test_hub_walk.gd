extends GutTest
## QA 2026-11-26: the hero walking the hub (straight lines between every pair of stations, through the stairs) never ends
## outside the floor, inside a building's footprint, or at a height the field does not give.

const YAW := 35.0
const STEP := 0.1


func _walk(a: Arena, from: Vector2, to: Vector2) -> Dictionary:
	var pos := from
	var bad := ""
	var worst_jump := 0.0
	var last_h := HubPlan.ground(pos, YAW)
	for i in 1200:
		var d := to - pos
		if d.length() < 0.15:
			break
		pos = a.resolve(pos + d.normalized() * minf(STEP, d.length()), 0.45)
		if not a.inside(pos, 0.0):
			bad = "outside the floor at %s" % pos
			break
		var loc := HubPlan.to_local(pos, YAW)
		for b in HubPlan.BUILDINGS:
			var r: Vector4 = b[&"rect"]
			if loc.x > r.x + 0.1 and loc.x < r.z - 0.1 and loc.y > r.y + 0.1 and loc.y < r.w - 0.1:
				bad = "inside building %s at %s" % [b[&"id"], loc]
		var h := HubPlan.ground(pos, YAW)
		worst_jump = maxf(worst_jump, absf(h - last_h))
		last_h = h
		if bad != "":
			break
	return {"pos": pos, "bad": bad, "jump": worst_jump, "dist": pos.distance_to(to)}


func test_walking_between_stations() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(HubPlan.layout(YAW))
	var worst := 0.0
	for s in HubPlan.STATIONS:
		for t in HubPlan.STATIONS:
			if s == t:
				continue
			var r := _walk(a, HubPlan.use_point(s, YAW), HubPlan.use_point(t, YAW))
			assert_eq(r.bad, "", "%s -> %s" % [s, t])
			worst = maxf(worst, r.jump)
	assert_lt(worst, HubPlan.TIER_H / HubPlan.STAIR_STEPS + 0.02, "no step taller than a tread")
