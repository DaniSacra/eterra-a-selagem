extends GutTest
## VendorOffer: the Vendedor's trades, Obras and Discernimento grades asked through one door (the rules stay in Vendor and Discern).


func _open_data() -> Dictionary:
	var d := SaveData.defaults()
	Oficios.block(d).orders[String(OficiosDef.live().order)] = "done"
	return d


func test_all_lists_trades_then_obras_then_the_two_grades() -> void:
	var def := OficiosDef.live()
	var all := VendorOffer.all(def, Vendor.load_catalog())
	assert_eq(all.size(), def.trades.size() + Vendor.load_catalog().size() + 2)
	assert_true(all[0].is_trade())
	assert_eq(all[-1].id(), &"discern_2")


func test_the_closed_stall_locks_trades_and_obras_but_not_the_grades() -> void:
	var def := OficiosDef.live()
	var d := SaveData.defaults()
	assert_eq(VendorOffer.trade_at(0).state(d, def), VendorOffer.State.LOCKED)
	assert_eq(VendorOffer.of_obra(Vendor.load_catalog()[0]).state(d, def), VendorOffer.State.LOCKED)


func test_trade_states_and_the_cap() -> void:
	var def := OficiosDef.live()
	var d := _open_data()
	var t := VendorOffer.trade_at(0)
	assert_eq(t.state(d, def), VendorOffer.State.SHORT)
	assert_eq(t.missing(d, def), {MaterialPurse.SILVER: 5})
	MaterialPurse.give(d, MaterialPurse.SILVER, 5)
	assert_eq(t.state(d, def), VendorOffer.State.CAN)
	MaterialPurse.give(d, MaterialPurse.MEMORY, int(MaterialPurse.CAP[MaterialPurse.MEMORY]))
	assert_eq(t.state(d, def), VendorOffer.State.FULL)


func test_commit_uses_the_rules_that_already_exist() -> void:
	var def := OficiosDef.live()
	var d := _open_data()
	MaterialPurse.give(d, MaterialPurse.SILVER, 50)
	assert_true(VendorOffer.trade_at(0).commit(d, def))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 45)
	assert_eq(MaterialPurse.amount(d, MaterialPurse.MEMORY), 1)
	assert_false(VendorOffer.of_discern(1).commit(d, def), "1 Memória is short of the grade")


func test_the_tilt_grows_with_what_is_given_and_stays_in_range() -> void:
	var def := OficiosDef.live()
	assert_almost_eq(VendorOffer.trade_at(0).tilt(def), 6.0, 0.01)
	for o in VendorOffer.all(def, Vendor.load_catalog()):
		assert_between(o.tilt(def), VendorOffer.TILT_MIN, VendorOffer.TILT_MAX)


func test_the_reading_of_a_trade_has_its_numbers_and_the_numbers_go_bold() -> void:
	var def := OficiosDef.live()
	var s := VendorOffer.trade_at(0).effect(def)
	assert_string_contains(s, "5 Prata")
	assert_string_contains(s, "1 Memória")
	assert_string_contains(VendorPlate.bold_numbers(s), "[b]5[/b]")
