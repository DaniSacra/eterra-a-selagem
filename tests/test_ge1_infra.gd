extends GutTest
## GE-1 of the heroes redesign: TalentDef.needs and the fixed ultimate of a weapon.


func _t(id: StringName, needs: StringName = &"") -> TalentDef:
	var t := TalentDef.new()
	t.id = id
	t.needs = needs
	t.branch = TalentDef.Branch.IMPETO
	t.tier = TalentDef.Tier.APEX
	return t


func test_needs_replaces_the_tier_rule() -> void:
	var entry := _t(&"a")
	entry.tier = TalentDef.Tier.ENTRY
	var apex := _t(&"b", &"a")
	assert_false(Talents.needs_met(apex, [] as Array[TalentDef]))
	assert_false(Talents.needs_met(apex, [_t(&"z")] as Array[TalentDef]))
	assert_true(Talents.needs_met(apex, [entry] as Array[TalentDef]))
	assert_true(Talents.needs_met(entry, [] as Array[TalentDef]), "no needs: free")


func test_a_gift_naming_nothing_is_free_whatever_its_tier() -> void:
	var middle := TalentDef.new()
	middle.tier = TalentDef.Tier.MIDDLE
	middle.branch = TalentDef.Branch.COMBO
	assert_true(Talents.needs_met(middle, [] as Array[TalentDef]), "the place in the tree no longer decides (04_PLANO A.1)")


func test_the_fixed_ultimate_of_each_weapon() -> void:
	var w := HeroDef.warrior()
	assert_eq(w.weapon, &"emeth")
	assert_null(w.ult_for_weapon(2))
	assert_eq(w.ult_for_weapon(3).id, &"cleave")
	assert_eq(w.ult_for_weapon(20).id, &"cleave", "the Voragem is in reserve, never chosen")
	assert_true(w.ultimate(&"vortex").reserve, "kept in the data and found by id")
	var m := HeroDef.maga()
	assert_eq(m.weapon, &"bastao")
	assert_null(m.ult_for_weapon(1))
	assert_eq(m.ult_for_weapon(2).weapon, &"bastao")
	assert_false(m.ult_for_weapon(20).reserve)
