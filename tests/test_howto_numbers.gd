extends GutTest
## BH-1 to BH-3 (2026-11-22): the numbers the Como Jogar and the hero's page say are the data's (they had been left behind
## by two changes of the kit).

var tree: ComboTree


func before_all() -> void:
	tree = load(HeroDef.warrior().combos)


func _node(id: StringName) -> ComboNode:
	for n in tree.all_nodes():
		if n.id == id:
			return n
	return null


func _says(key: StringName, number: String) -> void:
	assert_string_contains(T.t(key), number, String(key))


func test_the_right_button() -> void:
	var lance := _node(&"lance")
	var sweep := _node(&"sweep")
	assert_not_null(lance)
	assert_not_null(sweep)
	_says(&"howto_heavy_attack_desc", "%d de dano" % int(lance.damage))
	_says(&"howto_heavy_attack_desc", "%d de dano" % int(sweep.damage))
	assert_eq([lance.magick_cost, sweep.magick_cost], [0.0, 0.0], "no cost to say")
	assert_false(T.t(&"howto_heavy_attack_desc").contains("de Magia"), "the card names no price")
	assert_false(T.t(&"hero_skill_special").contains("de Magia"))


func test_the_left_button() -> void:
	var smash := _node(&"smash")
	_says(&"howto_light_attack_desc", "%d de dano" % int(smash.damage))
	assert_eq(smash.magick_cost, 0.0)
	assert_false(T.t(&"howto_light_attack_desc").contains("de Magia"))
