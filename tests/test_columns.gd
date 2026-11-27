extends GutTest
## The cracked columns that topple (RP-09; docs/design/rooms_progression.md; the falling tree of the Hades II): the
## paladin's first blow cracks one, the second topples it the way the blow went: a band of 1.2 x 5 m shown 0.6 s, 50 to each
## enemy on it, nothing to him, then a stump that stops bodies and no shots. Once per column per room. In the data:
## Santuário A and B (15, -6) and (-9, 6), Jardim A (4.5, 7), Cripta B (6.5, -6). The bot goes for one that would fall
## on an enemy.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0
const ARC := ComboNode.Shape.ARC

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _layout(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


func _column(at: Vector2) -> ArenaObstacle:
	var o := ArenaObstacle.circle(at, 0.65, &"column", 3.0, true, true)
	o.hits_to_fall = 2
	return o


func test_the_first_blow_cracks_the_second_topples_away_from_him() -> void:
	var f := ColumnFall.new([_column(Vector2(3, 0)), ArenaObstacle.circle(Vector2(0, 3), 0.6, &"column", 3.0)])
	assert_eq(f.columns.size(), 1, "only the cracked one counts")
	var did := f.hit(ARC, Vector2.ZERO, Vector2.RIGHT, 2.5, 120.0)
	assert_eq(Array(did.cracked), [0])
	assert_eq(f.stage[0], ColumnFall.Stage.CRACKED)
	did = f.hit(ARC, Vector2(3, 2.5), Vector2.UP, 2.5, 120.0)
	assert_eq(Array(did.toppled), [0])
	assert_true(f.way[0].is_equal_approx(Vector2.UP), "away from where the blow came from")
	var b := f.band(0)
	assert_eq(b.from, Vector2(3, 0))
	assert_eq(b.length, 5.0)
	did = f.hit(ARC, Vector2.ZERO, Vector2.RIGHT, 2.5, 120.0)
	assert_true((did.cracked as PackedInt32Array).is_empty() and (did.toppled as PackedInt32Array).is_empty(), "once per room")


func test_what_a_blow_reaches() -> void:
	var c := Vector2(3, 0)
	assert_true(ColumnFall.touches(ARC, Vector2.ZERO, Vector2.RIGHT, 2.5, 120.0, c, 0.65), "in the arc")
	assert_false(ColumnFall.touches(ARC, Vector2.ZERO, Vector2.LEFT, 2.5, 120.0, c, 0.65), "behind him")
	assert_false(ColumnFall.touches(ARC, Vector2.ZERO, Vector2.RIGHT, 1.5, 120.0, c, 0.65), "out of reach")
	assert_true(ColumnFall.touches(ComboNode.Shape.CIRCLE, Vector2.ZERO, Vector2.LEFT, 2.5, 0.0, c, 0.65), "the spin")
	assert_true(ColumnFall.touches(ComboNode.Shape.LINE, Vector2.ZERO, Vector2.RIGHT, 4.0, 1.0, c, 0.65), "a thrust")
	assert_false(ColumnFall.touches(ComboNode.Shape.LINE, Vector2.ZERO, Vector2.UP, 4.0, 1.0, c, 0.65), "a thrust aside")


func test_where_the_columns_crack() -> void:
	var want := {&"sanctuary": [[Vector2(15, -6), Vector2(-9, 6)], [Vector2(15, -6), Vector2(-9, 6)]],
		&"garden": [[Vector2(4.5, 7)], []], &"crypt": [[], [Vector2(6.5, -5.2)]]}
	for id: StringName in want:
		var base := _layout(id)
		for v in 2:
			var got: Array[Vector2] = []
			for o in base.variant(v).obstacles:
				if o.hits_to_fall > 0:
					got.append(o.center)
					assert_eq(o.piece, &"column")
					assert_almost_eq(o.fall_damage, 50.0, 0.01)
			assert_eq(got, Array(want[id][v], TYPE_VECTOR2, &"", null), "%s %d" % [id, v])
	var s := ColumnFall.stump(_column(Vector2(1, 2)))
	assert_eq(s.radius, 0.65, "the stump keeps the footprint (nobody ends inside anything new)")
	assert_true(s.blocks_move)
	assert_false(s.blocks_shots, "no more shots")


## In a real room: two blows topple it on the enemy behind it (50), not on him; the stump stops bodies, not shots; the
## room counts it.
func test_in_a_real_room_it_falls_on_them() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _layout(&"sanctuary")
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 3, stage.layouts.find(l), 0)
	game.rooms._enter(r)
	var cf := game.rooms.columns
	assert_not_null(cf, "the sanctuary has its cracked columns")
	assert_eq(cf.count(), 2)
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	var c := Vector2(15, -6)
	var o: ArenaObstacle = null
	for k in cf.fall.columns:
		if k.center == c:
			o = k
	assert_true(game.arena.cover.has(o), "standing, it stops shots")
	var e := game.horde.spawn(game.horde.def(&"guard"), c + Vector2(-3.0, 0.4), false)
	var hero := c + Vector2(2.0, 0.0)
	game.player.place(hero)
	game.player.invuln = 0.0
	var hp := game.player.hp
	game.combat.reached.emit(ARC, hero, Vector2.LEFT, 2.5, 120.0)
	assert_eq(cf.fall.stage[cf.fall.columns.find(o)], ColumnFall.Stage.CRACKED)
	game.combat.reached.emit(ARC, hero, Vector2.LEFT, 2.5, 120.0)
	for i in roundi(1.0 / DT):
		e.pos = c + Vector2(-3.0, 0.4)
		game.player.place(c + Vector2(-1.5, -0.3))  # (he walks under it: it never hurts him)
		cf.step(DT)
		game.ground.step(DT)
	assert_almost_eq(e.max_hp - e.hp, 50.0, 0.01, "50 to the enemy it fell on")
	assert_eq(game.player.hp, hp, "nothing to him")
	assert_false(game.arena.cover.has(o), "the stump stops no shot")
	assert_gt(game.arena.resolve(c, 0.4).distance_to(c), 0.5, "the stump still stops bodies")
	game.rooms._room_cleared()
	assert_null(game.rooms.columns)
	var room: Dictionary = game.room_tally.rooms(game.time)[-1]
	var t: Dictionary = room.get("columns", {})
	assert_eq(int(t.get("toppled", 0)), 1)
	assert_eq(int(t.get("cracked", 0)), 1)
	assert_almost_eq(float(t.get("enemy_damage", 0.0)), 50.0, 0.01)


## The bot goes for a column that would fall on an enemy (from its far side), not on nobody.
func test_the_bot_goes_for_a_column_on_a_pack() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _layout(&"sanctuary")
	game.rooms._enter(RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 3, stage.layouts.find(l), 0))
	game.horde.clear_crowd()
	var c := Vector2(15, -6)
	var p := c + Vector2(3, 0)
	game.horde.spawn(game.horde.def(&"skeleton"), c + Vector2(-8, 3), false)
	assert_null(Bot.column_plan(game, p), "nobody it could fall on: not worth it")
	game.horde.spawn(game.horde.def(&"skeleton"), c + Vector2(-4, -0.4), false)
	var plan: Variant = Bot.column_plan(game, p)
	assert_not_null(plan, "one in reach of its fall: it goes for it")
	assert_eq(plan.center, c)
	assert_lt(plan.way.x, -0.9, "falling toward the pack")
	assert_gt(plan.stand.x, c.x, "swinging from the other side")
