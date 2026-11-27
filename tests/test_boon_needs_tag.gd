extends GutTest
## A Blessing that needs a move shape (finisher, spin) is not offered to a hero without it (2026-11-24: four were dead
## for the Maga), and the Warrior still gets them.


## (V1: every Blessing of the angels is universal and none asks a move shape; the filter stays in the engine for the data that
## may want it, so it is tested on made-up Blessings.)
func _state_for(combos: String) -> BoonState:
	var shapes: Array[Boon] = []
	for tag in [&"finisher", &"spin"]:
		var b := Boon.new()
		b.id = StringName("needs_%s" % tag)
		b.family = Boon.Family.CHAMA
		b.needs_tag = tag
		shapes.append(b)
	var s := BoonState.new(shapes)
	s.set_hero_moves(load(combos) as ComboTree)
	return s


## The one exception (2026-11-27): the Warrior's blows cost no Magia, so the Blessing that gives Magia back asks the Maga's `arcane` tag.
func test_no_blessing_of_the_angels_asks_a_move_shape_but_the_one_that_gives_magia() -> void:
	for b in BoonState.load_catalog():
		if not b.reserve:
			assert_eq(b.needs_tag, &"arcane" if b.id == &"essencia_restauradora" else &"", "%s" % b.id)


func test_the_magia_blessing_is_the_makas_alone() -> void:
	var warrior := BoonState.new(BoonState.load_catalog())
	warrior.set_hero_moves(load(HeroDef.warrior().combos) as ComboTree)
	var maga := BoonState.new(BoonState.load_catalog())
	maga.set_hero_moves(load(HeroDef.maga().combos) as ComboTree)
	assert_false(warrior.offerable(warrior.find(&"essencia_restauradora")))
	assert_true(maga.hero_tags.has(&"arcane"), "her moves carry the tag it asks")
	assert_false(warrior.hero_tags.has(&"arcane"))


func test_a_hero_without_the_shape_is_never_offered_the_blessing() -> void:
	var warrior := _state_for(HeroDef.warrior().combos)
	var maga := _state_for(HeroDef.maga().combos)
	var dead := 0
	for id in [&"needs_finisher", &"needs_spin"]:
		assert_true(warrior.offerable(warrior.find(id)), "%s offered to the Warrior" % id)
		if not maga.offerable(maga.find(id)):
			dead += 1
	assert_gt(dead, 0, "the Maga lacks at least one of the shapes")


func test_no_hero_tags_no_filter() -> void:
	var s := BoonState.new(BoonState.load_catalog())
	for b in s.catalog:
		if not b.reserve and b.slot == Boon.Slot.ATTACK:
			assert_true(s.offerable(b), String(b.id))
