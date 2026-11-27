extends GutTest
## Blessings V2 (docs/design/bencaos_v2/IMPLEMENTACAO_V2.md 6): the catalog of nine angels (81 powers: 63 of V1 with the ids
## kept, 18 of Zerael and Saarael), the families and angels that are new, the text of every card and the facts of every number.

const V1_IDS: Array[StringName] = [
	&"golpe_brasa", &"pesado_brasa", &"circulo_brasa", &"passo_brasa", &"chuva_brasas", &"combustao", &"chama_contagiosa", &"brasa_persistente", &"fogo_crescente",
	&"golpe_geada", &"toque_geada", &"circulo_geada", &"floco_errante", &"peso_inverno", &"estilhaco", &"inverno_prolongado", &"geada_profunda", &"cristais_errantes",
	&"golpe_radiante", &"pesado_radiante", &"circulo_radiante", &"clarao", &"ultimo_radiante", &"luz_crescente", &"prosperidade", &"fortuna_celestial", &"esplendor",
	&"golpe_firme", &"pesado_firme", &"circulo_firme", &"passo_firme", &"ultimo_firme", &"ruptura", &"forca_inabalavel", &"peso_vigilia", &"amparo",
	&"golpe_veu", &"pesado_veu", &"circulo_veu", &"fios_cinza", &"crepusculo", &"vulnerabilidade", &"essencia_restauradora", &"veu_persistente", &"entardecer",
	&"golpe_mare", &"pesado_mare", &"circulo_mare", &"passos_leves", &"vendaval", &"cadencia", &"turbilhao", &"brisa_favoravel", &"fluxo_continuo",
	&"golpe_marca", &"pesado_marca", &"circulo_marca", &"olhar_rapido", &"exercito_ecos", &"eco_crescente", &"marca_persistente", &"sombra_revelada", &"ressonancia"]
const NEW_IDS: Array[StringName] = [
	&"golpe_peste", &"pesado_peste", &"circulo_peste", &"passo_peste", &"epidemia_celestial", &"saturacao", &"peste_persistente", &"deterioracao", &"contagio",
	&"golpe_trovao", &"pesado_trovao", &"circulo_trovao", &"passo_trovao", &"tempestade_celestial", &"descarga", &"conducao", &"sobrecarga", &"ressonancia_eletrica"]
## The V2 stats and the key of the fact each one reads in a card.
const NEW_STATS: Array[StringName] = [&"cel_poison", &"cel_poison_dps", &"cel_poison_time_pct", &"cel_poison_cold", &"cel_poison_grow",
	&"cel_poison_spread", &"cel_sat_dmg", &"dodge_plague_dps", &"cel_shock", &"cel_shock_zap", &"cel_force_discharge", &"cel_discharge",
	&"cel_conduct", &"cel_overload", &"cel_reson", &"cel_bleed", &"cel_bleed_pct", &"cel_bleed_crit", &"cel_antic", &"cel_antic_all",
	&"cel_stun_antic", &"cel_burn_div", &"cel_slot_shatter", &"cel_shatter_frag", &"cel_crystal_dot", &"cel_cold_keep", &"cel_cold_impact",
	&"cel_stun_pulse", &"cel_guard_impact", &"cel_weak_div", &"cel_weak_mana_div", &"cel_weak_extend", &"cel_whirl_spread", &"cel_cadence_mix",
	&"cel_mark_pass", &"cel_crit_apply", &"cel_extend"]

var catalog: Array[Boon]


func before_all() -> void:
	catalog = BoonState.load_catalog()


func _active() -> Array[Boon]:
	var out: Array[Boon] = []
	for b in catalog:
		if not b.reserve:
			out.append(b)
	return out


func _find(id: StringName) -> Boon:
	for b in catalog:
		if b.id == id:
			return b
	return null


func test_81_active_the_63_of_v1_kept_and_the_18_new() -> void:
	var ids := {}
	for b in _active():
		ids[b.id] = true
	assert_eq(ids.size(), 81)
	for id in V1_IDS:
		assert_true(ids.has(id), "V1 id lost: %s" % id)
	for id in NEW_IDS:
		assert_true(ids.has(id), "V2 id missing: %s" % id)
	assert_eq(V1_IDS.size() + NEW_IDS.size(), 81)


func test_nine_per_angel_five_slots_and_no_principal_on_e() -> void:
	var by_family := {}
	for b in _active():
		if b.is_duo():
			continue
		if not by_family.has(b.family):
			by_family[b.family] = []
		(by_family[b.family] as Array).append(b)
	assert_eq(by_family.size(), 9, "nine families")
	var principals := 0
	for f: int in by_family:
		var mine: Array = by_family[f]
		assert_eq(mine.size(), 9, "family %d" % f)
		var slots := {}
		for b: Boon in mine:
			if b.slot != Boon.Slot.NONE:
				principals += 1
				assert_false(slots.has(b.slot), "two principals of a slot in family %d" % f)
				slots[b.slot] = true
				assert_ne(b.slot, Boon.Slot.RUSH, "E has no Blessing")
		assert_eq(slots.size(), 5, "attack, special, power, dodge, ultimate in family %d" % f)
	assert_eq(principals, 45)


func test_every_complement_has_a_source_in_its_own_angel() -> void:
	for b in _active():
		if not b.is_complement():
			continue
		for need in b.needs_all:
			var ok := false
			for c in _active():
				if c.family != b.family:
					continue
				if c.id == StringName(need) or c.grants.has(need) or (need.begins_with("fam:") and String(c.family_tag()) == need.substr(4)):
					ok = true
					break
			assert_true(ok, "%s asks %s and nothing of its angel gives it" % [b.id, need])
	# the chains: Descarga and Condução, Saturação and the poison
	assert_eq(_find(&"conducao").needs_all, PackedStringArray(["descarga"]))
	assert_eq(_find(&"ressonancia_eletrica").needs_all, PackedStringArray(["descarga"]))
	assert_true(_find(&"descarga").needs_all.has("shock"))
	assert_true(_find(&"saturacao").needs_all.has("poison"))


func test_the_new_families_have_colour_tag_key_and_seal() -> void:
	assert_eq(int(Boon.Family.MARCA), 7)
	assert_eq(int(Boon.Family.PESTE), 8)
	assert_eq(int(Boon.Family.TROVAO), 9)
	assert_eq(Boon.FAMILY_COLOR.size(), 10)
	assert_eq(Boon.FAMILY_TAG.size(), 10)
	assert_eq(Boon.FAMILY_KEY.size(), 10)
	assert_eq(Boon.FAMILY_TAG[Boon.Family.PESTE], &"peste")
	assert_eq(Boon.FAMILY_TAG[Boon.Family.TROVAO], &"trovao")
	assert_eq(Boon.FAMILY_COLOR[Boon.Family.PESTE].to_html(false), "c9b458")
	assert_eq(Boon.FAMILY_COLOR[Boon.Family.TROVAO].to_html(false), "7d8590")
	for f in [Boon.Family.PESTE, Boon.Family.TROVAO]:
		assert_ne(T.t(Boon.FAMILY_KEY[f]), String(Boon.FAMILY_KEY[f]), "the family has a name")
		assert_ne(AngelSeal.tint(f), UiKit.OLD_GOLD, "the seal has a colour of its own")
	assert_eq(Combat.PLAGUE, Boon.FAMILY_COLOR[Boon.Family.PESTE])
	assert_eq(Combat.VOLT, Boon.FAMILY_COLOR[Boon.Family.TROVAO])


func test_nine_angels_with_portraits_for_zerael_and_saarael() -> void:
	var angels := Encounter.load_catalog()
	assert_eq(angels.size(), 9)
	var ids: Array[StringName] = []
	for a in angels:
		ids.append(a.id)
	assert_true(ids.has(&"zerael"))
	assert_true(ids.has(&"thunder"))
	for a in angels:
		assert_ne(T.t(a.name_key), String(a.name_key), "name of %s" % a.id)
		assert_ne(T.t(a.line_key), String(a.line_key), "line of %s" % a.id)
		assert_not_null(AngelArt.texture(a.id), "portrait of %s" % a.id)
	assert_eq(T.t(&"angel_thunder"), "Saarael")
	assert_eq(T.t(&"angel_zerael"), "Zerael")
	var families := {}
	for a in angels:
		families[a.family] = true
	assert_eq(families.size(), 9, "one angel a family")


func test_old_saves_and_ids_resolve_and_the_reserve_still_loads() -> void:
	var state := BoonState.new(catalog)
	for id in V1_IDS:
		assert_not_null(state.find(id), String(id))
	var reserve := catalog.filter(func(b: Boon) -> bool: return b.reserve)
	assert_gte(reserve.size(), 50, "the old catalog is still there, whole")


func test_only_the_marked_numbers_scale_with_rarity_in_the_new_cards() -> void:
	var scales: Array[StringName] = [&"cel_poison_dps", &"dodge_plague_dps", &"cel_sat_dmg", &"cel_shock_zap", &"cel_discharge", &"cel_bleed"]
	for id in NEW_IDS + [&"pesado_marca", &"exercito_ecos"] as Array[StringName]:
		var b := _find(id)
		for m in b.mods:
			for mult: float in Boon.RARITY_MULT:
				var want := m.base * mult if scales.has(m.stat) else m.base
				assert_almost_eq(m.at(1, mult), want, 0.0001, "%s %s x%s" % [id, m.stat, mult])
	# the explicit table of the spec (level 1)
	var table := {&"golpe_peste": 0.55, &"pesado_peste": 0.8, &"passo_peste": 1.0, &"saturacao": 8.0, &"golpe_trovao": 1.0, &"pesado_trovao": 1.5, &"descarga": 3.0}
	for id: StringName in table:
		var m := _find(id).mods[0]
		var got: Array[float] = []
		for mult: float in Boon.RARITY_MULT:
			got.append(m.at(1, mult))
		assert_almost_eq(got[0], float(table[id]), 0.0001, String(id))
		assert_almost_eq(got[3], float(table[id]) * 2.5, 0.0001, String(id))


func test_the_numbers_of_the_spec_are_the_numbers_in_play() -> void:
	var state := BoonState.new(catalog)
	var want := {&"golpe_peste": [&"cel_poison_dps", 0.55], &"pesado_peste": [&"cel_poison_dps", 0.8], &"passo_peste": [&"dodge_plague_dps", 1.0],
		&"saturacao": [&"cel_sat_dmg", 8.0], &"peste_persistente": [&"cel_poison_time_pct", 0.3], &"deterioracao": [&"cel_poison_grow", 0.06],
		&"contagio": [&"cel_poison_spread", 0.5], &"golpe_trovao": [&"cel_shock_zap", 1.0], &"pesado_trovao": [&"cel_shock_zap", 1.5],
		&"descarga": [&"cel_discharge", 3.0], &"conducao": [&"cel_conduct", 2.0], &"sobrecarga": [&"cel_overload", 0.5],
		&"ressonancia_eletrica": [&"cel_reson", 0.1], &"pesado_brasa": [&"cel_burn_dps", 5.0], &"combustao": [&"cel_combust_dmg", 9.0],
		&"pesado_marca": [&"cel_echo", 0.4], &"eco_crescente": [&"cel_echo_pct", 0.3], &"fogo_crescente": [&"cel_burn_dps_pct", 0.2]}
	for id: StringName in want:
		assert_almost_eq(state.find(id).mods[0].base, float(want[id][1]), 0.0001, String(id))
		assert_eq(state.find(id).mods[0].stat, want[id][0], String(id))
	var plague := state.find(&"circulo_peste").skill
	assert_eq(plague.status, &"poison")
	assert_almost_eq(plague.get_radius(1), 2.5, 0.001)
	assert_almost_eq(plague.get_duration(1), 4.0, 0.001)
	assert_almost_eq(plague.status_gap, 1.0, 0.001)
	assert_eq(plague.get_damage(1), 0.0, "no damage of contact")
	var epidemic := state.find(&"epidemia_celestial").skill
	assert_almost_eq(epidemic.get_radius(1), 7.0, 0.001)
	assert_almost_eq(epidemic.get_status_power(1), 3.0, 0.001)
	var storm := state.find(&"tempestade_celestial").skill
	assert_eq(storm.get_count(1), 6)
	assert_almost_eq(storm.get_status_power(1), 2.0, 0.001)
	assert_eq(state.find(&"circulo_trovao").skill.status, &"shock")
	assert_almost_eq(state.find(&"passo_trovao").skill.get_gap(1), 2.0, 0.001)
	assert_eq(state.find(&"pesado_mare").skill.status, &"spread")


func test_every_new_card_reads_its_real_numbers_and_every_new_stat_has_a_fact() -> void:
	for b in _active():
		for lv in range(1, b.max_level + 1):
			var desc := BoonChoice.describe(b, lv)
			assert_false(desc.contains("{"), "%s level %d: %s" % [b.id, lv, desc])
			assert_false(desc.contains("—") or desc.contains("–"), "a dash in %s" % b.id)
	for stat in NEW_STATS:
		assert_true(T.table.entries.has("fact_%s" % stat), "no fact for %s" % stat)
	for id in NEW_IDS:
		assert_ne(T.t("boon_%s" % id), "boon_%s" % id, String(id))
		assert_ne(T.t("boon_%s_desc" % id), "boon_%s_desc" % id, String(id))
	for term in [&"poison", &"bleed", &"shock", &"window", &"antic"]:
		for suffix in ["", "_text", "_words"]:
			assert_true(T.table.entries.has("gloss_%s%s" % [term, suffix]), "gloss_%s%s" % [term, suffix])
		assert_true(Glossary.TERMS.has(term), "%s is not a term the cards call" % term)
	assert_true(Glossary.terms_of("Aplica Veneno e cargas elétricas").has(&"poison"))
	assert_true(Glossary.terms_of("Aplica Veneno e cargas elétricas").size() <= Glossary.MAX)
	# the text of the page that were lost to nothing: no dash anywhere in the new texts
	for key: String in T.table.entries:
		if key.begins_with("gloss_") or key.begins_with("fact_cel") or key.ends_with("_peste") or key.ends_with("_trovao"):
			var t := String(T.table.entries[key])
			assert_false(t.contains("—") or t.contains("–"), key)
