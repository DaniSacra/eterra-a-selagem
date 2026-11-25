extends GutTest
## A number and its unit never split across lines (the space becomes a no-break space).

func test_unit_glued_to_number() -> void:
	assert_eq(TextTable.glue_units("congela por 0,8 s."), "congela por 0,8 s.")
	assert_eq(TextTable.glue_units("a cada {cd} s, algo"), "a cada {cd} s, algo")
	assert_eq(TextTable.glue_units("alcance 12 m"), "alcance 12 m")

func test_words_are_left_alone() -> void:
	assert_eq(TextTable.glue_units("10 sentinelas e 2 mortos"), "10 sentinelas e 2 mortos")
	assert_eq(TextTable.glue_units("a Sala 5 de 14"), "a Sala 5 de 14")

func test_t_goes_through_it() -> void:
	assert_eq(T.t(&"boon_passo_frio_desc", {"a": "1,5"}), "A Investida congela por 1,5 s.")
