extends GutTest
## Chapter II, A-5: the Pulso do Bosque. Shallow water slows (-15%, no damage) with a dry route in every room; the roots rise in warned
## spots (never on the paladin's tile, never leaving him without a way to a door); the spores burst over the mushrooms (never over him).

const STAGE := "res://data/stages/bosque.tres"
const OWN: Array[StringName] = [&"bosque_gates", &"bosque_garden", &"bosque_temple"]


func _layout(id: StringName) -> RoomLayout:
	var stage: StageDef = load(STAGE)
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


func _doors(l: RoomLayout) -> Array[Rect2]:
	var out: Array[Rect2] = []
	for e in l.exits:
		out.append(e.mouth)
		out.append(e.zone)
	return out


func _roots(seed_: int) -> ArenaHazard:
	var l := _layout(&"bosque_temple")
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	return ArenaHazard.new(l.hazard, l.floor, _doors(l), rng)


func test_water_slows_by_15_percent_and_stops_when_dry() -> void:
	var wet: Array[Rect2] = [Rect2(0, 0, 4, 4)]
	assert_almost_eq(WaterRules.speed_scale(wet, Vector2(2, 2)), 0.85, 0.0001)
	assert_eq(WaterRules.speed_scale(wet, Vector2(5, 2)), 1.0)
	assert_eq(WaterRules.speed_scale([] as Array[Rect2], Vector2(2, 2)), 1.0)
	var a := Arena.new()
	add_child_autofree(a)
	var l := _layout(&"bosque_temple")
	a.build(l, 2, 1406)
	var canal := l.water[0].get_center()
	assert_almost_eq(a.water_scale(canal), 0.85, 0.0001)
	assert_eq(a.water_scale(a.start), 1.0, "dry at the way in")
	assert_eq(a.water_scale(canal + Vector2(0, 6.0)), 1.0, "out of the canal, full pace again")


func test_chapter_one_has_no_water() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(null, 2, 1)
	assert_eq(a.water_scale(Vector2.ZERO), 1.0)


func test_a_dry_route_reaches_every_door_in_every_bosque_room() -> void:
	for id in OWN:
		var l := _layout(id)
		assert_gt(l.water.size(), 0, "%s has water" % id)
		for e in l.exits:
			assert_true(WaterRules.dry_route(l.floor, l.water, l.hero_spawn, e.edge()), "%s: dry route to %s" % [id, e.edge()])


func test_the_dry_route_check_sees_a_wall_of_water() -> void:
	var l := _layout(&"bosque_gates")
	var wall: Array[Rect2] = [Rect2(-30, -2, 60, 4)]
	assert_false(WaterRules.dry_route(l.floor, wall, l.hero_spawn, l.exits[0].edge()))


func test_one_family_per_room() -> void:
	assert_null(_layout(&"bosque_gates").hazard, "the Portões teach the water alone")
	var g := _layout(&"bosque_garden").hazard
	assert_eq(g.kind, HazardDef.Kind.SPORES)
	assert_eq(g.spots.size(), 8)
	assert_null(g.also)
	assert_eq(g.hero_damage, 10.0, "Chapter I's hazard damage")
	var t := _layout(&"bosque_temple").hazard
	assert_eq(t.kind, HazardDef.Kind.GRID)
	assert_true(t.spare_hero and t.keep_route)
	assert_null(t.also)
	assert_eq(t.hero_damage, 10.0)


func test_roots_cycle_calm_arm_fire_rest() -> void:
	var h := _roots(3)
	var d := h.def
	var t := 0.0
	var dt := 0.05
	var seen: Array[int] = []
	var at := {}
	while t < d.start_delay + d.warn + d.fire + d.rest + 1.0:
		var ev := h.step(dt, Vector2(0, 10), 1)
		t += dt
		if ev != ArenaHazard.Event.NONE:
			seen.append(ev)
			at[ev] = t if not at.has(ev) else at[ev]
	assert_eq(seen.slice(0, 3), [ArenaHazard.Event.ARMED, ArenaHazard.Event.FIRED, ArenaHazard.Event.ENDED] as Array[int])
	assert_almost_eq(float(at[ArenaHazard.Event.ARMED]), d.start_delay, 0.1, "nothing in the first seconds")
	assert_almost_eq(float(at[ArenaHazard.Event.FIRED]) - float(at[ArenaHazard.Event.ARMED]), d.warn, 0.1, "the warning")
	assert_almost_eq(float(at[ArenaHazard.Event.ENDED]) - float(at[ArenaHazard.Event.FIRED]), d.fire, 0.1)
	assert_eq(seen[3], ArenaHazard.Event.ARMED, "and again after the rest")


func test_roots_never_rise_on_the_paladin_and_always_leave_a_way_to_a_door() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var armed := 0
	for s in 12:
		var h := _roots(s)
		var l := _layout(&"bosque_temple")
		for n in 60:
			var hero := Vector2(rng.randf_range(-16, 16), rng.randf_range(-11, 11))
			if not l.floor.covers(hero):
				continue
			h.bodies = PackedVector2Array([Vector2(rng.randf_range(-12, 12), rng.randf_range(-10, 10))])
			# run one whole cycle with the paladin standing where he stands
			var ev := ArenaHazard.Event.NONE
			var guard := 0
			while ev != ArenaHazard.Event.ARMED and guard < 400:
				ev = h.step(0.1, hero, 1)
				guard += 1
			if ev != ArenaHazard.Event.ARMED:
				continue
			armed += 1
			var t := h.tile_at(hero)
			if t.x >= 0:
				assert_eq(h.lit[t.y * h.def.cols + t.x], 0, "seed %d: not on the paladin's tile" % s)
			assert_true(h.route_open(hero), "seed %d: a way to a door stays open" % s)
			assert_true(h.safe_everywhere(), "the unlit neighbour rule holds")
			assert_lte(h.share(), h.def.max_share + 0.001)
	assert_gt(armed, 100, "the cycle ran")


func test_route_open_sees_a_shut_exit() -> void:
	var h := _roots(1)
	var hero := Vector2(0, 5)
	assert_true(h.route_open(hero))
	var door := _layout(&"bosque_temple").exits[0].mouth.get_center()
	for i in h.lit.size():
		h.lit[i] = 1
	assert_false(h.route_open(hero), "every tile lit: no way")
	assert_true(door.y < 0.0)


func test_spores_burst_over_the_mushrooms_never_over_the_paladin() -> void:
	var l := _layout(&"bosque_garden")
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var h := SporeHazard.new(l.hazard, rng)
	var d := l.hazard
	var hero := l.hazard.spots[0] + Vector2(0.5, 0.0)
	var t := 0.0
	var order: Array[int] = []
	var armed_at := -1.0
	var fired_at := -1.0
	while t < d.start_delay + d.warn + d.fire + d.rest + 1.0:
		var ev := h.step(0.05, hero)
		t += 0.05
		if ev == ArenaHazard.Event.ARMED:
			order.append(ev)
			if armed_at < 0.0:
				armed_at = t
				assert_gt(h.lit.size(), 0)
				assert_lte(h.lit.size(), d.clouds)
				for s in h.lit:
					assert_gt(s.distance_to(hero), d.cloud_radius + SporeHazard.SPARE, "never over the paladin")
					assert_true(d.spots.has(s), "over a mushroom")
		elif ev == ArenaHazard.Event.FIRED and fired_at < 0.0:
			fired_at = t
	assert_almost_eq(armed_at, d.start_delay, 0.1)
	assert_almost_eq(fired_at - armed_at, d.warn, 0.1)
	assert_eq(order.size(), 2, "a second cloud group after the rest")


func test_a_cloud_hurts_the_paladin_and_the_creatures_in_it_in_a_real_room() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _layout(&"bosque_garden")
	game.rebuild_room(l, 2, 1406)
	game.horde.clear_crowd()
	var rng := RandomNumberGenerator.new()
	var sf := SporeFloor.new(game, l.hazard, rng)
	var at := l.hazard.spots[0]
	var e := game.horde.spawn(game.horde.def(&"skeleton"), at + Vector2(0.5, 0), false)
	var far := game.horde.spawn(game.horde.def(&"skeleton"), at + Vector2(6.0, 0), false)
	game.player.place(at + Vector2(-0.5, 0))
	game.player.invuln = 0.0
	var hp := game.player.hp
	sf.zones.append(game.ground.add_cloud(at, l.hazard.cloud_radius, 0.1, l.hazard.hero_damage, l.hazard.enemy_damage))
	for i in 10:
		game.ground.step(0.02)
	assert_almost_eq(game.player.hp, hp - 10.0, 0.01, "Chapter I's 10")
	assert_almost_eq(e.max_hp - e.hp, 60.0, 0.01, "the creature in the cloud too")
	assert_eq(far.hp, far.max_hp)
	assert_eq(game.last_hurt.get("attack", &""), &"spore")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Nuvem de Esporos")
	sf.stop()


func test_the_fight_in_the_garden_and_the_temple_run_their_floors() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var stage: StageDef = load(STAGE)
	game.rooms.stage = stage
	for id in [&"bosque_garden", &"bosque_temple"]:
		var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 2, stage.layouts.find(_layout(id)), 0)
		game.rooms._enter(r)
		if id == &"bosque_garden":
			assert_not_null(game.rooms.spores, "the garden has its clouds")
		else:
			assert_not_null(game.rooms.runes, "the temple has its roots")
		for i in 400:
			game.rooms.step(1.0 / 60.0)
			game.ground.step(1.0 / 60.0)
		var laid: Array = game.rooms.spores.patterns if id == &"bosque_garden" else game.rooms.runes.patterns
		assert_gt(laid.size(), 0, "%s: it laid a pattern after its start delay" % id)
		game.rooms._room_cleared()
		assert_null(game.rooms.spores)
		assert_null(game.rooms.runes)


func test_the_templo_roots_have_their_own_defeat_name() -> void:
	var st := load("res://data/stages/bosque.tres") as StageDef
	var found := false
	for l: RoomLayout in st.layouts:
		if l.hazard != null and l.hazard.kind == HazardDef.Kind.GRID and l.hazard.rune_source == Ground.ROOTGRID_SOURCE:
			found = true
	assert_true(found, "the Templo's root grid names itself")
	assert_true(Ground.ROOM_SOURCES.has(Ground.ROOTGRID_SOURCE), "it counts against the two at once")
	var cause := DefeatCause.of(Ground.ROOTGRID_SOURCE, &"")
	assert_eq(DefeatCause.text_key(cause), &"killer_rootgrid")
	assert_eq(T.t(&"killer_rootgrid"), "Raízes")
