extends GutTest
## The heroes redesign's save migration (04_PLANO A.4): the pure step, and since GE-3 switched on in SaveData.merged for the
## Warrior (version 13) and for the Maga (version 14, GE-4).


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


func test_no_new_gift_reuses_a_legacy_id() -> void:
	for hero: HeroDef in [HeroDef.maga(), HeroDef.warrior()]:
		var table: Dictionary = SaveData.LEGACY_DONS[String(hero.id)]
		for t in Talents.load_catalog(hero.talents_dir):
			assert_false(table.has(String(t.id)), "%s %s" % [hero.id, t.id])


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


func test_the_file_of_version_12_is_migrated_for_both_heroes() -> void:
	var old := _save_with("warrior", SaveData.LEGACY_DONS.warrior.keys(), ["furia_plena", "reserva"])
	old.version = 12
	var maga: Dictionary = SaveData.hero_defaults()
	maga["opened"] = SaveData.LEGACY_DONS.maga.keys()
	maga["equipped"] = ["combustao"]
	maga["ultimate"] = "storm"
	maga["mastery_xp"] = 55
	old.heroes["maga"] = maga
	var m0 := MaterialPurse.amount(old, MaterialPurse.MEMORY)
	var out := SaveData.merged(old)
	assert_eq(out.version, SaveData.VERSION)
	assert_eq(SaveData.VERSION, 15)
	assert_eq(MaterialPurse.amount(out, MaterialPurse.MEMORY) - m0, 121, "60 and 61 Memória back")
	assert_eq(out.heroes.warrior.opened, [])
	assert_eq(out.heroes.warrior.equipped, [], "the Vagas are free")
	assert_eq(out.heroes.warrior.mastery_xp, 777)
	assert_eq(out.heroes.maga.opened, [])
	assert_eq(out.heroes.maga.equipped, [])
	assert_eq(out.heroes.maga.ultimate, "")
	assert_eq(out.heroes.maga.mastery_xp, 55)
	var again := SaveData.merged(out)
	assert_eq(MaterialPurse.amount(again, MaterialPurse.MEMORY), MaterialPurse.amount(out, MaterialPurse.MEMORY), "idempotent")


func test_the_file_of_version_13_is_migrated_for_the_maga_only() -> void:
	var old := _save_with("warrior", ["disciplina"], ["disciplina"])
	old.version = 13
	var maga: Dictionary = SaveData.hero_defaults()
	maga["opened"] = SaveData.LEGACY_DONS.maga.keys()
	maga["equipped"] = ["combustao"]
	old.heroes["maga"] = maga
	var m0 := MaterialPurse.amount(old, MaterialPurse.MEMORY)
	var out := SaveData.merged(old)
	assert_eq(MaterialPurse.amount(out, MaterialPurse.MEMORY) - m0, 61, "the Maga gets her 61 back")
	assert_eq(out.heroes.maga.equipped, [])
	assert_eq(out.heroes.warrior.opened, ["disciplina"], "the Warrior is not touched again")
	var twice := SaveData.migrate_redesign(out)
	assert_eq(twice.maga, 0)


func test_a_current_save_is_not_touched() -> void:
	var d := _save_with("warrior", ["disciplina"], ["disciplina"])
	d.version = SaveData.VERSION
	var out := SaveData.merged(d)
	assert_eq(out.heroes.warrior.opened, ["disciplina"])
	assert_eq(out.heroes.warrior.equipped, ["disciplina"])
