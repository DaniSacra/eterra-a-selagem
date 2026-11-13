extends GutTest
## Gifts: levels, the numbers they add up to, the draw of three cards and the combinations between families.

var state: BoonState
var rng: RandomNumberGenerator


func before_each() -> void:
	state = BoonState.new(BoonState.load_catalog())
	rng = RandomNumberGenerator.new()
	rng.seed = 42


func _take(id: StringName, times: int = 1) -> void:
	for i in times:
		state.take(state.find(id))


func test_catalog_has_four_families_of_three_and_the_combinations() -> void:
	var per_family := {}
	for b in state.catalog:
		per_family[b.family] = per_family.get(b.family, 0) + 1
	for family: int in [Boon.Family.CHAMA, Boon.Family.GEADA, Boon.Family.LUZ, Boon.Family.VIGILIA]:
		assert_eq(per_family.get(family), 3)
	assert_gte(per_family.get(Boon.Family.DUO), 4)


func test_every_gift_has_three_levels_text_and_an_icon() -> void:
	var icons := 18  # glyphs drawn by scripts/ui/boon_icon.gd
	var seen := {}
	for b in state.catalog:
		assert_false(seen.has(b.id), "duplicate %s" % b.id)
		seen[b.id] = true
		assert_eq(b.max_level, 3, String(b.id))
		assert_lt(b.icon, icons, String(b.id))
		assert_ne(T.t("boon_%s" % b.id), "boon_%s" % b.id, "name of %s" % b.id)
		assert_true(b.mods.size() > 0 or b.skill != null, "%s does nothing" % b.id)
		for m in b.mods:
			assert_gte(m.values.size(), b.max_level, "%s needs a value per level" % b.id)
		for lv in range(1, b.max_level + 1):
			var desc := BoonChoice.describe(b, lv)
			assert_false(desc.contains("{"), "%s level %d: %s" % [b.id, lv, desc])
			assert_false(desc.contains("—"))


func test_combinations_join_two_different_families() -> void:
	for b in state.catalog:
		if not b.is_duo():
			continue
		assert_eq(b.requires.size(), 2, String(b.id))
		var a := state.find(b.requires[0])
		var c := state.find(b.requires[1])
		assert_not_null(a, "%s requires an unknown gift" % b.id)
		assert_not_null(c, "%s requires an unknown gift" % b.id)
		assert_ne(a.family, c.family, "%s must join two families" % b.id)


func test_levels_go_up_to_the_maximum_and_stop() -> void:
	var b := state.find(&"brasas")
	assert_eq(state.take(b), 1)
	assert_eq(state.take(b), 2)
	assert_eq(state.take(b), 3)
	assert_eq(state.take(b), 0, "already at the maximum")
	assert_eq(state.level(&"brasas"), 3)


func test_stat_follows_the_level() -> void:
	assert_eq(state.stat(&"freeze_time", [&"heavy"] as Array[StringName]), 0.0)
	_take(&"toque_geada")
	assert_almost_eq(state.stat(&"freeze_time", [&"heavy"] as Array[StringName]), 1.0, 0.001)
	_take(&"toque_geada", 2)
	assert_almost_eq(state.stat(&"freeze_time", [&"heavy"] as Array[StringName]), 2.0, 0.001)


func test_tagged_modifiers_only_touch_their_moves() -> void:
	_take(&"toque_geada")
	assert_eq(state.stat(&"freeze_time", [&"light"] as Array[StringName]), 0.0, "light moves do not freeze")
	assert_eq(state.stat(&"freeze_time"), 0.0)
	_take(&"estilhaco")
	assert_almost_eq(state.stat(&"shatter_pct", [&"light"] as Array[StringName]), 0.5, 0.001, "untagged modifiers apply everywhere")


func test_gifts_change_moves_of_the_tree_not_new_attacks() -> void:
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	var tags := {}
	for node in tree.all_nodes():
		for tag in node.tags:
			tags[tag] = true
	# skills carry "skill" and their family's tag (Boon.FAMILY_TAG)
	for extra: StringName in [&"mark", &"ember", &"skill"] + Boon.FAMILY_TAG:
		tags[extra] = true
	for b in state.catalog:
		for m in b.mods:
			if m.tag != &"":
				assert_true(tags.has(m.tag), "%s points at tag '%s', which no move has" % [b.id, m.tag])


func test_skill_gifts_cast_on_their_own() -> void:
	var b := state.find(&"flagelo")
	assert_not_null(b.skill)
	assert_eq(b.skill.kind, SkillDef.Kind.STRIKES)
	assert_eq(b.skill.status, &"stun")
	assert_gt(b.skill.get_count(3), b.skill.get_count(1))


func test_bonuses_from_different_gifts_add_up() -> void:
	_take(&"lamina_ardente", 2)
	_take(&"toque_geada", 3)
	_take(&"onda_maior")
	_take(&"aurora", 1)
	var tags: Array[StringName] = [&"heavy", &"luz"]
	assert_almost_eq(state.stat(&"freeze_time", tags), 2.0 + 0.8, 0.001)


func test_offers_are_three_different_gifts() -> void:
	for i in 30:
		var offers := state.offers(rng)
		assert_eq(offers.size(), 3)
		assert_ne(offers[0], offers[1])
		assert_ne(offers[1], offers[2])
		assert_ne(offers[0], offers[2])


func test_combinations_are_not_offered_before_both_gifts_are_owned() -> void:
	_take(&"brasas")
	for i in 60:
		for b in state.offers(rng):
			assert_false(b.is_duo(), "%s offered with one half missing" % b.id)


func test_combination_shows_up_once_both_gifts_are_owned() -> void:
	_take(&"brasas")
	_take(&"toque_geada")
	assert_true(state.can_offer(state.find(&"vapor")))
	var seen := false
	for i in 40:
		for b in state.offers(rng):
			seen = seen or b.id == &"vapor"
	assert_true(seen)
	_take(&"vapor")
	assert_gt(state.stat(&"steam_time"), 0.0)
	_take(&"vapor", 2)
	assert_false(state.can_offer(state.find(&"vapor")), "a maxed combination leaves the draw")


func test_maxed_gifts_leave_the_draw_and_the_draw_can_run_dry() -> void:
	for round in 3:
		for b in state.catalog:
			state.take(b)
	assert_eq(state.offers(rng).size(), 0)


func test_same_seed_same_offers() -> void:
	var a := state.offers(rng).map(func(b: Boon) -> StringName: return b.id)
	rng.seed = 42
	var b2 := state.offers(rng).map(func(b: Boon) -> StringName: return b.id)
	assert_eq(a, b2)


func test_values_are_written_the_brazilian_way() -> void:
	assert_eq(BoonMod.format(&"damage_pct", 0.15), "15%")
	assert_eq(BoonMod.format(&"undead_mult", 2.0), "100%")
	assert_eq(BoonMod.format(&"freeze_time", 1.2), "1,2")
	assert_eq(BoonMod.format(&"shield_cooldown", 20.0), "20")


func test_skill_values_grow_with_level() -> void:
	for b in state.catalog:
		if b.skill == null:
			continue
		var s := b.skill
		for lv in range(1, b.max_level + 1):
			assert_gt(s.get_cooldown(lv), 0.0, String(b.id))
			assert_gte(s.get_damage(lv), 0.0, String(b.id))
		if b.max_level > 1:
			assert_gte(s.get_damage(b.max_level), s.get_damage(1), String(b.id))
			assert_lte(s.get_cooldown(b.max_level), s.get_cooldown(1), String(b.id))
