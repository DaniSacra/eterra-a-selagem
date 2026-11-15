extends GutTest
## Elo (the Eterra name of a gift forged from two others): its sources for the card, the greeting of a new one, its text.

var state: BoonState


func before_each() -> void:
	state = BoonState.new(BoonState.load_catalog())


func test_sources_of_an_elo_are_its_two_gifts_in_order() -> void:
	var src := state.sources(state.find(&"vapor"))
	assert_eq(src.size(), 2)
	assert_eq(src[0].id, &"brasas")
	assert_eq(src[1].id, &"toque_geada")


func test_every_elo_has_two_sources() -> void:
	for b in state.catalog:
		if b.is_duo():
			assert_eq(state.sources(b).size(), 2, String(b.id))


func test_a_plain_gift_has_no_sources() -> void:
	assert_true(state.sources(state.find(&"brasas")).is_empty())
	assert_true(state.sources(null).is_empty())


func test_new_elos_lists_each_formed_elo_until_it_is_seen() -> void:
	var seen := {}
	assert_true(state.new_elos(seen).is_empty())
	state.take(state.find(&"brasas"))
	state.take(state.find(&"toque_geada"))
	assert_true(state.new_elos(seen).is_empty(), "owning both sources is not an Elo yet")
	state.take(state.find(&"vapor"))
	var fresh := state.new_elos(seen)
	assert_eq(fresh.size(), 1)
	assert_eq(fresh[0].id, &"vapor")
	seen[&"vapor"] = true
	state.take(state.find(&"vapor"))
	assert_true(state.new_elos(seen).is_empty(), "a level up of a known Elo is not greeted again")


func test_elo_text_names_both_gifts_without_dash() -> void:
	assert_eq(T.t(Boon.FAMILY_KEY[Boon.Family.DUO]), "Elo")
	for b in state.catalog:
		if not b.is_duo():
			continue
		var src := state.sources(b)
		var line := EloLink.caption(src)
		assert_true(line.contains(T.t("boon_" + String(src[0].id))), line)
		assert_true(line.contains(T.t("boon_" + String(src[1].id))), line)
		assert_false(line.contains("{"), line)
		assert_false(line.contains("—") or line.contains("–"), line)
		assert_false(T.t("boon_%s_desc" % b.id).contains("—"), String(b.id))
