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


func test_book_and_tree_open_after_the_first_descent() -> void:
	var d := _fresh()
	d.runs = 1
	assert_true(_open(d, HubPlan.BOOK) and _open(d, HubPlan.TREE))
	assert_false(_open(d, HubPlan.SMITH))
	assert_false(_open(d, HubPlan.VENDOR))


func test_forge_opens_on_first_guardian_or_enough_silver() -> void:
	var d := _fresh()
	d.runs = 1
	assert_false(_open(d, HubPlan.SMITH))
	MaterialPurse.give(d, MaterialPurse.SILVER, HubGate.temper_cost() - 1)
	assert_false(_open(d, HubPlan.SMITH), "one short")
	MaterialPurse.give(d, MaterialPurse.SILVER, 1)
	assert_true(_open(d, HubPlan.SMITH), "silver for the Temperar I")
	var g := _fresh()
	SaveData.hero(g, SaveData.FIRST_HERO).firsts = {"guardian": 1}
	assert_true(_open(g, HubPlan.SMITH), "first guardian")


func test_forge_counts_a_used_one() -> void:
	var d := _fresh()
	SaveData.hero(d, SaveData.FIRST_HERO).forge.temper = 1
	assert_true(_open(d, HubPlan.SMITH))


func test_vendor_opens_on_third_return_or_first_stone() -> void:
	var d := _fresh()
	d.runs = 2
	assert_false(_open(d, HubPlan.VENDOR))
	d.runs = 3
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


func test_presentation_is_said_once() -> void:
	var d := _fresh()
	d.runs = 1
	assert_eq(HubGate.to_present(d), [HubPlan.TREE, HubPlan.BOOK] as Array[StringName])
	HubGate.mark_presented(d, HubGate.to_present(d))
	assert_true(HubGate.to_present(d).is_empty())
	d.runs = 3
	assert_eq(HubGate.to_present(d), [HubPlan.VENDOR] as Array[StringName], "only the new one")
	for id: StringName in HubGate.TEXT:
		assert_ne(T.t(HubGate.TEXT[id]), String(HubGate.TEXT[id]), "text of %s" % id)


func test_old_save_counts_open_stations_as_shown() -> void:
	var old := SaveData.merged({"version": 8, "runs": 5, "wins": 0})
	assert_true(HubGate.to_present(old).is_empty(), "no announcement for what the save already had")
	assert_eq(old.version, SaveData.VERSION)
	assert_true(HubGate.presented(old).has("tree"))
	assert_true(HubGate.presented(old).has("vendor"))
	assert_false(HubGate.presented(old).has("smith") and not HubGate.is_open(old, HubPlan.SMITH))
	# a new version-9 file keeps what it was shown
	var kept := SaveData.merged({"version": 9, "runs": 1, "hub": {"presented": ["tree"]}})
	assert_eq(HubGate.to_present(kept), [HubPlan.BOOK] as Array[StringName])


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
