extends GutTest
## PT-25-9 in the common rooms: the optional crossings (a patch of floor ringed by water or rift that only the dash gets
## on, with breakables for the reward) and the enemies against them (NavGrid shuts them, Arena.keep_out_of_gaps holds a
## walker back). Rooms: the Santuário (A, B, C) and the Fendas (A, B).

var stage: StageDef = load("res://data/stages/catacombs.tres")


func _base(id: StringName) -> RoomLayout:
	for l: RoomLayout in stage.layouts:
		if l.id == id:
			return l
	return null


func _arena(l: RoomLayout) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(l, 3, 1406)
	return a


## The island of the grid the floor point p stands on (-1: no free cell there).
func _isle(g: NavGrid, p: Vector2) -> int:
	var i := g.cell_at(p)
	return g.island[i] if i >= 0 and g.free[i] == 1 else -1


func test_the_grid_shuts_a_gap_and_the_dash_grid_leaves_it_open() -> void:
	var floor := FloorShape.poly([PackedVector2Array([Vector2(-10, -5), Vector2(10, -5), Vector2(10, 5), Vector2(-10, 5)])])
	var bounds := Rect2(-11, -6, 22, 12)
	var open := NavGrid.build(bounds, floor)
	var gap: Array[Rect2] = [Rect2(-1.0, -5.0, 2.0, 10.0)]
	var shut := NavGrid.build(bounds, floor, [], 0.0, [], NavGrid.CLEARANCE, NavGrid.CELL, gap)
	assert_true(open.reachable(Vector2(-6, 0), Vector2(6, 0)))
	assert_ne(_isle(shut, Vector2(-6, 0)), _isle(shut, Vector2(6, 0)), "a gap wall to wall splits the floor")
	assert_false(shut.walkable(Vector2(0, 0)), "nobody walks in it")
	assert_false(shut.clear_line(Vector2(-6, 0), Vector2(6, 0)), "and the straight way is not clear")


func test_a_walker_is_held_on_the_bank_it_came_from() -> void:
	var a := _arena(_base(&"sanctuary"))
	var r: Rect2 = a.gaps[0]
	var from := Vector2(r.get_center().x, r.position.y - 0.4)
	var to := Vector2(r.get_center().x, r.get_center().y)
	assert_lt(a.keep_out_of_gaps(from, to).y, r.position.y, "an enemy pushed or walking in stays out")


func test_the_patches_are_for_the_dash_alone() -> void:
	for id: StringName in [&"sanctuary", &"rift"]:
		var base := _base(id)
		assert_false(base.gaps.is_empty(), "%s has its crossing" % id)
		for v in base.variant_count():
			var l := base.variant(v)
			var a := _arena(l)
			var name := "%s %d" % [id, v]
			assert_ne(a.nav_dash, a.nav, "%s: two grids" % name)
			var hero := _isle(a.nav, l.hero_spawn)
			assert_gte(hero, 0, "%s: he stands on floor" % name)
			var on_patch := 0
			var ring := l.gaps[0]
			for r in l.gaps:
				ring = ring.merge(r)
			for p in l.breakables:
				assert_lt(GapRule.inside(l.gaps, p.at), 0, "%s: a breakable in the water at %s" % [name, p.at])
				if ring.has_point(p.at):
					on_patch += 1
					assert_false(a.nav.reachable(p.at, l.hero_spawn) and _isle(a.nav, p.at) == hero, "%s: %s is shut off on foot" % [name, p.at])
					assert_true(a.nav_dash.reachable(p.at, l.hero_spawn), "%s: the dash grid reaches %s" % [name, p.at])
			assert_gte(on_patch, 2, "%s: a group of 2 or more is the reward on the patch" % name)
			# every door is on his island, so the crossing is never needed
			for e in l.exits:
				assert_true(a.nav.reachable(e.mouth.get_center(), l.hero_spawn), "%s: a door on his island" % name)
			assert_eq(_isle(a.nav, a.middle), hero, "%s: the reward rises on his island" % name)
			for r in l.spawns + l.late_spawns:
				assert_true(a.nav.reachable(r.get_center(), l.hero_spawn), "%s: nobody rises on the patch" % name)


func test_the_gaps_are_narrow_and_off_everything_that_matters() -> void:
	for id: StringName in [&"sanctuary", &"rift"]:
		var base := _base(id)
		for v in base.variant_count():
			var l := base.variant(v)
			for r in l.gaps:
				var tag := "%s %d %s" % [id, v, r]
				assert_between(minf(r.size.x, r.size.y), 2.0, 4.0, "%s: 2 to 4 m across" % tag)
				assert_gte(l.hero_spawn.distance_to(r.get_center()) - r.size.length() * 0.5, 6.0, "%s: off the way in" % tag)
				for e in l.exits:
					assert_false(e.mouth.grow(2.0).intersects(r), "%s: off the doors" % tag)
				for s in l.spawns + l.late_spawns:
					assert_false(s.grow(1.0).intersects(r), "%s: off the spawns" % tag)
				if l.hazard != null:
					for p in l.hazard.plates:
						assert_false(p.grow(1.5).intersects(r), "%s: off the slabs" % tag)
				for o in l.obstacles:
					if o.blocks_move:
						assert_lt(o.depth(r.get_center(), 0.0), 0.0, "%s: no piece on its middle" % tag)
