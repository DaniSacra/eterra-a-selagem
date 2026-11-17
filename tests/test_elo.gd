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


func test_the_sources_shown_are_the_ones_held() -> void:
	state.take(state.find(&"golpe_brasa"))
	state.take(state.find(&"circulo_geada"))
	assert_true(state.can_offer(state.find(&"vapor")), "any flame and any frost form Vapor (E3-02)")
	var src := state.sources(state.find(&"vapor"))
	assert_eq(src[0].id, &"golpe_brasa")
	assert_eq(src[1].id, &"circulo_geada")


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
	assert_true(state.new_elos(seen).is_empty(), "a known Elo is not greeted again")


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


## BUG-017: an Elo has no level beyond 1 and no rarity (Hades II's duos never grow by pomegranate and never scale).
func test_an_elo_has_no_level_and_no_rarity() -> void:
	var vapor := state.find(&"vapor")
	assert_false(vapor.has_rarity())
	assert_eq(vapor.max_level, 1)
	state.take(state.find(&"brasas"))
	state.take(state.find(&"toque_geada"))
	assert_eq(state.take(vapor, Boon.Rarity.EPIC), 1)
	assert_eq(state.rarity(&"vapor"), Boon.Rarity.COMMON, "an epic card makes no epic Elo")
	assert_almost_eq(state.stat(&"steam_time"), vapor.mods[0].base, 0.0001, "always its first number")
	assert_eq(state.take(vapor), 0, "never a second level")
	var rng := RandomNumberGenerator.new()
	rng.seed = 4
	for i in 20:
		for c in state.grow_cards(rng):
			assert_false(c.boon.is_duo(), "the pomegranate never offers an Elo")
	for b in state.catalog:
		if b.is_duo():
			for m in b.mods:
				assert_true(m.per_level.is_empty(), String(b.id))


## C13-06: once an Elo can be formed, about 12% of the cards are one.
func test_an_elo_comes_about_one_card_in_eight() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12
	var catalog := BoonState.load_catalog()
	var elos := 0
	var first := 0
	var draws := 6000
	for i in draws:
		var s := BoonState.new(catalog)
		s.take(s.find(&"brasas"))
		s.take(s.find(&"toque_geada"))
		var cards := s.draw(rng, 3, Boon.RARITY_CHANCE, 0.12, 0.0)
		if cards[0].boon.is_duo():
			first += 1
		for c in cards:
			if c.boon.is_duo():
				elos += 1
				assert_eq(c.rarity, Boon.Rarity.COMMON, "an Elo's card has no rarity")
				assert_eq(c.level, 1)
	assert_almost_eq(float(first) / draws, 0.12, 0.01, "the first card is an Elo 12% of the time")
	assert_gt(elos, first)


## E3-02: an Elo asks for one gift of each list, not two exact gifts.
func test_any_gift_of_each_list_forms_the_elo() -> void:
	var vapor := state.find(&"vapor")
	for a in vapor.requires_sets[0]:
		for b in vapor.requires_sets[1]:
			var ga := state.find(StringName(a))
			var gb := state.find(StringName(b))
			if ga.slot != Boon.Slot.NONE and ga.slot == gb.slot:
				continue  # one action holds one gift: these two never stand together
			var s := BoonState.new(state.catalog)
			s.take(s.find(StringName(a)))
			assert_false(s.can_offer(vapor), "one half is not enough")
			s.take(s.find(StringName(b)))
			assert_true(s.can_offer(vapor), "%s and %s form Vapor" % [a, b])
