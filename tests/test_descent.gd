extends GutTest
## The descent (C13-01, decision D-61): ten rooms and Morvath in the 11th, as Hades II's region: the opening in the
## catacomb hall, fights drawn among the three arenas (never the same twice in a row, none more than three times), the
## guardian in room 4 to 6, the fountain once in room 5 to 8 (in the hall), the shop in room 10, Morvath. The test one of
## 7 (--medium) and the old one of 5 (--short) stay. Each arena brings its own ceiling of enemies, shooters and banned
## roles to the fights in it. The rooms are counted for the human tests (QW-011) and the arena's name shows on
## entering (D-33).

const STAGE := "res://data/stages/catacombs.tres"

var stage: StageDef
var defs := {}


func before_all() -> void:
	stage = load(STAGE)
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)


## One whole descent by random doors: the rooms entered, in order. Every door offered is checked on the way: a
## fountain is always in the hall, inside its depths.
func _descend(rng: RandomNumberGenerator, st: StageDef = stage) -> Array[RunMap.Room]:
	var map := RunMap.new(st, rng)
	var out: Array[RunMap.Room] = []
	var room := map.first()
	while true:
		map.enter(room)
		out.append(room)
		if room.kind == RunMap.Kind.BOSS:
			break
		var doors := map.options(true)
		for d in doors:
			if d.kind == RunMap.Kind.FOUNTAIN:
				assert_eq(st.layouts[d.layout].id, &"hall", "the fountain is in the hall")
				assert_between(d.depth, st.fountain_depth_min, st.fountain_depth_max)
		room = doors[rng.randi() % doors.size()]
	return out


## The arena of each room, by id (&"" for the boss, &"altar" for the Altar Esquecido, E5).
func _places(st: StageDef, rooms: Array[RunMap.Room]) -> Array[StringName]:
	var out: Array[StringName] = []
	for r in rooms:
		out.append(&"" if r.kind == RunMap.Kind.BOSS else &"altar" if r.kind == RunMap.Kind.ALTAR else st.layouts[r.layout].id)
	return out


func test_ten_rooms_and_morvath_in_the_eleventh() -> void:
	var rng := RandomNumberGenerator.new()
	for run in 1000:
		rng.seed = run
		var rooms := _descend(rng)
		assert_eq(rooms.size(), 11, "eleven rooms")
		if rooms.size() != 11:
			return
		assert_eq(stage.layouts[rooms[0].layout].id, &"hall", "the opening is the hall")
		var guardian := -1
		var fountains := 0
		for i in rooms.size():
			if rooms[i].kind == RunMap.Kind.MINIBOSS:
				guardian = i + 1
				assert_true(stage.layouts[rooms[i].layout].guardian, "the guardian fights where a guardian may")
				if places_before(rooms, i) != &"sanctuary":
					assert_eq(stage.layouts[rooms[i].layout].id, &"sanctuary", "run %d: the guardian in his house (E5)" % run)
			if rooms[i].kind == RunMap.Kind.FOUNTAIN:
				fountains += 1
		assert_between(guardian, 4, 6, "run %d: the guardian in room 4 to 6" % run)
		assert_lte(fountains, 1, "the fountain once at most")
		assert_eq(rooms[9].kind, RunMap.Kind.SHOP)
		assert_eq(rooms[10].kind, RunMap.Kind.BOSS)
		var places := _places(stage, rooms)
		var count := {}
		var altars := 0
		for i in range(1, 9):
			if rooms[i].kind == RunMap.Kind.ALTAR:
				altars += 1
				assert_between(rooms[i].depth, stage.altar_depth_min, stage.altar_depth_max, "the altar within its depths")
				continue
			if rooms[i].kind == RunMap.Kind.FOUNTAIN:
				continue
			assert_ne(places[i], &"hall", "run %d: room %d is an arena" % [run, i + 1])
			assert_ne(places[i], places_before(rooms, i), "run %d: two rooms in a row in %s" % [run, places[i]])
		assert_lte(altars, 1, "run %d: the altar once at most" % run)
		for p in places:
			count[p] = count.get(p, 0) + 1
		for p: StringName in count:
			if p != &"" and p != &"altar":
				assert_lte(count[p], 3, "run %d: %s more than three times" % [run, p])
		assert_ne(places[1], places[2], "run %d: rooms 2 and 3 in different arenas" % run)
		for r in rooms:
			if r.kind != RunMap.Kind.BOSS and r.kind != RunMap.Kind.ALTAR:
				assert_lt(r.variant, stage.layouts[r.layout].variant_count(), "a variant the arena has")


## The arena of the room before room i, an altar between them skipped (it is no arena: the fight before it counts).
func places_before(rooms: Array[RunMap.Room], i: int) -> StringName:
	var k := i - 1
	while k > 0 and rooms[k].kind == RunMap.Kind.ALTAR:
		k -= 1
	return &"" if rooms[k].kind == RunMap.Kind.BOSS else stage.layouts[rooms[k].layout].id


func test_the_shorter_descents_stay() -> void:
	var rng := RandomNumberGenerator.new()
	var medium := Rooms.short_stage(stage, 6)
	var short := Rooms.short_stage(stage, 4)
	for run in 200:
		rng.seed = run
		var seven := _descend(rng, medium)
		assert_eq(seven.size(), 7)
		assert_eq(seven[4].kind, RunMap.Kind.MINIBOSS)
		assert_eq(seven[5].kind, RunMap.Kind.SHOP)
		assert_eq(seven[6].kind, RunMap.Kind.BOSS)
		var five := _descend(rng, short)
		assert_eq(five.size(), 5)
		assert_eq(five[2].kind, RunMap.Kind.MINIBOSS)
		assert_eq(five[3].kind, RunMap.Kind.SHOP)
	assert_eq(stage.rooms, 10, "the long descent is the default")
	assert_eq(stage.elite_from_depth, 3, "elites from depth 3, as in Hades II")
	assert_eq(medium.elite_from_depth, 2)


func test_every_arena_and_variant_comes_up() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var seen := {}
	for run in 300:
		for r in _descend(rng):
			if r.kind != RunMap.Kind.ALTAR:
				seen["%s %d" % [stage.layouts[r.layout].id, r.variant]] = true
	for id in ["crypt", "rift", "garden", "sanctuary", "bridge", "runes"]:
		for v in 2:
			assert_true(seen.has("%s %d" % [id, v]), "%s %d is drawn" % [id, v])


func test_the_same_seed_gives_the_same_descent() -> void:
	var r1 := RandomNumberGenerator.new()
	var r2 := RandomNumberGenerator.new()
	r1.seed = 5
	r2.seed = 5
	var one := _descend(r1)
	var two := _descend(r2)
	assert_eq(one.size(), two.size())
	for i in one.size():
		assert_eq(one[i].kind, two[i].kind)
		assert_eq(one[i].layout, two[i].layout)
		assert_eq(one[i].variant, two[i].variant)


func test_each_arena_holds_its_ceiling_shooters_and_roles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for l in stage.layouts:
		if l.id == &"hall":
			continue
		for i in 200:
			var depth := 2 + i % 3
			var fight := EncounterGen.generate(stage, depth, defs, rng, 1.0, l)
			assert_lte(fight.ceiling, l.max_alive.y, "%s: never more standing than it holds" % l.id)
			assert_between(fight.cap, l.max_alive.x, l.max_alive.y, "%s: the cap in its range" % l.id)
			for w in fight.waves:
				var shooters := 0
				for id in w:
					var d: EnemyDef = defs[id]
					if EncounterGen.ranged(d):
						shooters += 1
					assert_false(l.banned_roles.has(d.role), "%s: no %s here" % [l.id, d.role])
				if l.max_ranged > 0:
					assert_lte(shooters, l.max_ranged, "%s: at most %d shooters a wave" % [l.id, l.max_ranged])


func test_the_rooms_are_counted_for_the_human_tests() -> void:
	var t := RoomTally.new()
	t.enter(1, "hall", 30.0, 0.0)
	t.touch(2.5)
	t.touch(4.0)
	t.hurt("skeleton", 3.0)
	t.hurt("skeleton", 2.0)
	t.hurt("archer", 1.5)
	t.hurt("archer", 0.0)
	t.enter(2, "crypt", 23.5, 30.0)
	t.enter(7, "", 20.0, 70.0, true)
	t.hurt("scythe", 4.0)
	var rooms := t.rooms(100.0)
	assert_eq(rooms.size(), 3)
	assert_eq(rooms[0].layout, "hall")
	assert_eq(float(rooms[0].hp_in), 30.0)
	assert_eq(float(rooms[0].hurt_by.skeleton), 5.0)
	assert_eq(float(rooms[0].hurt_by.archer), 1.5)
	assert_eq(float(rooms[0].contact), 2.5, "the first blow only")
	assert_eq(float(rooms[0].time), 30.0)
	assert_eq(float(rooms[1].contact), -1.0, "no blow in the crypt yet")
	assert_eq(float(rooms[1].time), 40.0)
	assert_eq(float(rooms[2].time), 30.0, "the room he stands in is timed up to now")
	assert_eq(t.hp_at_boss, 20.0)
	rooms[2].hurt_by["scythe"] = 99.0
	assert_eq(float(t.rooms(100.0)[2].hurt_by.scythe), 4.0, "a copy")


func test_the_result_and_the_arena_name() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	assert_eq(game.arena.id, &"hall", "the run opens in the hall")
	assert_eq(game.hud.place_shown(), T.t(&"arena_hall"), "the name of the place shows on entering")
	var r := game.result()
	assert_eq(r.arena, "hall")
	assert_eq(r.rooms.size(), 1)
	assert_eq(r.rooms[0].layout, "hall")
	assert_eq(float(r.hp_at_boss), -1.0, "not at Morvath yet")
	for key in ["stuck", "stuck_by", "shots_blocked"]:
		assert_true(r.has(key), "RESULT has %s" % key)


## E5: the three new arenas are the plan's (spec sections 1 to 3): their size, difficulty, place in the descent, ceiling,
## shooters and banned roles, doors, the guardian's house, and the parts of the floor whose time is counted.
func test_the_three_arenas_of_e5() -> void:
	var by := {}
	for l in stage.layouts:
		by[l.id] = l
	for id: StringName in [&"sanctuary", &"bridge", &"runes"]:
		assert_true(by.has(id), "%s in the stage" % id)
		var l: RoomLayout = by[id]
		assert_eq(l.difficulty, 2, "%s is a high one" % id)
		assert_eq(l.exits.size(), 3)
		assert_eq(l.variant_count(), 2, "%s has two variants" % id)
		assert_ne(T.t(l.name_key), String(l.name_key), "%s has its name" % id)
	var s: RoomLayout = by[&"sanctuary"]
	assert_true(s.guardian_home, "the Santuário is the guardian's house")
	assert_eq(s.boss_spawn, Vector2(-17, 0), "he rises before the grille")
	assert_eq(s.size_class, RoomLayout.Size.LARGE)
	assert_eq(s.depth, Vector2(0.4, 1.0))
	assert_eq(s.area_at(Vector2(0, 0)), "nave")
	assert_eq(s.area_at(Vector2(0, 10)), "aisles")
	assert_eq(s.variant(1).floor.holes.size(), 1, "B: the nave fell in")
	var b: RoomLayout = by[&"bridge"]
	assert_eq(b.size_class, RoomLayout.Size.LONG)
	assert_true(b.banned_roles.has(&"area"), "no creeping vine on a bridge of 5 m")
	for e in b.exits:
		assert_gt(e.at.x, 14.0, "every door on the far platform (E5-D5)")
	for z in b.spawns + b.late_spawns:
		assert_true(z.end.x <= 7.0 and z.position.x >= -7.0 or z.position.x >= 14.0 or z.end.x <= -14.0, "nobody rises on a bridge: %s" % z)
	assert_eq(b.area_at(Vector2(-10, 0)), "bridge1")
	assert_eq(b.variant(1).area_at(Vector2(0, 0)), "landing")
	var r: RoomLayout = by[&"runes"]
	assert_eq(r.max_alive, Vector2i(4, 6))
	assert_eq(r.max_ranged, 2)
	assert_true(r.banned_roles.has(&"area"))
	assert_ne(r.cam_target, Vector2.ZERO, "the camera keeps the whole room in view")
	assert_not_null(r.hazard)


## The guardian's fight is in the Santuário when it may be, at any depth (it is a high arena drawn from 40% of the
## descent for fights); and in the shorter descents too.
func test_the_guardian_fights_in_the_sanctuary() -> void:
	var rng := RandomNumberGenerator.new()
	var at_home := 0
	for run in 300:
		rng.seed = 1000 + run
		for r in _descend(rng, Rooms.short_stage(stage, 6) if run % 3 == 0 else stage):
			if r.kind == RunMap.Kind.MINIBOSS and stage.layouts[r.layout].id == &"sanctuary":
				at_home += 1
	assert_gt(at_home, 255, "the guardian is at home unless he fought there the room before or it is used up (%d of 300)" % at_home)


## E5, the doors that show the way: the fights behind the doors are drawn before they open (Rooms._prepare), and the
## sign says which are hard (an elite) and which is the guardian's; the altar's door comes once, within its depths.
func test_the_doors_know_their_rooms_before_they_open() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var rooms := game.rooms
	var seen_hard := false
	for k in 40:
		rooms.map.depth = 2 + k % 6
		rooms.map.miniboss_depth = 0 if k % 5 else rooms.map.depth + 1
		rooms.next_rooms = rooms.map.options(true)
		rooms._prepare(rooms.next_rooms)
		for i in rooms.next_rooms.size():
			var r := rooms.next_rooms[i]
			var info := rooms.door_info(i)
			if r.kind == RunMap.Kind.COMBAT or r.kind == RunMap.Kind.MINIBOSS:
				assert_not_null(r.fight, "the fight behind door %d is drawn before it opens" % i)
				assert_ne(String(info.arena), "", "the doorway knows the arena it leads to")
			if r.kind == RunMap.Kind.MINIBOSS:
				assert_true(info.guardian)
				assert_true(Rooms.door_text(r).contains(T.t(&"room_miniboss")), "the guardian's door says so")
			if info.get("hard", false):
				seen_hard = true
				assert_true(Rooms.door_text(r).contains(T.t(&"door_hard")), "a hard fight's door says Difícil")
				assert_false((info.elites as Array).is_empty())
	assert_true(seen_hard, "a hard fight came up behind some door")
	# the fight he walks into is the one the door promised
	var door := rooms.next_rooms[0]
	if door.kind == RunMap.Kind.COMBAT:
		var promised := door.fight.kinds.duplicate()
		rooms._enter(door)
		var risen := {}
		for w in rooms._waves:
			for id in w:
				risen[id] = true
		for id in promised:
			assert_true(risen.has(id), "%s comes as promised" % id)
