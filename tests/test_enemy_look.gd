extends GutTest
## The first region's enemies after Daniel's sheet (docs/art/enemies_phase1.md): each one drawn by its own baked
## model, the elites by the gilded palette of the same figure, sizes in the sheet's order, magic in its colours.

const DIR := "res://data/enemies/"
## The sheet's scale, the soldier at 1.15 (docs/art/enemies_phase1.md).
const SHEET_SIZE := {
	&"skeleton": 1.15, &"runner": 1.04, &"mage": 1.27, &"archer": 1.27, &"guard": 1.5, &"priest": 1.3,
	&"knight": 2.07, &"priest_elder": 2.19, &"morvath": 2.53,
}


func _defs() -> Array[EnemyDef]:
	var out: Array[EnemyDef] = []
	for f in DirAccess.get_files_at(DIR):
		if f.ends_with(".tres"):
			out.append(load(DIR + f) as EnemyDef)
	return out


func test_every_enemy_has_its_baked_model() -> void:
	for d in _defs():
		assert_true(ResourceLoader.exists("res://assets/baked/%s.res" % d.model), "%s draws %s" % [d.id, d.model])


func test_each_enemy_of_the_sheet_has_a_figure_of_its_own() -> void:
	var models := {}
	for id: StringName in SHEET_SIZE:
		var d: EnemyDef = load(DIR + "%s.tres" % id)
		assert_false(models.has(d.model), "%s shares its model %s" % [id, d.model])
		models[d.model] = true


func test_sizes_follow_the_sheet() -> void:
	for id: StringName in SHEET_SIZE:
		var d: EnemyDef = load(DIR + "%s.tres" % id)
		assert_almost_eq(d.size, float(SHEET_SIZE[id]), 0.001, String(id))
		if d.elite_version != &"":
			assert_almost_eq((load(DIR + "%s.tres" % d.elite_version) as EnemyDef).size, d.size, 0.001, "the elite is as big")


func test_elites_wear_the_gilded_palette_of_the_same_figure() -> void:
	for d in _defs():
		if d.elite_version == &"":
			continue
		var e: EnemyDef = load(DIR + "%s.tres" % d.elite_version)
		assert_eq(e.model, d.model, "the elite of %s is the same figure" % d.id)
		assert_not_null(e.palette, "the elite of %s has its gilded palette" % d.id)
		assert_true(e.armor > 0.0, "the elite of %s keeps its armor bar" % d.id)


func test_magic_colours() -> void:
	var mage: EnemyDef = load(DIR + "mage.tres")
	var priest: EnemyDef = load(DIR + "priest.tres")
	var archer: EnemyDef = load(DIR + "archer.tres")
	# the sorcerer's violet: purple, colder and lighter than the priests' (Daniel, 2026-11-14), never green
	assert_true(mage.magic_color.b > mage.magic_color.r and mage.magic_color.b > mage.magic_color.g)
	assert_true(mage.magic_color.g > priest.magic_color.g, "the sorcerer's violet is lighter and colder")
	assert_true(priest.magic_color.b > priest.magic_color.g and priest.magic_color.r > priest.magic_color.g)
	assert_true(archer.magic_color.r > archer.magic_color.g and archer.magic_color.g > archer.magic_color.b, "orange bolts")
