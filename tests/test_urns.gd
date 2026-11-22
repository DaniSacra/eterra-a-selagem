extends GutTest
## The oil urns (RP-12, the Hades II's barrel; docs/design/rooms_progression.md, combat_cadence.md 9.3 and 9.4): two
## in the Cripta A, at the foot of the east and north walls. A blow of the paladin lights one; its ring of 2.5 m warns
## 1.3 s and blasts 10 to him and 80 to each enemy in it; the oil then runs down its channel at 3 m/s, each stretch of
## 2 m warned 1.0 s before the flame, 5 to him and 40 to an enemy, burning 2 s. Once per urn; asleep before two thirds
## of the descent. Never within 6 m of the way in, never over the room's slabs nor a door. In a real room it hurts both,
## names "Urna de Óleo" / "Óleo em Chamas" and the room counts it.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0
const ARC := ComboNode.Shape.ARC

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _crypt() -> RoomLayout:
	for l in stage.layouts:
		if l.id == &"crypt":
			return l
	return null


## The data: the urns stand on the floor as bodies, off the way in, rings and oil off the slabs and the doors, the oil
## whole on the floor and every stretch left by a step of 1.5 m sideways.
func test_where_the_urns_stand() -> void:
	var l := _crypt()
	var h := l.hazard.also
	assert_not_null(h, "Cripta A has its urns")
	assert_eq(h.kind, HazardDef.Kind.URNS)
	assert_gte(h.warn, 1.3, "combat_cadence.md 9.4: 1.3 s with the 10")
	assert_almost_eq(h.urn_radius, 2.5, 0.01, "a ring of 2.5 m")
	assert_gte(h.flow_lead, 1.0, "every stretch warned 1.0 s or more")
	assert_eq(h.hero_damage, 10.0)
	assert_gte(h.from_progress, 0.6, "late")
	var slabs := l.hazard.plates
	var doors: Array[Rect2] = []
	for e in l.exits:
		doors.append(e.mouth.grow(0.5))
	for i in h.urns.size():
		var u := h.urns[i]
		assert_true(l.floor.contains(u), "urn %d on the floor" % i)
		var body := false
		for o in l.obstacles:
			if o.piece == &"oil_urn" and o.center == u:
				body = true
		assert_true(body, "urn %d has its body in the data" % i)
		var ring := Rect2(u - Vector2.ONE * h.urn_radius, Vector2.ONE * h.urn_radius * 2.0)
		assert_gt(u.distance_to(l.hero_spawn) - h.urn_radius, 6.0, "ring %d off the way in" % i)
		for s in slabs:
			assert_gt(_rect_circle_gap(s, u), h.urn_radius - 0.35, "ring %d off the slabs (never two on a point)" % i)
		var f := h.flow_of(i)
		var a := Vector2(f.x, f.y)
		var b := Vector2(f.z, f.w)
		var dir := (b - a).normalized()
		var side := Vector2(-dir.y, dir.x)
		for k in 21:
			var p := a.lerp(b, k / 20.0)
			assert_true(l.floor.contains(p), "oil %d on the floor at %s" % [i, p])
			assert_gt(p.distance_to(l.hero_spawn), 6.0, "oil %d off the way in" % i)
			for s in slabs:
				assert_false(s.grow(h.flow_width * 0.5).has_point(p), "oil %d off the slabs at %s" % [i, p])
			for d in doors:
				assert_false(d.grow(h.flow_width * 0.5 - 0.3).has_point(p), "oil %d off the doors at %s" % [i, p])
			assert_true(l.floor.contains(p + side * 1.5) or l.floor.contains(p - side * 1.5), "a step out of the oil")
		assert_eq(ring.size.x, h.urn_radius * 2.0)
	# AT-H2: Cripta B has no urns, its second hazard is the niche's skeleton
	assert_eq(l.variant(1).hazard.also.plate_source, Ground.NICHE_SOURCE, "Cripta B: no urns, the niche")


static func _rect_circle_gap(r: Rect2, c: Vector2) -> float:
	var q := Vector2(clampf(c.x, r.position.x, r.end.x), clampf(c.y, r.position.y, r.end.y))
	return q.distance_to(c)


## The clock: lit, the ring blasts at warn; each stretch warns flow_lead before the flame and is struck as it comes,
## in order; burns `burn` s; once per urn; asleep: never.
func test_the_fuse_and_the_running_oil() -> void:
	var h := _crypt().hazard.also
	var u := UrnHazard.new(h)
	assert_true(u.light(0))
	assert_false(u.light(0), "once")
	var t := 0.0
	var blast := -1.0
	var armed: Dictionary = {}
	var reached: Dictionary = {}
	for i in roundi(8.0 / DT):
		t += DT
		var did := u.step(DT)
		if (did.blasted as PackedInt32Array).size() > 0:
			blast = t
		for p: Array in did.armed:
			armed[p[1]] = t
		for p: Array in did.reached:
			reached[p[1]] = t
	assert_almost_eq(blast, h.warn, 0.02, "the ring blasts at its warning's end")
	assert_eq(armed.size(), u.stretches[0].size())
	for k in armed:
		assert_almost_eq(reached[k] - armed[k], h.flow_lead, 0.02, "stretch %d warned %.1f s" % [k, h.flow_lead])
		if k > 0:
			assert_gt(reached[k], reached[k - 1], "the flame runs in order")
	assert_eq(u.stage[0], UrnHazard.Stage.DONE, "burnt out")
	var asleep := UrnHazard.new(h, false)
	assert_false(asleep.light(0), "asleep: a blow only rings")


## In a real room (late): a blow lights the urn; the ring blasts him 10 and an enemy 80; the oil strikes an enemy in it
## 40; "Urna de Óleo"; counted.
func test_in_a_real_room_it_blasts_and_burns() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _crypt()
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 9, stage.layouts.find(l), 0)
	game.rooms._enter(r)
	var uf := game.rooms.urns
	assert_not_null(uf, "a late Cripta A has its urns")
	assert_not_null(game.rooms.plates, "beside its slabs")
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	var h := uf.hazard.def
	var urn := h.urns[0]
	var f := h.flow_of(0)
	var hero := urn + Vector2(-1.6, 0.6)
	var in_ring := game.horde.spawn(game.horde.def(&"guard"), urn + Vector2(0.2, 1.4), false)
	var oil_at := Vector2(f.z, f.w) + Vector2(1.0, 0.0)
	var in_oil := game.horde.spawn(game.horde.def(&"guard"), oil_at, false)
	game.player.place(hero)
	game.player.invuln = 0.0
	var hp := game.player.hp
	game.combat.reached.emit(ARC, hero, (urn - hero).normalized(), 2.5, 120.0)
	assert_eq(uf.hazard.stage[0], UrnHazard.Stage.LIT, "the blow lit it")
	for i in roundi(6.0 / DT):
		if i < roundi(h.warn / DT) + 2:
			game.player.place(hero)
		else:
			game.player.place(Vector2(-6, 6))  # out of the oil
		in_ring.pos = urn + Vector2(0.2, 1.4)
		in_oil.pos = oil_at
		uf.step(DT)
		game.ground.step(DT)
	assert_almost_eq(hp - game.player.hp, 10.0, 0.01, "the blast 10 to him")
	assert_eq(T.t(DefeatCause.text_key({"attack": &"urn"})), "Urna de Óleo")
	assert_eq(T.t(DefeatCause.text_key({"attack": &"oil"})), "Óleo em Chamas")
	assert_almost_eq(in_ring.max_hp - in_ring.hp, 80.0, 0.01, "the blast 80 to the enemy in it")
	assert_almost_eq(in_oil.max_hp - in_oil.hp, 40.0, 0.01, "the oil 40 to the enemy in it")
	game.rooms._room_cleared()
	assert_null(game.rooms.urns)
	var room: Dictionary = game.room_tally.rooms(game.time)[-1]
	var hz: Dictionary = room.get("hazard", {})
	var urns: Dictionary = RoomTally.find_hazard(hz, "urn")
	assert_eq(urns.get("kind"), "urn")
	assert_eq(int(urns.get("blasts", 0)), 1)
	assert_almost_eq(float(urns.get("hero_damage", 0.0)), 10.0, 0.01)
	assert_almost_eq(float(urns.get("oil_damage", 0.0)), 40.0, 0.01)
