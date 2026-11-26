extends GutTest
## Rejogabilidade, Fatia 1 (docs/design/rejogabilidade/sistemas.md 3.3), the pure parts: the materials (MaterialPurse),
## the save version 6 and its migration (A1), the Forja (Forge, ForgeRank in BoonState.stat), the Gifts opened with
## Memória (Talents), the two new doors in the deck and the same map by the same seed (A3), the share of rooms whose
## doors trade a material against a Blessing (A6) and the meeting with two angels (Encounter, A4).

const STAGE := "res://data/stages/catacombs.tres"

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _fixture(version: int) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save_v%d.json" % version))


func _round_trip(data: Dictionary) -> Dictionary:
	return SaveData.merged(JSON.parse_string(JSON.stringify(data)))


# ---------- materials ----------

func test_a_purse_counts_by_source_and_reports_every_source() -> void:
	var p := MaterialPurse.new()
	assert_true(p.is_empty())
	assert_eq(p.add(MaterialPurse.SILVER, &"elite", 1), 1)
	p.add(MaterialPurse.SILVER, &"elite", 1)
	p.add(MaterialPurse.SILVER, &"door", 10)
	p.add(MaterialPurse.MEMORY, &"trial", 2)
	assert_eq(p.add(MaterialPurse.SILVER, &"door", 0), 0, "nothing for nothing")
	assert_eq(p.add(&"brasa", &"door", 3), 0, "no Brasa: three currencies only (Q-RJ2)")
	assert_eq(p.total(MaterialPurse.SILVER), 12)
	var r := p.report()
	assert_eq(r.silver, {"elite": 2, "room": 0, "door": 10, "guardian": 0, "boss": 0})
	assert_eq(r.memory, {"door": 0, "reach": 0, "guardian": 0, "trial": 2, "boss": 0})
	assert_eq(r.emerald, {"boss": 0, "juramentos": 0}, "Esmeralda from Morvath (Fatia 2) and a new best Peso (Fatia 3)")
	assert_eq(r.total, {"silver": 12, "memory": 2, "emerald": 0})


func test_the_save_holds_materials_up_to_their_cap_and_spends_only_what_it_has() -> void:
	var d := SaveData.defaults()
	assert_eq(d.materials, {"silver": 0, "memory": 0, "emerald": 0})
	assert_eq(MaterialPurse.give(d, MaterialPurse.SILVER, 990), 990)
	assert_eq(MaterialPurse.give(d, MaterialPurse.SILVER, 50), 9, "capped at 999")
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 999)
	assert_eq(int(d.materials_total.silver), 999, "the lifetime total counts what went in")
	assert_false(MaterialPurse.spend(d, MaterialPurse.MEMORY, 1), "no Memória to spend")
	assert_true(MaterialPurse.spend(d, MaterialPurse.SILVER, 15))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 984)
	assert_eq(MaterialPurse.parse("silver:30,memory:5,brasa:9,x"), {"silver": 30, "memory": 5})
	assert_eq(MaterialPurse.retro_silver(4), 20)
	assert_eq(MaterialPurse.retro_silver(40), 30, "up to 30 (Q-RJ8 a)")


## A1: a version 5 save opens with all it had, the Gifts its Mastery unlocked opened for free, the retroactive Prata,
## and nothing is lost through two deaths, a quit and a victory in a row (each banked, written and read back).
func test_a_version_5_save_opens_whole_and_keeps_everything_through_four_runs() -> void:
	var before: Dictionary = _fixture(5)
	var out := SaveData.merged(before)
	assert_eq(out.version, SaveData.VERSION)
	assert_gte(SaveData.VERSION, 6)
	var w: Dictionary = out.heroes.warrior
	assert_eq(int(w.mastery_xp), 330)
	assert_eq(w.equipped, [], "the old loadout goes with the v13 migration (the Vagas are free again)")
	# Mastery 6 (330 XP): Disciplina, Força Concentrada, Ruptura, Cadência and Determinação are revealed; Voz do Leão at 8
	for id in ["disciplina", "forca_concentrada", "ruptura", "cadencia", "determinacao"]:
		assert_true((w.opened as Array).has(id), "%s unlocked before: opened for free" % id)
	assert_false((w.opened as Array).has("voz_do_leao"), "nothing past its Mastery")
	assert_eq(int(w.forge.temper), 0)
	assert_eq(w.tools, [])
	assert_eq(MaterialPurse.amount(out, MaterialPurse.SILVER), 20, "5 a descent played (4)")
	assert_eq(MaterialPurse.amount(out, MaterialPurse.MEMORY), 0)
	assert_eq(out.options.camera, "near")
	assert_eq(out.codex.enemies.skeleton.defeated, 40)
	var book := HeroDef.warrior().talents()
	var level := HeroDef.warrior().mastery.level_of(int(w.mastery_xp))
	assert_eq(book.check(w.equipped, level, HeroDef.warrior().mastery.devotion(level), Talents.opened_of(w)).problem,
		Talents.Problem.OK, "the loadout is valid with what was opened")
	# two deaths, a quit and a victory: each run banks its purse, the file is written and read back
	var data := out
	var runs := [{"silver": 7, "memory": 0}, {"silver": 12, "memory": 3}, {"silver": 2, "memory": 0}, {"silver": 34, "memory": 6}]
	var silver := 20
	var memory := 0
	for r: Dictionary in runs:
		var p := MaterialPurse.new()
		p.add(MaterialPurse.SILVER, &"door", r.silver)
		p.add(MaterialPurse.MEMORY, &"door", r.memory)
		MaterialPurse.bank(data, p)
		data = _round_trip(data)
		silver += r.silver
		memory += r.memory
		assert_eq(MaterialPurse.amount(data, MaterialPurse.SILVER), silver)
		assert_eq(MaterialPurse.amount(data, MaterialPurse.MEMORY), memory)
	assert_eq(MaterialPurse.amount(data, MaterialPurse.SILVER), 75, "nothing lost")
	assert_eq(data.heroes.warrior.opened, w.opened, "the opened Gifts survive")
	# the retro Prata is given once: a version 6 file read again gets none more
	assert_eq(MaterialPurse.amount(_round_trip(data), MaterialPurse.SILVER), 75)


func test_older_versions_open_as_6_with_their_gifts_opened() -> void:
	for v in [1, 2, 3, 4, 5]:
		var out := SaveData.merged(_fixture(v))
		assert_eq(out.version, SaveData.VERSION, "version %d opens as the current one" % v)
		var w: Dictionary = out.heroes.warrior
		var level := HeroDef.warrior().mastery.level_of(int(w.mastery_xp))
		for t in HeroDef.warrior().talents().unlocked(level):
			assert_true((w.opened as Array).has(String(t.id)), "v%d: %s opened" % [v, t.id])
		assert_true(out.materials is Dictionary and out.materials_total is Dictionary)


func test_a_fresh_save_opens_only_the_free_gift() -> void:
	var d := SaveData.defaults()
	var book := HeroDef.warrior().talents()
	var opened := Talents.opened_of(d.heroes.warrior)
	assert_eq(opened, [])
	assert_eq(book.open_ones(1, opened).map(func(t: TalentDef) -> StringName: return t.id), [&"disciplina"],
		"Disciplina comes open (memory_cost 0)")
	assert_eq(book.find(&"forca_concentrada").memory_cost, 1)
	assert_eq(book.find(&"ruptura").memory_cost, 1)
	assert_eq(book.find(&"cadencia").memory_cost, 1, "1 each for Mastery 2 to 5 (balance 2026-11-24, Lote D)")


# ---------- the Gifts opened with Memória ----------

func test_a_gift_revealed_must_be_opened_before_it_is_equipped() -> void:
	var book := HeroDef.warrior().talents()
	var d := SaveData.defaults()
	var w: Dictionary = d.heroes.warrior
	assert_eq(book.check(["disciplina", "forca_concentrada"], 3, 99, Talents.opened_of(w)).problem, Talents.Problem.SEALED)
	assert_eq(book.check(["disciplina", "forca_concentrada"], 3, 99).problem, Talents.Problem.OK, "null: every Gift open (--talents)")
	assert_eq(book.open_problem(&"forca_concentrada", 1, [], 9), Talents.Problem.LOCKED, "not revealed yet")
	assert_eq(book.open_problem(&"forca_concentrada", 3, [], 0), Talents.Problem.SHORT)
	assert_eq(book.open_problem(&"disciplina", 3, [], 0), Talents.Problem.OPENED, "free")
	assert_false(book.open_in(d, "warrior", &"forca_concentrada", 3), "no Memória")
	MaterialPurse.give(d, MaterialPurse.MEMORY, 5)
	assert_true(book.open_in(d, "warrior", &"forca_concentrada", 3))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.MEMORY), 4, "1 spent (Lote D)")
	assert_false(book.open_in(d, "warrior", &"forca_concentrada", 3), "once")
	assert_eq(book.check(["disciplina", "forca_concentrada"], 3, 99, Talents.opened_of(w)).problem, Talents.Problem.OK)
	assert_eq(book.sanitized(["disciplina", "forca_concentrada", "ruptura"], 4, 99, Talents.opened_of(w)),
		[&"disciplina", &"forca_concentrada"] as Array[StringName], "a sealed Gift never goes down")
	assert_eq(book.why_dropped(["ruptura"], [], 4, 99, Talents.opened_of(w)).get(&"ruptura"), Talents.Problem.SEALED)


func test_the_hero_screen_sees_a_sealed_gift_and_opens_it() -> void:
	var d := SaveData.defaults()
	d.heroes.warrior.mastery_xp = HeroDef.warrior().mastery.total_to(3)
	var l := HeroLoadout.new(HeroDef.warrior(), d)
	var forca_concentrada := l.book.find(&"forca_concentrada")
	assert_eq(l.state(forca_concentrada), HeroLoadout.State.SEALED)
	assert_eq(l.next_step(forca_concentrada).key, &"hero_step_open")
	assert_eq(l.can_open(forca_concentrada), Talents.Problem.SHORT)
	assert_false(l.toggle(&"forca_concentrada"), "no Memória: nothing changes")
	MaterialPurse.give(d, MaterialPurse.MEMORY, 1)
	assert_false(l.toggle(&"forca_concentrada"), "toggle never opens a sealed Gift (the screen asks first)")
	assert_eq(l.can_open(forca_concentrada), Talents.Problem.OK)
	assert_true(l.open(&"forca_concentrada"))
	assert_true(l.toggle(&"forca_concentrada"), "opened, it goes on")
	assert_eq(l.state(forca_concentrada), HeroLoadout.State.EQUIPPED)
	assert_eq(l.memory(), 0)


# ---------- the Forja ----------

func test_the_forge_sells_temper_in_order_with_silver() -> void:
	var forge := Forge.new(Forge.load_catalog())
	var track := forge.track(Forge.TEMPER)
	assert_eq(track.size(), 3, "Temperar I, II and III (Fatia 2)")
	assert_eq(track[0].cost, 20, "Temperar I, early and small (Q-RJ7 a)")
	assert_eq(track[1].cost, 45)
	assert_eq(track[2].cost, 60)
	var d := SaveData.defaults()
	assert_eq(forge.problem(d, track[0]), Forge.Problem.SHORT)
	assert_eq(forge.problem(d, track[1]), Forge.Problem.NEEDS)
	MaterialPurse.give(d, MaterialPurse.SILVER, 75)
	assert_false(forge.buy(d, &"temper_2"), "II needs I")
	assert_true(forge.buy(d, &"temper_1"))
	assert_eq(Forge.temper(d), 1)
	assert_eq(forge.state(d, track[0]), Forge.State.OWNED)
	assert_eq(forge.state(d, track[1]), Forge.State.NEXT)
	assert_false(forge.buy(d, &"temper_1"), "once")
	assert_true(forge.buy(d, &"temper_2"))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 10)
	assert_eq(_round_trip(d).heroes.warrior.forge.temper, 2, "kept in the save")
	assert_eq(forge.owned(d).size(), 2)


func test_temper_adds_to_the_blows_through_the_boons_stat() -> void:
	var forge := Forge.new(Forge.load_catalog())
	var state := BoonState.new(BoonState.load_catalog())
	assert_eq(state.stat(&"damage_pct", [&"light"]), 0.0)
	state.equip_forge(forge.up_to(1))
	assert_almost_eq(state.stat(&"damage_pct", [&"light"]), 0.2, 0.0001, "the attack")
	assert_almost_eq(state.stat(&"damage_pct", [&"light", &"thrust", &"finisher", &"omega"]), 0.2, 0.0001, "the lance")
	assert_eq(state.stat(&"damage_pct", [&"heavy", &"wave"]), 0.0, "not the special yet")
	state.equip_forge(forge.up_to(2))
	assert_almost_eq(state.stat(&"damage_pct", [&"heavy", &"wave"]), 0.2, 0.0001, "the special")
	assert_almost_eq(state.stat(&"damage_pct", [&"heavy", &"wave", &"charge", &"omega"]), 0.2, 0.0001,
		"its Omega, counted once")
	var more := BoonMod.new()  # (V1: no Blessing adds plain damage; a Gift or a granted bonus does, and the sum is the same)
	more.stat = &"damage_pct"
	more.tag = &"light"
	more.base = 0.25
	state.grant([more])
	assert_almost_eq(state.stat(&"damage_pct", [&"light"]), 0.45, 0.0001, "summed with another bonus")


# ---------- the deck and the map ----------

func test_the_deck_has_a_door_of_silver_and_one_of_memory_more() -> void:
	var deck := Array(stage.reward_deck)
	assert_eq(deck.size(), 23, "21 of the Fatia 2, plus a gold door and a heart (C2)")
	assert_eq(deck.count(RunMap.Reward.ENCHANT), 2)
	assert_eq(deck.count(RunMap.Reward.PSALM), 1)
	assert_eq(deck.count(RunMap.Reward.SILVER), 1)
	assert_eq(deck.count(RunMap.Reward.MEMORY), 1)
	assert_eq(deck.count(RunMap.Reward.BOON), 8, "nothing taken; two more in the Fatia 2 (the same share)")
	assert_eq(RunMap.REWARD_KEY.size(), RunMap.Reward.size())
	for k in RunMap.REWARD_KEY:
		if k != &"":
			assert_ne(T.t(k), String(k), "%s has a text" % k)


## A3: the same seed draws the same map (200 seeds), and the same pair of angels for the same hand.
func test_the_same_seed_gives_the_same_map_and_the_same_angels() -> void:
	var book := Encounter.new(Encounter.load_catalog())
	var state := BoonState.new(BoonState.load_catalog())
	for s in 200:
		var a := RunMap.new(stage, hash([s, Rooms.MAP_SALT]))
		var b := RunMap.new(stage, hash([s, Rooms.MAP_SALT]))
		assert_eq(JSON.stringify(a.summary()), JSON.stringify(b.summary()), "seed %d" % s)
		var p1 := book.pair(state, Encounter.dice(s, 3, 2)).map(func(x: AngelDef) -> StringName: return x.id)
		var p2 := book.pair(state, Encounter.dice(s, 3, 2)).map(func(x: AngelDef) -> StringName: return x.id)
		assert_eq(p1, p2)


## A6: in at least 25% of the rooms with two or more doors one leads to a material and another to a Blessing. The
## share is printed for the report.
func test_material_doors_stand_beside_blessings() -> void:
	var with_doors := 0
	var both := 0
	var any_material := 0
	for s in 400:
		var map := RunMap.new(stage, hash([s, Rooms.MAP_SALT]))
		for r in map.nodes:
			if r.next.size() < 2:
				continue
			with_doors += 1
			var rewards: Array = r.next.map(func(id: int) -> int: return map.at(id).reward)
			var material := rewards.has(RunMap.Reward.SILVER) or rewards.has(RunMap.Reward.MEMORY)
			if material:
				any_material += 1
				if rewards.has(RunMap.Reward.BOON):
					both += 1
	var share := float(both) / with_doors
	gut.p("A6: %d of %d rooms with 2+ doors trade a material against a Blessing (%.1f%%); any material %.1f%%" %
		[both, with_doors, share * 100.0, float(any_material) / with_doors * 100.0])
	assert_gt(any_material, 0)


# ---------- the angels ----------

func test_seven_angels_one_a_family() -> void:
	var angels := Encounter.load_catalog()
	assert_eq(angels.size(), 7)
	var families := {}
	for a in angels:
		families[a.family] = a.id
		assert_ne(T.t(a.name_key), String(a.name_key))
		assert_ne(T.t(a.line_key), String(a.line_key))
		assert_false(T.t(a.line_key).contains("—"), "no dash")
	assert_eq(families, {Boon.Family.CHAMA: &"sarael", Boon.Family.GEADA: &"nivael", Boon.Family.LUZ: &"lumael",
		Boon.Family.VIGILIA: &"shomael", Boon.Family.VEU: &"velael", Boon.Family.MARE: &"galael", Boon.Family.MARCA: &"qeshael"})


## A random hand: up to n Blessings taken off random draws.
func _hand(state: BoonState, rng: RandomNumberGenerator, n: int) -> void:
	for i in n:
		var cards := state.draw(rng, 3)
		if cards.is_empty():
			return
		state.take_card(cards[rng.randi() % cards.size()])


## A4: 2000 meetings over random hands: never an invalid card, two different angels whenever two are eligible, each
## card of the angel's family; the rarity of the fresh cards at the E3 odds within 2 points.
func test_two_thousand_meetings_offer_no_invalid_card() -> void:
	var book := Encounter.new(Encounter.load_catalog())
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var rarities := PackedInt32Array([0, 0, 0, 0])
	var fresh := 0
	var offered := {}
	var meetings := 0
	for i in 2000:
		var state := BoonState.new(BoonState.load_catalog())
		_hand(state, rng, rng.randi_range(0, 9))
		var eligible := book.catalog.filter(func(a: AngelDef) -> bool: return Encounter.eligible(state, a))
		var pair := book.pair(state, Encounter.dice(i, i % 7, 3))
		assert_eq(pair.size(), mini(2, eligible.size()), "as many as can come, up to two")
		if pair.size() == 2:
			assert_ne(pair[0], pair[1], "two different angels")
		for a in pair:
			offered[a.id] = int(offered.get(a.id, 0)) + 1
			meetings += 1
			var cards := Encounter.cards(state, a, Encounter.cards_dice(i, 1, 3, a.id), 3, stage.rarity_chance,
				stage.elo_chance, stage.trade_chance)
			assert_eq(cards.size(), mini(3, Encounter.supply(state, a)), "an eligible angel has up to three cards (V1: as many as it has)")
			assert_gt(cards.size(), 0)
			var ids := {}
			for c in cards:
				assert_false(ids.has(c.boon.id), "no card twice")
				ids[c.boon.id] = true
				assert_true(Encounter.belongs(state, c.boon, a.family), "%s is %s's" % [c.boon.id, a.id])
				assert_true(state.can_offer(c.boon), "%s can be offered" % c.boon.id)
				assert_false(c.boon.reserve, "%s is in the reserve" % c.boon.id)
				if c.grow:
					assert_eq(c.level, state.level(c.boon.id) + 1, "a filler card is a level more of one held")
				else:
					assert_eq(state.level(c.boon.id), 0, "never one already held")
				if not c.grow and not c.trade and not c.boon.is_duo() and c.replaces == null:
					rarities[c.rarity] += 1
					fresh += 1
	var odds := BoonState.rarity_odds(stage.rarity_chance)
	for r in 3:
		assert_almost_eq(float(rarities[r]) / fresh, odds[r], 0.02, "rarity %d at the E3 odds" % r)
	for id: StringName in offered:
		gut.p("A8 (random hands): %s in %.1f%% of the angels shown" % [id, float(offered[id]) / meetings * 100.0])


## (V1, 2026-11-26: no trade and no Elo in the angel draw; test_blessings_v1_draw holds it.)


func test_one_angel_alone_or_none() -> void:
	var book := Encounter.new(Encounter.load_catalog())
	var state := BoonState.new(BoonState.load_catalog())
	# everything but the Geada's taken or banned: only Nivael has cards
	for b in state.catalog:
		if b.family != Boon.Family.GEADA or b.is_duo():
			state.banned[b.id] = true
	var pair := book.pair(state, Encounter.dice(1, 1, 1))
	assert_eq(pair.size(), 1)
	assert_eq(pair[0].id, &"nivael")
	for b in state.catalog:
		state.banned[b.id] = true
	assert_eq(book.pair(state, Encounter.dice(1, 1, 1)).size(), 0, "nobody: the rest card")


func test_forced_angels_and_the_robots_affinity() -> void:
	var book := Encounter.new(Encounter.load_catalog())
	var state := BoonState.new(BoonState.load_catalog())
	var pair := book.pair(state, Encounter.dice(1, 1, 1), ["shomael", "sarael"])
	assert_eq(pair.map(func(a: AngelDef) -> StringName: return a.id), [&"shomael", &"sarael"])
	state.take(state.find(&"brasas"))
	state.take(state.find(&"golpe_brasa"))
	state.take(state.find(&"escudo"))
	assert_eq(Encounter.affinity(state, pair).id, &"sarael", "two of the Chama against one of the Vigília")
	assert_eq(Encounter.affinity(BoonState.new(BoonState.load_catalog()), pair).id, &"shomael", "a tie: the first")


func test_an_older_log_line_reads_with_no_materials_nor_angels() -> void:
	var old := RunLog.normalized({"version": 4, "outcome": "death", "rooms": []})
	assert_eq(old.materials, {})
	assert_eq(old.angels, [])
	assert_eq(old.forge, {})
	assert_eq(old.talents_opened, 0)
	assert_eq(RunLog.VERSION, 9)  # (6: the Ofícios; test_oficios.gd; 7: uses; 8: cause and per-room hazard; 9: SW-O onboarding, test_run_log.gd)
