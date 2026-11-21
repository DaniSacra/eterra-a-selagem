extends GutTest
## The wall trap (SR-P1, docs/design/rooms_progression.md): a block in the wall throws blades along a line 1.2 m across,
## one line at a time (the one with most enemies in it, band_busy), 1.2 s of warning, 10 to him, 60 to an enemy, after 5 s
## of calm and from a share of the descent. In the data: the Jardim A's two traps, the Santuário A's three and C's two;
## every line whole on the floor, off every door's mouth, 6 m or more from the way in, with a block behind its start.
## In a real room: it hurts both, names "Armadilha de Lâminas", the room counts it, and it sleeps early in the descent.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _layout(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


## [layout, variant index (0 the base), trap hazard] of every room with a trap.
func _traps() -> Array:
	var out := []
	for id in [&"garden", &"sanctuary"]:
		var l := _layout(id)
		for v in l.variants.size() + 1:
			var lv := l.variant(v)
			var hz := lv.hazard
			while hz != null and hz.band_source != &"trap":
				hz = hz.also
			if hz != null and hz.kind == HazardDef.Kind.LINE:
				out.append([l, v, hz])
	return out


func test_where_the_traps_are() -> void:
	var seen := {}
	for t: Array in _traps():
		var l: RoomLayout = t[0]
		seen["%s%d" % [l.id, t[1]]] = (t[2] as HazardDef).bands.size()
	assert_eq(seen, {"garden0": 2, "sanctuary0": 3, "sanctuary2": 2}, "Jardim A, Santuário A and C")


func test_every_line_is_whole_and_fair() -> void:
	for t: Array in _traps():
		var l: RoomLayout = (t[0] as RoomLayout).variant(t[1])
		var h: HazardDef = t[2]
		assert_eq(h.band_dir.size(), h.bands.size(), "a way for every line")
		assert_almost_eq(h.hero_damage, 10.0, 0.001, "10 to him (the rule of every hazard)")
		assert_gte(h.warn, 1.0, "never less than the enemies' warning")
		assert_gte(h.start_delay, 5.0, "calm at the start")
		assert_true(h.band_busy)
		var blocks := l.obstacles.filter(func(o: ArenaObstacle) -> bool: return o.piece == &"trap_block")
		assert_eq(blocks.size(), h.bands.size(), "a block per line")
		for i in h.bands.size():
			var r := h.bands[i]
			var d := h.band_dir_of(i)
			assert_almost_eq(d.length(), 1.0, 0.001)
			var start := r.get_center() - d * (maxf(r.size.x, r.size.y) * 0.5)
			assert_true(blocks.any(func(o: ArenaObstacle) -> bool: return o.center.distance_to(start) < 0.5),
				"line %d starts at a block" % i)
			for k in 41:
				var q := r.position + r.size * Vector2(k / 40.0 if absf(d.x) > 0.5 else 0.5, k / 40.0 if absf(d.y) > 0.5 else 0.5)
				assert_true(l.floor.covers(q), "line %d on the floor at %s" % [i, q])
			assert_gte(Geometry2D.get_closest_point_to_segment(l.hero_spawn, start, start + d * maxf(r.size.x, r.size.y)).distance_to(l.hero_spawn),
				6.0 + r.size.x * 0.5, "line %d 6 m from the way in" % i)
			for e in l.exits:
				assert_false(e.mouth.grow(0.5).intersects(r), "line %d off a door" % i)
				assert_false(e.mouth.grow(1.0).has_point(start), "block %d off a door" % i)
		# a free way out: the lines leave floor between them (no two touch)
		for i in h.bands.size():
			for j in range(i + 1, h.bands.size()):
				assert_false(h.bands[i].grow(1.5).intersects(h.bands[j]), "lines %d and %d keep apart" % [i, j])


## The line with most enemies in it goes first (the paladin lures the pack in), and a trap before its share of the descent
## strikes nothing.
func test_the_busiest_line_first() -> void:
	var h := _layout(&"sanctuary").hazard.also
	var bt := BandHazard.new(h, [])
	var inside := h.bands[2].get_center()
	var bodies := PackedVector2Array([inside, inside + Vector2(0, 1), h.bands[0].get_center()])
	var armed := -1
	for i in roundi(6.0 / DT):
		var did := bt.step(DT, bodies)
		if int(did.armed) >= 0:
			armed = int(did.armed)
			break
	assert_eq(armed, 2, "the line with two enemies first, after the calm")


func _enter(layout_id: StringName, variant: int, depth: int) -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _layout(layout_id)
	game.rooms._enter(RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, depth, stage.layouts.find(l), variant))
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	return game


func test_early_in_the_descent_it_sleeps() -> void:
	var game := _enter(&"garden", 0, 1)
	var bf := game.rooms.bands
	assert_not_null(bf, "the room has it")
	var l := _layout(&"garden")
	var at: Vector2 = l.hazard.also.bands[0].get_center()
	game.player.place(at)
	game.player.invuln = 0.0
	var hp := game.player.hp
	for i in roundi(9.0 / DT):
		game.player.place(at)
		bf.step(DT)
		game.ground.step(DT)
	assert_eq(game.player.hp, hp, "asleep before 0.3 of the descent")


func test_in_a_real_room_it_hurts_both_and_is_counted() -> void:
	var game := _enter(&"garden", 0, 8)
	var bf := game.rooms.bands
	var h: HazardDef = _layout(&"garden").hazard.also
	var inside := h.bands[1].get_center() + Vector2(0, 2)
	var e := game.horde.spawn(game.horde.def(&"guard"), inside, false)
	var f := game.horde.spawn(game.horde.def(&"guard"), inside + Vector2(0, 1), false)
	var safe := Vector2(-12, 0)
	game.player.place(safe)
	game.player.invuln = 0.0
	var hp := game.player.hp
	for i in roundi(8.0 / DT):
		game.player.place(safe)
		e.pos = inside
		f.pos = inside + Vector2(0, 1)
		bf.step(DT)
		game.ground.step(DT)
		if bf.hazard.fired > 0:
			break
	assert_eq(game.player.hp, hp, "not him, out of the line")
	assert_almost_eq(e.max_hp - e.hp, 60.0, 0.01, "the enemy in the busiest line (the second) takes 60")
	assert_eq(bf.hazard.fired, 1)
	# then the pack is gone and he stands in the first line (nobody to draw it: in turn, the next after the second)
	game.horde.clear_crowd()
	var in_line: Vector2 = h.bands[0].get_center()
	for i in roundi(9.0 / DT):
		game.player.place(in_line)
		bf.step(DT)
		game.ground.step(DT)
		if game.player.hp < hp:
			break
	assert_almost_eq(game.player.hp, hp - 10.0, 0.01, "10 to him in the line")
	assert_eq(game.last_hurt.get("attack", &""), &"trap")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Armadilha de Lâminas")
	game.rooms._room_cleared()
	var room: Dictionary = game.room_tally.rooms(game.time)[-1]
	var hz: Dictionary = room.get("hazard", {})
	var tally: Dictionary = hz.get("also", hz) if hz.get("kind") != "trap" else hz
	assert_gte(float(tally.get("enemy_damage", 0.0)), 60.0)
	assert_gte(int(tally.get("fired", 0)), 1)
