extends GutTest
## Chapter II, A-1 and A-4: the regions (several StageDef by data, the region index apart from the depth, the idempotent passage, the
## switch off = Chapter I as it was) and the four enemies of the first slice as data.

const SLICE: Array[StringName] = [&"esporinho", &"retorcido", &"flor_espinhosa", &"sapo_brejo"]

var game: Game


func after_each() -> void:
	Dev.drop("chapter2")
	Dev.drop("region")


func _start() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)


# ---------- the pure rules ----------

func test_regions_are_stage_files_and_the_first_is_the_catacombs() -> void:
	assert_eq(Regions.count(), 2)
	assert_eq(Regions.path(0), Rooms.STAGE, "the first region is the stage the game always played")
	assert_eq(Regions.path(7), Regions.path(0), "a bad index is the first region")
	assert_true(Regions.has_next(0))
	assert_false(Regions.has_next(1))
	for i in Regions.count():
		assert_true(load(Regions.path(i)) is StageDef, Regions.path(i))


func test_the_switch_is_off_by_default_and_the_command_line_wins() -> void:
	assert_false(Regions.enabled())
	assert_false(Regions.enabled(false))
	assert_true(Regions.enabled(true), "the save's option")
	Dev.put("chapter2")
	assert_true(Regions.enabled(false), "--chapter2 turns it on")
	Dev.put("chapter2", "0")
	assert_false(Regions.enabled(true), "--chapter2=0 turns it off over the option")


func test_the_passage_is_idempotent_and_never_skips_a_region() -> void:
	var r := Regions.new()
	assert_false(r.pass_to(1, false), "off: no passage")
	assert_eq(r.index, 0)
	assert_false(r.pass_to(2, true), "no region 2")
	assert_true(r.pass_to(1, true))
	assert_false(r.pass_to(1, true), "a second call does nothing")
	assert_eq(r.index, 1)
	assert_eq(r.passages, 1)
	assert_false(r.pass_to(0, true), "never back")


func test_start_region_needs_the_switch() -> void:
	Dev.put("region", "1")
	assert_eq(Regions.start_region(false), 0)
	assert_eq(Regions.start_region(true), 1)
	Dev.put("region", "9")
	assert_eq(Regions.start_region(true), 1, "clamped to the last region")


# ---------- the Bosque's stage and its four enemies ----------

func test_the_bosque_is_its_own_stage_with_only_the_four_enemies() -> void:
	var cat: StageDef = load(Regions.path(0))
	var bq: StageDef = load(Regions.path(1))
	assert_ne(bq.resource_path, cat.resource_path)
	assert_eq(bq.enemies, SLICE)
	assert_eq(bq.minibosses.size(), 1, "the guardians are a list in the data (D2-8)")
	assert_lt(bq.rooms, cat.rooms)
	assert_false(bq.layouts.is_empty(), "greybox: Chapter I's layouts stand in until A-6")
	assert_true(cat.enemies.has(&"skeleton") and not cat.enemies.has(&"esporinho"), "Chapter I is untouched")


func test_the_slice_enemies_are_valid_data_with_existing_behaviours() -> void:
	var want := {&"esporinho": EnemyDef.Behavior.PULSE, &"retorcido": EnemyDef.Behavior.CONE,
		&"flor_espinhosa": EnemyDef.Behavior.ARCHER, &"sapo_brejo": EnemyDef.Behavior.LEAP}
	for id: StringName in SLICE:
		var d: EnemyDef = load("res://data/enemies/%s.tres" % id)
		assert_not_null(d, String(id))
		assert_eq(d.id, id)
		assert_eq(d.behavior, want[id], "%s behaves as an existing kind" % id)
		assert_true(d.ground_warning, "%s warns on the floor" % id)
		assert_gt(d.hp, 0.0)
		assert_gt(d.attack_damage, 0.0)
		assert_gt(d.cost, 0, "it has a price in the budget")
		assert_true(ResourceLoader.exists("res://assets/baked/%s.res" % d.model), "%s wears a model that exists" % id)
		assert_ne(T.t(d.name_key), String(d.name_key), "%s has its name in the text" % id)
		assert_false(T.t(d.name_key).contains("—"))
	var flor: EnemyDef = load("res://data/enemies/flor_espinhosa.tres")
	assert_gt(flor.shot_count, 1, "the Flor shoots a fan")
	assert_gt(flor.shot_spread, 0.0)
	assert_lt(flor.keep_away, 1.0, "and keeps away")


func test_bosque_fights_use_only_its_enemies_and_the_first_rooms_teach_one_at_a_time() -> void:
	var st: StageDef = load(Regions.path(1))
	var defs := {}
	for id in st.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for depth in range(1, st.rooms):
		for i in 20:
			var f := EncounterGen.generate(st, depth, defs, rng)
			assert_false(f.waves.is_empty())
			for w in f.waves:
				for id: StringName in w:
					assert_true(SLICE.has(id), "%s at depth %d" % [id, depth])
	var one := EncounterGen.generate(st, 1, defs, rng)
	assert_eq((one.waves[0] as Array).size(), 1, "the first room opens with a single silhouette")


func test_a_bosque_graph_is_complete_and_ends_at_the_guardian_then_the_chamber() -> void:
	var st: StageDef = load(Regions.path(1))
	var m := RunMap.new(st, 77)
	assert_eq(m.layers.size(), st.rooms + 2 - 0, "the hall, the rooms, the shop and the boss")
	var kinds := {}
	for r in m.nodes:
		kinds[r.kind] = true
	assert_true(kinds.has(RunMap.Kind.MINIBOSS) and kinds.has(RunMap.Kind.SHOP) and kinds.has(RunMap.Kind.BOSS))


# ---------- the run ----------

func test_switch_off_the_passage_does_nothing_and_the_run_is_chapter_i() -> void:
	_start()
	var st := game.rooms.stage
	var map := game.rooms.map
	assert_eq(st.resource_path, Rooms.STAGE)
	assert_false(game.rooms.enter_region(1))
	assert_eq(game.rooms.stage, st)
	assert_eq(game.rooms.map, map)
	assert_eq(game.rooms.regions.index, 0)


func test_the_passage_keeps_the_run_and_is_idempotent() -> void:
	Dev.put("chapter2")
	_start()
	game.rooms.gold = 133
	game.rooms.won.assign([RunMap.Kind.COMBAT, RunMap.Kind.MINIBOSS])
	game.player.hp = 31.0
	var boon_count := game.boons.owned().size()
	var seed_before := game.rooms.map.map_seed
	assert_true(game.rooms.enter_region(1))
	assert_eq(game.rooms.stage.resource_path, Regions.path(1))
	assert_eq(game.rooms.regions.index, 1)
	assert_ne(game.rooms.map.map_seed, seed_before, "a graph of its own")
	assert_eq(game.rooms.gold, 133, "the gold crosses")
	assert_eq(game.rooms.won.size(), 2, "the tally crosses")
	assert_eq(game.boons.owned().size(), boon_count, "the Blessings cross")
	assert_eq(game.player.hp, 31.0, "the life crosses")
	for id in SLICE:
		assert_true(game.rooms._defs.has(id), "%s is ready to rise" % id)
	var map := game.rooms.map
	assert_false(game.rooms.enter_region(1), "a second call does nothing")
	assert_eq(game.rooms.map, map, "no second graph")
	assert_eq(game.rooms.regions.passages, 1)


func test_the_same_seed_draws_the_same_bosque_graph() -> void:
	Dev.put("chapter2")
	_start()
	game.rooms.enter_region(1)
	var a := game.rooms.map.map_seed
	game.queue_free()
	await get_tree().process_frame
	_start()
	game.rooms.enter_region(1)
	assert_eq(game.rooms.map.map_seed, a)


func test_a_run_can_start_in_the_bosque_by_the_dev_switch() -> void:
	Dev.put("chapter2")
	Dev.put("region", "1")
	_start()
	assert_eq(game.rooms.regions.index, 1)
	assert_eq(game.rooms.stage.resource_path, Regions.path(1))
	Dev.drop("chapter2")
	Dev.drop("region")
	_start()
	assert_eq(game.rooms.regions.index, 0, "off: the region is ignored")


# ---------- the log and the old files ----------

func test_the_log_records_the_region_and_an_old_line_reads_as_the_catacombs() -> void:
	Dev.put("chapter2")
	_start()
	var heard: Array = []
	game.run_logged.connect(func(_o: String, e: Dictionary) -> void: heard.append(e))
	game.rooms.enter_region(1)
	game.log_run("quit")
	assert_eq(int(heard[0].region), 1)
	assert_eq(int(heard[0].passages), 1)
	var old := RunLog.normalized({"version": 9, "outcome": "death"})
	assert_eq(int(old.region), 0)
	assert_eq(int(old.passages), 0)


func test_an_old_save_opens_with_the_switch_off_and_keeps_what_it_had() -> void:
	var old := SaveData.defaults()
	old.version = 19
	old.options.erase("chapter2")
	old.wins = 3
	var back := SaveData.merged(old)
	assert_false(bool(back.options.chapter2))
	assert_eq(back.wins, 3)
	assert_false(Regions.enabled(back.options.chapter2))
	var on := SaveData.merged({"options": {"chapter2": true}})
	assert_true(bool(on.options.chapter2), "the option survives the round")
