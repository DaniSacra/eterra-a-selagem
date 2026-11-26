extends GutTest
## SW-O3 and SW-O4 (docs/design/onboarding_sw_o.md): the guided first descent in data (rooms, waves, doors), when it is the
## one played (FirstDescent.active), what ends it (FirstDescent.finish), the save's `first` and its migration, the
## graph RunMap.scripted draws from the data, the Antessala (the hall's variant "ante": its stream, its way) and that the
## long descent does not feel any of it.

const STAGE := "res://data/stages/catacombs.tres"
const CELL := 0.25
const REACH := 31.0
const EPS := 0.01

var stage: StageDef
var def: FirstDescentDef
var tutorial_stage: StageDef


func before_all() -> void:
	stage = load(STAGE)
	def = FirstDescentDef.live()
	tutorial_stage = FirstDescent.stage_for(stage, def)


func _hall() -> RoomLayout:
	return stage.layouts[0]


func _ante() -> RoomLayout:
	return _hall().variant(1)


func _room(id: StringName) -> FirstRoomDef:
	for r in def.rooms:
		if r.id == id:
			return r
	return null


func _ids_of(r: FirstRoomDef) -> Array[StringName]:
	return r.kinds()


# ---------- the data ----------

func test_the_data_loads_with_nine_steps() -> void:
	assert_not_null(def, "data/first_descent.tres loads")
	assert_eq(def.last_layer(), 8, "steps 0 to 8")
	assert_eq(def.rooms_total, 8, "Sala N de 8")
	for n in range(0, 9):
		assert_gt(def.layer(n).size(), 0, "step %d has a room" % n)
	assert_eq(def.layer(3).size(), 2, "the first choice of door: two rooms")
	assert_eq(def.layer(4).size(), 2, "the second: the fountain or the Cripta B")
	assert_eq(def.boss_last_phase, 1, "Morvath fights his first phase only")
	assert_lt(def.boss_hp_scale, 1.0, "with less life")


func test_every_enemy_exists_and_the_kinds_come_one_part_at_a_time() -> void:
	var known: Array[StringName] = []
	for id in stage.enemies:
		known.append(id)
	known.append(&"knight")
	for r in def.rooms:
		for id in r.kinds():
			assert_true(known.has(id), "%s: %s is an enemy of the stage" % [r.id, id])
			assert_true(ResourceLoader.exists("res://data/enemies/%s.tres" % id), "%s has its data" % id)
	assert_eq(_ids_of(_room(&"crypt_a")), [&"skeleton"] as Array[StringName], "room 1: only the skeleton")
	for id in _ids_of(_room(&"rift_a")):
		assert_true(id in [&"archer", &"skeleton"], "room 2: the archer and the skeleton, not %s" % id)
	for r in def.layer(3):
		for id in r.kinds():
			assert_true(id in [&"bone_rat", &"runner"], "room 3: rats and runners, not %s" % id)
	assert_true(_ids_of(_room(&"crypt_b")).size() >= 3, "the mix comes in room 4")
	for r in def.rooms:
		if r.layer > 0 and r.layer < 4:
			assert_false(&"guard" in r.kinds() or &"mage" in r.kinds(), "%s: no shield or caster before the mix" % r.id)
		for id in r.kinds():
			assert_false(String(id).ends_with("_elite") or String(id).ends_with("_big"), "%s: nothing bigger, no elite" % r.id)


func test_the_first_blessing_is_in_the_antessala_with_a_fixed_angel() -> void:
	# PT-25-8: the descent begins with a Blessing, asked for in the Antessala before the first room (Sarael's)
	var a := _room(&"ante")
	assert_eq(a.angel, &"sarael")
	assert_eq(_room(&"crypt_a").reward, RunMap.Reward.GOLD, "room 1 gives gold, the Blessing came before")
	assert_eq(_room(&"garden_boon").angel, &"nivael", "the second angel on the first choice")
	assert_eq(_room(&"garden_pom").reward, RunMap.Reward.POM, "or a pomegranate")
	assert_true(ResourceLoader.exists("res://data/angels/00_sarael.tres") and ResourceLoader.exists("res://data/angels/01_nivael.tres"))


func test_the_guardian_is_alone_in_room_five_the_shop_in_seven_and_morvath_in_eight() -> void:
	var k := _room(&"knight")
	assert_eq(k.kind, RunMap.Kind.MINIBOSS)
	assert_eq(k.layer, 5)
	assert_eq(k.waves.size(), 1, "one wave")
	assert_eq(k.waves[0].size(), 1, "the Knight, no escort")
	assert_eq(k.guardian, &"knight")
	assert_eq(k.hp_scale, 1.0, "full life (2026-11-26: 650 of his own, the guard stays 550 and 0.5)")
	assert_eq(_room(&"shop").kind, RunMap.Kind.SHOP)
	assert_eq(_room(&"shop").layer, 7)
	assert_eq(_room(&"morvath").kind, RunMap.Kind.BOSS)
	assert_eq(_room(&"morvath").layer, 8)
	assert_eq(_room(&"ante").kind, RunMap.Kind.ANTE)


func test_every_layout_is_in_the_stage_and_the_hazards_are_off_but_where_they_teach() -> void:
	for r in def.rooms:
		if r.layout_id == &"":
			continue
		var found := false
		for l in stage.layouts:
			found = found or l.id == r.layout_id
		assert_true(found, "%s: the arena %s exists" % [r.id, r.layout_id])
	assert_false(_room(&"crypt_a").hazards, "room 1: no slabs")
	assert_false(_room(&"rift_a").hazards, "room 2: no falling floor")
	assert_true(_room(&"crypt_b").hazards, "room 4: the teaching slabs")
	assert_lt(_room(&"crypt_b").hazard_progress, 0.26, "awake and on their own cycle")


# ---------- when it is the one played ----------

func test_active_the_whole_matrix() -> void:
	var fresh := {"first": 0}
	assert_true(FirstDescent.active(fresh, {"save": true}), "a new save plays it")
	assert_false(FirstDescent.active({"first": 1}, {"save": true}), "done")
	assert_false(FirstDescent.active({"first": 2}, {"save": true}), "skipped")
	assert_true(FirstDescent.active({}, {"save": true}), "no field: pending")
	for k in FirstDescent.BLOCKED_BY:
		assert_false(FirstDescent.active(fresh, {"save": true, k: true}), "%s keeps it out" % k)
	assert_false(FirstDescent.active(fresh, {"save": false}), "no save, no guided descent")
	assert_true(FirstDescent.active({"first": 1}, {"first": true}), "--first forces it on a done save")
	assert_true(FirstDescent.active(fresh, {"first": true, "bot": true, "nosave": true, "smoke": true, "save": false}), "and over every other switch")


func test_the_tests_and_the_robot_run_the_long_descent() -> void:
	# the hook (tests/hooks/pre_run.gd) turned Save.enabled off and no test passes --first
	assert_false(FirstDescent.active({"first": 0}, FirstDescent.flags_now(Save.enabled)), "a test never plays the guided descent")
	assert_false(Dev.has("first"))


func test_finish_writes_first_and_never_goes_back() -> void:
	var d := {"first": 0, "wins": 0}
	FirstDescent.finish(d, &"death")
	assert_eq(d.first, FirstDescent.DONE)
	assert_eq(d.wins, 0, "no win")
	assert_false(d.has("firsts"), "no first of the guardian nor of the victory")
	var e := {"first": 0}
	FirstDescent.finish(e, &"done")
	assert_eq(e.first, FirstDescent.DONE)
	var s := {"first": 0}
	FirstDescent.finish(s, &"skip")
	assert_eq(s.first, FirstDescent.SKIPPED)
	FirstDescent.finish(s, &"done")
	assert_eq(s.first, FirstDescent.SKIPPED, "a descent already past is not played again")


# ---------- the save ----------

func test_a_new_save_has_first_pending() -> void:
	assert_eq(SaveData.defaults().first, 0)
	assert_eq(SaveData.VERSION, 16)


func test_version_15_with_descents_played_is_done_and_a_new_one_is_pending() -> void:
	var old := SaveData.defaults()
	old["version"] = 15
	old.erase("first")
	old["runs"] = 3
	assert_eq(SaveData.merged(old).first, 1, "played: done")
	old["runs"] = 0
	assert_eq(SaveData.merged(old).first, 0, "never played: still to do")
	var kept := SaveData.defaults()
	kept["first"] = 2
	assert_eq(SaveData.merged(kept).first, 2, "a skip is kept")
	kept["first"] = 9
	assert_eq(SaveData.merged(kept).first, 2, "and a wrong value is held to the range")


func test_a_skipped_save_goes_to_the_santuario_and_a_new_one_to_the_descent() -> void:
	var boot := load("res://scripts/boot.gd") as GDScript
	assert_eq(boot.call(&"first_scene", {"runs": 0, "first": 0}), SceneGo.GAME)
	assert_eq(boot.call(&"first_scene", {"runs": 0, "first": 2}), SceneGo.HUB, "skipped: straight to the Santuário")
	assert_eq(boot.call(&"first_scene", {"runs": 2, "first": 1}), SceneGo.HUB)


func test_the_run_log_has_first_in_version_nine() -> void:
	assert_eq(RunLog.VERSION, 9)
	var old := RunLog.normalized({"version": 8, "outcome": "death"})
	assert_false(bool(old.first), "an old line is a descent like any other")


# ---------- the graph ----------

func test_scripted_is_linear_and_the_doors_are_the_next_step() -> void:
	var m := FirstDescent.map(tutorial_stage, def, 5)
	assert_true(m.is_scripted)
	assert_eq(m.last_depth(), 8, "Morvath at depth 8")
	assert_eq(m.first().kind, RunMap.Kind.ANTE)
	assert_eq(m.first().depth, 0)
	for d in range(0, 8):
		for id in m.layers[d]:
			var next: Array[int] = []
			for n in m.layers[d + 1]:
				next.append(n)
			assert_eq(m.nodes[id].next, next, "each room of step %d opens on every room of step %d" % [d, d + 1])
	assert_eq(m.nodes[m.layers[8][0]].next.size(), 0, "Morvath has no door")
	assert_eq(m.first().next.size(), 1, "the Antessala has one door")
	assert_eq(m.layers[1].size(), 1, "one way into room 1")
	assert_eq(m.layers[5].size(), 1, "and the guardian is one room")
	for r in m.nodes:
		assert_eq(r.guardian != &"", r.kind == RunMap.Kind.MINIBOSS, "only the guardian's room names a guardian")
		if r.kind == RunMap.Kind.COMBAT or r.kind == RunMap.Kind.MINIBOSS:
			assert_not_null(r.fight, "a fight written in the room")
	assert_eq(m.failures, 0, "no graph was drawn and thrown away")


func test_the_fight_in_the_graph_is_the_data() -> void:
	var m := FirstDescent.map(tutorial_stage, def, 5)
	var r := m.nodes[m.layers[1][0]]
	assert_eq(r.fight.waves.size(), 2)
	assert_eq(r.fight.waves[0], [&"skeleton"])
	assert_eq(r.fight.waves[1], [&"skeleton", &"skeleton"])
	assert_eq(r.reward, RunMap.Reward.GOLD)
	assert_eq(r.arena, &"crypt")
	assert_eq(tutorial_stage.layouts[r.layout].id, &"crypt")


func test_the_same_data_gives_the_same_graph() -> void:
	var a := FirstDescent.map(tutorial_stage, def, 5).summary()
	var b := FirstDescent.map(tutorial_stage, def, 5).summary()
	assert_eq(a.nodes, b.nodes)
	assert_eq(a.edges, b.edges)


func test_arrival_only_keeps_the_antessala_alone() -> void:
	var m := FirstDescent.map(tutorial_stage, def, 5, true)
	assert_eq(m.nodes.size(), 1)
	assert_eq(m.first().next.size(), 0, "its door leads nowhere")


func test_the_guided_stage_has_no_event_nor_long_room() -> void:
	assert_eq(tutorial_stage.rooms, 7, "Sala N de 8")
	assert_eq(tutorial_stage.trial_chance, 0.0)
	assert_eq(tutorial_stage.altar_chance, 0.0)
	assert_eq(tutorial_stage.route_shop_chance, 0.0)
	assert_true(tutorial_stage.long_depths.is_empty())
	assert_true(tutorial_stage.fixed_rewards.is_empty())
	assert_eq(stage.rooms, 13, "the long descent's stage is not touched")
	assert_false(stage.long_depths.is_empty())


func test_the_long_descent_never_draws_an_antessala() -> void:
	for seed_value in [1, 5, 11, 23]:
		var m := RunMap.new(stage, seed_value)
		assert_false(m.is_scripted)
		for r in m.nodes:
			assert_ne(r.kind, RunMap.Kind.ANTE)
			assert_eq(r.variant == 1 and r.layout == 0, false, "the hall's variant 1 is the Antessala's alone")
	assert_false(1 in _hall().variants_at(0.0), "no share of the descent holds it")
	assert_false(1 in _hall().variants_at(1.0))


func test_the_antessala_is_no_fight_room() -> void:
	assert_false(Rooms.is_fight_room(RunMap.Kind.ANTE))
	assert_eq(Rooms.base_room_heal(RunMap.Kind.ANTE, 3.0), 0.0, "no heal")
	assert_eq(Rooms.room_silver(RunMap.Kind.ANTE, 1), 0, "no Prata")
	assert_false(Rooms.warns_exits(RunMap.Kind.ANTE, 1), "no warning of doors lighting")
	assert_eq(RunMap.KIND_KEY.size(), RunMap.Kind.size(), "every kind has its key")


# ---------- the Antessala (SW-O3) ----------

func test_the_variant_ante_exists_and_has_a_stream_across_the_hall() -> void:
	assert_eq(_hall().variants.size(), 1)
	var l := _ante()
	assert_null(l.hazard, "no slab: the stream teaches the dodge")
	assert_eq(l.gaps.size(), 1, "one stream")
	var g := l.gaps[0]
	assert_gte(g.size.y, 2.0, "2 m or more across: walking does not hop it")
	assert_lte(g.size.y, 4.0, "4 m or less: the dodge (5.6 m) crosses it")
	assert_lte(g.position.x, -_hall().half.x, "from wall to wall: no way round")
	assert_gte(g.end.x, _hall().half.x)
	assert_eq(l.gap_fall, 0.0, "it never hurts")
	assert_eq(_hall().gaps.size(), 0, "the hall's other uses carry no stream")


func test_the_stream_is_far_from_the_way_in_the_door_and_the_vases() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(_ante(), 1, 1406)
	assert_eq(a.gaps.size(), 1, "the arena keeps it")
	var g := a.gaps[0]
	assert_gt(a.start.y, g.end.y + 6.0, "the way in 6 m or more south of it")
	for z in a.exit_zones:
		assert_lt(z.end.y, g.position.y - 1.5, "the door's mouth is 1.5 m and more north of it")
	for b in _hall().breakables:
		assert_false(g.grow(0.4).has_point(b.at), "no vase stands in the water (%s)" % b.at)
	for p in a.pillars:
		assert_false(g.grow(0.5).has_point(Vector2(p.x, p.y)), "off every piece of the hall")
	for bx in a.boxes:
		assert_false(g.grow(0.5).intersects(bx), "off every block of the hall")


func test_the_way_in_reaches_the_door_and_only_the_dash_crosses_the_stream() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(_ante(), 1, 1406)
	assert_eq(a.exits.size(), 1, "one door")
	var seen := _reachable(a, a.start)
	var found := false
	for k: Vector2i in seen:
		if a.exit_at(Vector2(k) * CELL) == 0:
			found = true
	assert_true(found, "the door's zone can be walked to (the grid ignores the stream: the dash is the way)")
	var goal := a.resolve(a.door_goal(0), Player.RADIUS)
	assert_eq(a.exit_at(goal), 0, "the robot's goal leaves by the door")
	# on foot the stream holds him on his bank
	var g := a.gaps[0]
	var bank := Vector2(0.0, g.end.y + 0.5)
	var on_foot := a.keep_out_of_gaps(bank, bank + Vector2(0.0, -2.0))
	assert_gt(on_foot.y, g.end.y, "walking into the water stops on the south bank")
	# and the dash: swept across and not held by it
	var across := a.sweep(bank, bank + Vector2(0.0, -5.0), Player.RADIUS)
	assert_lt(across.y, g.position.y, "the sweep itself never holds a dash (the rule is Player.step's)")


func test_the_hero_on_foot_never_crosses_and_one_who_dashes_does() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(_ante(), 1, 1406)
	var pl := Player.new()
	add_child_autofree(pl)
	pl.arena = a
	var g := a.gaps[0]
	pl.place(Vector2(2.0, g.end.y + 0.3))
	for i in 120:
		pl.step(1.0 / 60.0, Vector2.UP, Vector2.UP)
	assert_gt(pl.pos.y, g.end.y, "a long walk north ends on the south bank")
	# a dash from the bank
	pl.state = Player.State.DODGE
	pl._dodge_dir = Vector2.UP
	pl._state_t = 0.0
	for i in 40:
		pl.step(1.0 / 60.0, Vector2.ZERO, Vector2.UP)
	assert_lt(pl.pos.y, g.position.y, "the dash from the bank lands on the north bank")


func _reachable(a: Arena, from: Vector2) -> Dictionary:
	var seen := {}
	var start := Vector2i(roundi(from.x / CELL), roundi(from.y / CELL))
	seen[start] = true
	var todo: Array[Vector2i] = [start]
	var lim := roundi(REACH / CELL)
	while not todo.is_empty():
		var k: Vector2i = todo.pop_back()
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n := k + d
			if seen.has(n) or absi(n.x) > lim or absi(n.y) > lim:
				continue
			var p := Vector2(n) * CELL
			if a.resolve(p, Player.RADIUS).distance_to(p) < EPS:
				seen[n] = true
				todo.append(n)
	return seen


func test_the_antessala_has_no_enemy_and_the_door_is_open() -> void:
	var r := _room(&"ante")
	assert_true(r.waves.is_empty(), "no wave")
	assert_eq(r.reward, RunMap.Reward.NONE, "nothing given")
	var m := FirstDescent.map(tutorial_stage, def, 5)
	assert_null(m.first().fight, "no fight is drawn for it")
	assert_eq(m.first().reward, RunMap.Reward.NONE)
	assert_eq(m.first().kind, RunMap.Kind.ANTE)


func test_the_data_of_the_guided_descent_is_in_the_milestone_and_guide_files() -> void:
	assert_true(ResourceLoader.exists("res://data/hub_guide/05_ult.tres"), "the Ultimate's guide")
	var g := load("res://data/hub_guide/05_ult.tres") as HubGuideDef
	assert_eq(g.station, HubPlan.TREE)
	assert_eq(g.text_key, &"guide_ult")


func test_the_arrival_is_set_on_a_clear_spot_of_the_antessala_and_the_hero_stands_on_it() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(_ante(), 1, 1406)
	var at := ArrivalScene.birth_spot(a)
	assert_true(ArrivalScene.is_clear(a, at), "nothing within the crystals' reach")
	assert_gte(a.shape().clamp(at, ArrivalScene.CLEAR_RADIUS).distance_to(at), 0.0)
	assert_lt(at.distance_to(a.start), 14.0, "near the way in")
	assert_lte(absf(at.y) + ArrivalScene.CRYSTAL_RING, a.half.y - Arena.WALL + 0.01, "the crystals inside the hall's balustrades")
	assert_lte(absf(at.x) + ArrivalScene.CRYSTAL_RING, a.half.x - Arena.WALL + 0.01, "and its west balustrade")
	for p in a.pillars:
		assert_gte(at.distance_to(Vector2(p.x, p.y)), p.z + ArrivalScene.CRYSTAL_RING, "no pillar at the crystals")
	for bx in a.boxes:
		assert_gte(at.distance_to(at.clamp(bx.position, bx.end)), ArrivalScene.CRYSTAL_RING, "no block or balustrade at the crystals")
	for r: Rect2 in _ante().gaps:
		assert_false(r.grow(ArrivalScene.RING_RADIUS).has_point(at), "no stream under the ring")
	# the hero parked on it (what the scene does each frame) is where he is drawn
	var pl := Player.new()
	add_child_autofree(pl)
	pl.arena = a
	pl.place(at)
	assert_lt(pl.pos.distance_to(at), 0.01, "the floor keeps him where the scene is")
