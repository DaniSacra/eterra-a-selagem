extends GutTest
## HV-E: the Santuário grows with the save (HubEvolution). Each state of the save gives the right picture, nothing
## lights on a first death, a piece whose feature is off stays hidden, and the hub paints it (HubEvolution.apply).

var od: OficiosDef


func before_each() -> void:
	od = OficiosDef.live()


func _fresh() -> Dictionary:
	return SaveData.defaults()


## What one lost descent leaves in a save (the game's own writes: Maestria, Compêndio, materials, the first tool at a
## guardian won, the vein noted): nothing of it is bought, opened, delivered or sealed.
func _first_death() -> Dictionary:
	var d := _fresh()
	var hero := SaveData.hero(d, SaveData.FIRST_HERO)
	hero.mastery_xp = 190
	Forge.add_tool(d, Forge.TOOL_REFINE)
	MaterialPurse.give(d, &"silver", 26)
	MaterialPurse.give(d, &"memory", 5)
	for id in ["brasas", "toque_geada", "vapor", "aurora", "escudo", "onda_maior", "redemoinho"]:
		SaveData.codex_add(d, "boons", id, "seen")
	for id in ["skeleton", "runner", "mage", "archer", "guard", "knight"]:
		SaveData.codex_add(d, "enemies", id, "defeated")
	SaveData.codex_max(d, "enemies", "morvath", "phase", 3)
	SaveData.codex_add(d, "enemies", "morvath", "met")
	for id in ["hall", "crypt", "rift", "garden", "sanctuary"]:
		SaveData.codex_add(d, "arenas", id, "entered")
	(Oficios.block(d).seen as Array).append(Oficios.VEIN)
	return d


func test_a_new_save_shows_the_bare_hub() -> void:
	var s := HubEvolution.of(_fresh(), Hub.codex_chapters(_fresh()))
	assert_false(s.grown(), "nothing grown")
	assert_eq(s.forge_rank, 0)
	assert_eq(s.forge_tools.size(), 0)
	assert_eq(s.vendor, HubEvolution.Stall.CLOSED, "the stall closed (cloth over the goods)")
	assert_eq(s.tree_lit, 0)
	assert_eq(s.tree_total, 18, "a plate for each Gift bought with Memória")
	assert_eq(s.book_spines, 0)
	assert_true(s.shelf, "the Ofícios shelf stands (the mechanic exists)")
	assert_eq(s.shelf_items, 0, "and is empty")
	assert_true(s.alchemist_shown, "the Alquimista's bench stands")
	assert_false(s.alchemist_stocked, "empty")


func test_nothing_lights_on_a_first_death() -> void:
	var d := _first_death()
	var s := HubEvolution.of(d, Hub.codex_chapters(d))
	assert_false(s.grown(), "a first death never changes the hub")
	assert_true(s.mastery > 1, "though the Maestria rose (%d)" % s.mastery)
	assert_eq(s.forge_tools.size(), 0, "a tool found but never used is not hung up")
	assert_eq(s.book_spines, 0, "no Compêndio chapter near whole after one descent")


func test_e1_the_forge_by_its_rank_and_tools() -> void:
	var d := _fresh()
	Forge.block(d).temper = 2
	assert_eq(HubEvolution.of(d).forge_rank, 2)
	Forge.add_tool(d, Forge.TOOL_REFINE)
	assert_eq(HubEvolution.of(d).forge_tools.size(), 0, "found, never used")
	(Forge.block(d).refined as Array).append("refine_fio")
	assert_eq(HubEvolution.of(d).forge_tools, [Forge.TOOL_REFINE] as Array[StringName], "used: hung up")
	(Oficios.block(d).tools as Array).append(String(od.tool))
	var s := HubEvolution.of(d)
	assert_true(s.forge_tools.has(od.tool), "the Picareta restored")
	assert_eq(s.shelf_items, 1, "and on the Ofícios shelf")
	assert_true(s.grown())


func test_e2_the_vendor_closed_then_an_order_then_open() -> void:
	var d := _fresh()
	assert_eq(HubEvolution.of(d).vendor, HubEvolution.Stall.CLOSED)
	Oficios.add_item(d, od, od.stone, 2)
	assert_eq(HubEvolution.of(d).vendor, HubEvolution.Stall.ORDER, "Tem um pedido")
	MaterialPurse.give(d, &"silver", 30)
	assert_true(Oficios.deliver(d, od))
	var s := HubEvolution.of(d)
	assert_eq(s.vendor, HubEvolution.Stall.OPEN, "delivered: open")
	assert_eq(s.obras, 1, "the order's Obra made")


func test_e3_the_tree_plates_light_by_the_gifts_opened() -> void:
	var d := _fresh()
	var hero := SaveData.hero(d, SaveData.FIRST_HERO)
	hero.mastery_xp = 2470
	var s := HubEvolution.of(d)
	assert_eq(s.tree_lit, 0, "the Maestria alone lights none")
	assert_eq(s.mastery, 20)
	hero.opened = ["passo_encadeado", "golpe_sem_fim", "quarto_corte"]
	assert_eq(HubEvolution.of(d).tree_lit, 2, "the two bought with Memória (the free one has no plate)")


func test_e4_the_book_spines_by_the_compendium_and_morvath_sealed() -> void:
	var d := _fresh()
	assert_eq(HubEvolution.of(d, [Vector2i(10, 10), Vector2i(7, 10), Vector2i(8, 10), Vector2i(0, 0)]).book_spines, 2,
		"a spine per chapter found at 80%, an empty chapter none")
	var chapters := Hub.codex_chapters(d)
	assert_eq(chapters.size(), 7, "seven chapters (Bênçãos, Elos, Salmos, Inimigos, Arenas, Anjos, Morvath)")
	assert_eq(chapters[6], Vector2i(0, 1), "Morvath only once sealed")
	SaveData.codex_add(d, "enemies", "morvath", "defeated")
	assert_eq(Hub.codex_chapters(d)[6], Vector2i(1, 1))
	assert_eq(HubEvolution.of(d, Hub.codex_chapters(d)).book_spines, 1, "the sealing is a spine")


func test_a_piece_without_its_feature_stays_hidden() -> void:
	var d := _fresh()
	Oficios.add_item(d, od, od.stone, 2)
	Forge.block(d).temper = 1
	var off := {&"forge": false, &"vendor": false, &"tree": false, &"book": false, &"oficios_shelf": false,
		&"alchemist": false}
	var s := HubEvolution.of(d, [Vector2i(1, 1)], off)
	assert_eq(s.vendor, HubEvolution.Stall.HIDDEN, "no Vendedor's states")
	assert_false(s.shelf, "no Ofícios shelf")
	assert_eq(s.forge_rank, 0)
	assert_eq(s.book_spines, 0)
	assert_false(HubEvolution.FLAGS[&"alchemist"], "E5 off until Roteiro C")
	assert_true(HubEvolution.FLAGS[&"vendor"] and HubEvolution.FLAGS[&"oficios_shelf"], "E2 and E4 on (Lote C)")


class FakeLook:
	extends RefCounted
	var calls := {}

	func set_forge_rank(n: int) -> void:
		calls[&"forge"] = n

	func set_vendor(state: int, obras: int) -> void:
		calls[&"vendor"] = [state, obras]

	func set_book(spines: int, shelf: bool, items: int) -> void:
		calls[&"book"] = [spines, shelf, items]


func test_apply_calls_what_the_look_paints_and_skips_the_rest() -> void:
	var d := _fresh()
	Forge.block(d).temper = 3
	Oficios.add_item(d, od, od.stone, 1)
	var look := FakeLook.new()
	HubEvolution.apply(look, HubEvolution.of(d))
	assert_eq(look.calls[&"forge"], 3)
	assert_eq(look.calls[&"vendor"], [int(HubEvolution.Stall.ORDER), 0])
	assert_eq(look.calls[&"book"], [0, true, 0])
	assert_eq(look.calls.size(), 3, "set_tree_plates, set_forge_tools and set_alchemist not there: skipped")


func test_the_hub_paints_its_state() -> void:
	var hub: Hub = (load("res://scenes/hub.tscn") as PackedScene).instantiate()
	add_child_autofree(hub)
	await wait_process_frames(2)
	assert_true(hub.arena.look is HubLook)
	hub.evolve()  # (no error with the look of today: set_forge_rank only)
	pass_test("evolve runs on the real hub")
