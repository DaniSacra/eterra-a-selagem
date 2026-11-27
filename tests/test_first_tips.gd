extends GutTest
## GP-9 and 10B-2: the four first-descent tips (FirstTips, TipToast): what is due, once per save, new saves only, the
## robot and --nosave seeing none, the keys read from the bindings, no dash in the texts.

func after_each() -> void:
	for k in ["bot", "smoke", "nosave", "tips"]:
		Dev.drop(k)


func _data(runs := 0) -> Dictionary:
	var d := SaveData.defaults()
	d["runs"] = runs
	return d


func _ctx(over := {}) -> Dictionary:
	var c := {"fighting": true, "fight_t": 0.0, "poised": false, "boons": 0, "elos": 0}
	c.merge(over, true)
	return c


func test_nothing_before_the_fight_has_run_a_moment() -> void:
	assert_eq(FirstTips.pick(_data(), _ctx()), &"")


func test_fight_then_hold_then_poise_then_elo() -> void:
	var d := _data()
	assert_eq(FirstTips.pick(d, _ctx({"fight_t": 2.0})), &"fight")
	assert_eq(FirstTips.pick(d, _ctx({"fight_t": 3.0})), &"fight", "until it is marked")
	FirstTips.mark(d, &"fight")
	assert_eq(FirstTips.pick(d, _ctx({"fight_t": 3.0})), &"")
	assert_eq(FirstTips.pick(d, _ctx({"fight_t": FirstTips.HOLD_AFTER})), &"hold")
	FirstTips.mark(d, &"hold")
	assert_eq(FirstTips.pick(d, _ctx({"poised": true})), &"poise")
	FirstTips.mark(d, &"poise")
	assert_eq(FirstTips.pick(d, _ctx({"fighting": false, "boons": 2})), &"elo")
	assert_eq(FirstTips.pick(d, _ctx({"fighting": false, "boons": 1})), &"")
	assert_eq(FirstTips.pick(d, _ctx({"fighting": false, "boons": 3, "elos": 1})), &"")
	FirstTips.mark(d, &"elo")
	assert_eq(FirstTips.pick(d, _ctx({"fighting": false, "boons": 2})), &"")


func test_once_per_save_and_it_survives_a_merge() -> void:
	var d := _data()
	FirstTips.mark(d, &"fight")
	FirstTips.mark(d, &"fight")
	assert_eq(FirstTips.shown(d), ["fight"])
	var again := SaveData.merged(JSON.parse_string(JSON.stringify(d)))
	assert_false(FirstTips.open(again, &"fight"))
	assert_true(FirstTips.open(again, &"hold"))


func test_old_saves_have_no_tips() -> void:
	assert_eq(FirstTips.pick(_data(FirstTips.FIRST_RUNS), _ctx({"fight_t": 5.0})), &"")
	var legacy := SaveData.merged({"version": 12, "runs": 0, "hub": {"presented": [], "guided": []}})
	assert_true(FirstTips.open(legacy, &"fight"), "a save without the list gets it")


func test_robot_smoke_and_nosave_see_none() -> void:
	for k in ["bot", "smoke", "nosave"]:
		Dev.put(k, "1")
		assert_false(FirstTips.enabled(), k)
		Dev.drop(k)
	Dev.put("tips", "1")
	Dev.put("bot", "1")
	assert_true(FirstTips.enabled(), "--tips forces them")


func test_texts_say_the_bound_keys_and_have_no_dash() -> void:
	for id in FirstTips.IDS:
		var s := TipToast.text_of(id)
		assert_false(s.begins_with("tip_"), "%s has text" % id)
		assert_false(s.contains("{"), "%s has no open placeholder" % id)
		assert_false(s.contains("—") or s.contains("–"), "%s: no dash" % id)
	assert_true(TipToast.text_of(&"fight").contains(UiKit.action_label(&"light_attack")))
	assert_true(TipToast.text_of(&"fight").contains(UiKit.action_label(&"dodge")))
