extends GutTest
## A Blessing that needs a move shape (finisher, spin) is not offered to a hero without it (2026-11-24: four were dead
## for the Maga), and the Warrior still gets them.


func _state_for(combos: String) -> BoonState:
	var s := BoonState.new(BoonState.load_catalog())
	s.set_hero_moves(load(combos) as ComboTree)
	return s


func test_maga_never_offered_dead_blessings() -> void:
	var s := _state_for(HeroDef.maga().combos)
	for id in [&"golpe_geada", &"final_radiante", &"final_veu", &"golpe_certeiro"]:
		var b := s.find(id)
		assert_not_null(b, String(id))
		assert_ne(b.needs_tag, &"", "%s has a needed tag" % id)
		assert_false(s.offerable(b), "%s is not offered to the Maga" % id)


func test_warrior_keeps_them() -> void:
	var s := _state_for(HeroDef.warrior().combos)
	for id in [&"final_radiante", &"golpe_certeiro"]:
		assert_true(s.offerable(s.find(id)), "%s still offered to the Warrior" % id)


func test_no_hero_tags_no_filter() -> void:
	var s := BoonState.new(BoonState.load_catalog())
	assert_true(s.offerable(s.find(&"final_radiante")))
