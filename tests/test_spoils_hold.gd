extends GutTest
## PT-25-3: the Videira waters by holding (HoldPress); PT-25-6: the end screen's spoils (rooms won, what the descent opened).

var _saved: Dictionary
var _saving := true


func before_each() -> void:
	_saved = Save.data
	_saving = Save.enabled
	Save.enabled = false
	Save.data = SaveData.defaults()


func after_each() -> void:
	Save.data = _saved
	Save.enabled = _saving


func _screen(silver: int) -> VineScreen:
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, silver)
	var s := VineScreen.new()
	add_child_autofree(s)
	s.open(d)
	return s


func _mouse(pressed: bool) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = pressed
	return e


func test_a_short_press_waters_nothing() -> void:
	var s := _screen(30)
	assert_true(s.select(&"vida_1"))
	s.water_button.gui_input.emit(_mouse(true))
	assert_true(s.hold.holding())
	s.hold._process(0.3)
	s.water_button.gui_input.emit(_mouse(false))
	s.hold._process(1.0)
	assert_eq(s.vine.state(s._data, &"vida_1"), Vine.State.AVAILABLE, "let go before the ring filled")
	assert_eq(MaterialPurse.amount(s._data, MaterialPurse.SILVER), 30)


func test_holding_until_the_ring_fills_buys_once() -> void:
	var s := _screen(30)
	s.select(&"vida_1")
	var heard := []
	s.bought.connect(func(id: StringName) -> void: heard.append(id))
	s.water_button.gui_input.emit(_mouse(true))
	s.hold._process(HoldPress.TIME * 0.5)
	assert_gt(s.hold.progress(), 0.4)
	assert_eq(heard.size(), 0)
	s.hold._process(HoldPress.TIME)
	assert_eq(heard, [&"vida_1"])
	assert_eq(MaterialPurse.amount(s._data, MaterialPurse.SILVER), 25)
	s.hold._process(2.0)
	assert_eq(heard.size(), 1, "the ring stops after the purchase")


func test_holding_the_mouse_on_a_star_waters_it() -> void:
	var s := _screen(30)
	s.zoom_in(&"vida")
	var h: HoldPress = s.holds[&"vida_1"]
	var b: Button = s.buds[&"vida_1"]
	b.gui_input.emit(_mouse(true))
	assert_true(h.holding())
	h._process(HoldPress.TIME * 0.5)
	assert_eq(s.vine.state(s._data, &"vida_1"), Vine.State.AVAILABLE)
	h._process(HoldPress.TIME)
	assert_eq(s.vine.state(s._data, &"vida_1"), Vine.State.OWNED)


func test_holding_the_tag_fills_the_star_ring() -> void:
	var s := _screen(30)
	s.zoom_in(&"vida")
	(s.tags[&"vida_1"] as Button).gui_input.emit(_mouse(true))
	assert_true((s.holds[&"vida_1"] as HoldPress).holding())


func test_a_star_press_in_the_whole_sky_does_not_hold() -> void:
	var s := _screen(30)
	(s.buds[&"vida_1"] as Button).gui_input.emit(_mouse(true))
	assert_false((s.holds[&"vida_1"] as HoldPress).holding(), "from the sky a press opens the figure")


func test_a_disabled_button_does_not_hold() -> void:
	var s := _screen(0)
	s.water_button.gui_input.emit(_mouse(true))
	assert_false(s.hold.holding())


func test_opened_lists_only_the_new_milestones() -> void:
	var before: Array = [&"tree"]
	var after: Array = [&"tree", &"forge", &"account"]
	assert_eq(RunSpoils.opened(before, after), [&"forge", &"account"] as Array[StringName])
	assert_eq(RunSpoils.opened(after, after), [] as Array[StringName])
	assert_eq(T.t(RunSpoils.text_key(&"account")), "A Videira liberada")


func test_every_milestone_has_its_line() -> void:
	for d in Milestones.defaults():
		assert_ne(T.t(RunSpoils.text_key(d.id)), String(RunSpoils.text_key(d.id)), "text for %s" % d.id)


func test_end_screen_shows_rooms_and_what_opened_on_both_endings() -> void:
	for victory in [false, true]:
		var end := EndScreen.new()
		add_child_autofree(end)
		end.open(victory, {"time": 120.0, "level": 0, "kills": 9, "boons": 1, "rooms_won": 3, "gold": 40, "opened": [&"tree", &"account"]}, false)
		end.finish_sealing()
		assert_not_null(end.find_child("open_account", true, false), "the Videira line")
		assert_eq((end.find_child("open_account", true, false) as Label).text, "A Videira liberada")
		var texts := []
		for n in end.find_children("*", "Label", true, false):
			texts.append((n as Label).text)
		assert_true(texts.has("3"), "rooms won")
		assert_true(texts.has(T.t(&"end_rooms")))


func test_end_screen_without_openings_has_no_section() -> void:
	var end := EndScreen.new()
	add_child_autofree(end)
	end.open(false, {"time": 10.0, "level": 0, "kills": 1, "boons": 0, "opened": []}, false)
	assert_null(end.find_child("opened", true, false))
