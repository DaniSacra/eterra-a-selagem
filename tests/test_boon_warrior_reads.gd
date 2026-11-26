extends GutTest
## Lote R9 (docs/design/heroes/bencaos_por_botao.md): every Blessing the draw can offer the Warrior changes some number in
## play for him: it carries a skill (a button fires it), or a stat the game reads, on a tag one of his blows carries.

## Stats some code of the Warrior's game reads (Combat, Ultimates, Game, Player).
const READ: Array[StringName] = [&"damage_pct", &"reach_pct", &"wave_size_pct", &"burn_dps", &"freeze_time", &"shatter_pct",
	&"detonate_dmg", &"dodge_ember_dps", &"dodge_charges", &"move_speed_pct", &"max_hp", &"heal_on_kill", &"ult_charge_pct",
	&"steam_time", &"shield_cooldown", &"shield_burst", &"weak_time", &"mark_time", &"stun_pct", &"armor_pct", &"cast_dps", &"magick_max", &"weak_pct", &"push_pct", &"shove_pct", &"crit_pct", &"gold_pct"]
## Tags the Warrior's blows, Brado, Investida and Corte do Juizo carry (tools/make_data.gd, _tree).
const TAGS: Array[StringName] = [&"light", &"heavy", &"wave", &"cast", &"shout", &"dash", &"spin", &"finisher", &"thrust", &"omega", &"ultimate"]


func test_every_offerable_blessing_changes_a_number_for_the_warrior() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	var n := 0
	for b in state.catalog:
		if b.reserve or b.is_duo():
			continue
		n += 1
		var ok := b.skill != null
		for m in b.mods:
			# (V1: the numbers of the layer, cel_*, are read by Celestial for the action the Blessing rides)
			if String(m.stat).begins_with("cel_") or (READ.has(m.stat) and (m.tag == &"" or TAGS.has(m.tag))):
				ok = true
		assert_true(ok, "%s changes nothing for the Warrior" % b.id)
	assert_gt(n, 40)


func test_the_four_new_cells_are_filled() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	# (V1: E has no Blessing, so passo_claro and investida_firme are reserve; the dodge cells are Clarão and Passo Firme)
	var want := {&"ultimo_radiante": Boon.Slot.ULT, &"clarao": Boon.Slot.DASH, &"passo_firme": Boon.Slot.DASH, &"ultimo_firme": Boon.Slot.ULT}
	for id: StringName in want:
		var b := state.find(id)
		assert_not_null(b, String(id))
		assert_eq(b.slot, want[id], String(id))
		assert_false(b.reserve)
	assert_eq(state.find(&"ultimo_radiante").skill.trigger, SkillDef.Trigger.ULT)
	for id: StringName in [&"passo_claro", &"investida_firme"]:
		assert_true(state.find(id).reserve, "E has no Blessing in V1: %s" % id)
	assert_eq(state.find(&"ultimo_firme").skill.trigger, SkillDef.Trigger.ULT)


func test_firm_blessings_no_longer_read_dead_stats() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	for id: StringName in [&"pesado_firme", &"circulo_firme", &"passo_radiante"]:
		for m in state.find(id).mods:
			assert_false(m.stat in [&"cast_size_pct", &"dome_heal"], "%s still reads %s" % [id, m.stat])
	assert_eq(state.find(&"pesado_firme").mods[0].stat, &"cel_impact")
