extends GutTest
## HV-A and HV-B, the Santuário da Vigília Rev. 02 (docs/backlog.md P.5; Q-HV1 a: the quarters of today with the plan's
## distances; Q-HV2 a: the south well gone, every arrival on the Retorno's seal at the south-east): the plan (no well,
## the stairs' head open on the south edge, the fountain blocking 3.1 m, the Alquimista's space reserved outside the
## stations with its bench blocking), every way back to the hub landing on the seal, every station and the portal
## reached from it round the pieces, nothing on the arrival nor on a use point, the walk between every two stations
## measured under 4 s, and the portal whole on the screen from the seal with both cameras.

const DT := 1.0 / 60.0
const ASPECTS: Array[float] = [16.0 / 9.0, 4.0 / 3.0, 21.0 / 9.0]

var went: Array[String] = []


func before_each() -> void:
	went.clear()
	SceneGo.catch = func(path: String) -> void: went.append(path)
	Controls.virtual = null
	Controls.clear_presses()


func after_each() -> void:
	SceneGo.catch = Callable()
	Controls.virtual = null
	Controls.clear_presses()
	Engine.time_scale = 1.0


func _hub() -> Hub:
	var hub: Hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	return hub


func test_the_plan_has_no_well_and_the_retorno_at_the_south_east() -> void:
	var l := HubPlan.layout()
	assert_true(l.floor.contains(HubPlan.to_world(Vector2(0.0, -12.0)), Player.RADIUS), "the old well is floor now")
	assert_true(l.floor.contains(l.hero_spawn, Player.RADIUS), "the seal on the floor")
	assert_eq(l.hero_spawn, HubPlan.to_world(HubPlan.ARRIVAL))
	assert_almost_eq(HubPlan.ARRIVAL, Vector2(18.0, -11.4), Vector2(0.01, 0.01), "the plan's seal")
	# the stairs' head is an edge of the floor at the south, under the seal
	var head := false
	for i in HubPlan.FLOOR.size():
		var a: Vector2 = HubPlan.FLOOR[i]
		var b: Vector2 = HubPlan.FLOOR[(i + 1) % HubPlan.FLOOR.size()]
		if is_equal_approx(a.y, HubPlan.SOUTH) and is_equal_approx(b.y, HubPlan.SOUTH) \
				and is_equal_approx(minf(a.x, b.x), HubPlan.ARRIVAL_STAIRS.x) and is_equal_approx(maxf(a.x, b.x), HubPlan.ARRIVAL_STAIRS.y):
			head = true
	assert_true(head, "the stairs' head on the south edge")
	assert_between(HubPlan.ARRIVAL.x, HubPlan.ARRIVAL_STAIRS.x, HubPlan.ARRIVAL_STAIRS.y, "the seal over its stairs")
	assert_almost_eq(HubPlan.ARRIVAL_STAIRS.y - HubPlan.ARRIVAL_STAIRS.x, 7.0, 0.01, "7 m wide")
	var fountain := false
	for o in l.obstacles:
		if o.piece == &"hub_fountain":
			fountain = true
			assert_almost_eq(o.radius, 3.1, 0.001, "the fountain blocks 3.1 m")
	assert_true(fountain)


func test_the_alchemist_is_reserved_outside_the_stations() -> void:
	assert_false(HubPlan.STATIONS.has(&"alchemist"), "no station")
	assert_false(HubPlan.USE.has(&"alchemist"))
	var space := Rect2(Vector2(HubPlan.ALCHEMIST.x - HubPlan.ALCHEMIST.z, HubPlan.ALCHEMIST.y - HubPlan.ALCHEMIST.w),
		Vector2(HubPlan.ALCHEMIST.z, HubPlan.ALCHEMIST.w) * 2.0)
	var l := HubPlan.layout()
	var bench := 0
	for o in l.obstacles:
		var c := HubPlan.to_local(o.center)
		if o.piece == &"hub_alchemist":
			bench += 1
			assert_true(space.has_point(c), "its bench in its space")
			assert_true(o.blocks_move, "and it blocks")
		elif space.grow(-0.2).has_point(c):
			fail_test("%s %s in the Alquimista's space" % [o.piece, c])
	assert_eq(bench, 1)
	# no focus anywhere in it (a station two steps off would take it)
	var focus := HubFocus.new(_uses())
	for k in 25:
		var p := space.position + space.size * Vector2((k % 5) / 4.0, (k / 5) / 4.0)
		focus.step(HubPlan.to_world(p))
		assert_eq(focus.current, &"", "no focus at %s" % p)


func test_every_way_back_lands_on_the_seal() -> void:
	# death and victory: Voltar ao Santuário; the pause; the title's Iniciar (new save or loaded): all to the hub
	var game: Game = (load(SceneGo.GAME) as PackedScene).instantiate()
	add_child_autofree(game)
	for victory: bool in [false, true]:
		game._open_end(victory, false)
		var ends := game.find_children("*", "EndScreen", true, false)
		var end := ends[ends.size() - 1] as EndScreen
		(end.find_child("continue" if victory else "menu", true, false) as Button).pressed.emit()
		(end.find_child("again" if victory else "retry", true, false) as Button).pressed.emit()
	assert_eq(went, [SceneGo.HUB, SceneGo.GAME, SceneGo.HUB, SceneGo.GAME] as Array[String],
		"Voltar goes to the hub, Descer de novo straight down")
	went.clear()
	var pause := PauseMenu.new()
	add_child_autofree(pause)
	pause.open()
	(pause.find_child("quit", true, false) as Button).pressed.emit()
	assert_eq(went, [SceneGo.HUB] as Array[String])
	# and the hub always puts him on the seal, the arrival look on
	var hub := _hub()
	assert_almost_eq(hub.player.pos, HubPlan.to_world(HubPlan.ARRIVAL), Vector2(0.01, 0.01), "on the seal")
	assert_eq(hub.arrived, 0.0, "just arrived")
	assert_eq(hub.cam.wide, 1.0, "the arrival look")


func test_every_station_and_the_portal_are_reached_from_the_seal_round_the_pieces() -> void:
	var hub := _hub()
	var nav := hub.arena.nav
	for id in HubPlan.STATIONS:
		assert_true(nav.reachable(hub.arena.start, HubPlan.use_point(id)), "%s reached from the seal" % id)
	# nothing stands on the seal, nor where he uses a station
	for o in HubPlan.layout().obstacles:
		if not o.blocks_move:
			continue
		var r := o.radius if o.shape == ArenaObstacle.Shape.CIRCLE else o.half.length()
		assert_gt(o.center.distance_to(hub.arena.start), r + 1.5, "%s off the seal" % o.piece)
	for id in HubPlan.STATIONS:
		var p := HubPlan.use_point(id)
		assert_lt(hub.arena.resolve(p, Player.RADIUS + 0.3).distance_to(p), 0.01, "%s's use point free" % id)


## The walk measured: the hero walks from one place to the other round the pieces (the NavGrid's flow field, the
## bot's way) at his own speed; between two stations never over 4 s (LR-07), from the seal to the portal about 4.3.
func test_the_walks_between_the_stations_are_measured_under_four_seconds() -> void:
	var hub := _hub()
	var spots := {&"arrival": hub.arena.start}
	for id in HubPlan.STATIONS:
		spots[id] = HubPlan.use_point(id)
	var keys := spots.keys()
	var table := PackedStringArray()
	for i in keys.size():
		for j in range(i + 1, keys.size()):
			var t := _walk(hub, spots[keys[i]], spots[keys[j]])
			table.append("%s-%s %.2f s" % [keys[i], keys[j], t])
			if keys[i] == &"arrival":
				assert_lt(t, 5.5, "from the seal to %s: %.2f s" % [keys[j], t])
			else:
				assert_lt(t, 4.0, "%s to %s: %.2f s" % [keys[i], keys[j], t])
	gut.p("HUB WALKS " + ", ".join(table))


func _walk(hub: Hub, from: Vector2, to: Vector2) -> float:
	hub.player.pos = from
	var field := FlowField.new(hub.arena.nav)
	var t := 0.0
	for i in 900:
		var p := hub.player.pos
		if p.distance_to(to) < 0.3:
			return t
		var way := (to - p).normalized()
		if not hub.arena.nav.clear_line(p, to):
			field.aim(to, DT, 0)
			var w := field.next_step(p)
			if w != Vector2.ZERO:
				way = w
		hub.player.step(DT, way, Vector2.ZERO)
		t += DT
	return INF


## HV-B: as he comes up the Retorno both cameras show the portal whole (its sill a fifth to three tenths down the
## screen, the arch's top in it), the fountain and two stations or more, and him inside the arrival's safe frame;
## then each camera goes back to its own distance and the 18% (the arrival look eases out).
func test_from_the_seal_the_portal_shows_whole_with_both_cameras() -> void:
	var f := Feel.live()
	var l := HubPlan.layout()
	var hero := HubPlan.to_world(HubPlan.ARRIVAL)
	var d := HubPlan.ARRIVAL_DISTANCE
	for aspect in ASPECTS:
		# far: its point; near: the far one's point for the look (HubPlan.near_want_at) with no slack at this distance
		for want: Vector2 in [l.cam_target, HubPlan.near_want_at(hero, 0.0)]:
			var slack := CamFrame.slack(d, f.cam_distance, f.cam_pitch, f.cam_fov, aspect)
			assert_eq(slack, Vector2.ZERO)
			var at := CamFrame.hold(l.cam_target, want, l.cam_reach, hero, d, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect, true, slack, HubPlan.ARRIVAL_SAFE)
			var sc := func(p: Vector2, h: float) -> Vector2:
				return CamFrame.screen_of(HubPlan.to_world(p), h, at, d, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect)
			var sill: Vector2 = sc.call(Vector2(0.0, HubLook.SHEET_V), HubLook.TERRACE_Y)
			var top: Vector2 = sc.call(Vector2(HubPlan.PORTAL_TOP.x, HubPlan.PORTAL_TOP.y), HubPlan.PORTAL_TOP.z)
			var tag := "aspect %.2f" % aspect
			assert_between(sill.y, 0.15, 0.30, tag + ": the sill %.3f" % sill.y)
			assert_gt(top.y, 0.0, tag + ": the arch's top %.3f" % top.y)
			assert_between(top.x, 0.05, 0.95, tag + ": the arch across")
			var fountain: Vector2 = sc.call(Vector2(HubPlan.FOUNTAIN.x, HubPlan.FOUNTAIN.y), 1.0)
			assert_true(Rect2(0, 0, 1, 1).has_point(fountain), tag + ": the fountain")
			var seen := 0
			for id: StringName in [HubPlan.VENDOR, HubPlan.TREE, HubPlan.SMITH, HubPlan.BOOK]:
				if Rect2(0.03, 0.03, 0.94, 0.94).has_point(sc.call(HubPlan.USE[id], 0.0)):
					seen += 1
			assert_gte(seen, 2, tag + ": two stations or more")
			var h: Vector2 = sc.call(HubPlan.ARRIVAL, CamFrame.HERO_HEIGHT)
			assert_between(h.x, HubPlan.ARRIVAL_SAFE - 0.005, 1.0 - HubPlan.ARRIVAL_SAFE + 0.005, tag + ": him across")
			assert_between(h.y, HubPlan.ARRIVAL_SAFE - 0.005, 1.0 - HubPlan.ARRIVAL_SAFE + 0.005, tag + ": him up")
			# nothing tall of the square over the portal on the screen (the Livro's case, the cypresses, the forge)
			for o in l.obstacles:
				if o.height < 2.5 or HubPlan.to_local(o.center).y > HubPlan.NORTH:
					continue
				var tip := CamFrame.screen_of(o.center, o.height, at, d, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect)
				var over := tip.y < sill.y and absf(tip.x - top.x) < 0.08
				assert_false(over, "%s %s over the portal (%s)" % [o.piece, HubPlan.to_local(o.center), tag])
	assert_eq(HubPlan.arrival_share(0.0), 1.0)
	assert_eq(HubPlan.arrival_share(HubPlan.ARRIVAL_LOOK), 1.0, "the look holds")
	assert_eq(HubPlan.arrival_share(HubPlan.ARRIVAL_LOOK + HubPlan.ARRIVAL_EASE), 0.0, "then eases out")
	assert_eq(HubPlan.arrival_share(-1.0), 0.0, "placed by --hero-at: none")


func test_the_hub_eases_the_arrival_look_out() -> void:
	var hub := _hub()
	await get_tree().process_frame
	assert_almost_eq(hub.cam.dist(), HubPlan.ARRIVAL_DISTANCE, 0.01, "the arrival look's distance")
	hub.arrived = HubPlan.ARRIVAL_LOOK + HubPlan.ARRIVAL_EASE + 0.1
	hub._arrival_look()
	assert_eq(hub.cam.wide, 0.0)
	assert_eq(hub.cam.safe, CamFrame.SAFE)
	assert_almost_eq(hub.cam.dist(), CamRig.distance(), 0.001, "its own distance after")


static func _uses() -> Dictionary:
	var out := {}
	for id in HubPlan.STATIONS:
		out[id] = HubPlan.use_point(id)
	return out
