extends GutTest
## Blessings V1 (02_REGRAS): the pure rules of the layer: which action a blow belongs to (E and the dodge never confused with
## the others, a charged blow its source's), Frio, Impacto, the ceilings.


func _tags(list: Array) -> Array[StringName]:
	var out: Array[StringName] = []
	for t in list:
		out.append(StringName(t))
	return out


func test_each_blow_belongs_to_one_action_and_e_is_not_the_attack() -> void:
	assert_eq(CelRules.slot_of(_tags(["light", "spin", "finisher"])), Boon.Slot.ATTACK)
	assert_eq(CelRules.slot_of(_tags(["light"])), Boon.Slot.ATTACK)
	assert_eq(CelRules.slot_of(_tags(["heavy", "wave"])), Boon.Slot.SPECIAL)
	assert_eq(CelRules.slot_of(_tags(["shout", "cast"])), Boon.Slot.CAST)
	assert_eq(CelRules.slot_of(_tags(["light", "dash"])), Boon.Slot.RUSH, "the Investida carries light too, and is E")
	assert_eq(CelRules.slot_of(_tags(["ultimate"])), Boon.Slot.ULT)
	# a charged blow is its source's
	assert_eq(CelRules.slot_of(_tags(["light", "thrust", "finisher", "omega"])), Boon.Slot.ATTACK)
	assert_eq(CelRules.slot_of(_tags(["omega", "heavy", "cast", "arcane", "ice"])), Boon.Slot.SPECIAL, "the Maga's held special is no Brado")
	assert_eq(CelRules.slot_of(_tags(["shout", "cast", "arcane", "volt"])), Boon.Slot.CAST)
	# what a Blessing makes is no action
	assert_eq(CelRules.slot_of(_tags(["skill", "chama", "golpe_brasa"])), Boon.Slot.NONE)
	assert_eq(CelRules.slot_of(_tags(["echo", "light"])), Boon.Slot.NONE)
	assert_eq(CelRules.slot_of(_tags(["ember", "chama"])), Boon.Slot.NONE)
	assert_false(CelRules.is_direct(_tags(["light", CelRules.SECONDARY_TAG])))
	assert_true(CelRules.is_direct(_tags(["light"])))


func test_the_slots_of_every_move_of_both_heroes_are_known() -> void:
	for path in ["res://data/combos/paladin.tres", "res://data/combos/maga.tres"]:
		for node in (load(path) as ComboTree).all_nodes():
			var slot := CelRules.slot_of(node.tags)
			assert_ne(slot, Boon.Slot.NONE, "%s has no action" % node.id)
			if node.has_tag(&"dash"):
				assert_eq(slot, Boon.Slot.RUSH, node.id)


func test_three_cold_stacks_freeze_clear_and_make_immune() -> void:
	var st := CelState.new()
	assert_eq(st.add_cold(1, 4.0, 0.8), 0.0)
	assert_eq(st.add_cold(1, 4.0, 0.8), 0.0)
	assert_eq(st.cold, 2)
	assert_almost_eq(st.add_cold(1, 4.0, 0.8), 0.8, 0.0001, "the third freezes")
	assert_eq(st.cold, 0, "and clears")
	assert_true(st.shatterable())
	# immune for 2 s after it
	st.step(0.8)
	assert_false(st.shatterable(), "the freeze is over")
	for i in 5:
		assert_eq(st.add_cold(1, 4.0, 0.8), 0.0, "immune: no new freeze")
	assert_lte(st.cold, CelRules.COLD_NEED)
	st.step(2.1)
	assert_gt(st.add_cold(1, 4.0, 0.8), 0.0, "free to freeze again")


func test_cold_stacks_fall_when_the_window_runs_out() -> void:
	var st := CelState.new()
	st.add_cold(2, 4.0, 0.8)
	st.step(4.1)
	assert_eq(st.cold, 0)
	assert_eq(st.add_cold(1, 4.0, 0.8), 0.0)


func test_five_impact_points_stun_and_a_stun_leaves_it_immune_three_seconds() -> void:
	var st := CelState.new()
	for i in 4:
		assert_false(st.add_impact(1, 4.0))
	assert_true(st.add_impact(1, 4.0))
	assert_eq(st.impact, 0)
	for i in 6:
		assert_false(st.add_impact(1, 4.0), "immune")
	st.step(3.1)
	assert_false(st.add_impact(2, 4.0))
	assert_true(st.add_impact(3, 4.0), "two and three make five")


func test_ruptura_makes_it_four() -> void:
	var st := CelState.new()
	assert_false(st.add_impact(3, 4.0, 4))
	assert_true(st.add_impact(1, 4.0, 4))


func test_a_status_is_put_once_by_action_and_target() -> void:
	var st := CelState.new()
	assert_true(st.once(&"burn", 7))
	assert_false(st.once(&"burn", 7), "the same swing again")
	assert_true(st.once(&"burn", 8))
	assert_true(st.once(&"burn", 0), "no action key: a periodic source")
	assert_true(st.once(&"burn", 0))
	assert_true(st.ready(&"echo", 1.0))
	assert_false(st.ready(&"echo", 1.0))
	st.step(1.1)
	assert_true(st.ready(&"echo", 1.0))


func test_the_ceilings() -> void:
	assert_almost_eq(CelRules.crit_chance(0.9), 0.60, 0.0001)
	assert_eq(CelRules.crit_chance(-1.0), 0.0)
	assert_almost_eq(CelRules.crit_mult(0.0), 1.5, 0.0001)
	assert_almost_eq(CelRules.crit_mult(5.0), 2.5, 0.0001)
	assert_false(CelRules.crits(0.0, 0.0), "no chance without a source")
	assert_true(CelRules.crits(0.1, 0.05))
	assert_false(CelRules.crits(0.1, 0.5))
	assert_almost_eq(CelRules.speed_bonus(0.9), 0.5, 0.0001)
	assert_almost_eq(CelRules.cooldown_cut(0.9), 0.3, 0.0001)
	assert_almost_eq(CelRules.slow_of(3, 0.10), 0.30, 0.0001)
	assert_almost_eq(CelRules.slow_of(3, 0.15), 0.40, 0.0001, "capped at 40%")
	assert_almost_eq(CelRules.slow_of(10, 0.10), 0.40, 0.0001)
	assert_almost_eq(CelRules.weak_cut(0.25, 0.05), 0.30, 0.0001)
	assert_almost_eq(CelRules.weak_cut(0.25, 0.5), 0.40, 0.0001, "capped at 40%")
