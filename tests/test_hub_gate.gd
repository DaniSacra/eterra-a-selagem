extends GutTest
## The Santuário opens by stages (HubGate): each gate, the old saves, the opening said once.


func _fresh() -> Dictionary:
	return SaveData.defaults()


func _open(d: Dictionary, id: StringName) -> bool:
	return HubGate.is_open(d, id)


func test_new_save_has_only_the_portal() -> void:
	var d := _fresh()
	assert_eq(HubGate.open_ids(d), [HubPlan.PORTAL] as Array[StringName])
	assert_true(HubGate.to_present(d).is_empty())


func test_tree_opens_after_the_first_descent_and_the_book_waits() -> void:
	var d := _fresh()
	d.runs = 1
	assert_true(_open(d, HubPlan.TREE))
	assert_false(_open(d, HubPlan.BOOK), "SW-O5: the Livro is the third descent's")
	assert_false(_open(d, HubPlan.SMITH))
	assert_false(_open(d, HubPlan.VENDOR))
	d.runs = 0
	d.first = 2
	assert_true(_open(d, HubPlan.TREE), "a skipped first descent counts")


func test_forge_opens_on_first_guardian_or_the_third_descent() -> void:
	var d := _fresh()
	d.runs = 2
	assert_false(_open(d, HubPlan.SMITH))
	MaterialPurse.give(d, MaterialPurse.SILVER, HubGate.temper_cost())
	assert_false(_open(d, HubPlan.SMITH), "silver alone no longer opens it (the first descent gives some)")
	var g := _fresh()
	g.runs = 1
	SaveData.hero(g, SaveData.FIRST_HERO).firsts = {"guardian": 1}
	HubGate.mark_presented(g, [HubPlan.TREE])
	assert_true(_open(g, HubPlan.SMITH), "first guardian outside the first descent")
	var t := _fresh()
	t.runs = 3
	HubGate.mark_presented(t, [HubPlan.TREE])
	assert_true(_open(t, HubPlan.SMITH), "third descent")


func test_forge_counts_a_used_one() -> void:
	var d := _fresh()
	SaveData.hero(d, SaveData.FIRST_HERO).forge.temper = 1
	assert_true(_open(d, HubPlan.SMITH))


func test_vendor_opens_on_the_fifth_descent_or_first_stone() -> void:
	var d := _fresh()
	d.runs = 4
	HubGate.mark_presented(d, [HubPlan.TREE, HubPlan.BOOK, HubPlan.SMITH, HubPlan.VINE])
	assert_false(_open(d, HubPlan.VENDOR))
	d.runs = 5
	assert_true(_open(d, HubPlan.VENDOR))
	var s := _fresh()
	Oficios.block(s).items_total[String(OficiosDef.live().stone)] = 1
	assert_true(_open(s, HubPlan.VENDOR), "first Pedra Funda")
	var o := _fresh()
	Oficios.block(o).orders["vendor_stone"] = "open"
	assert_true(_open(o, HubPlan.VENDOR), "an order was taken")


func test_gifts_opened_keep_tree_and_book_open() -> void:
	var d := _fresh()
	SaveData.hero(d, SaveData.FIRST_HERO).opened = ["x"]
	assert_true(_open(d, HubPlan.TREE) and _open(d, HubPlan.BOOK))


func test_all_flag_opens_everything() -> void:
	assert_eq(HubGate.open_ids(_fresh(), true).size(), HubPlan.STATIONS.size())


func test_presentation_is_one_per_visit_and_said_once() -> void:
	var d := _fresh()
	d.runs = 3
	assert_eq(HubGate.to_present(d), [HubPlan.TREE] as Array[StringName])
	HubGate.begin_visit(d)
	HubGate.mark_presented(d, HubGate.to_present(d))
	assert_true(HubGate.to_present(d).is_empty(), "the visit's one thing is said")
	assert_false(_open(d, HubPlan.SMITH), "the second waits for the next return")
	assert_false(_open(d, HubPlan.BOOK))
	HubGate.end_visit()
	HubGate.begin_visit(d)
	assert_eq(HubGate.to_present(d), [HubPlan.SMITH] as Array[StringName], "the next return: the Forja")
	assert_true(_open(d, HubPlan.SMITH))
	assert_false(_open(d, HubPlan.BOOK))
	HubGate.end_visit()
	for id: StringName in HubGate.TEXT:
		if id == Milestones.ULT and not T.table.entries.has("hub_open_ult"):
			pending("hub_open_ult comes with the 3A3 texts")
			continue
		assert_ne(T.t(HubGate.TEXT[id]), String(HubGate.TEXT[id]), "text of %s" % id)


func test_what_was_shown_or_used_never_closes() -> void:
	var d := _fresh()
	d.runs = 3
	HubGate.mark_presented(d, [HubPlan.VENDOR, HubPlan.HEROES])
	assert_true(_open(d, HubPlan.VENDOR), "a Vendedor shown under the old rule (third return) stays")
	assert_true(_open(d, HubPlan.HEROES))
	var f := _fresh()
	SaveData.hero(f, SaveData.FIRST_HERO).forge.temper = 1
	assert_true(_open(f, HubPlan.SMITH), "a bought Temperar keeps the Forja")
	var v := _fresh()
	v.vine.bought = ["vida_1"]
	assert_true(_open(v, HubPlan.VINE), "a Videira node keeps her")


func test_old_save_counts_open_stations_as_shown() -> void:
	var old := SaveData.merged({"version": 8, "runs": 5, "wins": 0})
	assert_true(HubGate.to_present(old).is_empty(), "no announcement for what the save already had")
	assert_eq(old.version, SaveData.VERSION)
	assert_true(HubGate.presented(old).has("tree"))
	assert_true(HubGate.presented(old).has("vendor"))
	assert_true(HubGate.presented(old).has("smith"), "runs 5 reaches the Forja's third descent")
	# a new version-9 file keeps what it was shown
	var kept := SaveData.merged({"version": 9, "runs": 3, "hub": {"presented": ["tree"]}})
	assert_eq(HubGate.to_present(kept), [HubPlan.SMITH] as Array[StringName], "one at a time, in the milestones' order")


func test_hub_scene_closes_stations() -> void:
	Dev.drop("hub-open")
	Save.data = SaveData.defaults()
	var hub: Hub = load("res://scenes/hub.tscn").instantiate()
	add_child_autofree(hub)
	await wait_process_frames(2)
	assert_false(hub.focus.points.has(HubPlan.SMITH))
	assert_true(hub.focus.points.has(HubPlan.PORTAL))
	hub.use(HubPlan.SMITH)
	assert_false(hub.host.is_open(), "a closed station is not used")
	hub.host.close()
	Dev.put("hub-open", "all")
	Save.data = SaveData.defaults()
