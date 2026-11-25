extends GutTest
## The roots that strike in the Jardim (RP-10, H-1; docs/design/rooms_progression.md): a band 3 m across along each
## of the two outer roots; whoever lingers 0.5 s on it (the paladin or an enemy) wakes it, 1.2 s cracking, a strike of
## 0.25 s with the runes' numbers (7 to him, 60 to an enemy) that throws everyone on it 1 m off the root, 6 s before that
## root wakes again; asleep before the 4th room. In the data: each band along its root, on the floor, off the doors,
## the spawns and the middle, 6 m or more from the way in, and a way off it before it strikes. In a real room it hurts
## both, throws them off, names "Raiz Morta" and the room counts it.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0
const WALK := 6.75
const REACTION := 0.25

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _garden() -> RoomLayout:
	for l in stage.layouts:
		if l.id == &"garden":
			return l
	return null


func _def(strips: PackedVector4Array) -> HazardDef:
	var h := HazardDef.new()
	h.kind = HazardDef.Kind.PLATES
	h.strips = strips
	h.strip_width = 3.0
	h.dwell = 0.5
	h.warn = 1.2
	h.fire = 0.25
	h.rearm = 6.0
	h.start_delay = 0.0
	h.push_out = 1.0
	return h


func _stand(l: RoomLayout, q: Vector2) -> bool:
	if not l.floor.contains(q, Player.RADIUS * 0.5):
		return false
	for o in l.obstacles:
		if o.blocks_move and o.depth(q, Player.RADIUS) > 0.0:
			return false
	return true


func test_a_strip_is_a_band_along_its_root() -> void:
	var h := PlateHazard.new(_def(PackedVector4Array([Vector4(0, 0, 4, 4)])), [])
	assert_eq(h.count(), 1)
	assert_true(h.on(0, Vector2(2, 2)), "on its line")
	assert_true(h.on(0, Vector2(2, 2) + Vector2(-1, 1).normalized() * 1.4), "1.4 m across: on")
	assert_false(h.on(0, Vector2(2, 2) + Vector2(-1, 1).normalized() * 1.6), "1.6 m across: off")
	assert_false(h.on(0, Vector2(-0.5, -0.5)), "behind its start: off")
	assert_eq(h.plate_at(Vector2(3.9, 3.8)), 0)
	var b := h.bounds(0)
	assert_true(b.has_point(Vector2(2, 2)) and b.grow(0.01).has_point(Vector2(4, 4) + Vector2(1, -1).normalized() * 1.5),
		"its bounds hold it")


func test_it_wakes_only_to_who_lingers() -> void:
	var h := PlateHazard.new(_def(PackedVector4Array([Vector4(0, 0, 4, 0)])), [])
	var on := Vector2(2, 1)
	for i in roundi(0.4 / DT):
		h.step(DT, on, PackedVector2Array())
	assert_eq(h.phase[0], PlateHazard.Phase.IDLE, "0.4 s on it: still asleep")
	h.step(DT, Vector2(2, 5), PackedVector2Array())
	for i in roundi(0.4 / DT):
		h.step(DT, on, PackedVector2Array())
	assert_eq(h.phase[0], PlateHazard.Phase.IDLE, "stepping off starts the count again")
	for i in roundi(0.15 / DT):
		h.step(DT, on, PackedVector2Array())
	assert_eq(h.phase[0], PlateHazard.Phase.ARM, "0.55 s on it: it wakes")
	assert_eq(h.armed_by_hero, 1)
	for i in roundi(1.5 / DT):
		h.step(DT, Vector2.INF, PackedVector2Array())
	assert_eq(h.phase[0], PlateHazard.Phase.REST, "struck, then rests")
	var enemy := PackedVector2Array([Vector2(1, -1)])
	for i in roundi(5.5 / DT):
		h.step(DT, Vector2.INF, enemy)
	assert_ne(h.phase[0], PlateHazard.Phase.ARM, "6 s before it wakes again")
	for i in roundi(1.2 / DT):
		h.step(DT, Vector2.INF, enemy)
	assert_eq(h.armed_by_enemy, 1, "an enemy lingering wakes it too")


func test_an_enemy_wakes_it_sooner() -> void:
	var def := _def(PackedVector4Array([Vector4(0, 0, 4, 0)]))
	def.enemy_dwell = 0.2
	var h := PlateHazard.new(def, [])
	var foe := PackedVector2Array([Vector2(2, 1)])
	for i in roundi(0.15 / DT):
		h.step(DT, Vector2.INF, foe)
	assert_eq(h.phase[0], PlateHazard.Phase.IDLE, "0.15 s: asleep")
	for i in roundi(0.1 / DT):
		h.step(DT, Vector2.INF, foe)
	assert_eq(h.phase[0], PlateHazard.Phase.ARM, "0.25 s of an enemy: awake")
	assert_eq(h.armed_by_enemy, 1)
	var g := PlateHazard.new(def, [])
	for i in roundi(0.3 / DT):
		g.step(DT, Vector2(2, -1), PackedVector2Array())
	assert_eq(g.phase[0], PlateHazard.Phase.IDLE, "the paladin still needs 0.5 s")


## The data: the two outer roots of each variant, numbered as the plan, each band along its root.
func test_where_the_roots_strike() -> void:
	var base := _garden()
	for v in base.variant_count():
		var l := base.variant(v)
		var h := l.hazard
		assert_not_null(h, "garden %d has roots" % v)
		assert_eq(h.kind, HazardDef.Kind.PLATES)
		assert_eq(h.plate_source, Ground.ROOT_SOURCE)
		assert_eq(h.plates.size(), 0)
		# AT-H3: in B the stub by the west wall became the hostile plant (its own hazard, test_niche_plant.gd)
		assert_eq(h.strips.size(), 2 if v == 0 else 1, "the two outer roots (B: one, and the plant)")
		assert_almost_eq(h.dwell, 0.5, 0.001)
		assert_almost_eq(h.dwell_of_enemy(), 0.05, 0.001, "an enemy only walks over it")
		assert_almost_eq(h.warn, 1.5, 0.001)
		assert_almost_eq(h.rearm, 6.0, 0.001)
		assert_almost_eq(h.push_out, 1.0, 0.001)
		assert_almost_eq(h.hero_damage, 10.0, 0.001)
		assert_almost_eq(h.enemy_damage, 60.0, 0.001)
		assert_almost_eq(h.from_progress, 0.34, 0.001)
		var ph := PlateHazard.new(h, [])
		for i in ph.count():
			var tag := "garden %d root %d" % [v, i]
			var along_root := 0
			for o in l.obstacles:
				if o.piece == &"root" and ph.on(i, o.center):
					along_root += 1
			assert_gt(along_root, 0, "%s: lies along a root" % tag)
			for x in 21:
				for z in 21:
					var p := ph.bounds(i).position + ph.bounds(i).size * Vector2(x, z) / 20.0
					if not ph.on(i, p):
						continue
					assert_true(l.floor.covers(p), "%s: on the floor at %s" % [tag, p])
					assert_gte(p.distance_to(l.hero_spawn), 6.0, "%s: 6 m or more from the way in at %s" % [tag, p])
			for k in 11:
				var mid := ph.from[i] + ph.dirs[i] * ph.lengths[i] * k / 10.0
				assert_gt(mid.length(), 6.0, "%s: the root keeps off the middle at %s" % [tag, mid])
			for e in l.exits:
				assert_false(e.mouth.grow(0.5).intersects(ph.bounds(i)), "%s: off a door" % tag)
			for s in l.spawns:
				assert_false(s.intersects(ph.bounds(i)), "%s: off a spawn" % tag)


## From every spot on a band a person walks off it in the warning less a reaction.
func test_a_way_off_every_root() -> void:
	var reach := (1.2 - REACTION) * WALK
	var base := _garden()
	for v in base.variant_count():
		var l := base.variant(v)
		var ph := PlateHazard.new(l.hazard, [])
		for i in ph.count():
			var b := ph.bounds(i)
			for x in 16:
				for z in 16:
					var p := b.position + b.size * Vector2(x + 0.5, z + 0.5) / 16.0
					if not ph.on(i, p) or not _stand(l, p):
						continue
					var out := false
					for k in 16:
						var d := Vector2.RIGHT.rotated(TAU * k / 16.0)
						var s := 0.0
						while s <= reach and not out:
							var q := p + d * s
							if not _stand(l, q):
								break
							out = not ph.on(i, q)
							s += 0.1
					assert_true(out, "garden %d root %d: a way off from %s" % [v, i, p])


## The push: away from the band's middle line, on either side.
func test_the_push_is_away_from_the_root() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var z := game.ground.add_band(Vector2(0, 0), Vector2.RIGHT, 4.0, 3.0, 1.0, 0.0, 0.0, false, Ground.ROOT_SOURCE)
	assert_almost_eq(PlateFloor.away(z, Vector2(2, 0.7)).y, 1.0, 0.001)
	assert_almost_eq(PlateFloor.away(z, Vector2(2, -0.7)).y, -1.0, 0.001)
	game.ground.clear_warnings()


## In a real room (the 6th): he lingers by a root and loses 7, thrown 1 m off it; an enemy by it loses 60; "Derrotado
## por: Raiz Morta"; the room counts it as roots. In the 2nd room the roots sleep.
func test_in_a_real_room() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _garden()
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 6, stage.layouts.find(l), 0)
	game.rooms._enter(r)
	var pf := game.rooms.plates
	assert_not_null(pf, "a fight in the Jardim has its roots")
	assert_true(pf.hazard.awake)
	assert_eq(pf.nodes.size(), 2)
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	var h := pf.hazard
	var side := Vector2(-h.dirs[0].y, h.dirs[0].x)
	var at := Vector2.INF
	for k in 20:
		var q := h.from[0] + h.dirs[0] * h.lengths[0] * (0.3 + k * 0.03) + side * 1.15
		if _stand(l, q):
			at = q
			break
	assert_ne(at, Vector2.INF, "a spot by the root")
	var foe_at := at - side * 2.3
	game.player.place(at)
	game.player.invuln = 0.0
	var e := game.horde.spawn(game.horde.def(&"skeleton"), foe_at, false)
	var hp := game.player.hp
	var struck_at := Vector2.INF
	for i in roundi(5.0 / DT):
		if struck_at == Vector2.INF:
			game.player.place(at)
			e.pos = foe_at
		pf.step(DT)
		game.ground.step(DT)
		if struck_at == Vector2.INF and game.player.hp < hp:
			struck_at = game.player.pos
	assert_almost_eq(game.player.hp, hp - 10.0, 0.01, "he loses 10")
	assert_almost_eq(e.max_hp - e.hp, 60.0, 0.01, "the enemy 60")
	var off := (struck_at - h.from[0]).cross(h.dirs[0])
	assert_gt(absf(off), 1.15 + 0.6, "thrown off the root")
	assert_eq(game.last_hurt.get("attack", &""), Ground.ROOT_SOURCE)
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Raiz Morta")
	game.rooms._room_cleared()
	var hz: Dictionary = (game.room_tally.rooms(game.time)[-1] as Dictionary).get("hazard", {})
	assert_eq(hz.get("kind"), "roots")
	assert_almost_eq(float(hz.get("enemy_damage", 0.0)), 60.0, 0.01)
	r = RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 2, stage.layouts.find(l), 0)
	game.rooms._enter(r)
	assert_false(game.rooms.plates.hazard.awake, "room 2: asleep")
