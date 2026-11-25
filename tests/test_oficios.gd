extends GutTest
## Ofícios, Roteiro A (docs/design/oficios/15_prototipo.md): OF-05 and the pick's journey, pure.

var def: OficiosDef


func before_each() -> void:
	def = OficiosDef.live()


func _stage() -> StageDef:
	return load("res://data/stages/catacombs.tres")


## OF-05: in 1000 graphs no door of Prata before depth 4 and none of Memória on or before the guardian's layer.
func test_of05_material_doors_come_deep() -> void:
	var st := _stage()
	assert_eq(st.silver_from_depth, 4)
	assert_true(st.memory_after_guardian)
	var silver := 0
	var memory := 0
	var bad: Array[String] = []
	for seed in 1000:
		var m := RunMap.new(st, seed)
		for r in m.nodes:
			if r.reward == RunMap.Reward.SILVER:
				silver += 1
				if r.depth < 4:
					bad.append("silver at %d, seed %d" % [r.depth, seed])
			elif r.reward == RunMap.Reward.MEMORY:
				memory += 1
				if r.depth <= m.miniboss_depth:
					bad.append("memory at %d, guardian %d, seed %d" % [r.depth, m.miniboss_depth, seed])
	assert_eq(bad, [] as Array[String])
	assert_gt(silver, 300, "the Prata door still comes")
	assert_gt(memory, 200, "the Memória door still comes")


## P1: marking the finds leaves the graph as it was (kinds, rewards, arenas, links) on 200 seeds.
func test_finds_leave_the_map_as_it_was() -> void:
	var st := _stage()
	var changed := 0
	var marked := 0
	for seed in 200:
		var a := RunMap.new(st, seed)
		var b := RunMap.new(st, seed)
		if b.mark_finds(def.head, def.find_depth_min, def.find_depth_max, def.vein_arenas):
			marked += 1
		if JSON.stringify(a.summary()) != JSON.stringify(_without_find(b.summary())):
			changed += 1
	assert_eq(changed, 0)
	assert_eq(marked, 200, "a room for the head on every map")


func _without_find(sum: Dictionary) -> Dictionary:
	for w: Array in sum.nodes:
		w.erase("find")
	return sum


## The head's room: one fight room between depths 4 and 8, never a Provação's; veins only past the guardian, in the
## Fendas and the Runas.
func test_mark_finds_rules() -> void:
	var st := _stage()
	var bad: Array[String] = []
	var veins := 0
	for seed in 300:
		var m := RunMap.new(st, seed)
		m.mark_finds(def.head, def.find_depth_min, def.find_depth_max, def.vein_arenas)
		var finds := m.nodes.filter(func(r: RunMap.Room) -> bool: return r.find != &"")
		if finds.size() != 1:
			bad.append("seed %d: %d finds" % [seed, finds.size()])
		for r: RunMap.Room in finds:
			if r.kind != RunMap.Kind.COMBAT or r.trial or r.depth < def.find_depth_min or r.depth > def.find_depth_max:
				bad.append("seed %d: find at %d" % [seed, r.depth])
		for r in m.nodes:
			if r.vein:
				veins += 1
				if r.depth <= m.miniboss_depth or not (r.arena in [&"rift", &"runes"]) or r.kind != RunMap.Kind.COMBAT:
					bad.append("seed %d: vein at %d in %s" % [seed, r.depth, r.arena])
	assert_eq(bad, [] as Array[String])
	assert_gt(veins, 300, "veins stand past the guardian")
	# nothing wanted: no head, the veins all the same
	var m2 := RunMap.new(st, 7)
	assert_false(m2.mark_finds(&"", 4, 8, def.vein_arenas))
	assert_eq(m2.nodes.filter(func(r: RunMap.Room) -> bool: return r.find != &"").size(), 0)


## The journey in the save: noted, head found (banked once), pity, restored for 20 Prata, stones capped at 10, the
## Vendedor's order delivered once into the angels' preview.
func test_the_whole_journey() -> void:
	var data := SaveData.defaults()
	assert_false(Oficios.head_wanted(data, def), "nothing asked before the vein")
	var run := OficiosRun.from_save(data, def)
	run.noted = true
	Oficios.bank(data, def, run)
	assert_true(Oficios.noted(data))
	assert_true(Oficios.head_wanted(data, def))
	# two descents past the guardian missing the room: the pity is due
	for i in 2:
		var miss := OficiosRun.from_save(data, def)
		miss.marked = true
		miss.passed_guardian = true
		Oficios.bank(data, def, miss)
	assert_true(Oficios.pity_due(data, def))
	var found := OficiosRun.from_save(data, def)
	assert_true(found.pity_due)
	found.head_found = true
	var went := Oficios.bank(data, def, found)
	assert_eq(went.finds, ["pick_head"])
	assert_true(Oficios.has_find(data, def.head))
	assert_false(Oficios.pity_due(data, def), "found: the pity is cleared")
	assert_eq(Oficios.bank(data, def, found).finds, [], "a find is banked once")
	assert_eq(Oficios.restore_problem(data, def), Oficios.SHORT)
	assert_false(Oficios.restore(data, def))
	MaterialPurse.give(data, MaterialPurse.SILVER, 25)
	assert_eq(Oficios.restore_problem(data, def), &"")
	assert_true(Oficios.restore(data, def))
	assert_eq(MaterialPurse.amount(data, MaterialPurse.SILVER), 5)
	assert_true(Oficios.has_tool(data, def))
	assert_false(Oficios.has_find(data, def.head), "the head went into the pick")
	assert_false(Oficios.restore(data, def), "restored once")
	assert_true(OficiosRun.from_save(data, def).has_pick)
	assert_eq(Oficios.order_state(data, def), Oficios.Order.LOCKED)
	var dig := OficiosRun.from_save(data, def)
	dig.stones = 12
	Oficios.bank(data, def, dig)
	assert_eq(Oficios.count(data, def.stone), 10, "the Pedra Funda's cap")
	assert_eq(Oficios.order_state(data, def), Oficios.Order.OPEN)
	assert_eq(Oficios.order_missing(data, def), {OficiosDef.SILVER: 25})
	assert_false(Oficios.deliver(data, def))
	MaterialPurse.give(data, MaterialPurse.SILVER, 25)
	assert_true(Oficios.deliver(data, def))
	assert_eq(Oficios.count(data, def.stone), 8)
	assert_eq(MaterialPurse.amount(data, MaterialPurse.SILVER), 0)
	assert_eq(Oficios.order_state(data, def), Oficios.Order.DONE)
	assert_true(Oficios.has_recipe(data, def.order_gives))
	assert_true(OficiosRun.from_save(data, def).preview)
	MaterialPurse.give(data, MaterialPurse.SILVER, 30)
	assert_false(Oficios.deliver(data, def), "an order is delivered once")
	assert_eq(MaterialPurse.amount(data, MaterialPurse.SILVER), 30)


## Save 8: the block round-trips through JSON, and saves 1 to 7 open whole as 8 with an empty block.
func test_save_8_keeps_the_block_and_opens_older_files() -> void:
	var data := SaveData.defaults()
	assert_eq(data.version, SaveData.VERSION)
	Oficios.block(data).seen.append("vein")
	Oficios.add_item(data, def, def.stone, 3)
	(Oficios.block(data).tools as Array).append("pick")
	Oficios.block(data).orders["vendor_stone"] = "done"
	var back := SaveData.merged(JSON.parse_string(JSON.stringify(data)))
	assert_eq(Oficios.count(back, def.stone), 3)
	assert_true(Oficios.noted(back))
	assert_true(Oficios.has_tool(back, def))
	assert_eq(Oficios.order_state(back, def), Oficios.Order.DONE)
	for v in range(1, 8):
		var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save_v%d.json" % v))
		assert_true(raw is Dictionary, "fixture %d" % v)
		var out := SaveData.merged(raw)
		assert_eq(out.version, SaveData.VERSION, "version %d opens as 8" % v)
		assert_eq(out.oficios, Oficios.defaults(), "version %d has the empty block" % v)
	var v7 := SaveData.merged(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save_v7.json")))
	assert_eq(MaterialPurse.amount(v7, MaterialPurse.SILVER), 42, "the Prata of a version 7 stays")
	assert_eq(v7.heroes.warrior.tools, ["tool_refine"])


## The log's version 6 reads an older line with an empty oficios.
func test_run_log_6() -> void:
	assert_eq(RunLog.VERSION, 9)  # (7: uses; 8: cause, oaths, per-room hazard; 9: SW-O onboarding; test_run_log.gd)
	var old := RunLog.normalized({"version": 5, "outcome": "death"})
	assert_eq(old.oficios, {})
	assert_eq(int(old.version), 5)
	var r := OficiosRun.new()
	r.head_found = true
	r.head_id = "pick_head"
	r.stones = 2
	var rep := r.report()
	assert_eq(rep.finds, ["pick_head"])
	assert_eq(rep.gather.stones, 2)
