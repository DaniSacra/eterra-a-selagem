extends GutTest
## GE-1 of the heroes redesign (04_PLANO A.4): the pure migration, not yet switched on in SaveData.merged.


func _save_with(hero: String, opened: Array, equipped: Array) -> Dictionary:
	var d := SaveData.defaults()
	var b: Dictionary = d.heroes[hero] if d.heroes.has(hero) else SaveData.hero_defaults()
	b["opened"] = opened
	b["unlocked"] = opened.duplicate()
	b["equipped"] = equipped
	b["ultimate"] = "vortex"
	b["mastery_xp"] = 777
	d.heroes[hero] = b
	return d


func test_legacy_tables_sum_to_the_plan() -> void:
	var sums := {}
	for hero: String in SaveData.LEGACY_DONS:
		var t := 0
		for id: String in SaveData.LEGACY_DONS[hero]:
			t += int(SaveData.LEGACY_DONS[hero][id])
		sums[hero] = t
	assert_eq(sums.warrior, 60)
	assert_eq(sums.maga, 61)


func test_legacy_tables_match_the_catalogs_still_on_disk() -> void:
	# the catalogs are the old ones until GE-3 and GE-4: the frozen table must agree with them now
	for hero: HeroDef in [HeroDef.warrior(), HeroDef.maga()]:
		var table: Dictionary = SaveData.LEGACY_DONS[String(hero.id)]
		for t in Talents.load_catalog(hero.talents_dir):
			assert_eq(int(table.get(String(t.id), -1)), t.memory_cost, "%s %s" % [hero.id, t.id])


func test_refund_frees_slots_and_keeps_the_rest() -> void:
	var d := _save_with("warrior", ["quarto_corte", "furia_plena", "ainda_de_pe"], ["furia_plena", "ainda_de_pe"])
	var before := MaterialPurse.amount(d, MaterialPurse.MEMORY)
	var total_before: Variant = (d.materials_total as Dictionary).duplicate()
	var given := SaveData.migrate_redesign(d)
	assert_eq(given.warrior, 9)
	assert_eq(MaterialPurse.amount(d, MaterialPurse.MEMORY) - before, 9)
	var b: Dictionary = d.heroes.warrior
	assert_eq(b.opened, [])
	assert_eq(b.unlocked, [])
	assert_eq(b.equipped, [])
	assert_eq(b.ultimate, "")
	assert_eq(b.mastery_xp, 777, "Mastery is not touched")
	assert_eq(d.materials_total, total_before, "a refund is not brought home")


func test_two_runs_give_back_once() -> void:
	var d := _save_with("warrior", ["golpe_sem_fim", "reserva"], ["reserva"])
	var m0 := MaterialPurse.amount(d, MaterialPurse.MEMORY)
	SaveData.migrate_redesign(d)
	var m1 := MaterialPurse.amount(d, MaterialPurse.MEMORY)
	var again := SaveData.migrate_redesign(d)
	assert_eq(m1 - m0, 7)
	assert_eq(again.warrior, 0)
	assert_eq(MaterialPurse.amount(d, MaterialPurse.MEMORY), m1)


func test_everything_opened_gives_the_maximum() -> void:
	for hero in ["warrior", "maga"]:
		var ids: Array = SaveData.LEGACY_DONS[hero].keys()
		var d := _save_with(hero, ids, [])
		var given := SaveData.migrate_redesign(d)
		assert_eq(given[hero], 60 if hero == "warrior" else 61)


func test_a_save_without_gifts_or_heroes_is_safe() -> void:
	var d := SaveData.defaults()
	var m := MaterialPurse.amount(d, MaterialPurse.MEMORY)
	assert_eq(SaveData.migrate_redesign(d).warrior, 0)
	assert_eq(MaterialPurse.amount(d, MaterialPurse.MEMORY), m)
	assert_true(SaveData.migrate_redesign({}).is_empty())


func test_not_switched_on_yet() -> void:
	assert_lt(SaveData.VERSION, 13, "GE-3 turns the v13 migration on together with the new catalogs")
