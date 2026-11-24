extends GutTest
## UI-1 and UI-2 of the hero redesign (docs/design/heroes/redesign_2026-11-24/04_PLANO.md A.6, E): the player says
## "Golpe Carregado", never "Ômega"; a hero with a Supremo fixed by the weapon has no ULT nodes in the medallion.


func test_the_player_never_reads_omega() -> void:
	var file := FileAccess.get_file_as_string("res://data/text_pt.tres")
	assert_false(file.to_lower().contains("ômega"), "text_pt.tres has no Ômega")
	assert_eq(T.t(&"gloss_omega"), "Golpe Carregado")
	assert_true(Glossary.terms_of("Os Golpes Carregados congelam.").has(&"omega"))
	assert_true(Glossary.terms_of("Um golpe carregado em brasa").has(&"omega"))
	assert_false(Glossary.terms_of("Um golpe qualquer").has(&"omega"))
	assert_eq(T.t(&"boon_omega_geada"), "Golpe Carregado de Gelo")


func test_new_branch_and_vine_names_exist() -> void:
	for k in [&"hero_branch_impeto", &"hero_branch_dominio", &"hero_branch_elementalismo", &"hero_branch_conjuracao",
			&"hero_branch_feiticaria", &"vine_respiro", &"vine_respiro_desc", &"vine_ainda_de_pe", &"vine_ainda_de_pe_desc"]:
		assert_ne(T.t(k), String(k), "%s has a text" % k)


func test_the_medallion_keeps_ult_nodes_only_when_the_supremo_is_not_fixed() -> void:
	var hero := HeroDef.warrior()
	var def := MedallionDef.of("warrior")
	var shown := MedallionView.without_ults(def, hero)
	var ults := 0
	for n in shown.nodes:
		if n.kind == MedallionNodeDef.Kind.ULT:
			ults += 1
	if MedallionView.has_fixed_ult(hero):
		assert_eq(ults, 0, "a fixed Supremo has no node to choose")
		assert_lt(shown.nodes.size(), def.nodes.size())
		assert_not_null(MedallionView.weapon_ult(hero), "the Livro shows it")
	else:
		assert_same(shown, def, "without ult_for_weapon the medallion is as it was")
		assert_null(MedallionView.weapon_ult(hero))
