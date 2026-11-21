extends GutTest
## The stones that fall from the torn vault (RP-20; docs/design/rooms_progression.md, combat_cadence.md 9.3): squares of
## 2 m in the Santuário B (the nave round the hole) and the Fendas B (the east platform), at most two warming up, one
## every 4 s after 3 s, warned 1.2 s, 10 to him and 60 to each enemy; never over another stone nor another warning,
## never while the room has two warnings on (R9), never within 6 m of the way in nor on a door; half aimed at him; the
## rubble drawn only. In a real room it hurts both, names "Pedras da Abóbada" and the room counts it.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _base(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


func _rocks_rooms() -> Array[RoomLayout]:
	return [_base(&"sanctuary").variant(1), _base(&"rift").variant(1)]


func _doors(l: RoomLayout) -> Array[Rect2]:
	var out: Array[Rect2] = []
	for e in l.exits:
		out.append(e.mouth)
	return out


## The data: Santuário B and Fendas B have the stones beside their own hazard; zones 6 m off the way in, off the doors.
func test_where_the_stones_fall() -> void:
	for l in _rocks_rooms():
		var h := l.hazard.also
		assert_not_null(h, "%s B has the stones" % l.id)
		assert_eq(h.kind, HazardDef.Kind.DROPS)
		assert_gte(h.warn, 1.0)
		assert_gte(h.start_delay, 3.0)
		assert_eq(h.hero_damage, 10.0)
		assert_lte(h.drop_count, 2, "R9: never three")
		for z in h.drop_zones:
			for k in 11:
				for j in 11:
					var p := z.position + z.size * Vector2(k / 10.0, j / 10.0)
					assert_gte(p.distance_to(l.hero_spawn), 6.0, "%s: 6 m off the way in at %s" % [l.id, p])
		assert_null(_base(l.id).variant(0).hazard.also, "%s A has none" % l.id)


## Simulated on each room: never two stones touching, never more than two warming, never in the first 3 s, every square
## whole on the floor and off the doors, half aimed at him in a zone, and from inside any square a step of 1.6 m (a
## quarter of a 1.2 s warning's walk) reaches floor out of every stone.
func test_the_stones_keep_their_rules() -> void:
	for l in _rocks_rooms():
		var h := l.hazard.also
		var d := DropHazard.new(h, l.floor, _doors(l), 11)
		var hero := _on_floor(l, h.drop_zones[0])
		var t := 0.0
		var first := INF
		var count := 0
		for i in roundi(60.0 / DT):
			t += DT
			var did := d.step(DT, hero, [], 2)
			for r: Rect2 in did.armed:
				count += 1
				first = minf(first, t)
				for p in [r.position, r.end, r.get_center()]:
					assert_true(l.floor.covers(p), "%s: whole on the floor" % l.id)
				for door in _doors(l):
					assert_false(door.intersects(r), "%s: off the doors" % l.id)
				assert_true(_way_out(l, d, r), "%s: a way out of %s" % [l.id, r])
			assert_lte(d.warming(), 2, "never three")
			for a in d.stones.size():
				for b in range(a + 1, d.stones.size()):
					assert_false((d.stones[a].rect as Rect2).intersects(d.stones[b].rect), "never two touching")
		assert_gte(first, 3.0, "%s: nothing in the first 3 s" % l.id)
		assert_gt(count, 8, "%s: stones fell (%d)" % [l.id, count])
		assert_gt(d.aimed, count / 5, "%s: some aimed at him" % l.id)
		var full := DropHazard.new(h, l.floor, _doors(l), 11)
		var none := 0
		for i in roundi(20.0 / DT):
			none += (full.step(DT, hero, [], 0).armed as Array).size()
		assert_eq(none, 0, "%s: the room's two warnings on: none (R9)" % l.id)


## A point of zone z on the floor, 1.2 m in from the floor's edge (where he may stand with a stone round his feet).
func _on_floor(l: RoomLayout, z: Rect2) -> Vector2:
	for k in 21:
		for j in 21:
			var p := z.position + z.size * Vector2(k / 20.0, j / 20.0)
			if z.grow(-1.2).has_point(p) and l.floor.contains(p, 1.2):
				return p
	return z.get_center()


func _way_out(l: RoomLayout, d: DropHazard, r: Rect2) -> bool:
	for k in 9:
		var a := TAU * k / 8.0
		var q := r.get_center() + Vector2(cos(a), sin(a)) * (r.size.x * 0.5 + 1.6)
		if not l.floor.contains(q, Player.RADIUS * 0.5):
			continue
		var clear := true
		for s in d.stones:
			if (s.rect as Rect2).grow(Player.RADIUS).has_point(q):
				clear = false
		if clear:
			return true
	return false


## The stones keep off another warning given (blocked).
func test_the_stones_keep_off_other_warnings() -> void:
	var l := _rocks_rooms()[0]
	var h := l.hazard.also
	var d := DropHazard.new(h, l.floor, _doors(l), 5)
	var wall := h.drop_zones[0]
	for i in roundi(20.0 / DT):
		var did := d.step(DT, wall.get_center(), [Rect2(wall.position, Vector2(wall.size.x, wall.size.y * 0.5))], 2)
		for r: Rect2 in did.armed:
			assert_false(Rect2(wall.position, Vector2(wall.size.x, wall.size.y * 0.5)).intersects(r), "off the warning")


## In a real room: a stone falls on him and on an enemy, 10 and 60, "Pedras da Abóbada", the rubble stops no body, counted.
func test_in_a_real_room_it_strikes_and_is_counted() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var base := _base(&"sanctuary")
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 6, stage.layouts.find(base), 1)
	game.rooms._enter(r)
	var df := game.rooms.drops
	assert_not_null(df, "Santuário B has its stones")
	assert_not_null(game.rooms.plates, "beside its slabs")
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	var at := Vector2(-5.0, 0.0)
	var e := game.horde.spawn(game.horde.def(&"guard"), at + Vector2(0.3, 0.3), false)
	var hp := game.player.hp
	game.player.invuln = 0.0
	var hurt := false
	var felt := false
	for i in roundi(12.0 / DT):
		game.player.place(at)
		if not hurt:
			game.player.invuln = 0.0
		e.pos = at + Vector2(0.3, 0.3)
		df.step(DT)
		game.ground.step(DT)
		hurt = hurt or game.player.hp < hp
		felt = felt or e.hp < e.max_hp
		if hurt and felt:
			break
	assert_true(hurt, "a stone fell on him (aimed)")
	assert_almost_eq(hp - game.player.hp, 10.0, 0.01, "10 to him")
	assert_almost_eq(e.max_hp - e.hp, 60.0, 0.01, "60 to the enemy under it")
	assert_eq(game.last_hurt.get("attack", &""), &"rocks")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Pedras da Abóbada")
	for k in 10:
		df.step(DT)
	assert_lt(game.arena.resolve(at, 0.4).distance_to(at), 0.01, "the rubble stops no body")
	game.rooms._room_cleared()
	assert_null(game.rooms.drops, "the stones stop with the fight")
	var room: Dictionary = game.room_tally.rooms(game.time)[-1]
	var hz: Dictionary = room.get("hazard", {})
	var rocks: Dictionary = hz if hz.get("kind") == "rocks" else hz.get("also", {})
	assert_eq(rocks.get("kind"), "rocks")
	assert_almost_eq(float(rocks.get("hero_damage", 0.0)), 10.0, 0.01)
	assert_gte(int(rocks.get("strikes", 0)), 1)


## R9 (combat_cadence.md 9.2): with the room's two warnings on (another hazard's), a slab stepped on waits; one free,
## one slab arms.
func test_the_slabs_wait_for_the_room_s_two_warnings() -> void:
	var h := HazardDef.new()
	h.kind = HazardDef.Kind.PLATES
	h.plates = [Rect2(0, 0, 3, 3), Rect2(5, 0, 3, 3)]
	h.warn = 1.2
	h.fire = 0.25
	h.rearm = 5.0
	h.start_delay = 0.0
	var on := PackedVector2Array([Vector2(1.5, 1.5), Vector2(6.5, 1.5)])
	var p := PlateHazard.new(h, [])
	var armed := 0
	for i in 30:
		armed += (p.step(DT, Vector2.INF, on, 2).armed as PackedInt32Array).size()
	assert_eq(armed, 0, "two of the room's warnings on: no slab arms")
	for i in 30:
		armed += (p.step(DT, Vector2.INF, on, 1).armed as PackedInt32Array).size()
	assert_eq(armed, 1, "one free: one slab")
