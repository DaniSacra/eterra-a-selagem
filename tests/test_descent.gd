extends GutTest
## The descent (C13-01, D-61; DV-1, the Descida de Valmor, MAP-01): a graph of rooms in layers drawn from the run's
## seed. Every way through has 11 rooms: the opening in the catacomb hall, fights among the arenas (never the same twice
## in a row, none more than three times, on every way), one guardian on every way (the Knight and the Elder side by
## side when his layer has two rooms), the fountain at most once on a way, the altar at most once in the graph, the
## shop in room 10, Morvath in the 11th. The test one of 7 (--medium) and the old one of 5 (--short) stay. Each arena
## brings its own ceiling of enemies, shooters and banned roles to the fights in it.
## BUG-109: nothing here reads the wall clock or a seed drawn at random; every count of assertions is the same on every
## run (the graphs come from fixed seeds, the real game's map is drawn again from one).

const STAGE := "res://data/stages/catacombs.tres"

var stage: StageDef
var defs := {}


func before_all() -> void:
	stage = load(STAGE)
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)


## Every way from the hall to Morvath (each an Array of rooms).
func _ways(map: RunMap) -> Array:
	var out: Array = []
	var stack: Array = [[map.first()]]
	while not stack.is_empty():
		var way: Array = stack.pop_back()
		var last: RunMap.Room = way[-1]
		if last.next.is_empty():
			out.append(way)
			continue
		for id in last.next:
			var longer := way.duplicate()
			longer.append(map.at(id))
			stack.append(longer)
	return out


## The arena of the fight before room i of a way (the altar is no arena: the fight before it counts).
func _before(way: Array, i: int) -> int:
	var k := i - 1
	while k > 0 and (way[k] as RunMap.Room).kind == RunMap.Kind.ALTAR:
		k -= 1
	return (way[k] as RunMap.Room).layout


## True when links (i, j) and (i2, j2) between two layers cross.
func _cross(a: int, b: int, a2: int, b2: int) -> bool:
	return (a < a2 and b > b2) or (a > a2 and b < b2)


## MAP-01's acceptance on 1000 seeds: every way has 11 rooms, opens in the hall, passes one guardian, the shop in the
## 10th and ends at Morvath; every room reached and leading on, at most 3 doors and never more than its arena's; no two
## links crossing; the arenas' rules on every way; one fountain at most on a way, one altar at most in the graph; no
## two doors of a room promising the same reward, no pomegranate before room 3; some room with two doors that lead on
## to different rooms; the Knight and the Elder side by side in at least 30% of the seeds.
func test_a_thousand_graphs_keep_every_rule() -> void:
	var pairs := 0
	var failures := 0
	var bad := []
	for s in 1000:
		var map := RunMap.new(stage, s)
		failures += map.failures
		var why := _broken(map, &"hall")
		if why != "":
			bad.append("seed %d: %s" % [s, why])
		var g := map.layer(map.miniboss_depth)
		if g.size() == 2:
			pairs += 1
			if g[0].guardian == g[1].guardian:
				bad.append("seed %d: the same guardian twice" % s)
	assert_eq(bad, [], "every graph keeps every rule")
	assert_gte(pairs, 300, "the Knight and the Elder side by side in %d of 1000" % pairs)
	gut.p("graphs drawn again for a broken rule: %d in 1000 seeds" % failures)


## The first rule a graph breaks ("" for none); opening: the arena of the first room.
func _broken(map: RunMap, opening: StringName) -> String:
	if map.last_depth() != 11 or stage.layouts[map.first().layout].id != opening:
		return "11 layers, %s first" % opening
	var reached := {map.first().id: true}
	var altars := 0
	var fountains := 0
	for d in range(1, map.last_depth() + 1):
		var layer := map.layer(d)
		var rewards := {}
		for r in layer:
			if d > 1 and not reached.has(r.id):
				return "room %d is never reached" % r.id
			if r.depth != d:
				return "room %d out of its layer" % r.id
			if d < map.last_depth():
				if r.next.is_empty() or r.next.size() > 3:
					return "room %d has %d doors" % [r.id, r.next.size()]
				var arena: RoomLayout = stage.altar_layout if r.kind == RunMap.Kind.ALTAR else stage.layouts[r.layout]
				if arena.exits.size() > 0 and r.next.size() > arena.exits.size():
					return "room %d has more doors than its arena" % r.id
			for n in r.next:
				reached[n] = true
				if map.at(n).depth != d + 1:
					return "a link skips a layer"
				for r2 in layer:
					for n2 in r2.next:
						if _cross(r.slot, map.at(n).slot, r2.slot, map.at(n2).slot):
							return "two links cross"
			if r.kind == RunMap.Kind.COMBAT and d > 1:
				if rewards.has(r.reward):
					return "two rooms of a layer promise the same"
				rewards[r.reward] = true
				if r.reward == RunMap.Reward.POM and d < stage.pom_from_depth:
					return "a pomegranate before room %d" % stage.pom_from_depth
				if r.reward == RunMap.Reward.NONE:
					return "a fight with no reward"
			if r.kind == RunMap.Kind.ALTAR:
				altars += 1
				if d < stage.altar_depth_min or d > stage.altar_depth_max:
					return "the altar out of its depths"
			if r.kind == RunMap.Kind.FOUNTAIN:
				fountains += 1
				if stage.layouts[r.layout].id != &"hall" or d < stage.fountain_depth_min or d > stage.fountain_depth_max:
					return "the fountain out of the hall or of its depths"
			if r.kind == RunMap.Kind.MINIBOSS and (r.reward != RunMap.Reward.BOON or not stage.minibosses.has(r.guardian)):
				return "a guardian with no Blessing or no guardian"
			if r.trial and (r.kind != RunMap.Kind.COMBAT or not r.hidden or d < stage.trial_depth_min or d > stage.trial_depth_max):
				return "a \"?\" out of its rule"
	if altars > 1:
		return "two altars"
	if fountains < 1:
		return "no fountain"
	var differ := false
	for way: Array in _ways(map):
		if way.size() != 11:
			return "a way of %d rooms" % way.size()
		var kinds := way.map(func(r: RunMap.Room) -> int: return r.kind)
		if kinds.count(RunMap.Kind.MINIBOSS) != 1 or kinds[9] != RunMap.Kind.SHOP or kinds[10] != RunMap.Kind.BOSS:
			return "a way without its guardian, shop or Morvath"
		if kinds.count(RunMap.Kind.FOUNTAIN) > 1:
			return "two fountains on a way"
		if way.filter(func(r: RunMap.Room) -> bool: return r.trial).size() > 1:
			return "two \"?\" on a way"
		var uses := {}
		for i in way.size():
			var r: RunMap.Room = way[i]
			if r.layout >= 0:
				uses[r.layout] = int(uses.get(r.layout, 0)) + 1
			if (r.kind == RunMap.Kind.COMBAT or r.kind == RunMap.Kind.MINIBOSS) and i > 0:
				var l := stage.layouts[r.layout]
				if l.id == &"hall":
					return "a fight in the hall after the opening"
				if r.layout == _before(way, i):
					return "two rooms in a row in %s" % l.id
				if r.kind == RunMap.Kind.MINIBOSS and not l.guardian:
					return "the guardian where no guardian stands"
				if r.variant >= l.variant_count():
					return "a variant the arena has not"
		for l: int in uses:
			if uses[l] > stage.arena_max_uses:
				return "%s more than %d times" % [stage.layouts[l].id, stage.arena_max_uses]
	for r in map.nodes:
		for x in r.next.size():
			for y in range(x + 1, r.next.size()):
				if _after(map, map.at(r.next[x])) != _after(map, map.at(r.next[y])):
					differ = true
	if not differ:
		return "no room whose two doors lead on to different rooms"
	return ""


## The ids of the rooms after r (r left out), sorted.
func _after(map: RunMap, r: RunMap.Room) -> Array:
	var seen := {}
	var todo: Array = r.next.duplicate()
	while not todo.is_empty():
		var id: int = todo.pop_back()
		if not seen.has(id):
			seen[id] = true
			todo.append_array(map.at(id).next)
	var out := seen.keys()
	out.sort()
	return out


## The same seed, the same graph; 100 seeds give at least 95 different graphs (rooms, links, rewards, arenas).
func test_the_seed_decides_the_graph() -> void:
	assert_eq(_shape(RunMap.new(stage, 5)), _shape(RunMap.new(stage, 5)), "the same seed, the same graph")
	var shapes := {}
	for s in 100:
		shapes[_shape(RunMap.new(stage, 1000 + s))] = true
	assert_gte(shapes.size(), 95, "%d different graphs in 100 seeds" % shapes.size())


func _shape(map: RunMap) -> String:
	var sum := map.summary()
	return JSON.stringify([sum.nodes, sum.edges, map.nodes.map(func(r: RunMap.Room) -> int: return r.variant)])


## The fights left on the worst way (BUG-101 on the graph): from every room, the fewest fights on any way to the shop.
func test_the_fights_left_are_the_worst_way() -> void:
	for s in 200:
		var map := RunMap.new(stage, 3000 + s)
		var low := {}
		for way: Array in _ways(map):
			for i in way.size():
				var r: RunMap.Room = way[i]
				var n := way.slice(i + 1).filter(func(x: RunMap.Room) -> bool:
					return x.kind == RunMap.Kind.COMBAT or x.kind == RunMap.Kind.MINIBOSS).size()
				low[r.id] = mini(int(low.get(r.id, 99)), n)
		var wrong := 0
		for r in map.nodes:
			if map.fights_left(r) != int(low[r.id]):
				wrong += 1
			if r.trial and map.fights_left(r) < 3:
				wrong += 1
		assert_eq(wrong, 0, "seed %d: the fights left are the worst way's, and every \"?\" has 3 after it" % s)


## Walking the graph: the path, the room he stands in, its doors; a room of no graph (a test's) takes the doors of its
## depth's first room; the view in plain values for the map screen.
func test_walking_and_the_view() -> void:
	var map := RunMap.new(stage, 21)
	var heard := [0]
	map.changed.connect(func() -> void: heard[0] += 1)
	map.enter(map.first())
	assert_eq(map.here, map.first())
	assert_eq(map.path, [map.first().id] as Array[int])
	assert_eq(map.doors().size(), map.first().next.size())
	var door := map.doors()[0]
	map.enter(door)
	assert_eq(map.depth, 2)
	assert_true(map.walked(door))
	assert_eq(heard[0], 2, "the map says when he moves")
	var v := map.view()
	assert_eq((v.layers as Array).size(), 11)
	assert_eq(int(v.here), door.id)
	assert_eq(v.doors, door.next)
	for k in ["id", "depth", "slot", "kind", "reward", "guardian", "hidden", "arena", "next"]:
		assert_true((v.layers[0][0] as Dictionary).has(k), "a room of the view has %s" % k)
	var stray := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 4, 1, 0)
	map.enter(stray)
	assert_eq(stray.next, map.layer(4)[0].next, "a room of no graph takes its depth's doors")
	assert_eq(map.trial(4).kind, RunMap.Kind.TRIAL)


## A pomegranate behind a door when nothing can grow turns into a Blessing before the sign shows (Q-25 a), and the map
## says so; the "?" turns into its room when the slab appears.
func test_the_promise_is_kept_before_the_sign() -> void:
	var map: RunMap
	var pom: RunMap.Room = null
	for s in 20:
		map = RunMap.new(stage, s)
		for r in map.nodes:
			if r.reward == RunMap.Reward.POM:
				pom = r
		if pom != null:
			break
	assert_not_null(pom)
	var doors: Array[RunMap.Room] = [pom]
	assert_eq(map.settle(doors, true), 0, "something can grow: it stays")
	assert_eq(map.settle(doors, false), 1)
	assert_eq(pom.reward, RunMap.Reward.BOON)
	assert_eq(map.pom_turned, 1)
	var hidden := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 3)
	hidden.trial = true
	hidden.hidden = true
	map.reveal(hidden)
	assert_false(hidden.hidden)
	assert_true(hidden.trial)


func test_the_shorter_descents_stay() -> void:
	var medium := Rooms.short_stage(stage, 6)
	var short := Rooms.short_stage(stage, 4)
	for s in 200:
		for way: Array in _ways(RunMap.new(medium, s)):
			assert_eq(way.size(), 7)
			assert_eq((way[4] as RunMap.Room).kind, RunMap.Kind.MINIBOSS)
			assert_eq((way[5] as RunMap.Room).kind, RunMap.Kind.SHOP)
			assert_eq((way[6] as RunMap.Room).kind, RunMap.Kind.BOSS)
		for way: Array in _ways(RunMap.new(short, s)):
			assert_eq(way.size(), 5)
			assert_eq((way[2] as RunMap.Room).kind, RunMap.Kind.MINIBOSS)
			assert_eq((way[3] as RunMap.Room).kind, RunMap.Kind.SHOP)
	assert_eq(stage.rooms, 10, "the long descent is the default")
	assert_eq(stage.elite_from_depth, 3, "elites from depth 3, as in Hades II")
	assert_eq(medium.elite_from_depth, 2)


## --arena makes the opening that arena; the Juramentos' stage (more elites, dearer shop) draws the same graph.
func test_the_dev_arena_and_the_juramentos() -> void:
	var crypt := stage.layouts.find(stage.layouts.filter(func(l: RoomLayout) -> bool: return l.id == &"crypt")[0])
	for s in 50:
		var map := RunMap.new(stage, s, crypt)
		assert_eq(map.first().layout, crypt)
		assert_eq(_broken(map, &"crypt"), "", "seed %d with --arena=crypt" % s)
	var vows := Juramentos.new(Juramentos.load_catalog(), {&"menace": 2, &"debt": 1})
	var sworn := vows.stage_for(stage)
	assert_eq(_shape(RunMap.new(sworn, 9)), _shape(RunMap.new(stage, 9)), "the vows do not change the graph")


func test_every_arena_and_variant_comes_up() -> void:
	var seen := {}
	for s in 300:
		for r in RunMap.new(stage, 99 + s).nodes:
			if r.layout >= 0:
				seen["%s %d" % [stage.layouts[r.layout].id, r.variant]] = true
	for id in ["crypt", "rift", "garden", "sanctuary", "bridge", "runes"]:
		for v in 2:
			assert_true(seen.has("%s %d" % [id, v]), "%s %d is drawn" % [id, v])


## The guardian's fight is in the Santuário when it may be (it is a high arena drawn from 40% of the descent for
## fights); and in the shorter descents too.
func test_the_guardian_fights_in_the_sanctuary() -> void:
	var at_home := 0
	var all := 0
	for s in 300:
		var map := RunMap.new(Rooms.short_stage(stage, 6) if s % 3 == 0 else stage, 1000 + s)
		for r in map.layer(map.miniboss_depth):
			all += 1
			if stage.layouts[r.layout].id == &"sanctuary":
				at_home += 1
	assert_gt(float(at_home), all * 0.95, "the guardian is at home unless he fought there the room before (%d of %d)" % [at_home, all])


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
	t.enter(1, "hall", 30.0, 0.0, false, 0, 0, 0, 0)
	t.touch(2.5)
	t.touch(4.0)
	t.hurt("skeleton", 3.0)
	t.hurt("skeleton", 2.0)
	t.hurt("archer", 1.5)
	t.hurt("archer", 0.0)
	t.enter(2, "crypt", 23.5, 30.0, false, 0, 0, 0, 3)
	t.enter(7, "", 20.0, 70.0, true)
	t.hurt("scythe", 4.0)
	var rooms := t.rooms(100.0)
	assert_eq(rooms.size(), 3)
	assert_eq(rooms[0].layout, "hall")
	assert_eq(int(rooms[0].node), 0, "the node of the graph")
	assert_eq(int(rooms[1].node), 3)
	assert_eq(int(rooms[2].node), -1)
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


func _game() -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	return game


func test_the_result_and_the_arena_name() -> void:
	var game := _game()
	assert_eq(game.arena.id, &"hall", "the run opens in the hall")
	assert_eq(game.hud.place_shown(), T.t(&"arena_hall"), "the name of the place shows on entering")
	var r := game.result()
	assert_eq(r.arena, "hall")
	assert_eq(r.rooms.size(), 1)
	assert_eq(r.rooms[0].layout, "hall")
	assert_eq(int(r.rooms[0].node), game.rooms.map.first().id)
	assert_eq(float(r.hp_at_boss), -1.0, "not at Morvath yet")
	for key in ["stuck", "stuck_by", "shots_blocked", "map"]:
		assert_true(r.has(key), "RESULT has %s" % key)
	for key in ["seed", "nodes", "edges", "path"]:
		assert_true((r.map as Dictionary).has(key), "RESULT map has %s" % key)


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


## MAP-02: the doors of a room are the links of its node. Before they open, the fight behind each is drawn on that
## room's own seed (the same room gives the same fight whatever the way to it), the sign says "Difícil" for an elite and
## "Guardião" for the guardian (with who waits there), and the room he walks into is the room the door promised.
func test_the_doors_are_the_links_of_the_graph() -> void:
	var game := _game()
	var rooms := game.rooms
	rooms.map = RunMap.new(rooms.stage, 41)
	var seen_hard := false
	var told := 0
	for r in rooms.map.nodes:
		if r.kind == RunMap.Kind.BOSS:
			continue
		rooms.map.enter(r)
		rooms.next_rooms = rooms.map.doors()
		rooms._prepare(rooms.next_rooms)
		assert_eq(rooms.next_rooms.size(), r.next.size(), "room %d: one door a link" % r.id)
		for i in rooms.next_rooms.size():
			var d := rooms.next_rooms[i]
			var info := rooms.door_info(i)
			told += 1
			assert_eq(int(info.node), r.next[i], "door %d is link %d" % [i, i])
			assert_eq(int(info.reward), d.reward, "the sign tells the node's reward")
			assert_eq(int(info.kind), d.kind)
			assert_eq(bool(info.hidden), d.hidden)
			if d.kind == RunMap.Kind.COMBAT or d.kind == RunMap.Kind.MINIBOSS:
				assert_not_null(d.fight, "the fight behind door %d is drawn before it opens" % i)
				assert_eq(String(info.arena), String(d.arena), "the doorway knows the arena it leads to")
			if d.kind == RunMap.Kind.MINIBOSS:
				assert_true(info.guardian)
				assert_eq(d.fight.kinds[0], d.guardian, "the guardian of the node")
				assert_eq(info.guardian_key, game.horde.def(d.guardian).name_key)
				assert_true(Rooms.door_text(d).contains(T.t(&"room_miniboss")), "the guardian's door says so")
			if info.get("hard", false):
				seen_hard = true
				assert_true(Rooms.door_text(d).contains(T.t(&"door_hard")), "a hard fight's door says Difícil")
				assert_false((info.elites as Array).is_empty())
	assert_eq(told, rooms.map.summary().edges.size(), "a door for every link")
	assert_true(seen_hard, "a hard fight came up behind some door")
	# the same node, the same fight, whatever the dice of the run did before
	var again := RunMap.new(rooms.stage, 41)
	for k in 50:
		rooms._rng.randi()  # the run's dice moved on: other rooms, other choices
	for r in again.nodes:
		if r.kind == RunMap.Kind.COMBAT and r.depth > 1:
			var doors: Array[RunMap.Room] = [r]
			rooms._prepare(doors)
			var first := rooms.map.at(r.id)
			assert_eq(r.fight.kinds, first.fight.kinds, "room %d: the same fight" % r.id)
			assert_eq(r.fight.waves, first.fight.waves)
	# the fight he walks into is the one the door promised
	rooms.map.enter(rooms.map.first())
	rooms.next_rooms = rooms.map.doors()
	var door := rooms.next_rooms[0]
	var promised := door.fight.kinds.duplicate()
	rooms._enter(door)
	assert_eq(rooms.room, door)
	assert_eq(rooms.map.here, door)
	var risen := {}
	for w in rooms._waves:
		for id in w:
			risen[id] = true
	for id in promised:
		assert_true(risen.has(id), "%s comes as promised" % id)


## MAP-02 on 200 descents by the robot's doors (Rooms.bot_door on the graph, life going up and down): at every door
## the room walked into is the one its sign told (kind, reward, guardian, arena, "?", the fight drawn before it
## opened), a pomegranate is only promised when something can grow (now and then nothing can: it turns into a
## Blessing before the sign), every way ends at Morvath in the 11th room.
func test_two_hundred_descents_keep_the_promise() -> void:
	var game := _game()
	var rooms := game.rooms
	var broken := []
	var turned := 0
	var dice := RandomNumberGenerator.new()
	dice.seed = 200
	for s in 200:
		var map := RunMap.new(rooms.stage, 5000 + s)
		rooms.map = map
		map.enter(map.first())
		var walked := 1
		while map.here.kind != RunMap.Kind.BOSS:
			var doors := map.doors()
			rooms.next_rooms = doors
			rooms._prepare(doors)
			var can_grow := dice.randf() < 0.9
			turned += map.settle(doors, can_grow)
			var told: Array = []
			for i in doors.size():
				var info := rooms.door_info(i)
				told.append([info.kind, info.reward, info.guardian_id, String(info.arena), info.hidden, doors[i].fight])
				if not can_grow and int(info.reward) == RunMap.Reward.POM:
					broken.append("seed %d: a pomegranate promised with nothing to grow" % s)
			var pick := Rooms.bot_door(doors, dice.randf() < 0.5, dice.randf(), map)
			var r := doors[pick]
			map.enter(r)
			walked += 1
			var got := [r.kind, r.reward, String(r.guardian), String(r.arena), r.hidden, r.fight]
			if got != told[pick]:
				broken.append("seed %d room %d: told %s, got %s" % [s, walked, told[pick], got])
		if walked != 11:
			broken.append("seed %d: %d rooms" % [s, walked])
	assert_eq(broken, [], "the room is the one its door told")
	assert_gt(turned, 0, "a pomegranate turned when nothing could grow")


## The robot reads the map (MAP-04): its taste for the door in front of it plus half of the best way on after it,
## checked against every way of the graph; without the map, the doors' rewards as before.
func test_the_robot_reads_the_map() -> void:
	var off := 0
	var detours := 0
	for s in 100:
		var map := RunMap.new(stage, 700 + s)
		for r in map.nodes:
			var doors := map.doors_of(r)
			if doors.size() < 2:
				continue
			var pick := Rooms.bot_door(doors, true, 0.5, map)
			var plain := Rooms.bot_door(doors, true, 0.5)
			if pick != plain:
				detours += 1
			var scores: Array[float] = []
			for d in doors:
				var best := 0.0
				for way: Array in _ways_from(map, d):
					var worth := 0.0
					for n: RunMap.Room in way:
						worth += Rooms._bot_worth(n, true)
					best = maxf(best, worth)
				scores.append(best)
			for i in doors.size():
				# the door taken is never worse than another by more than its own taste can pay back
				if Rooms.BOT_AHEAD * (scores[i] - scores[pick]) > Rooms.BOT_PREFERENCE.size() + 2.0:
					off += 1
	assert_eq(off, 0, "the robot never leaves a much better way")
	assert_gt(detours, 0, "the map changes some of its choices")


## Every way from r on (r left out).
func _ways_from(map: RunMap, r: RunMap.Room) -> Array:
	if r.next.is_empty():
		return [[]]
	var out: Array = []
	for id in r.next:
		var n := map.at(id)
		for rest: Array in _ways_from(map, n):
			out.append([n] + rest)
	return out


## In a real room: the reward the room gives is the one its door promised, and the log says both (RESULT events).
func test_the_reward_given_is_the_one_promised() -> void:
	var game := _game()
	var rooms := game.rooms
	rooms.map = RunMap.new(rooms.stage, 41)
	rooms.map.enter(rooms.map.first())
	rooms.next_rooms = rooms.map.doors()
	rooms._prepare(rooms.next_rooms)
	var door: RunMap.Room = null
	for d in rooms.next_rooms:
		if d.kind == RunMap.Kind.COMBAT and d.reward in [RunMap.Reward.GOLD, RunMap.Reward.HEART, RunMap.Reward.MAGICK]:
			door = d
	if door == null:
		door = rooms.next_rooms[0]
		door.reward = RunMap.Reward.GOLD  # (this graph's hall shows no plain reward: the test makes one)
	var gold := rooms.gold
	rooms._log_leaving(door)
	rooms._enter(door)
	game.horde.clear_crowd()
	rooms._room_cleared()
	game.player.place(rooms._reward_at)
	rooms.step(0.0)
	assert_eq(game.room_tally.events.filter(func(e: Dictionary) -> bool: return e.type == "reward").size(), 0,
		"standing at it gives nothing (C19, Q-13)")
	rooms.use()
	rooms.step(0.0)
	var given := game.room_tally.events.filter(func(e: Dictionary) -> bool: return e.type == "reward")
	assert_eq(given.size(), 1, "the room gave once")
	assert_eq(int(given[0].node), door.id)
	assert_eq(given[0].reward, (RunMap.Reward.keys()[door.reward] as String).to_lower(), "what the door promised")
	if door.reward == RunMap.Reward.GOLD:
		assert_eq(rooms.gold - gold, rooms.stage.gold_reward)


## MAP-05, the PO's acceptance as far as a test goes: in a real descent a room shows two doors that lead on to
## different rooms; walking into one door's mouth in the arena takes him to that room, and the map's path says so;
## another seed draws another graph, every way of both reaching Morvath.
func test_map05_the_door_walked_through_is_the_way_on_the_map() -> void:
	var game := _game()
	var rooms := game.rooms
	rooms.map = RunMap.new(rooms.stage, 41)
	var map := rooms.map
	rooms._enter(map.first())
	var doors := map.doors()
	var pick := -1
	for i in doors.size():
		for k in doors.size():
			if k != i and _after(map, doors[i]) != _after(map, doors[k]):
				pick = i
	assert_gt(pick, -1, "two doors of the hall lead on to different rooms")
	game.horde.clear_crowd()
	rooms._wave = rooms._waves.size()
	rooms.phase = Rooms.Phase.REWARD
	rooms._open_doors()
	assert_eq(game.arena.exit_zones.size(), doors.size(), "a doorway for every link")
	game.player.place(game.arena.exit_zones[pick].get_center())
	rooms.use()  # (C19, Q-13: a door is used with interact)
	rooms.step(1.0 / 60.0)
	await wait_seconds(Rooms.FADE + 0.3)
	assert_eq(rooms.room, doors[pick], "he walked into the room behind that door")
	assert_eq(map.path, [map.first().id, doors[pick].id] as Array[int], "and the map's path says so")
	assert_eq(int(map.view().here), doors[pick].id)
	var other := RunMap.new(rooms.stage, 42)
	assert_ne(_shape(other), _shape(map), "another seed, another graph")
	for m: RunMap in [map, other]:
		for way: Array in _ways(m):
			assert_eq((way[-1] as RunMap.Room).kind, RunMap.Kind.BOSS, "every way reaches Morvath")
