extends GutTest
## E2-07 and E2-09 (docs/design/warrior_spec.md 3.1, 4.2, 4.3, 4.5): the Warrior's passive (P-A, 2 of Magia a
## finisher that lands) and every Gift of the tree, one test (or more) each. The rules are GiftState's (pure); the
## game's side (HeroGifts, Combat, Player, Rooms) is checked in a real run.

const L := ComboNode.In.LIGHT
const SPIN: Array[StringName] = [&"light", &"spin", &"finisher"]
const CUT: Array[StringName] = [&"light"]
const DASH: Array[StringName] = [&"light", &"dash"]
const LANCE: Array[StringName] = [&"heavy", &"omega", &"thrust", &"lance"]
const BOLT: Array[StringName] = [&"heavy", &"wave"]

var game: Game


## The rules with these Gifts equipped (none: the game of before).
func _state(ids: Array[StringName] = []) -> GiftState:
	var boons := BoonState.new()
	boons.equip_talents(HeroDef.warrior().talents().defs(ids))
	return GiftState.new(HeroDef.warrior(), boons)


## A run in the fountain room (nobody else), the paladin at the middle, with these Gifts.
func _run(ids: Array[StringName] = []) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.equip_talents(ids)


func _enemy(id: StringName, at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(at, 0.6), false)
	e.cooldown = 99.0
	return e


func _node(tree: ComboTree, id: StringName) -> ComboNode:
	for n in tree.all_nodes():
		if n.id == id:
			return n
	return null


func _spin() -> ComboNode:
	return _node(game.player.tree, &"cut3")


# ---------- the passive (P-A) ----------

func test_the_passive_gives_two_of_magia_for_each_finisher_that_lands() -> void:
	var s := _state()
	assert_eq(s.passive_magick(SPIN, 1), 2.0, "the spin")
	assert_eq(s.passive_magick(DASH, 1), 0.0, "GP-1 (D-4): the Investida left; a `dash` blow refunds nothing")
	assert_eq(s.passive_magick(LANCE, 1), 0.0, "GP-1 (D-4): the Lança pays, it does not refund")
	assert_eq(s.passive_magick(BOLT, 1), 0.0, "the rajada is no finisher (2026-11-21: the special's Omega left)")
	assert_eq(s.passive_magick(SPIN, 0), 0.0, "a finisher in the air gives nothing")
	assert_eq(s.passive_magick(CUT, 3), 0.0, "a plain cut is no finisher")
	assert_eq(s.passive_magick(BOLT, 1), 0.0, "nor the plain special")


func test_an_ultimate_blow_never_feeds_the_passive() -> void:
	var s := _state()
	for list: Array in [[&"ultimate", &"light"], [&"ultimate", &"cast"], [&"ultimate", &"finisher", &"omega"]]:
		var tags: Array[StringName] = []
		tags.assign(list)
		assert_false(s.is_finisher(tags), "%s" % [tags])
		assert_eq(s.passive_magick(tags, 5), 0.0, "%s" % [tags])


func test_the_passive_counts_once_a_blow_and_never_past_the_maximum() -> void:
	_run()
	var p := game.player
	for k in 3:
		_enemy(&"skeleton", Vector2.from_angle(TAU * k / 3.0) * 1.6)
	p.magick.value = 10.0
	game.combat.strike(_spin(), p.pos, Vector2.RIGHT)
	assert_eq(p.magick.value, 12.5, "three hit: two of Magia once (the passive) and 0.5 once (C1c, a hit of the attack)")
	p.magick.value = p.magick.max_value - 1.0
	game.combat.landed.emit(_spin(), SPIN, 1)
	assert_eq(p.magick.value, p.magick.max_value, "never past the maximum")
	p.magick.value = 10.0
	game.combat.strike(_node(p.tree, &"cut1"), p.pos, Vector2.RIGHT)
	assert_eq(p.magick.value, 10.5, "a plain cut gives only its 0.5 a hit (C1c), no passive")


func test_the_lance_and_the_smash_give_no_magia() -> void:
	_run()
	var p := game.player
	for k in 3:
		_enemy(&"skeleton", Vector2(3.0 + k * 1.2, 0))
	p.magick.value = 10.0
	game.combat.strike(_node(p.tree, &"lance"), p.pos, Vector2.RIGHT)
	assert_eq(p.magick.value, 10.0, "the Lança struck three and gave nothing: no finisher (D-4)")
	game.combat.strike(_node(p.tree, &"smash"), p.pos, Vector2.RIGHT)
	assert_eq(p.magick.value, 10.0, "nor the Esmagador")

func test_no_passive_turns_it_off_for_comparisons() -> void:
	var s := _state()
	s.passive = false
	assert_eq(s.passive_magick(SPIN, 1), 0.0)


# ---------- with no Gift, the game of before ----------

func test_with_no_gift_every_rule_answers_the_game_of_before() -> void:
	var s := _state()
	assert_eq(s.attack_speed(), 1.0)
	assert_eq(s.attack_speed(CUT), 1.0)
	assert_false(s.chain_hit(DASH), "only the attack's blows count in the sequence")
	assert_eq(float(s.wave(SPIN).damage), 0.0)
	assert_false(s.rise())
	assert_eq(s.room_heal(), 0.0)


# ---------- the catalog: three branches of four, no Fúria ----------

const LEVELS := {&"disciplina": [1, 2], &"cadencia": [4, 2], &"maestria_marcial": [9, 3], &"apogeu": [16, 4],
	&"forca_concentrada": [2, 2], &"determinacao": [6, 2], &"concentracao": [11, 3], &"forca_titanica": [17, 4],
	&"ruptura": [3, 2], &"alcance_marcial": [8, 3], &"imposicao": [13, 3], &"investida_implacavel": [18, 4]}


func test_the_catalog_is_three_branches_of_four() -> void:
	var cat := HeroDef.warrior().talents().catalog
	assert_eq(cat.size(), 12)
	for b: TalentDef.Branch in [TalentDef.Branch.COMBO, TalentDef.Branch.IMPETO, TalentDef.Branch.DOMINIO]:
		var of := cat.filter(func(t: TalentDef) -> bool: return t.branch == b)
		assert_eq(of.size(), 4, "branch %d" % b)
		for tier: TalentDef.Tier in [TalentDef.Tier.ENTRY, TalentDef.Tier.MIDDLE, TalentDef.Tier.APEX]:
			var n := of.filter(func(t: TalentDef) -> bool: return t.tier == tier).size()
			assert_eq(n, 2 if tier == TalentDef.Tier.MIDDLE else 1, "branch %d tier %d" % [b, tier])
	for t in cat:
		assert_true(LEVELS.has(t.id), String(t.id))
		assert_eq([t.unlock_level, t.cost], LEVELS[t.id], String(t.id))
		assert_eq(t.slot, Boon.Slot.NONE, "%s takes no button" % t.id)
		assert_true(not t.mods.is_empty() or t.combos != "", "%s has numbers or a combo tree" % t.id)
		for m in t.mods:
			assert_false(String(m.stat).begins_with("fury"), "no Fúria")
		if t.tier == TalentDef.Tier.ENTRY:
			assert_eq(t.needs, &"")
		else:
			var needed := HeroDef.warrior().talents().find(t.needs)
			assert_not_null(needed, "%s needs a Gift that exists" % t.id)
			assert_eq(needed.branch, t.branch)


func test_the_apexes_need_what_the_package_says() -> void:
	var book := HeroDef.warrior().talents()
	assert_eq(book.find(&"apogeu").needs, &"maestria_marcial")
	assert_eq(book.find(&"forca_titanica").needs, &"forca_concentrada")
	assert_eq(book.find(&"investida_implacavel").needs, &"imposicao")
	var apogeu := book.find(&"apogeu")
	assert_false(Talents.needs_met(apogeu, book.defs([&"disciplina"] as Array[StringName])))
	assert_true(Talents.needs_met(apogeu, book.defs([&"disciplina", &"maestria_marcial"] as Array[StringName])))


func test_the_fury_is_gone() -> void:
	var s := _state()
	assert_false("fury" in s)
	assert_false(s.has_method(&"on_kill"))
	assert_false(s.has_method(&"fury_full_pct"))


# ---------- Combo ----------

func test_disciplina_keeps_the_sequence_through_a_dodge_for_two_seconds() -> void:
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	for keep: float in [0.0, 2.0]:
		var runner := ComboRunner.new(tree)
		runner.dodge_keep = keep
		var started: Array[StringName] = []
		var lost := [0]
		runner.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
		runner.chain_lost.connect(func() -> void: lost[0] += 1)
		runner.press(L)
		runner.step(0.0)
		for k in int((runner.node.duration() + 0.01) * 120.0):
			runner.step(1.0 / 120.0)
		runner.on_dodge()
		runner.on_dodge_end()
		for k in 120:  # a second later
			runner.step(1.0 / 120.0)
		runner.press(L)
		runner.step(0.0)
		assert_eq(started.back(), &"cut2" if keep > 0.0 else &"cut1", "keep %s" % keep)
		assert_eq(lost[0], 0 if keep > 0.0 else 1, "the dodge drops the sequence only without Disciplina")


func test_disciplina_expires_after_its_two_seconds() -> void:
	var runner := ComboRunner.new(load("res://data/combos/paladin.tres"))
	runner.dodge_keep = 2.0
	var started: Array[StringName] = []
	var lost := [0]
	runner.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
	runner.chain_lost.connect(func() -> void: lost[0] += 1)
	runner.press(L)
	runner.step(0.0)
	for k in int((runner.node.duration() + 0.01) * 120.0):
		runner.step(1.0 / 120.0)
	runner.on_dodge()
	runner.on_dodge_end()
	for k in 300:  # 2.5 s
		runner.step(1.0 / 120.0)
	assert_eq(lost[0], 1, "the sequence is lost once the keeping runs out")
	runner.press(L)
	runner.step(0.0)
	assert_eq(started.back(), &"cut1")


func test_a_blow_taken_loses_the_sequence() -> void:
	var runner := ComboRunner.new(load("res://data/combos/paladin.tres"))
	var lost := [0]
	runner.chain_lost.connect(func() -> void: lost[0] += 1)
	runner.press(L)
	runner.step(0.0)
	runner.reset(false)
	assert_eq(lost[0], 1)


func test_cadencia_is_eight_percent_a_blow_of_the_sequence_for_the_attack_only() -> void:
	var s := _state([&"cadencia"])
	assert_eq(s.attack_speed(CUT), 1.0, "the opener")
	assert_true(s.chain_hit(CUT))
	assert_true(s.chain_hit(CUT))
	assert_almost_eq(s.attack_speed(CUT), 1.16, 0.0001)
	assert_eq(s.attack_speed(DASH), 1.0, "not the Investida")
	assert_eq(s.attack_speed(BOLT), 1.0, "not the special")
	assert_eq(s.attack_speed(LANCE), 1.0, "not the Golpe Carregado")
	s.chain_reset()
	assert_eq(s.attack_speed(CUT), 1.0)
	assert_eq(_state().attack_speed(CUT), 1.0, "nothing without the Gift")


func test_cadencia_in_the_game_counts_the_blows_that_land_and_starts_over_at_the_opener() -> void:
	_run([&"cadencia"])
	var state := game.hero_gifts.state
	game.hero_gifts._on_move_hit(_node(game.player.tree, &"cut1"))
	game.hero_gifts._on_move_hit(_node(game.player.tree, &"cut2"))
	game.hero_gifts._on_move_hit(_node(game.player.tree, &"lance"))
	assert_eq(state.chain_n, 2, "the Lança is no blow of the sequence")
	game.hero_gifts.step(0.0)
	game.player.runner.speed = state.attack_speed(CUT)
	assert_almost_eq(game.player.runner.speed, 1.16, 0.0001)
	game.hero_gifts._on_move_started(_node(game.player.tree, &"cut2"))
	assert_eq(state.chain_n, 2, "a follower goes on")
	game.hero_gifts._on_move_started(_node(game.player.tree, &"cut1"))
	assert_eq(state.chain_n, 0, "the opener starts over")


func test_maestria_marcial_plays_five_blows_ending_in_the_spin() -> void:
	_run([&"maestria_marcial"])
	assert_eq(game.player.tree.resource_path, "res://data/combos/paladin_fifth.tres")
	var runner := ComboRunner.new(game.player.tree)
	var started: Array[StringName] = []
	runner.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
	for i in 5:
		runner.press(L)
		runner.step(0.0)
		for k in int((runner.node.duration() + 0.02) * 120.0):
			runner.step(1.0 / 120.0)
	assert_eq(started, [&"cut1", &"cut2", &"thrust4", &"cut4", &"cut3"] as Array[StringName])
	var plain: ComboTree = load("res://data/combos/paladin.tres")
	for id: StringName in [&"cut1", &"cut2", &"cut3"]:
		assert_eq(_node(game.player.tree, id).tags, _node(plain, id).tags, "%s keeps its tags" % id)
	for id: StringName in [&"thrust4", &"cut4"]:
		assert_true(_node(game.player.tree, id).has_tag(&"light"), "%s is a blow of the attack" % id)
	assert_true(_node(game.player.tree, &"cut3").has_tag(&"finisher"), "the spin is still last")


## The loss of life of an enemy that one blow caused.
func _strike_loss(e: Enemy, id: StringName) -> float:
	var before := e.hp
	game.combat.strike(_node(game.player.tree, id), game.player.pos, Vector2.RIGHT)
	return before - e.hp


func test_apogeu_adds_one_and_a_half_times_the_sequence_to_the_last_blow() -> void:
	_run([&"maestria_marcial", &"apogeu"])
	var e := _enemy(&"skeleton", Vector2(1.5, 0))
	e.hp = 5000.0
	var sum := 0.0
	for id: StringName in [&"cut1", &"cut2", &"thrust4", &"cut4"]:
		sum += _strike_loss(e, id)
	assert_gt(sum, 0.0)
	assert_eq(game.combat.apogee.total(e.get_instance_id()), sum, "the books hold what the sequence dealt")
	var spin := _strike_loss(e, &"cut3")
	assert_eq(spin, 90.0 + minf(roundf(sum * 1.5), 270.0), "the spin and the share, never past 400% of itself")
	assert_eq(game.combat.apogee.total(e.get_instance_id()), 0.0, "the Apogeu blow spends the books and is not added")
	assert_eq(_strike_loss(e, &"cut3"), 90.0, "no second helping: no recursion")


func test_apogeu_is_a_share_of_the_sum_when_it_is_under_the_cap() -> void:
	var ledger := ApogeeLedger.new()
	ledger.add(7, 10.0)
	ledger.add(7, 10.0)
	assert_eq(ledger.finisher(7, 1.5, 20.0), 30.0)


func test_what_is_no_blow_of_the_sequence_never_enters_the_books() -> void:
	_run([&"maestria_marcial", &"apogeu"])
	var e := _enemy(&"skeleton", Vector2(1.5, 0))
	e.hp = 5000.0
	var id := e.get_instance_id()
	for node_id: StringName in [&"smash", &"lance", &"sweep"]:
		game.combat.strike(_node(game.player.tree, node_id), game.player.pos, Vector2.RIGHT)
	for i in 30:
		game.projectiles.step(1.0 / 60.0)
	assert_eq(game.combat.apogee.total(id), 0.0, "the Esmagador, the Lança, the Corte Circular")
	game.combat.hit_enemy(e, 10.0, [&"echo", &"light"] as Array[StringName], Vector2.RIGHT, 0.0, false)
	game.combat.hit_enemy(e, 10.0, [&"ember", &"chama"] as Array[StringName], Vector2.ZERO, 0.0, false)
	assert_eq(game.combat.apogee.total(id), 0.0, "an echo or a burn")


func test_the_books_close_on_a_death_and_when_the_sequence_starts_over() -> void:
	_run([&"maestria_marcial", &"apogeu"])
	var e := _enemy(&"skeleton", Vector2(1.5, 0))
	e.hp = 5000.0
	_strike_loss(e, &"cut1")
	assert_gt(game.combat.apogee.total(e.get_instance_id()), 0.0)
	game.hero_gifts._on_killed(e)
	assert_eq(game.combat.apogee.total(e.get_instance_id()), 0.0, "death")
	_strike_loss(e, &"cut1")
	game.hero_gifts._on_chain_lost()
	assert_eq(game.combat.apogee.size(), 0, "the sequence is over")


# ---------- Ímpeto ----------

func test_forca_concentrada_adds_forty_percent_to_the_golpe_carregado_only() -> void:
	var s := _state([&"forca_concentrada"])
	assert_eq(s.value(&"damage_pct", LANCE), 0.4)
	assert_eq(s.value(&"damage_pct", CUT), 0.0)


func test_the_golpe_carregado_damage_is_the_sum_then_forca_titanica_triples_it() -> void:
	var losses := {}
	for ids: Array in [[], [&"forca_concentrada"], [&"forca_titanica"], [&"forca_concentrada", &"forca_titanica"]]:
		var typed: Array[StringName] = []
		typed.assign(ids)
		_run(typed)
		var e := _enemy(&"skeleton", Vector2(1.5, 0))
		e.hp = 5000.0
		losses[ids.size() * 10 + (1 if ids.has(&"forca_titanica") else 0)] = _strike_loss(e, &"lance")
	var base: float = losses[0]
	assert_eq(base, 375.0)
	assert_eq(losses[10], 525.0, "Força Concentrada: +40%")
	assert_eq(losses[11], 1125.0, "Força Titânica: x3")
	assert_eq(losses[21], 1575.0, "x3 final after Força Concentrada's +40%")


func test_forca_titanica_raises_the_cost_and_never_leaves_negative_magia() -> void:
	_run([&"forca_titanica"])
	game.hero_gifts.step(0.0)
	var p := game.player
	var lance := _node(p.tree, &"lance")
	assert_eq(p.magick.max_value, 40.0, "the Gift raises the bar by 10")
	assert_eq(p.cost_of(lance, 0.0), 40.0, "x2: the whole bar")
	assert_eq(p.cost_of(_node(p.tree, &"smash"), 0.0), 24.0)
	assert_eq(p.cost_of(_node(p.tree, &"sweep"), 0.0), 0.0, "the Corte Circular is no Golpe Carregado (and free)")
	assert_eq(Player.omega_cost(20.0, 1.2, 1.0), 0.0, "never under zero")
	p.magick.value = 30.0
	assert_false(p._affordable(ComboNode.In.CHARGE), "30 does not pay 40: no charge starts, the button is refused")
	assert_false(p.magick.spend(40.0))
	assert_eq(p.magick.value, 30.0, "nothing was taken")
	p.magick.value = 40.0
	assert_true(p._affordable(ComboNode.In.CHARGE))
	_run()
	game.hero_gifts.step(0.0)
	game.player.magick.value = 30.0
	assert_true(game.player._affordable(ComboNode.In.CHARGE), "without the Gift 30 pays 20")

func test_a_charge_cancelled_costs_nothing() -> void:
	_run([&"forca_titanica"])
	game.hero_gifts.step(0.0)
	var p := game.player
	p.magick.value = 50.0
	p._charge_held = ComboNode.In.CHARGE_LIGHT
	p.charging = true
	p._end_charge()
	assert_eq(p.magick.value, 50.0, "the Magia goes only when the blow starts")


func test_concentracao_charges_thirty_percent_faster_at_the_same_cost() -> void:
	_run([&"concentracao"])
	game.hero_gifts.step(0.0)
	var p := game.player
	p._charge_held = ComboNode.In.CHARGE_LIGHT
	assert_almost_eq(p._charge_time(), 0.42, 0.0001, "the Esmagador: 0.6 x 0.7")
	p._charge_held = ComboNode.In.CHARGE
	assert_almost_eq(p._charge_time(), 0.56, 0.0001, "the Lança: 0.8 x 0.7")
	assert_eq(p.cost_of(_node(p.tree, &"lance"), 0.0), 20.0)
	_run()
	game.hero_gifts.step(0.0)
	game.player._charge_held = ComboNode.In.CHARGE_LIGHT
	assert_almost_eq(game.player._charge_time(), 0.6, 0.0001)

func test_determinacao_doubles_the_magia_of_the_attack() -> void:
	for ids: Array in [[], [&"determinacao"]]:
		var typed: Array[StringName] = []
		typed.assign(ids)
		_run(typed)
		var e := _enemy(&"skeleton", Vector2(1.5, 0))
		e.hp = 5000.0
		game.player.magick.value = 10.0
		game.combat.strike(_node(game.player.tree, &"cut1"), game.player.pos, Vector2.RIGHT)
		assert_eq(game.player.magick.value, 11.0 if ids.size() > 0 else 10.5)


func test_determinacao_keeps_the_cap_on_the_gain() -> void:
	_run([&"determinacao"])
	var e := _enemy(&"skeleton", Vector2(1.5, 0))
	e.hp = 5000.0
	game.player.magick.value = 0.0
	for k in 20:
		game.combat.strike(_node(game.player.tree, &"cut1"), game.player.pos, Vector2.RIGHT)
	assert_lte(game.player.magick.value, game.hero.gain_cap + 0.001, "gain_cap per gain_window still holds")


# ---------- Domínio ----------

func test_ruptura_breaks_armor_faster_with_the_finisher() -> void:
	var s := _state([&"ruptura"])
	assert_eq(s.value(&"poise_pct", SPIN), 0.5)
	assert_eq(s.value(&"poise_pct", CUT), 0.0)


func test_alcance_marcial_widens_and_pushes_the_corte_circular() -> void:
	var s := _state([&"alcance_marcial"])
	var sweep: Array[StringName] = [&"shout", &"cast", &"sweep"]
	assert_eq(s.value(&"reach_pct", sweep), 0.25)
	assert_eq(s.value(&"push_pct", sweep), 0.3)
	assert_eq(s.value(&"damage_pct", sweep), 0.0, "no damage: reach and push only")
	assert_eq(s.value(&"reach_pct", CUT), 0.0)

func test_imposicao_lengthens_the_quebra_stun() -> void:
	var stuns := []
	for ids: Array in [[], [&"imposicao"]]:
		var typed: Array[StringName] = []
		typed.assign(ids)
		_run(typed)
		var e := _enemy(&"skeleton", Vector2(1.5, 0))
		e.hp = 5000.0
		e.poise = 0.01
		game.combat.strike(_node(game.player.tree, &"cut1"), game.player.pos, Vector2.RIGHT)
		stuns.append(e.stun_t)
		assert_eq(game.horde.break_scale, 1.0, "set around the blow only")
	assert_gt(stuns[0], 0.0, "the Quebra stuns")
	assert_almost_eq(stuns[1], stuns[0] * 1.5, 0.001)


func test_the_stun_rule_has_one_exception_the_investida_that_goes_through() -> void:
	assert_true(StunRule.dash_stuns(true, 1.0))
	assert_false(StunRule.dash_stuns(false, 1.0), "elites and guardians are never stunned this way")
	assert_false(StunRule.dash_stuns(true, 0.0), "no stun without the Gift")


func test_investida_implacavel_stuns_everyone_the_roll_goes_through_two_seconds() -> void:
	_run([&"investida_implacavel"])
	game.hero_gifts.step(0.0)
	assert_true(game.player.dash_pierce)
	var crowd: Array[Enemy] = []
	for k in 3:
		var e := _enemy(&"skeleton", Vector2(1.5 + k * 1.0, 0))
		e.hp = 5000.0
		crowd.append(e)
	game.combat.dodge_through(game.player.pos, Vector2(4.8, 0))
	for e in crowd:
		assert_almost_eq(e.stun_t, 2.0, 0.001, "2 s each")
	game.combat.strike(_node(game.player.tree, &"cut1"), game.player.pos, Vector2.RIGHT)
	assert_almost_eq(crowd[0].stun_t, 2.0, 0.001, "a plain blow adds none: it is one stun a passage")

func test_without_the_gift_the_roll_stuns_no_one() -> void:
	_run()
	var e := _enemy(&"skeleton", Vector2(1.5, 0))
	e.hp = 5000.0
	game.combat.dodge_through(game.player.pos, Vector2(4.8, 0))
	assert_lt(e.stun_t, 2.0, "no 2 s stun")
	game.hero_gifts.step(0.0)
	assert_false(game.player.dash_pierce)

func test_the_roll_takes_the_quebra_of_the_dodge_from_a_boss_and_stuns_him_never() -> void:
	_run([&"investida_implacavel"])
	var e := _enemy(&"skeleton", Vector2(1.5, 0))
	e.def = e.def.duplicate()
	e.def.behavior = EnemyDef.Behavior.BOSS
	var seen: Array[StringName] = []
	game.horde.boss_blow.connect(func(_t: Enemy, src: StringName) -> void: seen.append(src))
	game.combat.dodge_through(game.player.pos, Vector2(4.8, 0))
	assert_eq(seen, [&"dash"] as Array[StringName], "the Quebra of the dodge (weight 0.5)")
	assert_eq(e.stun_t, 0.0)

func test_the_armored_take_more_from_the_roll_and_are_not_stunned() -> void:
	var s := _state([&"investida_implacavel"])
	assert_eq(s.value(&"poise_pct", DASH), 0.5, "x1.5 of armor damage")
	assert_eq(s.value(&"poise_pct", SPIN), 0.0)
	_run([&"investida_implacavel"])
	var e := _enemy(&"skeleton", Vector2(1.5, 0))
	e.def = e.def.duplicate()
	e.def.elite = true
	game.combat.dodge_through(game.player.pos, Vector2(4.8, 0))
	assert_eq(e.stun_t, 0.0)


# ---------- Lote R1 (backlog 2026-11-24 noite) ----------
## Stats some code reads while StunRule is NONE (an inert stat would make a Gift that does nothing).
const LIVE_STATS: Array[StringName] = [&"dodge_window_add", &"cadence_pct", &"apogee_pct", &"damage_pct", &"attack_magick_pct",
	&"charge_time_pct", &"omega_cost_pct", &"final_pct", &"poise_pct", &"reach_pct", &"push_pct", &"stun_pct", &"dash_pierce", &"dash_stun"]

func test_every_gift_changes_some_number_with_the_stun_rule_none() -> void:
	StunRule.live = StunRule.Mode.NONE
	var cat := HeroDef.warrior().talents().catalog
	for t: TalentDef in cat:
		if t.combos != "":
			continue  # Maestria Marcial: a tree of five blows, tested above
		var changed := false
		for m in t.mods:
			var tags: Array[StringName] = []
			if m.tag != &"":
				tags.append(m.tag)
			var ids: Array[StringName] = [t.id]
			var s := _state(ids)
			if LIVE_STATS.has(m.stat) and not is_zero_approx(s.value(m.stat, tags)):
				changed = true
		assert_true(changed, "%s changes a number" % t.id)
	# the two that were tied to the stun: Voz do Leão interrupts the common (an exception), Imposição is the Quebra of every blow
	assert_true(StunRule.shout_stuns(true, 0.5))
	assert_false(StunRule.shout_stuns(false, 0.5))
	assert_false(StunRule.shout_stuns(true, 0.0))


func test_the_twelve_gifts_cost_28_to_32_memory() -> void:
	var total := 0
	for t: TalentDef in HeroDef.warrior().talents().catalog:
		total += t.memory_cost
		if t.unlock_level >= 2 and t.unlock_level <= 5:
			assert_eq(t.memory_cost, 1, "%s: Mastery 2 to 5 costs 1" % t.id)
	assert_between(total, 28, 32)


## The timing of a blow of the tree as it plays (seconds): [windup, recovery] over the speed the Gifts give it.
func _timing(id: StringName, speed: float) -> Array[float]:
	var n := _node(game.player.tree, id)
	return [n.windup / speed, n.recovery / speed]


func test_with_no_gift_the_blows_play_as_before_the_redesign() -> void:
	# CF-02: the feel probe (42 scenarios) printed the same lines at d841c81 and here; these are the frames of the blows 1 to 3
	_run()
	assert_eq(game.hero_gifts.state.attack_speed(CUT), 1.0)
	assert_eq(game.hero_gifts.state.attack_speed(SPIN), 1.0)
	var f := func(id: StringName) -> Array:
		var n := _node(game.player.tree, id)
		return [roundi(n.windup * 60.0), roundi(n.recovery * 60.0)]
	assert_eq(f.call(&"cut1"), [5, 8])
	assert_eq(f.call(&"cut2"), [8, 13])
	assert_eq(f.call(&"cut3"), [17, 18], "the glint is added on top, as before")


func test_cadence_and_maestria_keep_the_blows_in_order() -> void:
	# CF-03: the 8% a blow stops at 24% (3 blows), so the fifth blow is never played as fast as the first one
	var s := _state([&"cadencia"])
	for i in 5:
		s.chain_hit(CUT)
	assert_almost_eq(s.attack_speed(CUT), 1.0 + GiftState.CADENCE_CAP, 0.0001)
	_run([&"cadencia", &"maestria_marcial"])
	var speed := 1.0 + GiftState.CADENCE_CAP
	var spin := _timing(&"cut3", speed)
	var first := _timing(&"cut1", 1.0)
	assert_gt(spin[0] * 60.0, first[0] * 60.0 + 4.0, "the finisher's preparation is 4 frames or more over the opener's")
	for id: StringName in [&"cut3", &"cut4", &"thrust4"]:
		assert_gte(_timing(id, speed)[1] * 60.0, 6.0, "%s recovers for 6 frames or more" % id)
	assert_gt(_timing(&"cut4", speed)[0], first[0] * 1.1, "the fourth blow does not wind up like the first")


func test_apogeu_lands_with_a_long_hit_stop_a_shake_and_a_sound() -> void:
	_run([&"maestria_marcial", &"apogeu"])
	var e := _enemy(&"skeleton", Vector2(1.5, 0))
	e.hp = 5000.0
	game.fx.hits.clear()
	_strike_loss(e, &"cut1")
	var plain := game.fx.hits.left()
	for id: StringName in [&"cut2", &"thrust4", &"cut4"]:
		_strike_loss(e, id)
	game.fx.hits.clear()
	_strike_loss(e, &"cut3")
	assert_gte(game.fx.hits.left() * 1000.0, 65.0, "Apogeu: 65 ms or more")
	assert_gt(game.fx.hits.left(), plain)
	assert_false(game.combat._apogee_landed, "spent")
