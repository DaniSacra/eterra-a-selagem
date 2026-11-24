extends GutTest
## Rejogabilidade, Fatia 2 (sistemas.md 1.5 to 1.7, 3.6): the doors fork by reward group (RJ-2, RJ-3), at most two
## Encantos on any way (the second from the 5th room), the Psalm's door, a Blessing's door that shows one angel (two
## of the six a meeting), the Esmeralda, the Forjador's first tool at the guardian that opens the Refinar, Temperar
## III, the Encantos' rules and their blows, and the new Blessings.

const R := RunMap.Reward
const MAP_SALT := 7411

var stage: StageDef
var game: Game


func before_all() -> void:
	stage = load("res://data/stages/catacombs.tres")


func _run(kind := RunMap.Kind.COMBAT) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(kind)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


# ---------- the deck and the map ----------

func test_draw_prefer_takes_a_preferred_card_and_falls_back() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var any := func(_c: int) -> bool: return true
	var deck := RewardDeck.new(PackedInt32Array([R.BOON, R.GOLD, R.SILVER]))
	assert_eq(deck.draw_prefer(rng, any, func(c: int) -> bool: return c == R.SILVER), R.SILVER)
	var got := deck.draw_prefer(rng, any, func(_c: int) -> bool: return false)
	assert_true(got == R.BOON or got == R.GOLD, "none preferred: any valid card")
	deck = RewardDeck.new(PackedInt32Array([R.BOON, R.GOLD]))
	var no_gold := func(c: int) -> bool: return c != R.GOLD
	assert_eq(deck.draw_prefer(rng, no_gold, func(c: int) -> bool: return c == R.GOLD), R.BOON, "the preferred must be valid too")


func test_doors_fork_by_group_on_a_thousand_maps() -> void:
	var forks := 0
	var mixed := 0
	for s in 300:
		var map := RunMap.new(stage, hash([s, MAP_SALT]))
		for r in map.nodes:
			var shown: Array[int] = []
			for n in r.next:
				var x := map.at(n)
				if x.kind == RunMap.Kind.COMBAT and x.reward != R.NONE:
					shown.append(x.reward)
			if shown.size() < 2:
				continue
			forks += 1
			var groups := {}
			for w in shown:
				groups[RunMap.group_of(w)] = true
			if groups.size() >= 2:
				mixed += 1
	var share := float(mixed) / forks
	gut.p("RJ-3: %d of %d forks show two groups or more (%.1f%%; 77.8%% before the Fatia 2)" % [mixed, forks, share * 100.0])
	assert_gt(share, 0.85, "most forks contrast")


func test_at_most_two_enchants_on_any_way_and_the_second_late() -> void:
	for s in 300:
		var map := RunMap.new(stage, hash([s, MAP_SALT]))
		var all: Array = []
		_ways(map, map.first().id, [], all)
		for way: Array in all:
			var depths: Array[int] = []
			for id: int in way:
				var x := map.at(id)
				if x.reward == R.ENCHANT:
					depths.append(x.depth)
				if x.psalm:
					assert_gte(x.depth, stage.psalm_from_depth, "seed %d: a Psalm's door from room %d" % [s, stage.psalm_from_depth])
			assert_lte(depths.size(), stage.enchant_max, "seed %d: at most two Encantos on a way" % s)
			if depths.size() == 2:
				assert_gte(depths[1], stage.enchant_second_from, "seed %d: the second from room %d" % [s, stage.enchant_second_from])


func test_a_third_of_the_blessing_rooms_are_meetings() -> void:
	var boons := 0
	var meetings := 0
	for s in 300:
		var map := RunMap.new(stage, hash([s, MAP_SALT]))
		for r in map.nodes:
			if r.reward == R.BOON and r.kind == RunMap.Kind.COMBAT and r.depth > 1 and not r.psalm:
				boons += 1
				if r.meeting:
					meetings += 1
			if r.depth == 1 and r.kind == RunMap.Kind.COMBAT:
				assert_true(r.meeting or r.reward != R.BOON, "the hall is a meeting")
			if r.kind == RunMap.Kind.MINIBOSS:
				assert_false(r.meeting, "PT-8: a guardian's door shows its own angel")
	var share := float(meetings) / boons
	assert_between(share, 0.25, 0.42, "two of six (%.2f)" % share)


func test_the_psalm_card_never_promises_a_psalm_on_the_map() -> void:
	# the deck's Psalm card lies on the map as a Blessing (never a meeting); its door shows a Psalm only when one can come
	var hopes := 0
	for s in 300:
		var map := RunMap.new(stage, hash([s, MAP_SALT]))
		for r in map.nodes:
			if r.reward == R.PSALM:
				hopes = -1000
			if r.psalm:
				hopes += 1
				if r.reward != R.BOON or r.meeting or r.depth < stage.psalm_from_depth:
					hopes = -1000
	assert_gt(hopes, 75, "the Psalm card lands on the map (%d in 300), as a Blessing, from room %d, never a meeting" % [hopes, stage.psalm_from_depth])
	var map := RunMap.new(stage, 5)
	var hope := RunMap.Room.new(RunMap.Kind.COMBAT, R.BOON, 5)
	hope.psalm = true
	var plain := RunMap.Room.new(RunMap.Kind.COMBAT, R.BOON, 5)
	var doors: Array[RunMap.Room] = [hope, plain]
	assert_eq(map.settle(doors, true), 0, "no Psalm can come: it stays a Blessing")
	assert_eq(hope.reward, R.BOON)
	assert_eq(map.settle(doors, true, true), 1, "one can come: its door shows the Psalm")
	assert_eq([hope.reward, plain.reward], [R.PSALM, R.BOON], "only where the card fell")


func test_settle_turns_what_cannot_come_into_a_blessing() -> void:
	var map := RunMap.new(stage, 5)
	var doors: Array[RunMap.Room] = []
	for reward in [R.POM, R.PSALM, R.ENCHANT, R.GOLD]:
		var r := RunMap.Room.new(RunMap.Kind.COMBAT, reward, 3)
		doors.append(r)
	assert_eq(map.settle(doors, true, true, true), 0)
	assert_eq(map.settle(doors, true, false, false), 2)
	assert_eq(doors.map(func(r: RunMap.Room) -> int: return r.reward), [R.POM, R.BOON, R.BOON, R.GOLD])
	assert_eq(map.pom_turned, 0, "only the pomegranates count there")


func _ways(map: RunMap, id: int, so_far: Array, out: Array) -> void:
	var here := so_far.duplicate()
	here.append(id)
	var r := map.at(id)
	if r.next.is_empty():
		out.append(here)
		return
	for n in r.next:
		_ways(map, n, here, out)


# ---------- the Forja ----------

func test_temper_three_and_the_refine_behind_the_tool() -> void:
	var forge := Forge.new(Forge.load_catalog())
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, 200)
	assert_true(forge.buy(d, &"temper_1"))
	assert_true(forge.buy(d, &"temper_2"))
	assert_true(forge.buy(d, &"temper_3"))
	var state := BoonState.new(BoonState.load_catalog())
	state.equip_forge(forge.ranks_for(d))
	assert_almost_eq(state.stat(&"damage_pct", [&"light"]), 0.30, 0.0001, "I and III on the attack")
	assert_almost_eq(state.stat(&"damage_pct", [&"heavy", &"wave"]), 0.30, 0.0001, "II and III on the special")
	assert_eq(forge.refine_slots(), [&"attack", &"special"] as Array[StringName])
	assert_eq(forge.refine_options(&"attack").size(), 3)
	var fio := forge.find(&"refine_fio")
	assert_eq(forge.problem(d, fio), Forge.Problem.NO_TOOL, "the tool first")
	assert_eq(forge.state(d, fio), Forge.State.LOCKED)
	assert_true(Forge.add_tool(d, Forge.TOOL_REFINE))
	assert_false(Forge.add_tool(d, Forge.TOOL_REFINE), "once")
	assert_eq(forge.state(d, fio), Forge.State.NEXT)
	assert_true(forge.buy(d, &"refine_fio"))
	assert_true(forge.is_on(d, fio), "the first bought goes on its empty action")
	assert_true(forge.buy(d, &"refine_peso"))
	assert_true(forge.is_on(d, fio), "the second waits")
	assert_true(forge.put_on(d, &"refine_peso"))
	assert_false(forge.is_on(d, fio), "one an action")
	assert_eq(forge.refines_on(d).map(func(r: ForgeRank) -> StringName: return r.id), [&"refine_peso"])
	var back := SaveData.merged(JSON.parse_string(JSON.stringify(d)))
	assert_eq(forge.refines_on(back).size(), 1, "kept in the save")
	assert_true(Forge.has_tool(back, Forge.TOOL_REFINE))
	forge.take_off(d, &"attack")
	assert_true(forge.refines_on(d).is_empty())


# ---------- the Encantos ----------

func test_three_encantos_learned_and_their_rules() -> void:
	var all := Enchants.load_catalog()
	assert_eq(all.size(), 6, "three learned and three to inscribe (Fatia 3)")
	for e in all:
		assert_ne(T.t(e.name_key), String(e.name_key), "%s has a name" % e.id)
		assert_ne(T.t(e.desc_key), String(e.desc_key))
		assert_false(T.t(e.desc_key).contains("—"))
	var pool := Enchants.learned(all)
	assert_eq(pool.size(), 3, "the first three learned from the start")
	var triple := all.filter(func(e: EnchantDef) -> bool: return e.id == &"lamina_triplice")[0] as EnchantDef
	var none: Array[EnchantDef] = []
	assert_false(Enchants.allowed(triple, none, [&"corte_crescente"] as Array[StringName]), "never with its Gift")
	var taken: Array[EnchantDef] = [triple]
	var rng := RandomNumberGenerator.new()
	var offers := Enchants.offers(pool, taken, [] as Array[StringName], rng)
	assert_eq(offers.size(), 2)
	assert_false(offers.has(triple), "never one taken")


func test_an_enchants_door_opens_the_choice_and_counts_two_at_most() -> void:
	_run()
	game.rooms._give(R.ENCHANT)
	assert_eq(game.mode, Game.Mode.CHOICE)
	assert_eq(game.enchant_options.size(), 3)
	var first := game.enchant_options[0]
	game.take_enchant(first)
	assert_eq(game.boons.enchants, [first] as Array[EnchantDef])
	game.close_screen()
	game.take_enchant(first)
	assert_eq(game.boons.enchants.size(), 1, "never twice")
	game.open_enchant_choice()
	game.take_enchant(game.enchant_options[0])
	assert_eq(game.boons.enchants.size(), 2)
	game.close_screen()
	assert_true(game.enchant_offers().is_empty(), "two a descent")
	assert_eq(game.result().enchants.size(), 2)


func test_the_robot_takes_the_first_encanto() -> void:
	_run()
	game.bot = Bot.new()
	game.rooms._give(R.ENCHANT)
	assert_eq(game.boons.enchants.size(), 1)
	assert_eq(game.mode, Game.Mode.PLAY)


func test_eco_strikes_again_for_half_and_retorno_reaches_farther() -> void:
	_run()
	var eco: EnchantDef = load("res://data/enchants/01_eco_da_verdade.tres")
	game.boons.take_enchant(eco)
	assert_almost_eq(game.boons.stat(&"echo_pct", [&"light", &"spin", &"finisher"]), 0.5, 0.0001)
	assert_eq(game.boons.stat(&"echo_pct", [&"light"]), 0.0, "only the spin")
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(1.5, 0), false)
	e.hp = 9999.0
	var spin: ComboNode = null
	for n in game.player.runner.tree.neutral:
		spin = spin if spin != null else _node(n, &"spin")
	assert_not_null(spin)
	game.combat.strike(spin, Vector2.ZERO, Vector2.RIGHT)
	var after := e.hp
	for i in 30:
		game.combat.step(1.0 / 60.0)
	assert_lt(e.hp, after, "the echo struck 0.3 s later")
	var back: EnchantDef = load("res://data/enchants/02_retorno_do_corte.tres")
	game.boons.take_enchant(back)
	assert_almost_eq(game.boons.stat(&"return_reach", [&"light", &"dash"]), 0.3, 0.0001)
	var plain := Combat.swing_shape(spin, 0.0)
	var wide := Combat.swing_shape(spin, 0.3, 0.3)
	assert_gt(float(wide.hit_reach), float(plain.hit_reach))


func _node(n: ComboNode, id: StringName) -> ComboNode:
	if n == null:
		return null
	if n.tags.has(id):
		return n
	for x in n.following():
		var found := _node(x, id)
		if found != null:
			return found
	return null


# ---------- the doors ----------

func test_a_psalm_door_offers_a_psalm_that_may_come() -> void:
	_run()
	game.psalm_cards = true
	for id in [&"brasas", &"escudo", &"consolo"]:
		game._take(game.boons.find(id))
	game.rooms._give(R.PSALM)
	assert_eq(game.mode, Game.Mode.CHOICE)
	var psalms := game.offer_cards.filter(func(c: BoonState.Card) -> bool: return c.psalm != null)
	var can := not game.psalms.eligible(game.boons, game.talents).is_empty()
	assert_eq(psalms.size(), 1 if can else 0, "a Psalm when one may come")


func test_a_blessing_door_shows_one_angel_who_comes() -> void:
	_run()
	var r := game.rooms.room
	r.reward = R.BOON
	r.meeting = false
	r.angel = game.encounters.door_angel(r)
	assert_ne(r.angel, &"")
	assert_true(Rooms.door_text(r).contains(T.t(StringName("angel_" + String(r.angel)))), "the sign names the angel")
	game.rooms._room_cleared()
	game.rooms._collect()
	# BC-4: the lone angel speaks first (the stage, alone), then a press takes it to its cards
	var meet := game._screen as EncounterScreen
	assert_not_null(meet, "the angel alone on the stage")
	assert_eq(meet.buttons.size(), 1)
	meet._opened_at -= BoonChoice.GUARD_MS * 2
	meet._press_focus()
	var entry: Dictionary = game.encounters.meetings[-1]
	assert_eq(entry.offered, [String(r.angel)], "the angel the door showed, alone")
	assert_eq(entry.chose, String(r.angel))
	assert_eq(entry.fallback, "door")
	assert_not_null(game._screen as BoonChoice, "straight to the angel's cards")
	r.meeting = true
	assert_true(Rooms.door_text(r).contains(T.t(&"door_angels_two")))


func test_a_hard_door_says_its_silver() -> void:
	_run()
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, R.GOLD, 3)
	r.fight = EncounterGen.Fight.new()
	r.fight.kinds = [&"skeleton", &"skeleton_elite"] as Array[StringName]
	r.fight.waves = [[&"skeleton", &"skeleton_elite"], [&"skeleton_elite", &"skeleton"]] as Array[Array]
	assert_eq(Rooms.elite_heads(r), 2)
	assert_true(Rooms.door_text(r).contains("+%d" % (2 * stage.silver_elite)), Rooms.door_text(r))


# ---------- the Esmeralda and the tool ----------

func test_esmeralda_at_phase_three_and_at_the_sealing() -> void:
	_run(RunMap.Kind.BOSS)
	game.rooms.boss_phase(2)
	assert_eq(game.materials.total(MaterialPurse.EMERALD), 0)
	game.rooms.boss_phase(3)
	game.rooms.boss_phase(4)
	assert_eq(game.materials.total(MaterialPurse.EMERALD), stage.emerald_phase, "once")
	game.rooms.victory()
	assert_eq(game.materials.total(MaterialPurse.EMERALD), stage.emerald_phase + stage.emerald_victory)
	assert_eq(game.materials.report().emerald.boss, 2)


func test_the_first_guardian_won_finds_the_forjadors_tool() -> void:
	_run(RunMap.Kind.MINIBOSS)
	game.bot = Bot.new()
	watch_signals(game)
	game.rooms._room_cleared()
	assert_eq(game.tools_found, [Forge.TOOL_REFINE] as Array[StringName])
	assert_signal_emitted(game, "tool_found")
	assert_eq(game.result().tools, ["tool_refine"])
	game.find_tool(Forge.TOOL_REFINE)
	assert_eq(game.tools_found.size(), 1, "once a descent")


# ---------- the new Blessings ----------

func test_two_to_three_new_blessings_a_family() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	var count := {}
	for b in state.catalog:
		if b.family != Boon.Family.DUO:
			count[b.family] = int(count.get(b.family, 0)) + 1
	for f in [Boon.Family.GEADA, Boon.Family.VIGILIA]:
		assert_gte(count[f], 9, "Geada and Vigília first (6 before)")
	for f in [Boon.Family.CHAMA, Boon.Family.LUZ]:
		assert_gte(count[f], 9)
	for id in [&"geada_final", &"omega_geada", &"vigia_firme", &"vigilia_longa", &"guarda_atenta",
			&"omega_brasa", &"chuva_brasas", &"final_radiante", &"onda_clara"]:
		var b := state.find(id)
		assert_not_null(b, String(id))
		assert_eq(b.slot, Boon.Slot.NONE, "%s acts on its own: never takes an action's place" % id)
		assert_ne(T.t(StringName("boon_" + id)), "boon_" + id)


# ---------- DV-2 (MAP-09): the route shop ----------

func test_a_route_shop_on_some_branches_of_the_middle() -> void:
	var with := 0
	for s in 300:
		var map := RunMap.new(stage, hash([s, MAP_SALT]))
		var route := 0
		for r in map.nodes:
			if map.is_route_shop(r):
				route += 1
				assert_between(r.depth, stage.route_shop_depth_min, stage.route_shop_depth_max, "seed %d" % s)
				assert_gt(map.layers[r.depth].size(), 1, "seed %d: never on every way" % s)
		assert_lte(route, 1, "seed %d: one at most" % s)
		if route > 0:
			with += 1
		var last := map.at(map.layers[stage.rooms][0])
		assert_eq(last.kind, RunMap.Kind.SHOP, "the last shop stays")
	gut.p("MAP-09: %d of 300 maps have a route shop" % with)
	assert_between(with, 60, 200, "some branches, not every map")


func test_the_route_shop_shows_three_items_one_a_group() -> void:
	_run(RunMap.Kind.SHOP)
	var map := game.rooms.map
	var r := RunMap.Room.new(RunMap.Kind.SHOP, R.NONE, stage.route_shop_depth_min)
	r.id = map.nodes.size()
	map.nodes.append(r)
	game.rooms._enter(r)
	await wait_process_frames(1)
	var shelf := game.rooms.shop()
	assert_eq(shelf.size(), stage.route_shop_items)
	var groups := {}
	for item: Dictionary in shelf:
		groups[item.group] = true
	assert_eq(groups.size(), shelf.size(), "one of each group")
	assert_false(game.room_tally.route_shop.is_empty(), "the RESULT keeps the route shop apart")
	assert_true(game.result().has("route_shop"))


func test_the_robot_walks_into_a_route_shop_with_gold() -> void:
	var shop := RunMap.Room.new(RunMap.Kind.SHOP, R.NONE, 7)
	var gold := RunMap.Room.new(RunMap.Kind.COMBAT, R.GOLD, 7)
	var doors: Array[RunMap.Room] = [gold, shop]
	assert_eq(Rooms.bot_door(doors, false, 1.0, 40), 0, "no gold: the fight")
	assert_eq(Rooms.bot_door(doors, false, 1.0, 160), 1, "gold to spend: the shop")


func test_the_psalm_door_stands_when_the_hand_opens_a_psalm() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.COMBAT)
	game.horde.clear_crowd()
	game.psalm_cards = true
	var hope := RunMap.Room.new(RunMap.Kind.COMBAT, R.BOON, 5)
	hope.psalm = true
	var doors: Array[RunMap.Room] = [hope]
	assert_false(game.rooms.psalm_can_come(), "an empty hand opens no Psalm")
	game.rooms.map.settle(doors, true, game.rooms.psalm_can_come())
	assert_eq(hope.reward, R.BOON, "no Psalm can come: the door stays a Blessing")
	# the Abrigo's three groups: a step, a shield, an Elo of the two (Rastro); the Sentinela needs the circle, which left the Warrior
	for id in ["passo_brasa", "escudo", "rastro"]:
		game.boons.take(load(_boon_path(id)))
	assert_true(game.rooms.psalm_can_come(), "the hand opens the Abrigo (%s; %d in the catalog, %d taken)" % [
		str(Psalms.held_of(game.boons, game.talents).keys()), game.psalms.catalog.size(), game.psalms.taken.size()])
	game.rooms.map.settle(doors, true, game.rooms.psalm_can_come())
	assert_eq(hope.reward, R.PSALM, "now its door shows the Psalm")


func _boon_path(id: String) -> String:
	for f in DirAccess.get_files_at("res://data/boons/"):
		if f.ends_with("_%s.tres" % id):
			return "res://data/boons/" + f
	return ""
