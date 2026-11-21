extends GutTest
## The floor of the Câmara das Runas Instáveis (E5; docs/art/e5_spec.md 3.2 to 3.4): square tiles in bands and blocks
## (never circles, D-29) that warm up 1.2 s, strike 0.25 s and rest 2.4 s; at most 35% of the tiles lit (50% for the
## dense ones, only with 3 enemies or fewer standing), every lit tile beside an unlit floor tile (unlit floor within
## 3 m of anywhere), nothing in the first 3 s, on a door's tiles, on the quiet stone or on a tile cut by the edge. In a
## real room it hurts the paladin and the enemies standing on it.

const STAGE := "res://data/stages/catacombs.tres"

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _runes() -> RoomLayout:
	for l in stage.layouts:
		if l.id == &"runes":
			return l
	return null


func _doors(l: RoomLayout) -> Array[Rect2]:
	var out: Array[Rect2] = []
	for e in l.exits:
		out.append(e.mouth)
		out.append(e.zone)
	return out


func _hazard(v: int, seed_: int) -> ArenaHazard:
	var l := _runes().variant(v)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	return ArenaHazard.new(l.hazard, l.floor, _doors(l), rng)


func test_the_numbers_of_the_spec() -> void:
	var l := _runes()
	assert_not_null(l, "the runes are an arena of the stage")
	for v in l.variant_count():
		var h := l.variant(v).hazard
		assert_not_null(h, "variant %d has its floor" % v)
		assert_eq(h.tile, 3.0)
		assert_eq(Vector2i(h.cols, h.rows), Vector2i(10, 8))
		assert_almost_eq(h.warn, 1.2, 0.001)
		assert_almost_eq(h.fire, 0.25, 0.001)
		assert_almost_eq(h.rest, 2.4, 0.001)
		assert_almost_eq(h.start_delay, 3.0, 0.001)
		assert_almost_eq(h.max_share, 0.35, 0.001)
		for p in h.patterns:
			assert_true(ArenaHazard.PATTERNS.has(p), "%s is a pattern" % p)
	assert_eq(l.hazard.patterns, [&"sweep", &"comb", &"cut"] as Array[StringName], "A: bands")
	assert_eq(l.variant(1).hazard.patterns, [&"checker", &"frame", &"islands"] as Array[StringName], "B: tiles")


func test_cut_corners_doors_and_the_quiet_stone_never_light() -> void:
	var a := _hazard(0, 1)
	for c: Vector2i in [Vector2i(0, 0), Vector2i(9, 0), Vector2i(0, 7), Vector2i(9, 7)]:
		assert_eq(a.live[c.y * 10 + c.x], 0, "the chamfered corner %s never lights" % c)
	# the east door (15, 0): the two tiles of the east edge beside it
	assert_eq(a.live[3 * 10 + 9], 0, "a door's tile never lights")
	assert_eq(a.live[4 * 10 + 9], 0)
	var b := _hazard(1, 1)
	for r in [3, 4]:
		for c in [4, 5]:
			assert_eq(b.live[r * 10 + c], 0, "the quiet stone (%d, %d) never lights" % [c, r])
	assert_eq(a.live[3 * 10 + 4], 1, "the middle of A lights")


## 600 patterns of each variant, the paladin anywhere and 0 to 8 standing: every rule of reading holds.
func test_every_pattern_keeps_the_rules() -> void:
	for v in 2:
		var a := _hazard(v, 7 + v)
		var rng := RandomNumberGenerator.new()
		rng.seed = 40 + v
		var seen := {}
		var t := 0.0
		var armed := 0
		while armed < 600:
			var hero := Vector2(rng.randf_range(-14, 14), rng.randf_range(-11, 11))
			var standing := rng.randi_range(0, 8)
			var ev := a.step(0.05, hero, standing)
			t += 0.05
			if ev != ArenaHazard.Event.ARMED:
				continue
			armed += 1
			seen[a.pattern] = true
			assert_gt(t, a.def.start_delay - 0.001, "nothing in the first seconds")
			var dense := ArenaHazard.DENSE.has(a.pattern)
			if dense:
				assert_lte(standing, a.def.dense_standing, "%s only with few standing" % a.pattern)
			assert_lte(a.share(), (a.def.dense_share if dense else a.def.max_share) + 0.001, "%s: never too much lit" % a.pattern)
			assert_gt(a.share(), 0.0, "%s lights something" % a.pattern)
			assert_true(a.safe_everywhere(), "%s: every lit tile beside an unlit one" % a.pattern)
			var count := 0
			for i in a.lit.size():
				if a.lit[i] == 1:
					count += 1
					assert_eq(a.live[i], 1, "%s lights only tiles that may" % a.pattern)
			# the bands as drawn are exactly the lit tiles, never overlapping
			var area := 0.0
			for r in a.rects():
				area += r.get_area()
				assert_almost_eq(r.size.y, a.def.tile, 0.001, "a band is one tile across")
			assert_almost_eq(area, count * a.def.tile * a.def.tile, 0.01)
			if a.pattern == &"cut":
				var ht := a.tile_at(hero)
				if ht.x >= 0:
					assert_eq(a.lit[ht.y * 10 + ht.x], 0, "the cut never lights his own tile")
		for p in a.def.patterns:
			assert_true(seen.has(p), "variant %d draws %s" % [v, p])


## RP-02: 2000 patterns of each variant, the paladin anywhere and 0 to 8 standing: no lit tile has any of its floor
## within 6 m of the way in (the hero_spawn), the rule of every hazard; the reading rules still hold.
func test_nothing_lights_within_6_m_of_the_way_in() -> void:
	var l := _runes()
	for v in 2:
		var a := _hazard(v, 70 + v)
		var spawn := l.variant(v).hero_spawn
		var rng := RandomNumberGenerator.new()
		rng.seed = 400 + v
		var armed := 0
		var near := 0
		var nearest := INF
		while armed < 2000:
			var ev := a.step(0.05, Vector2(rng.randf_range(-14, 14), rng.randf_range(-11, 11)), rng.randi_range(0, 8))
			if ev != ArenaHazard.Event.ARMED:
				continue
			armed += 1
			for r in a.def.rows:
				for c in a.def.cols:
					if a.lit[r * a.def.cols + c] != 1:
						continue
					var box := a.tile_rect(c, r)
					var d := spawn.distance_to(spawn.clamp(box.position, box.end))
					nearest = minf(nearest, d)
					if d < 6.0:
						near += 1
			if not a.safe_everywhere():
				near += 1000
		assert_eq(near, 0, "variant %d: nothing lit within 6 m of the way in, every lit tile beside an unlit one" % v)
		assert_gte(nearest, 6.0, "variant %d: the nearest lit tile is %.1f m from the way in" % [v, nearest])
	assert_almost_eq(l.hazard.hero_damage, 10.0, 0.001, "A1: the paladin loses 10 (the Hades; was 7 and 4)")
	assert_almost_eq(l.hazard.enemy_damage, 60.0, 0.001, "RP-03: an enemy 60 (a whole soldier)")
	assert_almost_eq(l.variant(1).hazard.hero_damage, 10.0, 0.001)


func test_the_rhythm_warn_strike_rest() -> void:
	var a := _hazard(0, 3)
	var events: Array = []
	var t := 0.0
	while t < 12.0:
		var ev := a.step(0.01, Vector2.ZERO, 2)
		if ev != ArenaHazard.Event.NONE:
			events.append([ev, snappedf(t + 0.01, 0.01)])
		t += 0.01
	assert_eq(events[0][0], ArenaHazard.Event.ARMED)
	assert_almost_eq(float(events[0][1]), 3.0, 0.02, "the first after 3 s")
	assert_eq(events[1][0], ArenaHazard.Event.FIRED)
	assert_almost_eq(float(events[1][1]) - float(events[0][1]), 1.2, 0.02, "1.2 s warming up")
	assert_eq(events[2][0], ArenaHazard.Event.ENDED)
	assert_almost_eq(float(events[2][1]) - float(events[1][1]), 0.25, 0.02, "0.25 s striking")
	assert_eq(events[3][0], ArenaHazard.Event.ARMED)
	assert_almost_eq(float(events[3][1]) - float(events[2][1]), 2.4, 0.02, "2.4 s of rest")
	assert_false(a.is_lit(Vector2(100, 100)), "off the grid nothing is lit")


## In a real room: a band that strikes hurts the paladin standing in it (as a warning) and an enemy too (E5-D3); the
## room's numbers count it; its amber is drawn under the enemies' warnings.
func test_it_hurts_everyone_on_it_in_a_real_room() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rebuild_room(_runes(), 2, 1406)
	game.horde.clear_crowd()
	var rng := RandomNumberGenerator.new()
	var rf := RuneFloor.new(game, _runes().hazard, rng)
	var band := Rect2(-12, -3, 24, 3)
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(-3, -1.5), false)
	var far := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(-3, 5.0), false)
	game.player.place(Vector2(3, -1.5))
	game.player.invuln = 0.0
	var hp := game.player.hp
	var z := game.ground.add_hazard(band, 0.1, 4.0, 35.0)
	rf.zones.append(z)
	assert_eq((z.node.material_override as ShaderMaterial).render_priority, GroundLook.HAZARD_PRIORITY, "drawn under the red")
	assert_eq(int((z.node.material_override as ShaderMaterial).get_shader_parameter(&"style")), GroundLook.Style.HAZARD)
	for i in 10:
		game.ground.step(0.02)
	assert_almost_eq(game.player.hp, hp - 4.0, 0.01, "the paladin on the band loses 4")
	assert_almost_eq(e.max_hp - e.hp, 35.0, 0.01, "the enemy on it loses 35")
	assert_eq(far.hp, far.max_hp, "the one off it nothing")
	assert_almost_eq(rf.enemy_damage, 35.0, 0.01)
	assert_eq(game.last_hurt.get("attack", &""), &"runes", "Derrotado por: Runas Instáveis")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Runas Instáveis")
	rf.stop()
	# a warning of an enemy reused from the pool is drawn as before
	var w := game.ground.add_warning(Vector2.ZERO, 2.0, 1.0, 1.0)
	assert_eq((w.node.material_override as ShaderMaterial).render_priority, 0)


func test_the_fight_in_the_runes_runs_its_floor() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 6, game.rooms.stage.layouts.find(_runes()), 0)
	game.rooms._enter(r)
	assert_not_null(game.rooms.runes, "a fight in the runes has its floor")
	for i in 220:
		game.rooms.step(1.0 / 60.0)
		game.ground.step(1.0 / 60.0)
	assert_gt(game.ground.zones.filter(func(z: Ground.Zone) -> bool: return z.hazard > 0.0).size(), 0, "bands warming after 3.6 s")
	game.rooms._room_cleared()
	assert_null(game.rooms.runes, "the floor stops with the fight")
	var room: Dictionary = game.room_tally.rooms(game.time)[-1]
	assert_true(room.has("hazard"), "the room's numbers say what the floor did")
