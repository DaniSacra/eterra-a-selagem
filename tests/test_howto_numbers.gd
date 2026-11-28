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
	_says(&"howto_heavy_attack_desc", "%d de Magia" % int(lance.magick_cost))
	# 2026-11-27: the Corte Circular is free ("0 de Magia" would also match "20 de Magia"); every text must say so.
	assert_eq(sweep.magick_cost, 0.0)
	_says(&"howto_heavy_attack_desc", "não gasta Magia")
	_says(&"hero_skill_cast", "sem gastar Magia")
	_says(&"lesson_power", "sem gastar Magia")
	_says(&"hero_skill_special", "%d de Magia" % int(lance.magick_cost))


func test_the_left_button() -> void:
	var smash := _node(&"smash")
	_says(&"howto_light_attack_desc", "%d de dano" % int(smash.damage))
	_says(&"howto_light_attack_desc", "%d de Magia" % int(smash.magick_cost))
