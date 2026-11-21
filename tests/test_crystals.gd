extends GutTest
## The crystals that discharge (RP-14, H-5; docs/design/rooms_progression.md, combat_cadence.md 9.3): two crystals by
## the north wall of the Câmara das Runas Instáveis B; three blows of the paladin discharge one along its column of
## tiles: the tiles that may light (never the quiet stone, the way in nor a door) warm up 1.2 s with the chevrons and
## strike 10 to him and 60 to each enemy; a pattern of the runes warming up goes dark unstruck (never two on the floor).
## No charge in the first 3 s nor while a discharge is on. In a real room it hurts both, names "Cristal Instável" and the
## room counts it.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0
const ARC := ComboNode.Shape.ARC

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _runes_b() -> RoomLayout:
	for l in stage.layouts:
		if l.id == &"runes":
			return l.variant(1)
	return null


## The data: Runas B has two crystals off the floor by the north wall, each with a column; the A has none.
func test_where_the_crystals_stand() -> void:
	var b := _runes_b()
	var h := b.hazard
	assert_eq(h.crystals.size(), 2, "two crystals in B")
	assert_eq(h.crystal_cols.size(), 2)
	assert_gte(h.warn, 1.0, "warned 1.0 s or more")
	assert_eq(h.hero_damage, 10.0, "A1: 10 to him")
	var floor := b.floor
	for i in h.crystals.size():
		var c := h.crystals[i]
		assert_false(floor.contains(c), "crystal %d stands off the floor" % i)
		assert_gt(c.distance_to(b.hero_spawn), 6.0, "far from the way in")
		# reachable: a blow from the floor before it touches it
		var from := Vector2(c.x, c.y + 1.4)
		assert_true(floor.contains(from), "the floor before crystal %d" % i)
		assert_true(ColumnFall.touches(ARC, from, Vector2.UP, 2.5, 120.0, c, h.crystal_radius), "a blow reaches it")
	for l in stage.layouts:
		if l.id == &"runes":
			assert_eq(l.variant(0).hazard.crystals.size(), 0, "A has none")


## Three blows discharge; one blow charges one crystal; nothing while busy or asleep.
func test_three_blows_discharge() -> void:
	var h := _runes_b().hazard
	var cr := CrystalHazard.new(h)
	var c := h.crystals[0]
	var from := Vector2(c.x, c.y + 1.4)
	for k in 2:
		var got := cr.hit(ARC, from, Vector2.UP, 2.5, 120.0, false)
		assert_eq(int(got.full), -1)
		assert_eq((got.charged as PackedInt32Array).size(), 1)
	assert_eq(int(cr.hit(ARC, from, Vector2.UP, 2.5, 120.0, true).full), -1, "busy: no charge")
	assert_eq(int(cr.hit(ARC, from, Vector2.UP, 2.5, 120.0, false).full), 0, "the third discharges")
	assert_eq(cr.charge[0], 0, "and empties")
	assert_eq(int(cr.hit(ARC, from, Vector2.DOWN, 2.5, 120.0, false).full), -1, "a blow away from it misses")
	var asleep := CrystalHazard.new(h, false)
	for k in 5:
		assert_eq(int(asleep.hit(ARC, from, Vector2.UP, 2.5, 120.0, false).full), -1, "asleep: never")


## The discharge: only the column's tiles that may light, chevrons, warned def.warn; the pattern warming up goes dark;
## the 35% and the unlit neighbour hold.
func test_the_discharge_lights_its_column_only() -> void:
	var l := _runes_b()
	var h := l.hazard
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var a := ArenaHazard.new(h, l.floor, [], rng)
	for i in roundi(4.0 / DT):
		a.step(DT, Vector2.ZERO, 2)
	for col: int in h.crystal_cols:
		assert_true(a.discharge(col), "column %d has tiles to light" % col)
		assert_eq(a.phase, ArenaHazard.Phase.ARM)
		assert_almost_eq(a.left, h.warn, 0.001)
		assert_eq(a.chevron, Vector2(0, 1), "the chevrons run away from the crystal")
		var lit := 0
		for r in h.rows:
			for c in h.cols:
				var i := r * h.cols + c
				if a.lit[i] == 1:
					lit += 1
					assert_eq(c, col, "only its column")
					assert_eq(a.live[i], 1, "only tiles that may light")
					var box := a.tile_rect(c, r)
					for q in h.quiet:
						assert_false(q.grow(-0.01).intersects(box), "never the quiet stone nor the way in")
		assert_gt(lit, 2)
		assert_lte(float(lit) / (h.cols * h.rows), h.max_share, "within the 35%")
		assert_true(a.discharging())
		for i in roundi((h.warn + h.fire + 0.1) / DT):
			a.step(DT, Vector2.ZERO, 2)
		assert_false(a.discharging(), "over after its strike")


## In a real room: three blows, the column strikes him 10 and an enemy 60, "Cristal Instável", counted.
func test_in_a_real_room_it_strikes_and_is_counted() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var base: RoomLayout = null
	for l in stage.layouts:
		if l.id == &"runes":
			base = l
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 7, stage.layouts.find(base), 1)
	game.rooms._enter(r)
	var rf := game.rooms.runes
	assert_not_null(rf)
	assert_not_null(rf.crystals, "Runas B has its crystals")
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	for i in roundi(3.2 / DT):
		rf.step(DT)
		game.ground.step(DT)
	# wait for a quiet moment of the runes (no pattern on the floor) so the column's strike is the crystal's
	var guard := 0
	while rf.hazard.phase != ArenaHazard.Phase.REST and guard < 600:
		rf.step(DT)
		game.ground.step(DT)
		guard += 1
	var h := rf.hazard.def
	var c := h.crystals[0]
	var col := h.crystal_cols[0]
	var tile := rf.hazard.tile_rect(col, 4)
	var at := tile.get_center()
	var from := Vector2(c.x, c.y + 1.4)
	game.player.place(at)
	game.player.invuln = 0.0
	var e := game.horde.spawn(game.horde.def(&"guard"), rf.hazard.tile_rect(col, 2).get_center(), false)
	var hp := game.player.hp
	for k in 3:
		game.combat.reached.emit(ARC, from, Vector2.UP, 2.5, 120.0)
	assert_true(rf.hazard.discharging(), "the third blow discharges")
	for i in roundi((h.warn + 0.2) / DT):
		game.player.place(at)
		e.pos = rf.hazard.tile_rect(col, 2).get_center()
		rf.step(DT)
		game.ground.step(DT)
	assert_almost_eq(game.player.hp, hp - 10.0, 0.01, "10 to him on the column")
	assert_almost_eq(e.max_hp - e.hp, 60.0, 0.01, "60 to the enemy on it")
	assert_eq(game.last_hurt.get("attack", &""), &"crystal")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Cristal Instável")
	game.rooms._room_cleared()
	var room: Dictionary = game.room_tally.rooms(game.time)[-1]
	var hz: Dictionary = room.get("hazard", {})
	assert_eq(int(hz.get("discharges", 0)), 1)
	assert_almost_eq(float(hz.get("crystal_damage", 0.0)), 60.0, 0.01)
	assert_almost_eq(float(hz.get("crystal_hero_damage", 0.0)), 10.0, 0.01)
