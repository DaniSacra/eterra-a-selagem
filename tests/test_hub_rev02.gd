extends GutTest
## HV-A and HV-B, the Santuário da Vigília Rev. 02, redone by SV-R (2026-11-25, the package's plan): the arrival at the
## Ponto de Vigilia, the Alquimista out of the stations with its bench and door, every way back to the hub landing on
## the Ponto de Vigilia, every station reached from it round the pieces, nothing on the arrival nor on a use point,
## the walks measured (the stations are farther apart than in the square: the way back to the gate stays under 12 s),
## and both cameras showing him and the Videira, the first station, as he arrives.

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


func test_the_plan_puts_him_at_the_ponto_de_vigilia_and_the_alchemist_is_no_station() -> void:
	var l := HubPlan.layout()
	assert_true(l.floor.contains(l.hero_spawn, Player.RADIUS), "the Ponto de Vigilia on the floor")
	assert_eq(l.hero_spawn, HubPlan.to_world(HubPlan.ARRIVAL))
	assert_eq(HubPlan.ARRIVAL, Vector2(-24.0, -7.0), "the package's point")
	assert_false(HubPlan.STATIONS.has(&"alchemist"), "no station")
	assert_false(HubPlan.USE.has(&"alchemist"))
	var bench := 0
	var room := Rect2(-29.0, 0.0, 12.0, 10.0)
	for o in l.obstacles:
		if o.piece == &"hub_alchemist":
			bench += 1
			assert_true(room.has_point(HubPlan.to_local(o.center)), "its bench in its courtyard")
			assert_true(o.blocks_move, "and it blocks")
	assert_eq(bench, 1)
	# no focus anywhere in its courtyard (a station two steps off would take it)
	var focus := HubFocus.new(_uses())
	for k in 25:
		var p := room.position + room.size * Vector2((k % 5) / 4.0, (k / 5) / 4.0)
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
		if o.blocks_move:
			assert_lte(o.depth(hub.arena.start, Player.RADIUS + 0.5), 0.0, "%s off the seal" % o.piece)
	for id in HubPlan.STATIONS:
		var p := HubPlan.use_point(id)
		assert_lt(hub.arena.resolve(p, Player.RADIUS + 0.3).distance_to(p), 0.01, "%s's use point free" % id)


## The walk measured: the hero walks from one place to the other round the pieces (the NavGrid's flow field, the
## bot's way) at his own speed. SV-R: the stations lie along a route 70 m long, so the bounds are the route's: the
## Videira a few seconds from the Ponto de Vigilia, the gate under 12 s (the return to the adventure stays quick).
func test_the_walks_between_the_stations_are_measured() -> void:
	var hub := _hub()
	var spots := {&"arrival": hub.arena.start}
	for id in HubPlan.STATIONS:
		spots[id] = HubPlan.use_point(id)
	var keys := spots.keys()
	var table := PackedStringArray()
	var worst := 0.0
	for i in keys.size():
		for j in range(i + 1, keys.size()):
			var t := _walk(hub, spots[keys[i]], spots[keys[j]])
			table.append("%s-%s %.2f s" % [keys[i], keys[j], t])
			worst = maxf(worst, t)
			if keys[i] == &"arrival" and keys[j] == HubPlan.VINE:
				assert_lt(t, 4.0, "the Videira is the first station: %.2f s" % t)
			if keys[i] == &"arrival" and keys[j] == HubPlan.PORTAL:
				assert_lt(t, 12.0, "from the Ponto de Vigilia to the gate: %.2f s" % t)
	assert_lt(worst, 18.0, "no two places of the hub more than 18 s apart")
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


## SV-R: as he arrives both cameras keep him inside the arrival's safe frame and show the Videira, the first station
## (its arch and its use point), with the near camera on the far one's point for the look; then each camera goes back
## to its own distance and the 18% (the arrival look eases out).
func test_from_the_ponto_de_vigilia_both_cameras_show_him_and_the_videira() -> void:
	var f := Feel.live()
	var l := HubPlan.layout()
	var hero := HubPlan.to_world(HubPlan.ARRIVAL)
	var d := HubPlan.ARRIVAL_DISTANCE
	for aspect in ASPECTS:
		for want: Vector2 in [l.cam_target, HubPlan.near_want_at(hero, 0.0)]:
			var slack := CamFrame.slack(d, f.cam_distance, f.cam_pitch, f.cam_fov, aspect)
			assert_eq(slack, Vector2.ZERO)
			var at := CamFrame.hold(l.cam_target, want, l.cam_reach, hero, d, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect, true, slack, HubPlan.ARRIVAL_SAFE)
			var sc := func(p: Vector2, h: float) -> Vector2:
				return CamFrame.screen_of(HubPlan.to_world(p), h, at, d, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect)
			var tag := "aspect %.2f" % aspect
			var h: Vector2 = sc.call(HubPlan.ARRIVAL, CamFrame.HERO_HEIGHT)
			assert_between(h.x, HubPlan.ARRIVAL_SAFE - 0.005, 1.0 - HubPlan.ARRIVAL_SAFE + 0.005, tag + ": him across")
			assert_between(h.y, HubPlan.ARRIVAL_SAFE - 0.005, 1.0 - HubPlan.ARRIVAL_SAFE + 0.005, tag + ": him up")
			var arch: Vector2 = sc.call(HubPlan.VINE_ARCH, 3.2)
			assert_true(Rect2(0.03, 0.03, 0.94, 0.94).has_point(arch), tag + ": the Videira's arch %s" % arch)
			assert_true(Rect2(0.03, 0.03, 0.94, 0.94).has_point(sc.call(HubPlan.USE[HubPlan.VINE], 0.0)), tag + ": its use point")
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
