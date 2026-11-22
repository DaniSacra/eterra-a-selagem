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


func test_the_special() -> void:
	var n := _node(&"bolt")
	assert_not_null(n)
	_says(&"howto_heavy_attack_desc", "%d de dano" % int(n.effect_power))
	_says(&"howto_heavy_attack_desc", "%d de Magia" % int(n.magick_cost))
	_says(&"hero_skill_special", "%d de Magia" % int(n.magick_cost))
	_says(&"title_controls", "%d de Magia" % int(n.magick_cost))


func test_the_rush_and_the_shout() -> void:
	var r := _node(&"dash_cut")
	_says(&"howto_rush_desc", "estocada de %d" % int(r.damage))
	_says(&"howto_rush_desc", "devolve %d de Magia" % int(r.magick_per_hit))
	_says(&"howto_rush_desc", "%d segundos" % int(r.cooldown))
	var s := _node(&"shout")
	_says(&"howto_shout_desc", "fere %d" % int(s.damage))
	_says(&"howto_shout_desc", "%d%% mais rápidos" % roundi(s.buff_speed * 100.0))
	_says(&"howto_shout_desc", "%d%% menos dano" % roundi(s.buff_guard * 100.0))
	_says(&"howto_shout_desc", "%d segundos" % int(s.cooldown))
