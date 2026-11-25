extends GutTest
## SR-P2 the slab that gives (PLATES named "sag"), SR-P3 the pit grate (LINE named "spikes"), the cycle that shortens
## deep in the descent (HazardDef.cycle_at, rearm_at), the wall trap's harder numbers and SR-P5 the relic in the stone.
## Data checks: every piece whole on the floor, 6 m from the way in, off the doors, clear of the other hazards' pieces and
## of the obstacles, at most one hazard of a kind's slot in a room.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _layout(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


## [variant layout, hazard] of every hazard of the sources `names`, in every room and variant.
func _found(names: Array) -> Array:
	var out := []
	for l in stage.layouts:
		for v in l.variants.size() + 1:
			var lv := l.variant(v)
			var hz := lv.hazard
			while hz != null:
				var n := hz.plate_source if hz.kind == HazardDef.Kind.PLATES else hz.band_source
				if names.has(n):
					out.append([lv, hz])
				hz = hz.also
	return out


func _rects(hz: HazardDef) -> Array[Rect2]:
	return hz.plates if hz.kind == HazardDef.Kind.PLATES else hz.bands


func test_where_they_are() -> void:
	var sag := _found([&"sag"]).map(func(t: Array) -> String: return "%s%d" % [(t[0] as RoomLayout).id, (t[1] as HazardDef).plates.size()])
	sag.sort()
	assert_eq(sag, ["rift2", "sanctuary3"], "slabs in the Fendas A and the Santuário A")
	var sp := _found([&"spikes"]).map(func(t: Array) -> String: return "%s%d" % [(t[0] as RoomLayout).id, (t[1] as HazardDef).bands.size()])
	sp.sort()
	assert_eq(sp, ["crypt2", "crypt2", "sanctuary2"], "grates in the Cripta A and B and the Santuário B")


func test_fair_and_whole() -> void:
	for t: Array in _found([&"sag", &"spikes"]):
		var l: RoomLayout = t[0]
		var h: HazardDef = t[1]
		assert_almost_eq(h.hero_damage, 10.0, 0.001, "10 to him")
		assert_gte(h.warn, 1.2, "never less than the enemies' warning")
		assert_gte(h.start_delay, 5.0, "calm at the start")
		assert_gte(h.from_progress, 0.15, "asleep until the 2nd room (RD-02: the slab to learn wakes at 0.15)")
		for r in _rects(h):
			for q in [r.position, r.end, r.position + Vector2(r.size.x, 0), r.position + Vector2(0, r.size.y), r.get_center()]:
				assert_true(l.floor.covers(q), "%s whole on the floor at %s" % [l.id, q])
			assert_gte(r.get_center().distance_to(l.hero_spawn), 6.0, "6 m from the way in")
			for e in l.exits:
				assert_false(e.mouth.grow(1.0).intersects(r), "%s off a door" % l.id)
			for o in l.obstacles:
				if o.blocks_move:
					assert_false(r.grow(0.2).intersects(o.rect()), "%s: no obstacle in a piece at %s" % [l.id, r])
		# clear of the room's other hazards' pieces
		var hz := l.hazard
		while hz != null:
			if hz != h:
				for r in _rects(h):
					for o in _rects(hz):
						assert_false(r.grow(0.5).intersects(o), "%s: %s clear of the other hazards" % [l.id, r])
			hz = hz.also


func test_no_two_of_a_slot() -> void:
	for l in stage.layouts:
		for v in l.variants.size() + 1:
			var plates := 0
			var lines := 0
			var hz := l.variant(v).hazard
			while hz != null:
				if hz.kind == HazardDef.Kind.PLATES:
					plates += 1
				elif hz.kind == HazardDef.Kind.LINE:
					lines += 1
				hz = hz.also
			assert_lte(plates, 2, "%s%d: Rooms keeps two PLATES" % [l.id, v])
			assert_lte(lines, 1, "%s%d: Rooms keeps one LINE" % [l.id, v])


func test_deeper_is_faster() -> void:
	for t: Array in _found([&"trap", &"spikes"]):
		var h: HazardDef = t[1]
		assert_gt(h.cycle_late, 0.0)
		assert_lt(h.cycle_late, h.cycle, "the cycle shortens deep in the descent")
		assert_almost_eq(h.cycle_at(0.3), h.cycle, 0.001)
		assert_almost_eq(h.cycle_at(0.9), h.cycle_late, 0.001)
		assert_almost_eq(BandHazard.new(h, [], 0.9).cycle, h.cycle_late, 0.001)
	var sanct := _layout(&"sanctuary").hazard.also
	assert_almost_eq(sanct.cycle, 3.5, 0.001, "the Santuário's trap: 3.5 s")
	assert_almost_eq(sanct.bands[0].size.x, 1.6, 0.001, "a line 1.6 m across")
	for t: Array in _found([&"sag"]):
		var h: HazardDef = t[1]
		assert_lt(h.rearm_at(0.9), h.rearm_at(0.3))
		assert_almost_eq(PlateHazard.new(h, [], true, 0.9).rearm, h.rearm_late, 0.001)


func test_the_slab_waits_then_gives() -> void:
	var h: HazardDef = _found([&"sag"])[0][1]
	var ph := PlateHazard.new(h, [], true, 0.5)
	var on := h.plates[0].get_center()
	var armed_at := -1.0
	var struck_at := -1.0
	var t := 0.0
	while t < 12.0:
		var did := ph.step(DT, on, PackedVector2Array())
		t += DT
		if armed_at < 0.0 and not (did.armed as Array).is_empty():
			armed_at = t
		if struck_at < 0.0 and not (did.fired as Array).is_empty():
			struck_at = t
			break
	assert_gt(armed_at, h.start_delay, "after the calm")
	assert_almost_eq(struck_at - armed_at, h.warn, 0.05, "it falls a warning after it arms")


func _enter(layout_id: StringName, depth: int, fight_seed := 7) -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _layout(layout_id)
	var room := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, depth, stage.layouts.find(l), 0)
	room.fight_seed = fight_seed
	game.rooms._enter(room)
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	return game


func test_the_sag_hurts_both_and_is_named() -> void:
	var game := _enter(&"sanctuary", 8)
	var pf := game.rooms.plates_also
	assert_not_null(pf, "the third hazard of the Santuário runs")
	assert_eq(pf.hazard.def.plate_source, Ground.SAG_SOURCE)
	var h := pf.hazard.def
	var at := h.plates[1].get_center()
	var e := game.horde.spawn(game.horde.def(&"guard"), at + Vector2(0.5, 0), false)
	game.player.place(at)
	game.player.invuln = 0.0
	var hp := game.player.hp
	for i in roundi(16.0 / DT):
		game.player.place(at)
		e.pos = at + Vector2(0.5, 0)
		pf.step(DT)
		game.ground.step(DT)
		if game.player.hp < hp:
			break
	assert_almost_eq(game.player.hp, hp - 10.0, 0.01, "10 to him standing on it")
	assert_eq(game.last_hurt.get("attack", &""), Ground.SAG_SOURCE)
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Laje que Cedeu")
	assert_lt(e.hp, e.max_hp, "and the enemy on it")


func test_the_grate_hurts_both_and_is_named() -> void:
	var game := _enter(&"crypt", 11)
	var bf := game.rooms.bands
	assert_not_null(bf)
	assert_eq(bf.hazard.def.band_source, Ground.SPIKES_SOURCE)
	assert_almost_eq(bf.hazard.cycle, 2.8, 0.001, "deep in the descent: the short cycle")
	var r := bf.hazard.def.bands[0]
	var at := r.get_center()
	var e := game.horde.spawn(game.horde.def(&"guard"), at + Vector2(0.3, 0), false)
	game.player.place(at)
	game.player.invuln = 0.0
	var hp := game.player.hp
	for i in roundi(12.0 / DT):
		game.player.place(at)
		e.pos = at + Vector2(0.3, 0)
		bf.step(DT)
		game.ground.step(DT)
		if game.player.hp < hp:
			break
	assert_almost_eq(game.player.hp, hp - 10.0, 0.01, "10 to him in the grate")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Grade de Espinhos")
	assert_lt(e.hp, e.max_hp)


func test_the_relic_spots() -> void:
	for id in [&"crypt", &"rift", &"garden", &"sanctuary"]:
		var base := _layout(id)
		for v in base.variants.size() + 1:
			var l := base.variant(v)
			assert_eq(l.relic_spots.size(), 1, "%s%d has a spot" % [id, v])
			var p := l.relic_spots[0]
			assert_true(l.floor.contains(p, 0.8), "%s%d: on the floor" % [id, v])
			assert_gte(p.distance_to(l.hero_spawn), 8.0, "%s%d: far from the way in" % [id, v])
			for e in l.exits:
				assert_false(e.mouth.grow(2.0).has_point(p), "%s%d: off the doors" % [id, v])
			for o in l.obstacles:
				assert_false(o.rect().grow(0.8).has_point(p) and o.blocks_move, "%s%d: off the obstacles" % [id, v])
			var hz := l.hazard
			while hz != null:
				for r in _rects(hz):
					assert_false(r.grow(1.5).has_point(p), "%s%d: off the hazards" % [id, v])
				hz = hz.also


## The relic stands after the fight, gives once with interact and the robot goes to it.
func test_the_relic_gives_once() -> void:
	var seen := {}
	for fs in 12:
		var game := _enter(&"crypt", 5, fs)
		game.rooms._relic_cleared()
		var rel: RelicFloor = game.rooms._relic
		if rel == null:
			continue
		seen[rel.gives] = true
		game.rooms.phase = Rooms.Phase.OPEN
		game.player.place(rel.at)
		assert_true(game.rooms.usable(), "it is there to use")
		assert_eq(game.rooms.use_kind(), &"relic")
		var gold := game.rooms.gold
		var silver := game.materials.total(MaterialPurse.SILVER)
		game.rooms.use()
		game.rooms._step_relic()
		assert_true(rel.spent)
		if rel.gives == &"gold":
			assert_eq(game.rooms.gold, gold + stage.relic_gold)
		else:
			assert_eq(game.materials.total(MaterialPurse.SILVER), silver + stage.relic_silver)
		game.rooms.use()
		game.rooms._step_relic()
		assert_false(game.rooms.usable(), "once")
		assert_eq(game.rooms.bot_goal() == rel.at, false, "the robot leaves it")
	assert_true(seen.has(&"gold") and seen.has(&"silver"), "both gifts come up in 12 fights")
	# too early in the descent: none
	var early := _enter(&"crypt", 1)
	early.rooms._relic_cleared()
	assert_null(early.rooms._relic)
