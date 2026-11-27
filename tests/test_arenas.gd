extends GutTest
## The arenas of cycle C12 (docs/design/cycle12_arenas_plan.md, section 7; plans in docs/art/cycle12_arenas_spec.md),
## built for real (headless) in every variant and with every count of doors: the paladin reaches every door and every
## spawn zone, no island of floor is cut off, a dash never crosses a hole, a body pushed toward the abyss stops at its
## edge, cover stops shots (the low walls only the creeping vine), a cornered paladin always has a way out, and the
## grid and flow field stay cheap.

const STAGE := "res://data/stages/catacombs.tres"
const ARENAS: Array[StringName] = [&"crypt", &"rift", &"garden", &"sanctuary", &"bridge", &"runes"]
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
			if i != home and c.layout.gaps.is_empty():  # (PT-25-9: the patch a stream shuts off is meant to be cut off; test_room_gaps)
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
	for id: StringName in [&"rift", &"sanctuary", &"bridge"]:
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
								if _over_hole(shape, at, next, l.exits) or (at.distance_to(next) > DASH / frames + 0.05 and not _near_mouth(l.exits, at, next)):
									crossed += 1
								at = next
				assert_eq(off, 0, "%s %d: the dash keeps the body on the floor at every frame" % [id, v])
				assert_eq(crossed, 0, "%s %d: no dash crosses the hole" % [id, v])


## True when a or b stands at a door's mouth (the seam between the floor and the stairs' landing may move a body more than a step).
func _near_mouth(exits: Array[ArenaExit], a: Vector2, b: Vector2) -> bool:
	for e in exits:
		if e.mouth.grow(1.0).has_point(a) or e.mouth.grow(1.0).has_point(b):
			return true
	return false


## A hole lies along the straight way from a to b (probes every 0.1 m).
## (a door's mouth is floor too, the landing of its stairs: Arena joins it, 2026-11-27 the doors stand where a dash reaches them)
func _over_hole(shape: FloorShape, a: Vector2, b: Vector2, exits: Array[ArenaExit] = []) -> bool:
	var n := ceili(a.distance_to(b) / 0.1)
	for i in n + 1:
		var p := a.lerp(b, float(i) / maxf(n, 1))
		if not shape.covers(p):
			var in_mouth := false
			for e in exits:
				in_mouth = in_mouth or e.mouth.grow(0.05).has_point(p)
			if not in_mouth:
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


## GP-03 (QA B-2 of cycle C12): a point in the very middle of a piece (or anywhere inside it) is pushed out to its
## nearest face, never left inside, and nobody raised (an elder's skeletons, Morvath's dead) stands in stone.
func test_resolve_pushes_out_of_every_piece_even_from_its_middle() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12
	var all: Array[RoomLayout] = stage.layouts.duplicate()
	all.append(stage.boss_layout)
	for l in all:
		for v in l.variant_count():
			var a := _arena(l.variant(v), 3)
			var pieces := a.blockers()
			var inside := 0
			var samples := 0
			for o in pieces:
				for r: float in [0.4, Player.RADIUS, 1.0]:
					if _in_stone(a, a.resolve(o.center, r), r - 0.01):
						inside += 1
			# 400 points drawn inside the pieces
			while samples < 400 and not pieces.is_empty():
				var o: ArenaObstacle = pieces[rng.randi() % pieces.size()]
				var size := Vector2.ONE * o.radius if o.shape == ArenaObstacle.Shape.CIRCLE else o.half
				var p := o.center + (Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * size).rotated(o.yaw)
				if o.depth(p, 0.0) <= 0.0:
					continue
				samples += 1
				if _in_stone(a, a.resolve(p, Player.RADIUS), Player.RADIUS - 0.01):
					inside += 1
			assert_eq(inside, 0, "%s %d: nothing left inside a piece (%d pieces)" % [l.id, v, pieces.size()])


func test_no_one_raised_stands_in_stone() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	# 200 skeletons of the elder (Horde.raise_spot), from where he may stand in each arena
	var h := Horde.new()
	add_child_autofree(h)
	var bad := 0
	for id: StringName in [&"hall", &"crypt", &"rift", &"garden", &"sanctuary", &"bridge", &"runes"]:
		var l := _layout(id)
		for v in l.variant_count():
			var a := _arena(l.variant(v), 3)
			h.arena = a
			for i in 200 / 7 + 1:
				var from := Rooms.spawn_point(a, a.start, rng)
				var at := h.raise_spot(from, i % Horde.PRIEST_RAISES)
				if _in_stone(a, at, 0.49):
					bad += 1
	assert_eq(bad, 0, "200 of the elder's skeletons, none in stone")
	# 200 of Morvath's dead (Boss._ring_spots), around him, the paladin anywhere on his floor
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	for i in 50:
		game.player.place(Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(0.0, 11.0))
		for at in game.boss._ring_spots(game.boss.e.pos, rng.randf_range(3.0, 9.0), 4):
			if _in_stone(game.arena, at, 0.49) or not game.arena.inside(at, 0.5):
				bad += 1
	assert_eq(bad, 0, "and 200 of Morvath's, none in stone nor off his floor")


func _in_stone(a: Arena, p: Vector2, r: float) -> bool:
	for o in a.blockers():
		if o.depth(p, r) > 0.0:
			return true
	return false


## GP-04 (QA B-3 of cycle C12): "surrounded" with enemies. In the 4 narrowest ways of each arena and variant, two
## skeletons on each side of the paladin; of his 16 dodges (4 in each way: toward each side, and each turned 25
## degrees) at least 12 take him more than 2.5 m away (the dash goes through bodies, not through stone).
func test_surrounded_in_the_narrowest_ways_the_dash_gets_out() -> void:
	for id in ARENAS:
		var l := _layout(id)
		for v in l.variant_count():
			var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
			add_child_autofree(game)
			game.rebuild_room(l.variant(v), 2, 1406)
			for e in game.horde.list:
				e.alive = false
			game.horde.list.clear()
			var out := 0
			var ways := _narrowest(game.arena, 4)
			assert_eq(ways.size(), 4, "%s %d: four ways found" % [id, v])
			var told: Array[String] = []
			for w: Dictionary in ways:
				var at: Vector2 = w.at
				var axis: Vector2 = w.axis
				for side: float in [1.0, -1.0]:
					for gap: float in [1.3, 2.1]:
						var e := game.horde.spawn(game.horde.def(&"skeleton"), game.arena.resolve(at + axis * side * gap, 0.5), false)
						e.stun_t = 1000.0
				game.horde.rehash()
				for dir: Vector2 in [axis, -axis, axis.rotated(0.44), -axis.rotated(0.44)]:
					var p := game.player
					p.place(at)
					var start := p.pos
					p.invuln = 100.0
					p.dodge_charges = p.dodge_max
					p._start_dodge(dir)
					for i in int((Feel.live().dodge_time + 0.05) * 60.0):
						p.step(1.0 / 60.0, dir, Vector2.ZERO)
						game.horde.target = p.pos
						game.horde.step(1.0 / 60.0)
					if p.pos.distance_to(start) > 2.5:
						out += 1
				for e in game.horde.list:
					e.alive = false
				game.horde.list.clear()
				told.append("%s %.1f m" % [at, w.width])
			gut.p("%s %d: %d of 16 dodges out of the narrowest ways %s" % [id, v, out, told])
			assert_gte(out, 12, "%s %d: the dash gets him out" % [id, v])
			game.queue_free()
			await wait_process_frames(1)


## The n narrowest ways of an arena's floor: walkable cells whose width across (free sweeps both sides, at most 3 m
## each) is smallest along an axis with at least 2.5 m free each way; at least 3 m apart. {at, axis, width}.
func _narrowest(a: Arena, n: int) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var nav := a.nav
	for i in range(0, nav.free.size(), 2):
		if nav.free[i] == 0:
			continue
		var p := nav.center(i)
		if not a.free_at(p, Player.RADIUS):
			continue
		var reach: Array[float] = []
		for k in 8:
			reach.append(a.sweep(p, p + Vector2.RIGHT.rotated(TAU * k / 8.0) * 3.0, Player.RADIUS).distance_to(p))
		for k in 4:
			if reach[k] < 2.5 or reach[k + 4] < 2.5:
				continue
			var width := reach[(k + 2) % 8] + reach[(k + 6) % 8]
			found.append({"at": p, "axis": Vector2.RIGHT.rotated(TAU * k / 8.0), "width": width})
	found.sort_custom(func(x: Dictionary, y: Dictionary) -> bool: return float(x.width) < float(y.width))
	var out: Array[Dictionary] = []
	for f in found:
		if out.all(func(o: Dictionary) -> bool: return Vector2(o.at).distance_to(f.at) >= 3.0):
			out.append(f)
			if out.size() == n:
				break
	return out


## E5: the Provação's chamber and the Altar Esquecido: he walks in on free floor, reaches every door and the middle
## where its choices stand, and its doors take him out.
func test_the_event_rooms_walk_to_every_door() -> void:
	for l: RoomLayout in [stage.trial_layout, stage.altar_layout]:
		assert_not_null(l)
		assert_ne(T.t(l.name_key), String(l.name_key), "%s has its name" % l.id)
		for n in [1, 2, 3]:
			var a := _arena(l, n)
			assert_true(a.nav.walkable(a.start), "%s: walks in on free floor" % l.id)
			for i in a.exits.size():
				assert_true(a.nav.reachable(a.start, a.exits[i]), "%s %d doors: door %d is reached" % [l.id, n, i])
				assert_eq(a.exit_at(a.resolve(a.door_goal(i), Player.RADIUS)), i, "%s: door %d leaves by its zone" % [l.id, i])
	var t := _arena(stage.trial_layout, 3)
	assert_true(t.nav.reachable(t.start, Rooms.TRIAL_SPOT), "the spot before the trial's block is reached")
	assert_true(t.free_at(Rooms.TRIAL_SPOT, Player.RADIUS), "and stands on free floor")
	var a := _arena(stage.altar_layout, 3)
	assert_true(a.nav.reachable(a.start, Rooms.ALTAR_SPOT), "the slab before the altar's step is reached")
	assert_true(a.free_at(Rooms.ALTAR_SPOT, Player.RADIUS))


static func _seg_gap(p: Vector2, a: Vector2, b: Vector2) -> float:
	return p.distance_to(Geometry2D.get_closest_point_to_segment(p, a, b))


static func _rect_gap(r: Rect2, p: Vector2) -> float:
	return Vector2(clampf(p.x, r.position.x, r.end.x), clampf(p.y, r.position.y, r.end.y)).distance_to(p)


## How far p keeps from every slab, band, urn, flow and crystal of a hazard and of its second (the edge of each).
static func _hazard_gap(h: HazardDef, p: Vector2) -> float:
	if h == null:
		return INF
	var d := INF
	for r in h.plates:
		d = minf(d, _rect_gap(r, p))
	for s in h.strips:
		d = minf(d, _seg_gap(p, Vector2(s.x, s.y), Vector2(s.z, s.w)) - h.strip_width * 0.5)
	for s in h.aims:
		d = minf(d, _seg_gap(p, Vector2(s.x, s.y), Vector2(s.z, s.w)) - h.aim_width * 0.5)
	for r in h.bands:
		d = minf(d, _rect_gap(r, p))
	for u in h.urns:
		d = minf(d, p.distance_to(u))
	for k in h.urn_flows:
		d = minf(d, _seg_gap(p, Vector2(k.x, k.y), Vector2(k.z, k.w)) - h.flow_width * 0.5)
	for c in h.crystals:
		d = minf(d, p.distance_to(c))
	return minf(d, _hazard_gap(h.also, p))


## AT-Q4: the breakables of every room, view and variant (and the Provação and the Altar): 4 to 10 in 2 to 4 groups of
## 2 to 5, each group against a wall, a balustrade or a piece (a piece within 1.6 m of the edge or 1.2 m of a piece), on the floor and
## off every piece, low, and 1.5 m and more from a door and its mark, the way in, the reward, a spawn, a use spot, the
## guardian's spawn and every slab and band of the room's hazards.
func test_breakables_stand_where_they_may() -> void:
	var views: Array = []
	for l: RoomLayout in stage.layouts:
		for v in l.variant_count():
			views.append(["%s %d" % [l.id, v], l.variant(v)])
	views.append(["trial", stage.trial_layout])
	views.append(["altar", stage.altar_layout])
	for view: Array in views:
		var name: String = view[0]
		var l: RoomLayout = view[1]
		var a := _arena(l, 3)
		assert_between(l.breakables.size(), 4, 10, "%s: 4 to 10 pieces" % name)
		var groups := {}
		var leaning := {}
		for p in l.breakables:
			groups[p.group] = int(groups.get(p.group, 0)) + 1
			var at := p.at
			assert_true(a.inside(at, p.radius), "%s: %s on the floor" % [name, at])
			assert_false(a.overlaps(at, p.radius), "%s: %s off every piece" % [name, at])
			if not a.inside(at, 1.6) or a.overlaps(at, 1.2):
				leaning[p.group] = true
			for gr in l.gaps:  # PT-25-9: the patch of a stream, ringed by water, is its own cover
				if _rect_gap(gr, at) <= 1.5:
					leaning[p.group] = true
			assert_between(p.height, 0.35, 1.0, "%s: low" % name)
			for z in a.exit_zones:
				assert_gte(_rect_gap(z, at), 1.5, "%s: %s off a door" % [name, at])
			for d in a.exit_zones.size():
				assert_gte(at.distance_to(a.door_label(d)), 1.5, "%s: %s off a door's mark" % [name, at])
			assert_gte(at.distance_to(a.start), 1.5, "%s: %s off the way in" % [name, at])
			assert_gte(at.distance_to(a.resolve(a.middle, 1.0)), 1.5, "%s: %s off the reward" % [name, at])
			for r in l.spawns + l.late_spawns:
				assert_gte(_rect_gap(r, at), 1.5, "%s: %s off a spawn" % [name, at])
			if l.guardian_home:
				assert_gte(at.distance_to(l.boss_spawn), 1.5, "%s: %s off the guardian" % [name, at])
			if name == "trial":
				assert_gte(at.distance_to(Rooms.TRIAL_SPOT), 1.5, "%s: off the use spot" % name)
			if name == "altar":
				assert_gte(at.distance_to(Rooms.ALTAR_SPOT), 1.5, "%s: off the use spot" % name)
			assert_gte(_hazard_gap(l.hazard, at), 1.5, "%s: %s off the hazard" % [name, at])
		assert_between(groups.size(), 2, 4, "%s: 2 to 4 groups" % name)
		for g in groups:
			assert_between(int(groups[g]), 2, 5, "%s: groups of 2 to 5" % name)
			assert_true(leaning.has(g), "%s: group %d against a wall, a balustrade or a piece" % [name, g])


## AT-FO2: the Fonte shows in the frame of both cameras as the paladin arrives in the Salão (with its light, the
## RewardShaft), on his way to the doors, and the room's breakables keep 5 m from its basin (AT-FO3).
func test_the_fountain_is_seen_on_arrival() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms._enter(RunMap.Room.new(RunMap.Kind.FOUNTAIN, RunMap.Reward.GOLD, 6, 0, 0))
	var at := Rooms.FOUNTAIN_SPOT
	assert_eq(game._fountain_at, at)
	for d: float in [Feel.live().cam_distance_near, Feel.live().cam_distance]:
		var s := game._screen_of(at, d, false)
		assert_between(s.x, 0.15, 0.85, "camera at %s m: across the screen" % d)
		assert_between(s.y, 0.15, 0.85, "camera at %s m: up the screen" % d)
	assert_true(game.arena.free_at(at, 2.5), "the basin on free floor")
	for p in game.arena.layout.breakables:
		assert_gte(p.at.distance_to(at), 5.0, "a vase 5 m off the basin")
	for k in game.arena.exit_zones.size():
		assert_gte(at.distance_to(game.arena.door_label(k)), 8.0, "off the doors")
