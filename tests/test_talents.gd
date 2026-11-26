extends GutTest
## The Warrior's tree of Gifts after the redesign of 2026-11-24 (TalentDef, Talents; 04_PLANO A.1, B.1): three branches of four,
## the unlock order, Devotion, requirements (`needs`) that count only when equipped, and the plain-number Gifts summed with
## the Blessings in BoonState.stat. The shape and the numbers of each Gift: test_warrior_talents.gd.

const B := TalentDef.Branch
const TIER := TalentDef.Tier
const TOP := 20

var book: Talents
var hero: HeroDef


func before_all() -> void:
	hero = HeroDef.warrior()
	book = hero.talents()


func _check(ids: Array, level: int = TOP, devotion: int = 99) -> Talents.Problem:
	return book.check(ids, level, devotion).problem


func test_the_tree_is_three_branches_of_four() -> void:
	assert_eq(book.catalog.size(), 12)
	for branch in [B.COMBO, B.IMPETO, B.DOMINIO]:
		assert_eq(book.catalog.filter(func(t: TalentDef) -> bool: return t.branch == branch).size(), 4)
	for t in book.catalog:
		assert_between(t.cost, 1, 5, "%s costs 1 to 5" % t.id)
		assert_ne(T.t(t.name_key), String(t.name_key), "%s has its name" % t.id)
		assert_ne(T.t(t.desc_key), String(t.desc_key), "%s has its text" % t.id)
		assert_false(T.t(t.desc_key).contains("—"), "no em dash")


func test_the_first_gifts_and_the_unlock_order() -> void:
	var first := {&"disciplina": [1, 2], &"forca_concentrada": [2, 2], &"ruptura": [3, 2], &"cadencia": [4, 2],
		&"determinacao": [6, 2], &"alcance_marcial": [8, 3], &"maestria_marcial": [9, 3]}
	for id: StringName in first:
		var t := book.find(id)
		assert_eq(t.unlock_level, first[id][0], "%s unlocks at %d" % [id, first[id][0]])
		assert_eq(t.cost, first[id][1], "%s costs %d" % [id, first[id][1]])
	assert_eq(hero.ultimate(&"cleave").mastery_level, 3)
	assert_eq(book.unlocked(TOP).size(), book.catalog.size(), "everything by level 20")
	assert_eq(book.unlocked(1).map(func(t: TalentDef) -> StringName: return t.id), [&"disciplina"])
	for t in book.catalog:
		if t.tier == TIER.APEX:
			assert_gte(t.unlock_level, 16, "%s is late" % t.id)


func test_devotion_bounds_the_loadout() -> void:
	var curve := hero.mastery
	assert_eq(book.cost([&"disciplina", &"forca_concentrada"]), 4)
	assert_eq(_check([&"disciplina", &"forca_concentrada"], 3, curve.devotion(3)), Talents.Problem.OK)
	assert_eq(book.cost([&"disciplina", &"forca_concentrada", &"ruptura"]), 6)
	assert_eq(_check([&"disciplina", &"forca_concentrada", &"ruptura"], 3, 5), Talents.Problem.DEVOTION, "6 of 5")
	assert_eq(_check([&"disciplina", &"forca_concentrada", &"ruptura"], 3, curve.devotion(3)), Talents.Problem.OK)


func test_locked_unknown_twice() -> void:
	assert_eq(_check([&"forca_concentrada"], 1), Talents.Problem.LOCKED)
	assert_eq(_check([&"forca_concentrada"], 2), Talents.Problem.OK)
	assert_eq(_check([&"nope"]), Talents.Problem.UNKNOWN)
	assert_eq(_check([&"ruptura", &"ruptura"]), Talents.Problem.TWICE)
	assert_eq(_check([]), Talents.Problem.OK, "nothing equipped is valid")


func test_a_requirement_counts_only_when_equipped() -> void:
	# unlocked (level 20) but not equipped: the Gift cannot stand without the one it needs
	assert_eq(_check([&"cadencia"]), Talents.Problem.NEEDS)
	assert_eq(_check([&"disciplina", &"cadencia"]), Talents.Problem.OK)
	assert_eq(book.check([&"cadencia"], TOP, 99).id, &"cadencia", "names the Gift")
	assert_eq(_check([&"alcance_marcial"]), Talents.Problem.NEEDS)
	assert_eq(_check([&"alcance_marcial", &"ruptura"]), Talents.Problem.OK, "order does not matter")


func test_an_apex_needs_the_gift_the_package_names() -> void:
	assert_eq(_check([&"disciplina", &"apogeu"]), Talents.Problem.NEEDS, "no Maestria Marcial")
	assert_eq(_check([&"disciplina", &"maestria_marcial", &"apogeu"]), Talents.Problem.OK)
	assert_eq(_check([&"forca_concentrada", &"forca_titanica"]), Talents.Problem.OK, "straight from the entry")
	assert_eq(_check([&"forca_titanica"]), Talents.Problem.NEEDS)
	assert_eq(_check([&"ruptura", &"investida_implacavel"]), Talents.Problem.NEEDS, "it asks for Imposição")
	assert_eq(_check([&"ruptura", &"imposicao", &"investida_implacavel"]), Talents.Problem.OK)


func test_no_gift_takes_a_button_so_they_stack() -> void:
	var all: Array = book.catalog.map(func(t: TalentDef) -> StringName: return t.id)
	assert_eq(_check(all), Talents.Problem.OK, "all twelve fit the 5 + Mastery 20 Vagas of Devotion")


func test_a_saved_loadout_is_cleaned() -> void:
	# a Gift that does not exist, one locked, one whose need went with it, one over the Devotion
	var clean := book.sanitized([&"disciplina", &"nope", &"cadencia", &"forca_concentrada"], 3, 8)
	assert_eq(clean, [&"disciplina", &"forca_concentrada"] as Array[StringName], "cadencia is locked at 3")
	assert_eq(book.sanitized([&"cadencia"], TOP, 99), [] as Array[StringName], "a Gift without what it needs goes")
	assert_eq(book.sanitized([&"disciplina", &"cadencia"], TOP, 99), [&"disciplina", &"cadencia"] as Array[StringName])
	assert_eq(book.sanitized([&"disciplina", &"forca_concentrada", &"ruptura"], 3, 5), [&"disciplina", &"forca_concentrada"] as Array[StringName], "over the Devotion")


func test_number_gifts_add_up_with_the_blessings() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	var light: Array[StringName] = [&"light"]
	var shout: Array[StringName] = [&"cast"]
	assert_eq(state.stat(&"reach_pct", shout), 0.0)
	state.equip_talents(book.defs([&"ruptura", &"alcance_marcial"]))
	assert_almost_eq(state.stat(&"reach_pct", shout), 0.25, 0.0001, "Alcance Marcial: the Corte Circular reaches 25% more")
	assert_eq(state.stat(&"reach_pct", light), 0.0, "only the Poder")
	# another source of the same number adds up (V1: no Blessing carries reach; the Forja, an Encanto or a granted bonus do)
	var more := BoonMod.new()
	more.stat = &"reach_pct"
	more.tag = &"light"
	more.base = 0.1
	state.grant([more])
	assert_almost_eq(state.stat(&"reach_pct", light), 0.1, 0.0001, "Gift and another source in one sum")
	assert_almost_eq(state.stat(&"reach_pct", shout), 0.25, 0.0001, "the other tag is untouched")
	state.equip_talents([])
	assert_eq(state.stat(&"reach_pct", shout), 0.0, "the cache follows what is equipped")
