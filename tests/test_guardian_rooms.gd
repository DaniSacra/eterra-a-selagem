extends GutTest
## The guardians' houses (Daniel, 2026-11-23): the Knight's hall (a square of 22 m, the vault's stones and a plate that
## raises spikes in each corner) and the Elder's chamber (a square of 24 m, four tall columns to hide behind from his
## orbs). RunMap sends each guardian to his own house, at any depth, the second one too; the houses are never an ordinary
## fight's arena; the hazards keep the room's rules (10 to him, 60 to an enemy, warned, off the way in and the doors, a
## way off every plate); the columns stop bodies and shots.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0
const WALK := 6.75
const REACTION := 0.25

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _house(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


func test_each_guardian_has_his_house_and_the_santuario_is_a_plain_room() -> void:
	var k := _house(&"knight_hall")
	var e := _house(&"elder_hall")
	assert_true(k.guardian_home and e.guardian_home)
	assert_eq(k.guardian_id, &"knight")
	assert_eq(e.guardian_id, &"priest_elder")
	assert_eq(k.floor.extent(), Vector2(11, 11), "22 m a side")
	assert_eq(e.floor.extent(), Vector2(12, 12), "24 m a side")
	var s := _house(&"sanctuary")
	assert_false(s.guardian_home, "the Santuário is an ordinary room")
	assert_ne(T.t(k.name_key), String(k.name_key))
	assert_ne(T.t(e.name_key), String(e.name_key))
	assert_ne(T.t(&"killer_spikeplate"), "killer_spikeplate")


func test_the_map_sends_every_guardian_home() -> void:
	var seen := {}
	for s in 300:
		var map := RunMap.new(stage, s)
		var home_ids := [&"knight_hall", &"elder_hall"]
		for r in map.nodes:
			if r.kind == RunMap.Kind.MINIBOSS and r.depth == map.miniboss_depth:
				var want := &"knight_hall" if r.guardian == &"knight" else &"elder_hall"
				assert_eq(stage.layouts[r.layout].id, want, "seed %d: first guardian %s" % [s, r.guardian])
				seen[r.guardian] = true
			elif home_ids.has(stage.layouts[r.layout].id) if r.layout >= 0 else false:
				assert_eq(r.kind, RunMap.Kind.MINIBOSS, "seed %d: a house holds only a guardian's fight" % s)
		if map.miniboss2_depth > 0:
			var first := map.layer(map.miniboss_depth)[s % 2]
			map.enter(first)
			var second := map.layer(map.miniboss2_depth)[0]
			assert_ne(second.guardian, first.guardian)
			var want2 := &"knight_hall" if second.guardian == &"knight" else &"elder_hall"
			assert_eq(stage.layouts[second.layout].id, want2, "seed %d: the second guardian is at home too" % s)
			assert_eq(second.arena, want2)
	assert_eq(seen.size(), 2, "both guardians met")


func _doors(l: RoomLayout) -> Array[Rect2]:
	var out: Array[Rect2] = []
	for e in l.exits:
		out.append(e.mouth)
	return out


func _stand(l: RoomLayout, q: Vector2) -> bool:
	if not l.floor.contains(q, Player.RADIUS * 0.5):
		return false
	for o in l.obstacles:
		if o.blocks_move and o.depth(q, Player.RADIUS) > 0.0:
			return false
	return true


func test_the_knights_hall_has_a_plate_and_stones_in_each_corner() -> void:
	var l := _house(&"knight_hall")
	var plates := l.hazard
	assert_eq(plates.kind, HazardDef.Kind.PLATES)
	assert_eq(plates.plate_source, &"spikeplate")
	assert_eq(plates.plates.size(), 4)
	assert_gte(plates.warn, 1.2, "never under an enemy's wind-up")
	assert_almost_eq(plates.hero_damage, 10.0, 0.001)
	assert_almost_eq(plates.enemy_damage, 60.0, 0.001)
	assert_gte(plates.start_delay, 3.0)
	var rocks := plates.also
	assert_eq(rocks.kind, HazardDef.Kind.DROPS)
	assert_eq(rocks.drop_zones.size(), 4)
	assert_lte(rocks.drop_count, 2, "R9")
	assert_gte(rocks.warn, 1.2)
	assert_almost_eq(rocks.hero_damage, 10.0, 0.001)
	assert_almost_eq(rocks.enemy_damage, 60.0, 0.001)
	assert_lte(rocks.from_progress, EncounterGen.progress(stage, 5), "awake at the first guardian")
	assert_lte(plates.from_progress, EncounterGen.progress(stage, 5))
	var corners := [Vector2(-1, -1), Vector2(-1, 1), Vector2(1, 1), Vector2(1, -1)]
	for c: Vector2 in corners:
		var stones := rocks.drop_zones.filter(func(z: Rect2) -> bool: return z.get_center().x * c.x > 5.0 and z.get_center().y * c.y > 5.0)
		assert_eq(stones.size(), 1, "stones in the corner %s" % c)
	# RD2-10: the plates lie flush against the walls where the charges end, on the sides and the south wall
	for r in plates.plates:
		var flush := absf(r.position.x) > 8.5 and (r.position.x < -10.9 or r.end.x > 10.9) or r.end.y > 10.9
		assert_true(flush, "plate %s flush against a wall" % r)
	for z in rocks.drop_zones:
		for k in 11:
			for j in 11:
				var p := z.position + z.size * Vector2(k / 10.0, j / 10.0)
				assert_gte(p.distance_to(l.hero_spawn), 6.0, "stones 6 m off the way in at %s" % p)
	for i in plates.plates.size():
		var r := plates.plates[i]
		for x in 13:
			for z in 13:
				var p := r.position + Vector2(x, z) * (r.size.x / 12.0)
				assert_true(l.floor.covers(p), "plate %d whole on the floor at %s" % [i, p])
		for e in l.exits:
			assert_false(e.mouth.grow(0.5).intersects(r), "plate %d off a door" % i)
		for s in l.spawns + l.late_spawns:
			assert_false(s.intersects(r), "plate %d off a spawn" % i)
		assert_gte(l.hero_spawn.clamp(r.position, r.end).distance_to(l.hero_spawn), 6.0, "plate %d 6 m off the way in" % i)
		assert_gte(l.boss_spawn.clamp(r.position, r.end).distance_to(l.boss_spawn), 3.0, "plate %d off the guardian" % i)
		# a way off it walking before it strikes
		var reach := (plates.warn - REACTION) * WALK
		for x in 6:
			for z in 6:
				var p := r.position + Vector2(x + 0.5, z + 0.5) * (r.size.x / 6.0)
				var out := false
				for k in 16:
					var d := Vector2.RIGHT.rotated(TAU * k / 16.0)
					var s := 0.0
					while s <= reach and _stand(l, p + d * s):
						if not r.grow(Player.RADIUS * 0.6).has_point(p + d * s):
							out = true
							break
						s += 0.1
					if out:
						break
				assert_true(out, "a way off plate %d from %s" % [i, p])


func test_the_stones_of_the_hall_keep_their_rules() -> void:
	var l := _house(&"knight_hall")
	var h := l.hazard.also
	var d := DropHazard.new(h, l.floor, _doors(l), 7)
	var hero := Vector2(0, 0)  # (out of every zone: nothing is aimed)
	var t := 0.0
	var first := INF
	var count := 0
	var corners := {}
	for i in roundi(240.0 / DT):
		t += DT
		if i == roundi(120.0 / DT):
			hero = Vector2(-8.5, -8.5)  # (then in a corner: half aimed at him)
		var did := d.step(DT, hero, [], 2)
		for r: Rect2 in did.armed:
			count += 1
			first = minf(first, t)
			corners[Vector2(signf(r.get_center().x), signf(r.get_center().y))] = true
			for p in [r.position, r.end, r.get_center()]:
				assert_true(l.floor.covers(p))
			for door in _doors(l):
				assert_false(door.intersects(r))
		assert_lte(d.warming(), 2)
	assert_gte(first, 3.0, "nothing in the first 3 s")
	assert_gt(count, 15)
	assert_gt(d.aimed, count / 5, "some aimed at him in his corner")
	assert_eq(corners.size(), 4, "every corner gets its stones %s" % [corners.keys()])


## The Elder's columns: four, tall, stopping bodies and shots, each wide enough to hide a paladin from a fan of orbs.
func test_the_elders_columns_hide_the_paladin() -> void:
	var l := _house(&"elder_hall")
	assert_null(l.hazard, "no hazard but the columns")
	var cols := l.obstacles.filter(func(o: ArenaObstacle) -> bool: return o.piece == &"column")
	assert_eq(cols.size(), 4)
	var orb_r := 0.35
	for o: ArenaObstacle in cols:
		assert_true(o.blocks_move and o.blocks_shots)
		assert_gte(o.height, 4.0, "tall")
		assert_eq(o.shape, ArenaObstacle.Shape.CIRCLE)
		assert_true(l.floor.contains(o.center, 4.0), "a way round it")
		# the elder 7 m off one side, the paladin 1.4 m behind the column: the fan's five threads (84 degrees, 21 between)
		for side in 8:
			var dir := Vector2.RIGHT.rotated(TAU * side / 8.0)
			var elder := o.center + dir * 7.0
			var hero := o.center - dir * (o.radius + Player.RADIUS + 0.4)
			for k in 5:
				var aim := (hero - elder).normalized().rotated(deg_to_rad(-42.0 + 21.0 * k))
				var through := o.hit_by(elder, elder + aim * 12.0, orb_r)
				var passes_hero := Geometry2D.get_closest_point_to_segment(hero, elder, elder + aim * 12.0).distance_to(hero) < Player.RADIUS + orb_r
				if passes_hero:
					assert_gte(through, 0.0, "the column stops the orb that would hit him (side %d, orb %d)" % [side, k])
		for p: Vector2 in l.exits.map(func(e: ArenaExit) -> Vector2: return e.at):
			assert_gt(p.distance_to(o.center), 3.0)
	# the way in and the guardian's rise clear of the columns
	for o: ArenaObstacle in cols:
		assert_gt(o.center.distance_to(l.hero_spawn), 4.0)
		assert_gt(o.center.distance_to(l.boss_spawn), 3.0)


## In a real room: the Knight's hall strikes with its plates (10 and 60, named "Laje de Espinhos") and the stones; the
## second guardian's escort fits; the Elder's chamber stands with its columns and no hazard.
func test_in_a_real_room() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _house(&"knight_hall")
	var r := RunMap.Room.new(RunMap.Kind.MINIBOSS, RunMap.Reward.BOON, 5, stage.layouts.find(l), 0)
	r.guardian = &"knight"
	game.rooms._enter(r)
	var pf := game.rooms.plates
	assert_not_null(pf, "the plates of the hall")
	assert_true(pf.hazard.awake, "awake at the first guardian")
	assert_not_null(game.rooms.drops, "and its stones")
	assert_true(game.rooms.drops.hazard.awake)
	assert_eq(pf.nodes.size(), 4)
	assert_not_null(pf.pieces[0], "drawn as the grate's piece")
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	var slab := l.hazard.plates[1]
	game.player.place(slab.get_center())
	game.player.invuln = 0.0
	var e := game.horde.spawn(game.horde.def(&"skeleton"), slab.get_center() + Vector2(0.6, 0.6), false)
	var hp := game.player.hp
	for i in roundi(8.0 / DT):
		game.player.place(slab.get_center())
		e.pos = slab.get_center() + Vector2(0.6, 0.6)
		pf.step(DT)
		game.ground.step(DT)
		if game.rooms.drops != null:
			game.rooms.drops.step(DT)
		if not e.alive or game.player.hp < hp - 9.9:
			break
	assert_almost_eq(game.player.hp, hp - 10.0, 0.01, "the paladin on it loses 10")
	assert_lte(e.hp, e.max_hp - 59.9, "the enemy on it 60")
	assert_eq(game.last_hurt.get("attack", &""), &"spikeplate")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Laje de Espinhos")


func test_the_second_guardian_fits_with_his_escort() -> void:
	for id: StringName in [&"knight_hall", &"elder_hall"]:
		var l := _house(id)
		var guardian: EnemyDef = load("res://data/enemies/%s.tres" % l.guardian_id)
		assert_false(guardian.escort.is_empty(), "%s has an escort" % l.guardian_id)
		var alive := EncounterGen.in_room(EncounterGen.alive_range(stage, stage.miniboss_tier), l)
		assert_gte(alive.y, 1 + guardian.escort.size(), "the escort fits at once")
		for z in l.spawns + l.late_spawns:
			assert_true(l.floor.contains(z.get_center(), 2.0))
			for o in l.obstacles:
				if o.blocks_move:
					assert_lt(o.depth(z.get_center(), 0.0), 0.0, "the spawn's middle off %s" % o.piece)
