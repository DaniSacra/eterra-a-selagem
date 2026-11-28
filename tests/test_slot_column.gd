extends GutTest
## PT28-6 option A: the left column of five places, the level badge rule, passives out, the Tab panel's pins.


func _boon(id: StringName, slot: Boon.Slot, f: Boon.Family = Boon.Family.CHAMA, max_level := 3) -> Boon:
	var b := Boon.new()
	b.id = id
	b.slot = slot
	b.family = f
	b.max_level = max_level
	return b


func _state() -> BoonState:
	var atk := _boon(&"atk", Boon.Slot.ATTACK)
	var dash := _boon(&"dash", Boon.Slot.DASH)
	var pas := _boon(&"pas", Boon.Slot.NONE, Boon.Family.GEADA)
	var second := _boon(&"second", Boon.Slot.ATTACK)
	var s := BoonState.new([atk, dash, pas, second] as Array[Boon])
	s.take(atk)
	s.take(dash)
	s.take(pas)
	return s


func test_five_places_in_order() -> void:
	assert_eq(SlotColumn.SLOTS, [Boon.Slot.ATTACK, Boon.Slot.CAST, Boon.Slot.SPECIAL, Boon.Slot.DASH, Boon.Slot.ULT])


func test_slot_mapping_keeps_fixed_places_with_nulls() -> void:
	var placed := SlotColumn.slot_boons(_state())
	assert_eq(placed.size(), 5)
	assert_eq(placed[0].id, &"atk")
	assert_null(placed[1])
	assert_null(placed[2])
	assert_eq(placed[3].id, &"dash")
	assert_null(placed[4])


func test_passives_are_not_in_the_column() -> void:
	var rest := SlotColumn.others(_state())
	assert_eq(rest.size(), 1)
	assert_eq(rest[0].id, &"pas")


func test_level_badge_rule() -> void:
	assert_eq(SlotColumn.level_badge(1, 3), "")
	assert_eq(SlotColumn.level_badge(0, 3), "")
	assert_eq(SlotColumn.level_badge(2, 3), "Nv 2")
	assert_eq(SlotColumn.level_badge(3, 3), "Máx")
	assert_eq(SlotColumn.level_badge(1, 1), "", "a Blessing that does not grow shows nothing")


func test_live_state_needs_a_running_recharge() -> void:
	assert_false(SlotColumn.is_live(Vector2.ZERO))
	assert_false(SlotColumn.is_live(Vector2(0.0, 5.0)))
	assert_true(SlotColumn.is_live(Vector2(2.0, 5.0)))


func test_column_shows_badge_and_empty_outline() -> void:
	var col := SlotColumn.new().setup()
	add_child_autofree(col)
	var s := _state()
	s.take(s.find(&"atk"))  # a second take raises the level
	col.show_build(s)
	assert_eq(col.cells.size(), 5)
	assert_null(col.cells[1].boon, "an empty place stays")
	assert_eq(col.cells[1].badge_label.text, "")
	assert_true(col.has_content())


func test_pins_toggle_and_cap_at_three() -> void:
	var p: Array[StringName] = []
	for id in [&"a", &"b", &"c", &"d"]:
		p = BlessingTab.toggle_pin(p, id)
	assert_eq(p, [&"a", &"b", &"c"] as Array[StringName])
	p = BlessingTab.toggle_pin(p, &"b")
	assert_eq(p, [&"a", &"c"] as Array[StringName])


func test_tab_cards_are_the_pinned_then_the_hovered() -> void:
	var tab := BlessingTab.new().setup()
	add_child_autofree(tab)
	var s := _state()
	tab.show_build(s)
	tab.set_open(true)
	tab.pin(s.find(&"pas"))
	tab.inspect(s.find(&"atk"))
	assert_eq(tab.card_ids(), [&"pas", &"atk"] as Array[StringName])
	tab.set_open(false)
	assert_eq(tab.card_ids(), [] as Array[StringName])
