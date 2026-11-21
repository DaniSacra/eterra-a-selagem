extends GutTest
## Rejogabilidade, Fatia 1, in a real run and in the hub (sistemas.md 3.3): a room's Blessing comes by two angels (the
## Encontro, EncounterScreen, then the angel's cards on the usual choice screen), the robot picks by affinity, the
## materials come from the doors, the elites, the guardian and Morvath, the RESULT carries them (and the forge and the
## meetings), the robot and a run without a save never bank (A2), and the Forjador sells Temperar I for Prata.

var game: Game


func _run(kind := RunMap.Kind.FOUNTAIN) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(kind)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


func test_a_rooms_blessing_meets_two_angels_then_their_cards() -> void:
	_run(RunMap.Kind.COMBAT)
	assert_true(game.encounters.on())
	game.rooms.room.reward = RunMap.Reward.BOON
	game.rooms._room_cleared()
	game.rooms._collect()
	assert_eq(game.mode, Game.Mode.CHOICE)
	var meet := game._screen as EncounterScreen
	assert_not_null(meet, "the meeting's screen first (the Encontro, EncounterScreen)")
	assert_eq(meet.buttons.size(), 2, "two angels")
	var pair := game.encounters.angels_now.duplicate()
	assert_ne(pair[0], pair[1])
	var entry: Dictionary = game.encounters.meetings[0]
	assert_eq(entry.offered.size(), 2)
	meet._opened_at -= BoonChoice.GUARD_MS * 2
	meet.buttons[1].pressed.emit()
	var chosen: AngelDef = pair[1]
	assert_eq(game.encounters.meetings[0].chose, String(chosen.id))
	var choice := game._screen as BoonChoice
	assert_not_null(choice, "then the angel's cards")
	assert_eq(game.mode, Game.Mode.CHOICE)
	for c in game.offer_cards:
		if c.psalm == null:
			assert_true(Encounter.belongs(game.boons, c.boon, chosen.family), "%s is %s's" % [c.boon.id, chosen.id])
	assert_eq(game.encounters.meetings[0].cards.size(), game.offer_cards.size())
	assert_eq(game.result().angels.size(), 1, "the RESULT carries the meeting")


func test_the_same_room_offers_the_same_cards_by_each_angel() -> void:
	_run(RunMap.Kind.COMBAT)
	game.encounters._chances = game.rooms.stage.rarity_chance
	var a: AngelDef = game.encounters.book.catalog[0]
	var first := game.encounters.cards_of(a).map(func(c: BoonState.Card) -> StringName: return c.boon.id if c.boon else &"psalm")
	var again := game.encounters.cards_of(a).map(func(c: BoonState.Card) -> StringName: return c.boon.id if c.boon else &"psalm")
	assert_eq(first, again, "looking twice never rerolls")


func test_the_robot_chooses_by_affinity() -> void:
	_run(RunMap.Kind.COMBAT)
	game.bot = Bot.new()
	game._take(game.boons.find(&"brasas"))
	game._take(game.boons.find(&"golpe_brasa"))
	Dev.put("angels", "nivael,sarael")
	game.open_boon_choice(game.rooms.stage.rarity_chance, -1.0, true)
	Dev.drop("angels")
	assert_eq(game.encounters.meetings[0].offered, ["nivael", "sarael"])
	assert_eq(game.encounters.meetings[0].chose, "sarael", "the family it holds most")
	assert_false(game._screen is AngelChoice, "no meeting screen for the robot")


func test_the_shop_blessing_is_drawn_as_before() -> void:
	_run()
	game.rooms._give(RunMap.Reward.BOON)
	assert_true(game.encounters.meetings.is_empty(), "no meeting in the shop")
	assert_true(game._screen is BoonChoice)


func test_materials_come_from_doors_elites_the_guardian_and_morvath() -> void:
	_run()
	var st := game.rooms.stage
	game.rooms._give(RunMap.Reward.SILVER)
	game.rooms._give(RunMap.Reward.MEMORY)
	assert_eq(game.materials.report().silver.door, st.silver_door)
	assert_eq(game.materials.report().memory.door, st.memory_door)
	var elite := game.horde.spawn(game.horde.def(&"skeleton_elite"), game.arena.resolve(Vector2(3, 3), 0.6), false)
	var plain := game.horde.spawn(game.horde.def(&"skeleton"), game.arena.resolve(Vector2(-3, 3), 0.6), false)
	elite.armor = 0.0
	game.horde.damage(elite, 99999.0, Vector2.RIGHT, 0.0)
	game.horde.damage(plain, 99999.0, Vector2.RIGHT, 0.0)
	assert_eq(game.materials.report().silver.elite, st.silver_elite, "the elite, not the common one")
	game.rooms.boss_phase(1)
	game.rooms.boss_phase(3)
	game.rooms.boss_phase(2)
	assert_eq(game.materials.report().silver.boss, 3 * st.silver_phase, "each phase reached once")
	game.rooms.victory()
	assert_eq(game.materials.report().silver.boss, 3 * st.silver_phase + st.silver_victory)
	assert_eq(game.materials.report().memory.boss, st.memory_victory)
	var r := game.result()
	assert_eq(r.materials.total.silver, game.materials.total(MaterialPurse.SILVER))
	assert_eq(r.forge, {"temper": 0, "refine": []})
	assert_true(r.has("talents_opened"))
	assert_eq(game.run_entry("quit", {}).version, RunLog.VERSION)


func test_a_guardian_won_brings_silver_and_memory() -> void:
	_run(RunMap.Kind.MINIBOSS)
	game.horde.clear_crowd()
	game.rooms._room_cleared()
	assert_eq(game.materials.report().silver.guardian, game.rooms.stage.silver_guardian)
	assert_eq(game.materials.report().memory.guardian, game.rooms.stage.memory_guardian)


## A2: banked once a run with a save, never the robot's (unless --materials-keep) nor without a save.
func test_only_a_persons_run_with_a_save_banks() -> void:
	assert_true(Game.banks_materials(true, false, false))
	assert_false(Game.banks_materials(false, false, false), "--nosave")
	assert_false(Game.banks_materials(true, true, false), "the robot")
	assert_true(Game.banks_materials(true, true, true), "--materials-keep")
	assert_false(Game.banks_materials(false, true, true))
	_run()
	game.rooms._give(RunMap.Reward.SILVER)
	var before := MaterialPurse.amount(Save.data, MaterialPurse.SILVER)
	game.log_run("death")
	game.log_run("death")
	assert_eq(MaterialPurse.amount(Save.data, MaterialPurse.SILVER), before, "the tests run without a save: nothing banked")
	assert_eq(game.materials_banked, {})


func test_the_forjador_sells_temper_for_silver() -> void:
	var saved := Save.data
	Save.data = SaveData.defaults()
	MaterialPurse.give(Save.data, MaterialPurse.SILVER, 20)
	var hub: Hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	var bought: Array[StringName] = []
	hub.forged.connect(func(id: StringName) -> void: bought.append(id))
	hub.use(HubPlan.SMITH)
	var f := hub.host.screen as ForgeScreen
	assert_not_null(f, "the Forja, a spread of the Livro")
	assert_eq(f.shown.id, &"temper_1", "the rank to buy first")
	assert_false(f.buy_button.disabled)
	f.buy_button.pressed.emit()
	assert_eq(Forge.temper(Save.data), 1)
	assert_eq(MaterialPurse.amount(Save.data, MaterialPurse.SILVER), 5)
	assert_eq(bought, [&"temper_1"] as Array[StringName])
	assert_eq(f.shown.id, &"temper_2", "on to the next rank")
	assert_true(f.buy_button.disabled, "5 of 35 for Temperar II: nothing to forge")
	await wait_process_frames(2)
	hub.host.close()
	Save.data = saved
