extends GutTest
## PT-6 (Daniel, 2026-11-23): in every room the paladin comes in at the bottom of the screen (the south) and the doors
## are in the north: in every arena, event room and guardian's house (and each variant) the way in stands in the south
## third of the floor, every door in the north third, and the way from one to the others exists.

const STAGE := "res://data/stages/catacombs.tres"


func _layouts() -> Array[RoomLayout]:
	var stage: StageDef = load(STAGE)
	var out: Array[RoomLayout] = []
	for l in stage.layouts:
		if l.platform:
			continue
		for v in l.variant_count():
			out.append(l.variant(v))
	out.append(stage.trial_layout)
	out.append(stage.altar_layout)
	return out


func test_the_way_in_is_south_and_the_doors_north() -> void:
	for l in _layouts():
		var box := l.floor.bounds()
		var third := box.size.y / 3.0
		assert_gt(l.hero_spawn.y, box.end.y - third, "%s: the way in in the south third" % l.id)
		assert_true(l.floor.contains(l.hero_spawn, Player.RADIUS), "%s: he comes in on the floor" % l.id)
		assert_lt(l.hero_facing.y, -0.5, "%s: he looks north" % l.id)
		assert_gte(l.exits.size(), 2, "%s has doors" % l.id)
		# the Altar (a chapel with its altar across the north wall) has its two doors on its sides, in the north half
		var limit := box.position.y + (box.size.y * 0.5 if l.id == &"altar" else third)
		for i in l.exits.size():
			var e := l.exits[i]
			assert_lt(e.edge().y, limit, "%s: door %d in the north third" % [l.id, i])
			assert_lt(e.at.y, l.hero_spawn.y - third, "%s: door %d far from the way in, to the north" % [l.id, i])


func test_the_way_in_reaches_every_door() -> void:
	for l in _layouts():
		for n in [1, 2, 3]:
			var a := Arena.new()
			add_child_autofree(a)
			a.build(l, mini(n, l.exits.size()), 1406)
			assert_true(a.nav.walkable(a.start), "%s: walks in on free floor" % l.id)
			for i in a.exits.size():
				assert_true(a.nav.reachable(a.start, a.exits[i]), "%s %d doors: door %d is reached" % [l.id, n, i])


## The Salão (fountain and shop) and the Seal Chamber were already so: he comes in at the south and the way on is north.
func test_the_hall_and_the_seal_chamber() -> void:
	var stage: StageDef = load(STAGE)
	var hall := Arena.new()
	add_child_autofree(hall)
	hall.build(stage.layouts[0], 3, 1406)
	assert_gt(hall.start.y, 0.0, "the hall: he comes in at the south")
	assert_lt(hall.door_pos.y, hall.start.y, "and the doors are north of him")
	var c := stage.boss_layout
	assert_gt(c.hero_spawn.y, c.boss_spawn.y, "the Seal Chamber: he comes in at the south, Morvath is north")
	assert_lt(c.hero_facing.y, -0.5)


## Nobody rises near the way in: every spawn zone of every room starts 7 m and more from where he comes in (the south).
func test_no_spawn_zone_by_the_way_in() -> void:
	for l in _layouts():
		for r in l.spawns:
			var rect := r as Rect2
			var near := Vector2(clampf(l.hero_spawn.x, rect.position.x, rect.end.x), clampf(l.hero_spawn.y, rect.position.y, rect.end.y))
			assert_gte(near.distance_to(l.hero_spawn), 7.0, "%s: a spawn zone %s by the way in" % [l.id, rect])
