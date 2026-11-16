extends GutTest
## The arenas of cycle C12 (docs/design/cycle12_arenas_plan.md, section 7; plans in docs/art/cycle12_arenas_spec.md),
## built for real (headless) in every variant and with every count of doors: the paladin reaches every door and every
## spawn zone, no island of floor is cut off, a dash never crosses a hole, a body pushed toward the abyss stops at its
## edge, cover stops shots (the low walls only the creeping vine), a cornered paladin always has a way out, and the
## grid and flow field stay cheap.

const STAGE := "res://data/stages/catacombs.tres"
const ARENAS: Array[StringName] = [&"crypt", &"rift", &"garden"]
## The dash (Hades II): 5.6 m in 0.2 s.
const DASH := 5.6
const DASH_TIME := 0.2

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _layout(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


func _arena(l: RoomLayout, exits: int) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(l, exits, 1406)
	return a


## Every arena in every variant, with 1 to 3 doors.
func _cases() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id in ARENAS:
		var l := _layout(id)
		for v in l.variant_count():
			for n in [1, 2, 3]:
				out.append({"layout": l.variant(v), "exits": n, "name": "%s %d (%d doors)" % [id, v, n]})
	return out


func test_the_stage_has_the_three_arenas_and_the_hall_opens() -> void:
	assert_eq(stage.layouts[0].id, &"hall", "the hall is the opening, the fountain and the shop (D-26)")
	assert_true(stage.layouts[0].fountain)
	assert_eq(stage.shop_layout.id, &"hall")
	for id in ARENAS:
		var l := _layout(id)
		assert_not_null(l, "%s is in the stage" % id)
		assert_gte(l.variant_count(), 2, "%s has two variants" % id)
		assert_ne(T.t(l.name_key), String(l.name_key), "%s has its name in the text" % id)
		assert_false(l.spawns.is_empty(), "%s has spawn zones" % id)
		assert_eq(l.exits.size(), 3, "%s has three mouths" % id)
	assert_eq(_layout(&"crypt").max_alive, Vector2i(4, 6))
	assert_eq(_layout(&"crypt").max_ranged, 2)
	assert_true(_layout(&"crypt").banned_roles.has(&"area"), "no priest in the crypt")
	assert_eq(_layout(&"rift").max_alive, Vector2i(6, 8))
	assert_eq(_layout(&"garden").max_alive, Vector2i(6, 8))


func test_every_door_and_spawn_zone_is_reached_and_no_island_is_cut_off() -> void:
	for c in _cases():
		var a := _arena(c.layout, c.exits)
		var nav := a.nav
		assert_true(nav.walkable(a.start), "%s: the paladin walks in on free floor" % c.name)
		var home := nav.island[nav.nearest_free(a.start)]
		for i in a.exits.size():
			assert_true(nav.reachable(a.start, a.exits[i]), "%s: door %d is reached" % [c.name, i])
			assert_eq(a.exit_at(a.resolve(a.door_goal(i), Player.RADIUS)), i, "%s: door %d leaves by its zone" % [c.name, i])
		var zones := a.spawns.duplicate()
		zones.append_array(a.late_spawns)
		for z: Rect2 in zones:
			var good := 0
			for k in 25:
				var p := z.position + z.size * Vector2((k % 5 + 0.5) / 5.0, (k / 5 + 0.5) / 5.0)
				if nav.walkable(p) and nav.reachable(a.start, p):
					good += 1
			assert_gt(good, 12, "%s: the spawn zone %s is mostly reached floor" % [c.name, z])
		# everything else is crumbs left between a piece and an edge (smaller than a body can stand on twice)
		var sizes := nav.island_sizes()
		for i in sizes.size():
			if i != home:
				assert_lt(sizes[i], 12, "%s: an island of %d cells cut off" % [c.name, sizes[i]])
		assert_true(a.nav.walkable(a.middle), "%s: the reward rises on free floor" % c.name)
		assert_true(nav.reachable(a.start, a.middle), "%s: and the paladin reaches it" % c.name)


func test_spawns_rise_far_from_him_on_reached_floor() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12
	for c in _cases():
		var a := _arena(c.layout, c.exits)
		for i in 40:
			var p := Rooms.spawn_point(a, a.start, rng, i % 2 == 1)
			assert_true(a.nav.reachable(a.start, p), "%s: %s is reached" % [c.name, p])
			assert_gt(p.distance_to(a.start), Rooms.SPAWN_CLEAR, "%s: %s rises away from him" % [c.name, p])


## The dash near every hole: 200 starting points round it, 16 directions, frame by frame at 60 and 30 FPS; the body is
## on the floor at every frame and never ends on the far side of a hole.
func test_a_dash_never_crosses_the_abyss() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for id: StringName in [&"rift"]:
		var l := _layout(id)
		for v in l.variant_count():
			var a := _arena(l.variant(v), 3)
			var shape := a.shape()
			for hole in shape.holes:
				var box := Rect2(hole[0], Vector2.ZERO)
				for q in hole:
					box = box.expand(q)
				box = box.grow(3.0)
				var tried := 0
				var off := 0
				var crossed := 0
				while tried < 200:
					var p := Vector2(rng.randf_range(box.position.x, box.end.x), rng.randf_range(box.position.y, box.end.y))
					if not a.free_at(p, Player.RADIUS):
						continue
					tried += 1
					for k in 16:
						var dir := Vector2.RIGHT.rotated(TAU * k / 16.0)
						for fps: float in [60.0, 30.0]:
							var at := p
							var frames := ceili(DASH_TIME * fps)
							for f in frames:
								var next := a.sweep(at, at + dir * DASH / frames, Player.RADIUS)
								if not shape.contains(next, Player.RADIUS - 0.02):
									off += 1
								# crossing: a frame's way passes over a hole, or jumps more than the dash moves in it
								if _over_hole(shape, at, next) or at.distance_to(next) > DASH / frames + 0.05:
									crossed += 1
								at = next
				assert_eq(off, 0, "%s %d: the dash keeps the body on the floor at every frame" % [id, v])
				assert_eq(crossed, 0, "%s %d: no dash crosses the hole" % [id, v])


## A hole lies along the straight way from a to b (probes every 0.1 m).
func _over_hole(shape: FloorShape, a: Vector2, b: Vector2) -> bool:
	var n := ceili(a.distance_to(b) / 0.1)
	for i in n + 1:
		if not shape.covers(a.lerp(b, float(i) / maxf(n, 1))):
			return true
	return false


## An enemy struck hard toward the rift stops at its edge (D-28: nothing falls in this cycle).
func test_a_body_pushed_toward_the_abyss_stops_at_the_edge() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.rebuild_room(_layout(&"rift"), 2, 7)
	game.horde.clear_crowd()
	game.player.pos = Vector2(-16, 6)
	var e := game.horde.spawn(game.horde.def(&"skeleton"), game.arena.resolve(Vector2(-9.5, -4.0), 0.6), false)
	for i in 6:
		game.horde.damage(e, 0.1, Vector2.RIGHT, 30.0)
		for f in 20:
			game.player.invuln = 10.0
			game._step(1.0 / 60.0)
			assert_true(game.arena.shape().contains(e.pos, e.def.radius - 0.05), "the body stays on the floor at %s" % e.pos)
	assert_lt(e.pos.x, -6.4, "it stopped on the west side of the rift")


func test_cover_stops_shots_and_low_walls_only_the_creeping_vine() -> void:
	var a := _arena(_layout(&"crypt"), 3)
	# the columns and the tomb are tall: a bolt across them dies on the stone
	assert_false(a.clear_shot(Vector2(-6.0, -9.0), Vector2(-6.0, -2.0), 0.15), "a column stops a bolt")
	assert_false(a.clear_shot(Vector2(0.5, -3.0), Vector2(0.5, 3.0), 0.15), "the tomb stops a bolt")
	assert_true(a.clear_shot(Vector2(-4.0, -3.0), Vector2(-4.0, 3.0), 0.15), "open floor lets it pass")
	# the low wall (0.9 m) lets a bolt fly over it, but not the vine on the floor
	var over := Vector2(-10.0, -2.0)
	var under := Vector2(-10.0, 2.0)
	assert_lt(a.shot_hit(over, under, 0.15), 0.0, "a bolt flies over the low wall")
	assert_gte(a.shot_hit(over, under, 0.15, true), 0.0, "the vine stops at it")
	# the trunk of the garden stops everything
	var g := _arena(_layout(&"garden"), 3)
	assert_false(g.clear_shot(Vector2(-8.0, 2.0), Vector2(-8.0, -12.0), 0.15), "the trunk stops a bolt")


func test_a_shot_dies_on_stone() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.rebuild_room(_layout(&"crypt"), 2, 7)
	game.horde.clear_crowd()
	game.player.pos = Vector2(-6.0, -1.0)
	game.player.invuln = 10.0
	var shot := game.projectiles.fire(Projectiles.Kind.BOLT, Vector2(-6.0, -9.0), Vector2(0, 1), 12.0, 1.0, 0.2)
	for f in 60:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
	assert_false(game.projectiles.shots.has(shot), "the bolt is gone")
	assert_eq(game.projectiles.blocked, 1, "it died on the column")
	assert_eq(game.player.hp, game.player.max_hp, "and never reached him")


## The paladin in the narrowest way of each arena with enemies at both ends: he can always move somewhere (and the
## dash passes through bodies). Here, the floor: from every free cell at least 4 of 16 directions run 1.5 m.
func test_no_dead_end_traps_a_cornered_paladin() -> void:
	for c in _cases():
		if c.exits != 2:
			continue
		var a := _arena(c.layout, c.exits)
		var nav := a.nav
		var trapped := 0
		for i in range(0, nav.free.size(), 3):
			if nav.free[i] == 0:
				continue
			var p := nav.center(i)
			var ways := 0
			for k in 16:
				var to := a.sweep(p, p + Vector2.RIGHT.rotated(TAU * k / 16.0) * 1.5, Player.RADIUS)
				if to.distance_to(p) > 1.2:
					ways += 1
			if ways < 4:
				trapped += 1
		assert_eq(trapped, 0, "%s: no pocket where he can barely move" % c.name)


## The plan's rule: the grid and the field are cheap. One step of the field and 8 bodies asking it their way stay
## well under 2 ms (headless, on the CPU running the tests).
func test_the_grid_and_the_field_stay_cheap() -> void:
	for id in ARENAS:
		var a := _arena(_layout(id), 3)
		var bodies: Array[Vector2] = []
		var rng := RandomNumberGenerator.new()
		rng.seed = 4
		for i in 8:
			bodies.append(Rooms.spawn_point(a, a.start, rng))
		var worst := 0
		var total := 0
		for f in 240:
			var t0 := Time.get_ticks_usec()
			a.flow.aim(a.start + Vector2(sin(f * 0.05), 0) * 3.0, 1.0 / 60.0)
			for b in bodies:
				a.flow.next_step(b)
			var used := Time.get_ticks_usec() - t0
			worst = maxi(worst, used)
			total += used
		gut.p("%s: field and 8 bodies %.3f ms per step, worst %.3f ms" % [id, total / 240.0 / 1000.0, worst / 1000.0])
		assert_lt(total / 240.0, 2000.0, "%s: well under 2 ms a step" % id)
