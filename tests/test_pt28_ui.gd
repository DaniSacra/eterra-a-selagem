extends GutTest
## PT28-5, 6, 8, 9: fixed Blessing cards, the Tab panel grouped by angel, the slot that fills from the bottom, no armour bar.


func _boon(id: StringName, f: Boon.Family) -> Boon:
	var b := Boon.new()
	b.id = id
	b.family = f
	return b


func test_blessings_group_by_angel_in_family_order() -> void:
	var list: Array[Boon] = [_boon(&"a", Boon.Family.GEADA), _boon(&"b", Boon.Family.CHAMA), _boon(&"c", Boon.Family.GEADA)]
	var g := BlessingGroups.group(list)
	assert_eq(g.keys(), [Boon.Family.CHAMA, Boon.Family.GEADA])
	assert_eq((g[Boon.Family.GEADA] as Array).size(), 2)


func test_panel_builds_a_block_per_angel() -> void:
	var p := BlessingGroups.new().setup()
	add_child_autofree(p)
	var list: Array[Boon] = [_boon(&"a", Boon.Family.GEADA), _boon(&"b", Boon.Family.CHAMA)]
	p.show_boons(list)
	assert_true(p.has_content())
	assert_false(p.visible, "hidden until Tab is held")


func test_show_blessings_action_is_bound_to_tab_and_a_pad_button() -> void:
	assert_true(InputMap.has_action(&"show_blessings"))
	var keys := InputMap.action_get_events(&"show_blessings")
	assert_true(keys.any(func(e: InputEvent) -> bool: return e is InputEventKey and (e as InputEventKey).physical_keycode == KEY_TAB))
	assert_true(keys.any(func(e: InputEvent) -> bool: return e is InputEventJoypadButton))


func test_fill_share_is_grey_when_starved_and_rises_as_the_wait_ends() -> void:
	assert_almost_eq(ActionSlot.fill_share(1.0, false), 0.0, 0.001)
	assert_almost_eq(ActionSlot.fill_share(0.25, false), 0.75, 0.001)
	assert_almost_eq(ActionSlot.fill_share(0.0, false), 1.0, 0.001)
	assert_almost_eq(ActionSlot.fill_share(0.0, true), 0.0, 0.001)


func test_slot_gets_the_fill_material_only_while_unavailable() -> void:
	var s := ActionSlot.new().setup(&"light_attack", Boon.Slot.ATTACK)
	add_child_autofree(s)
	s.refresh(null, 0.5)
	assert_true(s.material is ShaderMaterial)
	s.refresh(null, 0.0)
	assert_null(s.material)
	s.refresh(null, 0.0, 0, 0, true)
	assert_true(s.material is ShaderMaterial, "a cost not affordable is grey")


func test_tall_card_keeps_its_size_whatever_the_text() -> void:
	var b := Boon.new()
	b.id = &"x"
	var short := BoonCard.new()
	var long_ := BoonCard.new()
	add_child_autofree(short)
	add_child_autofree(long_)
	short.setup(b, Boon.Rarity.COMMON, 0, [], null, "Curto.")
	long_.setup(b, Boon.Rarity.COMMON, 0, [], null, "Texto muito longo. ".repeat(40))
	await wait_process_frames(4)
	assert_eq(short.custom_minimum_size, long_.custom_minimum_size)
	assert_eq(short.custom_minimum_size.y, BoonCard.SIZE.y)
