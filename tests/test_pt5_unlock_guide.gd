extends GutTest
## PT-5: the Santuário's unlock guide (HubGuide, HubGuideOverlay, Hub): what is due, once per save, the queue, skipping,
## the old saves, the robot and the nosave runs seeing nothing.

var hub: Hub
var _hub_open := ""


func before_each() -> void:
	_hub_open = Dev.arg("hub-open")
	Controls.virtual = null
	Controls.clear_presses()


func after_each() -> void:
	Dev.put("hub-open", _hub_open)
	for k in ["guide", "bot", "smoke", "nosave"]:
		Dev.drop(k)
	Save.data = SaveData.defaults()
	Controls.clear_presses()


func _ids(list: Array[HubGuideDef]) -> Array:
	return list.map(func(d: HubGuideDef) -> StringName: return d.id)


func test_data_is_complete_and_valid() -> void:
	var cat := HubGuide.catalog()
	assert_gt(cat.size(), 5)
	for d in cat:
		assert_true(HubPlan.STATIONS.has(d.station), "%s station" % d.id)
		assert_true(HubGuide.CONDITIONS.has(d.condition), "%s condition" % d.id)
		assert_true(T.table.entries.has(String(d.text_key)), "%s text" % d.id)
		assert_false((T.t(d.text_key) as String).contains("—"), "%s: no dash" % d.id)
	assert_true(T.table.entries.has("guide_continue"))


func test_new_save_is_only_told_about_the_portal() -> void:
	assert_eq(_ids(HubGuide.pending(SaveData.defaults())), [&"portal"])


func test_a_station_that_opens_brings_its_guide_once() -> void:
	var d := SaveData.defaults()
	HubGuide.mark_shown(d, [&"portal"])
	assert_true(HubGuide.pending(d).is_empty())
	d.runs = 1
	assert_eq(_ids(HubGuide.pending(d)), [&"tree", &"book"], "in the data's order")
	HubGuide.mark_shown(d, [&"tree", &"book"])
	assert_true(HubGuide.pending(d).is_empty(), "shown: never again")


func test_wins_and_the_account_open_theirs() -> void:
	var d := SaveData.defaults()
	d.wins = 1
	assert_true(_ids(HubGuide.pending(d)).has(&"sworn"))
	SaveData.hero(d, SaveData.FIRST_HERO).firsts = {"guardian": 1}
	var ids := _ids(HubGuide.pending(d))
	assert_true(ids.has(&"forge") and ids.has(&"account"))


func test_the_save_keeps_what_was_shown() -> void:
	var d := SaveData.defaults()
	HubGuide.mark_shown(d, [&"portal", &"tree"])
	var back := SaveData.merged(JSON.parse_string(JSON.stringify(d)))
	assert_eq(HubGuide.shown(back), ["portal", "tree"])


func test_an_old_save_counts_what_is_due_as_shown() -> void:
	var d := SaveData.defaults()
	d.runs = 5
	d.version = 10
	d.hub = {"presented": []}
	var back := SaveData.merged(JSON.parse_string(JSON.stringify(d)))
	assert_true(HubGuide.pending(back).is_empty())
	assert_eq(int(back.version), SaveData.VERSION)


func test_the_robot_and_nosave_see_nothing() -> void:
	Dev.put("hub-open", "")
	assert_true(HubGuide.enabled())
	Dev.put("bot")
	assert_false(HubGuide.enabled())
	Dev.drop("bot")
	Dev.put("nosave")
	assert_false(HubGuide.enabled())
	assert_true(HubGuide.to_show(SaveData.defaults()).is_empty())
	Dev.put("guide", "forge")
	assert_true(HubGuide.enabled(), "--guide forces it")
	assert_eq(_ids(HubGuide.to_show(SaveData.defaults())), [&"forge"])


func test_overlay_queue_skips_and_ends() -> void:
	var defs: Array[HubGuideDef] = [HubGuide.catalog()[1], HubGuide.catalog()[2]]
	var g := HubGuideOverlay.new().setup(defs)
	add_child_autofree(g)
	assert_eq(g.current.id, defs[0].id)
	assert_true(g.text.text.contains(UiKit.action_label(&"interact")), "the real key in the sentence")
	assert_false(g.text.text.contains("{key}"))
	var finished := [false]
	g.done.connect(func() -> void: finished[0] = true)
	# the press that brought him here does not skip
	var ev := InputEventKey.new()
	ev.keycode = KEY_SPACE
	ev.pressed = true
	g._input(ev)
	assert_eq(g.current.id, defs[0].id)
	g._process(HubGuideOverlay.GRACE + 0.1)
	g._input(ev)
	assert_eq(g.current.id, defs[1].id, "any key moves to the next")
	g._process(HubGuideOverlay.GRACE + 0.1)
	var click := InputEventMouseButton.new()
	click.pressed = true
	click.button_index = MOUSE_BUTTON_LEFT
	g._input(click)
	assert_null(g.current)
	assert_true(finished[0])


func test_hub_shows_the_guide_writes_it_and_holds_the_hero() -> void:
	Dev.put("hub-open", "")
	Dev.drop("hero-at")
	Save.data = SaveData.defaults()
	Save.data.runs = 1
	HubGuide.mark_shown(Save.data, [&"portal"])
	hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	assert_eq(_ids(hub._guide_wait), [&"tree", &"book"])
	hub._guide_tick(0.1)
	assert_null(hub.guide, "waits for the arrival look")
	hub.arrived = 10.0
	hub._guide_tick(0.1)
	assert_not_null(hub.guide)
	assert_eq(hub.guide.current.id, &"tree")
	assert_eq(HubGuide.shown(Save.data), ["portal", "tree", "book"], "written when it starts")
	var at := hub.lean()
	assert_eq(at, HubPlan.to_world(Vector2(HubPlan.SHOW[HubPlan.TREE].x, HubPlan.SHOW[HubPlan.TREE].y)), "leans on the station")
	var g := hub.guide
	g.advance()
	assert_eq(g.current.id, &"book")
	g.advance()
	assert_null(g.current)
	assert_null(hub.guide, "gone after the last")
	assert_eq(hub._guide_wait.size(), 0)
	# a second visit: nothing pending
	assert_true(HubGuide.pending(Save.data).is_empty())
