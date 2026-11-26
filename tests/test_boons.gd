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


func test_catalog_has_four_families_and_the_combinations() -> void:
	var per_family := {}
	for b in state.catalog:
		per_family[b.family] = per_family.get(b.family, 0) + 1
	for family: int in [Boon.Family.CHAMA, Boon.Family.GEADA, Boon.Family.LUZ, Boon.Family.VIGILIA]:
		assert_gte(per_family.get(family), 3)
	assert_gte(per_family.get(Boon.Family.DUO), 4)


func test_every_gift_has_its_levels_text_and_an_icon() -> void:
	var icons := 23  # glyphs drawn by scripts/ui/boon_icon.gd (20 to 22 the Veu, Mare and Marca of AN-2)
	var seen := {}
	for b in state.catalog:
		assert_false(seen.has(b.id), "duplicate %s" % b.id)
		seen[b.id] = true
		# (V1: a Blessing grows only when a number of it has a gain per level; the others are held once)
		var grows := b.skill != null and b.skill.damage.size() > 1
		for m in b.mods:
			grows = grows or not m.per_level.is_empty()
		assert_eq(b.max_level, 3 if grows and not b.is_duo() else 1, String(b.id))
		assert_lt(b.icon, icons, String(b.id))
		assert_ne(T.t("boon_%s" % b.id), "boon_%s" % b.id, "name of %s" % b.id)
		assert_true(b.mods.size() > 0 or b.skill != null, "%s does nothing" % b.id)
		for m in b.mods:
			if not b.is_duo():
				if b.reserve:
					assert_false(m.per_level.is_empty(), "%s needs a gain per level" % b.id)
			else:
				assert_true(m.per_level.is_empty(), "an Elo never grows (BUG-017): %s" % b.id)
		for lv in range(1, b.max_level + 1):
			var desc := BoonChoice.describe(b, lv)
			assert_false(desc.contains("{"), "%s level %d: %s" % [b.id, lv, desc])
			assert_false(desc.contains("—"))


func test_combinations_join_two_different_families() -> void:
	for b in state.catalog:
		if not b.is_duo():
			continue
		assert_eq(b.requires_sets.size(), 2, String(b.id))
		var families := []
		for list in b.requires_sets:
			assert_false(list.is_empty(), String(b.id))
			var fam := -1
			for id in list:
				var g := state.find(StringName(id))
				assert_not_null(g, "%s requires an unknown gift %s" % [b.id, id])
				if g == null:
					continue
				assert_false(g.is_duo(), "%s: an Elo never asks for an Elo" % b.id)
				if fam < 0:
					fam = g.family
				assert_eq(g.family, fam, "%s: a list is of one family" % b.id)
			families.append(fam)
		assert_ne(families[0], families[1], "%s must join two families" % b.id)


func test_levels_go_up_to_the_maximum_and_stop() -> void:
	var b := state.find(&"brasas")
	assert_eq(state.take(b), 1)
	assert_eq(state.take(b), 2)
	assert_eq(state.take(b), 3)
	assert_eq(state.take(b), 0, "already at the maximum")
	assert_eq(state.level(&"brasas"), 3)


func test_stat_follows_the_level() -> void:
	assert_eq(state.slot_stat(&"cel_burn_dps", Boon.Slot.ATTACK), 0.0)
	var m: BoonMod = state.find(&"golpe_brasa").mods[0]
	_take(&"golpe_brasa")
	assert_almost_eq(state.slot_stat(&"cel_burn_dps", Boon.Slot.ATTACK), m.value(1), 0.001)
	_take(&"golpe_brasa", 2)
	assert_almost_eq(state.slot_stat(&"cel_burn_dps", Boon.Slot.ATTACK), m.value(3), 0.001)
	assert_gt(m.value(3), m.value(1))


## C13-05 (Hades II's GetProcessedValue): level 1 is the base times the rarity, every level after adds a fixed gain the
## rarity never scales, the last gain again past the list.
func test_a_level_adds_a_fixed_gain_the_rarity_never_scales() -> void:
	var m := BoonMod.new()
	m.base = 0.2
	m.per_level = PackedFloat32Array([0.1, 0.05])
	assert_almost_eq(m.at(1), 0.2, 0.0001)
	assert_almost_eq(m.at(2), 0.3, 0.0001)
	assert_almost_eq(m.at(3), 0.35, 0.0001)
	assert_almost_eq(m.at(5), 0.45, 0.0001, "the last gain repeats")
	assert_almost_eq(m.at(1, 2.0), 0.4, 0.0001, "an epic doubles the base")
	assert_almost_eq(m.at(3, 2.0), 0.4 + 0.15, 0.0001, "and adds the gains as they are")
	assert_eq(m.at(0), 0.0)
	m.by_rarity = false
	assert_almost_eq(m.at(2, 2.5), 0.3, 0.0001, "a number that never scales")
	var s := SkillDef.new()
	s.damage = PackedFloat32Array([20, 30, 42])
	assert_almost_eq(s.damage_at(1, 1.5), 30.0, 0.0001)
	assert_almost_eq(s.damage_at(3, 1.5), 30.0 + 22.0, 0.0001, "a skill's levels add as they are too")


## Every Blessing's numbers at every level, migrated from the per-level lists (C13-05: the same at a common card).
func test_every_blessing_grows_by_its_gains() -> void:
	for b in state.catalog:
		for m in b.mods:
			for lv in range(1, b.max_level + 1):
				var want := m.base
				for k in range(2, lv + 1):
					if not m.per_level.is_empty():
						want += m.per_level[mini(k - 2, m.per_level.size() - 1)]
				assert_almost_eq(m.value(lv), want, 0.0001, "%s %s level %d" % [b.id, m.stat, lv])


func test_tagged_modifiers_only_touch_their_moves() -> void:
	# (V1: the Blessings carry no move tag, the engine keeps the filter for the Gifts and the data that use one)
	var heavy := BoonMod.new()
	heavy.stat = &"freeze_time"
	heavy.tag = &"heavy"
	heavy.base = 1.0
	var any := BoonMod.new()
	any.stat = &"shatter_pct"
	any.base = 0.5
	state.grant([heavy, any])
	assert_eq(state.stat(&"freeze_time", [&"light"] as Array[StringName]), 0.0, "light moves do not freeze")
	assert_eq(state.stat(&"freeze_time"), 0.0)
	assert_almost_eq(state.stat(&"freeze_time", [&"heavy"] as Array[StringName]), 1.0, 0.001)
	assert_almost_eq(state.stat(&"shatter_pct", [&"light"] as Array[StringName]), 0.5, 0.001, "untagged modifiers apply everywhere")


func test_gifts_change_moves_of_the_tree_not_new_attacks() -> void:
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	var tags := {}
	for node in tree.all_nodes():
		for tag in node.tags:
			tags[tag] = true
	# skills carry "skill" and their family's tag (Boon.FAMILY_TAG)
	for extra: StringName in [&"mark", &"ember", &"skill", &"ultimate", &"dash"] + Boon.FAMILY_TAG + Combat.CAST_TAGS:
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
	_take(&"brasa_persistente", 2)
	var more := BoonMod.new()
	more.stat = &"cel_burn_time_pct"
	more.base = 0.2
	state.grant([more])
	var m: BoonMod = state.find(&"brasa_persistente").mods[0]
	assert_almost_eq(state.stat(&"cel_burn_time_pct"), m.value(2) + 0.2, 0.001)


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
	_take(&"golpe_brasa")
	_take(&"toque_geada")
	assert_true(state.can_offer(state.find(&"vapor")))
	var seen := false
	for i in 40:
		for b in state.offers(rng):
			seen = seen or b.id == &"vapor"
	assert_false(seen, "V1: the Elos are out of the angel draw (the resource stays, a save or a test can still hold it)")
	_take(&"vapor")
	assert_gt(state.stat(&"steam_time"), 0.0)
	assert_false(state.can_offer(state.find(&"vapor")), "an Elo never grows: it leaves the draw once taken")


func test_maxed_gifts_leave_the_draw_and_the_draw_can_run_dry() -> void:
	for b in state.catalog:
		state.levels[b.id] = b.max_level
	assert_eq(state.offers(rng).size(), 0)


func test_a_blessing_held_is_never_drawn_again() -> void:
	_take(&"brasas")
	_take(&"golpe_radiante")
	for i in 200:
		for b in state.offers(rng):
			assert_ne(b.id, &"brasas", "it grows by the pomegranate, not by a card")
			assert_ne(b.id, &"golpe_radiante")


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
		for lv in range(1, maxi(b.max_level, 1) + 1):
			assert_gt(s.get_cooldown(lv), 0.0, String(b.id))
			assert_gte(s.get_damage(lv), 0.0, String(b.id))
		if b.max_level > 1:
			assert_gte(s.get_damage(b.max_level), s.get_damage(1), String(b.id))
			assert_lte(s.get_cooldown(b.max_level), s.get_cooldown(1), String(b.id))


## Gifts riding on an action: one per action, the new one replaces the old.
func _slot_gift(id: StringName, slot: Boon.Slot, stat_name: StringName = &"damage_pct", tag: StringName = &"light", by_rarity: bool = true) -> Boon:
	var b := Boon.new()
	b.id = id
	b.slot = slot
	var m := BoonMod.new()
	m.stat = stat_name
	m.tag = tag
	m.base = 0.2
	m.per_level = PackedFloat32Array([0.1, 0.1])
	m.by_rarity = by_rarity
	b.mods = [m]
	state.catalog.append(b)
	return b


func test_a_gift_on_a_taken_action_replaces_the_old_one() -> void:
	var a := _slot_gift(&"t_a", Boon.Slot.ATTACK)
	var b := _slot_gift(&"t_b", Boon.Slot.ATTACK)
	var c := _slot_gift(&"t_c", Boon.Slot.SPECIAL, &"damage_pct", &"heavy")
	state.take(a)
	state.take(c)
	assert_eq(state.replaced_by(b), a)
	assert_null(state.replaced_by(a), "levelling the same gift replaces nothing")
	state.take(b)
	assert_eq(state.level(&"t_a"), 0)
	assert_eq(state.in_slot(Boon.Slot.ATTACK), b)
	assert_eq(state.in_slot(Boon.Slot.SPECIAL), c, "other actions keep their gift")


func test_free_gifts_never_replace() -> void:
	_take(&"brasas")
	_take(&"onda_maior")
	assert_eq(state.owned().size(), 2)
	assert_null(state.in_slot(Boon.Slot.NONE))


func test_rarity_multiplies_marked_numbers_and_keeps_the_best() -> void:
	var a := _slot_gift(&"t_a", Boon.Slot.ATTACK)
	var n := _slot_gift(&"t_n", Boon.Slot.DASH, &"dodge_charges", &"", false)
	state.take(a, Boon.Rarity.EPIC)
	state.take(n, Boon.Rarity.LEGENDARY)
	var light: Array[StringName] = [&"light"]
	assert_almost_eq(state.stat(&"damage_pct", light), 0.2 * 2.0, 0.001)
	assert_almost_eq(state.stat(&"dodge_charges"), 0.2, 0.001, "counts do not scale")
	state.take(a, Boon.Rarity.COMMON)
	assert_eq(state.rarity(&"t_a"), Boon.Rarity.EPIC, "a later common card keeps the epic rarity")
	assert_almost_eq(state.stat(&"damage_pct", light), 0.2 * 2.0 + 0.1, 0.001, "the level's gain is not scaled")


func test_rarity_draw_is_mostly_common_and_the_legendary_rare() -> void:
	var seen := [0, 0, 0, 0]
	for i in 4000:
		seen[BoonState.roll_rarity(rng)] += 1
	assert_gt(seen[0], seen[1])
	assert_gt(seen[1], seen[2])
	assert_gt(seen[2], 0)
	assert_gt(seen[3], 0, "the legendary is in the common draw now (decision 10 of 2026-11-22: 1%)")
	assert_lt(seen[3], seen[2])


func test_a_guardian_gift_is_mostly_rare_and_the_legendary_is_3_percent() -> void:
	var seen := [0, 0, 0, 0]
	for i in 2000:
		seen[BoonState.roll_rarity(rng, Boon.RARITY_CHANCE_GUARDIAN)] += 1
	assert_gt(seen[1], seen[0] * 5)
	assert_gt(seen[1], seen[2])
	assert_gt(seen[3], 0, "the guardian gives the legendary now and then (3%)")
	assert_lt(seen[3], seen[2])


func test_grow_offers_only_owned_gifts_that_can_grow() -> void:
	assert_false(state.can_grow(), "nothing owned yet")
	var b := state.catalog[0]
	state.take(b)
	assert_true(state.can_grow())
	var offers := state.grow_offers(rng)
	assert_eq(offers.size(), 1)
	assert_eq(offers[0], b)
	state.levels[b.id] = b.max_level
	assert_false(state.can_grow())


## BO-2: the attack, the special and the Brado have a gift of every family; the Investida, the dodge and the ultimate the
## families done so far (R9 gave Luz and Vigília their Investida, dodge and ultimate cells).
func test_each_action_has_a_gift_of_its_families() -> void:
	# (V1: seven angels, V2: nine, five buttons; E carries no Blessing of the draw)
	var want := {Boon.Slot.ATTACK: 9, Boon.Slot.SPECIAL: 9, Boon.Slot.CAST: 9, Boon.Slot.DASH: 9, Boon.Slot.RUSH: 0, Boon.Slot.ULT: 9}
	for slot: Boon.Slot in want:
		var families := {}
		for b in state.catalog:
			if b.slot == slot and not b.reserve:
				families[b.family] = true
				for m in b.mods:
					# (the attack's spin is its last blow: a tag of the same light attack)
					var own: bool = m.tag == Boon.SLOT_TAG[slot] or m.tag == &"" or (slot == Boon.Slot.ATTACK and m.tag == &"spin")
					assert_true(own, "%s rides on %s but changes '%s'" % [b.id, Boon.SLOT_KEY[slot], m.tag])
		assert_eq(families.size(), want[slot], "slot %s" % Boon.SLOT_KEY[slot])


func test_vigia_firme_is_in_the_reserve_and_never_offered() -> void:
	var b := state.find(&"vigia_firme")
	assert_not_null(b)
	assert_true(b.reserve, "Vigia Firme does nothing under StunRule.NONE, so it waits in the reserve")
	assert_false(state.offerable(b))
