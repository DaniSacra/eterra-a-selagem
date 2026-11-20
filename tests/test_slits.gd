extends GutTest
## The arrow slit tied to a slab (RP-16; docs/design/rooms_progression.md): in the Ossuary (Cripta B) a slit on the
## north wall either side of the dividing wall; the slab on one side arms the slit of the other: its band (1 m across,
## from the slit's mouth to the row of the south sarcophagi) warns 1.0 s in the amber and strikes everyone in it (7 to
## him, 60 to an enemy), not the slab. The bot steps on the slab when two or more enemies stand in the band and he does
## not.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _crypt() -> RoomLayout:
	for l in stage.layouts:
		if l.id == &"crypt":
			return l
	return null


func _band(h: HazardDef, i: int) -> Array:
	var a := h.aims[i]
	return [Vector2(a.x, a.y), Vector2(a.z, a.w)]


func test_where_the_slits_fire() -> void:
	var l := _crypt().variant(1)
	var h := l.hazard
	assert_eq(h.aims.size(), 2, "both slabs of the Ossuary fire a slit")
	assert_almost_eq(h.aim_width, 1.0, 0.001)
	var slits := l.obstacles.filter(func(o: ArenaObstacle) -> bool: return o.piece == &"bolt_slit")
	assert_eq(slits.size(), 2, "two slits")
	for o: ArenaObstacle in slits:
		assert_true(o.blocks_move and o.blocks_shots, "a slit stops bodies and shots")
	var walls := []
	for i in 2:
		assert_true(h.aims_away(i))
		var ab := _band(h, i)
		var a: Vector2 = ab[0]
		var b: Vector2 = ab[1]
		walls.append(signf(a.x - 0.5))
		var mouth := slits.any(func(o: ArenaObstacle) -> bool: return o.center.distance_to(a) < 0.6)
		assert_true(mouth, "band %d starts at a slit's mouth" % i)
		assert_false(h.plates[i].has_point(a.lerp(b, 0.5)) or Bot.in_band(a, b, h.aim_width, h.plates[i].get_center()),
			"slab %d is not in the band it arms" % i)
		for k in 41:
			var q := a.lerp(b, k / 40.0)
			for side in [-0.5, 0.5]:
				var s := q + Vector2(side, 0)
				assert_true(l.floor.covers(s), "band %d on the floor at %s" % [i, s])
				assert_gte(s.distance_to(l.hero_spawn), 6.0, "band %d 6 m from the way in" % i)
		for e in l.exits:
			assert_false(e.mouth.grow(0.5).has_point(a), "band %d off a door" % i)
	assert_ne(walls[0], walls[1], "one each side of the dividing wall")
	assert_eq(_crypt().hazard.aims.size(), 0, "A has no slit")


## In a real room: he steps on the west slab, the east slit strikes the enemy in its band 60, not him; then an enemy
## steps on the east slab and the west slit strikes him 7, "Derrotado por: Seteira". The room counts the slit.
func test_in_a_real_room() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _crypt()
	var room := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 6, stage.layouts.find(l), 1)
	game.rooms._enter(room)
	var pf := game.rooms.plates
	assert_not_null(pf)
	pf.hazard.calm = 0.0
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	var h := pf.hazard.def
	var east: Array = _band(h, 0)
	var foe_at: Vector2 = (east[0] as Vector2).lerp(east[1], 0.6)
	var e := game.horde.spawn(game.horde.def(&"skeleton"), foe_at, false)
	var on := h.plates[0].get_center()
	game.player.invuln = 0.0
	var hp := game.player.hp
	for i in roundi(1.6 / DT):
		game.player.place(on)
		e.pos = foe_at
		pf.step(DT)
		game.ground.step(DT)
	assert_almost_eq(e.max_hp - e.hp, 60.0, 0.01, "the slit strikes the enemy in its band")
	assert_almost_eq(game.player.hp, hp, 0.01, "not him on the slab")
	var west: Array = _band(h, 1)
	var in_band: Vector2 = (west[0] as Vector2).lerp(west[1], 0.85)
	var f := game.horde.spawn(game.horde.def(&"skeleton"), h.plates[1].get_center(), false)
	for i in roundi(1.6 / DT):
		game.player.place(in_band)
		f.pos = h.plates[1].get_center()
		pf.step(DT)
		game.ground.step(DT)
	assert_almost_eq(game.player.hp, hp - 7.0, 0.01, "the other slit strikes him in its band")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Seteira")
	game.rooms._room_cleared()
	var hz: Dictionary = (game.room_tally.rooms(game.time)[-1] as Dictionary).get("hazard", {})
	assert_almost_eq(float(hz.get("slit_damage", 0.0)), 60.0, 0.01)
	assert_eq(int(hz.get("slit_struck", 0)), 1)


## The bot steps on the slab when two enemies stand in the band, not with one, nor when he stands in it.
func test_the_bot_lures_and_steps() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _crypt()
	game.rooms._enter(RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 6, stage.layouts.find(l), 1))
	var pf := game.rooms.plates
	pf.hazard.calm = 0.0
	game.horde.clear_crowd()
	var h := pf.hazard.def
	var east: Array = _band(h, 0)
	var near := h.plates[0].get_center() + Vector2(-2.5, 1.0)
	game.horde.spawn(game.horde.def(&"skeleton"), (east[0] as Vector2).lerp(east[1], 0.5), false)
	assert_null(Bot.slit_plan(game, near), "one enemy: not worth it")
	game.horde.spawn(game.horde.def(&"skeleton"), (east[0] as Vector2).lerp(east[1], 0.7), false)
	var plan: Variant = Bot.slit_plan(game, near)
	assert_not_null(plan, "two in the band: he goes")
	assert_true(h.plates[0].has_point(plan as Vector2), "to the slab that arms that slit")
	assert_null(Bot.slit_plan(game, (east[0] as Vector2).lerp(east[1], 0.3)), "never while he stands in it")
