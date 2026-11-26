extends GutTest
## Blessings V1 (docs/design/bencaos_v1/04_TESTES.md): the catalog of the seven angels. 7 families of 9, 63 ids, 35
## principals (a slot each) and 28 complements, no Duo and nothing of the Investida in the draw, every power eligible,
## taken and read for both heroes, every rarity, and the table of the document and the data agree.

const FAMILIES: Array[Boon.Family] = [Boon.Family.CHAMA, Boon.Family.GEADA, Boon.Family.LUZ, Boon.Family.VIGILIA, Boon.Family.VEU,
	Boon.Family.MARE, Boon.Family.MARCA]
## The slot each principal holds and the move tag that a hero needs for its action to exist (dodge and ultimate: any hero).
const SLOT_NEEDS := {Boon.Slot.ATTACK: &"light", Boon.Slot.SPECIAL: &"heavy", Boon.Slot.CAST: &"shout", Boon.Slot.DASH: &"", Boon.Slot.ULT: &""}
## What the rarity may multiply (direct extra damage, DPS and relative damage bonuses); the rest of the numbers never scale.
const SCALES: Array[StringName] = [&"cel_burn_dps", &"dodge_ember_dps", &"cel_combust_dmg", &"cel_whirl_dmg", &"cel_burn_dps_pct",
	&"cel_shatter_pct", &"cel_stunned_dmg_pct", &"cel_weak_dmg_pct", &"cel_echo_pct", &"cel_echo_marked_pct"]

var catalog: Array[Boon]


func before_all() -> void:
	catalog = BoonState.load_catalog()


func _active() -> Array[Boon]:
	var out: Array[Boon] = []
	for b in catalog:
		if not b.reserve:
			out.append(b)
	return out


func _hero_tags(hero: HeroDef) -> Dictionary:
	var tags := {}
	for node in (load(hero.combos) as ComboTree).all_nodes():
		for t in node.tags:
			tags[t] = true
	return tags


## A hand with a Blessing for every capability: what a complement of an angel asks for (a principal of the angel).
func _state_with_requirements(b: Boon, hero: HeroDef) -> BoonState:
	var state := BoonState.new(catalog)
	state.ult_open = true
	state.hero_tags = _hero_tags(hero)
	var guard := 0
	while not state.needs_met(b) and guard < 20:
		guard += 1
		for need in b.needs_all:
			if state.has_cap(need):
				continue
			var source := _source_of(need, b.family)
			assert_not_null(source, "%s asks %s: nothing grants it" % [b.id, need])
			if source != null:
				state.take(source)
	return state


func _source_of(need: String, family: Boon.Family) -> Boon:
	var best: Boon = null
	for c in _active():
		if c.id == StringName(need) or c.grants.has(need) or (need.begins_with("fam:") and String(c.family_tag()) == need.substr(4) and c.slot != Boon.Slot.NONE):
			if best == null or (c.family == family and best.family != family) or (c.slot != Boon.Slot.NONE and best.slot == Boon.Slot.NONE and c.family == family):
				best = c
	return best


func test_seven_families_of_nine_63_ids_35_principals_28_complements() -> void:
	var active := _active().filter(func(b: Boon) -> bool: return not b.is_duo())
	assert_eq(active.size(), 63)
	var seen := {}
	var principals := 0
	var complements := 0
	for b in active:
		assert_false(seen.has(b.id), "duplicate %s" % b.id)
		seen[b.id] = true
		if b.slot == Boon.Slot.NONE:
			complements += 1
		else:
			principals += 1
	assert_eq(principals, 35)
	assert_eq(complements, 28)
	for f in FAMILIES:
		var mine := active.filter(func(b: Boon) -> bool: return b.family == f)
		assert_eq(mine.size(), 9, "family %d" % f)
		var slots := {}
		for b in mine:
			if b.slot != Boon.Slot.NONE:
				assert_false(slots.has(b.slot), "two principals of one slot in family %d" % f)
				slots[b.slot] = true
		assert_eq(slots.keys().size(), 5, "family %d: attack, special, Brado, dodge and ultimate" % f)
		assert_false(slots.has(Boon.Slot.RUSH), "E has no Blessing of its own in V1")


func test_nothing_of_the_old_catalog_is_in_the_draw() -> void:
	for b in catalog:
		if b.is_duo():
			assert_true(b.reserve, "an Elo in the draw: %s" % b.id)
		if b.slot == Boon.Slot.RUSH:
			assert_true(b.reserve, "a Blessing of the Investida in the draw: %s" % b.id)
	var state := BoonState.new(catalog)
	state.ult_open = true
	for b in catalog:
		if b.reserve:
			assert_false(state.offerable(b), "%s is in the reserve and still offerable" % b.id)


func test_the_table_of_the_document_is_the_catalog() -> void:
	var file := FileAccess.open("res://docs/design/bencaos_v1/BALANCEAMENTO.csv", FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return
	file.get_line()
	var names := {}
	var rows := 0
	while not file.eof_reached():
		var parts := file.get_csv_line(";")
		if parts.size() < 6:
			continue
		rows += 1
		names[parts[2].strip_edges()] = parts[1]
	assert_eq(rows, 63)
	var mine := {}
	for b in _active():
		if not b.is_duo():
			mine[T.t("boon_%s" % b.id)] = true
	for n: String in names:
		assert_true(mine.has(n), "'%s' of the table has no Blessing of that name" % n)
	assert_eq(mine.size(), 63)


func test_every_power_has_text_icon_and_something_to_do() -> void:
	for b in _active():
		assert_ne(T.t("boon_%s" % b.id), "boon_%s" % b.id, "name of %s" % b.id)
		assert_true(b.mods.size() > 0 or b.skill != null, "%s does nothing" % b.id)
		assert_lt(b.icon, 23, String(b.id))
		for lv in range(1, b.max_level + 1):
			var desc := BoonChoice.describe(b, lv)
			assert_false(desc.contains("{"), "%s level %d: %s" % [b.id, lv, desc])
			assert_false(desc.contains("—") or desc.contains("–"), String(b.id))
		for cap in b.needs_all:
			assert_false(BoonNeeds.cap_name(cap).begins_with("boon_"), "%s asks '%s', which has no name" % [b.id, cap])


## The headline of the aceite: 63 powers on both heroes: eligible when it should be, taken, and read.
func test_every_power_is_eligible_taken_and_reads_for_both_heroes() -> void:
	for hero in [HeroDef.warrior(), HeroDef.maga()]:
		var tags := _hero_tags(hero)
		for b in _active():
			if b.is_duo():
				continue
			var label := "%s / %s" % [hero.id, b.id]
			var state := _state_with_requirements(b, hero)
			assert_true(state.offerable(b), "%s: not offerable with what it asks held" % label)
			if b.slot != Boon.Slot.NONE:
				var need: StringName = SLOT_NEEDS[b.slot]
				assert_true(need == &"" or tags.has(need), "%s: the hero has no %s move" % [label, need])
			var fresh := BoonState.new(catalog)
			fresh.ult_open = true
			fresh.hero_tags = tags
			if not b.needs_all.is_empty():
				assert_false(fresh.offerable(b), "%s: offered with nothing of what it asks" % label)
			assert_gt(state.take(b), 0, "%s: not taken" % label)
			assert_eq(state.level(b.id), 1)
			var rng := RandomNumberGenerator.new()
			rng.seed = 3
			for c in state.draw(rng, 3):
				assert_ne(c.boon.id, b.id, "%s: held and drawn again" % label)
			# its effect is in the numbers: a slot's mod is read by slot, a complement's by stat
			for m in b.mods:
				var read := state.slot_stat(m.stat, b.slot) if b.slot != Boon.Slot.NONE else state.stat(m.stat)
				assert_almost_eq(read, m.base, 0.0001, "%s: %s not read" % [label, m.stat])


func test_every_rarity_scales_only_what_the_rules_allow() -> void:
	for b in _active():
		if b.is_duo():
			continue
		for m in b.mods:
			for r in Boon.RARITY_MULT.size():
				var mult := Boon.RARITY_MULT[r]
				if SCALES.has(m.stat):
					assert_almost_eq(m.at(1, mult), m.base * mult, 0.0001, "%s %s rarity %d" % [b.id, m.stat, r])
				else:
					assert_almost_eq(m.at(1, mult), m.base, 0.0001, "%s %s must stay fixed on rarity %d" % [b.id, m.stat, r])
		if b.skill != null:
			assert_almost_eq(b.skill.damage_at(1, 2.0), b.skill.damage[0] * 2.0, 0.0001, "%s skill damage scales" % b.id)


func test_the_numbers_of_the_document_are_the_numbers_in_play() -> void:
	var state := BoonState.new(catalog)
	var want := {&"golpe_brasa": [&"cel_burn_dps", 3.5], &"pesado_brasa": [&"cel_burn_dps", 5.0], &"golpe_geada": [&"cel_cold", 1.0],
		&"toque_geada": [&"cel_cold", 2.0], &"golpe_radiante": [&"cel_crit", 0.10], &"circulo_radiante": [&"cel_crit", 0.15],
		&"golpe_firme": [&"cel_impact", 1.0], &"pesado_firme": [&"cel_impact", 2.0], &"golpe_veu": [&"cel_weak", 2.0],
		&"pesado_veu": [&"cel_weak", 3.0], &"golpe_mare": [&"cel_speed", 0.12], &"circulo_mare": [&"cel_cd_cut", 0.10],
		&"golpe_marca": [&"cel_mark", 3.0], &"pesado_marca": [&"cel_echo", 0.40], &"circulo_marca": [&"cel_echo", 0.35],
		&"combustao": [&"cel_combust_dmg", 9.0], &"fogo_crescente": [&"cel_burn_dps_pct", 0.2], &"estilhaco": [&"cel_shatter_pct", 0.4],
		&"fortuna_celestial": [&"cel_crit_global", 0.05], &"esplendor": [&"cel_crit_mult_global", 0.2], &"prosperidade": [&"gold_pct", 0.1],
		&"vulnerabilidade": [&"cel_weak_dmg_pct", 0.15], &"forca_inabalavel": [&"cel_stunned_dmg_pct", 0.3], &"ruptura": [&"cel_impact_need", -1.0],
		&"cadencia": [&"cel_cadence", 0.03], &"turbilhao": [&"cel_whirl_dmg", 18.0], &"brisa_favoravel": [&"move_speed_pct", 0.05],
		&"passos_leves": [&"dodge_charges", 1.0], &"passo_brasa": [&"dodge_ember_dps", 6.0], &"passo_firme": [&"cel_guard_time", 1.2]}
	for id: StringName in want:
		var b := state.find(id)
		assert_not_null(b, String(id))
		assert_eq(b.mods[0].stat, want[id][0], String(id))
		assert_almost_eq(b.mods[0].base, float(want[id][1]), 0.0001, String(id))
	# the skills of the buttons
	var rain := state.find(&"chuva_brasas").skill
	_eq([rain.get_count(1), rain.damage[0], rain.get_radius(1)], [8, 20.0, 2.2])
	var zone := state.find(&"circulo_brasa").skill
	_eq([zone.damage[0], zone.get_duration(1), zone.get_radius(1), zone.get_gap(1)], [6.0, 3.0, 2.5, 4.0])
	var glacial := state.find(&"circulo_geada").skill
	_eq([glacial.get_status_power(1), glacial.get_radius(1), glacial.get_gap(1)], [2.0, 3.0, 4.0])
	var winter := state.find(&"peso_inverno").skill
	_eq([winter.damage[0], winter.get_radius(1), winter.get_status_power(1)], [55.0, 4.0, 3.0])
	var judge := state.find(&"ultimo_radiante").skill
	_eq([judge.get_count(1), judge.damage[0], judge.get_status_power(1)], [3, 24.0, 0.15])
	var quake := state.find(&"ultimo_firme").skill
	_eq([quake.damage[0], quake.get_radius(1), quake.get_status_power(1)], [45.0, 6.0, 3.0])
	var power := state.find(&"circulo_firme").skill
	_eq([power.damage[0], power.get_status_power(1), power.get_radius(1), power.get_gap(1)], [14.0, 2.0, 3.0, 4.0])
	_eq([state.find(&"fios_cinza").skill.get_radius(1), state.find(&"fios_cinza").skill.get_gap(1), state.find(&"fios_cinza").skill.get_status_power(1)], [2.0, 3.0, 2.0])
	_eq([state.find(&"crepusculo").skill.get_radius(1), state.find(&"crepusculo").skill.get_status_power(1)], [7.0, 5.0])
	_eq([state.find(&"circulo_veu").skill.get_radius(1), state.find(&"circulo_veu").skill.get_status_power(1)], [3.0, 4.0])
	var gust := state.find(&"pesado_mare").skill
	_eq([gust.damage[0], gust.get_gap(1)], [14.0, 1.0])
	var flakes := state.find(&"floco_errante").skill
	_eq([flakes.get_count(1), flakes.get_duration(1), flakes.get_status_power(1), flakes.status_gap], [2, 3.0, 1.0, 1.0])
	var storm := state.find(&"vendaval")
	_eq([storm.mods[0].base, storm.mods[1].base, storm.mods[2].base], [0.3, 0.1, 5.0])
	var army := state.find(&"exercito_ecos")
	_eq([army.mods[0].base, army.mods[1].base], [0.4, 5.0])
	assert_eq(state.find(&"pesado_radiante").mods[1].base, 0.25)
	assert_eq(state.find(&"olhar_rapido").mods[0].base, 3.0)
	assert_eq(state.find(&"olhar_rapido").mods[1].base, 3.0)


## Arrays of numbers the data keeps in 32 bits: equal to the spec's within a thousandth.
func _eq(got: Array, want: Array) -> void:
	assert_eq(got.size(), want.size())
	for i in mini(got.size(), want.size()):
		assert_almost_eq(float(got[i]), float(want[i]), 0.001, "number %d of %s" % [i, str(want)])
