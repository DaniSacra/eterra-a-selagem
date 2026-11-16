extends GutTest
## The descent of cycle C12 (decision D-27): seven rooms, the opening in the catacomb hall, then fights drawn among
## the three arenas (never the same twice in a row), the fountain in the hall, the guardian, the shop, Morvath. Each
## arena brings its own ceiling of enemies, shooters and banned roles to the fights in it. The rooms are counted for the
## human tests (QW-011) and the arena's name shows on entering (D-33).

const STAGE := "res://data/stages/catacombs.tres"

var stage: StageDef
var defs := {}


func before_all() -> void:
	stage = load(STAGE)
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)


## One whole descent by random doors: the rooms entered, in order. Every door offered is checked on the way: a
## fountain is always in the hall.
func _descend(rng: RandomNumberGenerator) -> Array[RunMap.Room]:
	var map := RunMap.new(stage, rng)
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
				assert_eq(stage.layouts[d.layout].id, &"hall", "the fountain is in the hall")
				assert_eq(d.depth, 4, "the fountain is offered in room 4")
		room = doors[rng.randi() % doors.size()]
	return out


func test_seven_rooms_from_the_hall_to_morvath() -> void:
	var rng := RandomNumberGenerator.new()
	for run in 1000:
		rng.seed = run
		var rooms := _descend(rng)
		assert_eq(rooms.size(), 7, "seven rooms")
		if rooms.size() != 7:
			return
		assert_eq(stage.layouts[rooms[0].layout].id, &"hall", "the opening is the hall")
		assert_eq(rooms[4].kind, RunMap.Kind.MINIBOSS)
		assert_true(stage.layouts[rooms[4].layout].guardian, "the guardian fights where a guardian may")
		assert_eq(rooms[5].kind, RunMap.Kind.SHOP)
		assert_eq(rooms[6].kind, RunMap.Kind.BOSS)
		# after the opening, fights in the arenas (never the hall again), never the same arena twice in a row; the
		# first three fights in three different places
		var places: Array[StringName] = [stage.layouts[rooms[0].layout].id]
		for i in range(1, 5):
			if rooms[i].kind == RunMap.Kind.FOUNTAIN:
				places.append(&"")
				continue
			var at := stage.layouts[rooms[i].layout].id
			assert_ne(at, &"hall", "run %d: room %d is an arena" % [run, i + 1])
			assert_ne(at, places[-1], "run %d: two fights in a row in %s" % [run, at])
			places.append(at)
		assert_ne(places[1], places[2], "run %d: rooms 2 and 3 in different arenas" % run)
		for r in rooms:
			assert_lt(r.variant, stage.layouts[r.layout].variant_count(), "a variant the arena has")


func test_every_arena_and_variant_comes_up() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var seen := {}
	for run in 300:
		for r in _descend(rng):
			seen["%s %d" % [stage.layouts[r.layout].id, r.variant]] = true
	for id in ["crypt", "rift", "garden"]:
		for v in 2:
			assert_true(seen.has("%s %d" % [id, v]), "%s %d is drawn" % [id, v])


func test_the_same_seed_gives_the_same_descent() -> void:
	var r1 := RandomNumberGenerator.new()
	var r2 := RandomNumberGenerator.new()
	r1.seed = 5
	r2.seed = 5
	var one := _descend(r1)
	var two := _descend(r2)
	for i in one.size():
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
