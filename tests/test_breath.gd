extends GutTest
## The rift that breathes (RP-08, H-4; docs/design/rooms_progression.md): the flood trap of the Hades II on the Salão
## das Fendas. Three stretches of the rift's brink, one at a time every 7 s after 3 s of calm, warm up 1.2 s and push
## everyone in them 2.5 m away from the brink: no damage to anyone, a wind-up there is cut. In the data: both variants,
## every stretch on the floor, off the spawns and the bridge heads, every push landing on the floor. In a real room he
## loses nothing and is pushed, an enemy winding up there is pushed and cut, and the room counts it.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _rift() -> RoomLayout:
	for l in stage.layouts:
		if l.id == &"rift":
			return l
	return null


func test_where_the_rift_breathes() -> void:
	var base := _rift()
	for v in base.variant_count():
		var l := base.variant(v)
		var h := l.hazard
		assert_not_null(h, "variant %d breathes" % v)
		assert_eq(h.kind, HazardDef.Kind.LINE)
		assert_eq(h.band_source, &"breath")
		assert_eq(h.hero_damage, 0.0, "no damage to him")
		assert_eq(h.enemy_damage, 0.0, "nor to them")
		assert_almost_eq(h.cycle, 7.0, 0.001)
		assert_eq(h.bands.size(), 4, "four stretches, one at a time")
		assert_true(h.band_busy, "it breathes where the fight is")
		var keep_off: Array[Rect2] = []
		keep_off.append_array(l.spawns)
		keep_off.append_array(l.late_spawns)
		if v == 0:
			for name in ["bridge_n", "bridge_s"]:
				keep_off.append(l.areas[Array(l.area_names).find(name)])
		for i in h.bands.size():
			var r := h.bands[i]
			for k in keep_off:
				assert_false(k.intersects(r), "variant %d stretch %d off %s" % [v, i, k])
			var push := h.band_push_of(i)
			assert_almost_eq(push.length(), 2.5, 0.001)
			for x in 13:
				for z in 9:
					var p := r.position + r.size * Vector2(x / 12.0, z / 8.0)
					p = p.clamp(r.position + Vector2(0.01, 0.01), r.end - Vector2(0.01, 0.01))
					assert_true(l.floor.contains(p), "variant %d stretch %d on the floor at %s" % [v, i, p])
					var q := p + push
					assert_true(l.floor.contains(q, Player.RADIUS * 0.5), "the push lands on the floor at %s" % q)
			# the brink is behind it: back from its middle against the push lies the rift
			assert_false(l.floor.contains(r.get_center() - push.normalized() * 3.5), "variant %d stretch %d pushes away from the rift" % [v, i])


## In a real room: the stretch pushes him (no life lost) and an enemy winding up in it (pushed and cut, no life lost);
## the room counts it.
func test_in_a_real_room_it_pushes_and_cuts() -> void:
	# (with band_busy the stretch with the enemy goes first: band 0 holds both)
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _rift()
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 2, stage.layouts.find(l), 0)
	game.rooms._enter(r)
	var bf := game.rooms.bands
	assert_not_null(bf, "a fight in the rift breathes")
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	var band := l.hazard.bands[0]
	var at := Vector2(band.get_center().x, -6.0)  # (off the RP-05 stump at (5.5, -4) in this stretch)
	game.player.place(at)
	game.player.invuln = 0.0
	var e := game.horde.spawn(game.horde.def(&"skeleton"), at + Vector2(0, 4.0), false)
	var hp := game.player.hp
	var moved := false
	for i in roundi(4.5 / DT):
		if not moved:
			game.player.place(at)
			e.pos = at + Vector2(0, 4.0)
			e.state = Enemy.State.WINDUP
		bf.step(DT)
		game.ground.step(DT)
		moved = moved or game.player.pos.distance_to(at) > 1.0
	assert_true(moved, "the stretch breathed")
	assert_eq(game.player.hp, hp, "no life lost")
	var away := l.hazard.band_push_of(0).normalized()
	assert_gt((game.player.pos - at).dot(away), 2.0, "pushed away from the brink")
	assert_eq(e.hp, e.max_hp, "the enemy loses nothing")
	assert_gt((e.pos - at - Vector2(0, 4.0)).dot(away), 2.0, "the enemy pushed too")
	assert_ne(e.state, Enemy.State.WINDUP, "its wind-up cut")
	game.rooms._room_cleared()
	assert_null(game.rooms.bands)
	var room: Dictionary = game.room_tally.rooms(game.time)[-1]
	var hz: Dictionary = room.get("hazard", {})
	if hz.get("kind") != "breath":
		hz = hz.get("also", {})  # (SR-P2: the Fendas A's slabs are the first tally, the breath the second)
	assert_eq(hz.get("kind"), "breath")
	assert_eq(float(hz.get("hero_damage", -1.0)), 0.0)
	assert_eq(float(hz.get("enemy_damage", -1.0)), 0.0)
	assert_eq(int(hz.get("pushed", 0)), 1)
	assert_eq(int(hz.get("cut", 0)), 1)


## band_busy: the stretch with the most enemies goes next; none in any: in turn.
func test_it_breathes_where_the_fight_is() -> void:
	var def := HazardDef.new()
	def.kind = HazardDef.Kind.LINE
	def.bands = [Rect2(0, 0, 2, 2), Rect2(10, 0, 2, 2), Rect2(20, 0, 2, 2)]
	def.band_busy = true
	def.start_delay = 1.0
	def.cycle = 2.0
	var h := BandHazard.new(def, [])
	var bodies := PackedVector2Array([Vector2(21, 1), Vector2(21.5, 1), Vector2(11, 1)])
	var armed: Array[int] = []
	for i in roundi(5.5 / DT):
		var a := int(h.step(DT, bodies).armed)
		if a >= 0:
			armed.append(a)
			bodies = PackedVector2Array([Vector2(11, 1)]) if armed.size() == 1 else PackedVector2Array()
	assert_eq(armed, [2, 1, 2], "the busiest, then the busiest, then in turn after the last")
