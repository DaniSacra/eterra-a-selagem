extends GutTest
## Safety net for the room's shape while its look changes: builds the real catacomb hall (headless) for every room
## kind of the stage and checks what play needs, whatever the art: the paladin walks in on free floor, can walk to
## every door (a grid search over the real collision, Arena.resolve), each door's zone takes him out, the middle of
## the room stays clear for the fight, and enemies and Morvath rise on free floor he can reach.

const STAGE := "res://data/stages/catacombs.tres"
## Meters between two cells of the walking grid (smaller than the paladin's radius, so no gap is skipped).
const CELL := 0.25
## The grid covers this square around the middle of the room (the hall, its landing and the doors' zones).
const REACH := 26.0
## The free middle of the room: the room's rectangle less this many meters on each side.
const CLEAR_MARGIN := 4.0
## A point is free when resolve moves it less than this.
const EPS := 0.01
const SEED := 1406

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


## The hall as Rooms builds it: a layout of the stage and this many doors.
func _arena(layout: RoomLayout, exits: int, seed_: int = SEED) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(layout, exits, seed_)
	return a


## Every room shape the run can build, with the doors it can have (Rooms: 0 for Morvath, 1 to 3 otherwise).
func _cases() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for l in stage.layouts:
		for n in [1, 2, 3]:
			out.append({"layout": l, "exits": n, "name": "room %d doors" % n})
	out.append({"layout": stage.shop_layout, "exits": 2, "name": "shop"})
	out.append({"layout": stage.boss_layout, "exits": 0, "name": "boss"})
	return out


func _free(a: Arena, p: Vector2, radius: float = Player.RADIUS) -> bool:
	return a.resolve(p, radius).distance_to(p) < EPS


func _key(p: Vector2) -> Vector2i:
	return Vector2i(roundi(p.x / CELL), roundi(p.y / CELL))


func _point(k: Vector2i) -> Vector2:
	return Vector2(k) * CELL


## Grid cells the paladin can reach from `from` walking (4-neighbour steps between free cells).
func _reachable(a: Arena, from: Vector2, radius: float = Player.RADIUS) -> Dictionary:
	var seen := {}
	var start := _key(a.resolve(from, radius))
	if not _free(a, _point(start), radius):
		start = _key(a.resolve(_point(start), radius))
	seen[start] = true
	var todo: Array[Vector2i] = [start]
	var lim := roundi(REACH / CELL)
	while not todo.is_empty():
		var k: Vector2i = todo.pop_back()
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n := k + d
			if seen.has(n) or absi(n.x) > lim or absi(n.y) > lim:
				continue
			if _free(a, _point(n), radius):
				seen[n] = true
				todo.append(n)
	return seen


## The reachable cell nearest p is within one cell of it.
func _reached(cells: Dictionary, p: Vector2) -> bool:
	var k := _key(p)
	for dx in [-1, 0, 1]:
		for dz in [-1, 0, 1]:
			if cells.has(k + Vector2i(dx, dz)):
				return true
	return false


func test_stage_rooms_are_the_catacomb_hall() -> void:
	assert_false(stage.layouts.is_empty(), "the stage has room layouts")
	for c in _cases():
		assert_not_null(c.layout, "%s has a layout" % c.name)


func test_hero_walks_in_on_free_floor() -> void:
	for c in _cases():
		var a := _arena(c.layout, c.exits)
		assert_true(_free(a, a.start), "%s: the way in %s is free" % [c.name, a.start])
		assert_true(a.on_floor(a.start, Player.RADIUS), "%s: the way in is on the floor" % c.name)
		assert_eq(a.exit_at(a.start), -1, "%s: walking in never leaves at once" % c.name)
		assert_almost_eq(a.start_facing.length(), 1.0, 0.01, "%s: he faces a direction" % c.name)
		# a few steps the way he faces are free too (he does not walk in against a wall)
		assert_true(_free(a, a.start + a.start_facing * 2.0), "%s: free ahead of the way in" % c.name)


func test_doors_match_the_rooms() -> void:
	for c in _cases():
		var a := _arena(c.layout, c.exits)
		assert_eq(a.exits.size(), c.exits, "%s: one door per way on" % c.name)
		assert_eq(a.exit_zones.size(), a.exits.size(), "%s: each door has a zone" % c.name)
		assert_eq(a.exit_inward.size(), a.exits.size(), "%s: each door faces into the room" % c.name)


func test_every_door_is_reachable_and_leaves() -> void:
	for c in _cases():
		var a := _arena(c.layout, c.exits)
		var cells := _reachable(a, a.start)
		assert_gt(cells.size(), 2000, "%s: the paladin has room to walk" % c.name)
		for i in a.exits.size():
			# some reachable floor stands in the door's zone
			var found := false
			for k: Vector2i in cells:
				if a.exit_at(_point(k)) == i:
					found = true
					break
			assert_true(found, "%s: door %d can be reached on foot" % [c.name, i])
			# the bot walks to door_goal: free (or next to free floor) and inside that door's zone
			var goal := a.resolve(a.door_goal(i), Player.RADIUS)
			assert_eq(a.exit_at(goal), i, "%s: door_goal %d leaves by door %d" % [c.name, i, i])
			assert_true(_reached(cells, goal), "%s: door_goal %d is reachable" % [c.name, i])
			# the sign floats in front of the door, over the room's floor
			assert_true(a.on_floor(a.door_label(i), 0.0), "%s: the sign of door %d is over the floor" % [c.name, i])


func test_door_zones_do_not_overlap() -> void:
	var a := _arena(stage.layouts[0], 3)
	for i in a.exit_zones.size():
		for j in range(i + 1, a.exit_zones.size()):
			assert_false(a.exit_zones[i].intersects(a.exit_zones[j]), "doors %d and %d apart" % [i, j])


func test_middle_of_the_room_is_clear() -> void:
	for c in _cases():
		var a := _arena(c.layout, c.exits)
		if a.round_floor():
			# Morvath's chamber (cycle C11): the circle is all there is, nothing stands on it
			assert_true(a.pillars.is_empty() and a.boxes.is_empty() and a.exit_zones.is_empty(), "%s: nothing on the floor" % c.name)
			assert_gt(PI * pow(a.shape().radius - Player.RADIUS, 2.0), 300.0, "%s: a wide floor to fight on" % c.name)
			continue
		if c.layout.id != &"hall":
			# the arenas of cycle C12 fight round their pieces on purpose (tests/test_arenas.gd checks their ways)
			continue
		var mid := Rect2(-a.half + Vector2.ONE * CLEAR_MARGIN, (a.half - Vector2.ONE * CLEAR_MARGIN) * 2.0)
		assert_gt(mid.get_area(), 300.0, "%s: a wide middle to fight in" % c.name)
		for p in a.pillars:
			var nearest := Vector2(p.x, p.y).clamp(mid.position, mid.end)
			assert_gt(nearest.distance_to(Vector2(p.x, p.y)), p.z, "%s: pillar %s out of the middle" % [c.name, p])
		for b in a.boxes:
			assert_false(b.intersects(mid), "%s: solid box %s out of the middle" % [c.name, b])
		# and no door takes the paladin out from the middle of a fight
		for z in a.exit_zones:
			assert_false(z.intersects(mid), "%s: door zone %s out of the middle" % [c.name, z])


func test_resolve_keeps_bodies_on_the_floor() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for c in _cases():
		var a := _arena(c.layout, c.exits)
		var stuck := 0
		var off := 0
		for i in 600:
			var p := Vector2(rng.randf_range(-REACH, REACH), rng.randf_range(-REACH, REACH))
			var q := a.resolve(p, Player.RADIUS)
			if not a.on_floor(q, Player.RADIUS):
				off += 1
			# where resolve puts a body, it stays (no pillar pushing it into a box and back)
			if not _free(a, q):
				stuck += 1
		assert_eq(off, 0, "%s: resolve never leaves a body off the floor" % c.name)
		assert_eq(stuck, 0, "%s: resolve settles at once" % c.name)


func test_enemies_rise_on_free_floor_the_hero_reaches() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var biggest := 0.6
	for id in stage.enemies:
		biggest = maxf(biggest, (load("res://data/enemies/%s.tres" % id) as EnemyDef).radius)
	for c in _cases():
		if c.exits == 0:
			continue
		var a := _arena(c.layout, c.exits)
		var cells := _reachable(a, a.start)
		var h := a.half
		for i in 80:
			# as Rooms._spawn_point draws them (in the arenas' spawn zones, the hall anywhere)
			var at := Vector2(rng.randf_range(-h.x + 2.5, h.x - 2.5), rng.randf_range(-h.y + 2.5, h.y - 2.5))
			if not a.spawns.is_empty():
				at = Rooms.spawn_point(a, a.start, rng, i % 2 == 1)
			var p := a.resolve(at, 0.6)
			assert_true(_free(a, p, 0.6), "%s: spawn %s settles" % [c.name, p])
			assert_true(_free(a, a.resolve(p, biggest), biggest), "%s: the biggest enemy settles near %s" % [c.name, p])
			assert_true(_reached(cells, p), "%s: the paladin can reach the spawn %s" % [c.name, p])
		# the reward rises in the middle (Rooms._room_cleared) and the fountain a little north of it
		var spots: Array[Vector2] = [a.resolve(a.middle, 1.0)]
		if c.layout.fountain:
			spots.append(Vector2(0, -2.0))
		for spot: Vector2 in spots:
			assert_true(_reached(cells, spot), "%s: %s is reachable" % [c.name, spot])


func test_morvath_rises_in_reach() -> void:
	var a := _arena(stage.boss_layout, 0)
	var def: EnemyDef = load("res://data/enemies/%s.tres" % stage.boss)
	# in his round chamber he stands on the seal (Arena.boss_spawn), as Boss.setup puts him
	var at := a.boss_spawn if a.round_floor() else a.door_pos + Vector2(0, Arena.STAIRS_DEPTH + def.radius)
	var p := a.resolve(at, def.radius)
	assert_true(a.on_floor(p, def.radius), "Morvath stands on the floor")
	assert_lt(p.distance_to(at), 1.5, "Morvath rises about where Boss puts him")
	var cells := _reachable(a, a.start)
	assert_true(_reached(cells, a.resolve(p, Player.RADIUS)) or _reached(cells, p + Vector2(0, def.radius + Player.RADIUS)),
		"the paladin can walk up to Morvath")
	var center := a.shape().center if a.round_floor() else a.door_pos + Vector2(0, 14)
	assert_true(a.inside(center), "the middle of Morvath's patterns is inside the room")


func test_push_out_of_box_leaves_by_the_nearest_side() -> void:
	var b := Rect2(0, 0, 4, 2)
	assert_eq(Arena.push_out_of_box(Vector2(2, 1.8), 0.5, b), Vector2(2, 2.5))
	assert_eq(Arena.push_out_of_box(Vector2(0.2, 1), 0.5, b), Vector2(-0.5, 1))
	assert_eq(Arena.push_out_of_box(Vector2(9, 9), 0.5, b), Vector2(9, 9), "far away stays")
	var q := Arena.push_out_of_box(Vector2(4.2, 2.2), 0.5, b)
	assert_almost_eq(q.distance_to(Vector2(4, 2)), 0.5, 0.001, "a corner pushes along its diagonal")


## A bare arena (nothing built) of this size with these blockers.
func _bare(half: Vector2, pillars: Array[Vector3], boxes: Array[Rect2]) -> Arena:
	var a: Arena = autofree(Arena.new())
	a.half = half
	a.pillars = pillars
	a.boxes = boxes
	return a


func test_a_box_at_the_edge_never_pushes_over_it() -> void:
	# the floor ends at x = 10 - 1.2 - 0.5 = 8.3 for the paladin; the box reaches past it
	var a := _bare(Vector2(10, 10), [], [Rect2(7.6, 0, 1.0, 1.0)])
	for p: Vector2 in [Vector2(8.3, 0.5), Vector2(8.2, 0.3), Vector2(9.5, 0.6), Vector2(8.0, 0.9)]:
		var q := a.resolve(p, Player.RADIUS)
		assert_true(a.on_floor(q, Player.RADIUS), "%s -> %s stays on the floor" % [p, q])
		assert_true(_free(a, q), "%s -> %s settles out of the box" % [p, q])


func test_a_pillar_and_a_box_at_the_edge_settle() -> void:
	# the east edge of the hall: a fire bowl and a crate side by side against the floor's edge
	var a := _bare(Vector2(16, 15), [Vector3(14.2, 2.7, 0.6), Vector3(16.0, 2.1, 1.1)], [Rect2(13.59, 4.29, 0.83, 0.83)])
	for p: Vector2 in [Vector2(15.4, 2.9), Vector2(14.3, 4.8), Vector2(20.0, 2.0), Vector2(14.3, 3.5)]:
		var q := a.resolve(p, Player.RADIUS)
		assert_true(a.on_floor(q, Player.RADIUS), "%s -> %s stays on the floor" % [p, q])
		assert_true(_free(a, q), "%s -> %s settles" % [p, q])


## QA B2 (cycle 7): the light the portal spills down the steps is the portal's light, so it turns red with it when
## Morvath's doors open (it stayed green), and is green again in the next hall.
func test_the_portal_spill_follows_the_portal() -> void:
	var a := _arena(stage.layouts[0], 0)
	var kit := a._kit
	assert_false(kit.portal_tinted.get(0, []).is_empty(), "the hall's spill follows the portal")
	var spill: Light3D = kit.portal_tinted[0][0][0]
	assert_eq(spill.light_color, CatacombHall.SPILL_COLOR, "green while the portal is")
	a.open_door()
	assert_eq(spill.light_color, ArenaKit.MORVATH, "red with Morvath's portal")
	kit.light_portal(0, false)
	assert_eq(spill.light_color, CatacombHall.SPILL_COLOR, "its own green back with the portal's")
