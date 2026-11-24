extends GutTest
## AT-Q1, the things a blow breaks (docs/art/at_q0_breakables.md, combat_cadence.md 9.6): the rules (once, a crate
## twice, never by touch, by each source), the places (Salão, Crypt A and B), and in a real room: a struck swing breaks
## it, a swing cut by the dodge does not, the aim assist never turns to one, it stops no body, it changes nothing of the
## blow and the room's line in the RESULT counts it.

const F := 1.0 / 60.0
const ARC := ComboNode.Shape.ARC
const P := BreakablePiece.Form

var stage: StageDef = load("res://data/stages/catacombs.tres")
var game: Game
var pad: Controls.VirtualPad


func after_each() -> void:
	Controls.virtual = null
	Controls.flush()
	Engine.time_scale = 1.0


func _pieces() -> Array[BreakablePiece]:
	var out: Array[BreakablePiece] = [BreakablePiece.make(P.VASE, Vector2(2, 0), 0.6, 0),
		BreakablePiece.make(P.CRATE, Vector2(0, 2), 0.7, 0), BreakablePiece.make(P.URN, Vector2(-6, 0), 0.8, 1)]
	return out


func test_a_blow_breaks_once_and_a_crate_takes_two() -> void:
	var b := Breakables.new(_pieces())
	assert_eq(b.count(), 3)
	var did := b.swing(ARC, Vector2.ZERO, Vector2.RIGHT, 2.5, 120.0)
	assert_eq(did.broken, [0] as Array[int], "the vase ahead breaks")
	assert_true(did.cracked.is_empty())
	did = b.swing(ARC, Vector2.ZERO, Vector2.RIGHT, 2.5, 120.0)
	assert_true(did.broken.is_empty(), "a broken vase never breaks again")
	did = b.circle(Vector2(0, 2), 0.5, Breakables.Source.ENEMY)
	assert_eq(did.cracked, [1] as Array[int], "the first blow cracks the crate")
	did = b.circle(Vector2(0, 2), 0.5, Breakables.Source.HAZARD)
	assert_eq(did.broken, [1] as Array[int], "the second breaks it")
	assert_eq(b.tally(), {"total": 3, "broken": 2, "by_hero": 1, "by_enemy": 0, "by_hazard": 1})
	assert_false(b.broken(2), "the urn far away stands")


func test_each_material_and_its_reach() -> void:
	for f in P.values():
		var r := Breakables.radius_of(f, 1.0)
		assert_lte(r, Breakables.MAX_RADIUS, "never wider than %s m: nothing stops a body" % Breakables.MAX_RADIUS)
		assert_true(Breakables.SOUND.has(Breakables.material_of(f)), "each material has its sound")
	assert_eq(Breakables.material_of(P.CRATE), Breakables.Stuff.WOOD)
	assert_eq(Breakables.material_of(P.SAPLING), Breakables.Stuff.BRANCH)
	assert_eq(Breakables.material_of(P.WATER), Breakables.Stuff.WATER)


## Every piece of the Salão and the Crypt A and B on the floor, off every piece, 1.5 m or more from a door, the way in,
## the reward, a spawn, a slab that strikes and a hazard's band; in the Salão off the fountain and the shop's row.
func test_where_they_stand() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	var right := Feel.screen_to_floor(Vector2.RIGHT, Feel.live().cam_yaw)
	for id: StringName in [&"hall", &"crypt"]:
		var base: RoomLayout = null
		for l: RoomLayout in stage.layouts:
			if l.id == id:
				base = l
		assert_not_null(base)
		for v in base.variant_count():
			var l := base.variant(v)
			a.build(l, 3, 1406)
			var name := "%s %d" % [id, v]
			assert_between(l.breakables.size(), 4, 10, "%s: 4 to 10 pieces" % name)
			var groups := {}
			for p in l.breakables:
				groups[p.group] = int(groups.get(p.group, 0)) + 1
				assert_true(a.inside(p.at, p.radius), "%s: %s on the floor" % [name, p.at])
				assert_false(a.overlaps(p.at, p.radius), "%s: %s off every piece" % [name, p.at])
				assert_between(p.height, 0.35, 1.0, "%s: low" % name)
				for z in a.exit_zones:
					assert_gte(_rect_gap(z, p.at), 1.5, "%s: %s off a door" % [name, p.at])
				for d in a.exit_zones.size():
					assert_gte(p.at.distance_to(a.door_label(d)), 1.5, "%s: %s off a door's mark" % [name, p.at])
				assert_gte(p.at.distance_to(a.start), 1.5, "%s: off the way in" % name)
				assert_gte(p.at.distance_to(a.resolve(a.middle, 1.0)), 1.5, "%s: off the reward" % name)
				for r in l.spawns + l.late_spawns:
					assert_gte(_rect_gap(r, p.at), 1.5, "%s: %s off a spawn" % [name, p.at])
				if l.hazard != null:
					for r in l.hazard.plates:
						assert_gte(_rect_gap(r, p.at), 1.5, "%s: %s off a slab" % [name, p.at])
					for aim in l.hazard.aims:
						var from := Vector2(aim.x, aim.y)
						var to := Vector2(aim.z, aim.w)
						var q := Geometry2D.get_closest_point_to_segment(p.at, from, to)
						assert_gte(p.at.distance_to(q), 1.5 + l.hazard.aim_width * 0.5, "%s: off a slit's band" % name)
				for o in l.obstacles:
					if o.piece == &"oil_urn":
						assert_gte(p.at.distance_to(o.center), 1.5, "%s: never by an oil urn" % name)
				if id == &"hall":
					assert_gte(p.at.distance_to(Rooms.FOUNTAIN_SPOT), 5.0, "%s: 5 m off the fountain (AT-FO3)" % name)
					for k in 5:
						var item := Rooms.SHOP_SLOTS[k]
						assert_gte(p.at.distance_to(item), 3.0, "%s: off the shop's items" % name)
			for g in groups:
				assert_between(int(groups[g]), 2, 5, "%s: groups of 2 to 5" % name)


func test_no_breakables_in_the_hub() -> void:
	assert_true(HubPlan.layout().breakables.is_empty())


static func _rect_gap(r: Rect2, p: Vector2) -> float:
	var q := Vector2(clampf(p.x, r.position.x, r.end.x), clampf(p.y, r.position.y, r.end.y))
	return p.distance_to(q)


func _room() -> Player:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	pad = Controls.VirtualPad.new()
	Controls.virtual = pad
	var p := game.player
	p.state = Player.State.MOVE
	p.invuln = 0.0
	p.runner.reset()
	return p


func _frame(p: Player, aim: Vector2, taps: Array = []) -> void:
	for a: StringName in taps:
		pad.press(a)
	p.step(F, pad.move, aim)
	game.combat.step(F)
	game.breaks.step(F)
	pad.end_frame()
	for a: StringName in pad.held.keys():
		pad.release(a)
	pad.released.clear()


## The paladin 1 m from piece i, facing it.
func _by(p: Player, i: int) -> Vector2:
	var at: Vector2 = game.breaks.rules.pieces[i].at
	var dir := (Vector2(0, 0) - at).normalized()
	p.place(at + dir * 1.0)
	p.facing = -dir
	return -dir


func test_a_struck_swing_breaks_it_and_the_room_counts() -> void:
	var p := _room()
	assert_not_null(game.breaks, "the Salão has its vases")
	var aim := _by(p, 0)
	_frame(p, aim, [&"light_attack"])
	for i in 30:
		_frame(p, aim)
	assert_true(game.breaks.rules.broken(0), "the blow breaks the vase 1 m ahead")
	var t: Dictionary = game.room_tally.rooms(game.time)[-1].get("breakables", {})
	assert_eq(int(t.get("broken", 0)), game.breaks.rules.broken_count())
	assert_eq(int(t.get("by_hero", 0)), int(t.get("broken", 0)), "all by him")
	assert_eq(int(t.get("total", 0)), game.breaks.rules.count())
	assert_eq(game.combat.combo, 0, "a vase is not a hit of the combo")


func test_a_swing_cut_by_the_dodge_breaks_nothing() -> void:
	var p := _room()
	var aim := _by(p, 0)
	_frame(p, aim, [&"light_attack"])
	_frame(p, aim, [&"dodge"])
	for i in 30:
		_frame(p, aim)
	assert_false(game.breaks.rules.broken(0), "a cut swing never reaches")


func test_the_blow_keeps_its_times() -> void:
	# the same swing with and without a vase ahead: the same frames for each stage of the blow, the same world rate
	var seen := []
	for with_vase in [false, true]:
		var p := _room()
		var aim := _by(p, 0)
		if not with_vase:
			for i in game.breaks.rules.count():
				game.breaks.rules.life[i] = 0
		var stages := []
		var rates := []
		_frame(p, aim, [&"light_attack"])
		for f in 40:
			_frame(p, aim)
			game.fx.tick(F)
			stages.append(p.runner.stage())
			rates.append(snappedf(game.fx.rate, 0.001))
		seen.append([stages, rates])
		if with_vase:
			assert_true(game.breaks.rules.broken(0), "it broke")
	assert_eq(seen[0][0], seen[1][0], "a vase changes no stage of the blow")
	assert_eq(seen[0][1], seen[1][1], "nor the world's rate (no hit stop of its own)")


func test_the_aim_assist_never_turns_to_a_vase() -> void:
	var p := _room()
	var at: Vector2 = game.breaks.rules.pieces[0].at
	p.place(at + Vector2(1.0, 0.0))
	game.horde.clear_crowd()
	var e := game.horde.spawn(game.horde.def(&"skeleton"), p.pos + Vector2(0.5, -4.0), false)
	p.facing = Vector2(-1.0, -1.0).normalized()  # between the vase (west) and the skeleton (north)
	var dir := p._strike_dir()
	assert_almost_eq(dir.angle_to(e.pos - p.pos), 0.0, 0.01, "the blow turns to the skeleton")
	game.horde.clear_crowd()
	p.facing = Vector2.LEFT
	assert_almost_eq(p._strike_dir().angle_to(Vector2.LEFT), 0.0, 0.01, "with only vases around it turns to none")


func test_it_stops_no_body_nor_shot_and_walking_breaks_nothing() -> void:
	var p := _room()
	var at: Vector2 = game.breaks.rules.pieces[0].at
	assert_almost_eq(game.arena.resolve(at, Player.RADIUS).distance_to(at), 0.0, 0.01, "he may stand on it")
	assert_true(game.arena.cover.filter(func(o: ArenaObstacle) -> bool: return o.center == at).is_empty(), "no cover")
	p.place(at + Vector2(1.5, 0.0))
	pad.move = Vector2.LEFT
	for i in 30:
		_frame(p, Vector2.ZERO)
	assert_lt(p.pos.x, at.x, "he walked through it")
	assert_eq(game.breaks.rules.broken_count(), 0, "never by walking")


func test_an_enemy_blow_and_a_hazard_break_it_where_they_land() -> void:
	_room()
	var at: Vector2 = game.breaks.rules.pieces[0].at
	game.ground.add_warning(at, 0.3, 0.3, 5.0)
	for i in 15:
		game.ground.step(F)
	assert_false(game.breaks.rules.broken(0), "never on the warning's start")
	for i in 15:
		game.ground.step(F)
	assert_true(game.breaks.rules.broken(0), "an enemy's blow breaks it when it lands")
	assert_eq(int(game.breaks.rules.tally().by_enemy), 1)
	var at2: Vector2 = game.breaks.rules.pieces[game.breaks.rules.count() - 1].at
	game.ground.add_hazard(Rect2(at2 - Vector2(0.3, 0.3), Vector2(0.6, 0.6)), 0.1, 7.0, 60.0)
	for i in 12:
		game.ground.step(F)
	assert_eq(int(game.breaks.rules.tally().by_hazard), 1, "a hazard breaks it")


func test_a_wave_breaks_what_it_flies_through() -> void:
	var p := _room()
	var at: Vector2 = game.breaks.rules.pieces[0].at
	p.place(at + Vector2(4.0, 0.0))
	game.projectiles.fire_wave(Projectiles.Kind.WAVE, p.pos, Vector2.LEFT, 40.0, 11.0, 1.4, Color.WHITE, [&"heavy"])
	for i in 20:
		game.projectiles.step(F)
		game.breaks.step(F)
	assert_true(game.breaks.rules.broken(0))
