extends GutTest
## The chain that sweeps the bridge (RP-11, H-3; docs/design/rooms_progression.md): bands across the decks of the Ponte
## dos Condenados strike in turn, one at a time, every 6 s after 3 s of calm: 1.2 s warming up, 0.25 s striking 7 to
## him and 60 to each enemy (RP-03), pushing everyone in it 2.5 m along the bridge. In the data: A one bridge then the
## other, B the long bridge's halves, never within 4 m of B's landing; every band whole on the deck, every push landing
## on the floor, and from anywhere in a band a dash (5.6 m) along the bridge leaves it for floor out of every band. In a
## real room it hurts both, pushes, names "Corrente da Ponte" and the room counts it.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0
## The dash's reach (Hades II: 5.6 m) and the paladin's walk for half a warning.
const DASH := 5.6

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _bridge() -> RoomLayout:
	for l in stage.layouts:
		if l.id == &"bridge":
			return l
	return null


func _def(bands: Array[Rect2]) -> HazardDef:
	var h := HazardDef.new()
	h.kind = HazardDef.Kind.LINE
	h.bands = bands
	h.warn = 1.2
	h.fire = 0.25
	h.cycle = 6.0
	h.start_delay = 3.0
	return h


## The clock: calm, then a band every cycle, in turn, never two at once, each warning warn seconds before its strike.
func test_one_band_at_a_time_in_turn() -> void:
	var h := BandHazard.new(_def([Rect2(-11, -2.5, 2, 5), Rect2(9, -2.5, 2, 5)]), [])
	var armed: Array[int] = []
	var armed_at: Array[float] = []
	var fired_at: Array[float] = []
	var t := 0.0
	for i in roundi(20.0 / DT):
		t += DT
		var did := h.step(DT)
		if int(did.armed) >= 0:
			armed.append(int(did.armed))
			armed_at.append(t)
		if int(did.fired) >= 0:
			fired_at.append(t)
		var lit := 0
		for b in 2:
			if h.state(b) != Vector2.ZERO:
				lit += 1
		assert_lte(lit, 1, "never two bands at once")
	assert_eq(armed, [0, 1, 0], "in turn")
	assert_almost_eq(armed_at[0], 3.0, 0.02, "3 s of calm")
	assert_almost_eq(armed_at[1] - armed_at[0], 6.0, 0.02, "one every 6 s")
	assert_almost_eq(fired_at[0] - armed_at[0], 1.2, 0.02, "1.2 s of warning")
	h.stop()
	var more := 0
	for i in roundi(10.0 / DT):
		more += 1 if int(h.step(DT).armed) >= 0 else 0
	assert_eq(more, 0, "stopped: nothing more")


## A band touching a door's mouth never strikes: the next one takes its turn.
func test_a_band_over_a_door_is_skipped() -> void:
	var h := BandHazard.new(_def([Rect2(-11, -2.5, 2, 5), Rect2(9, -2.5, 2, 5)]), [Rect2(10, 2, 2, 2)])
	var armed: Array[int] = []
	for i in roundi(16.0 / DT):
		var a := int(h.step(DT).armed)
		if a >= 0:
			armed.append(a)
	assert_eq(armed, [0, 0, 0], "band 1 never: 3, 9 and 15 s all band 0")


## The data: both variants have the chain; bands whole on the deck, pushes along the bridge onto the floor, B's bands
## 4 m or more from the landing, and from anywhere in a band a dash along the bridge leaves it.
func test_where_the_chain_sweeps() -> void:
	var base := _bridge()
	for v in base.variant_count():
		var l := base.variant(v)
		var h := l.hazard
		assert_not_null(h, "variant %d has the chain" % v)
		assert_eq(h.kind, HazardDef.Kind.LINE)
		assert_eq(h.bands.size(), 2)
		for i in h.bands.size():
			var r := h.bands[i]
			var push := h.band_push_of(i)
			assert_almost_eq(push.y, 0.0, 0.001, "along the bridge, never off it")
			assert_gt(absf(push.x), 0.0)
			for k in 41:
				for j in 21:
					var p := r.position + r.size * Vector2(k / 40.0, j / 20.0)
					p = p.clamp(r.position + Vector2(0.01, 0.01), r.end - Vector2(0.01, 0.01))
					assert_true(l.floor.contains(p), "variant %d band %d whole on the floor at %s" % [v, i, p])
					# a body stands at least its radius inside the deck's sides
					var q := Vector2(p.x, clampf(p.y, r.position.y + Player.RADIUS, r.end.y - Player.RADIUS)) + push
					assert_true(l.floor.contains(q, Player.RADIUS * 0.5), "the push lands on the floor at %s" % q)
					assert_true(_leaves(l, h, p), "a dash out of band %d from %s" % [i, p])
		if v == 1:
			var landing := Rect2(-3, -4.5, 6, 9)
			for r in h.bands:
				var gap := maxf(landing.position.x - r.end.x, r.position.x - landing.end.x)
				assert_gte(gap, 4.0, "B: 4 m or more from the landing")


## Some dash along the bridge (either way) from p ends on the floor out of every band.
func _leaves(l: RoomLayout, h: HazardDef, p: Vector2) -> bool:
	for dir in [Vector2.LEFT, Vector2.RIGHT]:
		var q: Vector2 = p + dir * DASH
		if not l.floor.contains(q, Player.RADIUS * 0.5):
			continue
		var clear := true
		for r in h.bands:
			if r.grow(Player.RADIUS).has_point(q):
				clear = false
		if clear:
			return true
	return false


## In a real room: the band strikes him 7 and an enemy 60, pushes both along the bridge, "Derrotado por: Corrente da
## Ponte", and the room counts it.
func test_in_a_real_room_it_hurts_pushes_and_is_counted() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _bridge()
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 6, stage.layouts.find(l), 0)
	game.rooms._enter(r)
	var bf := game.rooms.bands
	assert_not_null(bf, "a fight on the bridge has its chain")
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	var band := l.hazard.bands[0]
	var at := band.get_center()
	game.player.place(at)
	game.player.invuln = 0.0
	var e := game.horde.spawn(game.horde.def(&"guard"), at + Vector2(0, 1.2), false)
	var hp := game.player.hp
	var struck := false
	for i in roundi(4.5 / DT):
		if not struck:
			game.player.place(at)
			e.pos = at + Vector2(0, 1.2)
		bf.step(DT)
		game.ground.step(DT)
		struck = struck or game.player.hp < hp  # the warning lands (and pushes) in the Ground's step
	assert_almost_eq(game.player.hp, hp - 10.0, 0.01, "the paladin in it loses 10 (A1)")
	assert_almost_eq(e.max_hp - e.hp, 60.0, 0.01, "the enemy in it 60 (the Escudo outlives it)")
	assert_lt(game.player.pos.x, at.x - 2.0, "pushed along the bridge toward the west")
	assert_lt(e.pos.x, at.x - 2.0, "the enemy too")
	assert_eq(game.last_hurt.get("attack", &""), &"chain")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Corrente da Ponte")
	game.rooms._room_cleared()
	assert_null(game.rooms.bands, "the chain stops with the fight")
	var room: Dictionary = game.room_tally.rooms(game.time)[-1]
	var hz: Dictionary = room.get("hazard", {})
	assert_eq(hz.get("kind"), "chain")
	assert_almost_eq(float(hz.get("enemy_damage", 0.0)), 60.0, 0.01)
	assert_almost_eq(float(hz.get("hero_damage", 0.0)), 10.0, 0.01)
	assert_eq(int(hz.get("strikes", 0)), 1)
