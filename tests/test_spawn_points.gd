extends GutTest
## RD2-02: no enemy rises inside stone. In every arena (every variant, early and late zones) the spawn point drawn
## many times is never inside a pillar, a box or a turned piece, and always on the walk.

const STAGE := "res://data/stages/catacombs.tres"
const DRAWS := 40


func test_no_spawn_point_inside_collision_in_any_arena() -> void:
	var stage: StageDef = load(STAGE)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var bad: Array[String] = []
	var layouts: Array[RoomLayout] = stage.layouts.duplicate()
	for l in layouts:
		for v in l.variant_count():
			var a := Arena.new()
			add_child_autofree(a)
			a.build(l.variant(v), 2, 1406)
			var hero := a.resolve(Vector2(0.0, a.half.y - 3.0), 0.6)
			for late in [false, true]:
				for i in DRAWS:
					var at := Rooms.spawn_point(a, hero, rng, late)
					if a.overlaps(at, 0.6) or not a.nav.walkable(at):
						bad.append("%s v%d late %s at %s" % [l.id, v, late, at])
						break
	assert_eq(bad, [], "spawn points in stone")


func test_elder_columns_leave_the_boss_in_view() -> void:
	# RD2-01: no column stands on the line from the south camera to the boss at (0, -7): none within 6 m of the axis
	# between the boss and the north wall's middle
	var stage: StageDef = load(STAGE)
	var hidden: Array[Vector2] = []
	for l in stage.layouts:
		if l.id != &"elder_hall":
			continue
		for o in l.obstacles:
			if o.piece == &"column" and o.center.y < -3.0 and o.center.y > -9.0 and absf(o.center.x) < 6.0:
				hidden.append(o.center)
	assert_eq(hidden, [], "columns hiding the boss")
